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

# Base directory for the data science workspace
BASE_DIR="/home/${USER}/Desktop/dsi-host-workspace"

# Cleanup temporary files
cleanup_temp_files() {
    log "Cleaning up temporary files..."
    
    # Clean Jupyter temporary files
    find "${BASE_DIR}/logs/jupyter" -type f -name "*.log" -mtime +7 -delete
    find /tmp -type f -name "jupyter-*" -mtime +1 -delete
    
    # Clean MLflow temporary files
    find "${BASE_DIR}/mlflow/artifacts" -type f -mtime +30 -delete
    find /tmp -type f -name "mlflow-*" -mtime +1 -delete
    
    # Clean pip cache
    rm -rf ~/.cache/pip/*
    
    # Clean conda cache
    conda clean -afy
    
    # Clean npm cache
    npm cache clean --force
    
    log "Temporary files cleanup completed"
}

# Cleanup Docker resources
cleanup_docker() {
    log "Cleaning up Docker resources..."
    
    # Remove unused containers
    docker container prune -f
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    # Remove unused networks
    docker network prune -f
    
    # Remove build cache
    docker builder prune -f --keep-storage 10GB
    
    log "Docker cleanup completed"
}

# Rotate log files
rotate_logs() {
    log "Rotating log files..."
    
    local log_dirs=(
        "${BASE_DIR}/logs/jupyter"
        "${BASE_DIR}/logs/mlflow"
    )
    
    for dir in "${log_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -name "*.log" -exec gzip -9 {} \;
            find "$dir" -type f -name "*.log.gz" -mtime +30 -delete
        fi
    done
    
    log "Log rotation completed"
}

# Backup important data
backup_data() {
    log "Starting backup process..."
    
    local backup_dir="${BASE_DIR}/backups/$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    # Backup MLflow database
    if [[ -f "${BASE_DIR}/mlflow/db/mlflow.db" ]]; then
        sqlite3 "${BASE_DIR}/mlflow/db/mlflow.db" ".backup '${backup_dir}/mlflow.db'"
    fi
    
    # Backup important notebooks
    if [[ -d "${BASE_DIR}/projects" ]]; then
        tar -czf "${backup_dir}/projects.tar.gz" -C "${BASE_DIR}" projects/
    fi
    
    # Cleanup old backups (keep last 7 days)
    find "${BASE_DIR}/backups" -type d -mtime +7 -exec rm -rf {} +
    
    log "Backup completed: $backup_dir"
}

# Check and optimize storage
optimize_storage() {
    log "Optimizing storage..."
    
    # Check disk usage
    local usage=$(df -h "${BASE_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( usage > 80 )); then
        warn "High disk usage: ${usage}%"
    fi
    
    # Compress old notebooks
    find "${BASE_DIR}/projects" -type f -name "*.ipynb" -mtime +30 -exec gzip -9 {} \;
    
    # Remove old MLflow runs
    if [[ -f "${BASE_DIR}/mlflow/db/mlflow.db" ]]; then
        sqlite3 "${BASE_DIR}/mlflow/db/mlflow.db" "DELETE FROM runs WHERE end_time < datetime('now', '-30 days');"
        sqlite3 "${BASE_DIR}/mlflow/db/mlflow.db" "VACUUM;"
    fi
    
    log "Storage optimization completed"
}

# Main execution
main() {
    log "Starting cleanup and maintenance tasks..."
    
    cleanup_temp_files
    cleanup_docker
    rotate_logs
    backup_data
    optimize_storage
    
    log "All cleanup and maintenance tasks completed successfully!"
}

main "$@" 