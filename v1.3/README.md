# Data Science Development Environment v1.3

A comprehensive Docker-based development environment for data science, with separate CPU and GPU configurations. This environment provides a complete setup with JupyterLab and essential data science tools.

## Table of Contents
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Environment Details](#environment-details)
- [Usage Guide](#usage-guide)
- [Security Features](#security-features)
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
  - BuildKit enabled for Docker

- **Recommended:**
  - 8+ CPU cores
  - 16GB RAM (10GB allocated to container)
  - 40GB disk space
  - SSD storage
  - Docker Compose v2.0+

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
  - 16GB+ system RAM (12GB allocated to container)
  - GPU memory fraction set to 0.6 (60% of available VRAM)

## Quick Start

### 1. Initial Setup
```bash
# Create workspace directories
bash scripts/setup_host.sh

# Generate configuration files
bash scripts/setup_conf.sh
```

### 2. Environment Configuration
The setup scripts will create:
- Workspace directory at: ${HOME}/Desktop/dsi-host-workspace
- Configuration files in: ${HOME}/Desktop/dsi-host-workspace/config
- Jupyter password in: ${HOME}/Desktop/dsi-host-workspace/config/jupyter/jupyter_password.txt

### 3. Start Services

#### CPU Version
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-cpu

# Access JupyterLab at: http://localhost:8888
```

#### GPU Version
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-gpu

# Access JupyterLab at: http://localhost:8889
```

## Environment Details

### Core Components

#### CPU Environment
- Python 3.9
- JupyterLab 4.0.7
- NumPy 1.24.3
- Pandas 1.5.3
- Scikit-learn 1.3.0
- XGBoost 1.7.6
- LightGBM 4.0.0
- Dask 2023.3.2

#### GPU Environment (Additional)
- CUDA 11.8
- cuDNN 8.9.2
- PyTorch 2.0.1+cu118
- TensorFlow 2.13.0
- CuPy 12.2.0
- Dask-CUDA 23.6.0

### Directory Structure
```
${HOME}/Desktop/dsi-host-workspace/
├── config/
│   ├── jupyter/          # Jupyter configuration
│   ├── docker-compose.yml
│   └── .env
├── projects/            # Your notebooks and code
├── datasets/           # Data storage (read-only)
└── logs/              # Container and application logs
    ├── jupyter/       # Jupyter logs
    └── error/         # Error logs
```

### Security Features
- Read-only root filesystem
- No new privileges restriction
- Dropped capabilities (minimal set)
- AppArmor profile enabled
- User namespace remapping
- Network isolation (bridge mode)
- Read-only dataset mounts

### Resource Management
- CPU limits configurable in .env
- Memory limits configurable in .env
- GPU memory fraction: 0.6 (60% of VRAM)
- Container health monitoring
- Resource usage metrics

## Usage Guide

### Basic Operations

1. **Start Services:**
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config

# Start CPU container
docker compose --env-file .env up -d jupyter-cpu

# Start GPU container
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
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log

# View error logs
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.error.log
```

### Resource Management

1. **CPU Resources:**
```bash
# View CPU usage
docker stats ds-workspace-cpu

# Configure in .env:
CPU_LIMIT=9
CPU_RESERVATION=2
```

2. **Memory Management:**
```bash
# View memory usage
docker stats ds-workspace-cpu

# Configure in .env:
CONTAINER_MEMORY_LIMIT=10
CONTAINER_MEMORY_RESERVATION=3
```

3. **GPU Resources:**
```bash
# View GPU status
docker exec ds-workspace-gpu nvidia-smi

# Configure in .env:
NVIDIA_GPU_MEM_FRACTION=0.6
NVIDIA_MEM_MAX_PERCENT=75
```

## Troubleshooting

### Common Issues

1. **Container Startup Issues:**
   - Check logs: `docker logs ds-workspace-cpu`
   - Verify ports: `docker port ds-workspace-cpu`
   - Check resources: `docker stats`

2. **GPU Issues:**
   - Verify NVIDIA drivers: `nvidia-smi`
   - Check CUDA: `docker exec ds-workspace-gpu nvidia-smi -L`
   - Monitor GPU memory: `nvidia-smi -l 1`

3. **Resource Issues:**
   - Check system resources: `htop`
   - Monitor container stats: `docker stats`
   - View process list: `docker top ds-workspace-cpu`

For more detailed information, check:
- [CPU Overview](docs/CPU_OVERVIEW.md)
- [GPU Overview](docs/GPU_OVERVIEW.md)
- [Docker Commands](docs/DOCKER_COMMANDS.md)
- [Changelog](docs/CHANGELOG.md)

## Support

For issues and support, please:
1. Check the troubleshooting guides
2. Review container logs
3. Monitor resource usage
4. Contact maintainer at bhumukulraj.ds@gmail.com 