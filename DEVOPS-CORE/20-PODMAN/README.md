# Podman - Complete Guide

## Overview

Podman (Pod Manager) is a daemonless container engine for developing, managing, and running OCI containers on Linux systems. It's a drop-in replacement for Docker with enhanced security features.

## What is Podman?

Podman is an open-source container management tool that:
- Runs containers without a daemon
- Provides rootless container execution
- Is compatible with Docker CLI commands
- Supports pods (groups of containers)
- Integrates with systemd for service management
- Works with Kubernetes YAML files

## Podman vs Docker

| Feature | Docker | Podman |
|---------|--------|--------|
| Architecture | Client-Server (daemon) | Daemonless |
| Root Privileges | Requires root daemon | Rootless mode available |
| Security | Single point of failure | More secure, isolated |
| Pods | No native support | Native pod support |
| systemd Integration | Limited | Full integration |
| Docker Compatibility | N/A | Drop-in replacement |
| Kubernetes YAML | No | Yes (podman play kube) |
| Image Building | docker build | podman build / buildah |
| Swarm | Yes | No (use Kubernetes) |

## Key Features

### Daemonless Architecture
- No background daemon required
- Each container runs as a child process
- Better security and resource management

### Rootless Containers
- Run containers without root privileges
- Enhanced security isolation
- User namespace mapping

### Pod Support
- Group multiple containers together
- Share network namespace
- Similar to Kubernetes pods

### Docker Compatibility
- Compatible with Docker CLI
- Works with Dockerfiles
- Can pull from Docker Hub
- `alias docker=podman` works seamlessly

### systemd Integration
- Generate systemd unit files
- Manage containers as services
- Auto-start on boot

## Installation

### RHEL/CentOS/Fedora
```bash
sudo dnf install -y podman
```

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y podman
```

### macOS
```bash
brew install podman

# Initialize Podman machine
podman machine init
podman machine start
```

### Windows
```powershell
# Using WSL2
wsl --install
# Then install Podman in WSL2

# Or use Podman Desktop
# Download from: https://podman-desktop.io/
```

## Getting Started

### Verify Installation
```bash
podman --version
podman info
```

### Basic Commands
```bash
# Pull an image
podman pull nginx

# Run a container
podman run -d --name web -p 8080:80 nginx

# List running containers
podman ps

# List all containers
podman ps -a

# Stop container
podman stop web

# Remove container
podman rm web

# List images
podman images

# Remove image
podman rmi nginx
```

## Learning Path

1. **Fundamentals** - Installation, basic commands, images
2. **Container Management** - Running, managing, networking
3. **Images & Builds** - Creating custom images, Dockerfiles
4. **Pods** - Multi-container applications
5. **Volumes & Storage** - Data persistence
6. **Networking** - Container networking, port mapping
7. **Security** - Rootless mode, SELinux
8. **Advanced Topics** - systemd integration, Kubernetes YAML
9. **Compose** - podman-compose for multi-container apps
10. **Production** - Best practices, monitoring, troubleshooting

## Use Cases

### Development
- Local development environment
- Testing applications
- CI/CD pipelines

### Production
- Microservices deployment
- Serverless workloads
- Edge computing

### Security-Focused
- Rootless containers
- Multi-tenant environments
- Compliance requirements

## Documentation Structure

This guide covers:
1. **Overview** - Introduction and concepts
2. **Installation** - Setup on various platforms
3. **Basic Commands** - Essential Podman commands
4. **Images** - Working with container images
5. **Containers** - Container lifecycle management
6. **Pods** - Multi-container applications
7. **Networking** - Container networking
8. **Volumes** - Data persistence
9. **Compose** - Multi-container orchestration
10. **systemd Integration** - Service management
11. **Security** - Rootless and security features
12. **Kubernetes Integration** - Working with K8s YAML
13. **Best Practices** - Production guidelines
14. **Troubleshooting** - Common issues and solutions

## Quick Start Example

```bash
# Pull an image
podman pull docker.io/library/nginx:latest

# Run container
podman run -d \
  --name mynginx \
  -p 8080:80 \
  nginx

# Check if running
podman ps

# View logs
podman logs mynginx

# Access the application
curl http://localhost:8080

# Stop and remove
podman stop mynginx
podman rm mynginx
```

## Resources

### Official Documentation
- [Podman Documentation](https://docs.podman.io/)
- [Podman GitHub](https://github.com/containers/podman)
- [Podman Desktop](https://podman-desktop.io/)

### Community
- [Podman Blog](https://podman.io/blogs/)
- [Red Hat Developer](https://developers.redhat.com/topics/containers)
- [Stack Overflow - Podman](https://stackoverflow.com/questions/tagged/podman)

### Training
- Red Hat Container Tools
- Linux Foundation Container Training
- Podman Tutorials on YouTube

## Next Steps

Start with the [Overview](0-Overview.md) to understand Podman architecture, then proceed through:
1. [Installation](1-Installation.md)
2. [Basic Commands](2-Basic-Commands.md)
3. [Images](3-Images.md)
4. [Containers](4-Containers.md)
5. [Pods](5-Pods.md)
6. [Networking](6-Networking.md)
7. [Volumes](7-Volumes.md)
8. [Compose](8-Compose.md)
9. [systemd Integration](9-Systemd-Integration.md)
10. [Security](10-Security.md)
11. [Kubernetes Integration](11-Kubernetes-Integration.md)
12. [Best Practices](12-Best-Practices.md)
13. [Troubleshooting](13-Troubleshooting.md)
