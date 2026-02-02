# Kubernetes Workloads

Workload resources manage sets of pods and provide different deployment patterns.

## Workload Resources Overview

```
┌─────────────────────────────────────────────────────┐
│              WORKLOAD RESOURCES                     │
├─────────────────────────────────────────────────────┤
│  Deployment      → Stateless apps, rolling updates │
│  StatefulSet     → Stateful apps, stable identity  │
│  DaemonSet       → One pod per node                │
│  Job             → Run-to-completion tasks         │
│  CronJob         → Scheduled tasks                 │
│  ReplicaSet      → Maintain pod replicas (low-level)│
└─────────────────────────────────────────────────────┘
```

## Deployments

Declarative updates for Pods and ReplicaSets.

### Basic Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
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
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Deployment Strategies

**Rolling Update (Default):**
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max pods above desired count
      maxUnavailable: 0  # Max pods unavailable during update
```

**Recreate:**
```yaml
spec:
  strategy:
    type: Recreate  # Kill all pods, then create new ones
```

### Update Deployment

```bash
# Update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Edit deployment
kubectl edit deployment nginx-deployment

# Apply changes
kubectl apply -f deployment.yaml

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Autoscale
kubectl autoscale deployment nginx-deployment --min=3 --max=10 --cpu-percent=80
```

### Rollout Management

```bash
# Check rollout status
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment

# View specific revision
kubectl rollout history deployment/nginx-deployment --revision=2

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Pause rollout
kubectl rollout pause deployment/nginx-deployment

# Resume rollout
kubectl rollout resume deployment/nginx-deployment

# Restart deployment
kubectl rollout restart deployment/nginx-deployment
```

### Advanced Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: advanced-deployment
spec:
  replicas: 3
  revisionHistoryLimit: 10
  progressDeadlineSeconds: 600
  minReadySeconds: 5
  
  selector:
    matchLabels:
      app: myapp
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - name: app
        image: myapp:1.0
        ports:
        - containerPort: 8080
        
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
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "500m"
          limits:
            memory: "256Mi"
            cpu: "1000m"
        
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
```

## StatefulSets

For stateful applications requiring stable network identity and persistent storage.

### Basic StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
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
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi
```

### Headless Service for StatefulSet

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None  # Headless service
  selector:
    app: nginx
```

**Pod DNS Names:**
- `web-0.nginx.default.svc.cluster.local`
- `web-1.nginx.default.svc.cluster.local`
- `web-2.nginx.default.svc.cluster.local`

### StatefulSet Features

**Ordered Deployment:**
- Pods created sequentially: 0, 1, 2
- Next pod created only after previous is Running and Ready

**Ordered Termination:**
- Pods terminated in reverse order: 2, 1, 0

**Stable Network Identity:**
- Predictable pod names
- Stable DNS entries

**Persistent Storage:**
- Each pod gets its own PVC
- PVCs retained on pod deletion

### StatefulSet Update Strategies

**RollingUpdate:**
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0  # Update pods >= partition
```

**OnDelete:**
```yaml
spec:
  updateStrategy:
    type: OnDelete  # Manual pod deletion required
```

### StatefulSet Commands

```bash
# Create StatefulSet
kubectl apply -f statefulset.yaml

# Scale StatefulSet
kubectl scale statefulset web --replicas=5

# Delete StatefulSet (keep PVCs)
kubectl delete statefulset web --cascade=orphan

# Update StatefulSet
kubectl patch statefulset web -p '{"spec":{"replicas":5}}'
```

## DaemonSets

Ensures a pod runs on all (or selected) nodes.

### Basic DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      
      containers:
      - name: fluentd
        image: fluentd:latest
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### DaemonSet with Node Selector

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nvidia-gpu-plugin
spec:
  selector:
    matchLabels:
      name: nvidia-gpu-plugin
  template:
    metadata:
      labels:
        name: nvidia-gpu-plugin
    spec:
      nodeSelector:
        accelerator: nvidia-gpu
      containers:
      - name: nvidia-gpu-plugin
        image: nvidia/k8s-device-plugin:latest
```

### DaemonSet Update Strategy

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
```

**Common Use Cases:**
- Log collectors (Fluentd, Filebeat)
- Monitoring agents (Prometheus Node Exporter)
- Network plugins (Calico, Weave)
- Storage daemons (Ceph, GlusterFS)

## Jobs

Run-to-completion tasks.

### Basic Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculation
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
  completions: 1
  parallelism: 1
```

