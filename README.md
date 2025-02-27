# Data Science Docker Project

This repository contains Docker environments for data science development, with separate CPU and GPU configurations. It provides a complete development environment with JupyterLab, MLflow, and essential data science tools.

## Quick Links
- [Detailed Documentation](v1.0/README.md)
- [Docker Commands](v1.0/docs/DOCKER_COMMANDS.md)
- [Changelog](v1.0/docs/CHANGELOG.md)
- [Docker Hub CPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-cpu)
- [Docker Hub GPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-gpu)

## Docker Hub Images

Pre-built images are available on Docker Hub:

```bash
# CPU Version
docker pull bhumukulrajds/ds-workspace-cpu:1.0.0
docker pull bhumukulrajds/ds-workspace-cpu:latest

# GPU Version
docker pull bhumukulrajds/ds-workspace-gpu:1.0.0
docker pull bhumukulrajds/ds-workspace-gpu:latest
```

## System Requirements

### Minimum (CPU Version)
- 4 CPU cores
- 8GB RAM
- 20GB disk space
- Docker Engine 20.10.0+
- Docker Compose 2.0.0+ (optional)
- Ubuntu 22.04 or compatible Linux distribution

### Recommended (GPU Version)
- 8 CPU cores
- 16GB RAM
- 40GB disk space
- NVIDIA GPU (8GB+ VRAM)
- NVIDIA drivers (latest stable version)
- NVIDIA Container Toolkit
- Ubuntu 22.04 or compatible Linux distribution

## Quick Start Guide

### Option 1: Using Docker Compose (Recommended if you have the full repository)

1. Set up host workspace:
```bash
mkdir -p ~/Desktop/dsi-host-workspace/{projects,.ssh,gitconfig,mlflow,logs/jupyter,datasets}
```

2. Configure environment:
```bash
cd v1.0
cp .env.example .env
# Edit .env and set JUPYTER_PASSWORD=your_secure_password
```

3. Start containers:
```bash
# For CPU version
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu

# For GPU version
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu
```

### Option 2: Using Docker Run (When using only Docker Hub images)

1. Create required directories:
```bash
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}
```

2. Run CPU Version:
```bash
docker run -d \
  --name ds-workspace-cpu \
  -p 8888:8888 \
  -p 5000:5000 \
  -e JUPYTER_PASSWORD="YourSecurePassword123" \
  -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
  -v ~/Desktop/dsi-host-workspace/projects:/workspace/projects \
  -v ~/Desktop/dsi-host-workspace/datasets:/workspace/datasets \
  -v ~/Desktop/dsi-host-workspace/mlflow:/workspace/mlflow \
  -v ~/Desktop/dsi-host-workspace/logs/jupyter:/var/log/jupyter \
  bhumukulrajds/ds-workspace-cpu:1.0.0
```

3. Run GPU Version:
```bash
docker run -d \
  --name ds-workspace-gpu \
  --gpus all \
  -p 8889:8888 \
  -p 5001:5000 \
  -e JUPYTER_PASSWORD="YourSecurePassword123" \
  -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics \
  -e NVIDIA_REQUIRE_CUDA="cuda>=11.8" \
  -e NVIDIA_MEM_MAX_PERCENT=75 \
  -e NVIDIA_GPU_MEM_FRACTION=0.75 \
  -v ~/Desktop/dsi-host-workspace/projects:/workspace/projects \
  -v ~/Desktop/dsi-host-workspace/datasets:/workspace/datasets \
  -v ~/Desktop/dsi-host-workspace/mlflow:/workspace/mlflow \
  -v ~/Desktop/dsi-host-workspace/logs/jupyter:/var/log/jupyter \
  bhumukulrajds/ds-workspace-gpu:1.0.0
```

