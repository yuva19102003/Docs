# Kubernetes Operators

Operators extend Kubernetes to automate management of complex applications.

## Operator Overview

```
┌────────────────────────────────────────────────┐
│         Operator Pattern                       │
├────────────────────────────────────────────────┤
│                                                │
│  Custom Resource (CR)                          │
│         ↓                                      │
│  Operator Controller                           │
│         ↓                                      │
│  Reconciliation Loop                           │
│         ↓                                      │
│  Kubernetes Resources                          │
│                                                │
└────────────────────────────────────────────────┘
```

## What is an Operator?

An Operator is a method of packaging, deploying, and managing a Kubernetes application using custom resources and controllers.

**Key Components:**
- Custom Resource Definition (CRD)
- Custom Controller
- Domain-specific knowledge

## Operator Capability Levels

```
Level 5: Auto Pilot
  ↑
Level 4: Deep Insights
  ↑
Level 3: Full Lifecycle
  ↑
Level 2: Seamless Upgrades
  ↑
Level 1: Basic Install
```

## Custom Resource Definition (CRD)

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: integer
                minimum: 1
                maximum: 100
              version:
                type: string
                enum: ["12", "13", "14"]
              backup:
                type: boolean
          status:
            type: object
            properties:
              phase:
                type: string
              ready:
                type: boolean
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
    - db
```

## Custom Resource

```yaml
apiVersion: example.com/v1
kind: Database
metadata:
  name: my-database
spec:
  size: 3
  version: "14"
  backup: true
```

## Popular Operators

### Prometheus Operator

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
spec:
  replicas: 2
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  resources:
    requests:
      memory: 400Mi
```

### MySQL Operator

```yaml
apiVersion: mysql.oracle.com/v2
kind: InnoDBCluster
metadata:
  name: mysql-cluster
spec:
  secretName: mysql-secret
  instances: 3
  router:
    instances: 2
  datadirVolumeClaimTemplate:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 20Gi
```

### PostgreSQL Operator

```yaml
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: postgres-cluster
spec:
  teamId: "myteam"
  volume:
    size: 10Gi
  numberOfInstances: 3
  users:
    myuser:
    - superuser
    - createdb
  databases:
    mydb: myuser
  postgresql:
    version: "14"
```

### Elasticsearch Operator

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch
spec:
  version: 8.5.0
  nodeSets:
  - name: default
    count: 3
    config:
      node.store.allow_mmap: false
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 100Gi
```

### Redis Operator

```yaml
apiVersion: redis.redis.opstreelabs.in/v1beta1
kind: Redis
metadata:
  name: redis-cluster
spec:
  kubernetesConfig:
    image: redis:7.0
  redisExporter:
    enabled: true
  storage:
    volumeClaimTemplate:
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

## Building an Operator

### Using Operator SDK

```bash
# Install Operator SDK
brew install operator-sdk

# Create new operator
operator-sdk init --domain=example.com --repo=github.com/example/myoperator

# Create API
operator-sdk create api --group=app --version=v1 --kind=MyApp --resource --controller

# Build and push
make docker-build docker-push IMG=myregistry/myoperator:v1.0.0

# Deploy
make deploy IMG=myregistry/myoperator:v1.0.0
```

### Controller Logic

```go
func (r *MyAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    log := log.FromContext(ctx)
    
    // Fetch the MyApp instance
    myApp := &appv1.MyApp{}
    err := r.Get(ctx, req.NamespacedName, myApp)
    if err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }
    
    // Reconciliation logic
    // 1. Check current state
    // 2. Compare with desired state
    // 3. Take action to reach desired state
    
    return ctrl.Result{}, nil
}
```

## Operator Lifecycle Manager (OLM)

### Install OLM

```bash
# Install OLM
operator-sdk olm install

# Check OLM status
operator-sdk olm status
```

### ClusterServiceVersion

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: ClusterServiceVersion
metadata:
  name: myoperator.v1.0.0
spec:
  displayName: My Operator
  description: Manages MyApp instances
  version: 1.0.0
  install:
    strategy: deployment
    spec:
      deployments:
      - name: myoperator-controller
        spec:
          replicas: 1
          selector:
            matchLabels:
              control-plane: controller-manager
          template:
            metadata:
              labels:
                control-plane: controller-manager
            spec:
              containers:
              - name: manager
                image: myoperator:v1.0.0
```

## Operator Best Practices

### 1. Idempotent Reconciliation

```go
// Always check current state before making changes
func (r *Reconciler) reconcile(ctx context.Context, obj *MyApp) error {
    // Get current state
    current := &appsv1.Deployment{}
    err := r.Get(ctx, types.NamespacedName{Name: obj.Name}, current)
    
    if errors.IsNotFound(err) {
        // Create new resource
        return r.Create(ctx, desired)
    }
    
    // Update if needed
    if !reflect.DeepEqual(current.Spec, desired.Spec) {
        return r.Update(ctx, desired)
    }
    
    return nil
}
```

### 2. Status Subresource

```yaml
status:
  phase: Running
  conditions:
  - type: Ready
    status: "True"
    lastTransitionTime: "2024-01-01T10:00:00Z"
  - type: Progressing
    status: "False"
    lastTransitionTime: "2024-01-01T10:05:00Z"
```

### 3. Finalizers

```go
const myFinalizer = "example.com/finalizer"

func (r *Reconciler) reconcile(ctx context.Context, obj *MyApp) error {
    // Check if object is being deleted
    if !obj.DeletionTimestamp.IsZero() {
        if controllerutil.ContainsFinalizer(obj, myFinalizer) {
            // Cleanup logic
            if err := r.cleanup(ctx, obj); err != nil {
                return err
            }
            
            // Remove finalizer
            controllerutil.RemoveFinalizer(obj, myFinalizer)
            return r.Update(ctx, obj)
        }
        return nil
    }
    
    // Add finalizer if not present
    if !controllerutil.ContainsFinalizer(obj, myFinalizer) {
        controllerutil.AddFinalizer(obj, myFinalizer)
        return r.Update(ctx, obj)
    }
    
    // Normal reconciliation
    return nil
}
```

### 4. Owner References

```go
// Set owner reference
if err := controllerutil.SetControllerReference(myApp, deployment, r.Scheme); err != nil {
    return err
}
```

## Operator Commands

```bash
# List CRDs
kubectl get crds

# Describe CRD
kubectl describe crd databases.example.com

# List custom resources
kubectl get databases

# Describe custom resource
kubectl describe database my-database

# Get operator logs
kubectl logs -n operators deployment/myoperator-controller

# Delete custom resource
kubectl delete database my-database
```

## Operator Hub

```bash
# Search operators
kubectl operator list

# Install operator
kubectl operator install prometheus

# Uninstall operator
kubectl operator uninstall prometheus
```

## Troubleshooting

```bash
# Check operator logs
kubectl logs -n operators -l control-plane=controller-manager

# Check CRD
kubectl get crd databases.example.com -o yaml

# Check custom resource status
kubectl get database my-database -o jsonpath='{.status}'

# Describe custom resource
kubectl describe database my-database

# Check events
kubectl get events --field-selector involvedObject.name=my-database
```

## References

- [Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Operator SDK](https://sdk.operatorframework.io/)
- [OperatorHub.io](https://operatorhub.io/)
- [Operator Capability Levels](https://sdk.operatorframework.io/docs/overview/operator-capabilities/)
