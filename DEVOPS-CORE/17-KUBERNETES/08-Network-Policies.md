# Kubernetes Network Policies

Network Policies control traffic flow between pods and network endpoints.

## Network Policy Overview

```
┌──────────────────────────────────────────────────┐
│           Default: All traffic allowed           │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│      With Network Policy: Deny by default        │
│                                                  │
│  ┌────────┐         ┌────────┐                  │
│  │Frontend│────X────│Database│                  │
│  └────────┘         └────────┘                  │
│                          │                       │
│                          ✓                       │
│                     ┌────────┐                   │
│                     │Backend │                   │
│                     └────────┘                   │
└──────────────────────────────────────────────────┘
```

**Key Concepts:**
- Pod-level firewall rules
- Namespace-scoped
- Requires CNI plugin support (Calico, Cilium, Weave)
- Additive (multiple policies combine)

## Basic Network Policy

### Deny All Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: default
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress
```

### Deny All Egress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### Allow All Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - {}
```

## Ingress Rules

### Allow from Specific Pods

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Allow from Specific Namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-namespace
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: production
    ports:
    - protocol: TCP
      port: 80
```

### Allow from IP Block

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-ip-range
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 192.168.1.0/24
        except:
        - 192.168.1.5/32
    ports:
    - protocol: TCP
      port: 80
```

### Multiple Ingress Rules

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: multi-ingress
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  # Allow from backend pods
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  
  # Allow from monitoring namespace
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
```

## Egress Rules

### Allow to Specific Pods

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-to-backend
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8080
```

### Allow DNS

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
```

### Allow External Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Egress
  egress:
  # Allow to external IPs
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32  # Block metadata service
    ports:
    - protocol: TCP
      port: 443
```

## Combined Ingress and Egress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow from frontend
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  
  egress:
  # Allow to database
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  
  # Allow external HTTPS
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
```

## Common Patterns

### Three-Tier Application

```yaml
# Frontend Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 8080
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
---
# Backend Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
---
# Database Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Namespace Isolation

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Only allow from same namespace
  - from:
    - podSelector: {}
  
  egress:
  # Only allow to same namespace
  - to:
    - podSelector: {}
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

### Allow Monitoring

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
spec:
  podSelector:
    matchLabels:
      monitoring: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
      podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9090
```

## Selector Combinations

### AND Logic (within selector)

```yaml
spec:
  podSelector:
    matchLabels:
      app: backend
      environment: production
```

### OR Logic (multiple from/to)

```yaml
spec:
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    - podSelector:
        matchLabels:
          app: admin
```

### Namespace AND Pod Selector

```yaml
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: production
      podSelector:
        matchLabels:
          app: frontend
```

## Testing Network Policies

### Test Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  labels:
    app: test
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'sleep 3600']
```

### Test Commands

```bash
# Test connectivity
kubectl exec -it test-pod -- curl http://backend-service:8080

# Test DNS
kubectl exec -it test-pod -- nslookup backend-service

# Test specific port
kubectl exec -it test-pod -- nc -zv backend-service 8080

# Test from specific namespace
kubectl exec -it test-pod -n namespace1 -- curl http://service.namespace2
```

## Debugging Network Policies

```bash
# List network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe networkpolicy <policy-name>

# Get policy YAML
kubectl get networkpolicy <policy-name> -o yaml

# Check pod labels
kubectl get pods --show-labels

# Check namespace labels
kubectl get namespaces --show-labels

# View CNI logs (Calico example)
kubectl logs -n kube-system -l k8s-app=calico-node
```

## CNI-Specific Features

### Calico Global Network Policy

```yaml
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-all-non-whitelisted
spec:
  selector: all()
  types:
  - Ingress
  - Egress
  egress:
  # Allow DNS
  - action: Allow
    protocol: UDP
    destination:
      ports:
      - 53
```

### Cilium Network Policy

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: l7-policy
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/api/.*"
```

## Best Practices

1. **Default Deny**
   - Start with deny-all policy
   - Explicitly allow required traffic
   - Principle of least privilege

2. **Label Strategy**
   - Consistent labeling scheme
   - Use meaningful labels
   - Document label usage

3. **DNS Access**
   - Always allow DNS egress
   - Specify kube-dns/CoreDNS
   - Use UDP port 53

4. **Testing**
   - Test policies in dev first
   - Use network policy simulator
   - Monitor blocked traffic

5. **Documentation**
   - Document policy intent
   - Use annotations
   - Maintain policy inventory

6. **Monitoring**
   - Monitor policy violations
   - Track blocked connections
   - Alert on unexpected traffic

## Common Pitfalls

1. **Forgetting DNS**
   ```yaml
   # Always include DNS egress
   egress:
   - to:
     - namespaceSelector:
         matchLabels:
           name: kube-system
     ports:
     - protocol: UDP
       port: 53
   ```

2. **Empty podSelector**
   ```yaml
   # {} means all pods in namespace
   podSelector: {}
   
   # Specific pods only
   podSelector:
     matchLabels:
       app: myapp
   ```

3. **Policy Types**
   ```yaml
   # Must specify policyTypes
   policyTypes:
   - Ingress
   - Egress
   ```

## Network Policy Tools

```bash
# Calico policy viewer
calicoctl get networkpolicy -o yaml

# Cilium policy viewer
cilium policy get

# Network policy simulator
kubectl run --rm -it netpol-test --image=nicolaka/netshoot --restart=Never -- bash
```

## References

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Calico Network Policy](https://docs.projectcalico.org/security/calico-network-policy)
- [Cilium Network Policy](https://docs.cilium.io/en/stable/policy/)
