# Kubernetes Secrets

Secrets store sensitive information like passwords, tokens, and keys.

## Secret Overview

```
┌──────────────────────────────────────┐
│            Secret                    │
│      (Base64 Encoded)                │
│                                      │
│  username: YWRtaW4=                  │
│  password: cGFzc3dvcmQxMjM=          │
└──────────────┬───────────────────────┘
               │
        ┌──────┴──────┐
        │             │
   ┌────▼────┐   ┌────▼────┐
   │ Env Var │   │ Volume  │
   └─────────┘   └─────────┘
```

**Important:** Secrets are base64 encoded, NOT encrypted by default!

## Secret Types

- `Opaque`: Arbitrary user-defined data (default)
- `kubernetes.io/service-account-token`: Service account token
- `kubernetes.io/dockercfg`: Docker config
- `kubernetes.io/dockerconfigjson`: Docker config JSON
- `kubernetes.io/basic-auth`: Basic authentication
- `kubernetes.io/ssh-auth`: SSH authentication
- `kubernetes.io/tls`: TLS certificate
- `bootstrap.kubernetes.io/token`: Bootstrap token

## Creating Secrets

### From Literal Values

```bash
kubectl create secret generic app-secret \
  --from-literal=username=admin \
  --from-literal=password=password123
```

### From Files

```bash
# Single file
kubectl create secret generic app-secret --from-file=./password.txt

# Multiple files
kubectl create secret generic app-secret \
  --from-file=username=./username.txt \
  --from-file=password=./password.txt

# SSH key
kubectl create secret generic ssh-key --from-file=ssh-privatekey=~/.ssh/id_rsa
```

### From YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=        # base64 encoded "admin"
  password: cGFzc3dvcmQxMjM= # base64 encoded "password123"
```

**Encode/Decode:**
```bash
# Encode
echo -n 'admin' | base64
# Output: YWRtaW4=

# Decode
echo 'YWRtaW4=' | base64 --decode
# Output: admin
```

### Using stringData

No need to base64 encode:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  username: admin
  password: password123
```

## Using Secrets

### As Environment Variables

**All keys:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    envFrom:
    - secretRef:
        name: app-secret
```

**Specific keys:**
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
          name: app-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
```

### As Volume

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
    - name: secrets
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: app-secret
```

**Mount specific keys:**
```yaml
volumes:
- name: secrets
  secret:
    secretName: app-secret
    items:
    - key: username
      path: db-username
    - key: password
      path: db-password
```

**With permissions:**
```yaml
volumes:
- name: secrets
  secret:
    secretName: app-secret
    defaultMode: 0400
```

## TLS Secrets

### Create TLS Secret

```bash
# From certificate files
kubectl create secret tls tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key
```

### TLS Secret YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

### Using TLS Secret

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Docker Registry Secrets

### Create Docker Secret

```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

### Docker Secret YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

### Using Docker Secret

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-pod
spec:
  containers:
  - name: app
    image: private-registry.io/myapp:1.0
  imagePullSecrets:
  - name: regcred
```

## Basic Auth Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
type: kubernetes.io/basic-auth
stringData:
  username: admin
  password: secretpassword
```

## SSH Auth Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-auth
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: <base64-encoded-private-key>
```

## Service Account Token

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sa-token
  annotations:
    kubernetes.io/service-account.name: myserviceaccount
type: kubernetes.io/service-account-token
```

## Immutable Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: immutable-secret
type: Opaque
data:
  key: dmFsdWU=
immutable: true
```

## Secret with Deployment

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  username: dbuser
  password: dbpass123
  connection-string: "postgresql://dbuser:dbpass123@postgres:5432/mydb"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:1.0
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
        volumeMounts:
        - name: db-config
          mountPath: /etc/db
          readOnly: true
      volumes:
      - name: db-config
        secret:
          secretName: db-secret
          items:
          - key: connection-string
            path: connection.conf
```

## External Secrets

### External Secrets Operator

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: app-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: prod/app/password
```

## Sealed Secrets

Encrypt secrets for Git:

```bash
# Install kubeseal
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Create sealed secret
kubeseal --format=yaml < secret.yaml > sealed-secret.yaml
```

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: app-secret
spec:
  encryptedData:
    password: AgBx8F7...encrypted...
```

## Secret Commands

```bash
# Create secret
kubectl create secret generic app-secret --from-literal=key=value

# List secrets
kubectl get secrets

# Describe secret
kubectl describe secret app-secret

# Get secret YAML
kubectl get secret app-secret -o yaml

# Get decoded secret
kubectl get secret app-secret -o jsonpath='{.data.password}' | base64 --decode

# Edit secret
kubectl edit secret app-secret

# Delete secret
kubectl delete secret app-secret

# Create TLS secret
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.io \
  --docker-username=user \
  --docker-password=pass
```

## Encryption at Rest

### Enable Encryption

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
          secret: <base64-encoded-32-byte-key>
    - identity: {}
```

**API Server flag:**
```bash
--encryption-provider-config=/etc/kubernetes/enc/encryption-config.yaml
```

### Verify Encryption

```bash
# Check if secret is encrypted in etcd
ETCDCTL_API=3 etcdctl get /registry/secrets/default/app-secret \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

## Best Practices

1. **Never Commit Secrets**
   - Don't commit to Git
   - Use .gitignore
   - Use sealed secrets or external secrets

2. **Enable Encryption at Rest**
   - Encrypt secrets in etcd
   - Use KMS providers
   - Rotate encryption keys

3. **RBAC**
   - Restrict secret access
   - Use service accounts
   - Principle of least privilege

4. **Rotation**
   - Rotate secrets regularly
   - Automate rotation
   - Update dependent resources

5. **External Secret Management**
   - Use Vault, AWS Secrets Manager
   - External Secrets Operator
   - Centralized secret management

6. **Immutability**
   - Use immutable secrets
   - Create new secrets for updates
   - Prevent accidental changes

7. **Audit**
   - Enable audit logging
   - Monitor secret access
   - Alert on suspicious activity

## Security Considerations

1. **Base64 is NOT Encryption**
   - Easily decoded
   - Enable encryption at rest
   - Use external secret managers

2. **Pod Access**
   - Pods can read mounted secrets
   - Limit pod permissions
   - Use network policies

3. **RBAC**
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: secret-reader
   rules:
   - apiGroups: [""]
     resources: ["secrets"]
     verbs: ["get", "list"]
     resourceNames: ["app-secret"]
   ```

4. **Service Account**
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: app-sa
   automountServiceAccountToken: false
   ```

## Troubleshooting

```bash
# Check if secret exists
kubectl get secret app-secret

# View secret data (base64 encoded)
kubectl get secret app-secret -o yaml

# Decode secret
kubectl get secret app-secret -o jsonpath='{.data.password}' | base64 --decode

# Check pod environment
kubectl exec pod-name -- env | grep PASSWORD

# Check mounted secrets
kubectl exec pod-name -- ls -la /etc/secrets
kubectl exec pod-name -- cat /etc/secrets/password

# Check pod events
kubectl describe pod pod-name

# Verify secret reference
kubectl get pod pod-name -o yaml | grep -A 5 secretKeyRef
```

## Common Issues

1. **Secret not found**
   ```bash
   kubectl get secret -n <namespace>
   ```

2. **Permission denied**
   ```bash
   kubectl auth can-i get secrets --as=system:serviceaccount:default:app-sa
   ```

3. **Decoding issues**
   ```bash
   # Ensure no newlines
   echo -n 'value' | base64
   ```

## References

- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Encryption at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)
- [External Secrets Operator](https://external-secrets.io/)
