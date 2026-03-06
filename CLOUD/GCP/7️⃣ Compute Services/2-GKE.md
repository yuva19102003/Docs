# Google Kubernetes Engine (GKE)

Complete guide to managed Kubernetes on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Cluster Types](#cluster-types)
3. [Cluster Creation](#cluster-creation)
4. [Node Pools](#node-pools)
5. [Workload Deployment](#workload-deployment)
6. [Networking](#networking)
7. [Storage](#storage)
8. [Security](#security)
9. [Scaling](#scaling)
10. [Monitoring](#monitoring)
11. [Cost Optimization](#cost-optimization)
12. [Best Practices](#best-practices)

---

## Introduction

GKE is a managed Kubernetes service that simplifies deploying, managing, and scaling containerized applications.

### Key Features

✅ Managed control plane  
✅ Auto-scaling (cluster and pods)  
✅ Auto-repair and auto-upgrade  
✅ Integrated logging and monitoring  
✅ Workload Identity  
✅ Binary Authorization  
✅ Multi-cluster management  
✅ Service mesh (Anthos Service Mesh)  
✅ Serverless with Cloud Run for Anthos  
✅ Windows Server containers  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│              GKE Cluster                            │
├─────────────────────────────────────────────────────┤
│  Control Plane (Managed by Google)                 │
│  ┌──────────────────────────────────────────────┐   │
│  │  API Server                                  │   │
│  │  Scheduler                                   │   │
│  │  Controller Manager                          │   │
│  │  etcd                                        │   │
│  └──────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────┤
│  Node Pools (Your Compute)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Node 1  │  │  Node 2  │  │  Node 3  │         │
│  │  ┌────┐  │  │  ┌────┐  │  │  ┌────┐  │         │
│  │  │Pod │  │  │  │Pod │  │  │  │Pod │  │         │
│  │  └────┘  │  │  └────┘  │  │  └────┘  │         │
│  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────┘
```

---

## Cluster Types

### Standard Mode

**Full control over cluster configuration:**
- Manual node management
- Custom node pools
- Fine-grained control
- More configuration options

```bash
# Create standard cluster
gcloud container clusters create standard-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --disk-size=50 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10
```

### Autopilot Mode

**Fully managed, hands-off Kubernetes:**
- Google manages nodes
- Pay only for pods
- Automatic scaling
- Built-in security
- Reduced operational overhead

```bash
# Create autopilot cluster
gcloud container clusters create-auto autopilot-cluster \
  --region=us-central1
```

### Comparison

| Feature | Standard | Autopilot |
|---------|----------|-----------|
| **Node Management** | Manual | Automatic |
| **Pricing** | Per node | Per pod |
| **Control** | Full | Limited |
| **Security** | Manual | Built-in |
| **Scaling** | Manual/Auto | Automatic |
| **Maintenance** | Manual | Automatic |
| **Best For** | Custom needs | Simplicity |

---

## Cluster Creation

### Basic Cluster

```bash
# Create basic cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3
```

### Production Cluster

```bash
# Create production-ready cluster
gcloud container clusters create prod-cluster \
  --region=us-central1 \
  --num-nodes=1 \
  --machine-type=n2-standard-4 \
  --disk-type=pd-ssd \
  --disk-size=100 \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=30 \
  --enable-autorepair \
  --enable-autoupgrade \
  --maintenance-window-start=2026-01-01T00:00:00Z \
  --maintenance-window-duration=4h \
  --enable-ip-alias \
  --network=my-vpc \
  --subnetwork=my-subnet \
  --cluster-secondary-range-name=pods \
  --services-secondary-range-name=services \
  --enable-stackdriver-kubernetes \
  --enable-cloud-logging \
  --enable-cloud-monitoring \
  --addons=HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
  --workload-pool=my-project.svc.id.goog \
  --enable-shielded-nodes \
  --enable-network-policy \
  --labels=env=prod,team=platform
```

### Terraform Example

```hcl
resource "google_container_cluster" "primary" {
  name     = "prod-cluster"
  location = "us-central1"

  # Autopilot mode
  enable_autopilot = false

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  # Network policy
  network_policy {
    enabled = true
  }

  # Logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # Security
  enable_shielded_nodes = true
  
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 3
    max_node_count = 30
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-ssd"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env  = "prod"
      team = "platform"
    }

    tags = ["gke-node", "prod"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
```

---

## Node Pools

### Create Node Pool

```bash
# Create node pool
gcloud container node-pools create high-mem-pool \
  --cluster=my-cluster \
  --zone=us-central1-a \
  --machine-type=n2-highmem-4 \
  --num-nodes=2 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5 \
  --node-labels=workload=memory-intensive \
  --node-taints=workload=memory-intensive:NoSchedule
```

### Spot (Preemptible) Node Pool

```bash
# Create Spot node pool
gcloud container node-pools create spot-pool \
  --cluster=my-cluster \
  --zone=us-central1-a \
  --spot \
  --machine-type=n2-standard-4 \
  --num-nodes=3 \
  --enable-autoscaling \
  --min-nodes=0 \
  --max-nodes=10 \
  --node-labels=workload=batch
```

### GPU Node Pool

```bash
# Create GPU node pool
gcloud container node-pools create gpu-pool \
  --cluster=my-cluster \
  --zone=us-central1-a \
  --machine-type=n1-standard-4 \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --num-nodes=1 \
  --enable-autoscaling \
  --min-nodes=0 \
  --max-nodes=5
```

### Node Pool Management

```bash
# List node pools
gcloud container node-pools list --cluster=my-cluster --zone=us-central1-a

# Resize node pool
gcloud container node-pools resize high-mem-pool \
  --cluster=my-cluster \
  --zone=us-central1-a \
  --num-nodes=5

# Delete node pool
gcloud container node-pools delete high-mem-pool \
  --cluster=my-cluster \
  --zone=us-central1-a
```

---

## Workload Deployment

### Get Credentials

```bash
# Get cluster credentials
gcloud container clusters get-credentials my-cluster \
  --zone=us-central1-a

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Deploy Application

**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: gcr.io/my-project/web-app:v1
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
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

**service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

```bash
# Deploy
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check status
kubectl get deployments
kubectl get pods
kubectl get services

# Get external IP
kubectl get service web-service
```

### Ingress

**ingress.yaml:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "web-ip"
    networking.gke.io/managed-certificates: "web-cert"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: web-service
            port:
              number: 80
```

**managed-cert.yaml:**
```yaml
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: web-cert
spec:
  domains:
    - example.com
    - www.example.com
```

---

## Networking

### VPC-Native Clusters

```bash
# Create VPC-native cluster
gcloud container clusters create vpc-native-cluster \
  --zone=us-central1-a \
  --enable-ip-alias \
  --network=my-vpc \
  --subnetwork=my-subnet \
  --cluster-secondary-range-name=pods \
  --services-secondary-range-name=services
```

### Network Policy

**network-policy.yaml:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-db
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 5432
```

### Private Clusters

```bash
# Create private cluster
gcloud container clusters create private-cluster \
  --zone=us-central1-a \
  --enable-private-nodes \
  --enable-private-endpoint \
  --master-ipv4-cidr=172.16.0.0/28 \
  --enable-ip-alias \
  --network=my-vpc \
  --subnetwork=my-subnet
```

---

## Storage

### Persistent Volumes

**pvc.yaml:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard-rwo
  resources:
    requests:
      storage: 10Gi
```

**deployment-with-pvc.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-app
  template:
    metadata:
      labels:
        app: storage-app
    spec:
      containers:
      - name: app
        image: gcr.io/my-project/app:v1
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: data-pvc
```

### Storage Classes

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

---

## Security

### Workload Identity

```bash
# Enable Workload Identity
gcloud container clusters update my-cluster \
  --zone=us-central1-a \
  --workload-pool=my-project.svc.id.goog

# Create Kubernetes service account
kubectl create serviceaccount app-sa -n default

# Create GCP service account
gcloud iam service-accounts create app-gsa

# Bind accounts
gcloud iam service-accounts add-iam-policy-binding \
  app-gsa@my-project.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="serviceAccount:my-project.svc.id.goog[default/app-sa]"

# Annotate K8s service account
kubectl annotate serviceaccount app-sa \
  iam.gke.io/gcp-service-account=app-gsa@my-project.iam.gserviceaccount.com
```

### RBAC

**rbac.yaml:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer
  namespace: development
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
  namespace: development
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: ServiceAccount
  name: developer
  namespace: development
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

### Binary Authorization

```bash
# Enable Binary Authorization
gcloud container clusters update my-cluster \
  --zone=us-central1-a \
  --enable-binauthz

# Create policy
gcloud container binauthz policy import policy.yaml
```

---

## Scaling

### Horizontal Pod Autoscaler

**hpa.yaml:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 30
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

### Vertical Pod Autoscaler

```bash
# Install VPA
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-v1-crd-gen.yaml
```

**vpa.yaml:**
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: web-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  updatePolicy:
    updateMode: "Auto"
```

### Cluster Autoscaler

```bash
# Enable cluster autoscaler
gcloud container clusters update my-cluster \
  --zone=us-central1-a \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=30
```

---

## Monitoring

### Cloud Monitoring

```bash
# Enable monitoring
gcloud container clusters update my-cluster \
  --zone=us-central1-a \
  --enable-cloud-monitoring

# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="kubernetes.io/container/cpu/core_usage_time"'
```

### Logging

```bash
# View logs
kubectl logs -f deployment/web-app

# View logs in Cloud Logging
gcloud logging read "resource.type=k8s_container" --limit=50
```

---

## Cost Optimization

### Strategies

✅ Use Autopilot mode for variable workloads  
✅ Use Spot VMs for fault-tolerant workloads  
✅ Right-size pod resource requests  
✅ Use cluster autoscaler  
✅ Use node auto-provisioning  
✅ Delete unused clusters  
✅ Use committed use discounts  
✅ Optimize container images  
✅ Use horizontal pod autoscaling  
✅ Monitor and optimize resource usage  

### Cost Comparison

**Standard vs Autopilot (3 nodes, n2-standard-4):**

| Mode | Monthly Cost | Notes |
|------|--------------|-------|
| Standard | ~$425 | 3 nodes × $141.62 |
| Autopilot | ~$200-400 | Pay only for pods |

---

## Best Practices

✅ Use regional clusters for HA  
✅ Enable auto-repair and auto-upgrade  
✅ Use Workload Identity  
✅ Implement network policies  
✅ Use private clusters  
✅ Enable Binary Authorization  
✅ Use resource quotas  
✅ Implement pod security policies  
✅ Use namespaces for isolation  
✅ Monitor and alert on metrics  

---

## Next Steps

- **[Cloud Run](3-Cloud-Run.md)** - Serverless containers
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
