# Data Science Environment - GPU Version

## Overview

The GPU version of our Data Science environment is designed for deep learning and GPU-accelerated machine learning tasks. It provides a powerful environment with CUDA support and optimized GPU performance.

## Image Details

- **Base Image**: nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
- **Image Name**: bhumukulrajds/ds-workspace-gpu
- **Version**: 1.3
- **Python Version**: 3.9
- **CUDA Version**: 11.8
- **cuDNN Version**: 8

## Resource Requirements

### Minimum
- NVIDIA GPU with CUDA support
- 8GB GPU memory
- 8 CPU cores
- 16GB RAM
- 40GB disk space
- Docker Engine 20.10.0+
- NVIDIA Container Toolkit
- Ubuntu 22.04 or compatible Linux distribution

### Recommended
- NVIDIA GPU with 12GB+ memory
- 12+ CPU cores
- 32GB RAM
- 100GB SSD storage
- Docker Compose 2.0.0+

## Quick Start

### 1. Setup Environment
```bash
# Create workspace directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,logs/jupyter,datasets}

# Set permissions
chmod -R 777 ~/Desktop/dsi-host-workspace
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

### Deep Learning Frameworks
- PyTorch 2.0.1 (CUDA 11.8)
- TensorFlow 2.13.0
- CUDA Toolkit 11.8
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
- XGBoost 1.7.6 (GPU)
- LightGBM 4.0.0 (GPU)
- Dask 2023.3.2
- Dask-CUDA 23.6.0

### Development Environment
- JupyterLab 3.6.5
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

## Resource Management

### Container Configuration
```yaml
deploy:
  resources:
    limits:
      cpus: '8'
      memory: 16G
    reservations:
      cpus: '4'
      memory: 8G
```

### Environment Variables
```bash
# Required
JUPYTER_PASSWORD=your_secure_password

# Optional
CONTAINER_MEMORY_LIMIT=16G
CONTAINER_MEMORY_RESERVATION=8G
NVIDIA_VISIBLE_DEVICES=0
NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
NVIDIA_REQUIRE_CUDA=cuda>=11.8
```

## Performance Optimization

### GPU Optimization
- CUDA-aware memory management
- Multi-GPU support
- Optimized deep learning operations
- GPU-accelerated data processing

### Memory Management
- Set appropriate GPU memory limits
- Monitor GPU memory usage
- Use GPU memory-efficient operations
- Enable GPU-accelerated processing

### Storage Optimization
- Use efficient data formats (parquet, feather)
- Implement data chunking
- Regular cleanup of unused data

## Troubleshooting

### Common Issues

1. **Container Fails to Start**
```bash
# Check logs
docker logs ds-workspace-gpu

# Verify GPU availability
nvidia-smi

# Check resource usage
docker stats ds-workspace-gpu
```

2. **GPU Issues**
```bash
# Check NVIDIA driver
nvidia-smi

# Monitor GPU usage
watch -n 1 nvidia-smi

# Verify CUDA installation
docker exec ds-workspace-gpu python -c "import torch; print(torch.cuda.is_available())"
```

3. **JupyterLab Access Issues**
```bash
# Check JupyterLab logs
docker exec ds-workspace-gpu bash -c "cat /workspace/logs/jupyter.log"

# Verify JupyterLab process
docker exec ds-workspace-gpu ps aux | grep jupyter

# Check port forwarding
docker port ds-workspace-gpu
```

### Recovery Steps

1. **Complete Reset**
```bash
# Stop container
docker compose --env-file .env down

# Remove container and volumes
docker compose --env-file .env down -v

# Rebuild from scratch
docker compose --env-file .env build --no-cache jupyter-gpu
docker compose --env-file .env up -d jupyter-gpu
```

2. **Clean Workspace**
```bash
# Backup data
cp -r ~/Desktop/dsi-host-workspace/projects ~/Desktop/projects_backup

# Reset workspace
rm -rf ~/Desktop/dsi-host-workspace/*
mkdir -p ~/Desktop/dsi-host-workspace/{projects,logs/jupyter,datasets}
chmod -R 777 ~/Desktop/dsi-host-workspace
```

## Common Operations

### Container Management
```bash
# Start container
docker compose --env-file .env up -d jupyter-gpu

# Stop container
docker compose --env-file .env stop jupyter-gpu

# Restart container
docker compose --env-file .env restart jupyter-gpu

# Access shell
docker exec -it ds-workspace-gpu bash
```

### Data Management
```bash
# Backup workspace
tar -czf workspace_backup.tar.gz ~/Desktop/dsi-host-workspace

# Restore workspace
tar -xzf workspace_backup.tar.gz -C ~/Desktop/

# Clean unused data
docker system prune -a
```

### Development Workflow
```bash
# Access JupyterLab
# Open http://localhost:8889 in browser
```

## Best Practices

### Development
- Use version control
- Implement proper logging
- Write unit tests
- Document code and notebooks

### Production
- Monitor GPU usage
- Regular backups
- Keep dependencies updated
- Use appropriate resource limits

### Security
- Keep system updated
- Use non-root user
- Set appropriate permissions
- Monitor access logs

## Support

For issues and questions:
- Check container logs
- Monitor GPU resources
- Review error messages
- Contact maintainer: bhumukulraj.ds@gmail.com 