# Docker Commands Reference

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
# Build CPU image
docker compose --env-file .env build jupyter-cpu

# Build GPU image
docker compose --env-file .env build jupyter-gpu

# Build with no cache
docker compose --env-file .env build --no-cache jupyter-cpu
docker compose --env-file .env build --no-cache jupyter-gpu

# Build with BuildKit cache
docker compose --env-file .env build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  jupyter-cpu
```

## Container Management

### Start Containers
```bash
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

# Adjust CPU limits
docker update --cpus=4 --cpu-shares=1024 ds-workspace-cpu

# View process list
docker top ds-workspace-cpu
```

### GPU Container
```bash
# View GPU status
nvidia-smi

# Monitor GPU usage
watch -n 1 nvidia-smi

# View GPU metrics
docker exec ds-workspace-gpu nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.free,temperature.gpu --format=csv

# Check CUDA
docker exec ds-workspace-gpu nvidia-smi -L
```

### Memory Management
```bash
# View memory usage
docker stats ds-workspace-cpu ds-workspace-gpu

# Adjust memory limits
docker update --memory=10G --memory-reservation=3G ds-workspace-cpu
docker update --memory=12G --memory-reservation=4G ds-workspace-gpu
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
docker port ds-workspace-cpu
docker port ds-workspace-gpu

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

# Run command as root (if needed)
docker exec -u 0 ds-workspace-cpu id

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
docker builder prune
```

### Container Cleanup
```bash
# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune

# Full system cleanup
docker system prune -a
```

### Log Rotation
```bash
# View log size
du -h $(docker inspect --format='{{.LogPath}}' ds-workspace-cpu)

# Rotate container logs
docker container restart ds-workspace-cpu
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

### Resource Issues
```bash
# Check system resources
docker info

# View detailed stats
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Monitor GPU issues
nvidia-smi -l 1
```

### Network Debug
```bash
# Test container networking
docker exec ds-workspace-cpu ping -c 4 8.8.8.8

# View DNS config
docker exec ds-workspace-cpu cat /etc/resolv.conf

# Check network connectivity
docker exec ds-workspace-cpu curl -v https://www.google.com
```

## Environment Variables

### View Variables
```bash
# List all variables
docker exec ds-workspace-cpu env

# View specific variable
docker exec ds-workspace-cpu bash -c 'echo $NVIDIA_GPU_MEM_FRACTION'
```

### Update Variables
```bash
# Update single variable
docker exec -e NVIDIA_GPU_MEM_FRACTION=0.6 ds-workspace-gpu nvidia-smi

# Load from file
docker compose --env-file .env up -d
```

## Volume Management

### Volume Commands
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect jupyter_logs_cpu

# Clean unused volumes
docker volume prune
```

### Backup Commands
```bash
# Backup volume data
docker run --rm -v jupyter_logs_cpu:/source -v $(pwd):/backup ubuntu tar czf /backup/logs_backup.tar.gz -C /source .

# Restore volume data
docker run --rm -v jupyter_logs_cpu:/source -v $(pwd):/backup ubuntu bash -c "cd /source && tar xzf /backup/logs_backup.tar.gz"
```

## Container Management

### Container Logs
```bash
# View CPU container logs
docker logs ds-workspace-cpu

# View GPU container logs
docker logs ds-workspace-gpu

# Follow logs in real-time
docker logs -f ds-workspace-cpu

# Show last 100 lines
docker logs --tail 100 ds-workspace-cpu

# Show logs with timestamps
docker logs -t ds-workspace-cpu

# Save logs to file
docker logs ds-workspace-cpu > cpu_container.log 2>&1
```

### Container Shell Access
```bash
# Run specific command in container
docker exec ds-workspace-gpu nvidia-smi
docker exec ds-workspace-gpu python -c "import torch; print('GPU available:', torch.cuda.is_available())"

# Run command as root
docker exec -it -u root ds-workspace-cpu bash
```

## Cleanup Commands

### System Cleanup
```bash
# Remove specific resources
docker container prune  # Remove stopped containers
docker image prune -a   # Remove all unused images
docker volume prune     # Remove unused volumes
docker network prune    # Remove unused networks

# Show Docker disk usage
docker system df -v     # Detailed view

# Clean specific container logs
truncate -s 0 $(docker inspect --format='{{.LogPath}}' ds-workspace-cpu)
```

### Cache Management
```bash
# Clear BuildKit cache
docker builder prune

# Clear old cache (older than 24h)
docker builder prune --filter until=24h

# Clear specific types of cache
docker builder prune --filter type=exec.cachemount
docker builder prune --filter type=source.local

