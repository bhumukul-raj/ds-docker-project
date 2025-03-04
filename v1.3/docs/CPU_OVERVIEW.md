# Data Science Environment - CPU Version

## Overview

The CPU version of our Data Science environment is designed for general data science workflows, machine learning tasks, and development work that doesn't require GPU acceleration. It provides a lightweight yet powerful environment with optimized performance for CPU-based computations.

## Image Details

- **Base Image**: ubuntu:22.04
- **Image Name**: bhumukulrajds/ds-workspace-cpu
- **Version**: 1.2
- **Python Version**: 3.9
- **Build Optimization**: OpenBLAS

## Resource Requirements

### Minimum
- 4 CPU cores
- 8GB RAM
- 20GB disk space
- Docker Engine 20.10.0+
- Ubuntu 22.04 or compatible Linux distribution

### Recommended
- 8+ CPU cores
- 16GB RAM
- 40GB SSD storage
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
docker compose --env-file .env build jupyter-cpu
docker compose --env-file .env up -d jupyter-cpu

# Access services:
# JupyterLab: http://localhost:8888
```

### 3. Verify Setup
```bash
# Check container status
docker ps | grep ds-workspace-cpu

# View logs
docker logs ds-workspace-cpu

# Test Python environment
docker exec ds-workspace-cpu bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate ds-cpu && python3 -c 'import numpy; print(\"NumPy:\", numpy.__version__)'"
```

## Core Components

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
      cpus: '4'
      memory: 8G
    reservations:
      cpus: '2'
      memory: 4G
```

### Environment Variables
```bash
# Required
JUPYTER_PASSWORD=your_secure_password

# Optional
CONTAINER_MEMORY_LIMIT=8G
CONTAINER_MEMORY_RESERVATION=2G
```

## Performance Optimization

### CPU Optimization
- OpenBLAS for numerical computations
- Parallel processing with Dask
- Efficient memory management
- Optimized container resources

### Memory Management
- Set appropriate container limits
- Monitor memory usage
- Use memory-efficient data processing
- Enable Dask for large datasets

### Storage Optimization
- Use efficient data formats (parquet, feather)
- Implement data chunking
- Regular cleanup of unused data

## Troubleshooting

### Common Issues

1. **Container Fails to Start**
```bash
# Check logs
docker logs ds-workspace-cpu

# Verify port availability
sudo lsof -i :8888

# Check resource usage
docker stats ds-workspace-cpu
```

2. **Memory Issues**
```bash
# Monitor container memory
docker stats ds-workspace-cpu

# Adjust memory limits in .env
CONTAINER_MEMORY_LIMIT=12G
CONTAINER_MEMORY_RESERVATION=4G

# Clear system cache
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
```

3. **JupyterLab Access Issues**
```bash
# Check JupyterLab logs
docker exec ds-workspace-cpu bash -c "cat /workspace/logs/jupyter.log"

# Verify JupyterLab process
docker exec ds-workspace-cpu ps aux | grep jupyter

# Check port forwarding
docker port ds-workspace-cpu
```

### Recovery Steps

1. **Complete Reset**
```bash
# Stop container
docker compose --env-file .env down

# Remove container and volumes
docker compose --env-file .env down -v

# Rebuild from scratch
docker compose --env-file .env build --no-cache jupyter-cpu
docker compose --env-file .env up -d jupyter-cpu
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
docker compose --env-file .env up -d jupyter-cpu

# Stop container
docker compose --env-file .env stop jupyter-cpu

# Restart container
docker compose --env-file .env restart jupyter-cpu

# Access shell
docker exec -it ds-workspace-cpu bash
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
# Open http://localhost:8888 in browser
```

## Best Practices

### Development
- Use version control
- Implement proper logging
- Write unit tests
- Document code and notebooks

### Production
- Monitor resource usage
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
- Monitor system resources
- Review error messages
- Contact maintainer: bhumukulraj.ds@gmail.com 