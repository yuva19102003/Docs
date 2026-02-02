# Kubernetes Monitoring

Comprehensive monitoring and observability for Kubernetes clusters.

## Monitoring Stack

```
┌────────────────────────────────────────────────┐
│         Monitoring Components                  │
├────────────────────────────────────────────────┤
│  Metrics:                                      │
│    - Prometheus                                │
│    - Metrics Server                            │
│    - Grafana                                   │
│                                                │
│  Logging:                                      │
│    - ELK Stack                                 │
│    - Loki                                      │
│    - Fluentd                                   │
│                                                │
│  Tracing:                                      │
│    - Jaeger                                    │
│    - Zipkin                                    │
│                                                │
│  APM:                                          │
│    - Datadog                                   │
│    - New Relic                                 │
└────────────────────────────────────────────────┘
```

## Metrics Server

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify
kubectl get deployment metrics-server -n kube-system

# View metrics
kubectl top nodes
kubectl top pods
```

## Prometheus

### Install with Helm

```bash
# Add Prometheus repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: myapp-monitor
  labels:
    app: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### PrometheusRule

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-alerts
spec:
  groups:
  - name: myapp
    interval: 30s
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status="500"}[5m]) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
```

## Grafana

### Access Grafana

```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Get admin password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Grafana Dashboard

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "My App Dashboard",
        "panels": []
      }
    }
```

## Application Metrics

### Expose Metrics Endpoint

```go
// Go example
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpRequests = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
)

func init() {
    prometheus.MustRegister(httpRequests)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":9090", nil)
}
```

### Pod Annotations

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
spec:
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - name: metrics
      containerPort: 9090
```

## Alertmanager

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: alertmanager-config
spec:
  route:
    groupBy: ['alertname']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: 'slack'
  receivers:
  - name: 'slack'
    slackConfigs:
    - apiURL: 'https://hooks.slack.com/services/XXX'
      channel: '#alerts'
      title: 'Alert: {{ .GroupLabels.alertname }}'
```

## Key Metrics to Monitor

### Cluster Metrics
- Node CPU/Memory usage
- Pod count
- Namespace resource usage
- API server latency

### Application Metrics
- Request rate
- Error rate
- Response time
- Saturation

### Resource Metrics
- CPU utilization
- Memory utilization
- Disk I/O
- Network I/O

## Monitoring Commands

```bash
# View metrics
kubectl top nodes
kubectl top pods
kubectl top pods --containers

# Get resource usage
kubectl describe node <node-name>

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

## Best Practices

1. **Monitor Everything**
2. **Set Up Alerts**
3. **Use Dashboards**
4. **Track SLIs/SLOs**
5. **Regular Reviews**

## References

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
