# Kubernetes Pods

Pods are the smallest deployable units in Kubernetes that can be created and managed.

## What is a Pod?

A Pod represents a single instance of a running process in your cluster and can contain one or more containers.

```
┌─────────────────────────────────────┐
│             POD                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │  Container 1 │  │ Container 2 │ │
│  │   (nginx)    │  │  (sidecar)  │ │
│  └──────────────┘  └─────────────┘ │
│                                     │
│  ┌──────────────────────────────┐  │
│  │     Shared Network (IP)      │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │     Shared Storage Volumes   │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Key Characteristics:**
- Shared network namespace (same IP)
- Shared storage volumes
- Shared IPC namespace
- Ephemeral by nature
- Scheduled together on same node

## Basic Pod Definition

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: production
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

## Pod Lifecycle

### Pod Phases

```
Pending → Running → Succeeded/Failed
```

**Phases:**
- **Pending**: Accepted but not running yet
- **Running**: At least one container is running
- **Succeeded**: All containers terminated successfully
- **Failed**: All containers terminated, at least one failed
- **Unknown**: Pod state cannot be determined

```bash
# Check pod phase
kubectl get pod nginx-pod -o jsonpath='{.status.phase}'
```

### Container States

**Waiting**: Container is not running (pulling image, etc.)
```yaml
state:
  waiting:
    reason: ContainerCreating
```

**Running**: Container is executing
```yaml
state:
  running:
    startedAt: "2024-01-01T10:00:00Z"
```

**Terminated**: Container finished execution
```yaml
state:
  terminated:
    exitCode: 0
    reason: Completed
    startedAt: "2024-01-01T10:00:00Z"
    finishedAt: "2024-01-01T10:05:00Z"
```

### Pod Conditions

```yaml
status:
  conditions:
  - type: PodScheduled
    status: "True"
  - type: Initialized
    status: "True"
  - type: ContainersReady
    status: "True"
  - type: Ready
    status: "True"
```

## Multi-Container Pods

### Sidecar Pattern

Helper container alongside main container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
spec:
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  
  - name: log-shipper
    image: fluentd:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  
  volumes:
  - name: shared-logs
    emptyDir: {}
```

### Ambassador Pattern

Proxy container for external services:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-ambassador
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_HOST
      value: localhost
    - name: DATABASE_PORT
      value: "5432"
  
  - name: db-proxy
    image: ambassador-proxy:latest
    ports:
    - containerPort: 5432
```

### Adapter Pattern

Transform output to standard format:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-adapter
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: logs
      mountPath: /var/log
  
  - name: log-adapter
    image: log-formatter:latest
    volumeMounts:
    - name: logs
      mountPath: /var/log
  
  volumes:
  - name: logs
    emptyDir: {}
```

## Init Containers

Run before app containers start:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  initContainers:
  - name: init-db
    image: busybox:1.35
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done']
  
  - name: init-config
    image: busybox:1.35
    command: ['sh', '-c', 'echo "Initializing config" && sleep 5']
  
  containers:
  - name: myapp
    image: myapp:1.0
```

**Init Container Characteristics:**
- Run sequentially
- Must complete successfully
- Run before app containers
- Useful for setup tasks

## Container Configuration

### Resource Requests and Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-demo
spec:
  containers:
  - name: app
    image: nginx
    env:
    # Static value
    - name: ENVIRONMENT
      value: "production"
    
    # From ConfigMap
    - name: CONFIG_VALUE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    
    # From Secret
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
    
    # From field
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    
    # From resource field
    - name: CPU_LIMIT
      valueFrom:
        resourceFieldRef:
          containerName: app
          resource: limits.cpu
```

### Volume Mounts

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-demo
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: data-volume
      mountPath: /data
    - name: cache-volume
      mountPath: /cache
  
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: data-volume
    persistentVolumeClaim:
      claimName: data-pvc
  - name: cache-volume
    emptyDir: {}
```

## Health Checks

### Liveness Probe

Restart container if unhealthy:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
  - name: app
    image: myapp:1.0
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
```

### Readiness Probe

Remove from service if not ready:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-demo
spec:
  containers:
  - name: app
    image: myapp:1.0
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Startup Probe

For slow-starting containers:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
  - name: app
    image: myapp:1.0
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      failureThreshold: 30
      periodSeconds: 10
```

### Probe Types

**HTTP GET:**
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
    httpHeaders:
    - name: Custom-Header
      value: Awesome
```

**TCP Socket:**
```yaml
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20
```

**Exec Command:**
```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 5
```

**gRPC:**
```yaml
livenessProbe:
  grpc:
    port: 9090
  initialDelaySeconds: 10
```

## Pod Security

### Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  
  containers:
  - name: app
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
```

### Service Account

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-demo
spec:
  serviceAccountName: my-service-account
  automountServiceAccountToken: true
  containers:
  - name: app
    image: nginx
```

## Pod Scheduling

### Node Selector

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-demo
spec:
  nodeSelector:
    disktype: ssd
    environment: production
  containers:
  - name: nginx
    image: nginx
```

### Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-demo
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
            - arm64
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx
```

### Pod Affinity/Anti-Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-demo
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - cache
        topologyKey: kubernetes.io/hostname
    
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - web
          topologyKey: kubernetes.io/hostname
  containers:
  - name: nginx
    image: nginx
```

### Taints and Tolerations

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-demo
spec:
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  - key: "key2"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 3600
  containers:
  - name: nginx
    image: nginx
```

## Pod Disruption Budget

Ensure minimum availability during disruptions:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
```

## Pod Commands

```bash
# Create pod
kubectl run nginx --image=nginx

# Create from YAML
kubectl apply -f pod.yaml

# List pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces

# Describe pod
kubectl describe pod nginx-pod

# View logs
kubectl logs nginx-pod
kubectl logs nginx-pod -c container-name
kubectl logs nginx-pod --previous
kubectl logs -f nginx-pod

# Execute command
kubectl exec nginx-pod -- ls /
kubectl exec -it nginx-pod -- /bin/bash

# Port forward
kubectl port-forward nginx-pod 8080:80

# Copy files
kubectl cp nginx-pod:/path/to/file ./local-file
kubectl cp ./local-file nginx-pod:/path/to/file

# Delete pod
kubectl delete pod nginx-pod
kubectl delete pod nginx-pod --grace-period=0 --force
```

## Best Practices

1. **Single Responsibility**
   - One main process per container
   - Use sidecars for supporting functions

2. **Resource Management**
   - Always set resource requests
   - Set appropriate limits
   - Monitor actual usage

3. **Health Checks**
   - Implement liveness probes
   - Implement readiness probes
   - Use startup probes for slow apps

4. **Security**
   - Run as non-root user
   - Use read-only root filesystem
   - Drop unnecessary capabilities
   - Use security contexts

5. **Logging**
   - Log to stdout/stderr
   - Use structured logging
   - Include correlation IDs

6. **Configuration**
   - Use ConfigMaps for config
   - Use Secrets for sensitive data
   - Don't hardcode values

## References

- [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
