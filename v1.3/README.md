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

### 1. Clone Repository and Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/ds-docker-project.git
cd ds-docker-project

# Run setup scripts
bash scripts/setup_host.sh
bash v1.3/scripts/setup_conf.sh
```

### 2. Build Images with BuildKit
```bash
# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Build CPU image
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env build jupyter-cpu
# Or pull from Docker Hub
docker pull bhumukulrajds/ds-workspace-cpu:1.3

# Build GPU image (if needed)
docker compose --env-file .env build jupyter-gpu
# Or pull from Docker Hub
docker pull bhumukulrajds/ds-workspace-gpu:1.3
```

### 3. Start Containers

#### CPU Version
```bash
# Start CPU container
docker compose --env-file .env up -d jupyter-cpu

# Access at:
# - JupyterLab: http://localhost:8888/lab
```

#### GPU Version
```bash
# Start GPU container
docker compose --env-file .env up -d jupyter-gpu

# Access at:
# - JupyterLab: http://localhost:8889/lab
```

The Jupyter password can be found in:
```bash
cat ${HOME}/Desktop/dsi-host-workspace/config/jupyter/jupyter_password.txt
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

#### GPU Environment (Additional)
- CUDA 11.8
- cuDNN 8.9.2
- PyTorch 2.0.1+cu118
- TensorFlow 2.10.0
- CuPy 12.2.0
- NVIDIA Container Runtime
- GPU Memory Management:
  - Memory Fraction: 0.6 (60% of VRAM)
  - Shared Memory: 2GB
  - Memory Max Percent: 75%

### Security Features
- Read-only root filesystem
- No new privileges restriction
- Dropped capabilities (minimal set required)
- AppArmor profile enabled
- User namespace remapping
- Network isolation (bridge mode)
- Read-only dataset mounts

### Build Optimizations
- Multi-stage builds for smaller images
- BuildKit caching enabled
- Layer optimization
- Conditional package installation
- Resource-aware building

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

### Logging and Monitoring
- Structured JSON logging
- Log rotation and compression
- Separate error logs
- Resource usage metrics
- GPU metrics (for GPU version)
- Health checks with auto-recovery

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

## Usage Guide

### Basic Operations

1. **Start Services:**
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config

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
# View container logs (JSON format)
docker logs ds-workspace-cpu  # or ds-workspace-gpu

# View Jupyter logs
cat ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log

# View error logs
cat ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.error.log
```

### Resource Management

1. **CPU Resource Limits:**
```bash
# View CPU usage
docker stats ds-workspace-cpu

# Adjust CPU limits in .env:
CPU_LIMIT=4
CPU_RESERVATION=2
```

2. **Memory Management:**
```bash
# View memory usage
docker stats ds-workspace-cpu

# Adjust memory limits in .env:
CONTAINER_MEMORY_LIMIT=10G
CONTAINER_MEMORY_RESERVATION=3G
```

3. **GPU Resource Management:**
```bash
# View GPU status
docker exec ds-workspace-gpu nvidia-smi

# Adjust GPU memory fraction in .env:
NVIDIA_GPU_MEM_FRACTION=0.6
```

### Health Checks

1. **Container Health:**
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu

# View health check logs
docker inspect --format='{{json .State.Health}}' ds-workspace-cpu | jq
```

2. **GPU Health:**
```bash
# Check GPU health
docker exec ds-workspace-gpu nvidia-smi

# Verify PyTorch GPU access
docker exec ds-workspace-gpu python3 -c 'import torch; print(torch.cuda.is_available())'
```

## Security Features

### Container Security
1. **Read-only Filesystem:**
   - Root filesystem is read-only
   - Only specific directories are writable
   - Datasets mounted as read-only

2. **Capability Restrictions:**
   - All capabilities dropped by default
   - Only essential capabilities added:
     - CHOWN
     - SETUID
     - SETGID
     - NET_BIND_SERVICE

3. **Network Security:**
   - Bridge network mode
   - DNS configuration
   - Port exposure limited to necessary services

4. **User Security:**
   - Non-root user execution
   - User namespace remapping
   - No privilege escalation

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
   - Check GPU memory fraction setting

3. **Access Issues**
   - Confirm ports are not in use
   - Check Jupyter password file
   - Verify network mode settings
   - Check container health status

### Quick Fixes

1. **Reset Environment:**
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env down
docker compose --env-file .env up -d
```

2. **Regenerate Configuration:**
```bash
bash ${HOME}/Desktop/ds-docker-project/v1.3/scripts/setup_conf.sh
```

3. **Clean Workspace:**
```bash
# Backup data
cp -r ${HOME}/Desktop/dsi-host-workspace/projects ~/Desktop/projects_backup

# Reset workspace
rm -rf ${HOME}/Desktop/dsi-host-workspace/*
bash ${HOME}/Desktop/ds-docker-project/scripts/setup_host.sh
bash ${HOME}/Desktop/ds-docker-project/v1.3/scripts/setup_conf.sh
```

## Common Operations

### Container Management
```bash
# View container status
docker ps -a

# View resource usage
docker stats ds-workspace-cpu  # or ds-workspace-gpu

# View logs
docker logs -f --tail=100 ds-workspace-cpu
```

### Resource Monitoring
```bash
# Monitor GPU usage
watch -n 1 nvidia-smi

# Monitor container resources
docker stats

# View structured logs
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.log | jq
```

For more information and updates, visit the project repository or contact the maintainer at bhumukulraj.ds@gmail.com 