# Network Security

Securing network communication in Kubernetes clusters.

## Network Security Layers

```
┌────────────────────────────────────────────────┐
│         Network Security Stack                 │
├────────────────────────────────────────────────┤
│  1. Network Policies (L3/L4)                   │
│  2. Service Mesh (L7)                          │
│  3. Ingress Security                           │
│  4. TLS/mTLS                                   │
│  5. Network Encryption                         │
└────────────────────────────────────────────────┘
```

## Network Policies

### Default Deny All

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Allow Specific Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
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
  - from:
    - podSelector: {}
  egress:
  - to:
    - podSelector: {}
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

## TLS/SSL

### TLS Termination at Ingress

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
            name: web
            port:
              number: 80
```

### mTLS with Service Mesh

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

## Service Mesh Security

### Istio Authorization

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: frontend
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/backend"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]
```

### Linkerd mTLS

```yaml
apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: backend-server
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  port: 8080
  proxyProtocol: HTTP/2
```

## Ingress Security

### Rate Limiting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limited
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
            name: api
            port:
              number: 80
```

### IP Whitelisting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: whitelisted
  annotations:
    nginx.ingress.kubernetes.io/whitelist-source-range: "10.0.0.0/8,192.168.0.0/16"
spec:
  rules:
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin
            port:
              number: 80
```

### WAF Integration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: waf-protected
  annotations:
    nginx.ingress.kubernetes.io/enable-modsecurity: "true"
    nginx.ingress.kubernetes.io/enable-owasp-core-rules: "true"
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app
            port:
              number: 80
```

## Network Encryption

### CNI Encryption (Calico)

```yaml
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec:
  wireguardEnabled: true
```

### CNI Encryption (Cilium)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cilium-config
  namespace: kube-system
data:
  enable-ipsec: "true"
  ipsec-key-file: /etc/ipsec/keys
```

## DNS Security

### CoreDNS Security

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

## Egress Control

### Egress Gateway

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: egress-gateway
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "*.external-api.com"
```

### Egress Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-https
spec:
  podSelector:
    matchLabels:
      app: api-client
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32
    ports:
    - protocol: TCP
      port: 443
```

## Security Best Practices

### 1. Default Deny

```yaml
# Apply to all namespaces
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 2. Namespace Isolation

```yaml
# Isolate production namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: production-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: production
```

### 3. Enable mTLS

```yaml
# Istio strict mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

### 4. Encrypt Traffic

Enable CNI encryption (WireGuard, IPSec)

### 5. Monitor Traffic

```bash
# Monitor with Cilium Hubble
hubble observe --namespace production

# Monitor with Istio
istioctl dashboard kiali
```

## Security Monitoring

### Falco Rules

```yaml
- rule: Unexpected outbound connection
  desc: Detect unexpected outbound connections
  condition: outbound and not allowed_outbound
  output: Unexpected connection (command=%proc.cmdline connection=%fd.name)
  priority: WARNING
```

### Network Policy Logging

```bash
# Enable logging (Calico)
kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"flowLogsEnableNetworkPolicy":true}}'
```

## Troubleshooting

```bash
# Test network policy
kubectl run test --rm -it --image=busybox --restart=Never -- wget -O- http://service

# Check network policy
kubectl describe networkpolicy <policy-name>

# View denied connections (Cilium)
hubble observe --verdict DROPPED

# Check TLS certificate
openssl s_client -connect example.com:443 -servername example.com
```

## References

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Istio Security](https://istio.io/latest/docs/concepts/security/)
- [Cilium Network Policy](https://docs.cilium.io/en/stable/policy/)
