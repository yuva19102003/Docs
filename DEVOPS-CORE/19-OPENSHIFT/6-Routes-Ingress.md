# OpenShift Routes and Ingress

## Overview

Routes expose services externally by providing a hostname and path-based routing. OpenShift Routes are similar to Kubernetes Ingress but with additional features.

## Routes vs Ingress

| Feature | OpenShift Route | Kubernetes Ingress |
|---------|----------------|-------------------|
| Native Support | Yes | Yes (with controller) |
| TLS Termination | Edge, Passthrough, Re-encrypt | Edge only |
| Load Balancing | Built-in | Depends on controller |
| Wildcard Routes | Yes | Limited |
| Custom Certificates | Yes | Yes |

## Creating Routes

### Simple Route
```bash
# Expose a service
oc expose service myapp

# Expose with custom hostname
oc expose service myapp --hostname=myapp.example.com
```

### Route YAML
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-route
  namespace: myproject
spec:
  host: myapp.example.com
  to:
    kind: Service
    name: myapp
    weight: 100
  port:
    targetPort: 8080
```

## TLS/SSL Configuration

### Edge Termination
TLS terminates at the router, traffic to pods is HTTP.

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-edge
spec:
  host: myapp.example.com
  to:
    kind: Service
    name: myapp
  tls:
    termination: edge
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    caCertificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

### Passthrough Termination
TLS passes through to the pod, router doesn't decrypt.

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-passthrough
spec:
  host: secure.example.com
  to:
    kind: Service
    name: myapp
  tls:
    termination: passthrough
```

### Re-encrypt Termination
TLS terminates at router, re-encrypts to pod.

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-reencrypt
spec:
  host: myapp.example.com
  to:
    kind: Service
    name: myapp
  tls:
    termination: reencrypt
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    destinationCACertificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

## Path-Based Routing

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-api
spec:
  host: myapp.example.com
  path: /api
  to:
    kind: Service
    name: api-service
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-web
spec:
  host: myapp.example.com
  path: /
  to:
    kind: Service
    name: web-service
```

## Wildcard Routes

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: wildcard-route
spec:
  host: "*.apps.example.com"
  wildcardPolicy: Subdomain
  to:
    kind: Service
    name: myapp
  tls:
    termination: edge
```

## Load Balancing

### Round Robin (Default)
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-route
spec:
  to:
    kind: Service
    name: myapp
    weight: 100
```

### Multiple Backends
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ab-test-route
spec:
  host: myapp.example.com
  to:
    kind: Service
    name: myapp-v1
    weight: 80
  alternateBackends:
  - kind: Service
    name: myapp-v2
    weight: 20
```

## Custom Annotations

### Timeout Configuration
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-route
  annotations:
    haproxy.router.openshift.io/timeout: 60s
spec:
  to:
    kind: Service
    name: myapp
```

### Rate Limiting
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-route
  annotations:
    haproxy.router.openshift.io/rate-limit-connections: "100"
    haproxy.router.openshift.io/rate-limit-connections.concurrent-tcp: "50"
spec:
  to:
    kind: Service
    name: myapp
```

### IP Whitelist
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: myapp-route
  annotations:
    haproxy.router.openshift.io/ip_whitelist: "192.168.1.0/24 10.0.0.0/8"
spec:
  to:
    kind: Service
    name: myapp
```

## Managing Routes

### CLI Commands
```bash
# List routes
oc get routes

# Describe route
oc describe route myapp-route

# Get route URL
oc get route myapp-route -o jsonpath='{.spec.host}'

# Delete route
oc delete route myapp-route

# Edit route
oc edit route myapp-route
```

### Testing Routes
```bash
# Test HTTP route
curl http://myapp.example.com

# Test HTTPS route
curl -k https://myapp.example.com

# Test with specific header
curl -H "Host: myapp.example.com" http://router-ip
```

## Blue-Green Deployment

```bash
# Create blue deployment
oc new-app --name=blue --image=myapp:v1
oc expose svc/blue

# Create green deployment
oc new-app --name=green --image=myapp:v2

# Create route pointing to blue
oc create route edge myapp --service=blue --hostname=myapp.example.com

# Switch to green
oc patch route myapp -p '{"spec":{"to":{"name":"green"}}}'

# Split traffic (90% blue, 10% green)
oc set route-backends myapp blue=90 green=10

# Full cutover to green
oc set route-backends myapp blue=0 green=100
```

## Ingress Controller

### Using Kubernetes Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: myproject
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 8080
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
```

## Troubleshooting

### Check Router Logs
```bash
# Get router pods
oc get pods -n openshift-ingress

# View logs
oc logs -f router-pod-name -n openshift-ingress
```

### Common Issues
```bash
# Route not accessible
oc get route myapp-route
oc describe route myapp-route
oc get svc myapp

# Check endpoints
oc get endpoints myapp

# Verify DNS
nslookup myapp.example.com

# Test from router pod
oc rsh -n openshift-ingress router-pod-name
curl http://myapp-service:8080
```

## Best Practices

1. **Use TLS**: Always enable TLS for production routes
2. **Custom Domains**: Use meaningful hostnames
3. **Health Checks**: Configure proper health endpoints
4. **Timeouts**: Set appropriate timeout values
5. **Rate Limiting**: Protect against abuse
6. **Monitoring**: Monitor route metrics and logs
7. **Annotations**: Use annotations for advanced features
