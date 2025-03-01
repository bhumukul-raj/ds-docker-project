# Data Science Environment - GPU Version

## Overview

The GPU version of our Data Science environment is optimized for deep learning and GPU-accelerated computing tasks. It provides a complete development environment with CUDA support, popular deep learning frameworks, and essential data science tools.

## Image Details

- **Base Image**: nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
- **Image Name**: ds-workspace-gpu
- **Version**: 1.2
- **Python Version**: 3.9
- **CUDA Version**: 11.8
- **cuDNN Version**: 8.9.2

## Resource Requirements

### Minimum
- 4 CPU cores
- 16GB RAM
- 40GB disk space
- NVIDIA GPU with 4GB+ VRAM
- NVIDIA Driver 450.80.02+
- NVIDIA Container Toolkit
- Ubuntu 22.04 or compatible Linux distribution

### Recommended
- 8+ CPU cores
- 32GB RAM
- 100GB SSD storage
- NVIDIA GPU with 8GB+ VRAM (RTX series recommended)
- Latest NVIDIA drivers
- Docker Engine 20.10.0+
- Docker Compose 2.0.0+

## Quick Start

### 1. Verify NVIDIA Setup
```bash
# Check NVIDIA drivers
nvidia-smi

# Verify NVIDIA Docker
nvidia-docker version
sudo systemctl status nvidia-docker

# Check CUDA installation
nvcc --version
```

### 2. Start Container
```bash
# Build and start
docker compose --env-file .env build jupyter-gpu
docker compose --env-file .env up -d jupyter-gpu

# Access services:
# JupyterLab: http://localhost:8889
# MLflow: http://localhost:5001
```

### 3. Verify GPU Access
```bash
# Check NVIDIA GPU in container
docker exec ds-workspace-gpu nvidia-smi

# Verify PyTorch GPU access
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import torch; print(\"CUDA available:\", torch.cuda.is_available())'"

# Verify TensorFlow GPU support
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import tensorflow as tf; print(\"GPU devices:\", tf.config.list_physical_devices(\"GPU\"))'"

# Check GPU memory usage
docker exec ds-workspace-gpu nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu --format=csv
```

## Deep Learning Stack

### PyTorch Environment
- PyTorch 2.0.1+cu118
- torchvision 0.15.2+cu118
- torchaudio 2.0.2+cu118
- CUDA 11.8 support
- cuDNN 8.9.2
- Automatic Mixed Precision (AMP) support
- Distributed training support

### TensorFlow Environment
- TensorFlow 2.13.0
- GPU-optimized build
- Mixed precision support
- XLA compilation support
- Horovod integration (optional)
- TensorBoard support

### Additional GPU Libraries
- CuPy 12.2.0
- NVIDIA RAPIDS (optional)
- nvidia-ml-py for GPU monitoring
- NCCL for multi-GPU support
- Numba for CUDA acceleration

## Resource Management

### GPU Memory
```bash
# Set in docker-compose.yml
environment:
  - NVIDIA_VISIBLE_DEVICES=0
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
  - NVIDIA_REQUIRE_CUDA=cuda>=11.8
  - NVIDIA_MEM_MAX_PERCENT=75
  - NVIDIA_GPU_MEM_FRACTION=0.75
  - CUDA_CACHE_PATH=/workspace/.cache/cuda
  - CUDA_CACHE_MAXSIZE=2147483648
```

### Container Resources
```yaml
deploy:
  resources:
    limits:
      cpus: '8'
      memory: 16G
    reservations:
      cpus: '2'
      memory: 4G
  runtime: nvidia
  environment:
    - NVIDIA_VISIBLE_DEVICES=all
    - NVIDIA_DRIVER_CAPABILITIES=all
```

## Performance Optimization

### CUDA Configuration
- Use appropriate CUDA versions
- Enable GPU memory growth
- Set memory limits
- Monitor GPU utilization
- Configure CUDA cache
- Enable CUDA graph optimization

