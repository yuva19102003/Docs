# Kubernetes Best Practices

Production-ready guidelines for deploying and managing Kubernetes clusters.

## Resource Management

### 1. Always Set Resource Requests and Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
```

**Why:**
- Ensures proper scheduling
- Prevents resource starvation
- Enables autoscaling
- Protects cluster stability

### 2. Use ResourceQuotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "50"
```

### 3. Use LimitRanges

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: 500m
    defaultRequest:
      memory: 256Mi
      cpu: 250m
    type: Container
```

## Health Checks

### 1. Implement Liveness Probes

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### 2. Implement Readiness Probes

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

### 3. Use Startup Probes for Slow Apps

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

## Security

### 1. Run as Non-Root

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
```

### 2. Use Read-Only Root Filesystem

```yaml
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

### 3. Drop Unnecessary Capabilities

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
    add:
    - NET_BIND_SERVICE
```

### 4. Use Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 5. Enable RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### 6. Use Secrets for Sensitive Data

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

## Configuration

### 1. Use ConfigMaps for Configuration

```yaml
envFrom:
- configMapRef:
    name: app-config
```

### 2. Don't Hardcode Values

❌ **Bad:**
```yaml
env:
- name: DATABASE_URL
  value: "postgres://db:5432"
```

✅ **Good:**
```yaml
env:
- name: DATABASE_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database_url
```

### 3. Use Namespaces for Isolation

```bash
kubectl create namespace production
kubectl create namespace staging
kubectl create namespace development
```

## Deployment Strategies

### 1. Use Deployments, Not Pods

❌ **Bad:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
```

✅ **Good:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
```

### 2. Set Appropriate Replica Counts

```yaml
spec:
  replicas: 3  # Minimum for HA
```

### 3. Use Rolling Updates

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### 4. Set Pod Disruption Budgets

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
```

## Labels and Annotations

### 1. Use Consistent Labels

```yaml
metadata:
  labels:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp-prod
    app.kubernetes.io/version: "1.0"
    app.kubernetes.io/component: backend
    app.kubernetes.io/part-of: myplatform
    app.kubernetes.io/managed-by: helm
```

### 2. Use Annotations for Metadata

```yaml
metadata:
  annotations:
    description: "Production backend service"
    contact: "devops@example.com"
    documentation: "https://docs.example.com"
```

## Monitoring and Logging

### 1. Log to stdout/stderr

```python
# Good practice
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.info("Application started")
```

### 2. Use Structured Logging

```json
{
  "timestamp": "2024-01-01T10:00:00Z",
  "level": "INFO",
  "message": "Request processed",
  "request_id": "abc123",
  "duration_ms": 45
}
```

### 3. Expose Metrics

```yaml
ports:
- name: metrics
  containerPort: 9090
  protocol: TCP
```

### 4. Add Prometheus Annotations

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
```

## Storage

### 1. Use PersistentVolumes for Data

```yaml
volumeMounts:
- name: data
  mountPath: /data
volumes:
- name: data
  persistentVolumeClaim:
    claimName: data-pvc
```

### 2. Use StorageClasses

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  storageClassName: fast-ssd
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### 3. Backup Important Data

```bash
# Regular backups
kubectl exec -it pod-name -- tar czf - /data | gzip > backup.tar.gz
```

## Networking

### 1. Use Services for Communication

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
```

### 2. Use Ingress for External Access

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

### 3. Enable TLS

```yaml
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: tls-secret
```

## High Availability

### 1. Run Multiple Replicas

```yaml
spec:
  replicas: 3
```

### 2. Use Anti-Affinity

```yaml
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
            - myapp
        topologyKey: kubernetes.io/hostname
```

### 3. Spread Across Zones

```yaml
topologySpreadConstraints:
- maxSkew: 1
  topologyKey: topology.kubernetes.io/zone
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      app: myapp
```

## Image Management

### 1. Use Specific Image Tags

❌ **Bad:**
```yaml
image: myapp:latest
```

✅ **Good:**
```yaml
image: myapp:1.2.3
```

### 2. Use Image Pull Policies

```yaml
imagePullPolicy: IfNotPresent  # or Always for :latest
```

### 3. Use Private Registries

```yaml
imagePullSecrets:
- name: regcred
```

### 4. Scan Images for Vulnerabilities

```bash
# Using trivy
trivy image myapp:1.2.3
```

## Autoscaling

### 1. Use Horizontal Pod Autoscaler

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
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 2. Use Cluster Autoscaler

Enable on cloud provider for node autoscaling.

## CI/CD Integration

### 1. Use GitOps

```yaml
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  source:
    repoURL: https://github.com/example/myapp
    path: k8s
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

### 2. Implement Blue-Green Deployments

```yaml
# Blue deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3
---
# Green deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
```

### 3. Use Canary Deployments

```yaml
# Canary with Istio
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: v2
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
```

## Documentation

### 1. Document Resources

```yaml
metadata:
  annotations:
    description: "Production API backend"
    owner: "backend-team"
    runbook: "https://wiki.example.com/runbooks/api"
```

### 2. Maintain README

Include:
- Architecture overview
- Deployment instructions
- Configuration options
- Troubleshooting guide

### 3. Use NOTES.txt in Helm Charts

```
Thank you for installing {{ .Chart.Name }}.

Your release is named {{ .Release.Name }}.

To access your application:
  export POD_NAME=$(kubectl get pods -l "app={{ include "myapp.name" . }}" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward $POD_NAME 8080:80
```

## Testing

### 1. Test in Non-Production First

```bash
# Deploy to staging
kubectl apply -f deployment.yaml -n staging

# Verify
kubectl get pods -n staging
```

### 2. Use Dry Run

```bash
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server
```

### 3. Implement Smoke Tests

```bash
#!/bin/bash
# smoke-test.sh
kubectl wait --for=condition=ready pod -l app=myapp --timeout=300s
kubectl exec -it $(kubectl get pod -l app=myapp -o jsonpath='{.items[0].metadata.name}') -- curl localhost:8080/healthz
```

## Cleanup

### 1. Set TTL for Jobs

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-job
spec:
  ttlSecondsAfterFinished: 100
```

### 2. Use Finalizers Carefully

```yaml
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
```

### 3. Regular Cleanup

```bash
# Delete completed pods
kubectl delete pods --field-selector=status.phase==Succeeded

# Delete failed pods
kubectl delete pods --field-selector=status.phase==Failed
```

## Cost Optimization

### 1. Right-Size Resources

Monitor and adjust resource requests/limits based on actual usage.

### 2. Use Spot/Preemptible Instances

```yaml
nodeSelector:
  node.kubernetes.io/instance-type: spot
tolerations:
- key: "spot"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
```

### 3. Implement Autoscaling

Reduce costs during low-traffic periods.

## References

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Production Best Practices](https://learnk8s.io/production-best-practices)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/security-checklist/)
