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
    exit 0
}

trap cleanup SIGTERM SIGINT SIGQUIT

# Validate required environment variables
validate_environment() {
    log "Validating environment variables..."
    
    # Optional variables with defaults
    export TZ=${TZ:-UTC}
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
    mkdir -p /workspace/projects
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

# Activate appropriate conda environment
activate_environment

# Execute the main command
log "Executing: $@"

# Execute main command (Jupyter)
exec "$@" 