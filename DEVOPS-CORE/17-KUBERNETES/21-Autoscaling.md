# Kubernetes Autoscaling

Automatic scaling of applications and infrastructure based on demand.

## Autoscaling Types

```
┌────────────────────────────────────────────────┐
│         Kubernetes Autoscaling                 │
├────────────────────────────────────────────────┤
│                                                │
│  HPA (Horizontal Pod Autoscaler)              │
│    → Scale number of pods                     │
│                                                │
│  VPA (Vertical Pod Autoscaler)                │
│    → Scale pod resources (CPU/Memory)         │
│                                                │
│  Cluster Autoscaler                           │
│    → Scale number of nodes                    │
│                                                │
└────────────────────────────────────────────────┘
```

## Horizontal Pod Autoscaler (HPA)

Automatically scales the number of pods based on metrics.

### Prerequisites

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify metrics-server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods
```

### Basic HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Create HPA via kubectl

```bash
# CPU-based autoscaling
kubectl autoscale deployment myapp --cpu-percent=70 --min=2 --max=10

# View HPA
kubectl get hpa

# Describe HPA
kubectl describe hpa myapp-hpa
```

### CPU and Memory Based

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

### Custom Metrics

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  # CPU metric
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  
  # Custom metric (requests per second)
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
  
  # External metric (SQS queue length)
  - type: External
    external:
      metric:
        name: sqs_queue_length
        selector:
          matchLabels:
            queue: myqueue
      target:
        type: AverageValue
        averageValue: "30"
```

### HPA with Multiple Metrics

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 3
  maxReplicas: 20
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
  - type: Pods
    pods:
      metric:
        name: http_requests
      target:
        type: AverageValue
        averageValue: "10000"
```

### Scaling Behavior

```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
    policies:
    - type: Percent
      value: 50  # Scale down max 50% of current pods
      periodSeconds: 60
    - type: Pods
      value: 2  # Scale down max 2 pods
      periodSeconds: 60
    selectPolicy: Min  # Use minimum of policies
  
  scaleUp:
    stabilizationWindowSeconds: 0  # Scale up immediately
    policies:
    - type: Percent
      value: 100  # Double the pods
      periodSeconds: 15
    - type: Pods
      value: 4  # Add max 4 pods
      periodSeconds: 15
    selectPolicy: Max  # Use maximum of policies
```

## Vertical Pod Autoscaler (VPA)

Automatically adjusts CPU and memory requests/limits.

### Install VPA

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

### Basic VPA

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"  # Auto, Recreate, Initial, Off
```

### VPA Update Modes

**Auto**: VPA updates pods automatically
```yaml
updatePolicy:
  updateMode: "Auto"
```

**Recreate**: VPA recreates pods with new resources
```yaml
updatePolicy:
  updateMode: "Recreate"
```

**Initial**: VPA only sets resources on pod creation
```yaml
updatePolicy:
  updateMode: "Initial"
```

**Off**: VPA only provides recommendations
```yaml
updatePolicy:
  updateMode: "Off"
```

### VPA with Resource Policy

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: app
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 2000m
        memory: 2Gi
      controlledResources: ["cpu", "memory"]
      mode: Auto
```

### View VPA Recommendations

```bash
# Get VPA
kubectl get vpa

# Describe VPA
kubectl describe vpa myapp-vpa

# Get recommendations
kubectl get vpa myapp-vpa -o jsonpath='{.status.recommendation}'
```

## Cluster Autoscaler

Automatically adjusts the number of nodes in the cluster.

### AWS EKS

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.27.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<cluster-name>
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

### GKE

```bash
# Enable cluster autoscaler
gcloud container clusters update <cluster-name> \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10 \
  --zone=<zone>
```

### AKS

```bash
# Enable cluster autoscaler
az aks update \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 10
```

### Cluster Autoscaler Configuration

```yaml
# ConfigMap for cluster autoscaler
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-autoscaler-priority-expander
  namespace: kube-system
data:
  priorities: |-
    10:
      - .*-spot-.*
    50:
      - .*-ondemand-.*
