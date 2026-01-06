# Containerization - Docker & Kubernetes

## Overview
Containerization packages applications with their dependencies in isolated, lightweight environments. This directory covers Docker for container management and Kubernetes for orchestration at scale.

---

## What is Containerization?

**Containerization** is a method of packaging applications along with their dependencies, libraries, and configuration files into isolated units called containers.

### Key Benefits
- ✅ **Consistency** - Same behavior across dev, test, and production
- ✅ **Portability** - Run anywhere (laptop, cloud, on-premise)
- ✅ **Efficiency** - Lightweight compared to virtual machines
- ✅ **Isolation** - Applications don't interfere with each other
- ✅ **Scalability** - Easy to scale up or down
- ✅ **Fast Deployment** - Start in seconds, not minutes

### Containers vs Virtual Machines

| Feature | Containers | Virtual Machines |
|---------|-----------|------------------|
| **Size** | MBs | GBs |
| **Startup** | Seconds | Minutes |
| **Resource Usage** | Low | High |
| **Isolation** | Process-level | OS-level |
| **Portability** | High | Medium |
| **Performance** | Near-native | Overhead |

---

## Learning Path

### Beginner Level - Docker Basics
1. **[Docker Fundamentals](Docker/0-Docker-Fundamentals.md)** - Start here
   - What is Docker and containerization
   - Docker architecture (client-server model)
   - Container lifecycle
   - Docker commands overview
   - Volumes and networking basics
   - Docker Compose introduction

2. **[Docker Concepts](Docker/README.md)**
   - Why Docker exists
   - Images vs containers
   - Docker architecture
   - Image layers
   - Build vs run time
   - Container isolation

3. **[Installation](Docker/1-Installation.md)**
   - Installing Docker on various platforms
   - Docker Desktop setup
   - Verifying installation
   - Post-installation configuration

### Intermediate Level - Docker Usage
4. **[Docker Commands](Docker/2-Docker-Commands.md)**
   - Essential Docker CLI commands
   - Container management
   - Image management
   - Network commands
   - Volume commands
   - Debugging and troubleshooting

5. **[Dockerfile](Docker/3-Dockerfile.md)**
   - Dockerfile syntax and instructions
   - Building custom images
   - Multi-stage builds
   - Best practices
   - Optimization techniques

6. **[Docker Compose](Docker/4-Docker-Compose.md)**
   - Multi-container applications
   - docker-compose.yml syntax
   - Service definitions
   - Networks and volumes
   - Environment management
   - Common patterns

### Advanced Level - Production
7. **[Advanced Topics](Docker/5-Advanced-Topics.md)**
   - Security best practices
   - Performance optimization
   - Production deployment
   - Monitoring and logging
   - CI/CD integration
   - Troubleshooting

---

## Quick Reference

### Essential Docker Commands

#### Container Management
```bash
# Run container
docker run -d --name myapp nginx

# List containers
docker ps                    # Running
docker ps -a                 # All

# Stop/Start/Restart
docker stop myapp
docker start myapp
docker restart myapp

# Remove container
docker rm myapp
docker rm -f myapp           # Force remove

# View logs
docker logs myapp
docker logs -f myapp         # Follow logs

# Execute command in container
docker exec -it myapp bash
```

#### Image Management
```bash
# List images
docker images

# Pull image
docker pull nginx:latest

# Build image
docker build -t myapp:1.0 .

# Tag image
docker tag myapp:1.0 username/myapp:1.0

# Push image
docker push username/myapp:1.0

# Remove image
docker rmi myapp:1.0
```

#### Docker Compose
```bash
# Start services
docker compose up
docker compose up -d         # Detached mode

# Stop services
docker compose down

# View logs
docker compose logs
docker compose logs -f       # Follow logs

# Execute command
docker compose exec web bash

# Rebuild services
docker compose up --build
```

### Dockerfile Example
```dockerfile
# Multi-stage build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Docker Compose Example
```yaml
version: '3.8'

services:
  web:
    build: ./web
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    volumes:
      - ./web:/app
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

---

## Docker Architecture

### Components

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Client                        │
│                   (docker CLI)                          │
└────────────────────┬────────────────────────────────────┘
                     │ REST API
┌────────────────────▼────────────────────────────────────┐
│                 Docker Daemon                           │
│                  (dockerd)                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Images   │  │Containers│  │ Networks │            │
│  └──────────┘  └──────────┘  └──────────┘            │
│  ┌──────────┐  ┌──────────┐                           │
│  │ Volumes  │  │ Plugins  │                           │
│  └──────────┘  └──────────┘                           │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Docker Registry                            │
│            (Docker Hub, Private)                        │
└─────────────────────────────────────────────────────────┘
```

**Docker Client:** CLI tool that sends commands to Docker daemon
**Docker Daemon:** Background service that manages containers, images, networks, and volumes
**Docker Registry:** Storage for Docker images (Docker Hub, private registries)

---

## Container Lifecycle

```
┌─────────┐
│ Created │  docker create
└────┬────┘
     │
     │ docker start
     ▼
┌─────────┐
│ Running │  docker run
└────┬────┘
     │
     ├─────► docker pause ──► ┌────────┐
     │                         │ Paused │
     │      docker unpause ◄── └────────┘
     │
     │ docker stop
     ▼
┌─────────┐
│ Stopped │
└────┬────┘
     │
     │ docker rm
     ▼
