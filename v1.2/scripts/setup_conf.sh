#!/bin/bash

# Enable better error handling
set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base workspace directory
WORKSPACE_DIR="/home/${USER}/Desktop/dsi-host-workspace"

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

# Function to verify workspace directory exists
verify_workspace() {
    if [ ! -d "${WORKSPACE_DIR}" ]; then
        error "Workspace directory ${WORKSPACE_DIR} does not exist. Please run the directory setup script first."
    fi
    log "Using workspace directory: ${WORKSPACE_DIR}"
}

# Function to generate Jupyter password files
generate_jupyter_password() {
    log "Generating Jupyter password files..."
    
    # Create the password files directory if it doesn't exist
    local password_dir="${WORKSPACE_DIR}/config/jupyter"
    mkdir -p "$password_dir"
    
    # Generate a random password (16 characters)
    local password=$(openssl rand -hex 8)
    
    # Save the readable password
    echo "$password" > "$password_dir/jupyter_password.txt"
    chmod 600 "$password_dir/jupyter_password.txt"
    
    # Generate SHA1 hash that Jupyter accepts
    local salt=$(openssl rand -hex 6)
    local password_hash=$(echo -n "${password}${salt}" | openssl dgst -sha1 | cut -d' ' -f2)
    
    # Create the config JSON with the hash
    cat > "$password_dir/jupyter_server_config.json" << EOF
{
  "ServerApp": {
    "password": "sha1:${salt}:${password_hash}"
  }
}
EOF
    
    chmod 600 "$password_dir/jupyter_server_config.json"
    
    log "Generated new Jupyter password files:"
    log "  - Plain password saved to: $password_dir/jupyter_password.txt"
    log "  - Config file created at: $password_dir/jupyter_server_config.json"
    log "  - Your new password is: $password"
}

