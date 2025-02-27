# Data Science Docker Environment

Version: 1.0.0  
Maintainer: bhumukulraj.ds@gmail.com

This repository contains a secure and optimized Docker setup for data science projects with separate CPU and GPU environments.

## Quick Links
- [Docker Hub CPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-cpu)
- [Docker Hub GPU Image](https://hub.docker.com/r/bhumukulrajds/ds-workspace-gpu)
- [Docker Commands](docs/DOCKER_COMMANDS.md)
- [Changelog](docs/CHANGELOG.md)

## Docker Hub Images

Official images are available on Docker Hub:

```bash
# CPU Version
docker pull bhumukulrajds/ds-workspace-cpu:1.0.0
docker pull bhumukulrajds/ds-workspace-cpu:latest

# GPU Version
docker pull bhumukulrajds/ds-workspace-gpu:1.0.0
docker pull bhumukulrajds/ds-workspace-gpu:latest
```

## Technical Specifications

### Base Images
- CPU: ubuntu:22.04
- GPU: nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

### Python Environment
- Python 3.9
- Conda/Mamba for package management
- Optimized numerical computations with OpenBLAS

### Resource Management
- Default CPU allocation: 75% of available cores
- Default Memory allocation: 75% of system RAM
- GPU Memory: 75% of available VRAM
- Swap space: 2GB

## Service Configuration

### JupyterLab
- CPU Version: http://localhost:8888
- GPU Version: http://localhost:8889
- Authentication: Password protected (set via JUPYTER_PASSWORD)
- Workspace: /workspace
- Extensions:
  - Git integration
  - System monitor
  - Resource usage
  - Server proxy

### MLflow
- CPU Version: http://localhost:5000
- GPU Version: http://localhost:5001
- Backend: SQLite (host-mounted at ~/Desktop/dsi-host-workspace/mlflow/mlflow.db)
- Artifact Store: ~/Desktop/dsi-host-workspace/mlflow
- Workers: 4
- Persistence: Host-mounted storage for data retention
- Shared tracking: Both CPU and GPU containers use the same database

## Environment Setup

### Required Environment Variables
```bash
# Required
JUPYTER_PASSWORD=your_secure_password  # Min 12 characters

# Optional with defaults
HOST_WORKSPACE_DIR=/home/$USER/Desktop/dsi-host-workspace  # Host workspace path
CONTAINER_MEMORY_LIMIT=12G
CONTAINER_MEMORY_RESERVATION=4G
TZ=UTC
MLFLOW_TRACKING_URI=sqlite:///home/$USER/Desktop/dsi-host-workspace/mlflow/mlflow.db
NVIDIA_VISIBLE_DEVICES=all            # GPU only
NVIDIA_DRIVER_CAPABILITIES=all        # GPU only
CUDA_VISIBLE_DEVICES=0                # GPU only
```

### Host Directory Setup
```bash
# Create required directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,.ssh,gitconfig,mlflow,logs/jupyter,datasets}

# Set proper permissions
sudo chown -R $USER:$USER ~/Desktop/dsi-host-workspace
sudo chmod -R 755 ~/Desktop/dsi-host-workspace
```

## Deployment Methods

### 1. Using Pre-built Images (Recommended)
```bash
# Pull and start CPU version
docker compose -f docker/docker-compose.yml --env-file .env pull jupyter-cpu
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu

# Pull and start GPU version
docker compose -f docker/docker-compose.yml --env-file .env pull jupyter-gpu
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu
```

### 2. Building from Source
```bash
# Set required environment variables and build
export HOST_WORKSPACE_DIR=/home/$USER/Desktop/dsi-host-workspace && \
export JUPYTER_PASSWORD=DataScience@2024 && \
export TZ=UTC && \
export MLFLOW_TRACKING_URI=sqlite:///home/$USER/Desktop/dsi-host-workspace/mlflow/mlflow.db && \
mkdir -p /home/$USER/Desktop/dsi-host-workspace/mlflow && \
docker compose -f docker/docker-compose.yml build jupyter-cpu jupyter-gpu

# Start containers after build
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu  # For CPU
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu  # For GPU
```

### Build Resource Requirements
- CPU Version: ~15-20 minutes, peaks at 4GB RAM
- GPU Version: ~25-30 minutes, peaks at 6GB RAM
- Total disk space required: ~30GB (both versions)

## Directory Structure

### Container Paths
```
/workspace/
├── projects/          # Your code and notebooks
├── datasets/          # Data files
├── mlflow/           # MLflow artifacts
└── logs/             # Container logs
    ├── entrypoint.log
    ├── mlflow.log
    └── mlflow.pid

/home/ds-user-ds/
├── .jupyter/         # Jupyter configuration
├── .ssh/            # SSH keys (read-only)
└── .gitconfig       # Git configuration
```

### Host Mounts
```
~/Desktop/dsi-host-workspace/
├── projects/        → /workspace/projects
├── datasets/        → /workspace/datasets
├── mlflow/         → /workspace/mlflow
├── logs/jupyter/   → /var/log/jupyter
├── .ssh/           → /home/ds-user-ds/.ssh
└── gitconfig/      → /home/ds-user-ds/.gitconfig
```

## Installed Packages

### Core Data Science
- NumPy 1.24.3
- Pandas 1.5.3
- Scipy 1.11.2
- Scikit-learn 1.3.0

### Machine Learning
- XGBoost 1.7.6
- LightGBM 4.0.0
- MLflow 2.6.0

### Deep Learning (GPU Only)
- PyTorch 2.0.1
- TensorFlow 2.13.0
- CUDA 11.8
- cuDNN 8.9.2

### Visualization
- Matplotlib 3.7.2
- Seaborn 0.12.2
- Plotly 5.16.1

### Development Tools
- Git + Git LFS
- Black 23.7.0
- Flake8 6.1.0
- MyPy 1.5.1
- Pre-commit hooks

## Container Management

### Starting Services
```bash
# CPU Environment
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu

# GPU Environment
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu
```

### Monitoring
```bash
# View container logs
docker logs -f ds-workspace-cpu
docker logs -f ds-workspace-gpu

# Check container status
docker ps -a

# Monitor resource usage
docker stats ds-workspace-cpu
docker stats ds-workspace-gpu
```

### Shell Access
```bash
# CPU container
docker exec -it ds-workspace-cpu bash

# GPU container
docker exec -it ds-workspace-gpu bash
```

## Security Features

- Non-root user execution (ds-user-ds)
- Password-protected JupyterLab
- Read-only mounting of sensitive files
- Regular security updates
- Limited port exposure
- Container resource limits
- Host-mounted storage for persistence

## Performance Optimization

### Resource Management
- Adjust container memory in `.env`
- Configure GPU memory fraction
- Use appropriate swap space
- Monitor resource usage

### Storage Management
- Regular cleanup of unused images
- Monitor MLflow artifact storage
- Manage container logs
- Use volume mounts efficiently

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

### Health Checks
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
docker inspect --format='{{.State.Health.Status}}' ds-workspace-gpu

# View recent health check logs
docker inspect --format='{{json .State.Health}}' ds-workspace-cpu | jq
docker inspect --format='{{json .State.Health}}' ds-workspace-gpu | jq
```

## Support

For issues, questions, or contributions:
- Email: bhumukulraj.ds@gmail.com
- GitHub Issues: [Create an issue](https://github.com/yourusername/ds-docker-project/issues)
- Documentation: See [DOCKER_COMMANDS.md](docs/DOCKER_COMMANDS.md) for detailed command reference 