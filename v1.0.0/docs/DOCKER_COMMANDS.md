# Docker Commands Reference

This document provides a comprehensive list of Docker commands used in this project.

## Build Commands

### Basic Build
```bash
# Build CPU version
docker compose -f docker/docker-compose.yml --env-file .env build jupyter-cpu

# Build GPU version
docker compose -f docker/docker-compose.yml --env-file .env build jupyter-gpu
```

### Optimized Build (Recommended)
```bash
# Build with BuildKit and detailed logging
DOCKER_BUILDKIT=1 \
BUILDKIT_PROGRESS=plain \
BUILDKIT_STEP_LOG_MAX_SIZE=10485760 \
BUILDKIT_STEP_LOG_MAX_SPEED=10485760 \
COMPOSE_DOCKER_CLI_BUILD=1 \
docker compose -f docker/docker-compose.yml \
              --env-file .env \
              --verbose \
              build \
              --progress=plain \
              --pull \
              jupyter-cpu  # or jupyter-gpu

# Build with compose bake (Alternative)
COMPOSE_BAKE=true \
docker compose -f docker/docker-compose.yml \
              --env-file .env \
              build
```

## Container Management

### Start Containers
```bash
# Start CPU container
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-cpu

# Start GPU container
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu

# Start with resource limits
CONTAINER_MEMORY_LIMIT=12G \
CONTAINER_MEMORY_RESERVATION=4G \
docker compose -f docker/docker-compose.yml --env-file .env up -d jupyter-gpu
```

### Stop Containers
```bash
# Stop CPU container
docker compose -f docker/docker-compose.yml stop jupyter-cpu

# Stop GPU container
docker compose -f docker/docker-compose.yml stop jupyter-gpu

# Stop all containers
docker compose -f docker/docker-compose.yml stop

# Stop and remove containers
docker compose -f docker/docker-compose.yml down
```

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
```

### Container Shell Access
```bash
# Access CPU container shell
docker exec -it ds-workspace-cpu bash

# Access GPU container shell
docker exec -it ds-workspace-gpu bash

# Run specific command in container
docker exec ds-workspace-gpu nvidia-smi
docker exec ds-workspace-gpu python -c "import torch; print('GPU available:', torch.cuda.is_available())"
```

## Cleanup Commands

### System Cleanup
```bash
# Remove all unused resources
docker system prune -a --volumes

# Remove specific resources
docker container prune  # Remove stopped containers
docker image prune -a   # Remove all unused images
docker volume prune     # Remove unused volumes
docker network prune    # Remove unused networks

# Show Docker disk usage
docker system df -v     # Detailed view
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
```

### Specific Resource Removal
```bash
# Remove images
docker rmi ds-workspace-cpu:1.0.0
docker rmi ds-workspace-gpu:1.0.0
docker rmi $(docker images -f "dangling=true" -q)

# Remove containers
docker rm ds-workspace-cpu
docker rm ds-workspace-gpu
docker rm $(docker ps -a -f status=exited -q)

# Remove volumes
docker volume rm jupyter_logs_cpu
docker volume rm jupyter_logs_gpu
docker volume rm mlflow_data
```

## Monitoring Commands

### Resource Usage
```bash
# Show running containers
docker ps
docker ps -a  # Show all containers

# Show container resource usage
docker stats
docker stats ds-workspace-cpu
docker stats ds-workspace-gpu

# Show detailed container info
docker inspect ds-workspace-cpu
docker inspect ds-workspace-gpu
```

### Health Checks
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' ds-workspace-cpu
docker inspect --format='{{.State.Health.Status}}' ds-workspace-gpu

# Show container logs since last health check
docker logs ds-workspace-gpu --since $(docker inspect --format='{{.State.Health.LastCheck}}' ds-workspace-gpu)
```

### GPU Specific Commands
```bash
# Check GPU status in container
docker exec ds-workspace-gpu nvidia-smi

# Monitor GPU usage
docker exec ds-workspace-gpu nvidia-smi -l 1

# Check CUDA version
docker exec ds-workspace-gpu nvcc --version

# Verify PyTorch GPU support
docker exec ds-workspace-gpu python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Verify TensorFlow GPU support
docker exec ds-workspace-gpu python -c "import tensorflow as tf; print('GPU devices:', tf.config.list_physical_devices('GPU'))"
```

## Development Workflow

### Building for Development
```bash
# Build with development options
DOCKER_BUILDKIT=1 \
BUILDKIT_PROGRESS=plain \
COMPOSE_DOCKER_CLI_BUILD=1 \
docker compose -f docker/docker-compose.yml \
              --env-file .env \
              build \
              --no-cache \
              --build-arg BUILDKIT_INLINE_CACHE=0 \
              jupyter-gpu
```

### Debugging Containers
```bash
# Start container with debug options
docker compose -f docker/docker-compose.yml --env-file .env run --rm \
              -e PYTHONBREAKPOINT=ipdb.set_trace \
              jupyter-gpu python your_script.py

# Check container environment variables
docker exec ds-workspace-gpu env

# Check running processes
docker exec ds-workspace-gpu ps aux

# Check network connections
docker exec ds-workspace-gpu netstat -tulpn
```

## Notes

- Add `-f` or `--force` to skip confirmation prompts in prune commands
- Use `--volumes` with `docker system prune` to remove volumes
- Always verify before running destructive commands
- Check logs if containers fail to start
- Use `docker compose logs` for service logs in compose

## Common Issues

1. Permission Issues:
```bash
# Fix ownership of host directories
sudo chown -R $USER:$USER ~/Desktop/dsi-host-workspace
```

2. Port Conflicts:
```bash
# Check ports in use
sudo lsof -i :8888
sudo lsof -i :8889
sudo lsof -i :5000
```

3. Resource Limits:
```bash
# Check system resources
docker info
docker system info
```

4. GPU Issues:
```bash
# Verify NVIDIA runtime
docker info | grep -i runtime
# Check NVIDIA container toolkit
nvidia-container-cli info
``` 