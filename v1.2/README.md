# Data Science Development Environment v1.2

A comprehensive Docker-based development environment for data science, with separate CPU and GPU configurations. This environment provides a complete setup with JupyterLab, MLflow, and essential data science tools.

## Table of Contents
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Environment Details](#environment-details)
- [Usage Guide](#usage-guide)
- [Troubleshooting](#troubleshooting)
- [Common Operations](#common-operations)

## System Requirements

### CPU Version
- **Minimum:**
  - 4 CPU cores
  - 8GB RAM
  - 20GB disk space
  - Docker Engine 20.10.0+
  - Ubuntu 22.04 or compatible Linux distribution

- **Recommended:**
  - 8+ CPU cores
  - 16GB RAM
  - 40GB disk space
  - SSD storage

### GPU Version
- **Minimum:**
  - All CPU version requirements
  - NVIDIA GPU with 4GB+ VRAM
  - NVIDIA Driver 450.80.02+
  - NVIDIA Container Toolkit
  - CUDA 11.8 compatible GPU

- **Recommended:**
  - NVIDIA GPU with 8GB+ VRAM
  - Latest NVIDIA drivers
  - 16GB+ system RAM

## Quick Start

### 1. Clone Repository and Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/ds-docker-project.git
cd ds-docker-project

# Run setup scripts
bash scripts/setup_host.sh
bash v1.2/scripts/setup_conf.sh
```

### 2. Build Images
```bash
# Build CPU image
cd ~/Desktop/dsi-host-workspace/config
docker compose --env-file .env build jupyter-cpu
# Or pull from Docker Hub
docker pull bhumukulrajds/ds-workspace-cpu:1.2

# Build GPU image (if needed)
docker compose --env-file .env build jupyter-gpu
# Or pull from Docker Hub
docker pull bhumukulrajds/ds-workspace-gpu:1.2
```

### 3. Start Containers

#### CPU Version
```bash
# Start CPU container
docker compose --env-file .env up -d jupyter-cpu

# Access at:
# - JupyterLab: http://localhost:8888/lab
# - MLflow: http://localhost:5000
```

#### GPU Version
```bash
# Start GPU container
docker compose --env-file .env up -d jupyter-gpu

# Access at:
# - JupyterLab: http://localhost:8888/lab
# - MLflow: http://localhost:5000
```

The Jupyter password can be found in:
```bash
cat ~/Desktop/dsi-host-workspace/config/jupyter/jupyter_password.txt
```

## Environment Details

### Core Components

#### CPU Environment
- Python 3.9
- JupyterLab 3.6.5
- MLflow 2.6.0
- NumPy 1.24.3
- Pandas 1.5.3
- Scikit-learn 1.3.0
- XGBoost 1.7.6
- LightGBM 4.0.0

#### GPU Environment (Additional)
- CUDA 11.8
- cuDNN 8.9.2
- PyTorch 2.0.1+cu118
- TensorFlow 2.13.0
- CuPy 12.2.0
- NVIDIA Container Runtime

### Development Tools
- Git with LFS support
- JupyterLab Extensions:
  - Git integration
  - Resource monitoring
  - Code formatting
  - Language server
  - Variable inspector
  - System monitor
  - Execution time
  - LaTeX support
  - Draw.io integration

### Directory Structure
```
~/Desktop/dsi-host-workspace/
├── config/
│   ├── jupyter/          # Jupyter configuration
│   ├── docker-compose.yml
│   └── .env
├── projects/            # Your notebooks and code
├── datasets/           # Data storage
├── mlflow/             # MLflow tracking
│   ├── artifacts/
│   └── db/
└── logs/              # Container and application logs
    └── jupyter/
```

## Usage Guide

### Basic Operations

1. **Start Services:**
```bash
cd ~/Desktop/dsi-host-workspace/config

# Start both CPU and GPU
docker compose --env-file .env up -d

# Start CPU only
docker compose --env-file .env up -d jupyter-cpu

# Start GPU only
docker compose --env-file .env up -d jupyter-gpu
```

2. **Stop Services:**
```bash
# Stop all containers
docker compose --env-file .env down

# Stop specific container
docker compose --env-file .env stop jupyter-cpu  # or jupyter-gpu
```

3. **View Logs:**
```bash
# View container logs
docker logs ds-workspace-cpu  # or ds-workspace-gpu

# View Jupyter logs
cat ~/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log
```

### GPU Support Verification

```bash
# Check NVIDIA GPU status
docker exec ds-workspace-gpu nvidia-smi

# Verify PyTorch GPU access
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import torch; print(torch.cuda.is_available())'"

# Verify TensorFlow GPU access
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import tensorflow as tf; print(tf.config.list_physical_devices(\"GPU\"))'"
```

## Troubleshooting

### Common Issues and Solutions

1. **Container Fails to Start**
   - Check container logs
   - Verify port availability
   - Check resource limits
   - Ensure directories exist with correct permissions

2. **GPU Issues**
   - Verify NVIDIA drivers
   - Check NVIDIA Container Toolkit
   - Validate CUDA compatibility
   - Monitor GPU memory usage

3. **Access Issues**
   - Confirm ports are not in use
   - Check Jupyter password file
   - Verify network mode settings
   - Check container health status

### Quick Fixes

1. **Reset Environment:**
```bash
cd ~/Desktop/dsi-host-workspace/config
docker compose --env-file .env down
docker compose --env-file .env up -d
```

2. **Regenerate Configuration:**
```bash
bash ~/Desktop/ds-docker-project/v1.2/scripts/setup_conf.sh
```

3. **Clean Workspace:**
```bash
# Backup data
cp -r ~/Desktop/dsi-host-workspace/projects ~/Desktop/projects_backup

# Reset workspace
rm -rf ~/Desktop/dsi-host-workspace/*
bash ~/Desktop/ds-docker-project/scripts/setup_host.sh
bash ~/Desktop/ds-docker-project/v1.2/scripts/setup_conf.sh
```

## Common Operations

### Container Management
```bash
# View container status
docker ps -a

# View resource usage
docker stats

# Access container shell
docker exec -it ds-workspace-cpu bash  # or ds-workspace-gpu
```

### Data Management
```bash
# Backup workspace
tar -czf workspace_backup.tar.gz ~/Desktop/dsi-host-workspace

# Restore workspace
tar -xzf workspace_backup.tar.gz -C ~/Desktop/
```

### Maintenance and Cleanup

The environment comes with a comprehensive cleanup script (`scripts/cleanup.sh`) that helps maintain the system's health and performance.

#### Features
- Automatic cleanup of temporary files
- Docker resource management
- Log rotation
- Automated backups
- Storage optimization
- Safety checks and verifications

#### Usage

1. **Basic Cleanup**:
```bash
# Run standard cleanup
./scripts/cleanup.sh

# Dry run (preview changes)
./scripts/cleanup.sh -d

# Run with desktop notifications
./scripts/cleanup.sh -n
```

2. **What It Cleans**:
- Temporary Jupyter and MLflow files
- Old log files (rotated after 7 days)
- Unused Docker resources
- Package caches (pip, conda, npm)
- Old MLflow runs (>30 days)
- Compressed old notebooks

3. **Safety Features**:
- Prerequisite checks
- Space verification
- Lock file prevention
- Backup verification
- Running container detection
- Non-root user verification

4. **Configuration**:
Create `~/Desktop/dsi-host-workspace/config/cleanup.conf` to customize:
```bash
# Example configuration
BACKUP_RETENTION_DAYS=14    # Default: 7
LOG_RETENTION_DAYS=30       # Default: 30
REQUIRED_SPACE=10          # Default: 5GB
```

5. **Backup Management**:
- Automatic daily backups
- MLflow database backup
- Project notebooks backup
- 7-day backup retention
- Backup verification

6. **Storage Optimization**:
- Disk usage monitoring
- Old notebook compression
- MLflow database optimization
- Docker cache management
- Unused resource cleanup

7. **Error Handling**:
- Detailed error logging
- Automatic recovery attempts
- Failure notifications
- Progress reporting
- Color-coded output

#### Scheduling Cleanup

To run cleanup automatically, add to crontab:
```bash
# Edit crontab
crontab -e

# Run daily at 2 AM
0 2 * * * /home/bhumukul-raj/Desktop/ds-docker-project/v1.2/scripts/cleanup.sh -n
```

#### Best Practices
1. Run cleanup during low-activity periods
2. Always run with `-d` first to preview changes
3. Keep at least 10GB free space
4. Monitor cleanup logs regularly
5. Verify backups periodically

For more information and updates, visit the project repository or contact the maintainer at bhumukulraj.ds@gmail.com. 