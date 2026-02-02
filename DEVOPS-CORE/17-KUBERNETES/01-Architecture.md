# Kubernetes Architecture

Kubernetes follows a master-worker architecture with a control plane managing worker nodes.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      CONTROL PLANE                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  API Server  │  │   Scheduler  │  │  Controller  │     │
│  │              │  │              │  │   Manager    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │     etcd     │  │ Cloud Ctrl   │                        │
│  │  (Key-Value) │  │   Manager    │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌──────▼─────────┐
│   WORKER NODE  │  │   WORKER NODE  │  │  WORKER NODE   │
│                │  │                │  │                │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │   Kubelet  │ │  │ │   Kubelet  │ │  │ │   Kubelet  │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │ Kube-Proxy │ │  │ │ Kube-Proxy │ │  │ │ Kube-Proxy │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │ Container  │ │  │ │ Container  │ │  │ │ Container  │ │
│ │  Runtime   │ │  │ │  Runtime   │ │  │ │  Runtime   │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│                │  │                │  │                │
│  ┌──────────┐  │  │  ┌──────────┐  │  │  ┌──────────┐  │
│  │   Pods   │  │  │  │   Pods   │  │  │  │   Pods   │  │
│  └──────────┘  │  │  └──────────┘  │  │  └──────────┘  │
└────────────────┘  └────────────────┘  └────────────────┘
```

## Control Plane Components

### 1. API Server (kube-apiserver)

The front-end for the Kubernetes control plane. All communications go through the API server.

**Responsibilities:**
- Exposes Kubernetes API
- Validates and processes REST requests
- Updates etcd
- Authentication and authorization

**Key Features:**
- RESTful interface
- Horizontal scaling support
- Admission controllers
- API versioning

```bash
# Check API server status
kubectl get --raw /healthz

# View API resources
kubectl api-resources

# View API versions
kubectl api-versions
```

### 2. etcd

Distributed key-value store that holds all cluster data.

**Responsibilities:**
- Store cluster state
- Store configuration data
- Service discovery data
- Distributed locking

**Key Features:**
- Consistent and highly-available
- Watch mechanism for changes
- Raft consensus algorithm
- Backup and restore capabilities

```bash
# Backup etcd (on control plane node)
ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Restore etcd
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db
```

### 3. Scheduler (kube-scheduler)

Assigns pods to nodes based on resource requirements and constraints.

**Responsibilities:**
- Watch for newly created pods
- Select optimal node for pod placement
- Consider resource requirements
- Apply scheduling policies

**Scheduling Factors:**
- Resource requirements (CPU, memory)
- Hardware/software constraints
- Affinity/anti-affinity rules
- Data locality
- Taints and tolerations

```yaml
# Pod with node selector
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
```

### 4. Controller Manager (kube-controller-manager)

Runs controller processes that regulate cluster state.

**Built-in Controllers:**
- **Node Controller**: Monitors node health
- **Replication Controller**: Maintains correct number of pods
- **Endpoints Controller**: Populates endpoint objects
- **Service Account Controller**: Creates default accounts
- **Namespace Controller**: Manages namespace lifecycle

```bash
# View controller manager status
kubectl get componentstatuses
```

### 5. Cloud Controller Manager

Integrates with cloud provider APIs.

**Cloud-Specific Controllers:**
- Node controller (cloud provider)
- Route controller
- Service controller (load balancers)
- Volume controller

## Worker Node Components

### 1. Kubelet

Primary node agent that runs on each worker node.

**Responsibilities:**
- Register node with API server
- Watch for pod assignments
- Manage pod lifecycle
- Report node and pod status
- Execute liveness/readiness probes

**Key Features:**
- Pod lifecycle management
- Volume mounting
- Container health monitoring
- Resource monitoring

```bash
# Check kubelet status
systemctl status kubelet

# View kubelet logs
journalctl -u kubelet -f
```

### 2. Kube-Proxy

Network proxy that maintains network rules on nodes.

**Responsibilities:**
- Implement service abstraction
- Maintain network rules
- Handle connection forwarding
- Load balancing

**Proxy Modes:**
- **iptables**: Default mode, uses iptables rules
- **IPVS**: High-performance load balancing
- **userspace**: Legacy mode

```bash
# Check kube-proxy mode
kubectl logs -n kube-system kube-proxy-xxxxx | grep "Using"

# View iptables rules
iptables -t nat -L -n -v
```

### 3. Container Runtime

Software responsible for running containers.

**Supported Runtimes:**
- **containerd**: Industry-standard runtime
- **CRI-O**: Lightweight runtime
- **Docker**: Via dockershim (deprecated)

**Container Runtime Interface (CRI):**
- Standardized plugin interface
- Runtime agnostic
- Image management
- Container lifecycle

```bash
# Check container runtime
kubectl get nodes -o wide

# List containers (containerd)
crictl ps

# List images
crictl images
```

## Add-ons

### CoreDNS

Provides DNS-based service discovery.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
# Accessible via: my-service.default.svc.cluster.local
```

### CNI (Container Network Interface)

Provides networking capabilities.

**Popular CNI Plugins:**
- Calico
- Flannel
- Weave Net
- Cilium

### Metrics Server

Collects resource metrics from kubelets.

```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View metrics
kubectl top nodes
kubectl top pods
```

## Communication Flow

### Pod Creation Flow

```
1. kubectl → API Server
2. API Server → etcd (store pod spec)
3. API Server → Scheduler (watch for unscheduled pods)
4. Scheduler → API Server (assign node)
5. API Server → Kubelet (on assigned node)
6. Kubelet → Container Runtime (create container)
7. Kubelet → API Server (update pod status)
```

### Service Request Flow

```
Client → Service (ClusterIP)
       → kube-proxy (iptables/IPVS rules)
       → Pod (backend)
```

## High Availability Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    LOAD BALANCER                        │
│                  (API Server Traffic)                   │
└────────────┬────────────────────────┬───────────────────┘
             │                        │
    ┌────────▼────────┐      ┌────────▼────────┐
    │ CONTROL PLANE 1 │      │ CONTROL PLANE 2 │
    │                 │      │                 │
    │  API Server     │      │  API Server     │
    │  Scheduler      │      │  Scheduler      │
    │  Controller Mgr │      │  Controller Mgr │
    └────────┬────────┘      └────────┬────────┘
             │                        │
             └────────┬───────────────┘
                      │
              ┌───────▼────────┐
              │  etcd Cluster  │
              │  (3+ members)  │
              └────────────────┘
```

## Best Practices

1. **High Availability**
   - Run multiple control plane nodes (odd number)
   - Use external etcd cluster
   - Load balance API server traffic

2. **Security**
   - Enable RBAC
   - Use network policies
   - Secure etcd with TLS
   - Regular security updates

3. **Monitoring**
   - Monitor control plane components
   - Track resource usage
   - Set up alerts
   - Log aggregation

4. **Backup**
   - Regular etcd backups
   - Backup cluster configuration
   - Test restore procedures

## Troubleshooting

```bash
# Check component health
kubectl get componentstatuses

# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check control plane pods
kubectl get pods -n kube-system

# View logs
kubectl logs -n kube-system <pod-name>

# Check API server
kubectl cluster-info

# Verify etcd health
kubectl get --raw /healthz/etcd
```

## References

- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Cluster Architecture](https://kubernetes.io/docs/concepts/architecture/)
