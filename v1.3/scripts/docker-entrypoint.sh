#!/bin/bash

# Enable better error handling
set -euo pipefail

# Setup logging
LOG_DIR="/workspace/logs"
ERROR_LOG="${LOG_DIR}/entrypoint.error.log"

# Create log directory with proper permissions
if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p "${LOG_DIR}"
    chown -R ds-user-ds:users "${LOG_DIR}"
    chmod 755 "${LOG_DIR}"
fi

LOGFILE="${LOG_DIR}/entrypoint.log"
touch "${LOGFILE}" "${ERROR_LOG}" || {
    echo "Error: Cannot create log files. Please check permissions."
    exit 1
}

# Setup structured logging
exec > >(tee -a "${LOGFILE}") 2> >(tee -a "${ERROR_LOG}" >&2)

log() {
    local level="INFO"
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"level\":\"${level}\",\"message\":\"$*\"}" | tee -a "${LOGFILE}"
}

error() {
    local level="ERROR"
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"level\":\"${level}\",\"message\":\"$*\"}" | tee -a "${ERROR_LOG}" >&2
    exit 1
}

warn() {
    local level="WARNING"
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"level\":\"${level}\",\"message\":\"$*\"}" | tee -a "${LOGFILE}" >&2
}

# Setup signal handlers
cleanup() {
    log "Caught signal, cleaning up..."
    # Cleanup temporary files
    find /tmp -type f -name "jupyter-*" -delete
    exit 0
}

trap cleanup SIGTERM SIGINT SIGQUIT

# Check NVIDIA runtime and GPU memory
check_nvidia_runtime() {
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        log "Checking NVIDIA runtime..."
        if ! command -v nvidia-smi &>/dev/null; then
            error "NVIDIA runtime not detected. Check Docker GPU setup."
        fi
        
        # Check NVIDIA driver version
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
        local min_version="450.80.02"
        if [[ "$(printf '%s\n' "$min_version" "$driver_version" | sort -V | head -n1)" != "$min_version" ]]; then
            error "NVIDIA driver version must be >= $min_version (current: $driver_version)"
        fi
        
        # Check GPU memory
        local gpu_memory_free=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | awk '{print $1}')
        if [ "${gpu_memory_free}" -lt 1000 ]; then
            warn "Low GPU memory available (${gpu_memory_free}MB free, <1GB)"
        fi
        
        # Check GPU utilization
        local gpu_utilization=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
        if [ "${gpu_utilization}" -gt 80 ]; then
            warn "High GPU utilization (${gpu_utilization}%)"
        fi
        
        log "NVIDIA runtime check passed: Driver version $driver_version, ${gpu_memory_free}MB free"
    fi
}

# Check workspace disk space
check_workspace_space() {
    log "Checking workspace disk space..."
    local min_space_mb=1000  # 1GB minimum
    local available_space_mb=$(df -BM /workspace --output=avail | tail -1 | tr -d 'M')
    local total_space_mb=$(df -BM /workspace --output=size | tail -1 | tr -d 'M')
    local used_space_mb=$(df -BM /workspace --output=used | tail -1 | tr -d 'M')
    
    # Calculate usage percentage
    local usage_percent=$((used_space_mb * 100 / total_space_mb))
    
    if [ "$available_space_mb" -lt "$min_space_mb" ]; then
        warn "Low disk space on /workspace: ${available_space_mb}MB available (< ${min_space_mb}MB)"
    fi
    
    # Check if workspace is getting full (>80% used)
    if [ "$usage_percent" -gt 80 ]; then
        warn "High disk usage on /workspace: ${usage_percent}% used (${available_space_mb}MB free)"
    fi
    
    # Log disk space metrics
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"type\":\"metric\",\"name\":\"disk_space\",\"total_mb\":${total_space_mb},\"used_mb\":${used_space_mb},\"available_mb\":${available_space_mb},\"usage_percent\":${usage_percent}}" >> "${LOGFILE}"
    
    log "Disk space check completed"
}

# Check system resources
check_system_resources() {
    log "Checking system resources..."
    
    # Check memory usage
    local total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local free_mem_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local used_mem_kb=$((total_mem_kb - free_mem_kb))
    local mem_usage_percent=$((used_mem_kb * 100 / total_mem_kb))
    
    if [ "$mem_usage_percent" -gt 80 ]; then
        warn "High memory usage: ${mem_usage_percent}% (${free_mem_kb}KB free)"
    fi
    
    # Check CPU load
    local cpu_load=$(cat /proc/loadavg | cut -d' ' -f1)
    local cpu_count=$(nproc)
    local cpu_load_percent=$(awk -v load="$cpu_load" -v cores="$cpu_count" 'BEGIN {printf "%.0f\n", load/cores*100}')
    
    if [ "$cpu_load_percent" -gt 80 ]; then
        warn "High CPU load: ${cpu_load_percent}% (load: ${cpu_load})"
    fi
    
    # Log resource metrics
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"type\":\"metric\",\"name\":\"system_resources\",\"memory_usage_percent\":${mem_usage_percent},\"cpu_load_percent\":${cpu_load_percent}}" >> "${LOGFILE}"
    
    log "System resource check completed"
}

