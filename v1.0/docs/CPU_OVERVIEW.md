# Data Science Environment - CPU Version

## Overview

The CPU version of our Data Science environment is optimized for general data science workflows, machine learning tasks, and development work that doesn't require GPU acceleration. It provides a lightweight yet powerful environment for data analysis, model development, and experimentation.

## Image Details

- **Base Image**: ubuntu:22.04
- **Image Name**: bhumukulrajds/ds-workspace-cpu
- **Tags**: 
  - `1.0` - Stable release
  - `latest` - Most recent version

## Resource Requirements

### Minimum
- 4 CPU cores
- 8GB RAM
- 20GB disk space

### Recommended
- 8+ CPU cores
- 16GB RAM
- 40GB disk space
- SSD storage

## Quick Start

### Option 1: Using Docker Compose (if available)
```bash
# Pull the image
docker pull bhumukulrajds/ds-workspace-cpu:1.0

# Start the container
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu
```

### Option 2: Using Docker Run (standalone)
```bash
# Create required directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Run the container
docker run -d \
  --name ds-workspace-cpu \
  -p 8888:8888 \
  -p 5000:5000 \
  -e JUPYTER_PASSWORD="YourSecurePassword123" \
  -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
  -v ~/Desktop/dsi-host-workspace/projects:/workspace/projects \
  -v ~/Desktop/dsi-host-workspace/datasets:/workspace/datasets \
  -v ~/Desktop/dsi-host-workspace/mlflow:/workspace/mlflow \
  -v ~/Desktop/dsi-host-workspace/logs/jupyter:/var/log/jupyter \
  bhumukulrajds/ds-workspace-cpu:1.0
```

### Option 3: Using Startup Script
Create a file named `start-ds-environment.sh`:
```bash
#!/bin/bash

# Create directories
mkdir -p ~/Desktop/dsi-host-workspace/{projects,mlflow,logs/jupyter,datasets}

# Set environment variables
JUPYTER_PASSWORD="YourSecurePassword123"
HOST_DIR=~/Desktop/dsi-host-workspace

docker run -d \
    --name ds-workspace-cpu \
    -p 8888:8888 \
    -p 5000:5000 \
    -e JUPYTER_PASSWORD="${JUPYTER_PASSWORD}" \
    -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
    -v ${HOST_DIR}/projects:/workspace/projects \
    -v ${HOST_DIR}/datasets:/workspace/datasets \
    -v ${HOST_DIR}/mlflow:/workspace/mlflow \
    -v ${HOST_DIR}/logs/jupyter:/var/log/jupyter \
    bhumukulrajds/ds-workspace-cpu:1.0

echo "CPU version started at http://localhost:8888"
echo "MLflow available at http://localhost:5000"
```

Run the script:
```bash
chmod +x start-ds-environment.sh
./start-ds-environment.sh
```

## Access Points

- JupyterLab: http://localhost:8888
- MLflow UI: http://localhost:5000

## Key Features

### Development Environment
- Python 3.9
- JupyterLab 3.6.5
- MLflow 2.6.0
- Conda/Mamba package management

### Core Packages
- NumPy 1.24.3
- Pandas 1.5.3
- Scipy 1.11.2
- Scikit-learn 1.3.0

### Machine Learning
- XGBoost 1.7.6
- LightGBM 4.0.0
- MLflow 2.6.0
- Dask 2023.7.1

### Visualization
- Matplotlib 3.7.2
- Seaborn 0.12.2
- Plotly 5.16.1

### Development Tools
- Git
- VS Code Server
- Jupyter Extensions
- Shell access

## Resource Management

### Container Configuration
```yaml
services:
  jupyter-cpu:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

### Environment Variables
```bash
JUPYTER_PORT=8888
MLFLOW_PORT=5000
WORKSPACE_ROOT=/workspace
HOST_WORKSPACE_ROOT=~/Desktop/dsi-host-workspace
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

### Memory Management
- Set appropriate container memory limits
- Monitor memory usage with `docker stats`
- Use memory-efficient data processing with Dask

### CPU Optimization
- Configure CPU allocation
- Use multiprocessing when appropriate
- Enable parallel processing in Pandas/Scikit-learn

### Storage Optimization
- Use efficient data formats (parquet, feather)
- Implement data chunking for large datasets
- Monitor MLflow artifacts

## Common Operations

### Basic Container Management
```bash
# View logs
docker logs ds-workspace-cpu

# Access shell
docker exec -it ds-workspace-cpu bash

# Stop container
docker stop ds-workspace-cpu

# Start container
docker start ds-workspace-cpu

# Remove container
docker rm ds-workspace-cpu
```

### Resource Management
```bash
# Run with specific resource limits
docker run -d \
  --name ds-workspace-cpu \
  --memory=8g \
  --memory-reservation=4g \
  --cpus=4 \
  -p 8888:8888 \
  -p 5000:5000 \
  -e JUPYTER_PASSWORD="YourSecurePassword123" \
  -e MLFLOW_TRACKING_URI="sqlite:///workspace/mlflow/mlflow.db" \
  -v ~/Desktop/dsi-host-workspace/projects:/workspace/projects \
  -v ~/Desktop/dsi-host-workspace/datasets:/workspace/datasets \
  -v ~/Desktop/dsi-host-workspace/mlflow:/workspace/mlflow \
  -v ~/Desktop/dsi-host-workspace/logs/jupyter:/var/log/jupyter \
  bhumukulrajds/ds-workspace-cpu:1.0
```

### Resource Monitoring
```bash
# Monitor container resources
docker stats ds-workspace-cpu

# Check container processes
docker top ds-workspace-cpu

# View container details
docker inspect ds-workspace-cpu
```

## Troubleshooting

### Common Issues
1. Memory Issues
```bash
# Check memory usage
docker stats ds-workspace-cpu --no-stream

# Increase container memory
# Edit docker-compose.yml memory limits
```

2. Port Conflicts
```bash
# Check port usage
docker port ds-workspace-cpu

# List all running containers
docker ps
```

3. Storage Issues
```bash
# Check disk usage
docker system df

# Clean up unused data
docker system prune
```

## Security Features

- Isolated container environment
- Non-root user execution
- Volume mount restrictions
- Network port limitations
- Resource constraints

## Support

For issues and questions:
- Email: bhumukulraj.ds@gmail.com
- Documentation: [Main README](../README.md)
- Commands Reference: [DOCKER_COMMANDS.md](DOCKER_COMMANDS.md)
- Docker Documentation: [Docker Docs](https://docs.docker.com/) 