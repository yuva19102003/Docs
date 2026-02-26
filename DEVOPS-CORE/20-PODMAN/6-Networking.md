# Podman Networking

## Network Modes

### Bridge Network (Default)
```bash
# Create container with bridge network
podman run -d --network=bridge nginx

# Containers get private IP
# Isolated from host network
```

### Host Network
```bash
# Use host network stack
podman run -d --network=host nginx

# Container uses host IP
# No network isolation
# Better performance
```

### None Network
```bash
# No networking
podman run -d --network=none nginx

# Completely isolated
# No network interfaces
```

### Container Network
```bash
# Share another container's network
podman run -d --name web nginx
podman run -d --network=container:web alpine
```

## Custom Networks

### Create Network
```bash
# Create bridge network
podman network create mynet

# Create with subnet
podman network create --subnet=172.20.0.0/16 mynet

# Create with gateway
podman network create \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  mynet

# Create with DNS
podman network create \
  --dns=8.8.8.8 \
  mynet
```

### Manage Networks
```bash
# List networks
podman network ls

# Inspect network
podman network inspect mynet

# Remove network
podman network rm mynet

# Prune unused networks
podman network prune
```

### Connect Containers
```bash
# Create network
podman network create app-net

# Run containers on network
podman run -d --name db --network=app-net postgres
podman run -d --name api --network=app-net node-api

# Connect existing container
podman network connect app-net existing-container

# Disconnect
podman network disconnect app-net existing-container
```

## Port Mapping

### Basic Port Mapping
```bash
# Map single port
podman run -d -p 8080:80 nginx

# Map to specific interface
podman run -d -p 127.0.0.1:8080:80 nginx

# Map multiple ports
podman run -d -p 8080:80 -p 8443:443 nginx

# Map port range
podman run -d -p 8000-8010:8000-8010 nginx

# Random host port
podman run -d -p 80 nginx
```

### View Port Mappings
```bash
# List all port mappings
podman port mycontainer

# Specific port
podman port mycontainer 80
```

## DNS Configuration

### Custom DNS
```bash
# Set DNS servers
podman run -d --dns=8.8.8.8 --dns=8.8.4.4 nginx

# DNS search domains
podman run -d --dns-search=example.com nginx

# DNS options
podman run -d --dns-opt=ndots:2 nginx
```

### Hosts File
```bash
# Add host entries
podman run -d --add-host=db:192.168.1.10 nginx

# Multiple entries
podman run -d \
  --add-host=db:192.168.1.10 \
  --add-host=cache:192.168.1.11 \
  nginx
```

## Network Aliases

```bash
# Create network
podman network create mynet

# Run with alias
podman run -d \
  --name web \
  --network=mynet \
  --network-alias=webserver \
  nginx

# Access via alias
podman run --rm --network=mynet alpine ping webserver
```

## Container Communication

### Same Network
```bash
# Create network
podman network create app-net

# Backend
podman run -d --name backend --network=app-net api-server

# Frontend (can access backend by name)
podman run -d --name frontend --network=app-net \
  -e API_URL=http://backend:8080 \
  web-app
```

### Multiple Networks
```bash
# Create networks
podman network create frontend-net
podman network create backend-net

# Database (backend only)
podman run -d --name db --network=backend-net postgres

# API (both networks)
podman run -d --name api \
  --network=frontend-net \
  --network=backend-net \
  api-server

# Web (frontend only)
podman run -d --name web --network=frontend-net nginx
```

## Network Drivers

### Bridge Driver
```bash
# Default driver
podman network create --driver=bridge mynet
```

### Macvlan Driver
```bash
# Create macvlan network
podman network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Run container
podman run -d --network=macvlan-net nginx
```

## Network Troubleshooting

### Inspect Network
```bash
# Network details
podman network inspect mynet

# Connected containers
podman network inspect --format='{{range .Containers}}{{.Name}} {{end}}' mynet
```

### Test Connectivity
```bash
# Ping between containers
podman exec container1 ping container2

# Check DNS resolution
podman exec container1 nslookup container2

# View network interfaces
podman exec container1 ip addr

# Check routes
podman exec container1 ip route

# Test port connectivity
podman exec container1 nc -zv container2 8080
```

### Debug Network Issues
```bash
# Check container IP
podman inspect --format='{{.NetworkSettings.IPAddress}}' mycontainer

# Check network settings
podman inspect --format='{{.NetworkSettings}}' mycontainer

# View iptables rules
sudo iptables -L -n -v

# Check CNI plugins
ls /usr/libexec/cni/
```

## Best Practices

1. **Use Custom Networks**: Better than default bridge
2. **Network Segmentation**: Separate frontend/backend
3. **DNS Names**: Use container names for communication
4. **Limit Exposure**: Only expose necessary ports
5. **Use Network Aliases**: For service discovery
6. **Monitor Traffic**: Track network usage
7. **Secure Communication**: Use TLS between services
8. **Clean Up**: Remove unused networks

## Next Steps

- [Volumes](7-Volumes.md) - Data persistence
- [Compose](8-Compose.md) - Multi-container apps
- [Security](10-Security.md) - Network security
