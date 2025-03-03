# Data Science Development Environment

A comprehensive Docker-based development environment for data science, with separate CPU and GPU configurations. This environment provides a complete setup with JupyterLab, MLflow, and essential data science tools.

Version: 1.2  
Maintainer: bhumukulraj.ds@gmail.com

## Quick Links
- [Docker Hub CPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-cpu)
- [Docker Hub GPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-gpu)
- [Documentation](docs/)
- [Changelog](docs/CHANGELOG.md)

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

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/ds-docker-project.git
cd ds-docker-project

# Run setup scripts
bash scripts/setup_host.sh
bash v1.2/scripts/setup_conf.sh
```

### 2. Environment Configuration
```bash
# Configuration files are automatically set up in
~/Desktop/dsi-host-workspace/config/
```

### 3. Start Containers

#### CPU Version
```bash
cd ~/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-cpu

# Access at:
# - JupyterLab: http://localhost:8888/lab
# - MLflow: http://localhost:5000
```

#### GPU Version
```bash
cd ~/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-gpu

# Access at:
# - JupyterLab: http://localhost:8888/lab
# - MLflow: http://localhost:5000
```

## Environment Details

### Core Components

#### CPU Environment
- Python 3.9
- JupyterLab 3.6.5
- MLflow 2.6.0
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

## Directory Structure
```
~/Desktop/dsi-host-workspace/
├── config/
│   ├── jupyter/          # Jupyter configuration
│   ├── docker-compose.yml
│   └── .env
├── projects/            # Your notebooks and code
├── datasets/           # Data storage
├── mlflow/             # MLflow tracking
│   ├── artifacts/
│   └── db/
└── logs/              # Container and application logs
    └── jupyter/
```

## Usage Guide

### Basic Operations

1. **Start Services:**
```bash
cd ~/Desktop/dsi-host-workspace/config

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

### GPU Support Verification
```bash
# Check NVIDIA GPU status
docker exec ds-workspace-gpu nvidia-smi

# Verify PyTorch GPU access
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import torch; print(torch.cuda.is_available())'"

# Verify TensorFlow GPU access
docker exec ds-workspace-gpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-gpu && python3 -c 'import tensorflow as tf; print(tf.config.list_physical_devices(\"GPU\"))'"
```

### Container Management
```bash
# View container status
docker ps -a

# View resource usage
docker stats ds-workspace-cpu  # or ds-workspace-gpu
```

### Viewing Logs
```bash
# View container logs
docker logs ds-workspace-cpu  # or ds-workspace-gpu

# View Jupyter logs
cat ~/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log
```

## Troubleshooting

### Common Issues and Solutions

1. **Container Fails to Start**
   - Check container logs: `docker logs ds-workspace-cpu`
   - Verify port availability
   - Check resource limits in config/.env
   - Ensure directories exist with correct permissions

2. **GPU Issues**
   - Verify NVIDIA drivers: `nvidia-smi`
   - Check NVIDIA Container Toolkit
   - Validate CUDA compatibility
   - Monitor GPU memory usage

3. **Access Issues**
   - Confirm ports are not in use
   - Check Jupyter password file
   - Verify network settings
   - Check container health status

### Quick Fixes

1. **Reset Environment:**
```bash
cd ~/Desktop/dsi-host-workspace/config
docker compose --env-file .env down
docker compose --env-file .env up -d
```

2. **Regenerate Configuration:**
```bash
bash ~/Desktop/ds-docker-project/v1.2/scripts/setup_conf.sh
```

3. **Clean Workspace:**
```bash
# Backup data
cp -r ~/Desktop/dsi-host-workspace/projects ~/Desktop/projects_backup

# Reset workspace
rm -rf ~/Desktop/dsi-host-workspace/*
bash ~/Desktop/ds-docker-project/scripts/setup_host.sh
bash ~/Desktop/ds-docker-project/v1.2/scripts/setup_conf.sh
```

## Security Features

- Non-root user execution
- Password-protected JupyterLab
- Read-only mounting of sensitive files
- Regular security updates
- Limited port exposure
- Container resource limits
- Host-mounted storage for persistence

## Support and Contribution

For issues, feature requests, or contributions, please:
1. Check existing issues on the GitHub repository
2. Create a new issue with detailed information
3. Follow the contribution guidelines in CONTRIBUTING.md

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Version History

- v1.0: Initial release with basic CPU and GPU support
- v1.1: Added enhanced monitoring and resource management
- v1.2: Improved configuration management and security features 