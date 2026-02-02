# Pod Security

Security configurations and best practices for Kubernetes pods.

## Pod Security Standards

Three levels of security policies:

### Privileged
Unrestricted policy (not recommended for production)

### Baseline
Minimally restrictive policy preventing known privilege escalations

### Restricted
Heavily restricted policy following current pod hardening best practices

## Pod Security Context

### Pod-Level Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    fsGroupChangePolicy: "OnRootMismatch"
    seccompProfile:
      type: RuntimeDefault
    supplementalGroups: [4000]
  containers:
  - name: app
    image: myapp:1.0
```

### Container-Level Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-security
spec:
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
```

## Security Context Fields

### runAsNonRoot

```yaml
securityContext:
  runAsNonRoot: true  # Prevents running as root
```

### runAsUser / runAsGroup

```yaml
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
```

### fsGroup

```yaml
securityContext:
  fsGroup: 2000  # Ownership of mounted volumes
```

### allowPrivilegeEscalation

```yaml
securityContext:
  allowPrivilegeEscalation: false  # Prevent privilege escalation
```

### readOnlyRootFilesystem

```yaml
securityContext:
  readOnlyRootFilesystem: true  # Immutable root filesystem
```

### privileged

```yaml
securityContext:
  privileged: false  # Never use true in production
```

## Linux Capabilities

### Drop All Capabilities

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
```

### Add Specific Capabilities

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
    add:
    - NET_BIND_SERVICE  # Bind to ports < 1024
    - CHOWN             # Change file ownership
```

### Common Capabilities

- `NET_BIND_SERVICE`: Bind to privileged ports
- `CHOWN`: Change file ownership
- `DAC_OVERRIDE`: Bypass file permissions
- `SETUID/SETGID`: Set user/group ID
- `NET_ADMIN`: Network administration
- `SYS_ADMIN`: System administration

## SELinux

```yaml
securityContext:
  seLinuxOptions:
    level: "s0:c123,c456"
    role: "sysadm_r"
    type: "container_t"
    user: "system_u"
```

## AppArmor

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apparmor-pod
  annotations:
    container.apparmor.security.beta.kubernetes.io/app: localhost/k8s-apparmor-example
spec:
  containers:
  - name: app
    image: nginx
```

## Seccomp

### RuntimeDefault Profile

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

### Custom Profile

```yaml
securityContext:
  seccompProfile:
    type: Localhost
    localhostProfile: profiles/audit.json
```

## Pod Security Admission

### Namespace Labels

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Modes

**enforce**: Reject non-compliant pods
**audit**: Log violations
**warn**: Show warnings

## Restricted Pod Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /app/cache
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

## Service Accounts

### Create Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
automountServiceAccountToken: false
```

### Use in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
spec:
  serviceAccountName: app-sa
  automountServiceAccountToken: false
  containers:
  - name: app
    image: myapp:1.0
```

## Host Namespaces

### Avoid Host Namespaces

```yaml
# DON'T DO THIS in production
spec:
  hostNetwork: false
  hostPID: false
  hostIPC: false
```

## Volume Security

### Read-Only Volumes

```yaml
volumeMounts:
- name: config
  mountPath: /etc/config
  readOnly: true
```

### EmptyDir with Size Limit

```yaml
volumes:
- name: cache
  emptyDir:
    sizeLimit: 1Gi
```

## Best Practices

### 1. Run as Non-Root

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

### 2. Drop All Capabilities

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
```

### 3. Read-Only Root Filesystem

```yaml
securityContext:
  readOnlyRootFilesystem: true
```

### 4. Disable Privilege Escalation

```yaml
securityContext:
  allowPrivilegeEscalation: false
```

### 5. Use Seccomp

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

### 6. Minimal Service Account

```yaml
serviceAccountName: minimal-sa
automountServiceAccountToken: false
```

## Security Scanning

```bash
# Scan pod security
kubectl auth can-i --list --as=system:serviceaccount:default:app-sa

# Check pod security standards
kubectl label --dry-run=server --overwrite ns production \
  pod-security.kubernetes.io/enforce=restricted
```

## Troubleshooting

```bash
# Check security context
kubectl get pod secure-pod -o jsonpath='{.spec.securityContext}'

# Check container security context
kubectl get pod secure-pod -o jsonpath='{.spec.containers[0].securityContext}'

# View pod security violations
kubectl get events --field-selector reason=FailedCreate

# Test as service account
kubectl auth can-i create pods --as=system:serviceaccount:default:app-sa
```

## References

- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [Security Context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
