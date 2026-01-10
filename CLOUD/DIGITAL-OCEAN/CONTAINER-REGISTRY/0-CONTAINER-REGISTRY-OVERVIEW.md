# DigitalOcean Container Registry (DOCR) Overview

## Introduction

DigitalOcean Container Registry (DOCR) is a private Docker container registry integrated with Kubernetes and App Platform for secure container image storage and deployment.

## Key Features

- Private Docker registry
- Kubernetes integration
- Vulnerability scanning
- Garbage collection
- Team access control
- $5/month for 500 GB

## Quick Start

```bash
# Create registry
doctl registry create my-registry

# Login
doctl registry login

# Push image
docker tag myapp registry.digitalocean.com/my-registry/myapp:v1
docker push registry.digitalocean.com/my-registry/myapp:v1
```

## Kubernetes Integration

```bash
# Auto-integration with DOKS
doctl registry kubernetes-manifest | kubectl apply -f -
```

## Pricing

- Starter: $5/month (500 GB)
- Basic: $20/month (1 TB)
- Professional: $40/month (2 TB)
