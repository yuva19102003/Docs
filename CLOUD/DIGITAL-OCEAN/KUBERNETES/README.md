# DigitalOcean Kubernetes (DOKS)

Managed Kubernetes service for deploying, managing, and scaling containerized applications.

## Documentation

- [Kubernetes Overview](./0-KUBERNETES-OVERVIEW.md) - Introduction and key features

## Quick Start

```bash
# Create cluster
doctl kubernetes cluster create my-cluster \
  --region nyc3 \
  --node-pool "name=worker;size=s-2vcpu-4gb;count=3"

# Get kubeconfig
doctl kubernetes cluster kubeconfig save my-cluster

# Deploy app
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## Quick Links

- [Official Documentation](https://docs.digitalocean.com/products/kubernetes/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Pricing](https://www.digitalocean.com/pricing/kubernetes)
