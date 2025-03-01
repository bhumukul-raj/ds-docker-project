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
    
    # Required variables
    if [[ -z "${JUPYTER_PASSWORD}" ]]; then
        error "JUPYTER_PASSWORD environment variable is required"
    fi
    
    if [[ "${#JUPYTER_PASSWORD}" -lt 12 ]]; then
        error "JUPYTER_PASSWORD must be at least 12 characters long"
    fi
    
    # Optional variables with defaults
    export TZ=${TZ:-UTC}
    export MLFLOW_TRACKING_URI=${MLFLOW_TRACKING_URI:-sqlite:///workspace/mlflow.db}
}

# Function to generate Jupyter password
generate_jupyter_password() {
    log "Setting up Jupyter configuration..."
    
    # Create jupyter config directory if it doesn't exist
    mkdir -p ${HOME}/.jupyter
    
    # Write the jupyter configuration directly
    cat > ${HOME}/.jupyter/jupyter_notebook_config.py << EOF
c.ServerApp.ip = '*'
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_root = False
c.ServerApp.open_browser = False
c.ServerApp.root_dir = '/workspace'
c.ServerApp.token = '${JUPYTER_PASSWORD}'
c.ServerApp.password = ''
c.ServerApp.disable_check_xsrf = True
EOF
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
    
    # Ensure conda environment is activated
    . /opt/conda/etc/profile.d/conda.sh
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        conda activate ds-gpu
    else
        conda activate ds-cpu
    fi
    
    # Kill any existing MLflow processes
    pkill -f "mlflow server" || true
    
    # Start MLflow with proper process management
    setsid mlflow server \
        --host 0.0.0.0 \
        --port 5000 \
        --backend-store-uri "${MLFLOW_TRACKING_URI}" \
        --default-artifact-root "/workspace/mlflow" \
        >> "${LOG_DIR}/mlflow.log" 2>&1 &
    
    # Store MLflow PID
    MLFLOW_PID=$!
    echo $MLFLOW_PID > "${LOG_DIR}/mlflow.pid"
    
    # Wait for MLflow to start
    log "Waiting for MLflow to start..."
    for i in {1..30}; do
        if curl -s http://localhost:5000 > /dev/null; then
            log "MLflow server is up and running on port 5000"
            break
        elif ! kill -0 $MLFLOW_PID 2>/dev/null; then
            error "MLflow server failed to start. Check logs at ${LOG_DIR}/mlflow.log"
        fi
        sleep 1
    done
fi

# Execute main command (Jupyter)
exec "$@" 