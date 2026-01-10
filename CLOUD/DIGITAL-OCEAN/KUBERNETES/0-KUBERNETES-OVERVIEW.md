# DigitalOcean Kubernetes (DOKS) Overview

## Introduction

DigitalOcean Kubernetes (DOKS) is a managed Kubernetes service that simplifies deploying, managing, and scaling containerized applications. It provides a production-ready Kubernetes cluster without the complexity of managing the control plane.

## Key Features

- **Managed Control Plane**: Free, fully managed Kubernetes control plane
- **Auto-Scaling**: Horizontal Pod Autoscaler and Cluster Autoscaler
- **Auto-Upgrades**: Automated Kubernetes version updates
- **High Availability**: Multi-node control plane
- **Integrated Monitoring**: Built-in metrics and logging
- **Load Balancer Integration**: Automatic LoadBalancer service provisioning
- **Block Storage**: Persistent volumes with DigitalOcean Volumes
- **Container Registry**: Integrated with DigitalOcean Container Registry
- **1-Click Apps**: Helm charts and marketplace apps
- **Free Control Plane**: Only pay for worker nodes


## DOKS Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              DigitalOcean Kubernetes Cluster                 │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Control Plane (Managed by DigitalOcean)        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │ │
│  │  │ API Server   │  │   etcd       │  │ Scheduler   │ │ │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │ │
│  │  ┌──────────────┐  ┌──────────────┐                  │ │
│  │  │ Controller   │  │   Cloud      │                  │ │
│  │  │  Manager     │  │  Controller  │                  │ │
│  │  └──────────────┘  └──────────────┘                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
│  ┌────────────────────────┼────────────────────────────────┐│
│  │         Worker Nodes (Your Droplets)                    ││
│  │                        │                                 ││
│  │  ┌─────────────────────▼──────────────────────────┐    ││
│  │  │  Node Pool 1 (e.g., s-2vcpu-4gb)               │    ││
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐     │    ││
│  │  │  │  Node 1  │  │  Node 2  │  │  Node 3  │     │    ││
│  │  │  │  Pods    │  │  Pods    │  │  Pods    │     │    ││
│  │  │  └──────────┘  └──────────┘  └──────────┘     │    ││
│  │  └─────────────────────────────────────────────────┘    ││
│  │                                                          ││
│  │  ┌──────────────────────────────────────────────────┐   ││
│  │  │  Node Pool 2 (e.g., c-4, CPU-optimized)         │   ││
│  │  │  ┌──────────┐  ┌──────────┐                     │   ││
│  │  │  │  Node 1  │  │  Node 2  │                     │   ││
│  │  │  │  Pods    │  │  Pods    │                     │   ││
│  │  │  └──────────┘  └──────────┘                     │   ││
│  │  └──────────────────────────────────────────────────┘   ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Integrated Services                        │ │
│  │  ├─> Load Balancers (automatic)                        │ │
│  │  ├─> Block Storage Volumes (PVs)                       │ │
│  │  ├─> Container Registry (DOCR)                         │ │
│  │  ├─> VPC Networking                                    │ │
│  │  └─> Monitoring & Logging                              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Cluster Configurations

### Node Pool Sizes

**Basic Droplets** (Shared CPU)
```
s-1vcpu-2gb    - $12/month  - Dev/Test
s-2vcpu-2gb    - $18/month  - Small workloads
s-2vcpu-4gb    - $24/month  - General purpose
s-4vcpu-8gb    - $48/month  - Medium workloads
s-8vcpu-16gb   - $96/month  - Large workloads
```

**General Purpose** (Dedicated CPU)
```
g-2vcpu-8gb    - $63/month  - Production apps
g-4vcpu-16gb   - $126/month - High-traffic apps
g-8vcpu-32gb   - $252/month - Enterprise apps
```

**CPU-Optimized**
```
c-2            - $42/month  - Compute-intensive
c-4            - $84/month  - CI/CD pipelines
c-8            - $168/month - High-performance
```

**Memory-Optimized**
```
m-2vcpu-16gb   - $126/month - In-memory apps
m-4vcpu-32gb   - $252/month - Caching layers
m-8vcpu-64gb   - $504/month - Big data
```

