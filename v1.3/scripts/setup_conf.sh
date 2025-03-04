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
#--------------------------------------
here add the docker-compose file
#--------------------------------------
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
#---------------------------------------
here add the env file
# User configuration - Use current user's UID and GID
#UID=${current_uid}
#GID=${current_gid}
#---------------------------------------
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