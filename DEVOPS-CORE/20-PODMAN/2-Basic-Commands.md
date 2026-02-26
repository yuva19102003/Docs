# Podman Basic Commands

## Container Lifecycle

### Run Containers

#### Basic Run
```bash
# Run container in foreground
podman run nginx

# Run in detached mode
podman run -d nginx

# Run with name
podman run -d --name mynginx nginx

# Run with port mapping
podman run -d -p 8080:80 nginx

# Run with environment variables
podman run -d -e MYSQL_ROOT_PASSWORD=secret mysql

# Run with volume
podman run -d -v /host/path:/container/path nginx

# Run interactively
podman run -it ubuntu bash

# Run and remove after exit
podman run --rm -it ubuntu bash
```

#### Advanced Run Options
```bash
# Set hostname
podman run -d --hostname myapp nginx

# Set resource limits
podman run -d --cpus=2 --memory=1g nginx

# Set restart policy
podman run -d --restart=always nginx

# Run as specific user
podman run -d --user 1000:1000 nginx

# Add capabilities
podman run -d --cap-add=NET_ADMIN nginx

# Set working directory
podman run -d --workdir=/app nginx

# Add labels
podman run -d --label env=prod --label app=web nginx
```

### List Containers

```bash
# List running containers
podman ps

# List all containers
podman ps -a

# List with specific format
podman ps --format "{{.ID}} {{.Names}} {{.Status}}"

# List container IDs only
podman ps -q

# List with size
podman ps -s

# Filter containers
podman ps --filter "status=running"
podman ps --filter "name=nginx"
podman ps --filter "label=env=prod"
```

### Container Control

```bash
# Start container
podman start mynginx

# Stop container
podman stop mynginx

# Stop with timeout
podman stop -t 30 mynginx

# Restart container
podman restart mynginx

# Pause container
podman pause mynginx

# Unpause container
podman unpause mynginx

# Kill container
podman kill mynginx

# Kill with signal
podman kill -s SIGTERM mynginx
```

### Remove Containers

```bash
# Remove stopped container
podman rm mynginx

# Force remove running container
podman rm -f mynginx

# Remove all stopped containers
podman container prune

# Remove all containers
podman rm -f $(podman ps -aq)
```

## Image Management

### Pull Images

```bash
# Pull from Docker Hub
podman pull nginx

# Pull specific tag
podman pull nginx:1.21

# Pull from specific registry
podman pull quay.io/nginx/nginx

# Pull with digest
podman pull nginx@sha256:abc123...
```

### List Images

```bash
# List all images
podman images

# List with digests
podman images --digests

# List specific repository
podman images nginx

# Filter images
podman images --filter "dangling=true"
podman images --filter "before=nginx:latest"
```

### Remove Images

```bash
# Remove image
podman rmi nginx

# Force remove
podman rmi -f nginx

# Remove unused images
podman image prune

# Remove all images
podman rmi $(podman images -q)
```

### Image Information

```bash
# Inspect image
podman inspect nginx

# View image history
podman history nginx

# Show image layers
podman image tree nginx
```

## Container Inspection

### View Logs

```bash
# View logs
podman logs mynginx

# Follow logs
podman logs -f mynginx

# Show timestamps
podman logs -t mynginx

# Show last N lines
podman logs --tail 100 mynginx

# Show logs since time
podman logs --since 2024-01-01 mynginx
```

### Inspect Container

```bash
# Full inspection
podman inspect mynginx

# Get specific field
podman inspect --format='{{.State.Status}}' mynginx

# Get IP address
podman inspect --format='{{.NetworkSettings.IPAddress}}' mynginx

# Get all environment variables
podman inspect --format='{{.Config.Env}}' mynginx
```

### Container Stats

```bash
# Show resource usage
podman stats

# Show specific container
podman stats mynginx

# Show once (no stream)
podman stats --no-stream

# Custom format
podman stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Container Processes

```bash
# List processes in container
podman top mynginx

# Show with custom format
podman top mynginx user pid ppid
```

## Execute Commands

### Exec into Container

```bash
# Run command in container
podman exec mynginx ls /app