### Deep Learning Best Practices
- Use mixed precision training (FP16/BF16)
- Enable XLA compilation
- Optimize batch sizes
- Monitor GPU memory usage
- Use gradient accumulation
- Enable tensor cores
- Implement data prefetching
- Use efficient data formats

### Multi-GPU Training
- Configure NCCL parameters
- Use appropriate distribution strategy
- Monitor GPU synchronization
- Optimize data parallelism
- Balance GPU workloads

## Troubleshooting

### Common GPU Issues

1. **CUDA Not Available**
```bash
# Check NVIDIA runtime
docker info | grep -i runtime

# Verify NVIDIA Docker installation
which nvidia-docker
nvidia-docker version

# Check container GPU access
docker exec ds-workspace-gpu nvidia-smi

# Verify CUDA installation
docker exec ds-workspace-gpu nvcc --version

# Check CUDA libraries
docker exec ds-workspace-gpu bash -c "ldconfig -p | grep cuda"
```

2. **Memory Issues**
```bash
# Monitor GPU memory
nvidia-smi -l 1

# Check container memory limits
docker stats ds-workspace-gpu

# Monitor specific process GPU usage
nvidia-smi --query-compute-apps=pid,used_memory --format=csv

# Clear GPU memory
nvidia-smi --gpu-reset

# Check memory fragmentation
nvidia-smi --query-gpu=memory.free,memory.total,memory.used --format=csv
```

3. **Driver Issues**
```bash
# Check driver compatibility
nvidia-smi | grep "Driver Version"

# Update NVIDIA drivers if needed
sudo ubuntu-drivers autoinstall

# Verify driver installation
sudo nvidia-smi -pm 1

# Check driver status
systemctl status nvidia-*
```

### Performance Issues

1. **Slow Training**
- Check GPU utilization
- Monitor memory usage
- Verify batch sizes
- Enable profiling
- Check data pipeline
- Monitor PCIe bandwidth
- Analyze CPU bottlenecks

2. **Out of Memory**
- Reduce batch size
- Enable gradient accumulation
- Use mixed precision training
- Clean up unused tensors
- Monitor memory leaks
- Use memory-efficient models
- Implement checkpointing

3. **Multi-GPU Issues**
- Check NCCL configuration
- Monitor GPU synchronization
- Verify network bandwidth
- Balance GPU workloads
- Optimize data distribution

## Maintenance

### Regular Updates
```bash
# Update container
docker compose pull jupyter-gpu
docker compose up -d jupyter-gpu

# Update NVIDIA drivers
sudo apt update
sudo apt install -y nvidia-driver-xxx

# Update CUDA toolkit
sudo apt install -y cuda-toolkit-11-8

# Update container toolkit
sudo apt install -y nvidia-container-toolkit
```

### Cleanup
```bash
# Remove unused resources
docker system prune -a

# Clean NVIDIA cache
rm -rf ~/.nv/
rm -rf /workspace/.cache/cuda

# Clear PyTorch cache
rm -rf ~/.cache/torch/

# Clear container logs
truncate -s 0 $(docker inspect --format='{{.LogPath}}' ds-workspace-gpu)
```

## Best Practices

### Development
- Use version control for notebooks
- Monitor GPU memory usage
- Enable automatic mixed precision
- Profile model performance
- Implement efficient data loading
- Use appropriate batch sizes
- Regular code profiling

### Production
- Use appropriate batch sizes
- Enable XLA compilation
- Monitor GPU utilization
- Set memory limits
- Implement proper logging
- Regular performance monitoring
- Automated health checks

### Security
- Keep drivers updated
- Use non-root user
- Set appropriate permissions
- Monitor resource usage
- Regular security updates
- Access control implementation
- Audit logging

## Support

For issues and questions:
- Check container logs
- Monitor GPU status
- Review error messages
- Check system requirements
- Verify CUDA compatibility
- Contact maintainer: bhumukulraj.ds@gmail.com 