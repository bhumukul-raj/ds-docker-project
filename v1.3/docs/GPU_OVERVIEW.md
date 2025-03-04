# Data Science Environment - GPU Version

## Overview

The GPU version of our Data Science environment is optimized for deep learning and GPU-accelerated computations. It includes all CPU version features plus GPU-specific tools and libraries configured for optimal performance with NVIDIA GPUs.

## Image Details

- **Base Image**: nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
- **Image Name**: bhumukulrajds/ds-workspace-gpu
- **Version**: 1.3
- **Python Version**: 3.9
- **CUDA Version**: 11.8
- **cuDNN Version**: 8.9.2

## Resource Requirements

### Minimum Requirements
- All CPU version requirements
- NVIDIA GPU with 4GB+ VRAM
- NVIDIA Driver 450.80.02+
- NVIDIA Container Toolkit
- CUDA 11.8 compatible GPU
- BuildKit enabled

### Recommended Configuration
- 8+ CPU cores
- 16GB+ system RAM (12GB allocated to container)
- NVIDIA GPU with 8GB+ VRAM
- Latest NVIDIA drivers
- 40GB SSD storage
- Fast network connection
- Docker Compose v2.0+

## Quick Start

### 1. Setup Environment
```bash
# Create workspace directories
mkdir -p ${HOME}/Desktop/dsi-host-workspace/{projects,logs/jupyter,datasets}

# Set permissions
chmod -R 755 ${HOME}/Desktop/dsi-host-workspace
```

### 2. Start Container
```bash
# Build and start
docker compose --env-file .env build jupyter-gpu
docker compose --env-file .env up -d jupyter-gpu

# Access services:
# JupyterLab: http://localhost:8889
```

### 3. Verify Setup
```bash
# Check container status
docker ps | grep ds-workspace-gpu

# View logs
docker logs ds-workspace-gpu

# Test GPU availability
docker exec ds-workspace-gpu nvidia-smi
```

## Core Components

### Deep Learning Stack
- PyTorch 2.0.1+cu118
- TensorFlow 2.10.0
- CuPy 12.2.0
- NVIDIA CUDA 11.8
- cuDNN 8.9.2
- NCCL 2.18.3

### Data Science Stack
- NumPy 1.24.3
- Pandas 1.5.3
- Scipy 1.11.2
- Scikit-learn 1.3.0
- Matplotlib 3.7.2
- Seaborn 0.12.2
- Plotly 5.16.1

### Machine Learning
- XGBoost 1.7.6
- LightGBM 4.0.0
- Dask 2023.3.2
- Dask-CUDA 23.6.0

### Development Environment
- JupyterLab 4.0.7
- Jupyter Extensions:
  - Git integration
  - System monitor
  - Code formatting
  - Language server
  - Variable inspector
  - Draw.io integration
  - LaTeX support
- Visual Studio Code Server

### Development Tools
- Git with LFS support
- Black 23.7.0 (formatter)
- Flake8 6.1.0 (linter)
- MyPy 1.5.1 (type checker)
- isort 5.12.0 (import sorter)
- pytest 7.4.0 (testing)

## Directory Structure
```
${HOME}/Desktop/dsi-host-workspace/
├── config/
│   ├── jupyter/          # Jupyter configuration
│   ├── docker-compose.yml
│   └── .env
├── projects/            # Your notebooks and code
├── datasets/           # Data storage
└── logs/              # Container and application logs
    └── jupyter/       # Jupyter logs
```

## Resource Management

### Container Configuration
```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 12G
    reservations:
      cpus: '2'
      memory: 4G
```

### GPU Configuration
```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display
  - NVIDIA_REQUIRE_CUDA=cuda>=11.8
  - NVIDIA_MEM_MAX_PERCENT=75
  - NVIDIA_GPU_MEM_FRACTION=0.6
  - CUDA_CACHE_PATH=/workspace/.cache/cuda
  - TORCH_HOME=/workspace/.cache/torch
```