### Parallel Jobs

**Fixed Completion Count:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  completions: 10      # Total successful completions
  parallelism: 3       # Max parallel pods
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item && sleep 5"]
      restartPolicy: Never
```

**Work Queue:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: work-queue
spec:
  parallelism: 5       # Parallel workers
  template:
    spec:
      containers:
      - name: worker
        image: worker:latest
        env:
        - name: QUEUE_URL
          value: "redis://queue:6379"
      restartPolicy: Never
```

### Job Patterns

**Single Job:**
```yaml
spec:
  completions: 1
  parallelism: 1
```

**Parallel Jobs with Fixed Completion:**
```yaml
spec:
  completions: 10
  parallelism: 3
```

**Parallel Jobs with Work Queue:**
```yaml
spec:
  parallelism: 5
  # No completions specified
```

### Job Configuration

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: advanced-job
spec:
  completions: 5
  parallelism: 2
  backoffLimit: 3              # Max retries
  activeDeadlineSeconds: 600   # Max runtime
  ttlSecondsAfterFinished: 100 # Auto-cleanup
  
  template:
    spec:
      containers:
      - name: worker
        image: worker:latest
      restartPolicy: OnFailure
```

### Job Commands

```bash
# Create job
kubectl create job test --image=busybox -- echo "Hello"

# View jobs
kubectl get jobs

# View job pods
kubectl get pods --selector=job-name=pi-calculation

# View job logs
kubectl logs job/pi-calculation

# Delete job
kubectl delete job pi-calculation

# Delete job and pods
kubectl delete job pi-calculation --cascade=foreground
```

## CronJobs

Scheduled jobs using cron syntax.

### Basic CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"  # Every day at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
            command:
            - /bin/sh
            - -c
            - backup-database.sh
          restartPolicy: OnFailure
```

### CronJob Configuration

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: advanced-cronjob
spec:
  schedule: "*/5 * * * *"           # Every 5 minutes
  concurrencyPolicy: Forbid         # Allow, Forbid, Replace
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  startingDeadlineSeconds: 200
  suspend: false
  
  jobTemplate:
    spec:
      backoffLimit: 2
      activeDeadlineSeconds: 300
      template:
        spec:
          containers:
          - name: task
            image: task-runner:latest
          restartPolicy: OnFailure
```

### Cron Schedule Syntax

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# * * * * *
```

**Examples:**
```yaml
# Every hour
schedule: "0 * * * *"

# Every day at midnight
schedule: "0 0 * * *"

# Every Monday at 9 AM
schedule: "0 9 * * 1"

# Every 15 minutes
schedule: "*/15 * * * *"

# First day of month
schedule: "0 0 1 * *"
```

### CronJob Commands

```bash
# Create CronJob
kubectl create cronjob backup --image=backup:latest --schedule="0 2 * * *" -- backup.sh

# List CronJobs
kubectl get cronjobs

# Describe CronJob
kubectl describe cronjob backup

# Suspend CronJob
kubectl patch cronjob backup -p '{"spec":{"suspend":true}}'

# Create job from CronJob manually
kubectl create job --from=cronjob/backup manual-backup

# Delete CronJob
kubectl delete cronjob backup
```

## Best Practices

### Deployments
1. Always set resource requests and limits
2. Use readiness and liveness probes
3. Set appropriate replica counts
4. Use rolling updates with proper maxSurge/maxUnavailable
5. Keep revision history for rollbacks

### StatefulSets
1. Use headless services
2. Implement proper init containers
3. Handle pod identity in application
4. Plan for storage requirements
5. Test scaling operations

### DaemonSets
1. Use resource limits to prevent node exhaustion
2. Add appropriate tolerations
3. Use node selectors for targeted deployment
4. Monitor resource usage
5. Plan for updates carefully

### Jobs
1. Set appropriate backoffLimit
2. Use activeDeadlineSeconds for timeouts
3. Clean up completed jobs (TTL)
4. Handle failures gracefully
5. Use appropriate restart policies

### CronJobs
1. Set concurrencyPolicy appropriately
2. Limit job history
3. Set startingDeadlineSeconds
4. Monitor job execution
5. Handle timezone considerations

## References

- [Workloads](https://kubernetes.io/docs/concepts/workloads/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
