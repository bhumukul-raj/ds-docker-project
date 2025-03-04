#!/bin/bash

# Enable better error handling
set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Version compatibility matrix
declare -A VERSION_MATRIX=(
    ["CUDA"]="11.8.0"
    ["cuDNN"]="8.9.2"
    ["Python"]="3.9"
    ["PyTorch"]="2.0.1"
    ["TensorFlow"]="2.13.0"
    ["JupyterLab"]="3.6.5"
)

# Check Docker version
check_docker_version() {
    local min_version="20.10.0"
    local current_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "0.0.0")
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]]; then
        error "Docker version must be >= $min_version (current: $current_version)"
    fi
    
    log "Docker version check passed: $current_version"
}

# Check NVIDIA drivers for GPU environment
check_nvidia_drivers() {
    if [[ "${USE_GPU:-false}" == "true" ]]; then
        if ! command -v nvidia-smi &> /dev/null; then
            error "NVIDIA drivers not found. Required for GPU environment."
        fi
        
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
        local min_version="450.80.02"
        
        if [[ "$(printf '%s\n' "$min_version" "$driver_version" | sort -V | head -n1)" != "$min_version" ]]; then
            error "NVIDIA driver version must be >= $min_version (current: $driver_version)"
        fi
        
        log "NVIDIA driver check passed: $driver_version"
    fi
}

# Check system resources
check_system_resources() {
    local min_memory=8 # GB
    local min_cpus=4
    
    # Get total memory in GB
    local total_memory=$(free -g | awk '/^Mem:/{print $2}')
    if (( total_memory < min_memory )); then
        error "Insufficient memory: ${total_memory}GB (minimum: ${min_memory}GB)"
    fi
    
    # Get CPU count
    local cpu_count=$(nproc)
    if (( cpu_count < min_cpus )); then
        error "Insufficient CPUs: ${cpu_count} (minimum: ${min_cpus})"
    fi
    
    log "System resource check passed: ${total_memory}GB RAM, ${cpu_count} CPUs"
}

# Check disk space
check_disk_space() {
    local min_space=20 # GB
    local workspace_dir="/home/${USER}/Desktop/dsi-host-workspace"
    
    # Get available disk space in GB
    local available_space=$(df -BG "$workspace_dir" | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( available_space < min_space )); then
        error "Insufficient disk space: ${available_space}GB (minimum: ${min_space}GB)"
    fi
    
    log "Disk space check passed: ${available_space}GB available"
}

# Check network connectivity
check_network() {
    local urls=(
        "https://pypi.org"
        "https://conda.anaconda.org"
        "https://github.com"
        "https://registry.hub.docker.com"
    )
    
    for url in "${urls[@]}"; do
        if ! curl --silent --head --fail "$url" &>/dev/null; then
            error "Cannot connect to $url"
        fi
    done
    
    log "Network connectivity check passed"
}

# Check port availability
check_ports() {
    local ports=(8888 8889)
    
    for port in "${ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            error "Port $port is already in use"
        fi
    done
    
    log "Port availability check passed"
}

# Main execution
main() {
    log "Starting environment validation..."
    
    check_docker_version
    check_nvidia_drivers
    check_system_resources
    check_disk_space
    check_network
    check_ports
    
    log "All validation checks passed successfully!"
    
    # Print version compatibility matrix
    echo -e "\nVersion Compatibility Matrix:"
    for key in "${!VERSION_MATRIX[@]}"; do
        echo -e "${GREEN}$key:${NC} ${VERSION_MATRIX[$key]}"
    done
}

main "$@" 