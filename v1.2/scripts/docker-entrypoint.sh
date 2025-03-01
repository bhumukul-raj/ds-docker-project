#!/bin/bash

# Enable better error handling
set -euo pipefail

# Setup logging
LOG_DIR="/workspace/logs"

# Create log directory with proper permissions
if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p "${LOG_DIR}"
    chown -R ds-user-ds:users "${LOG_DIR}"
    chmod 755 "${LOG_DIR}"
fi

LOGFILE="${LOG_DIR}/entrypoint.log"
touch "${LOGFILE}" || {
    echo "Error: Cannot create log file. Please check permissions."
    exit 1
}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOGFILE}"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

# Setup signal handlers
cleanup() {
    log "Caught signal, cleaning up..."
    # Cleanup temporary files
    find /tmp -type f -name "jupyter-*" -delete
    find /tmp -type f -name "mlflow-*" -delete
    exit 0
}

trap cleanup SIGTERM SIGINT SIGQUIT

# Validate required environment variables
validate_environment() {
    log "Validating environment variables..."
    
    # Optional variables with defaults
    export TZ=${TZ:-UTC}
    export MLFLOW_TRACKING_URI=${MLFLOW_TRACKING_URI:-sqlite:///workspace/mlflow/db/mlflow.db}
}

# Function to generate Jupyter configuration
generate_jupyter_password() {
    log "Setting up Jupyter configuration..."
    
    # Create jupyter config directory if it doesn't exist
    mkdir -p ${HOME}/.jupyter
    
    # Check if mounted password file exists
    if [ -f "${HOME}/.jupyter/jupyter_server_config.json" ]; then
        log "Using mounted Jupyter password configuration"
        # No need to copy or change permissions since it's already mounted in the correct location
    else
        error "Password configuration file not found at ${HOME}/.jupyter/jupyter_server_config.json"
    fi
}

# Function to setup MLflow
setup_mlflow() {
    if [[ -n "${MLFLOW_TRACKING_URI}" ]]; then
        log "Setting up MLflow..."
        
        # Create MLflow directories with proper permissions
        MLFLOW_DB_DIR="/workspace/mlflow"
        mkdir -p "${MLFLOW_DB_DIR}"
        chown -R $(id -u):$(id -g) "${MLFLOW_DB_DIR}"
        
        # Extract database path from URI and create directory
        MLFLOW_DB_PATH=$(echo "${MLFLOW_TRACKING_URI}" | sed 's|sqlite:///||')
        MLFLOW_DB_PARENT=$(dirname "${MLFLOW_DB_PATH}")
        mkdir -p "${MLFLOW_DB_PARENT}"
        chown -R $(id -u):$(id -g) "${MLFLOW_DB_PARENT}"
        
        # Ensure database directory is writable
        touch "${MLFLOW_DB_PATH}" 2>/dev/null || {
            log "Creating MLflow database directory..."
            mkdir -p "$(dirname ${MLFLOW_DB_PATH})"
            touch "${MLFLOW_DB_PATH}"
        }
        chown $(id -u):$(id -g) "${MLFLOW_DB_PATH}"
        chmod 644 "${MLFLOW_DB_PATH}"
    fi
}

# Function to activate conda environment
activate_environment() {
    . /opt/conda/etc/profile.d/conda.sh
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        log "Activating GPU environment..."
        if ! conda activate ds-gpu; then
            error "Failed to activate GPU environment"
        fi
        
        # Verify CUDA availability
        if ! python -c "import torch; assert torch.cuda.is_available(), 'CUDA not available'"; then
            error "CUDA is not available in the GPU environment"
        fi
        
        # Set CUDA visible devices if specified
        if [[ -n "${NVIDIA_VISIBLE_DEVICES:-}" ]]; then
            export CUDA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES}
        fi
    else
        log "Activating CPU environment..."
        if ! conda activate ds-cpu; then
            error "Failed to activate CPU environment"
        fi
    fi
}

# Function to setup workspace
setup_workspace() {
    log "Setting up workspace directories..."
    mkdir -p /workspace/{projects,mlflow}
    chown -R $(id -u):$(id -g) /workspace
}

# Main setup
log "Starting container setup..."

# Validate environment
validate_environment

# Setup workspace
setup_workspace

