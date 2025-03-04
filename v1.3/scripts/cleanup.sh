#!/bin/bash

# Enable better error handling
set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script configuration
DRY_RUN=false
NOTIFY=false
LOCK_FILE="/tmp/ds_cleanup.lock"
BASE_DIR="/home/${USER}/Desktop/dsi-host-workspace"
CONFIG_FILE="${BASE_DIR}/config/cleanup.conf"

# Load configuration if exists
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Parse command line options
while getopts "dn" opt; do
    case $opt in
        d) DRY_RUN=true ;;
        n) NOTIFY=true ;;
        *) echo "Usage: $0 [-d] [-n]" >&2; exit 1 ;;
    esac
done

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    cleanup_failure "${FUNCNAME[1]:-main}"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

progress() {
    local current="$1"
    local total="$2"
    local prefix="$3"
    printf "${prefix} [%-50s] %d%%\r" \
        $(printf "#%.0s" $(seq 1 $(($current*50/$total)))) \
        $(($current*100/$total))
}

# Prerequisite checks
check_prerequisites() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
    fi
    
    # Check if base directory exists
    if [[ ! -d "${BASE_DIR}" ]]; then
        error "Base directory ${BASE_DIR} does not exist"
    fi
    
    # Check for required commands
    local required_cmds=(docker gzip tar)
    local optional_cmds=(conda npm)
    
    for cmd in "${required_cmds[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            error "$cmd is required but not installed"
        fi
    done
    
    # Check optional commands
    for cmd in "${optional_cmds[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            warn "$cmd is not installed - some cleanup operations will be skipped"
        fi
    done
    
    # Check available space
    check_space
}

check_space() {
    local required_space=5  # GB
    local available_space=$(df -BG "${BASE_DIR}" | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( available_space < required_space )); then
        error "Insufficient space: ${available_space}GB available, ${required_space}GB required"
    fi
}

check_containers() {
    if docker ps -q | grep -q .; then
        warn "Running containers detected. Some cleanup operations may be limited."
    fi
}

# Cleanup functions
cleanup_temp_files() {
    log "Cleaning up temporary files..."
    
    if [[ "$DRY_RUN" = true ]]; then
        log "DRY RUN: Would clean temporary files"
        return
    fi
    
    # Clean Jupyter temporary files
    find "${BASE_DIR}/logs/jupyter" -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
    find /tmp -type f -name "jupyter-*" -mtime +1 -delete 2>/dev/null || true
    
    # Clean pip cache if exists
    if [[ -d ~/.cache/pip ]]; then
        rm -rf ~/.cache/pip/* 2>/dev/null || true
    fi
    
    # Clean conda cache if conda exists
    if command -v conda &> /dev/null; then
        conda clean -afy
    fi
    
    # Clean npm cache if npm exists
    if command -v npm &> /dev/null; then
        npm cache clean --force
    fi
    
    log "Temporary files cleanup completed"
}

cleanup_docker() {
    log "Cleaning up Docker resources..."
    
    if [[ "$DRY_RUN" = true ]]; then
        log "DRY RUN: Would clean Docker resources"
        return
    fi
    
    check_containers
    
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

rotate_logs() {
    log "Rotating log files..."
    
    if [[ "$DRY_RUN" = true ]]; then
        log "DRY RUN: Would rotate logs"
        return
    fi
    
    local log_dirs=(
        "${BASE_DIR}/logs/jupyter"
    )
    
    for dir in "${log_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -name "*.log" -exec gzip -9 {} \;
            find "$dir" -type f -name "*.log.gz" -mtime +30 -delete
        fi
    done
    
    log "Log rotation completed"
}

backup_data() {
    log "Starting backup process..."
    
    if [[ "$DRY_RUN" = true ]]; then
        log "DRY RUN: Would backup data"
        return
    fi
    
    local backup_dir="${BASE_DIR}/backups/$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    # Backup important notebooks
    if [[ -d "${BASE_DIR}/projects" ]]; then
        log "Backing up project notebooks..."
        tar -czf "${backup_dir}/projects.tar.gz" -C "${BASE_DIR}" projects/
        verify_backup "${backup_dir}/projects.tar.gz"
    fi
    
    # Cleanup old backups (keep last 7 days)
    find "${BASE_DIR}/backups" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true
    
    log "Backup completed: $backup_dir"
}

verify_backup() {
    local backup_file="$1"
    if [[ ! -f "$backup_file" || ! -s "$backup_file" ]]; then
        error "Backup failed: $backup_file is empty or missing"
    fi
}

optimize_storage() {
    log "Optimizing storage..."
    
    if [[ "$DRY_RUN" = true ]]; then
        log "DRY RUN: Would optimize storage"
        return
    fi
    
    # Check disk usage
    local usage=$(df -h "${BASE_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( usage > 80 )); then
        warn "High disk usage: ${usage}%"
    fi
    
    # Compress old notebooks
    if [[ -d "${BASE_DIR}/projects" ]]; then
        log "Compressing old notebooks..."
        find "${BASE_DIR}/projects" -type f -name "*.ipynb" -mtime +30 -exec gzip -9 {} \; 2>/dev/null || true
    fi
    
    log "Storage optimization completed"
}

cleanup_failure() {
    local failed_function="$1"
    warn "Failed during $failed_function"
    case "$failed_function" in
        cleanup_docker)
            warn "Attempting to recover Docker cleanup..."
            docker system prune -f --volumes
            ;;
        backup_data)
            warn "Attempting alternative backup method..."
            cp -r "${BASE_DIR}/projects" "${backup_dir}/projects_backup"
            ;;
    esac
}

# Main execution
main() {
    log "Starting cleanup and maintenance tasks..."
    
    # Check for running instance
    if [ -f "$LOCK_FILE" ]; then
        error "Another cleanup process is running"
    fi
    trap 'rm -f $LOCK_FILE' EXIT
    touch "$LOCK_FILE"
    
    # Run prerequisite checks
    check_prerequisites
    
    # Execute cleanup tasks
    cleanup_temp_files
    cleanup_docker
    rotate_logs
    backup_data
    optimize_storage
    
    log "All cleanup and maintenance tasks completed successfully!"
    
    # Send notification if enabled
    if [[ "$NOTIFY" = true ]]; then
        notify-send "Cleanup Complete" "Data Science workspace cleanup completed successfully"
    fi
}

main "$@" 