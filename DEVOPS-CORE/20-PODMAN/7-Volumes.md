# Podman Volumes

## Volume Types

### Named Volumes
Managed by Podman, stored in Podman's storage directory.

```bash
# Create volume
podman volume create mydata

# Use volume
podman run -d -v mydata:/app/data nginx

# List volumes
podman volume ls

# Inspect volume
podman volume inspect mydata

# Remove volume
podman volume rm mydata
```

### Bind Mounts
Mount host directory into container.

```bash
# Bind mount
podman run -d -v /host/path:/container/path nginx

# Read-only bind mount
podman run -d -v /host/path:/container/path:ro nginx

# With SELinux label
podman run -d -v /host/path:/container/path:Z nginx
```

### tmpfs Mounts
Temporary filesystem in memory.

```bash
# Mount tmpfs
podman run -d --tmpfs /tmp nginx

# With size limit
podman run -d --tmpfs /tmp:size=100m nginx

# With mode
podman run -d --tmpfs /tmp:rw,size=100m,mode=1777 nginx
```

## Volume Management

### Create Volumes
```bash
# Basic volume
podman volume create myvolume

# With driver options
podman volume create --opt type=tmpfs myvolume

# With labels
podman volume create --label env=prod myvolume
```

### List and Inspect
```bash
# List all volumes
podman volume ls

# Filter volumes
podman volume ls --filter name=my

# Inspect volume
podman volume inspect myvolume

# Get mount point
podman volume inspect --format='{{.Mountpoint}}' myvolume
```

### Remove Volumes
```bash
# Remove volume
podman volume rm myvolume

# Force remove
podman volume rm -f myvolume

# Remove all unused volumes
podman volume prune

# Remove with filter
podman volume prune --filter label=env=dev
```

## Using Volumes

### Data Persistence
```bash
# Create volume
podman volume create db-data

# Run database with volume
podman run -d \
  --name postgres \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# Data persists after container removal
podman rm -f postgres
podman run -d --name postgres -v db-data:/var/lib/postgresql/data postgres:13
```

### Sharing Data Between Containers
```bash
# Create shared volume
podman volume create shared-data

# Writer container
podman run -d \
  --name writer \
  -v shared-data:/data \
  alpine sh -c "while true; do date > /data/timestamp; sleep 5; done"

# Reader container
podman run -d \
  --name reader \
  -v shared-data:/data:ro \
  alpine sh -c "while true; do cat /data/timestamp; sleep 5; done"
```

### Backup and Restore

#### Backup Volume
```bash
# Backup to tar
podman run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/myvolume-backup.tar.gz -C /data .

# Or using volume mount point
sudo tar czf myvolume-backup.tar.gz -C /var/lib/containers/storage/volumes/myvolume/_data .
```

#### Restore Volume
```bash
# Create new volume
podman volume create myvolume-restored

# Restore from tar
podman run --rm \
  -v myvolume-restored:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/myvolume-backup.tar.gz -C /data
```

## Bind Mounts

### Basic Bind Mount
```bash
# Mount host directory
podman run -d -v /host/data:/app/data nginx

# Current directory
podman run -d -v $(pwd):/app nginx

# Absolute path required
podman run -d -v /home/user/data:/data nginx
```

### Mount Options
```bash
# Read-only
podman run -d -v /host/data:/data:ro nginx

# Read-write (default)
podman run -d -v /host/data:/data:rw nginx

# SELinux private label
podman run -d -v /host/data:/data:z nginx

# SELinux shared label
podman run -d -v /host/data:/data:Z nginx

# No copy (don't copy data from image)
podman run -d -v /host/data:/data:nocopy nginx
```

### Development Workflow
```bash
# Mount source code
podman run -d \
  --name dev \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/package.json:/app/package.json \
  -p 3000:3000 \
  node:18 \
  npm run dev

# Changes on host reflect immediately in container
```

## Volume Drivers

### Local Driver (Default)
```bash
# Create with local driver
podman volume create --driver local myvolume
```

### Custom Options
```bash
# tmpfs volume
podman volume create \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=100m \
  tmpfs-volume

# NFS volume
podman volume create \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/dir \
  nfs-volume
```

## Volume Permissions

### User Mapping
```bash
# Run as specific user
podman run -d \
  --user 1000:1000 \
  -v myvolume:/data \
  nginx

# Fix permissions
podman run --rm \
  -v myvolume:/data \
  alpine chown -R 1000:1000 /data
```

### SELinux Context
```bash
# Private label (z)
podman run -d -v /host/data:/data:z nginx

# Shared label (Z)
podman run -d -v /host/data:/data:Z nginx

# Disable SELinux for mount
podman run -d -v /host/data:/data:U nginx
```

## Volume Inspection

### Get Volume Information
```bash
# Full details
podman volume inspect myvolume

# Mount point
podman volume inspect --format='{{.Mountpoint}}' myvolume

# Driver
podman volume inspect --format='{{.Driver}}' myvolume

# Labels
podman volume inspect --format='{{.Labels}}' myvolume

# Created time
podman volume inspect --format='{{.CreatedAt}}' myvolume
```

### List Volume Usage
```bash
# Volumes in use
podman ps -a --format='{{.Names}} {{.Mounts}}'

# Find containers using volume
podman ps -a --filter volume=myvolume
```

## Volume Best Practices

1. **Use Named Volumes**: For persistent data
2. **Bind Mounts for Development**: Live code updates
3. **Read-Only When Possible**: Prevent accidental writes
4. **Regular Backups**: Backup important volumes
5. **Clean Up**: Remove unused volumes
6. **Proper Permissions**: Set correct ownership
7. **SELinux Labels**: Use appropriate labels
8. **Document Volumes**: Label volumes clearly
9. **Volume Drivers**: Use appropriate drivers
10. **Monitor Size**: Track volume disk usage

## Troubleshooting

### Permission Issues
```bash
# Check volume permissions
podman run --rm -v myvolume:/data alpine ls -la /data

# Fix permissions
podman run --rm -v myvolume:/data alpine chown -R 1000:1000 /data
```

### SELinux Issues
```bash
# Check SELinux context
ls -Z /host/path

# Relabel for container
chcon -Rt svirt_sandbox_file_t /host/path

# Or use :Z mount option
podman run -d -v /host/path:/data:Z nginx
```

### Volume Not Found
```bash
# List all volumes
podman volume ls

# Recreate volume
podman volume create myvolume

# Check volume path
podman volume inspect --format='{{.Mountpoint}}' myvolume
```

## Next Steps

- [Compose](8-Compose.md) - Multi-container orchestration
- [systemd Integration](9-Systemd-Integration.md) - Service management
- [Security](10-Security.md) - Security best practices
