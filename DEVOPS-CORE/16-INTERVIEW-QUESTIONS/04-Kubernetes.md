# Kubernetes Interview Questions

**Comprehensive Kubernetes interview preparation**

---

## Basic Questions

### 1. What is Kubernetes?

**Answer:**
Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Key Features:**
- **Automated Deployment** - Deploy containers across cluster
- **Self-Healing** - Restart failed containers
- **Auto-Scaling** - Scale based on demand
- **Load Balancing** - Distribute traffic
- **Rolling Updates** - Zero-downtime deployments
- **Service Discovery** - Automatic DNS and load balancing

**Architecture:**
```
Control Plane (Master)
├── API Server
├── etcd
├── Scheduler
└── Controller Manager

Worker Nodes
├── kubelet
├── kube-proxy
└── Container Runtime
```

---

### 2. Explain Kubernetes architecture

**Answer:**

**Control Plane Components:**

1. **API Server** - Frontend for Kubernetes control plane
2. **etcd** - Distributed key-value store for cluster data
3. **Scheduler** - Assigns pods to nodes
4. **Controller Manager** - Runs controller processes
5. **Cloud Controller Manager** - Interacts with cloud providers

**Node Components:**

1. **kubelet** - Agent that runs on each node
2. **kube-proxy** - Network proxy on each node
3. **Container Runtime** - Docker, containerd, CRI-O

**Diagram:**
```
┌─────────────────────────────────────┐
│         Control Plane               │
│  ┌──────────┐  ┌──────────┐        │
│  │API Server│  │   etcd   │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │Scheduler │  │Controller│        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
            │
    ┌───────┴───────┐
    │               │
┌───▼────┐      ┌───▼────┐
│ Node 1 │      │ Node 2 │
│ kubelet│      │ kubelet│
│ kube-  │      │ kube-  │
│ proxy  │      │ proxy  │
│ Pods   │      │ Pods   │
└────────┘      └────────┘
```

---

### 3. What is a Pod?

**Answer:**
A Pod is the smallest deployable unit in Kubernetes, representing one or more containers that share storage and network resources.

**Characteristics:**
- Shared network namespace (same IP)
- Shared storage volumes
- Scheduled together on same node
- Ephemeral (not permanent)

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

**Multi-Container Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
  - name: sidecar
    image: logging-agent:1.0
```

---

### 4. What is a Deployment?

**Answer:**
A Deployment provides declarative updates for Pods and ReplicaSets, managing the desired state of your application.

**Features:**
- Rolling updates
- Rollback capability
- Scaling
- Self-healing

**Example:**
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

**Commands:**
```bash
# Create deployment
kubectl create deployment nginx --image=nginx

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Update image
kubectl set image deployment/nginx nginx=nginx:1.22

# Rollback
kubectl rollout undo deployment/nginx

# Check status
kubectl rollout status deployment/nginx
```

---

### 5. What is a Service?

**Answer:**
A Service is an abstraction that defines a logical set of Pods and a policy to access them, providing stable networking.

**Service Types:**

1. **ClusterIP** (default) - Internal cluster IP
2. **NodePort** - Exposes on each node's IP at a static port
3. **LoadBalancer** - Creates external load balancer
4. **ExternalName** - Maps to external DNS name

**Example:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**Service Discovery:**
```
Pod → Service Name (DNS) → Service IP → Pod IPs
```

---

### 6. What is a Namespace?

**Answer:**
Namespaces provide a way to divide cluster resources between multiple users or teams.

**Default Namespaces:**
- `default` - Default namespace for objects
- `kube-system` - Kubernetes system components
- `kube-public` - Publicly readable
- `kube-node-lease` - Node heartbeats

**Example:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

**Commands:**
```bash
# Create namespace
kubectl create namespace dev

# List namespaces
kubectl get namespaces

# Set default namespace
kubectl config set-context --current --namespace=dev

# Get resources in namespace
kubectl get pods -n dev
```

---

### 7. What is a ConfigMap?

**Answer:**
ConfigMap stores non-confidential configuration data in key-value pairs, allowing you to decouple configuration from container images.

**Example:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://db:5432"
  log_level: "info"
  config.json: |
    {
      "feature_flag": true
    }
```

