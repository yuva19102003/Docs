# Kubernetes ConfigMaps

ConfigMaps store non-confidential configuration data in key-value pairs.

## ConfigMap Overview

```
┌──────────────────────────────────────┐
│          ConfigMap                   │
│                                      │
│  key1: value1                        │
│  key2: value2                        │
│  config.yaml: |                      │
│    setting: value                    │
└──────────────┬───────────────────────┘
               │
        ┌──────┴──────┐
        │             │
   ┌────▼────┐   ┌────▼────┐
   │ Env Var │   │ Volume  │
   └─────────┘   └─────────┘
```

## Creating ConfigMaps

### From Literal Values

```bash
kubectl create configmap app-config \
  --from-literal=database_url=postgres://db:5432 \
  --from-literal=log_level=info \
  --from-literal=max_connections=100
```

### From File

```bash
# Single file
kubectl create configmap app-config --from-file=config.properties

# Multiple files
kubectl create configmap app-config \
  --from-file=config.properties \
  --from-file=database.conf

# From directory
kubectl create configmap app-config --from-file=./config/
```

### From Env File

```bash
# Create from .env file
kubectl create configmap app-config --from-env-file=app.env
```

**app.env:**
```
DATABASE_URL=postgres://db:5432
LOG_LEVEL=info
MAX_CONNECTIONS=100
```

### From YAML

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  # Simple key-value
  database_url: "postgres://db:5432"
  log_level: "info"
  max_connections: "100"
  
  # Multi-line value
  app.properties: |
    database.url=postgres://db:5432
    database.pool.size=10
    logging.level=INFO
  
  # JSON configuration
  config.json: |
    {
      "server": {
        "port": 8080,
        "host": "0.0.0.0"
      },
      "database": {
        "host": "db",
        "port": 5432
      }
    }
```

## Using ConfigMaps

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
    - configMapRef:
        name: app-config
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
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
```

**With prefix:**
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
    - configMapRef:
        name: app-config
      prefix: APP_
```

### As Volume

**Mount entire ConfigMap:**
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
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

**Mount specific keys:**
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
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
      items:
      - key: app.properties
        path: application.properties
      - key: config.json
        path: config.json
```

**With custom permissions:**
```yaml
volumes:
- name: config
  configMap:
    name: app-config
    defaultMode: 0644
    items:
    - key: app.properties
      path: application.properties
      mode: 0600
```

### As Command Arguments

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    command: ["/bin/sh"]
    args:
    - "-c"
    - "echo Database: $(DATABASE_URL)"
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
```

## ConfigMap Examples

### Application Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
data:
  # Server configuration
  server.conf: |
    server {
      listen 80;
      server_name example.com;
      
      location / {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
      }
    }
  
  # Application settings
  application.yaml: |
    server:
      port: 8080
      host: 0.0.0.0
    
    database:
      host: postgres
      port: 5432
      name: myapp
      pool:
        min: 5
        max: 20
    
    logging:
      level: INFO
      format: json
    
    features:
      cache_enabled: true
      debug_mode: false
```

### Database Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  POSTGRES_DB: "myapp"
  POSTGRES_MAX_CONNECTIONS: "100"
  POSTGRES_SHARED_BUFFERS: "256MB"
  
  postgresql.conf: |
    max_connections = 100
    shared_buffers = 256MB
    effective_cache_size = 1GB
    maintenance_work_mem = 64MB
    checkpoint_completion_target = 0.9
    wal_buffers = 16MB
    default_statistics_target = 100
    random_page_cost = 1.1
    effective_io_concurrency = 200
```

### Nginx Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;
    
    events {
        worker_connections 1024;
    }
    
    http {
        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
        
        access_log /var/log/nginx/access.log main;
        
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        
        include /etc/nginx/conf.d/*.conf;
    }
```

## Immutable ConfigMaps

Prevent accidental updates:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: immutable-config
data:
  key: value
immutable: true
```

**Benefits:**
- Protects from accidental updates
- Improves performance (no watch needed)
- Reduces API server load

## ConfigMap with Deployment

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "postgres://db:5432"
  LOG_LEVEL: "info"
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
        envFrom:
        - configMapRef:
            name: app-config
        volumeMounts:
        - name: config
          mountPath: /etc/config
      volumes:
      - name: config
        configMap:
          name: app-config
```

## Updating ConfigMaps

### Update ConfigMap

```bash
# Edit directly
kubectl edit configmap app-config

# Update from file
kubectl create configmap app-config --from-file=config.properties --dry-run=client -o yaml | kubectl apply -f -

# Patch
kubectl patch configmap app-config -p '{"data":{"key":"new-value"}}'
```

### Trigger Pod Restart

ConfigMap updates don't automatically restart pods:

```bash
# Restart deployment
kubectl rollout restart deployment webapp

# Delete pods (for StatefulSet/DaemonSet)
kubectl delete pod -l app=webapp
```

### Auto-reload with Annotations

Add checksum to trigger updates:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    spec:
      containers:
      - name: webapp
        image: webapp:1.0
```

## ConfigMap Commands

```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=key=value

# List ConfigMaps
kubectl get configmaps
kubectl get cm

# Describe ConfigMap
kubectl describe configmap app-config

# Get ConfigMap YAML
kubectl get configmap app-config -o yaml

# Get specific key
kubectl get configmap app-config -o jsonpath='{.data.database_url}'

# Edit ConfigMap
kubectl edit configmap app-config

# Delete ConfigMap
kubectl delete configmap app-config

# Export ConfigMap
kubectl get configmap app-config -o yaml > configmap.yaml
```

## Best Practices

1. **Naming Convention**
   - Use descriptive names
   - Include app/component name
   - Version if needed

2. **Size Limits**
   - Max 1MB per ConfigMap
   - Split large configs
   - Use external config servers for large data

3. **Immutability**
   - Use immutable for production
   - Create new ConfigMap for updates
   - Update deployment to use new ConfigMap

4. **Environment-Specific**
   - Separate ConfigMaps per environment
   - Use namespaces for isolation
   - Don't hardcode environment values

5. **Security**
   - Don't store secrets in ConfigMaps
   - Use Secrets for sensitive data
   - Apply RBAC restrictions

6. **Updates**
   - Plan for config updates
   - Implement reload mechanisms
   - Test config changes

7. **Documentation**
   - Document config keys
   - Add descriptions in annotations
   - Maintain config schema

## Troubleshooting

```bash
# Check if ConfigMap exists
kubectl get configmap app-config

# View ConfigMap data
kubectl describe configmap app-config

# Check pod environment variables
kubectl exec pod-name -- env

# Check mounted config files
kubectl exec pod-name -- ls -la /etc/config
kubectl exec pod-name -- cat /etc/config/app.properties

# Check pod events
kubectl describe pod pod-name

# Verify ConfigMap reference
kubectl get pod pod-name -o yaml | grep -A 5 configMap
```

## Common Issues

1. **ConfigMap not found**
   ```bash
   # Check namespace
   kubectl get configmap -n <namespace>
   
   # Verify name
   kubectl get configmap --all-namespaces | grep app-config
   ```

2. **Key not found**
   ```bash
   # List all keys
   kubectl get configmap app-config -o jsonpath='{.data}'
   ```

3. **Pod not updating**
   ```bash
   # Restart pods
   kubectl rollout restart deployment webapp
   ```

4. **Permission denied**
   ```bash
   # Check volume permissions
   kubectl exec pod-name -- ls -la /etc/config
   ```

## References

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Configure Pods with ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
