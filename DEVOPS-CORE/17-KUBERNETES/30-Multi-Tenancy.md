# Multi-Tenancy in Kubernetes

Strategies for sharing Kubernetes clusters across multiple teams or customers.

## Multi-Tenancy Models

```
┌────────────────────────────────────────────────┐
│         Multi-Tenancy Approaches               │
├────────────────────────────────────────────────┤
│  1. Namespace-based (Soft Multi-Tenancy)       │
│  2. Cluster-based (Hard Multi-Tenancy)         │
│  3. Virtual Clusters                           │
└────────────────────────────────────────────────┘
```

## Namespace Isolation

### Create Tenant Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
  labels:
    tenant: tenant-a
    environment: production
```

### Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-a-quota
  namespace: tenant-a
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "50"
    services: "10"
    persistentvolumeclaims: "10"
```

### Limit Ranges

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-a-limits
  namespace: tenant-a
spec:
  limits:
  - max:
      cpu: "2"
      memory: 4Gi
    min:
      cpu: 100m
      memory: 128Mi
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 250m
      memory: 256Mi
    type: Container
```

## Network Isolation

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-isolation
  namespace: tenant-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

## RBAC for Tenants

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-admin
  namespace: tenant-a
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-a-admin
  namespace: tenant-a
subjects:
- kind: Group
  name: tenant-a-admins
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: tenant-admin
  apiGroup: rbac.authorization.k8s.io
```

## Pod Security

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Virtual Clusters (vcluster)

```bash
# Install vcluster
helm repo add loft-sh https://charts.loft.sh
helm install vcluster loft-sh/vcluster \
  --namespace tenant-a \
  --create-namespace

# Connect to vcluster
vcluster connect vcluster -n tenant-a
```

## Best Practices

1. **Use Namespaces**
2. **Enforce Resource Quotas**
3. **Network Isolation**
4. **RBAC Policies**
5. **Pod Security Standards**
6. **Monitoring Per Tenant**

## References

- [Multi-Tenancy](https://kubernetes.io/docs/concepts/security/multi-tenancy/)
- [vcluster](https://www.vcluster.com/)
