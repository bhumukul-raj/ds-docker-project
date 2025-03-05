# CPU Environment Overview

## Image Details

- **Base Image**: ubuntu:22.04
- **Image Name**: bhumukulrajds/ds-workspace-cpu
- **Version**: 1.3
- **Python Version**: 3.9

## Resource Requirements

### Minimum Requirements
- 4 CPU cores
- 8GB system RAM
- 20GB disk space
- Docker Engine 20.10.0+
- BuildKit enabled
- Ubuntu 22.04 or compatible Linux distribution

### Recommended Configuration
- 8+ CPU cores
- 16GB system RAM (10GB allocated to container)
- 40GB SSD storage
- Docker Compose v2.0+
- Fast network connection

## Quick Start

### 1. Setup Environment
```bash
# Run setup scripts
bash scripts/setup_host.sh
bash scripts/setup_conf.sh

# Verify setup
ls -la ${HOME}/Desktop/dsi-host-workspace/config
```

### 2. Start Container
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config
docker compose --env-file .env up -d jupyter-cpu

# Access JupyterLab at: http://localhost:8888
```

### 3. Verify Setup
```bash
# Check container status
docker ps | grep ds-workspace-cpu

# View logs
docker logs ds-workspace-cpu

# Check health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
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
- Distributed 2023.3.2.1

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

## Container Configuration

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '9'
      memory: 10G
      pids: 1000
    reservations:
      cpus: '2'
      memory: 3G
```

### Security Configuration
- Read-only root filesystem
- No new privileges
- Dropped capabilities (minimal set)
- AppArmor profile enabled
- User namespace remapping
- Bridge network mode
- Read-only dataset mounts

### Network Configuration
- Bridge network mode
- Explicit DNS configuration
- Port 8888 exposed for JupyterLab
- Limited network access

## Performance Optimization

### Build Optimization
- BuildKit caching enabled
- Layer optimization
- Multi-stage builds
- Conditional package installation
- Resource-aware building

### Runtime Optimization
- Python garbage collection settings
- Process limits
- Memory limits
- I/O throttling
- Network isolation

### Resource Management
- Memory monitoring
- CPU usage tracking
- Disk space validation
- Process monitoring
- Resource metrics collection

## Logging and Monitoring

### Log Configuration
- Structured JSON logging
- Log rotation enabled
- Log compression
- Separate error logs
- Resource usage metrics

### Health Checks
```bash
# Container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu

# View health check logs
docker inspect --format='{{json .State.Health}}' ds-workspace-cpu | jq

# Resource monitoring
docker stats ds-workspace-cpu

# View logs
docker logs -f ds-workspace-cpu | jq
```

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
# Resource Configuration
CPU_LIMIT=9
CPU_RESERVATION=2
CONTAINER_MEMORY_LIMIT=10
CONTAINER_MEMORY_RESERVATION=3

# Python Configuration
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
PYTHONHASHSEED=random
PYTHONGC=2

# Container Configuration
TZ=UTC
USER_UID=1000
USER_GID=1000
```

## Troubleshooting

### Common Issues

1. **Container Fails to Start**
   - Check resource limits: `docker stats`
   - Verify port availability: `sudo lsof -i :8888`
   - Check log files: `docker logs ds-workspace-cpu`
   - Validate directory permissions: `ls -la ${HOME}/Desktop/dsi-host-workspace`

2. **Performance Issues**
   - Monitor resource usage: `docker stats`
   - Check process limits: `docker top ds-workspace-cpu`
   - Verify memory allocation: `free -h`
   - Review garbage collection settings: `docker exec ds-workspace-cpu python3 -c "import gc; print(gc.get_threshold())"`

3. **Network Issues**
   - Check DNS configuration: `docker exec ds-workspace-cpu cat /etc/resolv.conf`
   - Verify bridge network: `docker network inspect bridge`
   - Validate port mappings: `docker port ds-workspace-cpu`
   - Check network isolation: `docker inspect ds-workspace-cpu | grep -i network`

### Debug Commands
```bash
# Check container status
docker ps -a | grep ds-workspace-cpu

# View resource usage
docker stats ds-workspace-cpu

# Check logs
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/jupyter.log
tail -f ${HOME}/Desktop/dsi-host-workspace/logs/jupyter/entrypoint.error.log

# Inspect container
docker inspect ds-workspace-cpu

# Check system resources
bash scripts/validate_environment.sh
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

## Maintenance

### Regular Tasks
1. Log rotation and cleanup
2. Resource monitoring
3. Security updates
4. Performance optimization
5. Configuration validation

### Best Practices
1. Regular backups
2. Resource monitoring
3. Security audits
4. Performance tuning
5. Log analysis

## Support

For issues and support, please:
1. Check the troubleshooting section above
2. Review container logs
3. Monitor resource usage
4. Contact maintainer at bhumukulraj.ds@gmail.com 