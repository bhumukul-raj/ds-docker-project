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

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root or with sudo"
fi

# Base directory for the data science workspace
BASE_DIR="$HOME/Desktop/dsi-host-workspace"

# Directory structure with specific permissions
declare -A DIR_PERMS=(
    ["$BASE_DIR"]="777"
    ["$BASE_DIR/projects"]="777"
    ["$BASE_DIR/datasets"]="777"
    ["$BASE_DIR/mlflow"]="777"
    ["$BASE_DIR/mlflow/artifacts"]="777"
    ["$BASE_DIR/mlflow/db"]="777"
    ["$BASE_DIR/logs"]="777"
    ["$BASE_DIR/logs/jupyter"]="777"
)

log "Setting up Data Science Environment directories..."

# Create directories with specific permissions
for dir in "${!DIR_PERMS[@]}"; do
    if [ ! -d "$dir" ]; then
        log "Creating directory: $dir"
        mkdir -p "$dir"
    else
        warn "Directory already exists: $dir"
    fi
    # Set permissions
    chmod "${DIR_PERMS[$dir]}" "$dir"
done

# Create necessary files with proper permissions
log "Setting up MLflow database file..."
touch "$BASE_DIR/mlflow/db/mlflow.db"
chmod 666 "$BASE_DIR/mlflow/db/mlflow.db"

# Verify permissions
log "Verifying directory permissions..."
for dir in "${!DIR_PERMS[@]}"; do
    if [ -d "$dir" ]; then
        current_perms=$(stat -c "%a" "$dir")
        if [ "$current_perms" != "${DIR_PERMS[$dir]}" ]; then
            warn "Permission mismatch for $dir: Expected ${DIR_PERMS[$dir]}, got $current_perms"
            chmod "${DIR_PERMS[$dir]}" "$dir"
        fi
    fi
done

log "Setup completed successfully!"
echo -e "\nDirectory structure created at: $BASE_DIR"
echo -e "All directories have been created with proper permissions."
echo -e "\nDirectory Structure:"
echo -e "${GREEN}Main directory:${NC}"
ls -la "$BASE_DIR"
echo -e "\n${GREEN}MLflow directory:${NC}"
ls -la "$BASE_DIR/mlflow"
echo -e "\n${GREEN}Logs directory:${NC}"
ls -la "$BASE_DIR/logs" 