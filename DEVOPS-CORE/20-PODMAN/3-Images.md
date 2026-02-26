# Podman Images

## Understanding Images

Container images are read-only templates containing:
- Application code
- Runtime environment
- System libraries
- Dependencies
- Configuration files

### Image Layers
Images are built in layers:
```
Layer 4: Application code
Layer 3: Application dependencies
Layer 2: Runtime (Node.js, Python, etc.)
Layer 1: Base OS (Alpine, Ubuntu, etc.)
```

## Building Images

### Using Dockerfile

#### Basic Dockerfile
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Build Image
```bash
# Build from Dockerfile
podman build -t myapp:latest .

# Build with specific file
podman build -f Dockerfile.prod -t myapp:prod .

# Build with build args
podman build --build-arg VERSION=1.0 -t myapp:1.0 .

# Build without cache
podman build --no-cache -t myapp:latest .

# Build with labels
podman build --label version=1.0 --label env=prod -t myapp .
```

### Multi-Stage Builds

```dockerfile
# Build stage
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Runtime stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp .
EXPOSE 8080
CMD ["./myapp"]
```

```bash
# Build multi-stage
podman build -t myapp:latest .

# Build specific stage
podman build --target builder -t myapp:builder .
```

### Dockerfile Best Practices

#### Optimize Layers
```dockerfile
# Bad: Multiple RUN commands
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim

# Good: Single RUN command
RUN apt-get update && \
    apt-get install -y \
        curl \
        vim && \
    rm -rf /var/lib/apt/lists/*
```

#### Use .dockerignore
```
# .dockerignore
node_modules
.git
.env
*.log
.DS_Store
```

#### Minimize Image Size
```dockerfile
# Use Alpine base
FROM node:18-alpine

# Multi-stage build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

## Using Buildah

Buildah provides more flexibility than Dockerfile builds.

### Basic Buildah Commands

```bash
# Create working container
buildah from alpine

# Run commands in container
buildah run alpine-working-container apk add nginx

# Copy files
buildah copy alpine-working-container index.html /usr/share/nginx/html/

# Configure container
buildah config --port 80 alpine-working-container
buildah config --cmd "nginx -g 'daemon off;'" alpine-working-container

# Commit to image
buildah commit alpine-working-container mynginx:latest
```

### Buildah Script Example

```bash
#!/bin/bash

# Create container from base
container=$(buildah from node:18-alpine)

# Install dependencies
buildah run $container npm install -g pm2

# Copy application
buildah copy $container package*.json /app/
buildah run $container --workingdir /app npm install
buildah copy $container . /app/

# Configure
buildah config --workingdir /app $container
buildah config --port 3000 $container
buildah config --cmd "pm2-runtime start server.js" $container

# Commit
buildah commit $container myapp:latest

# Cleanup
buildah rm $container
```

## Image Management

### Tagging Images

```bash
# Tag image
podman tag myapp:latest myapp:v1.0

# Tag for registry
podman tag myapp:latest registry.example.com/myapp:latest

# Multiple tags
podman tag myapp:latest myapp:stable
podman tag myapp:latest myapp:production
```

### Pushing Images

```bash
# Login to registry
podman login docker.io
podman login quay.io
podman login registry.example.com

# Push image
podman push myapp:latest

# Push to specific registry
podman push myapp:latest docker.io/username/myapp:latest

# Push all tags
podman push --all-tags myapp
```

### Pulling Images

```bash
# Pull latest
podman pull nginx

# Pull specific tag
podman pull nginx:1.21-alpine

# Pull from specific registry
podman pull quay.io/nginx/nginx:latest

# Pull with digest
podman pull nginx@sha256:abc123...

# Pull all tags
podman pull --all-tags nginx
```

## Image Inspection

### Inspect Image

```bash
# Full inspection
podman inspect nginx

# Get specific field
podman inspect --format='{{.Config.Cmd}}' nginx

# Get environment variables
podman inspect --format='{{.Config.Env}}' nginx

# Get exposed ports
podman inspect --format='{{.Config.ExposedPorts}}' nginx

# Get labels
podman inspect --format='{{.Config.Labels}}' nginx
```

### Image History

```bash
# View image layers
podman history nginx

# Show full commands
podman history --no-trunc nginx

# Human-readable sizes
podman history --human nginx