**Using ConfigMap:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

---

### 8. What is a Secret?

**Answer:**
Secrets store sensitive information like passwords, tokens, and keys in base64-encoded format.

**Types:**
- `Opaque` - Arbitrary user-defined data
- `kubernetes.io/service-account-token` - Service account token
- `kubernetes.io/dockerconfigjson` - Docker registry credentials
- `kubernetes.io/tls` - TLS certificates

**Example:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: cGFzc3dvcmQ=  # base64 encoded "password"
```

**Using Secret:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

**Commands:**
```bash
# Create secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret

# Encode/decode
echo -n 'admin' | base64
echo 'YWRtaW4=' | base64 --decode
```

---

### 9. What is an Ingress?

**Answer:**
Ingress manages external access to services in a cluster, typically HTTP/HTTPS, providing load balancing, SSL termination, and name-based virtual hosting.

**Example:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
  tls:
  - hosts:
    - myapp.example.com
    secretName: tls-secret
```

**Ingress Controller:**
- NGINX Ingress Controller
- Traefik
- HAProxy
- AWS ALB Ingress Controller

---

### 10. What is a StatefulSet?

**Answer:**
StatefulSet manages stateful applications, providing guarantees about ordering and uniqueness of Pods.

**Features:**
- Stable network identities
- Stable persistent storage
- Ordered deployment and scaling
- Ordered rolling updates

**Use Cases:**
- Databases (MySQL, PostgreSQL)
- Distributed systems (Kafka, ZooKeeper)
- Applications requiring stable storage

**Example:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

**Pod Names:**
```
mysql-0
mysql-1
mysql-2
```

---

## Intermediate Questions

### 11. What is the difference between Deployment and StatefulSet?

**Answer:**

| Feature | Deployment | StatefulSet |
|---------|------------|-------------|
| **Pod Names** | Random | Ordered (app-0, app-1) |
| **Network Identity** | No stable identity | Stable hostname |
| **Storage** | Shared or ephemeral | Persistent per pod |
| **Scaling** | Parallel | Ordered |
| **Updates** | Rolling | Ordered rolling |
| **Use Case** | Stateless apps | Stateful apps |

---

### 12. What is a DaemonSet?

**Answer:**
DaemonSet ensures that all (or some) nodes run a copy of a Pod, typically used for node-level operations.

**Use Cases:**
- Log collection (Fluentd, Logstash)
- Monitoring agents (Prometheus Node Exporter)
- Network plugins (Calico, Weave)
- Storage daemons

**Example:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

---

### 13. What is a Job and CronJob?

**Answer:**

**Job** - Runs pods to completion (batch processing)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-import
spec:
  template:
    spec:
      containers:
      - name: import
        image: data-importer:1.0
      restartPolicy: Never
  backoffLimit: 4
```

**CronJob** - Runs jobs on a schedule
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:1.0
          restartPolicy: OnFailure
```

---

### 14. What are resource requests and limits?

**Answer:**
Resource requests and limits control CPU and memory allocation for containers.

**Requests** - Minimum guaranteed resources
**Limits** - Maximum allowed resources

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

**CPU Units:**
- `1` = 1 CPU core
- `100m` = 0.1 CPU core (100 millicores)

**Memory Units:**
- `Mi` = Mebibytes (1024^2 bytes)
- `Gi` = Gibibytes (1024^3 bytes)

**QoS Classes:**
1. **Guaranteed** - Requests = Limits
2. **Burstable** - Requests < Limits
3. **BestEffort** - No requests/limits

---

### 15. What is a PersistentVolume (PV) and PersistentVolumeClaim (PVC)?

**Answer:**

**PersistentVolume (PV)** - Cluster-level storage resource
**PersistentVolumeClaim (PVC)** - User request for storage

**PV Example:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data
```

**PVC Example:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

**Using PVC:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: pvc-data
```

**Access Modes:**
- `ReadWriteOnce` (RWO) - Single node read-write
- `ReadOnlyMany` (ROX) - Multiple nodes read-only
- `ReadWriteMany` (RWX) - Multiple nodes read-write