# Clear all build cache
docker builder prune --all
```

### Specific Resource Removal
```bash
# Remove images
docker rmi ds-workspace-cpu:1.2.1
docker rmi ds-workspace-gpu:1.2.1
docker rmi $(docker images -f "dangling=true" -q)

# Remove containers
docker rm ds-workspace-cpu
docker rm ds-workspace-gpu
docker rm $(docker ps -a -f status=exited -q)

# Remove volumes
docker volume rm jupyter_logs_cpu
docker volume rm jupyter_logs_gpu

# Remove all project-related resources
docker compose --env-file .env down --rmi all --volumes --remove-orphans
```

## Monitoring Commands

### Resource Usage
```bash
# Show container resource usage
docker stats

# Show detailed container info
docker inspect ds-workspace-cpu
docker inspect ds-workspace-gpu

# Monitor resource usage continuously
watch docker stats

# Export container metrics
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" > metrics.txt
```

### Health Checks
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
docker inspect --format='{{.State.Health.Status}}' ds-workspace-gpu

# Show container logs since last health check
docker logs ds-workspace-gpu --since $(docker inspect --format='{{.State.Health.LastCheck}}' ds-workspace-gpu)

# Show health check history
docker inspect --format='{{range .State.Health.Log}}{{.Start}}: {{.ExitCode}}{{println}}{{end}}' ds-workspace-gpu
```

### GPU Specific Commands
```bash
# Monitor GPU usage
docker exec ds-workspace-gpu nvidia-smi -l 1

# Check CUDA version
docker exec ds-workspace-gpu nvcc --version

# Verify PyTorch GPU support
docker exec ds-workspace-gpu python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Verify TensorFlow GPU support
docker exec ds-workspace-gpu python -c "import tensorflow as tf; print('GPU devices:', tf.config.list_physical_devices('GPU'))"

# Monitor GPU memory usage
docker exec ds-workspace-gpu nvidia-smi --query-gpu=memory.used,memory.total --format=csv
```

## Development Workflow

### Building for Development
```bash
# Build with development options
DOCKER_BUILDKIT=1 \
BUILDKIT_PROGRESS=plain \
COMPOSE_DOCKER_CLI_BUILD=1 \
docker compose --env-file .env \
              build \
              --no-cache \
              --build-arg BUILDKIT_INLINE_CACHE=0 \
              jupyter-gpu

# Build with debug output
BUILDKIT_PROGRESS=plain \
docker compose --env-file .env \
              build \
              --progress=plain \
              --no-cache \
              jupyter-gpu
```

### Debugging Containers
```bash
# Start container with debug options
docker compose --env-file .env run --rm \
              -e PYTHONBREAKPOINT=ipdb.set_trace \
              jupyter-gpu python your_script.py

# Check container environment variables
docker exec ds-workspace-gpu env

# Check running processes
docker exec ds-workspace-gpu ps aux

# Check network connections
docker exec ds-workspace-gpu netstat -tulpn

# Check container logs in real-time with timestamps
docker logs -f --timestamps ds-workspace-gpu

# Export container configuration
docker inspect ds-workspace-gpu > container_config.json
```

## Notes

- Add `-f` or `--force` to skip confirmation prompts in prune commands
- Use `--volumes` with `docker system prune` to remove volumes
- Always verify before running destructive commands
- Check logs if containers fail to start
- Use `docker compose logs` for service logs in compose
- Set appropriate resource limits to prevent container issues
- Monitor GPU memory usage for deep learning tasks
- Regular cleanup of unused resources to maintain performance

## Common Issues

1. Permission Issues:
```bash
# Fix ownership of host directories
sudo chown -R $USER:$USER ~/Desktop/dsi-host-workspace

# Fix container permissions
docker exec -it -u root ds-workspace-cpu chown -R ds-user-ds:users /workspace
```

2. Port Conflicts:
```bash
# Check ports in use
sudo lsof -i :8888
sudo lsof -i :8889
sudo lsof -i :5000

# Kill process using port
sudo kill $(sudo lsof -t -i:8888)
```

3. Resource Limits:
```bash
# Check system resources
docker info
docker system info

# Monitor resource usage
docker stats --no-stream
```

4. GPU Issues:
```bash
# Verify NVIDIA runtime
docker info | grep -i runtime

# Check NVIDIA container toolkit
nvidia-container-cli info

# Reset NVIDIA devices
sudo nvidia-smi --gpu-reset

# Check NVIDIA driver compatibility
nvidia-container-cli -k -d /dev/tty info
```

5. Network Issues:
```bash
# Check container networking
docker network ls
docker network inspect bridge

# Restart Docker network
sudo systemctl restart docker

# Clear DNS cache
sudo systemctl restart systemd-resolved
```

For more information and updates, visit the project repository or contact the maintainer: bhumukulraj.ds@gmail.com 