┌─────────┐
│ Deleted │
└─────────┘
```

---

## Docker Networking

### Network Drivers

| Driver | Description | Use Case |
|--------|-------------|----------|
| **bridge** | Default, isolated network | Single-host communication |
| **host** | Uses host network directly | Performance-critical apps |
| **overlay** | Multi-host networking | Docker Swarm, Kubernetes |
| **macvlan** | Assigns MAC address to container | Legacy app integration |
| **none** | No networking | Isolated containers |

### Network Commands
```bash
# Create network
docker network create mynetwork

# List networks
docker network ls

# Inspect network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork mycontainer

# Disconnect
docker network disconnect mynetwork mycontainer

# Remove network
docker network rm mynetwork
```

---

## Docker Volumes

### Volume Types

1. **Named Volumes** - Managed by Docker
```bash
docker volume create mydata
docker run -v mydata:/data myapp
```

2. **Bind Mounts** - Host directory mounted
```bash
docker run -v /host/path:/container/path myapp
```

3. **tmpfs Mounts** - Temporary, in-memory
```bash
docker run --tmpfs /tmp myapp
```

### Volume Commands
```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume

# Remove unused volumes
docker volume prune
```

---

## Best Practices

### Image Building
- ✅ Use official base images
- ✅ Use specific tags, not `latest`
- ✅ Minimize layers (combine RUN commands)
- ✅ Use multi-stage builds
- ✅ Don't run as root user
- ✅ Use .dockerignore file
- ✅ Scan images for vulnerabilities
- ✅ Keep images small

### Container Management
- ✅ One process per container
- ✅ Use environment variables for configuration
- ✅ Implement health checks
- ✅ Set resource limits (CPU, memory)
- ✅ Use volumes for persistent data
- ✅ Log to stdout/stderr
- ✅ Handle signals properly (SIGTERM)
- ✅ Use restart policies

### Security
- ✅ Don't store secrets in images
- ✅ Use secrets management (Docker secrets, env vars)
- ✅ Run containers as non-root
- ✅ Use read-only filesystems when possible
- ✅ Limit container capabilities
- ✅ Keep images updated
- ✅ Scan for vulnerabilities
- ✅ Use trusted registries

### Production
- ✅ Use orchestration (Kubernetes, Docker Swarm)
- ✅ Implement monitoring and logging
- ✅ Use health checks
- ✅ Implement graceful shutdown
- ✅ Use CI/CD pipelines
- ✅ Tag images with version numbers
- ✅ Document your setup
- ✅ Test disaster recovery

---

## Common Use Cases

### Development Environment
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
```

### Microservices
```yaml
services:
  frontend:
    image: myapp/frontend:1.0
  backend:
    image: myapp/backend:1.0
  database:
    image: postgres:15
  cache:
    image: redis:7
```

### CI/CD Pipeline
```bash
# Build
docker build -t myapp:${VERSION} .

# Test
docker run myapp:${VERSION} npm test

# Push
docker push myapp:${VERSION}

# Deploy
docker service update --image myapp:${VERSION} myservice
```

---

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker logs container_name

# Inspect container
docker inspect container_name

# Check events
docker events

# Try interactive mode
docker run -it image_name /bin/bash
```

### Network Issues
```bash
# Check network
docker network inspect bridge

# Test connectivity
docker exec container_name ping other_container

# Check ports
docker port container_name
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Check container processes
docker top container_name

# Inspect container details
docker inspect container_name
```

### Image Issues
```bash
# Check image layers
docker history image_name

# Inspect image
docker inspect image_name

# Remove unused images
docker image prune
```

---

## Tools and Resources

### Essential Tools
- **Docker Desktop** - GUI for Docker
- **Docker Compose** - Multi-container orchestration
- **Docker Hub** - Public image registry
- **Portainer** - Container management UI
- **Dive** - Image layer explorer
- **Trivy** - Vulnerability scanner

### Monitoring
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **cAdvisor** - Container metrics
- **ELK Stack** - Log aggregation

### CI/CD Integration
- **Jenkins** - Automation server
- **GitLab CI** - Integrated CI/CD
- **GitHub Actions** - GitHub workflows
- **CircleCI** - Cloud CI/CD

---

## Directory Structure

```
CONTAINERIZATION/
├── README.md                      # This file
│
└── Docker/                        # Docker documentation
    ├── 0-Docker-Fundamentals.md   # Comprehensive basics
    ├── README.md                  # Docker concepts
    ├── 1-Installation.md          # Setup guide
    ├── 2-Docker-Commands.md       # CLI reference
    ├── 3-Dockerfile.md            # Image building
    ├── 4-Docker-Compose.md        # Multi-container apps
    ├── 5-Advanced-Topics.md       # Production topics
    ├── image.png                  # Architecture diagram
    ├── image 1.png                # Lifecycle diagram
    └── image 2.png                # States diagram
```

---

## Next Steps

### After Learning Docker
1. **Kubernetes** - Container orchestration at scale
2. **Docker Swarm** - Docker's native orchestration
3. **Service Mesh** - Istio, Linkerd for microservices
4. **CI/CD** - Automate build and deployment
5. **Monitoring** - Prometheus, Grafana setup
6. **Security** - Container security best practices

### Related Topics
- [DevOps Core](../README.md) - Main documentation
- [CI/CD](../CICD/) - Continuous integration and deployment
- [Observability](../OBSERVABILITY/) - Monitoring containers
- [Networking](../NETWORKING/) - Network fundamentals

---

**Last Updated:** January 2026
**Maintained by:** DevOps Documentation Team
