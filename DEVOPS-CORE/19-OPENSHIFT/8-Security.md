# OpenShift Security

## Overview

OpenShift provides comprehensive security features including RBAC, Security Context Constraints (SCC), network policies, and secrets management.

## Security Context Constraints (SCC)

### What are SCCs?
SCCs control pod security policies and define what actions pods can perform and what resources they can access.

### Default SCCs
```bash
# List all SCCs
oc get scc

# Common SCCs:
# - restricted: Default, most restrictive
# - anyuid: Run as any UID
# - privileged: Full access (admin only)
# - hostnetwork: Access host network
# - hostmount-anyuid: Mount host volumes
```

### View SCC Details
```bash
oc describe scc restricted
oc describe scc anyuid
```

### Grant SCC to Service Account
```bash
# Grant anyuid SCC
oc adm policy add-scc-to-user anyuid -z myapp-sa

# Grant privileged SCC
oc adm policy add-scc-to-user privileged -z myapp-sa

# Remove SCC
oc adm policy remove-scc-from-user anyuid -z myapp-sa
```

### Custom SCC
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: custom-scc
allowPrivilegedContainer: false
allowHostDirVolumePlugin: false
allowHostNetwork: false
allowHostPorts: false
allowHostPID: false
allowHostIPC: false
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000
  uidRangeMax: 2000
seLinuxContext:
  type: MustRunAs
fsGroup:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## RBAC (Role-Based Access Control)

### Roles and ClusterRoles

#### Project-Level Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: myproject
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

#### Cluster-Level Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

### RoleBindings

#### Bind Role to User
```bash
# Project-level
oc adm policy add-role-to-user view user1 -n myproject
oc adm policy add-role-to-user edit user2 -n myproject
oc adm policy add-role-to-user admin user3 -n myproject

# Cluster-level
oc adm policy add-cluster-role-to-user cluster-admin admin-user
```

#### RoleBinding YAML
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: myproject
subjects:
- kind: User
  name: user1
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Service Accounts

```bash
# Create service account
oc create sa myapp-sa -n myproject

# Grant permissions
oc adm policy add-role-to-user edit system:serviceaccount:myproject:myapp-sa

# Use in pod
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  serviceAccountName: myapp-sa
  containers:
  - name: myapp
    image: myapp:latest
```

## Secrets Management

### Create Secrets

#### Generic Secret
```bash
# From literal
oc create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123

# From file
oc create secret generic app-config \
  --from-file=config.json
```

#### Docker Registry Secret
```bash
oc create secret docker-registry registry-secret \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=user@example.com
```

#### TLS Secret
```bash
oc create secret tls tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/key.key
```

### Use Secrets in Pods

#### Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
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

#### Volume Mount
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
```

## Network Security

### Network Policies

#### Deny All Traffic
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: myproject
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

#### Allow Specific Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: myproject
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

#### Allow Egress to External
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external
  namespace: myproject
spec:
  podSelector:
    matchLabels:
      app: myapp
  egress:
  - to:
    - namespaceSelector: {}
  - to:
    - podSelector: {}
  - ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
```

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
  - name: myapp
    image: myapp:latest
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

## Image Security

### Image Streams
```bash
# Create image stream
oc create imagestream myapp

# Import image
oc import-image myapp:latest \
  --from=docker.io/myorg/myapp:latest \
  --confirm

# Tag image
oc tag myapp:latest myapp:prod
```

### Image Signing
```bash
# Sign image
oc image sign myapp:latest \
  --registry-config=/path/to/config.json

# Verify signature
oc image verify myapp:latest
```

## OAuth and Authentication

### OAuth Clients
```yaml
apiVersion: oauth.openshift.io/v1
kind: OAuthClient
metadata:
  name: myapp-oauth
secret: secret-value
redirectURIs:
- https://myapp.example.com/callback
grantMethod: auto
```

### Identity Providers
```yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-secret
```

## Audit Logging

### Enable Audit
```yaml
apiVersion: config.openshift.io/v1
kind: APIServer
metadata:
  name: cluster
spec:
  audit:
    profile: Default
```

## Security Scanning

### Scan Images
```bash
# Using oc
oc image info myapp:latest

# Check vulnerabilities
oc adm must-gather --image=registry.redhat.io/openshift4/ose-must-gather
```

## Best Practices

1. **Least Privilege**: Use restrictive SCCs by default
2. **Service Accounts**: Create dedicated service accounts
3. **Secrets**: Never hardcode credentials
4. **Network Policies**: Implement network segmentation
5. **RBAC**: Follow principle of least privilege
6. **Image Security**: Use trusted registries and scan images
7. **Audit**: Enable and monitor audit logs
8. **Updates**: Keep OpenShift and images updated
9. **Non-Root**: Run containers as non-root users
10. **Read-Only**: Use read-only root filesystems when possible
