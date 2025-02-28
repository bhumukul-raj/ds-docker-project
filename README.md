# Data Science Docker Project

This repository contains Docker environments for data science development, with separate CPU and GPU configurations. It provides a complete development environment with JupyterLab, MLflow, and essential data science tools.

## Quick Links
- [Latest Documentation (v1.1.0)](v1.1.0/README.md)
- [Previous Version (v1.0.0)](v1.0.0/README.md)
- [Docker Commands](v1.1.0/docs/DOCKER_COMMANDS.md)
- [Changelog](v1.1.0/docs/CHANGELOG.md)
- [Docker Hub CPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-cpu)
- [Docker Hub GPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-gpu)

## Docker Hub Images

Pre-built images are available on Docker Hub:

```bash
# CPU Version
docker pull bhumukulrajds/ds-workspace-cpu:1.1.0
docker pull bhumukulrajds/ds-workspace-cpu:latest

# GPU Version
docker pull bhumukulrajds/ds-workspace-gpu:1.1.0
docker pull bhumukulrajds/ds-workspace-gpu:latest
```

## System Requirements

### Minimum (CPU Version)
- 4 CPU cores
- 8GB RAM
- 20GB disk space
- Docker Engine 20.10.0+
- Docker Compose 2.0.0+
- Ubuntu 22.04 or compatible Linux distribution

### Recommended (GPU Version)
- 8+ CPU cores
- 32GB RAM
- 100GB SSD storage
- NVIDIA GPU with 8GB+ VRAM (RTX series recommended)
- Latest NVIDIA drivers
- NVIDIA Container Toolkit
- Ubuntu 22.04 or compatible Linux distribution

## Quick Start Guide

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

# Required environment variables
JUPYTER_PASSWORD=your_secure_password  # Min 12 characters

# Optional environment variables
CONTAINER_MEMORY_LIMIT=12G
CONTAINER_MEMORY_RESERVATION=4G
TZ=UTC
MLFLOW_TRACKING_URI=sqlite:///workspace/mlflow/db/mlflow.db
```

### 3. Start Containers

#### CPU Version
```bash
# Build and start
docker compose --env-file .env build jupyter-cpu
docker compose --env-file .env up -d jupyter-cpu

# Access at:
# JupyterLab: http://localhost:8888
# MLflow: http://localhost:5000
```

#### GPU Version
```bash
# Build and start
docker compose --env-file .env build jupyter-gpu
docker compose --env-file .env up -d jupyter-gpu

# Access at:
# JupyterLab: http://localhost:8889
# MLflow: http://localhost:5001
```

## Key Features

### Development Environment
- Python 3.9 with optimized numerical computations
- JupyterLab 3.6.5 with extensive extensions
- MLflow 2.8.1 for experiment tracking
- Pre-configured GPU support (CUDA 11.8, cuDNN 8.9.2)
- Advanced resource monitoring and health checks

### Core Packages
- Data Analysis: 
  - NumPy 1.24.3
  - Pandas 1.5.3
  - Scipy 1.11.2
  - Scikit-learn 1.3.0
- Machine Learning:
  - XGBoost 1.7.6
  - LightGBM 4.0.0
  - MLflow 2.8.1
- Deep Learning (GPU):
  - PyTorch 2.0.1
  - TensorFlow 2.13.0
  - CUDA 11.8
  - cuDNN 8.9.2
- Visualization:
  - Matplotlib 3.7.2
  - Seaborn 0.12.2
  - Plotly 5.16.1

### Development Tools
- Git with LFS support
- Pre-commit hooks for code quality
- Black, Flake8, MyPy for code formatting and linting
- Advanced logging and monitoring

## Common Operations

### Container Management
```bash
# View container logs
docker logs ds-workspace-cpu  # or ds-workspace-gpu

# Access container shell
docker exec -it ds-workspace-cpu bash  # or ds-workspace-gpu

# Monitor resource usage
docker stats ds-workspace-cpu  # or ds-workspace-gpu

# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
```

### GPU Verification
```bash
# Check NVIDIA GPU in container
docker exec ds-workspace-gpu nvidia-smi

# Verify PyTorch GPU access
docker exec ds-workspace-gpu python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Verify TensorFlow GPU access
docker exec ds-workspace-gpu python -c "import tensorflow as tf; print('GPU devices:', tf.config.list_physical_devices('GPU'))"
```

## Troubleshooting

### Common Issues

1. Permission Issues:
```bash
# Fix workspace permissions
sudo chown -R $USER:$USER ~/Desktop/dsi-host-workspace
sudo chmod -R 755 ~/Desktop/dsi-host-workspace
```

2. Port Conflicts:
```bash
# Check ports in use
sudo lsof -i :8888  # CPU JupyterLab
sudo lsof -i :8889  # GPU JupyterLab
sudo lsof -i :5000  # CPU MLflow
sudo lsof -i :5001  # GPU MLflow
```

3. GPU Issues:
```bash
# Verify NVIDIA drivers
nvidia-smi

# Check NVIDIA Container Toolkit
nvidia-container-cli info

# Verify GPU in container
docker exec ds-workspace-gpu nvidia-smi
```

## Support and Documentation

- For detailed documentation, see [v1.1.0/README.md](v1.1.0/README.md)
- For Docker commands reference, see [DOCKER_COMMANDS.md](v1.1.0/docs/DOCKER_COMMANDS.md)
- For version history, see [CHANGELOG.md](v1.1.0/docs/CHANGELOG.md)
- For issues or questions, contact the maintainer

## Maintainer

bhumukulraj.ds@gmail.com 