# Setup Jupyter configuration
generate_jupyter_password

# Setup MLflow
setup_mlflow

# Activate appropriate conda environment
activate_environment

# Execute the main command
log "Executing: $@"

# Start MLflow server in the background with proper process management
if [[ -n "${MLFLOW_TRACKING_URI}" ]]; then
    log "Starting MLflow server..."
    
    # Debug: Print environment information
    log "Debug: Current working directory: $(pwd)"
    log "Debug: Contents of /workspace:"
    ls -la /workspace >> "${LOGFILE}" 2>&1
    log "Debug: Contents of ${LOG_DIR}:"
    ls -la "${LOG_DIR}" >> "${LOGFILE}" 2>&1
    
    # Ensure conda environment is activated
    . /opt/conda/etc/profile.d/conda.sh
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        ENV_NAME="ds-gpu"
    else
        ENV_NAME="ds-cpu"
    fi
    
    # Debug: Check conda environment
    log "Debug: Checking conda environment..."
    conda env list >> "${LOGFILE}" 2>&1
    log "Debug: Python path in ${ENV_NAME}:"
    conda run -n $ENV_NAME which python >> "${LOGFILE}" 2>&1
    log "Debug: MLflow path in ${ENV_NAME}:"
    conda run -n $ENV_NAME which mlflow >> "${LOGFILE}" 2>&1
    
    # Debug: Check MLflow version
    log "Debug: MLflow version:"
    conda run -n $ENV_NAME mlflow --version >> "${LOGFILE}" 2>&1
    
    # Debug: Check directory permissions
    log "Debug: Checking directory permissions..."
    log "MLflow DB parent dir permissions:"
    ls -la "$(dirname ${MLFLOW_TRACKING_URI#sqlite:///})" >> "${LOGFILE}" 2>&1
    log "MLflow artifact root permissions:"
    ls -la "${MLFLOW_DEFAULT_ARTIFACT_ROOT:-/workspace/mlflow/artifacts}" >> "${LOGFILE}" 2>&1
    
    # Start MLflow server with detailed error output
    log "Starting MLflow server with environment: $ENV_NAME"
    log "MLflow tracking URI: ${MLFLOW_TRACKING_URI}"
    log "MLflow artifact root: ${MLFLOW_DEFAULT_ARTIFACT_ROOT:-/workspace/mlflow/artifacts}"
    
    # Start MLflow with proper process management and redirect all output
    log "Debug: Starting MLflow server with full command output..."
    (conda run -n $ENV_NAME mlflow server \
        --host 0.0.0.0 \
        --port 5000 \
        --backend-store-uri "${MLFLOW_TRACKING_URI}" \
        --default-artifact-root "${MLFLOW_DEFAULT_ARTIFACT_ROOT:-/workspace/mlflow/artifacts}" \
        --workers 1 \
        2>&1 | tee -a "${LOG_DIR}/mlflow.log") &
    
    # Store MLflow PID
    MLFLOW_PID=$!
    echo $MLFLOW_PID > "${LOG_DIR}/mlflow.pid"
    log "Debug: MLflow process started with PID: $MLFLOW_PID"
    
    # Wait for MLflow to start with more detailed logging
    log "Waiting for MLflow to start (PID: $MLFLOW_PID)..."
    for i in {1..30}; do
        log "Debug: Attempt $i to connect to MLflow..."
        if curl -v http://localhost:5000 >> "${LOGFILE}" 2>&1; then
            log "MLflow server is up and running on port 5000"
            break
        elif ! kill -0 $MLFLOW_PID 2>/dev/null; then
            log "MLflow process ($MLFLOW_PID) has died. Checking logs..."
            if [ -f "${LOG_DIR}/mlflow.log" ]; then
                log "Debug: Last 20 lines of MLflow log:"
                tail -n 20 "${LOG_DIR}/mlflow.log" >> "${LOGFILE}"
                log "Debug: Process status:"
                ps aux | grep mlflow >> "${LOGFILE}" 2>&1
                log "Debug: Network status:"
                netstat -tulpn | grep 5000 >> "${LOGFILE}" 2>&1
            fi
            error "MLflow server failed to start. Check logs at ${LOG_DIR}/mlflow.log"
        fi
        sleep 1
    done
fi

# Execute main command (Jupyter)
exec "$@" 