## Kubernetes Versions

### Supported Versions (2026)
```
Latest:
├─> 1.29.x (Latest stable)
├─> 1.28.x (Stable)
└─> 1.27.x (Stable)

Auto-Upgrade:
├─> Minor version updates
├─> Security patches
├─> Maintenance windows
└─> Zero-downtime upgrades
```

## Use Cases

### 1. Microservices Architecture
```
Deployment:
├─> Multiple services in containers
├─> Service mesh (Istio, Linkerd)
├─> API gateway
├─> Inter-service communication
└─> Independent scaling

Benefits:
├─> Service isolation
├─> Independent deployment
├─> Technology diversity
└─> Fault isolation
```

### 2. CI/CD Pipelines
```
Workflow:
├─> Build containers
├─> Run tests in pods
├─> Deploy to staging
├─> Promote to production
└─> Rollback if needed

Tools:
├─> Jenkins X
├─> GitLab CI/CD
├─> Argo CD
├─> Tekton
└─> Flux
```

### 3. Batch Processing
```
Jobs:
├─> Data processing
├─> ETL pipelines
├─> Machine learning training
├─> Report generation
└─> Scheduled tasks

Features:
├─> CronJobs
├─> Job parallelism
├─> Auto-scaling
└─> Resource limits
```

### 4. Web Applications
```
Stack:
├─> Frontend (React, Vue)
├─> Backend API (Node.js, Go)
├─> Database (PostgreSQL)
├─> Cache (Redis)
└─> Message queue (RabbitMQ)

Features:
├─> Load balancing
├─> Auto-scaling
├─> Rolling updates
└─> Health checks
```

### 5. Machine Learning
```
ML Workloads:
├─> Model training (GPU nodes)
├─> Model serving (inference)
├─> Feature engineering
├─> Data preprocessing
└─> Experiment tracking

Tools:
├─> Kubeflow
├─> MLflow
├─> TensorFlow Serving
└─> Seldon Core
```

## Quick Start

### Create Cluster via doctl

```bash
# Install doctl
brew install doctl

# Authenticate
doctl auth init

# List available regions
doctl kubernetes options regions

# List available node sizes
doctl kubernetes options sizes

# Create cluster
doctl kubernetes cluster create my-cluster \
  --region nyc3 \
  --version 1.29.0-do.0 \
  --node-pool "name=worker-pool;size=s-2vcpu-4gb;count=3;auto-scale=true;min-nodes=2;max-nodes=5" \
  --wait

# Get kubeconfig
doctl kubernetes cluster kubeconfig save my-cluster

# Verify cluster
kubectl get nodes
kubectl cluster-info
```

### Deploy Sample Application

```bash
# Create deployment
kubectl create deployment nginx --image=nginx:latest --replicas=3

# Expose as LoadBalancer
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service
kubectl get service nginx

# Get external IP
kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test
curl http://<external-ip>
```

## Cluster Management

### Scaling Node Pools

```bash
# Manual scaling
doctl kubernetes cluster node-pool update my-cluster worker-pool \
  --count 5

# Enable auto-scaling
doctl kubernetes cluster node-pool update my-cluster worker-pool \
  --auto-scale \
  --min-nodes 2 \
  --max-nodes 10

# Add new node pool
doctl kubernetes cluster node-pool create my-cluster \
  --name cpu-pool \
  --size c-4 \
  --count 2 \
  --auto-scale \
  --min-nodes 1 \
  --max-nodes 5
```

### Upgrading Cluster

```bash
# List available versions
doctl kubernetes options versions

# Upgrade cluster
doctl kubernetes cluster upgrade my-cluster \
  --version 1.29.0-do.0

# Check upgrade status
doctl kubernetes cluster get my-cluster
```

## Integrated Features

### 1. Load Balancers

```yaml
# Automatic LoadBalancer creation
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

### 2. Persistent Volumes

```yaml
# Using DigitalOcean Block Storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: do-block-storage
```

### 3. Container Registry

```bash
# Create registry
doctl registry create my-registry

