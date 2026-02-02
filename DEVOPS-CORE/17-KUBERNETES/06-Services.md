# Kubernetes Services

Services provide stable network endpoints for accessing pods.

## Service Overview

A Service is an abstraction that defines a logical set of Pods and a policy to access them.

```
┌────────────────────────────────────────────────┐
│              SERVICE                           │
│         (ClusterIP: 10.96.0.1)                │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │         Load Balancer                    │ │
│  └──────────┬───────────┬───────────────────┘ │
└─────────────┼───────────┼──────────────────────┘
              │           │
     ┌────────▼──┐   ┌────▼────────┐   ┌──────────┐
     │  Pod 1    │   │   Pod 2     │   │  Pod 3   │
     │ 10.1.1.1  │   │  10.1.1.2   │   │ 10.1.1.3 │
     │ app=web   │   │  app=web    │   │ app=web  │
     └───────────┘   └─────────────┘   └──────────┘
```

## Service Types

### 1. ClusterIP (Default)

Exposes service on cluster-internal IP.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - protocol: TCP
    port: 80          # Service port
    targetPort: 8080  # Container port
```

**Characteristics:**
- Only accessible within cluster
- Default service type
- Gets a stable ClusterIP
- DNS name: `<service-name>.<namespace>.svc.cluster.local`

```bash
# Access from within cluster
curl http://backend-service.default.svc.cluster.local
```

### 2. NodePort

Exposes service on each node's IP at a static port.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    nodePort: 30080  # Optional: 30000-32767
```

**Access Pattern:**
```
External Client
      │
      ▼
<NodeIP>:30080
      │
      ▼
Service (ClusterIP)
      │
      ▼
Pod:8080
```

```bash
# Access from outside cluster
curl http://<node-ip>:30080
```

### 3. LoadBalancer

Exposes service externally using cloud provider's load balancer.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  loadBalancerIP: 203.0.113.10  # Optional
```

**Cloud Provider Integration:**
```
External Client
      │
      ▼
Cloud Load Balancer (External IP)
      │
      ▼
NodePort (on all nodes)
      │
      ▼
Service (ClusterIP)
      │
      ▼
Pods
```

```bash
# Get external IP
kubectl get service loadbalancer-service

# Access service
curl http://<external-ip>
```

### 4. ExternalName

Maps service to external DNS name.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-database
spec:
  type: ExternalName
  externalName: database.example.com
```

**Use Case:**
```yaml
# Application connects to service
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: myapp
    env:
    - name: DB_HOST
      value: external-database.default.svc.cluster.local
```

## Service Definition

### Complete Service Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: default
  labels:
    app: myapp
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: myapp
    tier: frontend
  
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
  
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  
  externalTrafficPolicy: Local
  healthCheckNodePort: 30000
```

## Service Discovery

### DNS-Based Discovery

```yaml
# Service in same namespace
http://my-service

# Service in different namespace
http://my-service.other-namespace

# Fully qualified
http://my-service.other-namespace.svc.cluster.local
```

### Environment Variables

Kubernetes automatically creates environment variables:

```bash
# For service named "redis-master"
REDIS_MASTER_SERVICE_HOST=10.96.0.1
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_PORT=tcp://10.96.0.1:6379
REDIS_MASTER_PORT_6379_TCP=tcp://10.96.0.1:6379
REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379
REDIS_MASTER_PORT_6379_TCP_ADDR=10.96.0.1
```

## Endpoints

Services route traffic to endpoints (pod IPs).

```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
- addresses:
  - ip: 10.1.1.1
  - ip: 10.1.1.2
  ports:
  - port: 8080
```

```bash
# View endpoints
kubectl get endpoints my-service

# Describe endpoints
kubectl describe endpoints my-service
```

### EndpointSlices

More scalable alternative to Endpoints:

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-abc
  labels:
    kubernetes.io/service-name: my-service
addressType: IPv4
ports:
- name: http
  protocol: TCP
  port: 8080
endpoints:
- addresses:
  - "10.1.1.1"
  conditions:
    ready: true
  hostname: pod-1
  nodeName: node-1
```

## Headless Services

Service without ClusterIP for direct pod access.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-service
spec:
  clusterIP: None  # Headless
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

**DNS Returns:**
- Pod IPs directly (not service IP)
- Useful for StatefulSets
- Client-side load balancing

```bash
# DNS lookup returns all pod IPs
nslookup headless-service.default.svc.cluster.local
```

## Service Without Selector

For external services or custom endpoints:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-service
subsets:
- addresses:
  - ip: 192.168.1.100
  - ip: 192.168.1.101
  ports:
  - port: 80
```

## Multi-Port Services

```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  selector:
    app: myapp
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
  - name: metrics
    protocol: TCP
    port: 9090
    targetPort: 9090
```

## Session Affinity

Route requests from same client to same pod:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sticky-service
spec:
  selector:
    app: myapp
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800  # 3 hours
  ports:
  - port: 80
    targetPort: 8080
```

**Options:**
- **None**: Default, random distribution
- **ClientIP**: Based on client IP

## External Traffic Policy

Control how external traffic is routed:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local  # or Cluster (default)
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

**Cluster (Default):**
- Traffic distributed to all pods
- May involve extra hop
- Source IP is masked

**Local:**
- Traffic only to pods on receiving node
- Preserves source IP
- Better performance
- May cause imbalance

## Service Topology

Route traffic based on topology:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: topology-aware-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
  topologyKeys:
  - "kubernetes.io/hostname"
  - "topology.kubernetes.io/zone"
  - "*"
```

## Service Annotations

### AWS Load Balancer

```yaml
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
```

### GCP Load Balancer

```yaml
metadata:
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
    networking.gke.io/load-balancer-type: "Internal"
```

### Azure Load Balancer

```yaml
metadata:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "subnet-name"
```

## Service Commands

```bash
# Create service
kubectl expose deployment nginx --port=80 --target-port=8080

# Create service from YAML
kubectl apply -f service.yaml

# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service my-service

# Get service details
kubectl get service my-service -o yaml

# Get endpoints
kubectl get endpoints my-service

# Delete service
kubectl delete service my-service

# Port forward to service
kubectl port-forward service/my-service 8080:80

# Get service URL (Minikube)
minikube service my-service --url
```

## Service Mesh Integration

### Istio Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: reviews
  labels:
    app: reviews
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: reviews
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 75
    - destination:
        host: reviews
        subset: v2
      weight: 25
```

## Troubleshooting Services

```bash
# Check service exists
kubectl get service my-service

# Check endpoints
kubectl get endpoints my-service

# Verify selector matches pods
kubectl get pods -l app=myapp

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup my-service

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://my-service

# Check kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# View iptables rules
kubectl exec -n kube-system <kube-proxy-pod> -- iptables-save | grep my-service
```

## Best Practices

1. **Use Appropriate Service Type**
   - ClusterIP for internal services
   - LoadBalancer for external access
   - NodePort for development/testing

2. **Health Checks**
   - Implement readiness probes
   - Pods must be ready to receive traffic
   - Unhealthy pods removed from endpoints

3. **Resource Naming**
   - Use descriptive names
   - Follow naming conventions
   - Include environment in name

4. **Port Naming**
   - Name ports in multi-port services
   - Use standard names (http, https, metrics)

5. **Session Affinity**
   - Use only when necessary
   - Consider stateless design
   - May cause load imbalance

6. **External Traffic**
   - Use Local policy to preserve source IP
   - Consider load distribution
   - Monitor node-level traffic

## References

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [DNS for Services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