```

## KEDA (Kubernetes Event-Driven Autoscaling)

Scale based on external events and metrics.

### Install KEDA

```bash
# Using Helm
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda --create-namespace
```

### KEDA ScaledObject

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-scaledobject
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 1
  maxReplicaCount: 10
  triggers:
  # Prometheus trigger
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: http_requests_total
      threshold: '100'
      query: sum(rate(http_requests_total[2m]))
  
  # RabbitMQ trigger
  - type: rabbitmq
    metadata:
      host: amqp://rabbitmq:5672
      queueName: myqueue
      queueLength: '5'
  
  # Kafka trigger
  - type: kafka
    metadata:
      bootstrapServers: kafka:9092
      consumerGroup: mygroup
      topic: mytopic
      lagThreshold: '10'
```

### KEDA with AWS SQS

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: sqs-scaledobject
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 0
  maxReplicaCount: 20
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-east-1.amazonaws.com/123456789/myqueue
      queueLength: "5"
      awsRegion: "us-east-1"
      identityOwner: pod
```

### KEDA with Cron

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: cron-scaledobject
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 1
  maxReplicaCount: 10
  triggers:
  - type: cron
    metadata:
      timezone: America/New_York
      start: 0 8 * * *  # Scale up at 8 AM
      end: 0 18 * * *    # Scale down at 6 PM
      desiredReplicas: "10"
```

## Testing Autoscaling

### Load Testing

```bash
# Install load generator
kubectl run -it --rm load-generator --image=busybox --restart=Never -- /bin/sh

# Generate load
while true; do wget -q -O- http://myapp; done
```

### Monitor HPA

```bash
# Watch HPA
kubectl get hpa --watch

# Watch pods
kubectl get pods --watch

# Check metrics
kubectl top pods
```

### Stress Test

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stress-test
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        cpu: "1000m"
      limits:
        cpu: "2000m"
```

## Best Practices

### 1. Set Resource Requests

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 2. Use Appropriate Metrics

- CPU for compute-intensive apps
- Memory for data-intensive apps
- Custom metrics for business logic
- External metrics for queue-based apps

### 3. Configure Scaling Behavior

```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300
  scaleUp:
    stabilizationWindowSeconds: 0
```

### 4. Set Reasonable Limits

```yaml
minReplicas: 2  # For high availability
maxReplicas: 20  # Prevent runaway scaling
```

### 5. Monitor and Alert

```yaml
# Prometheus alert
- alert: HPAMaxedOut
  expr: kube_hpa_status_current_replicas == kube_hpa_spec_max_replicas
  for: 15m
  annotations:
    summary: "HPA {{ $labels.hpa }} has been maxed out"
```

### 6. Test Scaling

- Load test before production
- Verify scaling behavior
- Monitor costs

### 7. Combine Autoscalers

- HPA for pod scaling
- Cluster Autoscaler for node scaling
- VPA for resource optimization (use carefully with HPA)

## Troubleshooting

```bash
# Check HPA status
kubectl get hpa
kubectl describe hpa myapp-hpa

# Check metrics
kubectl top pods
kubectl top nodes

# Check metrics-server
kubectl get deployment metrics-server -n kube-system
kubectl logs -n kube-system deployment/metrics-server

# Check VPA recommendations
kubectl describe vpa myapp-vpa

# Check cluster autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler
```

## Common Issues

### HPA Not Scaling

1. **Metrics not available**
   ```bash
   kubectl top pods
   # If error, check metrics-server
   ```

2. **Resource requests not set**
   ```yaml
   resources:
     requests:
       cpu: 100m  # Required for HPA
   ```

3. **Target not reached**
   ```bash
   kubectl describe hpa myapp-hpa
   # Check current vs target metrics
   ```

### VPA Not Working

1. **VPA not installed**
   ```bash
   kubectl get deployment -n kube-system | grep vpa
   ```

2. **Update mode incorrect**
   ```yaml
   updatePolicy:
     updateMode: "Auto"  # Not "Off"
   ```

## References

- [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [KEDA](https://keda.sh/)
