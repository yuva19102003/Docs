# Kubernetes Objects

Kubernetes objects are persistent entities that represent the state of your cluster.

## Understanding Kubernetes Objects

### What are Objects?

Objects are records of intent - once created, Kubernetes works to ensure the object exists.

**Key Characteristics:**
- Persistent entities
- Represent desired state
- Managed via API
- Stored in etcd

### Object Spec and Status

Every Kubernetes object has two nested fields:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:              # Desired state
  containers:
  - name: nginx
    image: nginx
status:            # Current state (managed by K8s)
  phase: Running
  conditions: []
```

## Required Fields

All objects require these fields:

```yaml
apiVersion: v1           # API version
kind: Pod                # Object type
metadata:                # Identifying data
  name: my-object
  namespace: default
spec:                    # Desired state
  # Object-specific fields
```

## Object Categories

### 1. Workload Objects

Manage application workloads:

- **Pod**: Smallest deployable unit
- **Deployment**: Declarative updates for Pods
- **StatefulSet**: Stateful applications
- **DaemonSet**: One pod per node
- **Job**: Run-to-completion tasks
- **CronJob**: Scheduled jobs

### 2. Service Objects

Expose applications:

- **Service**: Stable network endpoint
- **Ingress**: HTTP/HTTPS routing
- **EndpointSlice**: Network endpoints

### 3. Storage Objects

Manage persistent data:

- **PersistentVolume (PV)**: Storage resource
- **PersistentVolumeClaim (PVC)**: Storage request
- **StorageClass**: Dynamic provisioning
- **VolumeSnapshot**: Volume backup

### 4. Configuration Objects

Manage configuration:

- **ConfigMap**: Configuration data
- **Secret**: Sensitive data

### 5. Security Objects

Control access:

- **ServiceAccount**: Pod identity
- **Role**: Namespace permissions
- **ClusterRole**: Cluster-wide permissions
- **RoleBinding**: Bind role to subjects
- **ClusterRoleBinding**: Cluster-wide binding

### 6. Cluster Objects

Cluster-level resources:

- **Namespace**: Virtual clusters
- **Node**: Worker machine
- **PersistentVolume**: Cluster storage
- **ClusterRole**: Cluster permissions

## Object Management

### Imperative Commands

Quick operations without YAML:

```bash
# Create deployment
kubectl create deployment nginx --image=nginx

# Expose service
kubectl expose deployment nginx --port=80

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Delete resource
kubectl delete deployment nginx
```

### Imperative Object Configuration

Using YAML files:

```bash
# Create from file
kubectl create -f deployment.yaml

# Update from file
kubectl replace -f deployment.yaml

# Delete from file
kubectl delete -f deployment.yaml
```

### Declarative Object Configuration

Recommended for production:

```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Apply directory
kubectl apply -f ./configs/

# Apply with recursive
kubectl apply -f ./configs/ -R

# View last applied configuration
kubectl get deployment nginx -o yaml
```

## Object Metadata

### Labels

Key-value pairs for organizing objects:

```yaml
metadata:
  labels:
    app: nginx
    environment: production
    tier: frontend
    version: "1.0"
```

**Label Selectors:**

```bash
# Equality-based
kubectl get pods -l app=nginx
kubectl get pods -l environment!=production

# Set-based
kubectl get pods -l 'environment in (production, staging)'
kubectl get pods -l 'tier notin (frontend, backend)'

# Multiple selectors
kubectl get pods -l app=nginx,environment=production
```

### Annotations

Non-identifying metadata:

```yaml
metadata:
  annotations:
    description: "Production nginx deployment"
    contact: "devops@example.com"
    buildVersion: "1.2.3"
    kubernetes.io/change-cause: "Update to version 1.2.3"
```

### Namespaces

Virtual clusters for resource isolation:

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace dev

# Set default namespace
kubectl config set-context --current --namespace=dev

# Get resources in namespace
kubectl get pods -n dev

# Get resources in all namespaces
kubectl get pods --all-namespaces
```

## Object Names and UIDs

### Names

User-provided identifiers:

```yaml
metadata:
  name: my-pod        # Must be unique within namespace
  namespace: default
```

**Naming Constraints:**
- Max 253 characters
- Lowercase alphanumeric, `-`, `.`
- Start and end with alphanumeric

### UIDs

System-generated unique identifiers:

```bash
# View UID
kubectl get pod my-pod -o jsonpath='{.metadata.uid}'
```

## Owner References

Establish parent-child relationships:

```yaml
metadata:
  ownerReferences:
  - apiVersion: apps/v1
    kind: ReplicaSet
    name: nginx-deployment-7d64c5d5c9
    uid: 12345678-1234-1234-1234-123456789012
    controller: true
    blockOwnerDeletion: true
```

**Garbage Collection:**
- Foreground: Delete dependents first
- Background: Delete owner immediately
- Orphan: Leave dependents

```bash
# Delete with cascade
kubectl delete deployment nginx --cascade=foreground

# Delete without cascade (orphan)
kubectl delete deployment nginx --cascade=orphan
```

## Finalizers

Prevent deletion until conditions are met:

```yaml
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  - example.com/custom-finalizer
```

## Field Selectors

Query objects by field values:

```bash
# By status
kubectl get pods --field-selector status.phase=Running

# By metadata
kubectl get pods --field-selector metadata.namespace=default

# Multiple fields
kubectl get pods --field-selector status.phase=Running,spec.restartPolicy=Always
```

## Common Object Patterns

### Basic Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://db:5432"
  log_level: "info"
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQxMjM=  # base64 encoded
```

## Object Lifecycle

```
┌──────────┐
│ Created  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Pending  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Running  │
└────┬─────┘
     │
     ▼
┌──────────┐
│Succeeded │
│  Failed  │
│ Unknown  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Deleted  │
└──────────┘
```

## Viewing Objects

```bash
# Get resources
kubectl get pods
kubectl get deployments
kubectl get services

# Describe resource
kubectl describe pod nginx-pod

# Get YAML
kubectl get pod nginx-pod -o yaml

# Get JSON
kubectl get pod nginx-pod -o json

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Watch resources
kubectl get pods --watch
```

## Editing Objects

```bash
# Edit live object
kubectl edit deployment nginx

# Patch object
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# Set image
kubectl set image deployment/nginx nginx=nginx:1.22

# Annotate
kubectl annotate pod nginx description="Production pod"

# Label
kubectl label pod nginx environment=production
```

## Best Practices

1. **Use Declarative Configuration**
   - Store YAML in version control
   - Use `kubectl apply`
   - Enable GitOps workflows

2. **Organize with Labels**
   - Consistent labeling scheme
   - Use for selection and grouping
   - Include app, environment, version

3. **Use Namespaces**
   - Separate environments
   - Resource quotas per namespace
   - RBAC per namespace

4. **Document with Annotations**
   - Add descriptions
   - Track changes
   - Store metadata

5. **Resource Management**
   - Set resource requests/limits
   - Use resource quotas
   - Monitor usage

## References

- [Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/)
- [Object Management](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)
