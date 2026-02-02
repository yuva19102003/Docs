# Kubernetes Ingress

Ingress manages external HTTP/HTTPS access to services in a cluster.

## Ingress Overview

```
    Internet
        │
        ▼
   ┌─────────┐
   │ Ingress │
   └────┬────┘
        │
   ┌────┴────┐
   │         │
   ▼         ▼
Service1  Service2
   │         │
   ▼         ▼
 Pods      Pods
```

**Benefits:**
- Single entry point
- SSL/TLS termination
- Name-based virtual hosting
- Path-based routing
- Load balancing

## Ingress Controller

Required to fulfill Ingress resources.

### Popular Controllers

**NGINX Ingress Controller:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

**Traefik:**
```bash
helm install traefik traefik/traefik
```

**HAProxy:**
```bash
helm install haproxy-ingress haproxy-ingress/haproxy-ingress
```

**Istio Gateway:**
```bash
istioctl install --set profile=demo
```

## Basic Ingress

### Simple Fanout

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-fanout
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### Name-Based Virtual Hosting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: name-virtual-host
spec:
  ingressClassName: nginx
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

## TLS/SSL Configuration

### TLS Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    - www.example.com
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

### Create TLS Secret

```bash
# Create TLS secret from files
kubectl create secret tls tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key

# Create from literal
kubectl create secret tls tls-secret \
  --cert=<(echo "$CERT_DATA") \
  --key=<(echo "$KEY_DATA")
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

## Path Types

### Exact

Matches exact path:

```yaml
paths:
- path: /api/v1/users
  pathType: Exact
  backend:
    service:
      name: users-service
      port:
        number: 80
```

### Prefix

Matches path prefix:

```yaml
paths:
- path: /api
  pathType: Prefix
  backend:
    service:
      name: api-service
      port:
        number: 80
```

### ImplementationSpecific

Controller-specific matching:

```yaml
paths:
- path: /api/*
  pathType: ImplementationSpecific
  backend:
    service:
      name: api-service
      port:
        number: 80
```

## Ingress Annotations

### NGINX Ingress

```yaml
metadata:
  annotations:
    # Rewrite
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    
    # SSL Redirect
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    
    # Rate Limiting
    nginx.ingress.kubernetes.io/limit-rps: "10"
    
    # CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    
    # Timeouts
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "30"
    
    # Body Size
    nginx.ingress.kubernetes.io/proxy-body-size: "8m"
    
    # Authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    
    # Whitelist
    nginx.ingress.kubernetes.io/whitelist-source-range: "10.0.0.0/8,192.168.0.0/16"
```

### Traefik Ingress

```yaml
metadata:
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.middlewares: default-redirect-https@kubernetescrd
```

## Advanced Configurations

### URL Rewriting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

### Basic Authentication

```bash
# Create auth file
htpasswd -c auth username

# Create secret
kubectl create secret generic basic-auth --from-file=auth
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auth-ingress
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
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

### Rate Limiting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limit-ingress
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/limit-connections: "10"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

### Custom Headers

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: custom-headers
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Custom-Header: value";
      more_set_headers "X-Another-Header: another-value";
spec:
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

### Canary Deployments

```yaml
# Main ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: production
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: production-service
            port:
              number: 80
---
# Canary ingress (10% traffic)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: canary-service
            port:
              number: 80
```

## Default Backend

Fallback for unmatched requests:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-with-default
spec:
  defaultBackend:
    service:
      name: default-service
      port:
        number: 80
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Multiple Ingress Controllers

```yaml
# NGINX Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: nginx.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
---
# Traefik Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: traefik.example.com
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

## IngressClass

Define ingress controller classes:

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: k8s.io/ingress-nginx
```

## Cert-Manager Integration

Automatic TLS certificate management:

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### ClusterIssuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Ingress with Cert-Manager

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-auto-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    secretName: example-tls
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

## Ingress Commands

```bash
# Create ingress
kubectl apply -f ingress.yaml

# List ingress
kubectl get ingress
kubectl get ing

# Describe ingress
kubectl describe ingress my-ingress

# Get ingress details
kubectl get ingress my-ingress -o yaml

# Edit ingress
kubectl edit ingress my-ingress

# Delete ingress
kubectl delete ingress my-ingress

# Check ingress controller
kubectl get pods -n ingress-nginx

# View controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## Troubleshooting

```bash
# Check ingress status
kubectl get ingress

# Describe ingress
kubectl describe ingress my-ingress

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Test DNS resolution
nslookup example.com

# Test connectivity
curl -H "Host: example.com" http://<ingress-ip>

# Check TLS certificate
openssl s_client -connect example.com:443 -servername example.com

# Validate ingress
kubectl get ingress my-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Best Practices

1. **Use TLS**
   - Always use HTTPS in production
   - Automate certificate management
   - Use cert-manager for Let's Encrypt

2. **Resource Limits**
   - Set rate limits
   - Configure timeouts
   - Limit request body size

3. **Security**
   - Implement authentication
   - Use IP whitelisting
   - Enable CORS properly

4. **Monitoring**
   - Monitor ingress metrics
   - Track response times
   - Alert on errors

5. **High Availability**
   - Run multiple controller replicas
   - Use anti-affinity rules
   - Configure health checks

## References

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
