# Kubernetes Networking Overview

Kubernetes networking enables communication between pods, services, and external clients.

## Kubernetes Networking Model

### Core Principles

1. **Every pod gets its own IP address**
2. **Pods can communicate with all other pods without NAT**
3. **Agents on a node can communicate with all pods on that node**
4. **Pods see themselves with the same IP that others see them with**

```
┌─────────────────────────────────────────────────────────┐
│                    CLUSTER NETWORK                      │
│                                                         │
│  ┌──────────────┐              ┌──────────────┐       │
│  │   NODE 1     │              │   NODE 2     │       │
│  │              │              │              │       │
│  │  ┌────────┐  │              │  ┌────────┐  │       │
│  │  │Pod A   │  │              │  │Pod C   │  │       │
│  │  │10.1.1.1│◄─┼──────────────┼─►│10.1.2.1│  │       │
│  │  └────────┘  │              │  └────────┘  │       │
│  │              │              │              │       │
│  │  ┌────────┐  │              │  ┌────────┐  │       │
│  │  │Pod B   │  │              │  │Pod D   │  │       │
│  │  │10.1.1.2│◄─┼──────────────┼─►│10.1.2.2│  │       │
│  │  └────────┘  │              │  └────────┘  │       │
│  └──────────────┘              └──────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Network Types

### 1. Pod-to-Pod Communication

Direct communication using pod IPs:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
spec:
  containers:
  - name: client
    image: busybox
    command: ['sh', '-c', 'wget -O- http://10.1.2.1:8080']
```

**Characteristics:**
- Flat network space
- No NAT required
- Direct IP communication
- Implemented by CNI plugins

### 2. Pod-to-Service Communication

Using service abstraction:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
```

**Access Methods:**
- ClusterIP (internal)
- DNS name resolution
- Environment variables
- Service discovery

### 3. External-to-Service Communication

Exposing services externally:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 8080
```

**Methods:**
- NodePort
- LoadBalancer
- Ingress
- ExternalName

## Network Namespaces

### Container Network Namespace

```
┌─────────────────────────────────────┐
│              POD                    │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Network Namespace          │  │
│  │                              │  │
│  │  eth0: 10.1.1.1              │  │
│  │  lo: 127.0.0.1               │  │
│  │                              │  │
│  │  ┌──────────┐  ┌──────────┐ │  │
│  │  │Container1│  │Container2│ │  │
│  │  │localhost │  │localhost │ │  │
│  │  └──────────┘  └──────────┘ │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Shared in Pod:**
- Network interface
- IP address
- Port space
- Routing table

## CNI (Container Network Interface)

### What is CNI?

Standard interface between container runtime and network plugins.

```
┌──────────────┐
│   Kubelet    │
└──────┬───────┘
       │
       │ CNI API
       │
┌──────▼───────┐
│  CNI Plugin  │
└──────┬───────┘
       │
       │ Configure
       │
┌──────▼───────┐
│   Network    │
└──────────────┘
```

### Popular CNI Plugins

**Calico:**
```bash
# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check Calico status
kubectl get pods -n kube-system -l k8s-app=calico-node
```

**Flannel:**
```bash
# Install Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

**Weave Net:**
```bash
# Install Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

**Cilium:**
```bash
# Install Cilium
helm install cilium cilium/cilium --namespace kube-system
```

### CNI Plugin Comparison

| Plugin | Network Model | Encryption | Network Policy | Performance |
|--------|--------------|------------|----------------|-------------|
| Calico | L3 BGP | Yes | Yes | High |
| Flannel | Overlay (VXLAN) | No | No | Medium |
| Weave | Overlay | Yes | Yes | Medium |
| Cilium | eBPF | Yes | Yes | Very High |

## DNS in Kubernetes

### CoreDNS

Default DNS server in Kubernetes:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```

### DNS Records

**Service DNS:**
```
<service-name>.<namespace>.svc.cluster.local
```

**Pod DNS:**
```
<pod-ip-with-dashes>.<namespace>.pod.cluster.local
```

**Headless Service Pod DNS:**
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

### DNS Resolution Examples

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
```

```bash
# Test DNS resolution
kubectl exec -it dns-test -- nslookup kubernetes.default

# Test service DNS
kubectl exec -it dns-test -- nslookup my-service.default.svc.cluster.local

# Test external DNS
kubectl exec -it dns-test -- nslookup google.com
```

### Custom DNS Configuration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns
spec:
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
    - 8.8.8.8
    - 8.8.4.4
    searches:
    - my-namespace.svc.cluster.local
    - svc.cluster.local
    - cluster.local
    options:
    - name: ndots
      value: "2"
  containers:
  - name: app
    image: nginx
```