---

### 16. What is a Horizontal Pod Autoscaler (HPA)?

**Answer:**
HPA automatically scales the number of pods based on CPU utilization or custom metrics.

**Example:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-deployment
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

**Commands:**
```bash
# Create HPA
kubectl autoscale deployment app --cpu-percent=70 --min=2 --max=10

# Check HPA status
kubectl get hpa

# Describe HPA
kubectl describe hpa app
```

---

### 17. What is a Liveness Probe and Readiness Probe?

**Answer:**

**Liveness Probe** - Checks if container is alive (restart if fails)
**Readiness Probe** - Checks if container is ready to serve traffic

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
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
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      successThreshold: 1
```

**Probe Types:**
1. **HTTP GET** - HTTP request
2. **TCP Socket** - TCP connection
3. **Exec** - Command execution

---

### 18. What is a NetworkPolicy?

**Answer:**
NetworkPolicy controls traffic flow between pods and network endpoints.

**Example:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
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

**Default Policies:**
```yaml
# Deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

---

### 19. What is RBAC in Kubernetes?

**Answer:**
Role-Based Access Control (RBAC) regulates access to Kubernetes resources based on roles.

**Components:**
1. **Role** - Namespace-scoped permissions
2. **ClusterRole** - Cluster-wide permissions
3. **RoleBinding** - Binds Role to users/groups
4. **ClusterRoleBinding** - Binds ClusterRole

**Example:**
```yaml
# Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

### 20. What is a ServiceAccount?

**Answer:**
ServiceAccount provides an identity for processes running in a Pod.

**Example:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default

---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: myapp:1.0
```

**Commands:**
```bash
# Create service account
kubectl create serviceaccount app-sa

# Get service accounts
kubectl get serviceaccounts

# Describe service account
kubectl describe serviceaccount app-sa
```

---

## Advanced Questions

### 21. How does Kubernetes networking work?

**Answer:**

**Kubernetes Networking Model:**
1. All pods can communicate without NAT
2. All nodes can communicate with pods without NAT
3. Pod sees its own IP as others see it

**Components:**
- **CNI (Container Network Interface)** - Network plugin
- **kube-proxy** - Network rules on nodes
- **CoreDNS** - DNS service

**Popular CNI Plugins:**
- Calico
- Flannel
- Weave Net
- Cilium

**Network Flow:**
```
Pod A → Service → kube-proxy → iptables → Pod B
```

---

### 22. What is a Custom Resource Definition (CRD)?

**Answer:**
CRD extends Kubernetes API to create custom resources.

**Example:**
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
                type: string
              version:
                type: string
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
```

**Using Custom Resource:**
```yaml
apiVersion: example.com/v1
kind: Database
metadata:
  name: my-database
spec:
  size: "10Gi"
  version: "14.5"
```

---

### 23. What is an Operator?

**Answer:**
An Operator is a method of packaging, deploying, and managing Kubernetes applications using custom resources and controllers.

**Components:**
1. **Custom Resource** - Defines desired state
2. **Controller** - Reconciles actual state with desired state

**Popular Operators:**
- Prometheus Operator
- MySQL Operator
- Elasticsearch Operator

---

### 24. How do you troubleshoot a CrashLoopBackOff pod?

**Answer:**

**Steps:**
```bash
# 1. Check pod status
kubectl get pods

# 2. Describe pod
kubectl describe pod <pod-name>

# 3. Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# 4. Check events
kubectl get events --sort-by='.lastTimestamp'

# 5. Execute into pod (if running)
kubectl exec -it <pod-name> -- /bin/sh
```

**Common Causes:**
- Application crashes
- Missing dependencies
- Configuration errors
- Resource limits
- Liveness probe failures
- Image pull errors

---

### 25. How do you perform a rolling update?

**Answer:**

**Update Deployment:**
```bash
# Update image
kubectl set image deployment/app app=myapp:v2

# Edit deployment
kubectl edit deployment app

# Apply new manifest
kubectl apply -f deployment.yaml
```

**Monitor Rollout:**
```bash
# Watch rollout status
kubectl rollout status deployment/app

# Check rollout history
kubectl rollout history deployment/app

