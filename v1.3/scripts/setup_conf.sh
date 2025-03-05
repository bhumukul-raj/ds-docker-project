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
    memory: 10g  # Aligned with service limits
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
        NB_UID: ${UID:-1000}
        NB_GID: ${GID:-1000}
      x-bake:
        platforms:
          - linux/amd64
        cache-from:
          - type=local,src=.buildx-cache
        cache-to:
          - type=local,dest=.buildx-cache
        resources:
          cpu-quota: 900000
          memory: 10G
          swap: 2G
    image: bhumukulrajds/ds-workspace-cpu:1.3
    container_name: ds-workspace-cpu
    network_mode: "host"
    dns:
      - 8.8.8.8
      - 1.1.1.1
    userns_mode: "host"
    labels:
      maintainer: "bhumukulraj.ds@gmail.com"
      version: "1.3"
      description: "Data Science Development Environment - CPU Version"
    deploy:
      resources:
        limits:
          cpus: '${CPU_LIMIT:-4}'
          memory: ${CONTAINER_MEMORY_LIMIT:-10}G
          pids: 1000
        reservations:
          cpus: '${CPU_RESERVATION:-2}'
          memory: ${CONTAINER_MEMORY_RESERVATION:-3}G
    ports:
      - "127.0.0.1:8888:8888"
    volumes:
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/projects
        target: /workspace/projects
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/datasets
        target: /workspace/datasets
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/logs
        target: /workspace/logs
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/config/jupyter
        target: /home/ds-user-ds/.jupyter
    environment:
      - USE_GPU=false
      - TZ=${TZ:-UTC}
      - PYTHONGC=2
      - JUPYTER_IP=0.0.0.0
    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "5"
        compress: "true"
        tag: "{{.Name}}"
    user: "${UID:-1000}:${GID:-1000}"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8888/api/status"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped
    read_only: false
    security_opt:
      - "no-new-privileges:true"
      - "apparmor:docker-default"
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETUID
      - SETGID
      - NET_BIND_SERVICE

  jupyter-gpu:
    build:
      context: ..
      dockerfile: docker/Dockerfile.gpu
      args:
        BUILDKIT_INLINE_CACHE: 1
        NB_UID: ${UID:-1000}
        NB_GID: ${GID:-1000}
      x-bake:
        platforms:
          - linux/amd64
        cache-from:
          - type=local,src=.buildx-cache
        cache-to:
          - type=local,dest=.buildx-cache
        resources:
          cpu-quota: 900000
          memory: 10G
          swap: 2G
    image: bhumukulrajds/ds-workspace-gpu:1.3
    container_name: ds-workspace-gpu
    runtime: nvidia
    shm_size: "2g"
    network_mode: "host"
    dns:
      - 8.8.8.8
      - 1.1.1.1
    userns_mode: "host"
    labels:
      maintainer: "bhumukulraj.ds@gmail.com"
      version: "1.3"
      description: "Data Science Development Environment - GPU Version"
    deploy:
      resources:
        limits:
          cpus: '${CPU_LIMIT:-4}'
          memory: ${CONTAINER_MEMORY_LIMIT:-12}G
          pids: 1000
        reservations:
          cpus: '${CPU_RESERVATION:-2}'
          memory: ${CONTAINER_MEMORY_RESERVATION:-4}G
    ports:
      - "127.0.0.1:8889:8888"
    volumes:
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/projects
        target: /workspace/projects
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/datasets
        target: /workspace/datasets
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/logs
        target: /workspace/logs
      - type: bind
        source: ${HOST_WORKSPACE_DIR}/config/jupyter
        target: /home/ds-user-ds/.jupyter
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    environment:
      - USE_GPU=true
      - TZ=${TZ:-UTC}
      - PYTHONGC=2
      - JUPYTER_IP=0.0.0.0
      - NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-0}
      - NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-compute,utility,graphics,display}
      - NVIDIA_REQUIRE_CUDA=${NVIDIA_REQUIRE_CUDA:-"cuda>=11.8"}
      - NVIDIA_MEM_MAX_PERCENT=${NVIDIA_MEM_MAX_PERCENT:-75}
      - NVIDIA_GPU_MEM_FRACTION=${NVIDIA_GPU_MEM_FRACTION:-0.6}
      - CUDA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-0}
      - DISPLAY=${DISPLAY:-:0}
      - QT_XCB_GL_INTEGRATION=none
    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "5"
        compress: "true"
        tag: "{{.Name}}"
    user: "${UID:-1000}:${GID:-1000}"
    healthcheck:
      test: ["CMD-SHELL", "timeout 5 nvidia-smi >/dev/null 2>&1 && curl -f http://localhost:8888/api/status"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped
    read_only: false
    security_opt:
      - "no-new-privileges:true"
      - "apparmor:docker-default"
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETUID
      - SETGID
      - NET_BIND_SERVICE

volumes:
  jupyter_logs_cpu:
    driver: local
  jupyter_logs_gpu:
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
# Required environment variables
# Host workspace directory (use absolute path)
HOST_WORKSPACE_DIR=${HOME}/Desktop/dsi-host-workspace

# User configuration (use current user's UID/GID)

UID=${current_uid}
GID=${current_gid}

# Optional environment variables
# Timezone configuration
TZ=UTC

# Container configuration
COMPOSE_PROJECT_NAME=ds-workspace-v1

# Resource limits
CPU_LIMIT=9
CPU_RESERVATION=2
CONTAINER_MEMORY_LIMIT=10
CONTAINER_MEMORY_RESERVATION=3

# Performance tuning
DASK_NUM_WORKERS=8

# NVIDIA Configuration (for GPU container)
NVIDIA_VISIBLE_DEVICES=0
NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display
NVIDIA_REQUIRE_CUDA=cuda>=11.8
NVIDIA_MEM_MAX_PERCENT=75
NVIDIA_GPU_MEM_FRACTION=0.6  # Reduced to 60% for 4GB GPU
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