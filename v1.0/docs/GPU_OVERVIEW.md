# Data Science Environment - GPU Version

## Overview

The GPU version of our Data Science environment is optimized for deep learning, CUDA-accelerated machine learning, and high-performance computing tasks. It includes full NVIDIA GPU support with CUDA and cuDNN integration.

## Image Details

- **Base Image**: nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
- **Image Name**: bhumukulrajds/ds-workspace-gpu
- **Tags**: 
  - `1.0` - Stable release
  - `latest` - Most recent version

## Resource Requirements

### Minimum
- 8 CPU cores
- 16GB RAM
- 40GB disk space
- NVIDIA GPU (8GB+ VRAM)
- NVIDIA drivers (latest stable)
- NVIDIA Container Toolkit

### Recommended
- 12+ CPU cores
- 32GB RAM
- 50GB disk space
- NVIDIA GPU (12GB+ VRAM)
- Multiple GPUs for distributed training

## Quick Start

### Option 1: Using Docker Compose (if available)
```bash
# Verify NVIDIA setup
nvidia-smi
nvidia-container-cli info

# Pull the image
docker pull bhumukulrajds/ds-workspace-gpu:1.0

# Start the container
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu
```

### Option 2: Using Docker Run (standalone)
```bash
# First verify NVIDIA setup
nvidia-smi
nvidia-container-cli info

# Create required directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Run the container
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
  bhumukulrajds/ds-workspace-gpu:1.0
```

### Option 3: Using Startup Script
Create a file named `start-ds-environment.sh`:
```bash
#!/bin/bash

# Verify NVIDIA setup
if ! command -v nvidia-smi &> /dev/null; then
    echo "Error: NVIDIA drivers not found"
    exit 1
fi

if ! command -v nvidia-container-cli &> /dev/null; then
    echo "Error: NVIDIA Container Toolkit not found"
    exit 1
fi

# Create directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Set environment variables
JUPYTER_PASSWORD="YourSecurePassword123"
HOST_DIR=~/Desktop/dsi-host-workspace

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
    bhumukulrajds/ds-workspace-gpu:1.0

echo "GPU version started at http://localhost:8889"
echo "MLflow available at http://localhost:5001"
```

Run the script:
```bash
chmod +x start-ds-environment.sh
./start-ds-environment.sh
```

## Access Points

- JupyterLab: http://localhost:8889
- MLflow UI: http://localhost:5001

## Key Features

### Development Environment
- Python 3.9
- JupyterLab 3.6.5
- MLflow 2.6.0
- CUDA 11.8
- cuDNN 8.9.2
- Conda/Mamba package management

### Deep Learning
- PyTorch 2.0.1
- TensorFlow 2.13.0
- CUDA-enabled XGBoost
- GPU-accelerated Scikit-learn

### Core Packages
- NumPy 1.24.3 (CUDA-aware)
- Pandas 1.5.3
- Scipy 1.11.2
- CuPy 12.2.0

### Machine Learning
- XGBoost 1.7.6 (GPU)
- LightGBM 4.0.0
- MLflow 2.6.0
- Dask-CUDA 23.6.0

### Visualization
- Matplotlib 3.7.2
- Seaborn 0.12.2
- Plotly 5.16.1

## GPU Configuration

### NVIDIA Settings
```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
  - NVIDIA_REQUIRE_CUDA=cuda>=11.8
  - NVIDIA_MEM_MAX_PERCENT=75
  - NVIDIA_GPU_MEM_FRACTION=0.75
  - CUDA_VISIBLE_DEVICES=0
```

### Resource Management
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## Storage Structure

### Container Paths
```
/workspace/
├── projects/          # Code and notebooks
├── datasets/          # Data files
├── mlflow/           # MLflow artifacts
└── logs/             # Container logs
```

### Host Mounts
```
~/Desktop/dsi-host-workspace/
├── projects/        → /workspace/projects
├── datasets/        → /workspace/datasets
├── mlflow/         → /workspace/mlflow
├── logs/jupyter/   → /var/log/jupyter
```

## Performance Optimization

### GPU Memory Management
- Set appropriate NVIDIA_MEM_MAX_PERCENT
- Monitor GPU memory with nvidia-smi
- Use GPU memory caching in PyTorch/TensorFlow

### Multi-GPU Setup
- Configure CUDA_VISIBLE_DEVICES
- Use DistributedDataParallel in PyTorch
- Enable multi-GPU training in TensorFlow

### Storage Optimization
- Use appropriate batch sizes
- Enable GPU memory caching
- Monitor MLflow artifacts

## Common Operations

### Basic Container Management
```bash
# View logs
docker logs ds-workspace-gpu

# Access shell
docker exec -it ds-workspace-gpu bash

# Stop container
docker stop ds-workspace-gpu

# Start container
docker start ds-workspace-gpu

# Remove container
docker rm ds-workspace-gpu
```

### Resource Management
```bash
# Run with specific resource limits
docker run -d \
  --name ds-workspace-gpu \
  --gpus all \
  --memory=16g \
  --memory-reservation=8g \
  --cpus=8 \
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
  bhumukulrajds/ds-workspace-gpu:1.0
```

### Multi-GPU Setup
```bash
# Run with multiple GPUs
docker run -d \
  --name ds-workspace-gpu \
  --gpus all \
  -e NVIDIA_VISIBLE_DEVICES=0,1 \  # Specify GPU indices
  ... # (rest of the configuration remains the same)
```

### GPU Monitoring
```bash
# Check GPU status
nvidia-smi

# Monitor GPU usage
docker exec ds-workspace-gpu nvidia-smi -l 1

# Verify PyTorch GPU
docker exec ds-workspace-gpu python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Verify TensorFlow GPU
docker exec ds-workspace-gpu python -c "import tensorflow as tf; print('GPU devices:', tf.config.list_physical_devices('GPU'))"
```

## Troubleshooting

### Common GPU Issues
1. CUDA Version Mismatch
```bash
# Check CUDA version
docker exec ds-workspace-gpu nvcc --version

# Verify CUDA libraries
docker exec ds-workspace-gpu python -c "import torch; print('CUDA version:', torch.version.cuda)"
```

2. GPU Memory Issues
```bash
# Monitor GPU memory
nvidia-smi -l 1

# Clear GPU memory
docker exec ds-workspace-gpu nvidia-smi -r
```

3. Container GPU Access
```bash
# Verify NVIDIA runtime
docker info | grep -i runtime

# Check NVIDIA container toolkit
nvidia-container-cli info
```

## Support

For issues and questions:
- Email: bhumukulraj.ds@gmail.com
- Documentation: [Main README](../README.md)
- Commands Reference: [DOCKER_COMMANDS.md](DOCKER_COMMANDS.md)
- NVIDIA Support: [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html) 