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

## NVIDIA Container Toolkit Setup

The NVIDIA Container Toolkit is required to use GPUs with Docker containers. Follow these steps to set it up:

### 1. Install NVIDIA Container Toolkit
```bash
# Add NVIDIA Container Toolkit repository GPG key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# Add NVIDIA Container Toolkit repository
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package list and install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

### 2. Configure Docker Runtime
```bash
# Configure Docker to use NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker daemon to apply changes
sudo systemctl restart docker
```

### 3. Verify Installation
```bash
# Check NVIDIA driver
nvidia-smi

# Verify Docker NVIDIA runtime
docker info | grep -i runtime

# Test with a simple CUDA container
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Common Issues
1. **Runtime not found error**: If you see "unknown runtime: nvidia" error, make sure you've:
   - Installed NVIDIA Container Toolkit
   - Configured Docker runtime
   - Restarted Docker daemon

2. **GPU not detected**: Verify that:
   - NVIDIA drivers are installed: `nvidia-smi`
   - Docker has GPU access: `docker info | grep -i runtime`
   - Container has GPU capabilities enabled in docker-compose.yml

3. **Permission issues**: Ensure your user is in the docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

## Quick Start

### 1. Download Setup Scripts
```bash
# Create scripts directory
mkdir -p scripts

# Download setup scripts
curl -o scripts/setup_host.sh https://raw.githubusercontent.com/bhumukul-raj/ds-docker-project/refs/heads/main/v1.3/scripts/setup_host.sh
curl -o scripts/setup_conf.sh https://raw.githubusercontent.com/bhumukul-raj/ds-docker-project/refs/heads/main/v1.3/scripts/setup_conf.sh

# Make scripts executable
chmod +x scripts/setup_host.sh scripts/setup_conf.sh
```

### 2. Setup Environment
```bash
# Run setup scripts
bash scripts/setup_host.sh
bash scripts/setup_conf.sh

# Verify NVIDIA setup
nvidia-smi
```

### 3. Start Container
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-gpu

# Access JupyterLab at: http://localhost:8889
```

### 4. Verify Setup
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
- TensorFlow 2.13.0
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
  - Resource monitoring
  - Code formatting
  - Language server
  - Variable inspector
  - Draw.io integration
  - LaTeX support
  - System monitor
  - Execution time

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
      cpus: '9'
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
shm_size: "2g"
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
- Memory fraction control (60% of VRAM)
- Shared memory allocation (2GB)
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
   - Check NVIDIA driver version: `nvidia-smi`
   - Verify NVIDIA Container Toolkit: `docker info | grep -i runtime`
   - Validate CUDA: `docker exec ds-workspace-gpu nvidia-smi -L`
   - Check GPU memory: `nvidia-smi -q -d MEMORY`

2. **Performance Issues**
   - Monitor GPU utilization: `nvidia-smi -l 1`
   - Check memory allocation: `nvidia-smi -q -d MEMORY`
   - Verify process limits: `docker stats ds-workspace-gpu`
   - Review cache settings: `ls -la /workspace/.cache/cuda`

3. **Container Issues**
   - Check container health: `docker inspect ds-workspace-gpu`
   - Verify resource limits: `docker stats`
   - Monitor log files: `tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log`
   - Validate GPU access: `docker exec ds-workspace-gpu python3 -c "import torch; print(torch.cuda.is_available())"` 

### Debug Commands
```bash
# Check container status
docker ps -a | grep ds-workspace-gpu

# View resource usage
docker stats ds-workspace-gpu

# Check logs
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.error.log

# Inspect container
docker inspect ds-workspace-gpu

# Check GPU
nvidia-smi -q
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
CPU_LIMIT=9
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

For issues and support:
1. Check the troubleshooting section above
2. Review container and GPU logs
3. Monitor resource usage
4. Contact maintainer at bhumukulraj.ds@gmail.com 