# Validate required environment variables
validate_environment() {
    log "Validating environment variables..."
    
    # Optional variables with defaults
    export TZ=${TZ:-UTC}
    export PYTHONGC=${PYTHONGC:-2}  # Aggressive garbage collection
    
    # Check GPU-specific variables if GPU is enabled
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        export NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-0}
        export NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-"compute,utility,graphics,display"}
        export NVIDIA_REQUIRE_CUDA=${NVIDIA_REQUIRE_CUDA:-"cuda>=11.8"}
        export NVIDIA_MEM_MAX_PERCENT=${NVIDIA_MEM_MAX_PERCENT:-75}
        export NVIDIA_GPU_MEM_FRACTION=${NVIDIA_GPU_MEM_FRACTION:-0.6}
        
        # Set Python environment variables for GPU
        export CUDA_DEVICE_ORDER="PCI_BUS_ID"
        export CUDA_CACHE_PATH="/workspace/.cache/cuda"
        export TORCH_HOME="/workspace/.cache/torch"
    fi
    
    # Set Python environment variables
    export PYTHONUNBUFFERED=1
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONHASHSEED=random
}

# Function to generate Jupyter configuration
generate_jupyter_password() {
    log "Setting up Jupyter configuration..."
    
    # Create jupyter config directory if it doesn't exist
    mkdir -p ${HOME}/.jupyter
    
    # Check if mounted password file exists
    if [ ! -f "${HOME}/.jupyter/jupyter_server_config.json" ]; then
        log "Password configuration file not found, generating default password..."
        # Generate a random password
        local password=$(openssl rand -hex 8)
        # Generate salt
        local salt=$(openssl rand -hex 6)
        # Generate password hash
        local password_hash=$(echo -n "${password}${salt}" | openssl dgst -sha1 | cut -d' ' -f2)
        
        # Create config with the hash and extension settings
        cat > "${HOME}/.jupyter/jupyter_server_config.json" << EOF
{
  "ServerApp": {
    "password": "sha1:${salt}:${password_hash}",
    "allow_root": false,
    "allow_remote_access": true,
    "ip": "0.0.0.0",
    "port": 8888,
    "open_browser": false,
    "webbrowser_open_new": 0,
    "allow_origin": "*",
    "disable_check_xsrf": false,
    "terminado_settings": {
      "shell_command": ["/bin/bash"]
    }
  },
  "LanguageServerManager": {
    "enabled": true
  },
  "LSPExtension": {
    "language_servers": {
      "pylsp": {
        "serverSettings": {
          "pylsp.plugins.jedi_completion.enabled": true,
          "pylsp.plugins.jedi_definition.enabled": true,
          "pylsp.plugins.jedi_hover.enabled": true,
          "pylsp.plugins.jedi_references.enabled": true,
          "pylsp.plugins.jedi_signature_help.enabled": true,
          "pylsp.plugins.jedi_symbols.enabled": true
        }
      }
    }
  }
}
EOF
        log "Generated new Jupyter password: ${password}"
        log "Please save this password for future access!"
    else
        log "Using mounted Jupyter password configuration"
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
        
        # Log GPU information
        nvidia-smi --query-gpu=gpu_name,driver_version,memory.total,memory.free,memory.used,temperature.gpu --format=csv,noheader | \
        awk -F, '{printf "{\"timestamp\":\"%s\",\"type\":\"gpu_info\",\"gpu_name\":\"%s\",\"driver_version\":\"%s\",\"memory_total\":\"%s\",\"memory_free\":\"%s\",\"memory_used\":\"%s\",\"temperature\":\"%s\"}\n", strftime("%Y-%m-%dT%H:%M:%S%z"), $1, $2, $3, $4, $5, $6}' >> "${LOGFILE}"
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
    # Create all required workspace directories
    mkdir -p /workspace/{projects,datasets,logs}
    
    # Set proper ownership for all workspace directories
    chown -R $(id -u):$(id -g) /workspace
    
    # Set specific permissions for logs directory
    chmod -R 755 /workspace/logs
    
    # Ensure log directory is writable
    if [ ! -w "/workspace/logs" ]; then
        error "Log directory is not writable. Please check permissions."
    fi
    
    # Check workspace disk space
    check_workspace_space
    
    # Check system resources
    check_system_resources
    
    log "Workspace directories setup completed"
}

# Main setup
log "Starting container setup..."

# Validate environment
validate_environment

# Check NVIDIA runtime if GPU is enabled
check_nvidia_runtime

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