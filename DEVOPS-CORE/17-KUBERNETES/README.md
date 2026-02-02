# Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

## 📚 Documentation Structure

### Core Concepts
- [Kubernetes Architecture](01-Architecture.md) - Control plane, nodes, and components
- [Kubernetes Objects](02-Objects.md) - Understanding K8s resources
- [Pods](03-Pods.md) - The smallest deployable units
- [Workloads](04-Workloads.md) - Deployments, StatefulSets, DaemonSets, Jobs

### Networking
- [Networking Overview](05-Networking-Overview.md) - K8s networking model
- [Services](06-Services.md) - Service types and load balancing
- [Ingress](07-Ingress.md) - HTTP/HTTPS routing
- [Network Policies](08-Network-Policies.md) - Traffic control

### Storage
- [Storage Overview](09-Storage-Overview.md) - Volumes and persistence
- [Persistent Volumes](10-Persistent-Volumes.md) - PV and PVC
- [Storage Classes](11-Storage-Classes.md) - Dynamic provisioning

### Configuration & Secrets
- [ConfigMaps](12-ConfigMaps.md) - Configuration management
- [Secrets](13-Secrets.md) - Sensitive data management

### Security
- [Security Overview](14-Security-Overview.md) - K8s security model
- [RBAC](15-RBAC.md) - Role-Based Access Control
- [Pod Security](16-Pod-Security.md) - Security contexts and policies
- [Network Security](17-Network-Security.md) - Securing cluster networking

### Advanced Topics
- [Operators](18-Operators.md) - Extending Kubernetes
- [Custom Resources](19-Custom-Resources.md) - CRDs and custom controllers
- [Helm](20-Helm.md) - Package management
- [Autoscaling](21-Autoscaling.md) - HPA, VPA, Cluster Autoscaler

### Operations
- [kubectl Commands](22-kubectl-Commands.md) - Essential CLI commands
- [Cluster Setup](23-Cluster-Setup.md) - Installation and configuration
- [Monitoring](24-Monitoring.md) - Observability and metrics
- [Logging](25-Logging.md) - Log aggregation
- [Troubleshooting](26-Troubleshooting.md) - Common issues and solutions

### Workflows & Best Practices
- [CI/CD with Kubernetes](27-CICD-Workflows.md) - Deployment workflows
- [GitOps](28-GitOps.md) - GitOps practices
- [Best Practices](29-Best-Practices.md) - Production recommendations
- [Multi-Tenancy](30-Multi-Tenancy.md) - Cluster sharing strategies

## 🚀 Quick Start

```bash
# Check cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get all resources
kubectl get all
```

## 📖 Learning Path

1. **Fundamentals**: Architecture → Objects → Pods → Workloads
2. **Networking**: Services → Ingress → Network Policies
3. **Storage**: Volumes → Persistent Volumes → Storage Classes
4. **Configuration**: ConfigMaps → Secrets
5. **Security**: RBAC → Pod Security → Network Security
6. **Advanced**: Operators → Custom Resources → Helm
7. **Operations**: kubectl → Monitoring → Troubleshooting

## 🔗 Official Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubernetes GitHub](https://github.com/kubernetes/kubernetes)
- [CNCF Kubernetes](https://www.cncf.io/projects/kubernetes/)
