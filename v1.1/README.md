# Data Science Development Environment v1.1

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

### 1. Setup Host Environment

```bash
# Create workspace directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Set permissions
chmod -R 777 ~/Desktop/dsi-host-workspace
```

### 2. Environment Configuration

```bash
# Copy and edit environment file
cp .env.example .env
# Edit .env file with your preferred settings:
# - Set JUPYTER_PASSWORD
# - Adjust memory limits if needed
```

### 3. Start Containers

#### CPU Version
```bash
# Build and start
docker compose --env-file .env build jupyter-cpu
docker compose --env-file .env up -d jupyter-cpu

# Access at:
# - JupyterLab: http://localhost:8888
# - MLflow: http://localhost:5000
```

#### GPU Version
```bash
# Build and start
docker compose --env-file .env build jupyter-gpu
docker compose --env-file .env up -d jupyter-gpu

# Access at:
# - JupyterLab: http://localhost:8889
# - MLflow: http://localhost:5001
```

## Environment Details

### Core Components

#### CPU Environment
- Python 3.9
- JupyterLab 3.6.5
- MLflow 2.8.1
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
- Visual Studio Code Server
- JupyterLab Extensions
  - Git integration
  - Resource monitoring
  - Code formatting
  - Language server
  - Variable inspector

## Usage Guide

### Starting Services

1. **CPU Version:**
```bash
# Start services
docker compose --env-file .env up -d jupyter-cpu

# Stop services
docker compose --env-file .env stop jupyter-cpu

# Restart services
docker compose --env-file .env restart jupyter-cpu
```

2. **GPU Version:**
```bash
# Start services
docker compose --env-file .env up -d jupyter-gpu

# Stop services
docker compose --env-file .env stop jupyter-gpu

# Restart services
docker compose --env-file .env restart jupyter-gpu
```

### Verifying GPU Support

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

   a. Check logs:
   ```bash
   docker logs ds-workspace-cpu  # or ds-workspace-gpu
   ```

   b. Verify port availability:
   ```bash
   sudo lsof -i :8888  # For CPU JupyterLab
   sudo lsof -i :8889  # For GPU JupyterLab
   sudo lsof -i :5000  # For CPU MLflow
   sudo lsof -i :5001  # For GPU MLflow
   ```

   c. Check resource limits in .env file:
   ```bash
   CONTAINER_MEMORY_LIMIT=8G
   CONTAINER_MEMORY_RESERVATION=2G
   ```

2. **GPU Issues**

   a. Verify NVIDIA drivers:
   ```bash
   nvidia-smi
   ```

   b. Check NVIDIA Container Toolkit:
   ```bash
   sudo systemctl status nvidia-docker
   ```

   c. Common GPU error solutions:
   - If CUDA unavailable: Check nvidia-docker2 installation
   - If memory errors: Adjust GPU memory limits in docker-compose.yml
   - If driver version mismatch: Update NVIDIA drivers

3. **MLflow Database Issues**

   a. Check permissions:
   ```bash
   ls -la ~/Desktop/dsi-host-workspace/mlflow
   ```

   b. Reset MLflow database:
   ```bash
   rm ~/Desktop/dsi-host-workspace/mlflow/db/mlflow.db
   ```

4. **JupyterLab Access Issues**

   a. Reset password:
   ```bash
   # Edit .env file
   JUPYTER_PASSWORD=newpassword

   # Restart container
   docker compose --env-file .env restart jupyter-cpu  # or jupyter-gpu
   ```

   b. Check JupyterLab logs:
   ```bash
   docker exec ds-workspace-cpu bash -c "cat /workspace/logs/jupyter.log"
   ```

### Recovery Steps

1. **Complete Reset**
```bash
# Stop all containers
docker compose --env-file .env down

# Remove containers and volumes
docker compose --env-file .env down -v

# Rebuild from scratch
docker compose --env-file .env build --no-cache
docker compose --env-file .env up -d
```

2. **Clean Workspace**
```bash
# Backup important data
cp -r ~/Desktop/dsi-host-workspace/projects ~/Desktop/projects_backup

# Reset workspace
rm -rf ~/Desktop/dsi-host-workspace/*
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}
chmod -R 777 ~/Desktop/dsi-host-workspace
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

# View logs
docker logs -f ds-workspace-cpu  # or ds-workspace-gpu
```

### Data Management
```bash
# Backup workspace
tar -czf workspace_backup.tar.gz ~/Desktop/dsi-host-workspace

# Restore workspace
tar -xzf workspace_backup.tar.gz -C ~/Desktop/
```

### Resource Cleanup
```bash
# Remove unused data
docker system prune -a

# Clean build cache
docker builder prune

# Remove specific container
docker rm -f ds-workspace-cpu  # or ds-workspace-gpu
``` 