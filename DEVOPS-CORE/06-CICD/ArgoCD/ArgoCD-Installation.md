# ArgoCD Installation Guide

## Installation Methods

```
┌────────────────────────────────────────────────────────┐
│          ARGOCD INSTALLATION OPTIONS                    │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │   kubectl    │  │     Helm     │  │  Operator   │ │
│  │   Manifest   │  │    Chart     │  │             │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                 │                 │          │
│         ▼                 ▼                 ▼          │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ • Quick      │  │ • Production │  │ • GitOps    │ │
│  │ • Simple     │  │ • Customizable│ │ • Automated │ │
│  │ • Official   │  │ • Upgradeable│  │ • Managed   │ │
│  └──────────────┘  └──────────────┘  └─────────────┘ │
└────────────────────────────────────────────────────────┘
```

## Prerequisites

- Kubernetes cluster (v1.21+)
- kubectl configured
- Cluster admin access
- 2 GB RAM minimum
- 2 CPU cores minimum

## Method 1: Install with kubectl (Recommended for Getting Started)

### Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Verify installation
kubectl get pods -n argocd
```

### Access ArgoCD UI

**Option 1: Port Forward (Quick Access)**

```bash
# Port forward to localhost
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
```

**Option 2: LoadBalancer (Cloud Environments)**

```bash
# Change service type to LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get external IP
kubectl get svc argocd-server -n argocd
```

**Option 3: Ingress (Production)**

Create `argocd-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
  tls:
  - hosts:
    - argocd.example.com
    secretName: argocd-tls
```

Apply:

```bash
kubectl apply -f argocd-ingress.yaml
```

### Get Initial Admin Password

```bash
# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login with:
# Username: admin
# Password: <output from above command>
```

### Change Admin Password

```bash
# Install ArgoCD CLI first (see below)
argocd login localhost:8080

# Change password
argocd account update-password
```

## Method 2: Install with Helm

### Add Helm Repository

```bash
# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Install with Default Values

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 5.51.0
```

### Install with Custom Values

Create `argocd-values.yaml`:

```yaml
global:
  domain: argocd.example.com

server:
  service:
    type: LoadBalancer
  
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - argocd.example.com
    tls:
      - secretName: argocd-tls
        hosts:
          - argocd.example.com
  
  config:
    url: https://argocd.example.com
    
  rbacConfig:
    policy.default: role:readonly

redis-ha:
  enabled: true

controller:
  replicas: 2
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

repoServer:
  replicas: 2
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi

applicationSet:
  enabled: true

notifications:
  enabled: true
```

Install with custom values:

```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values argocd-values.yaml
```

### Upgrade ArgoCD

```bash
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  --values argocd-values.yaml
```

## Method 3: Install with Operator

### Install ArgoCD Operator

```bash
# Install operator
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/master/deploy/argo-cd/argo-cd.yaml
```

### Create ArgoCD Instance

Create `argocd-instance.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd
  namespace: argocd
spec:
  server:
    route:
      enabled: true
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
  
  controller:
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
  
  repo:
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
  
  redis:
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
  
  ha:
    enabled: true
```

Apply:

```bash
kubectl apply -f argocd-instance.yaml
```

## Install ArgoCD CLI

### Linux

```bash
# Download latest version
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Make executable
chmod +x argocd

# Move to PATH
sudo mv argocd /usr/local/bin/

# Verify installation
argocd version
```

### macOS

```bash
# Using Homebrew
brew install argocd

# Or download binary
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

### Windows

```powershell
# Download from GitHub releases
# https://github.com/argoproj/argo-cd/releases/latest

# Or using Chocolatey
choco install argocd-cli
```

## CLI Login

```bash
# Port forward if needed
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login
argocd login localhost:8080

# Or with credentials
argocd login localhost:8080 --username admin --password <password>

# Skip TLS verification (for self-signed certs)
argocd login localhost:8080 --insecure
```

## High Availability Setup

### HA Installation

```bash
# Install HA version
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
```

### HA Components

- **Multiple replicas** of application controller
- **Redis HA** with sentinel
- **Multiple repo servers**
- **Multiple API servers**

### HA Helm Values

```yaml
redis-ha:
  enabled: true
  haproxy:
    enabled: true

controller:
  replicas: 2

server:
  replicas: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5

repoServer:
  replicas: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
```

## Post-Installation Configuration

### Disable Admin User (Production)

```bash
# Update argocd-cm ConfigMap
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"admin.enabled":"false"}}'
```

### Configure SSO (Example: GitHub)

```bash
kubectl patch configmap argocd-cm -n argocd --type merge -p '{
  "data": {
    "url": "https://argocd.example.com",
    "dex.config": "connectors:\n  - type: github\n    id: github\n    name: GitHub\n    config:\n      clientID: $GITHUB_CLIENT_ID\n      clientSecret: $GITHUB_CLIENT_SECRET\n      orgs:\n      - name: my-org"
  }
}'
```

### Configure Repositories

```bash
# Add Git repository
argocd repo add https://github.com/user/repo.git \
  --username <username> \
  --password <password>

# Add private repository with SSH
argocd repo add git@github.com:user/repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

### Configure Clusters

```bash
# List contexts
kubectl config get-contexts

# Add cluster
argocd cluster add <context-name>

# List clusters
argocd cluster list
```

## Monitoring and Observability

### Prometheus Metrics

ArgoCD exposes Prometheus metrics by default:

```yaml
# ServiceMonitor for Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
```

### Grafana Dashboards

Import official ArgoCD dashboards:
- Dashboard ID: 14584 (ArgoCD Overview)
- Dashboard ID: 14585 (ArgoCD Application)

## Backup and Restore

### Backup ArgoCD

```bash
# Backup all ArgoCD resources
kubectl get all -n argocd -o yaml > argocd-backup.yaml

# Backup applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Backup secrets
kubectl get secrets -n argocd -o yaml > argocd-secrets-backup.yaml
```

### Restore ArgoCD

```bash
# Restore resources
kubectl apply -f argocd-backup.yaml
kubectl apply -f argocd-apps-backup.yaml
kubectl apply -f argocd-secrets-backup.yaml
```

## Upgrading ArgoCD

### Upgrade with kubectl

```bash
# Upgrade to latest stable
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Upgrade with Helm

```bash
# Update repository
helm repo update

# Upgrade
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  --values argocd-values.yaml
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n argocd

# Check pod logs
kubectl logs -n argocd <pod-name>

# Describe pod
kubectl describe pod -n argocd <pod-name>
```

### Cannot Access UI

```bash
# Check service
kubectl get svc -n argocd argocd-server

# Check ingress
kubectl get ingress -n argocd

# Port forward for testing
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Sync Issues

```bash
# Check application status
argocd app get <app-name>

# View application logs
argocd app logs <app-name>

# Refresh application
argocd app get <app-name> --refresh
```

## Uninstall ArgoCD

### kubectl

```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

### Helm

```bash
helm uninstall argocd --namespace argocd
kubectl delete namespace argocd
```

## Next Steps

Continue to:
- **ArgoCD-Applications.md** - Creating and managing applications
- **ArgoCD-Advanced.md** - Multi-cluster, RBAC, SSO
- **ArgoCD-Examples.md** - Real-world examples