# Pause rollout
kubectl rollout pause deployment/app

# Resume rollout
kubectl rollout resume deployment/app
```

**Rollback:**
```bash
# Rollback to previous version
kubectl rollout undo deployment/app

# Rollback to specific revision
kubectl rollout undo deployment/app --to-revision=2
```

---

### 26. What is the difference between kubectl apply and kubectl create?

**Answer:**

**kubectl create:**
- Imperative command
- Creates new resource
- Fails if resource exists
- No change tracking

**kubectl apply:**
- Declarative command
- Creates or updates resource
- Tracks changes
- Supports three-way merge
- Recommended for production

**Example:**
```bash
# Create (fails if exists)
kubectl create -f deployment.yaml

# Apply (creates or updates)
kubectl apply -f deployment.yaml
```

---

### 27. How do you backup and restore Kubernetes cluster?

**Answer:**

**Backup etcd:**
```bash
ETCDCTL_API=3 etcdctl snapshot save backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

**Restore etcd:**
```bash
ETCDCTL_API=3 etcdctl snapshot restore backup.db \
  --data-dir=/var/lib/etcd-restore
```

**Backup Resources:**
```bash
# Backup all resources
kubectl get all --all-namespaces -o yaml > backup.yaml

# Backup specific namespace
kubectl get all -n production -o yaml > production-backup.yaml
```

**Tools:**
- Velero (formerly Heptio Ark)
- Kasten K10
- Stash

---

### 28. What is a Helm chart?

**Answer:**
Helm is a package manager for Kubernetes. A Helm chart is a collection of files that describe Kubernetes resources.

**Chart Structure:**
```
mychart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── charts/             # Dependencies
```

**Commands:**
```bash
# Install chart
helm install myapp ./mychart

# Upgrade release
helm upgrade myapp ./mychart

# Rollback release
helm rollback myapp 1

# List releases
helm list

# Uninstall release
helm uninstall myapp
```

---

### 29. How do you secure a Kubernetes cluster?

**Answer:**

**Security Best Practices:**

1. **RBAC** - Implement least privilege access
2. **Network Policies** - Restrict pod communication
3. **Pod Security Policies** - Control pod security settings
4. **Secrets Management** - Use external secret stores (Vault)
5. **Image Security** - Scan images for vulnerabilities
6. **API Server Security** - Enable authentication and authorization
7. **etcd Encryption** - Encrypt data at rest
8. **Audit Logging** - Enable audit logs
9. **Resource Quotas** - Limit resource usage
10. **Regular Updates** - Keep Kubernetes updated

**Example Security Context:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

---

### 30. What is the difference between kubectl exec and kubectl attach?

**Answer:**

**kubectl exec:**
- Executes command in container
- Creates new process
- Can run any command
- Interactive or non-interactive

```bash
kubectl exec -it pod-name -- /bin/bash
kubectl exec pod-name -- ls /app
```

**kubectl attach:**
- Attaches to running process
- Connects to main container process
- View output of main process

```bash
kubectl attach pod-name -it
```

---

## Troubleshooting Scenarios

### 31. Pod is in Pending state

**Causes:**
- Insufficient resources
- No nodes match pod requirements
- PVC not bound
- Image pull issues

**Debug:**
```bash
kubectl describe pod <pod-name>
kubectl get events
kubectl get nodes
```

---

### 32. Service not accessible

**Causes:**
- Incorrect selector
- Wrong port configuration
- Network policy blocking
- Endpoint not ready

**Debug:**
```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
kubectl get pods -l app=myapp
```

---

### 33. High memory usage

**Solutions:**
- Set resource limits
- Implement HPA
- Optimize application
- Use memory profiling

```bash
kubectl top pods
kubectl top nodes
```

---

## Related Topics
- [DevOps Fundamentals](01-DevOps-Fundamentals.md)
- [Docker Containers](03-Docker-Containers.md)
- [CI/CD Tools](05-CI-CD-Tools.md)

---

**Total Questions:** 33+  
**Difficulty:** Basic to Advanced  
**Topics Covered:** Architecture, Pods, Services, Storage, Networking, Security, Troubleshooting
