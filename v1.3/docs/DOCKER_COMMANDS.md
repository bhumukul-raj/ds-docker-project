# Docker Commands Reference

## Setup Commands

### Initial Setup
```bash
# Run setup scripts
bash scripts/setup_host.sh
bash scripts/setup_conf.sh

# Verify setup
ls -la ${HOME}/Desktop/dsi-host-workspace/config
```

### Environment Configuration
```bash
# View Jupyter password
cat ${HOME}/Desktop/dsi-host-workspace/config/jupyter/jupyter_password.txt

# Check environment variables
cat ${HOME}/Desktop/dsi-host-workspace/config/.env
```

## Build Commands

### BuildKit Configuration
```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Configure BuildKit settings
export BUILDKIT_PROGRESS=plain
export BUILDKIT_STEP_LOG_MAX_SIZE=10485760
```

### Build Images
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config

# Build CPU image
docker compose --env-file .env build jupyter-cpu

# Build GPU image
docker compose --env-file .env build jupyter-gpu

# Build with no cache
docker compose --env-file .env build --no-cache jupyter-cpu
docker compose --env-file .env build --no-cache jupyter-gpu
```

## Container Management

### Start Containers
```bash
cd ${HOME}/Desktop/dsi-host-workspace/config

# Start CPU container
docker compose --env-file .env up -d jupyter-cpu

# Start GPU container
docker compose --env-file .env up -d jupyter-gpu

# Start both containers
docker compose --env-file .env up -d
```

### Stop Containers
```bash
# Stop CPU container
docker compose --env-file .env stop jupyter-cpu

# Stop GPU container
docker compose --env-file .env stop jupyter-gpu

# Stop all containers
docker compose --env-file .env down
```

### Container Status
```bash
# List running containers
docker ps | grep ds-workspace

# View container details
docker inspect ds-workspace-cpu
docker inspect ds-workspace-gpu

# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
docker inspect --format='{{.State.Health.Status}}' ds-workspace-gpu
```

## Resource Management

### CPU Container
```bash
# View CPU usage
docker stats ds-workspace-cpu

# View process list
docker top ds-workspace-cpu

# Configure in .env:
CPU_LIMIT=9
CPU_RESERVATION=2
```

### GPU Container
```bash
# View GPU status
nvidia-smi

# Monitor GPU usage
watch -n 1 nvidia-smi

# View GPU metrics
docker exec ds-workspace-gpu nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.free,temperature.gpu --format=csv

# Configure in .env:
NVIDIA_GPU_MEM_FRACTION=0.6
NVIDIA_MEM_MAX_PERCENT=75
```

### Memory Management
```bash
# View memory usage
docker stats ds-workspace-cpu ds-workspace-gpu

# Configure in .env:
CONTAINER_MEMORY_LIMIT=10
CONTAINER_MEMORY_RESERVATION=3
```

## Logging and Monitoring

### Container Logs
```bash
# View container logs
docker logs -f ds-workspace-cpu
docker logs -f ds-workspace-gpu

# View last N lines
docker logs --tail=100 ds-workspace-cpu
docker logs --tail=100 ds-workspace-gpu

# View logs with timestamps
docker logs -f --timestamps ds-workspace-cpu
```

### Health Checks
```bash
# View health check logs
docker inspect --format='{{json .State.Health}}' ds-workspace-cpu | jq
docker inspect --format='{{json .State.Health}}' ds-workspace-gpu | jq

# Monitor health status
watch -n 5 'docker inspect --format="{{.State.Health.Status}}" ds-workspace-cpu'
```

### Resource Monitoring
```bash
# Monitor all containers
docker stats

# Monitor specific container
docker stats ds-workspace-cpu

# View process stats
docker top ds-workspace-cpu
```

## Network Management

### Network Configuration
```bash
# View network settings
docker network inspect bridge

# List container networks
docker network ls

# View container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ds-workspace-cpu
```

### Port Management
```bash
# View port mappings
docker port ds-workspace-cpu  # 8888
docker port ds-workspace-gpu  # 8889

# Check port usage
sudo lsof -i :8888
sudo lsof -i :8889
```

## Security Commands

### Container Security
```bash
# View security options
docker inspect --format='{{.HostConfig.SecurityOpt}}' ds-workspace-cpu

# View capabilities
docker inspect --format='{{.HostConfig.CapAdd}}' ds-workspace-cpu
docker inspect --format='{{.HostConfig.CapDrop}}' ds-workspace-cpu

# Check read-only status
docker inspect --format='{{.HostConfig.ReadonlyRootfs}}' ds-workspace-cpu
```

### User Management
```bash
# View container user
docker exec ds-workspace-cpu id

# View user mapping
docker inspect --format='{{.HostConfig.UsernsMode}}' ds-workspace-cpu
```

## Maintenance Commands

### Image Maintenance
```bash
# Remove unused images
docker image prune -a

# Remove dangling images
docker image prune

# Clean build cache
docker builder prune --keep-storage 10GB
```

### Container Cleanup
```bash
# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune

# Full system cleanup
docker system prune -a --volumes
```

### Log Rotation
```bash
# View log size
du -h $(docker inspect --format='{{.LogPath}}' ds-workspace-cpu)

# Clean logs
bash scripts/cleanup.sh
```

## Troubleshooting Commands

### Debug Information
```bash
# View container events
docker events --filter container=ds-workspace-cpu

# Export container config
docker inspect ds-workspace-cpu > container_config.json

# View container processes
docker top ds-workspace-cpu -eo pid,ppid,cmd
```

### GPU Debugging
```bash
# Check NVIDIA driver
nvidia-smi

# Verify CUDA
docker exec ds-workspace-gpu nvidia-smi -L

# Test PyTorch GPU
docker exec ds-workspace-gpu python3 -c "import torch; print(torch.cuda.is_available())"

# Monitor GPU metrics
nvidia-smi dmon
```

### System Validation
```bash
# Check system resources
bash scripts/validate_environment.sh

# View resource limits
cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
```

For more information and updates, contact maintainer at bhumukulraj.ds@gmail.com 