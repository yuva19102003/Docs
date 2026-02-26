# Podman Containers

## Container Lifecycle Management

### Creating Containers

```bash
# Create without starting
podman create --name myapp nginx

# Create with options
podman create \
  --name myapp \
  -p 8080:80 \
  -v /data:/app/data \
  -e ENV=production \
  nginx

# Start created container
podman start myapp
```

### Running Containers

```bash
# Run detached
podman run -d --name web nginx

# Run interactive
podman run -it --name shell ubuntu bash

# Run with auto-remove
podman run --rm nginx

# Run with restart policy
podman run -d --restart=always nginx

# Run with resource limits
podman run -d \
  --cpus=2 \
  --memory=1g \
  --memory-swap=2g \
  nginx
```

### Container States

```
Created → Running → Paused → Stopped → Removed
```

```bash
# Check state
podman inspect --format='{{.State.Status}}' myapp

# Possible states:
# - created
# - running
# - paused
# - exited
# - dead
```

## Resource Management

### CPU Limits

```bash
# Limit to 2 CPUs
podman run -d --cpus=2 nginx

# CPU shares (relative weight)
podman run -d --cpu-shares=512 nginx

# Specific CPUs
podman run -d --cpuset-cpus=0,1 nginx
```

### Memory Limits

```bash
# Memory limit
podman run -d --memory=1g nginx

# Memory + swap
podman run -d --memory=1g --memory-swap=2g nginx

# Memory reservation
podman run -d --memory-reservation=500m nginx

# OOM kill disable
podman run -d --oom-kill-disable nginx
```

### Disk I/O

```bash
# Block IO weight
podman run -d --blkio-weight=500 nginx

# Read/write limits
podman run -d \
  --device-read-bps=/dev/sda:1mb \
  --device-write-bps=/dev/sda:1mb \
  nginx
```

## Networking

### Network Modes

```bash
# Bridge (default)
podman run -d --network=bridge nginx

# Host network
podman run -d --network=host nginx

# No network
podman run -d --network=none nginx

# Container network
podman run -d --network=container:other-container nginx

# Custom network
podman network create mynet
podman run -d --network=mynet nginx
```

### Port Mapping

```bash
# Map single port
podman run -d -p 8080:80 nginx

# Map to specific interface
podman run -d -p 127.0.0.1:8080:80 nginx

# Map multiple ports
podman run -d -p 8080:80 -p 8443:443 nginx

# Map range
podman run -d -p 8000-8010:8000-8010 nginx

# Random host port
podman run -d -p 80 nginx
```

### DNS Configuration

```bash
# Custom DNS
podman run -d --dns=8.8.8.8 nginx

# DNS search
podman run -d --dns-search=example.com nginx

# Add hosts
podman run -d --add-host=db:192.168.1.10 nginx
```

## Storage and Volumes

### Volume Mounts

```bash
# Named volume
podman volume create mydata
podman run -d -v mydata:/app/data nginx

# Bind mount
podman run -d -v /host/path:/container/path nginx

# Read-only mount
podman run -d -v /host/path:/container/path:ro nginx

# Mount with options
podman run -d -v /host/path:/container/path:Z nginx  # SELinux label
```

### tmpfs Mounts

```bash
# Mount tmpfs
podman run -d --tmpfs /tmp nginx

# With size limit
podman run -d --tmpfs /tmp:size=100m nginx
```

## Environment Variables

```bash
# Single variable
podman run -d -e DB_HOST=localhost nginx

# Multiple variables
podman run -d \
  -e DB_HOST=localhost \
  -e DB_PORT=5432 \
  -e DB_NAME=mydb \
  nginx

# From file
podman run -d --env-file=.env nginx
```

## Health Checks

### Define Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

```bash
# Run with health check
podman run -d \
  --health-cmd='curl -f http://localhost/ || exit 1' \
  --health-interval=30s \
  --health-timeout=3s \
  --health-retries=3 \
  nginx

# Check health status
podman inspect --format='{{.State.Health.Status}}' myapp
```

## Security

### User and Permissions

```bash
# Run as specific user
podman run -d --user 1000:1000 nginx

# Run as non-root
podman run -d --user nobody nginx
```

### Capabilities

```bash
# Add capability
podman run -d --cap-add=NET_ADMIN nginx

# Drop capability
podman run -d --cap-drop=ALL nginx

# Drop all and add specific
podman run -d --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx
```

### Security Options

```bash
# SELinux label
podman run -d --security-opt label=level:s0:c100,c200 nginx

# AppArmor profile
podman run -d --security-opt apparmor=docker-default nginx

# No new privileges
podman run -d --security-opt no-new-privileges nginx
```

### Read-Only Root

```bash
# Read-only filesystem
podman run -d --read-only nginx

# With tmpfs for writes
podman run -d --read-only --tmpfs /tmp nginx
```

## Logging

### Log Drivers

```bash
# journald (default)
podman run -d --log-driver=journald nginx

# JSON file
podman run -d --log-driver=json-file nginx

# k8s-file
podman run -d --log-driver=k8s-file nginx

# None
podman run -d --log-driver=none nginx
```

### Log Options

```bash
# Max size and files
podman run -d \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  nginx
```

## Container Inspection

### Detailed Information

```bash
# Full inspect
podman inspect myapp

# Specific field
podman inspect --format='{{.NetworkSettings.IPAddress}}' myapp

# Multiple fields
podman inspect --format='{{.State.Status}} {{.NetworkSettings.IPAddress}}' myapp
```

### Resource Usage

```bash
# Real-time stats
podman stats myapp

# One-time stats
podman stats --no-stream myapp

# All containers
podman stats --all
```

## Container Updates

### Update Running Container

```bash
# Update resources
podman update --cpus=4 myapp
podman update --memory=2g myapp

# Update restart policy
podman update --restart=always myapp
```

## Checkpoint and Restore

### CRIU Support

```bash
# Checkpoint container
podman container checkpoint myapp

# Restore container
podman container restore myapp

# Export checkpoint
podman container checkpoint --export=/tmp/checkpoint.tar myapp

# Import and restore
podman container restore --import=/tmp/checkpoint.tar
```

## Container Cleanup

```bash
# Stop all containers
podman stop $(podman ps -q)

# Remove all stopped
podman container prune

# Remove all containers
podman rm -f $(podman ps -aq)

# Remove with filter
podman container prune --filter "until=24h"
```

## Best Practices

1. **One Process Per Container**: Single responsibility
2. **Use Health Checks**: Monitor container health
3. **Set Resource Limits**: Prevent resource exhaustion
4. **Run as Non-Root**: Enhanced security
5. **Use Read-Only Root**: When possible
6. **Proper Logging**: Configure log rotation
7. **Clean Up**: Remove unused containers
8. **Label Containers**: Use labels for organization
9. **Restart Policies**: Configure for production
10. **Monitor Resources**: Track CPU, memory usage

## Next Steps

- [Pods](5-Pods.md) - Multi-container applications
- [Networking](6-Networking.md) - Advanced networking
- [Volumes](7-Volumes.md) - Data persistence
