# Kubernetes RBAC (Role-Based Access Control)

RBAC regulates access to Kubernetes resources based on roles assigned to users.

## RBAC Overview

```
┌──────────────────────────────────────────────────┐
│              RBAC Components                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  Subject  ──────►  RoleBinding  ──────►  Role   │
│  (Who)            (Assignment)         (What)   │
│                                                  │
│  • User                                          │
│  • Group                                         │
│  • ServiceAccount                                │
└──────────────────────────────────────────────────┘
```

## Core Concepts

### Subjects (Who)
- **User**: Human users
- **Group**: Collection of users
- **ServiceAccount**: Pod identity

### Resources (What)
- Pods, Services, Deployments, etc.
- API groups and versions
- Specific resource names

### Verbs (Actions)
- get, list, watch
- create, update, patch, delete
- deletecollection

## Role vs ClusterRole

### Role (Namespace-scoped)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

### ClusterRole (Cluster-wide)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

## RoleBinding vs ClusterRoleBinding

### RoleBinding

Grants permissions within a namespace:

```yaml
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

### ClusterRoleBinding

Grants cluster-wide permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-global
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Common Role Examples

### Read-Only Access

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-only
  namespace: default
rules:
- apiGroups: ["", "apps", "batch"]
  resources:
  - pods
  - deployments
  - services
  - jobs
  - cronjobs
  verbs: ["get", "list", "watch"]
```

### Developer Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: development
rules:
# Pods
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch", "create", "delete"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]

# Deployments
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Services
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# ConfigMaps and Secrets
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

### Admin Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-admin
  namespace: production
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

### CI/CD Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cicd-deployer
  namespace: production
rules:
# Deployments
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]

# Pods (for logs)
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]

# Services
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "create", "update"]

# ConfigMaps
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "create", "update"]
```

## ServiceAccount

### Create ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
```

### Use ServiceAccount in Pod

```yaml
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

### ServiceAccount with Role

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: pod-reader-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Resource Names

Restrict access to specific resources:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: specific-pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  resourceNames: ["my-pod", "another-pod"]
  verbs: ["get", "delete"]
```

## Aggregated ClusterRoles

Combine multiple ClusterRoles:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
rules:
- apiGroups: [""]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-aggregate
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: []  # Automatically filled
```

## Default ClusterRoles

Kubernetes provides default roles:

- **cluster-admin**: Full cluster access
- **admin**: Full namespace access
- **edit**: Read/write namespace access
- **view**: Read-only namespace access

```bash
# View default roles
kubectl get clusterroles

# Describe default role
kubectl describe clusterrole view
```

### Using Default Roles

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-view
  namespace: development
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

## Multi-Namespace Access

Grant access to multiple namespaces:

```yaml
# RoleBinding in namespace1
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: namespace1
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
---
# RoleBinding in namespace2
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: namespace2
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Group Bindings

Bind roles to groups:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developers
  namespace: development
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

## Testing RBAC

### Check Permissions

```bash
# Check if you can perform action
kubectl auth can-i create deployments

# Check for specific namespace
kubectl auth can-i create deployments --namespace=production

# Check as another user
kubectl auth can-i create deployments --as=jane

# Check as service account
kubectl auth can-i create deployments \
  --as=system:serviceaccount:default:app-sa

# List all permissions
kubectl auth can-i --list

# List permissions in namespace
kubectl auth can-i --list --namespace=production
```

### Impersonate User

```bash
# Run command as user
kubectl get pods --as=jane

# Run as service account
kubectl get pods --as=system:serviceaccount:default:app-sa

# Run as group
kubectl get pods --as=jane --as-group=developers
```

## RBAC Commands

```bash
# List roles
kubectl get roles
kubectl get clusterroles

# List role bindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Describe role
kubectl describe role pod-reader

# Describe role binding
kubectl describe rolebinding read-pods

# Create role
kubectl create role pod-reader --verb=get,list --resource=pods

# Create role binding
kubectl create rolebinding read-pods \
  --role=pod-reader \
  --user=jane

# Create cluster role
kubectl create clusterrole pod-reader --verb=get,list --resource=pods

# Create cluster role binding
kubectl create clusterrolebinding read-pods-global \
  --clusterrole=pod-reader \
  --user=jane

# Delete role
kubectl delete role pod-reader

# Delete role binding
kubectl delete rolebinding read-pods
```

## Common Patterns

### Read-Only User

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-user
subjects:
- kind: User
  name: readonly
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

### Namespace Admin

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: namespace-admin
  namespace: production
subjects:
- kind: User
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
```

### CI/CD Pipeline

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cicd-sa
  namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cicd-role
  namespace: production
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cicd-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: cicd-sa
  namespace: production
roleRef:
  kind: Role
  name: cicd-role
  apiGroup: rbac.authorization.k8s.io
```

## Best Practices

1. **Principle of Least Privilege**
   - Grant minimum required permissions
   - Use specific verbs and resources
   - Avoid wildcard permissions

2. **Use ServiceAccounts**
   - Don't use default service account
   - Create dedicated service accounts
   - One per application/component

3. **Namespace Isolation**
   - Use Roles instead of ClusterRoles
   - Separate environments by namespace
   - Limit cross-namespace access

4. **Regular Audits**
   - Review permissions regularly
   - Remove unused roles
   - Monitor RBAC changes

5. **Documentation**
   - Document role purposes
   - Maintain role inventory
   - Use descriptive names

6. **Testing**
   - Test permissions before applying
   - Use `kubectl auth can-i`
   - Verify in non-production first

## Security Considerations

1. **Avoid cluster-admin**
   - Don't use for regular operations
   - Create specific roles instead
   - Use only for cluster management

2. **Restrict Secret Access**
   ```yaml
   rules:
   - apiGroups: [""]
     resources: ["secrets"]
     verbs: ["get"]
     resourceNames: ["specific-secret"]
   ```

3. **Limit Exec Access**
   ```yaml
   rules:
   - apiGroups: [""]
     resources: ["pods/exec"]
     verbs: ["create"]
     resourceNames: ["debug-pod"]
   ```

4. **Audit Logging**
   - Enable audit logs
   - Monitor RBAC changes
   - Alert on suspicious activity

## Troubleshooting

```bash
# Check current user
kubectl auth whoami

# Check permissions
kubectl auth can-i create pods

# View role details
kubectl describe role pod-reader

# View binding details
kubectl describe rolebinding read-pods

# Check service account token
kubectl get secret -n default | grep app-sa

# View service account
kubectl describe sa app-sa

# Check pod service account
kubectl get pod pod-name -o jsonpath='{.spec.serviceAccountName}'
```

## References

- [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
