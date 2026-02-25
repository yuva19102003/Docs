# OpenShift Monitoring and Logging

## Overview

OpenShift provides built-in monitoring with Prometheus and Grafana, plus centralized logging with the EFK (Elasticsearch, Fluentd, Kibana) stack or Loki.

## Monitoring Stack

### Components
- **Prometheus**: Metrics collection and storage
- **Alertmanager**: Alert handling and routing
- **Grafana**: Visualization and dashboards
- **Thanos**: Long-term metrics storage

### Access Monitoring UI
```bash
# Get monitoring route
oc get route -n openshift-monitoring

# Access Prometheus
https://prometheus-k8s-openshift-monitoring.apps.cluster.example.com

# Access Grafana
https://grafana-openshift-monitoring.apps.cluster.example.com
```

## Application Monitoring

### Enable User Workload Monitoring
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
```

### ServiceMonitor
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: myapp-monitor
  namespace: myproject
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### PodMonitor
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: myapp-pod-monitor
  namespace: myproject
spec:
  selector:
    matchLabels:
      app: myapp
  podMetricsEndpoints:
  - port: metrics
    interval: 30s
```

## Custom Metrics

### Expose Metrics Endpoint
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
  selector:
    app: myapp
```

### Application Code (Go Example)
```go
package main

import (
    "net/http"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    requestCounter = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "myapp_requests_total",
            Help: "Total number of requests",
        },
        []string{"method", "endpoint"},
    )
)

func init() {
    prometheus.MustRegister(requestCounter)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

## Alerting

### PrometheusRule
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-alerts
  namespace: myproject
spec:
  groups:
  - name: myapp
    interval: 30s
    rules:
    - alert: HighErrorRate
      expr: |
        rate(myapp_errors_total[5m]) > 0.05
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value }} errors/sec"
    
    - alert: PodDown
      expr: |
        up{job="myapp"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is down"
        description: "{{ $labels.pod }} has been down for 5 minutes"
```

### AlertmanagerConfig
```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: myapp-alertmanager
  namespace: myproject
spec:
  route:
    groupBy: ['alertname']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: 'team-notifications'
  receivers:
  - name: 'team-notifications'
    emailConfigs:
    - to: 'team@example.com'
      from: 'alerts@example.com'
      smarthost: 'smtp.example.com:587'
      authUsername: 'alerts@example.com'
      authPassword:
        name: smtp-secret
        key: password
```

## Logging

### Cluster Logging Operator

#### Install Logging
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging
spec:
  channel: stable
  name: cluster-logging
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

#### Configure Logging
```yaml
apiVersion: logging.openshift.io/v1
kind: ClusterLogging
metadata:
  name: instance
  namespace: openshift-logging
spec:
  managementState: Managed
  logStore:
    type: elasticsearch
    elasticsearch:
      nodeCount: 3
      storage:
        size: 200Gi
        storageClassName: gp2
      redundancyPolicy: SingleRedundancy
  visualization:
    type: kibana
    kibana:
      replicas: 1
  collection:
    logs:
      type: fluentd
      fluentd: {}
```

### Application Logging

#### Structured Logging (JSON)
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
    - name: LOG_FORMAT
      value: json
```

#### Log to stdout/stderr
```python
import json
import sys

def log(level, message, **kwargs):
    log_entry = {
        "level": level,
        "message": message,
        "timestamp": datetime.now().isoformat(),
        **kwargs
    }
    print(json.dumps(log_entry), file=sys.stdout)

log("info", "Application started", version="1.0.0")
```

### View Logs

#### CLI Commands
```bash
# View pod logs
oc logs myapp-pod

# Follow logs
oc logs -f myapp-pod

# Previous container logs
oc logs myapp-pod --previous

# Specific container in pod
oc logs myapp-pod -c container-name

# All pods with label
oc logs -l app=myapp --all-containers=true
```

#### Kibana Access
```bash
# Get Kibana route
oc get route kibana -n openshift-logging

# Access Kibana UI
https://kibana-openshift-logging.apps.cluster.example.com
```

## Log Forwarding

### ClusterLogForwarder
```yaml
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  outputs:
  - name: external-elasticsearch
    type: elasticsearch
    url: https://elasticsearch.example.com:9200
    secret:
      name: es-secret
  
  - name: splunk
    type: splunk
    url: https://splunk.example.com:8088
    secret:
      name: splunk-secret
  
  pipelines:
  - name: application-logs
    inputRefs:
    - application
    outputRefs:
    - external-elasticsearch
  
  - name: infrastructure-logs
    inputRefs:
    - infrastructure
    outputRefs:
    - splunk
```

## Metrics Queries

### PromQL Examples
```promql
# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total{namespace="myproject"}[5m])) by (pod)

# Memory usage by pod
sum(container_memory_working_set_bytes{namespace="myproject"}) by (pod)

# Request rate
rate(http_requests_total{namespace="myproject"}[5m])

# Error rate
rate(http_requests_total{namespace="myproject",status=~"5.."}[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Dashboards

### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "MyApp Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{app='myapp'}[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{app='myapp',status=~'5..'}[5m])"
          }
        ]
      }
    ]
  }
}
```

## Events

### View Events
```bash
# All events in namespace
oc get events -n myproject

# Watch events
oc get events -n myproject --watch

# Filter by type
oc get events -n myproject --field-selector type=Warning

# Sort by timestamp
oc get events -n myproject --sort-by='.lastTimestamp'
```

## Resource Metrics

### Node Metrics
```bash
# Node resource usage
oc adm top nodes

# Detailed node info
oc describe node node-name
```

### Pod Metrics
```bash
# Pod resource usage
oc adm top pods -n myproject

# Specific pod
oc adm top pod myapp-pod -n myproject

# All containers in pod
oc adm top pod myapp-pod --containers -n myproject
```

## Troubleshooting

### Debug Monitoring
```bash
# Check Prometheus targets
oc get servicemonitor -n myproject
oc describe servicemonitor myapp-monitor -n myproject

# Check Prometheus pods
oc get pods -n openshift-monitoring

# View Prometheus logs
oc logs prometheus-k8s-0 -n openshift-monitoring
```

### Debug Logging
```bash
# Check logging pods
oc get pods -n openshift-logging

# Check Elasticsearch health
oc exec -n openshift-logging elasticsearch-cdm-xxx -- \
  curl -s http://localhost:9200/_cluster/health?pretty

# Check Fluentd logs
oc logs fluentd-xxx -n openshift-logging
```

## Best Practices

1. **Enable User Workload Monitoring**: For application metrics
2. **Structured Logging**: Use JSON format for better parsing
3. **Log Levels**: Use appropriate log levels (DEBUG, INFO, WARN, ERROR)
4. **Retention**: Configure appropriate retention policies
5. **Alerts**: Create meaningful alerts with proper thresholds
6. **Dashboards**: Build dashboards for key metrics
7. **Resource Limits**: Set limits for monitoring components
8. **Security**: Secure access to monitoring and logging UIs