### NVIDIA Runtime
```yaml
runtime: nvidia
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## Performance Optimization

### Build Optimization
- Multi-stage builds for smaller images
- BuildKit caching enabled
- Layer optimization
- Conditional package installation
- Resource-aware building

### GPU Optimization
- Optimized CUDA configuration
- Memory fraction control
- Shared memory allocation
- Process scheduling
- Cache management

### Resource Management
- GPU memory monitoring
- CPU/Memory tracking
- Disk space validation
- Process monitoring
- Resource metrics collection

## Logging and Monitoring

### Log Configuration
- Structured JSON logging
- Log rotation enabled
- Log compression
- Separate error logs
- GPU metrics collection

### Health Checks
```bash
# Container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-gpu

# View health check logs
docker inspect --format='{{json .State.Health}}' ds-workspace-gpu | jq

# GPU status
nvidia-smi

# Resource monitoring
docker stats ds-workspace-gpu

# View logs
docker logs -f ds-workspace-gpu | jq
```

### GPU Metrics
```bash
# Monitor GPU usage
watch -n 1 nvidia-smi

# Check CUDA availability
docker exec ds-workspace-gpu python3 -c 'import torch; print(torch.cuda.is_available())'

# View GPU metrics
docker exec ds-workspace-gpu nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.free,temperature.gpu --format=csv
```

## Troubleshooting

### Common Issues

1. **GPU Access Issues**
   - Check NVIDIA driver version
   - Verify NVIDIA Container Toolkit
   - Validate CUDA compatibility
   - Check GPU memory fraction

2. **Performance Issues**
   - Monitor GPU utilization
   - Check memory allocation
   - Verify process limits
   - Review cache settings

3. **Container Issues**
   - Check container health
   - Verify resource limits
   - Monitor log files
   - Validate GPU access

### Debug Commands
```bash
# Check container status
docker ps -a | grep ds-workspace-gpu

# View GPU status
nvidia-smi

# Check CUDA
docker exec ds-workspace-gpu nvidia-smi -L

# View logs
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.error.log

# Check GPU metrics
docker exec ds-workspace-gpu nvidia-smi dmon
```

## Security Features

### File System Security
- Read-only root filesystem
- Limited writable directories
- Read-only dataset mounts
- Proper permissions

### Process Security
- No privilege escalation
- Limited capabilities
- Process isolation
- Resource limits

### Network Security
- Bridge network isolation
- Limited port exposure
- DNS configuration
- Network access control

### User Security
- Non-root execution
- User namespace remapping
- Group permissions
- Volume ownership

## Directory Structure
```
${HOME}/Desktop/dsi-host-workspace/
├── config/
│   ├── jupyter/          # Jupyter configuration
│   ├── docker-compose.yml
│   └── .env
├── projects/            # Notebooks and code
├── datasets/           # Read-only data storage
└── logs/              # Container and application logs
    ├── jupyter/       # Jupyter logs
    └── error/         # Error logs
```

## Environment Variables
```bash
# GPU Configuration
NVIDIA_VISIBLE_DEVICES=0
NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display
NVIDIA_REQUIRE_CUDA=cuda>=11.8
NVIDIA_GPU_MEM_FRACTION=0.6
NVIDIA_MEM_MAX_PERCENT=75

# Resource Configuration
CPU_LIMIT=4
CPU_RESERVATION=2
CONTAINER_MEMORY_LIMIT=12G
CONTAINER_MEMORY_RESERVATION=4G

# Python Configuration
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
PYTHONHASHSEED=random
PYTHONGC=2

# CUDA Configuration
CUDA_DEVICE_ORDER=PCI_BUS_ID
CUDA_VISIBLE_DEVICES=0
CUDA_CACHE_PATH=/workspace/.cache/cuda
TORCH_HOME=/workspace/.cache/torch

# Container Configuration
TZ=UTC
USER_UID=1000
USER_GID=1000
```

## Maintenance

### Regular Tasks
1. GPU driver updates
2. CUDA toolkit updates
3. Log rotation and cleanup
4. Resource monitoring
5. Security updates

### Best Practices
1. Regular GPU health checks
2. Memory usage monitoring
3. Temperature monitoring
4. Performance optimization
5. Log analysis

## Support

For issues and support, please:
1. Check the troubleshooting guide
2. Review container logs
3. Monitor GPU metrics
4. Contact maintainer at bhumukulraj.ds@gmail.com 