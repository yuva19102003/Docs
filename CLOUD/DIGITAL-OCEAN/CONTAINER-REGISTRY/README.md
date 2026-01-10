# DigitalOcean Container Registry (DOCR)

Private Docker container registry integrated with Kubernetes and App Platform.

## Features
- Private container storage
- Kubernetes integration
- Vulnerability scanning
- Garbage collection
- Team access control

## Documentation
- [Container Registry Overview](./0-CONTAINER-REGISTRY-OVERVIEW.md)

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

## Links
- [Official Docs](https://docs.digitalocean.com/products/container-registry/)
- [Pricing](https://www.digitalocean.com/pricing/container-registry)