# Function to generate docker-compose.yml
generate_docker_compose() {
    local compose_file="${WORKSPACE_DIR}/config/docker-compose.yml"
    mkdir -p "$(dirname "$compose_file")"
    log "Generating docker-compose.yml..."
    
    cat > "$compose_file" << 'EOL'
x-bake:
  args:
    BUILDKIT_INLINE_CACHE: 1
  resources:
    memory: 12g
    swap: 2g
    cpus: 9
    cpu-quota: 900000

services:
  jupyter-cpu:
    build:
      context: ..
      dockerfile: docker/Dockerfile.cpu
      args:
        BUILDKIT_INLINE_CACHE: 1
      # Build-time resource constraints (75% of 16GB RAM and 12 cores)
      x-bake:
        platforms:
          - linux/amd64
        cache-from:
          - type=local,src=.buildx-cache
        cache-to:
          - type=local,dest=.buildx-cache
        resources:
          cpu-quota: 900000    # 9 CPUs (100000 = 1 CPU)
          memory: 12G          # 12GB RAM for build (75% of 16GB)
          swap: 2G             # 2GB swap
    image: bhumukulrajds/ds-workspace-cpu:1.2
    container_name: ds-workspace-cpu
    network_mode: host
    labels:
      maintainer: "bhumukulraj.ds@gmail.com"
      version: "1.2"
      description: "Data Science Development Environment - CPU Version"
    deploy:
      resources:
        limits:
          cpus: '9'           # 75% of available CPUs
          memory: ${CONTAINER_MEMORY_LIMIT:-12}G
        reservations:
          cpus: '2'           # Minimum 2 CPUs
          memory: ${CONTAINER_MEMORY_RESERVATION:-4}G
    ports:
      - "8888:8888"
      - "5000:5000"  # MLflow UI
    volumes:
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/projects
        target: /workspace/projects
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/datasets
        target: /workspace/datasets
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/mlflow
        target: /workspace/mlflow
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/logs
        target: /workspace/logs
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/config/jupyter
        target: /home/ds-user-ds/.jupyter
    environment:
      - USE_GPU=false
      - TZ=${TZ:-UTC}
      - MLFLOW_TRACKING_URI=sqlite:///workspace/mlflow/db/mlflow.db
      - MLFLOW_BACKEND_STORE_URI=sqlite:///workspace/mlflow/db/mlflow.db
      - MLFLOW_DEFAULT_ARTIFACT_ROOT=/workspace/mlflow/artifacts
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
    user: "1000:1000"
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep jupyter-lab > /dev/null || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped

  jupyter-gpu:
    image: bhumukulrajds/ds-workspace-gpu:1.2
    build:
      context: ..
      dockerfile: docker/Dockerfile.gpu
      args:
        BUILDKIT_INLINE_CACHE: 1
      x-bake:
        platforms:
          - linux/amd64
        cache-from:
          - type=local,src=.buildx-cache
        cache-to:
          - type=local,dest=.buildx-cache
        resources:
          cpu-quota: 900000    # 9 CPUs (100000 = 1 CPU)
          memory: 12G          # 12GB RAM for build (75% of 16GB)
          swap: 2G             # 2GB swap
    container_name: ds-workspace-gpu
    runtime: nvidia
    network_mode: host
    labels:
      maintainer: "bhumukulraj.ds@gmail.com"
      version: "1.2"
      description: "Data Science Development Environment - GPU Version"
    deploy:
      resources:
        limits:
          cpus: '9'           # 75% of available CPUs
          memory: ${CONTAINER_MEMORY_LIMIT:-12}G
        reservations:
          cpus: '2'           # Minimum 2 CPUs
          memory: ${CONTAINER_MEMORY_RESERVATION:-4}G
    ports:
      - "8889:8888"          # JupyterLab on different port to avoid conflict
      - "5001:5000"          # MLflow on different port to avoid conflict
    volumes:
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/projects
        target: /workspace/projects
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/datasets
        target: /workspace/datasets
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/mlflow
        target: /workspace/mlflow
      - type: bind
        source: /home/${USER}/Desktop/dsi-host-workspace/logs
        target: /workspace/logs
      - /tmp/.X11-unix:/tmp/.X11-unix:ro  # For GUI applications
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/config/jupyter
        target: /home/ds-user-ds/.jupyter
    environment:
      - USE_GPU=true
      - TZ=${TZ:-UTC}
      - MLFLOW_TRACKING_URI=sqlite:///workspace/mlflow/db/mlflow.db
      - MLFLOW_BACKEND_STORE_URI=sqlite:///workspace/mlflow/db/mlflow.db
      - MLFLOW_DEFAULT_ARTIFACT_ROOT=/workspace/mlflow/artifacts
      # GPU-specific environment variables
      - NVIDIA_VISIBLE_DEVICES=0
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display
      - NVIDIA_REQUIRE_CUDA=cuda>=11.8
      - NVIDIA_MEM_MAX_PERCENT=75
      - NVIDIA_GPU_MEM_FRACTION=0.75
      - CUDA_VISIBLE_DEVICES=0
      - DISPLAY=${DISPLAY:-:0}  # For GUI applications
      - QT_XCB_GL_INTEGRATION=none  # Fix for Qt error
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
    user: "1000:1000"
    healthcheck:
      test: ["CMD-SHELL", "nvidia-smi && ps aux | grep jupyter-lab > /dev/null || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped

volumes:
  jupyter_logs_cpu:
    driver: local
  jupyter_logs_gpu:
    driver: local
  mlflow_data:
    driver: local
EOL

    log "docker-compose.yml generated successfully at: $compose_file"
}

# Function to generate .env file
generate_env_file() {
    local env_file="${WORKSPACE_DIR}/config/.env"
    mkdir -p "$(dirname "$env_file")"
    local current_uid=$(id -u)
    local current_gid=$(id -g)
    
    log "Generating .env file..."
    
    cat > "$env_file" << EOL
# Container resource configuration
CONTAINER_CPU_LIMIT=4
CONTAINER_CPU_RESERVATION=1
CONTAINER_MEMORY_LIMIT=8
CONTAINER_MEMORY_RESERVATION=2

# Host workspace directory
HOST_WORKSPACE_DIR=${WORKSPACE_DIR}

# MLflow configuration
MLFLOW_TRACKING_URI=sqlite:///workspace/mlflow/db/mlflow.db

# Timezone configuration
TZ=UTC

# Container configuration
COMPOSE_PROJECT_NAME=ds-workspace-v1

# User configuration - Use current user's UID and GID
UID=${current_uid}
GID=${current_gid}
EOL

    log ".env file generated successfully at: $env_file"
}

# Main execution
main() {
    log "Starting configuration file generation..."
    
    # Verify workspace exists
    verify_workspace
    
    # Generate configuration files
    generate_jupyter_password
    generate_docker_compose
    generate_env_file
    
    log "Configuration files generated successfully!"
    log "Workspace directory: ${WORKSPACE_DIR}"
    log "Your new Jupyter password can be found in: ${WORKSPACE_DIR}/config/jupyter/jupyter_password.txt"
    log "To start the container, run:"
    log "  cd ${WORKSPACE_DIR}/config && docker compose --env-file .env up -d jupyter-cpu"
}

main "$@" 