# Show layer IDs
podman history --format "{{.ID}} {{.Size}}" nginx
```

### Image Tree

```bash
# Show image layers as tree
podman image tree nginx

# Show with layer IDs
podman image tree --whatrequires nginx
```

## Image Scanning

### Using Skopeo

```bash
# Inspect remote image
skopeo inspect docker://nginx:latest

# Copy image between registries
skopeo copy \
  docker://nginx:latest \
  docker://registry.example.com/nginx:latest

# Delete remote image
skopeo delete docker://registry.example.com/nginx:old
```

### Vulnerability Scanning

```bash
# Using Trivy
trivy image nginx:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL nginx:latest

# Generate report
trivy image --format json -o report.json nginx:latest
```

## Working with Registries

### Registry Configuration

```bash
# Edit registries.conf
vi /etc/containers/registries.conf
```

```toml
[registries.search]
registries = ['docker.io', 'quay.io']

[registries.insecure]
registries = ['registry.local:5000']

[registries.block]
registries = []
```

### Private Registry

```bash
# Run local registry
podman run -d -p 5000:5000 --name registry registry:2

# Tag for local registry
podman tag myapp:latest localhost:5000/myapp:latest

# Push to local registry
podman push localhost:5000/myapp:latest

# Pull from local registry
podman pull localhost:5000/myapp:latest
```

### Authentication

```bash
# Login
podman login registry.example.com

# Login with credentials
podman login -u username -p password registry.example.com

# Logout
podman logout registry.example.com

# View stored credentials
cat ~/.config/containers/auth.json
```

## Image Optimization

### Reduce Image Size

#### Use Alpine Base
```dockerfile
FROM node:18-alpine
# Alpine is ~5MB vs Ubuntu ~70MB
```

#### Multi-Stage Builds
```dockerfile
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o app

FROM scratch
COPY --from=builder /app/app /app
CMD ["/app"]
```

#### Remove Unnecessary Files
```dockerfile
RUN apt-get update && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*
```

### Layer Caching

```dockerfile
# Copy dependencies first (cached)
COPY package*.json ./
RUN npm install

# Copy source code last (changes frequently)
COPY . .
```

## Image Formats

### OCI vs Docker

```bash
# Build OCI format (default)
podman build --format oci -t myapp:latest .

# Build Docker format
podman build --format docker -t myapp:latest .
```

### Manifest Lists

```bash
# Create manifest list
podman manifest create myapp:latest

# Add images to manifest
podman manifest add myapp:latest myapp:amd64
podman manifest add myapp:latest myapp:arm64

# Push manifest
podman manifest push myapp:latest docker://registry.example.com/myapp:latest
```

## Advanced Image Operations

### Flatten Image

```bash
# Export and import to flatten
podman export $(podman create nginx) | podman import - nginx:flat
```

### Modify Image

```bash
# Create container from image
podman create --name temp nginx

# Make changes
podman exec temp apt-get update
podman exec temp apt-get install -y curl

# Commit changes
podman commit temp nginx:modified

# Cleanup
podman rm temp
```

### Image Diff

```bash
# Show changes in container
podman diff mynginx

# Output:
# C /etc
# A /etc/nginx/custom.conf
# D /tmp/cache
```

## Troubleshooting Images

### Debug Build Issues

```bash
# Build with verbose output
podman build --log-level=debug -t myapp .

# Build specific stage
podman build --target builder -t myapp:debug .

# Run intermediate container
podman run -it <layer-id> sh
```

### Check Image Issues

```bash
# Verify image
podman inspect myapp:latest

# Check layers
podman history myapp:latest

# Test image
podman run --rm myapp:latest
```

## Best Practices

1. **Use Official Base Images**: Start with trusted images
2. **Keep Images Small**: Use Alpine, multi-stage builds
3. **One Process Per Container**: Follow single responsibility
4. **Don't Run as Root**: Use USER directive
5. **Use .dockerignore**: Exclude unnecessary files
6. **Tag Properly**: Use semantic versioning
7. **Scan for Vulnerabilities**: Regular security scans
8. **Document**: Add LABEL instructions
9. **Cache Wisely**: Order instructions for optimal caching
10. **Clean Up**: Remove temporary files in same layer

## Next Steps

Continue to:
- [Containers](4-Containers.md) - Advanced container management
- [Pods](5-Pods.md) - Working with pods
- [Networking](6-Networking.md) - Container networking
