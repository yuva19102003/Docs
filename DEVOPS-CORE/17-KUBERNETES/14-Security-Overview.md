# Kubernetes Security Overview

Comprehensive security practices for Kubernetes clusters.

## Security Layers

```
┌────────────────────────────────────────────────┐
│         Kubernetes Security Layers             │
├────────────────────────────────────────────────┤
│  1. Cluster Security                           │
│     - API Server Authentication                │
│     - TLS Encryption                           │
│     - Network Policies                         │
│                                                │
│  2. Pod Security                               │
│     - Security Contexts                        │
│     - Pod Security Standards                   │
│     - Service Accounts                         │
│                                                │
│  3. Network Security                           │
│     - Network Policies                         │
│     - Service Mesh                             │
│     - Ingress Security                         │
│                                                │
│  4. Data Security                              │
│     - Secrets Encryption                       │
│     - Volume Encryption                        │
│     - etcd Encryption                          │
│                                                │
└────────────────────────────────────────────────┘
```

## 4C's of Cloud Native Security

```
┌─────────────────────────────────────┐
│            Code                     │
│         ┌─────────┐                 │
│         │Container│                 │
│      ┌──┴─────────┴──┐              │
│      │   Cluster     │              │
│   ┌──┴───────────────┴──┐           │
│   │      Cloud/Host     │           │
│   └─────────────────────┘           │
└─────────────────────────────────────┘
```

## Authentication

### User Authentication

```yaml
# Certificate-based
apiVersion: v1
kind: Config
users:
- name: admin
  user:
    client-certificate: /path/to/cert
    client-key: /path/to/key
```

### Service Account Tokens

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
automountServiceAccountToken: true
```

### OIDC Integration

```bash
# API server flags
--oidc-issuer-url=https://accounts.google.com
--oidc-client-id=kubernetes
--oidc-username-claim=email
--oidc-groups-claim=groups
```

## Authorization

### RBAC (Recommended)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### Node Authorization

Authorizes kubelet API requests.

### Webhook Authorization

External authorization service.

## Pod Security

### Security Context

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
    seccompProfile:
      type: RuntimeDefault
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

### Pod Security Standards

**Privileged**: Unrestricted
**Baseline**: Minimally restrictive
**Restricted**: Heavily restricted

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

## Network Security

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### TLS Everywhere

```yaml
# Ingress with TLS
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
```

## Secrets Management

### Encryption at Rest

```yaml
# /etc/kubernetes/enc/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <base64-encoded-secret>
    - identity: {}
```

### External Secrets

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secret
spec:
  secretStoreRef:
    name: aws-secretsmanager
  target:
    name: app-secret
  data:
  - secretKey: password
    remoteRef:
      key: prod/app/password
```

## Image Security

### Image Scanning

```bash
# Trivy
trivy image myapp:1.0

# Clair
clairctl analyze myapp:1.0
```

### Image Pull Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-pod
spec:
  imagePullSecrets:
  - name: regcred
  containers:
  - name: app
    image: private-registry.io/myapp:1.0
```

### Image Policy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: verified-pod
spec:
  containers:
  - name: app
    image: myapp@sha256:abc123...  # Use digest
```

## Audit Logging

```yaml
# /etc/kubernetes/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods"]
```

## Security Best Practices

### 1. Minimize Attack Surface

```yaml
# Disable unnecessary features
--anonymous-auth=false
--enable-admission-plugins=NodeRestriction,PodSecurityPolicy
```

### 2. Use Least Privilege

```yaml
# Minimal RBAC
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: minimal-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]
  resourceNames: ["specific-pod"]
```

### 3. Regular Updates

```bash
# Keep Kubernetes updated
kubectl version
kubeadm upgrade plan
```

### 4. Monitor and Alert

```yaml
# Falco rules
- rule: Unauthorized Process
  desc: Detect unauthorized process
  condition: spawned_process and not allowed_process
  output: Unauthorized process started
  priority: WARNING
```

## Security Tools

### Falco (Runtime Security)

```bash
# Install Falco
helm install falco falcosecurity/falco
```

### OPA/Gatekeeper (Policy Engine)

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-labels
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
  parameters:
    labels: ["app", "environment"]
```

### Kube-bench (CIS Benchmark)

```bash
# Run kube-bench
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
```

## Security Checklist

- [ ] Enable RBAC
- [ ] Use Network Policies
- [ ] Encrypt secrets at rest
- [ ] Use Pod Security Standards
- [ ] Scan images for vulnerabilities
- [ ] Enable audit logging
- [ ] Use TLS everywhere
- [ ] Regular security updates
- [ ] Monitor and alert
- [ ] Backup etcd regularly

## References

- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
