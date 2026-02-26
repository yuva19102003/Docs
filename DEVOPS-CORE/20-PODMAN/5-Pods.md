# Podman Pods

## What are Pods?

Pods are groups of one or more containers that:
- Share the same network namespace
- Share the same IPC namespace
- Can share volumes
- Are managed as a single unit
- Similar to Kubernetes pods

## Creating Pods

### Basic Pod Creation

```bash
# Create empty pod
podman pod create --name mypod

# Create with port mapping
podman pod create --name mypod -p 8080:80

# Create with hostname
podman pod create --name mypod --hostname myapp

# Create with network
podman pod create --name mypod --network mynet
```

### Add Containers to Pod

```bash
# Add container to pod
podman run -d --pod mypod --name web nginx
podman run -d --pod mypod --name app python:3.9

# Containers share network
# web can access app via localhost
```

## Managing Pods

### List Pods

```bash
# List all pods
podman pod ls

# List with containers
podman pod ps --ctr-names

# List with IDs
podman pod ps --ctr-ids
```

### Pod Control

```bash
# Start pod
podman pod start mypod

# Stop pod
podman pod stop mypod

# Restart pod
podman pod restart mypod

# Pause pod
podman pod pause mypod

# Unpause pod
podman pod unpause mypod

# Kill pod
podman pod kill mypod
```

### Remove Pods

```bash
# Remove stopped pod
podman pod rm mypod

# Force remove running pod
podman pod rm -f mypod

# Remove all pods
podman pod rm -a

# Prune unused pods
podman pod prune
```

## Pod Inspection

```bash
# Inspect pod
podman pod inspect mypod

# Get pod status
podman pod inspect --format='{{.State}}' mypod

# List containers in pod
podman ps --filter pod=mypod

# Pod stats
podman pod stats mypod

# Pod top
podman pod top mypod
```

## Multi-Container Example

### Web Application with Database

```bash
# Create pod
podman pod create --name webapp -p 8080:80

# Add database
podman run -d \
  --pod webapp \
  --name db \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# Add application
podman run -d \
  --pod webapp \
  --name app \
  -e DB_HOST=localhost \
  -e DB_PORT=5432 \
  myapp:latest

# Add nginx
podman run -d \
  --pod webapp \
  --name web \
  nginx:alpine
```

### Microservices Pod

```bash
# Create pod
podman pod create --name microservices -p 8080:80

# Frontend
podman run -d --pod microservices --name frontend react-app

# Backend API
podman run -d --pod microservices --name api node-api

# Redis cache
podman run -d --pod microservices --name cache redis

# All services communicate via localhost
```

## Pod Networking

### Shared Network Namespace

```bash
# Create pod
podman pod create --name netpod -p 8080:80

# Container 1 listens on port 80
podman run -d --pod netpod nginx

# Container 2 can access via localhost:80
podman run -d --pod netpod --name client alpine sleep 3600
podman exec client wget -O- localhost:80
```

### Custom Network

```bash
# Create network
podman network create mynet

# Create pod on network
podman pod create --name mypod --network mynet

# Add containers
podman run -d --pod mypod nginx
```

## Shared Volumes

```bash
# Create pod with volume
podman pod create --name datapod

# Create volume
podman volume create shared-data

# Container 1 writes data
podman run -d \
  --pod datapod \
  --name writer \
  -v shared-data:/data \
  alpine sh -c "while true; do date > /data/timestamp; sleep 5; done"

# Container 2 reads data
podman run -d \
  --pod datapod \
  --name reader \
  -v shared-data:/data \
  alpine sh -c "while true; do cat /data/timestamp; sleep 5; done"
```

## Kubernetes YAML

### Generate Kubernetes YAML

```bash
# Generate YAML from pod
podman generate kube mypod > mypod.yaml

# Generate with service
podman generate kube --service mypod > mypod.yaml
```

### Example Generated YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: web
    image: nginx:latest
    ports:
    - containerPort: 80
      hostPort: 8080
  - name: app
    image: myapp:latest
    env:
    - name: DB_HOST
      value: localhost
```

### Play Kubernetes YAML

```bash
# Create pod from YAML
podman play kube mypod.yaml

# Remove pod from YAML
podman play kube --down mypod.yaml

# Replace existing
podman play kube --replace mypod.yaml
```

## Pod Templates

### WordPress Pod

```bash
# Create pod
podman pod create --name wordpress -p 8080:80

# MySQL
podman run -d \
  --pod wordpress \
  --name db \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -v wp-db:/var/lib/mysql \
  mysql:8

# WordPress
podman run -d \
  --pod wordpress \
  --name wp \
  -e WORDPRESS_DB_HOST=localhost \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  -v wp-content:/var/www/html \
  wordpress:latest
```

### Monitoring Stack

```bash
# Create pod
podman pod create --name monitoring -p 9090:9090 -p 3000:3000

# Prometheus
podman run -d \
  --pod monitoring \
  --name prometheus \
  -v prometheus-data:/prometheus \
  prom/prometheus

# Grafana
podman run -d \
  --pod monitoring \
  --name grafana \
  -v grafana-data:/var/lib/grafana \
  grafana/grafana
```

## Pod Logs

```bash
# View all pod logs
podman pod logs mypod

# Follow logs
podman pod logs -f mypod

# Specific container in pod
podman logs mypod-web

# All containers with timestamps
podman pod logs -t mypod
```

## Pod Best Practices

1. **Group Related Containers**: Keep tightly coupled services together
2. **Share Network**: Leverage localhost communication
3. **Use Shared Volumes**: For data exchange between containers
4. **Single Responsibility**: One main service per pod
5. **Health Checks**: Monitor all containers
6. **Resource Limits**: Set limits for entire pod
7. **Proper Naming**: Use descriptive pod and container names
8. **Clean Up**: Remove unused pods regularly
9. **Use Labels**: Organize pods with labels
10. **Document**: Use Kubernetes YAML for documentation

## Troubleshooting Pods

### Debug Pod Issues

```bash
# Check pod status
podman pod ps

# Inspect pod
podman pod inspect mypod

# Check container logs
podman logs mypod-container

# Exec into container
podman exec -it mypod-container sh

# Check network
podman exec mypod-container netstat -tulpn
```

### Common Issues

```bash
# Port already in use
podman pod rm -f mypod
podman pod create --name mypod -p 8081:80

# Container won't start
podman logs mypod-container
podman inspect mypod-container

# Network issues
podman pod inspect --format='{{.InfraConfig.NetworkOptions}}' mypod
```

## Next Steps

- [Networking](6-Networking.md) - Advanced networking
- [Volumes](7-Volumes.md) - Data persistence
- [Compose](8-Compose.md) - Multi-container orchestration
