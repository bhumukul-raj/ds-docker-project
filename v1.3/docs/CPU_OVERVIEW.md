# CPU Environment Overview

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

## Container Configuration

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '4'
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

## Troubleshooting

### Common Issues

1. **Container Fails to Start**
   - Check resource limits
   - Verify port availability
   - Check log files
   - Validate directory permissions

2. **Performance Issues**
   - Monitor resource usage
   - Check process limits
   - Verify memory allocation
   - Review garbage collection settings

3. **Network Issues**
   - Check DNS configuration
   - Verify bridge network
   - Validate port mappings
   - Check network isolation

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

# Check network
docker network inspect bridge
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
# Resource Configuration
CPU_LIMIT=4
CPU_RESERVATION=2
CONTAINER_MEMORY_LIMIT=10G
CONTAINER_MEMORY_RESERVATION=3G

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
1. Check the troubleshooting guide
2. Review container logs
3. Monitor resource usage
4. Contact maintainer at bhumukulraj.ds@gmail.com 