**DNS Policies:**
- **Default**: Inherit from node
- **ClusterFirst**: Use cluster DNS (default for pods)
- **ClusterFirstWithHostNet**: For pods with hostNetwork
- **None**: Custom DNS configuration

## Network Plugins Architecture

### Overlay Network (VXLAN)

```
┌─────────────────────────────────────────────────────┐
│                  Physical Network                   │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   Node 1     │              │   Node 2     │   │
│  │  10.0.1.10   │              │  10.0.1.11   │   │
│  │              │              │              │   │
│  │  ┌────────┐  │   VXLAN      │  ┌────────┐  │   │
│  │  │VTEP    │◄─┼──Tunnel──────┼─►│VTEP    │  │   │
│  │  └───┬────┘  │              │  └───┬────┘  │   │
│  │      │       │              │      │       │   │
│  │  ┌───▼────┐  │              │  ┌───▼────┐  │   │
│  │  │Pod     │  │              │  │Pod     │  │   │
│  │  │10.1.1.1│  │              │  │10.1.2.1│  │   │
│  │  └────────┘  │              │  └────────┘  │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

### BGP Network (Calico)

```
┌─────────────────────────────────────────────────────┐
│                  Physical Network                   │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   Node 1     │              │   Node 2     │   │
│  │              │              │              │   │
│  │  ┌────────┐  │   BGP        │  ┌────────┐  │   │
│  │  │BGP     │◄─┼──Peering─────┼─►│BGP     │  │   │
│  │  │Speaker │  │              │  │Speaker │  │   │
│  │  └───┬────┘  │              │  └───┬────┘  │   │
│  │      │       │              │      │       │   │
│  │  ┌───▼────┐  │              │  ┌───▼────┐  │   │
│  │  │Pod     │  │              │  │Pod     │  │   │
│  │  │10.1.1.1│  │              │  │10.1.2.1│  │   │
│  │  └────────┘  │              │  └────────┘  │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Network Troubleshooting

### Debug Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'sleep 3600']
```

### Common Commands

```bash
# Test connectivity
kubectl exec -it netshoot -- ping 10.1.1.1

# Test DNS
kubectl exec -it netshoot -- nslookup kubernetes.default

# Test service connectivity
kubectl exec -it netshoot -- curl http://my-service

# Check routes
kubectl exec -it netshoot -- ip route

# Check interfaces
kubectl exec -it netshoot -- ip addr

# Trace route
kubectl exec -it netshoot -- traceroute 10.1.1.1

# Port scan
kubectl exec -it netshoot -- nc -zv my-service 80

# DNS lookup
kubectl exec -it netshoot -- dig my-service.default.svc.cluster.local
```

### Network Debugging

```bash
# Check CNI plugin
kubectl get pods -n kube-system | grep -E 'calico|flannel|weave|cilium'

# Check kube-proxy
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# View kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Check iptables rules
kubectl exec -it <kube-proxy-pod> -n kube-system -- iptables-save

# Check service endpoints
kubectl get endpoints

# Describe service
kubectl describe service my-service
```

## Network Performance

### Bandwidth Testing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: iperf-server
spec:
  containers:
  - name: iperf
    image: networkstatic/iperf3
    command: ['iperf3', '-s']
    ports:
    - containerPort: 5201
---
apiVersion: v1
kind: Pod
metadata:
  name: iperf-client
spec:
  containers:
  - name: iperf
    image: networkstatic/iperf3
    command: ['sh', '-c', 'sleep 3600']
```

```bash
# Run bandwidth test
kubectl exec -it iperf-client -- iperf3 -c <iperf-server-ip>
```

### Latency Testing

```bash
# Ping test
kubectl exec -it netshoot -- ping -c 10 <target-ip>

# HTTP latency
kubectl exec -it netshoot -- curl -w "@curl-format.txt" -o /dev/null -s http://my-service
```

## Best Practices

1. **Choose Appropriate CNI Plugin**
   - Consider network requirements
   - Evaluate performance needs
   - Check feature requirements (encryption, network policies)

2. **Network Segmentation**
   - Use namespaces
   - Implement network policies
   - Separate environments

3. **DNS Configuration**
   - Optimize DNS caching
   - Monitor DNS performance
   - Use appropriate ndots value

4. **Monitoring**
   - Monitor network traffic
   - Track latency metrics
   - Alert on connectivity issues

5. **Security**
   - Enable network policies
   - Use encryption where needed
   - Limit external access

## References

- [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