# Login to registry
doctl registry login

# Build and push image
docker build -t registry.digitalocean.com/my-registry/app:v1 .
docker push registry.digitalocean.com/my-registry/app:v1

# Create image pull secret
doctl registry kubernetes-manifest | kubectl apply -f -
```

### 4. Monitoring

```bash
# Install metrics server (pre-installed)
kubectl top nodes
kubectl top pods

# View cluster metrics in control panel
# Navigate to Kubernetes → Cluster → Insights
```

## Helm Charts & 1-Click Apps

### Install Helm

```bash
# Install Helm
brew install helm

# Add repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Deploy Applications

```bash
# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.publishService.enabled=true

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Install Prometheus & Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

## Best Practices

### 1. Resource Management

```yaml
# Set resource requests and limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: app
        image: myapp:v1
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 2. High Availability

```yaml
# Use pod anti-affinity
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - web-app
              topologyKey: kubernetes.io/hostname
```

### 3. Health Checks

```yaml
# Implement liveness and readiness probes
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:v1
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 4. Security

```yaml
# Use security contexts
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: app
        image: myapp:v1
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
```

### 5. Auto-Scaling

```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Networking

### Ingress Controller

```yaml
# Install NGINX Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Network Policies

```yaml
# Restrict pod communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-network-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

## Monitoring & Logging

### Prometheus & Grafana

```bash
# Install kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Default credentials: admin / prom-operator
```

### Logging with Loki

```bash
# Install Loki stack
helm install loki grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  --set grafana.enabled=true

# Access logs in Grafana
kubectl port-forward -n logging svc/loki-grafana 3000:80
```

## Cost Optimization

### Strategies

```
1. Right-Size Node Pools
   ├─> Monitor resource usage
   ├─> Use appropriate node sizes
   └─> Remove unused nodes

2. Use Auto-Scaling
   ├─> Scale down during low traffic
   ├─> Scale up during peak hours
   └─> Set appropriate min/max

3. Optimize Workloads
   ├─> Set resource requests/limits
   ├─> Use spot instances (when available)
   └─> Consolidate small workloads

4. Use Cluster Autoscaler
   ├─> Automatically add/remove nodes
   ├─> Based on pod scheduling needs
   └─> Reduce idle capacity

5. Monitor Costs
   ├─> Track node pool costs
   ├─> Monitor LoadBalancer usage
   └─> Review storage volumes
```

## Troubleshooting

### Common Issues

**Pods Not Starting**
```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

**Node Issues**
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check node resources
kubectl top nodes

# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets
```

**Service Not Accessible**
```bash
# Check service
kubectl get service
kubectl describe service <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# Test from within cluster
kubectl run test --image=busybox -it --rm -- wget -O- http://service-name
```

## Pricing

### Control Plane
```
Free: $0/month
├─> Fully managed
├─> High availability
├─> Auto-upgrades
└─> Monitoring included
```

### Worker Nodes
```
Pay for Droplets:
├─> Basic: $12-96/month
├─> General Purpose: $63-1,008/month
├─> CPU-Optimized: $42-672/month
└─> Memory-Optimized: $126-2,016/month

Additional Costs:
├─> Load Balancers: $12/month each
├─> Block Storage: $0.10/GB/month
└─> Bandwidth: Included in Droplet
```

## Documentation Structure

1. **[Kubernetes Overview](./0-KUBERNETES-OVERVIEW.md)** - This page
2. **[Creating Clusters](./1-CREATING-CLUSTERS.md)** - Setup guide
3. **[Deploying Applications](./2-DEPLOYING-APPLICATIONS.md)** - Deployment patterns
4. **[Cluster Management](./3-CLUSTER-MANAGEMENT.md)** - Operations

## Next Steps

- [Create your first cluster](./1-CREATING-CLUSTERS.md)
- [Deploy applications](./2-DEPLOYING-APPLICATIONS.md)
- [Learn cluster management](./3-CLUSTER-MANAGEMENT.md)

## Additional Resources

- [Official Documentation](https://docs.digitalocean.com/products/kubernetes/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Charts](https://artifacthub.io/)