4. Optional: Use Startup Script
Create a script `start-ds-environment.sh`:
```bash
#!/bin/bash

# Create directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Set environment variables
JUPYTER_PASSWORD="YourSecurePassword123"
HOST_DIR=~/Desktop/dsi-host-workspace

# Choose which version to run (cpu/gpu)
VERSION=${1:-cpu}

if [ "$VERSION" = "cpu" ]; then
    docker run -d \
        --name ds-workspace-cpu \
        -p 8888:8888 \
        -p 5000:5000 \
        -e JUPYTER_PASSWORD="${JUPYTER_PASSWORD}" \
        -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
        -v ${HOST_DIR}/projects:/workspace/projects \
        -v ${HOST_DIR}/datasets:/workspace/datasets \
        -v ${HOST_DIR}/mlflow:/workspace/mlflow \
        -v ${HOST_DIR}/logs/jupyter:/var/log/jupyter \
        bhumukulrajds/ds-workspace-cpu:1.0.0
    echo "CPU version started at http://localhost:8888"
    echo "MLflow available at http://localhost:5000"
elif [ "$VERSION" = "gpu" ]; then
    docker run -d \
        --name ds-workspace-gpu \
        --gpus all \
        -p 8889:8888 \
        -p 5001:5000 \
        -e JUPYTER_PASSWORD="${JUPYTER_PASSWORD}" \
        -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
        -e NVIDIA_VISIBLE_DEVICES=all \
        -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics \
        -e NVIDIA_REQUIRE_CUDA="cuda>=11.8" \
        -e NVIDIA_MEM_MAX_PERCENT=75 \
        -e NVIDIA_GPU_MEM_FRACTION=0.75 \
        -v ${HOST_DIR}/projects:/workspace/projects \
        -v ${HOST_DIR}/datasets:/workspace/datasets \
        -v ${HOST_DIR}/mlflow:/workspace/mlflow \
        -v ${HOST_DIR}/logs/jupyter:/var/log/jupyter \
        bhumukulrajds/ds-workspace-gpu:1.0.0
    echo "GPU version started at http://localhost:8889"
    echo "MLflow available at http://localhost:5001"
else
    echo "Invalid version. Use 'cpu' or 'gpu'"
    exit 1
fi
```

Run the script:
```bash
chmod +x start-ds-environment.sh
./start-ds-environment.sh cpu  # for CPU version
# or
./start-ds-environment.sh gpu  # for GPU version
```

## Access Your Environment

### JupyterLab
- CPU Version: http://localhost:8888
- GPU Version: http://localhost:8889
- Password: As set in JUPYTER_PASSWORD

### MLflow
- CPU Version: http://localhost:5000
- GPU Version: http://localhost:5001
- No authentication required

## Key Features

### Development Environment
- Python 3.9 with optimized numerical computations
- JupyterLab 3.6.5 with Git integration
- MLflow 2.6.0 for experiment tracking
- Pre-configured GPU support (CUDA 11.8, cuDNN 8)
- Dask for distributed computing

### Core Packages
- Data Analysis: NumPy 1.24.3, Pandas 1.5.3
- Machine Learning: Scikit-learn 1.3.0, XGBoost 1.7.6
- Deep Learning (GPU): PyTorch 2.0.1, TensorFlow 2.13.0
- Visualization: Matplotlib 3.7.2, Seaborn 0.12.2, Plotly 5.16.1

## Common Operations

### Container Management
```bash
# View container logs
docker logs ds-workspace-cpu  # or ds-workspace-gpu

# Access container shell
docker exec -it ds-workspace-cpu bash  # or ds-workspace-gpu

# Stop container
docker stop ds-workspace-cpu  # or ds-workspace-gpu

# Remove container
docker rm ds-workspace-cpu  # or ds-workspace-gpu
```

### Resource Monitoring
```bash
# Check container status
docker ps -a

# Monitor resource usage
docker stats ds-workspace-cpu  # or ds-workspace-gpu

# For GPU container, verify GPU access
docker exec ds-workspace-gpu nvidia-smi
```

## Support and Documentation

- For detailed documentation, see [v1.0/README.md](v1.0/README.md)
- For Docker commands reference, see [DOCKER_COMMANDS.md](v1.0/docs/DOCKER_COMMANDS.md)
- For version history, see [CHANGELOG.md](v1.0/docs/CHANGELOG.md)

## Maintainer

bhumukulraj.ds@gmail.com 