# Interactive shell
podman exec -it mynginx bash

# Run as specific user
podman exec -u root mynginx whoami

# Set environment variable
podman exec -e VAR=value mynginx env

# Set working directory
podman exec -w /app mynginx pwd
```

## Copy Files

```bash
# Copy from host to container
podman cp /host/file.txt mynginx:/container/path/

# Copy from container to host
podman cp mynginx:/container/file.txt /host/path/

# Copy directory
podman cp /host/dir mynginx:/container/path/
```

## Port Management

```bash
# List port mappings
podman port mynginx

# Show specific port
podman port mynginx 80
```

## Container Commit

```bash
# Create image from container
podman commit mynginx mynginx:v2

# With message and author
podman commit -m "Added config" -a "John Doe" mynginx mynginx:v2

# Pause container during commit
podman commit --pause mynginx mynginx:v2
```

## Export/Import

### Export Container

```bash
# Export container filesystem
podman export mynginx > mynginx.tar

# Export to file
podman export -o mynginx.tar mynginx
```

### Import Image

```bash
# Import from tarball
podman import mynginx.tar mynginx:imported

# Import from URL
podman import https://example.com/image.tar mynginx:imported
```

## Save/Load Images

### Save Images

```bash
# Save image to tar
podman save -o nginx.tar nginx

# Save multiple images
podman save -o images.tar nginx mysql redis

# Compress while saving
podman save nginx | gzip > nginx.tar.gz
```

### Load Images

```bash
# Load image from tar
podman load -i nginx.tar

# Load from stdin
cat nginx.tar | podman load

# Load compressed
gunzip -c nginx.tar.gz | podman load
```

## Search Images

```bash
# Search Docker Hub
podman search nginx

# Limit results
podman search --limit 5 nginx

# Filter by stars
podman search --filter stars=100 nginx

# Show official images only
podman search --filter is-official=true nginx
```

## System Commands

### System Info

```bash
# Show system information
podman info

# Show version
podman version

# Show disk usage
podman system df

# Detailed disk usage
podman system df -v
```

### System Cleanup

```bash
# Remove unused data
podman system prune

# Remove all unused images
podman system prune -a

# Remove volumes too
podman system prune --volumes

# Force without confirmation
podman system prune -f
```

### System Events

```bash
# Watch events
podman events

# Filter events
podman events --filter event=start
podman events --filter container=mynginx

# Show events since time
podman events --since 2024-01-01
```

## Networking Commands

```bash
# List networks
podman network ls

# Inspect network
podman network inspect bridge

# Create network
podman network create mynet

# Remove network
podman network rm mynet

# Connect container to network
podman network connect mynet mynginx

# Disconnect from network
podman network disconnect mynet mynginx
```

## Volume Commands

```bash
# List volumes
podman volume ls

# Create volume
podman volume create myvolume

# Inspect volume
podman volume inspect myvolume

# Remove volume
podman volume rm myvolume

# Remove unused volumes
podman volume prune
```

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

# Docker compatibility
alias docker=podman

# Common shortcuts
alias pps='podman ps'
alias ppsa='podman ps -a'
alias pimg='podman images'
alias plog='podman logs -f'
alias pexec='podman exec -it'
alias prm='podman rm -f'
alias prmi='podman rmi'
alias pstop='podman stop'
alias pstart='podman start'
```

## Quick Reference

### Container Lifecycle
```bash
podman run -d --name app nginx    # Create and start
podman stop app                    # Stop
podman start app                   # Start
podman restart app                 # Restart
podman rm app                      # Remove
```

### Debugging
```bash
podman logs -f app                 # View logs
podman exec -it app bash           # Shell access
podman inspect app                 # Detailed info
podman stats app                   # Resource usage
podman top app                     # Processes
```

### Cleanup
```bash
podman container prune             # Remove stopped containers
podman image prune                 # Remove unused images
podman volume prune                # Remove unused volumes
podman system prune -a             # Remove everything unused
```

## Next Steps

Continue to:
- [Images](3-Images.md) - Building and managing images
- [Containers](4-Containers.md) - Advanced container management
- [Pods](5-Pods.md) - Working with pods
