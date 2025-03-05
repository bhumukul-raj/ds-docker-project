#!/bin/bash

# Enable better error handling
set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WORKSPACE_DIR="/home/${USER}/Desktop/dsi-host-workspace"

# Logging functions
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

# Function to check and backup existing directory
check_existing_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_dir="${dir}_backup_${timestamp}"
        warn "Found existing directory: $dir"
        log "Creating backup at: $backup_dir"
        mv "$dir" "$backup_dir" || error "Failed to create backup of existing directory"
        log "Backup created successfully"
    fi
}

# Function to create workspace directories
create_workspace() {
    log "Creating workspace directories..."
    
    # Create main workspace directory
    mkdir -p "${WORKSPACE_DIR}"/{projects,datasets,logs/jupyter,config/jupyter} || error "Failed to create workspace directories"
    
    # Set permissions
    chmod -R 755 "${WORKSPACE_DIR}"
    
    log "Workspace directories created successfully at: ${WORKSPACE_DIR}"
}

# Main execution
main() {
    log "Starting workspace setup..."
    
    # Check for existing workspace directory
    check_existing_dir "$WORKSPACE_DIR"
    
    # Create workspace directories
    create_workspace
    
    log "Workspace setup completed successfully!"
    log "Next steps:"
    log "1. Run: bash scripts/setup_conf.sh"
}

main "$@" 