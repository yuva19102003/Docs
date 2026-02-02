# Kubernetes Logging

Centralized logging and log management for Kubernetes.

## Logging Architecture

```
┌────────────────────────────────────────────────┐
│         Logging Stack                          │
├────────────────────────────────────────────────┤
│  Application → stdout/stderr                   │
│         ↓                                      │
│  Container Runtime                             │
│         ↓                                      │
│  Log Collector (Fluentd/Fluent Bit)          │
│         ↓                                      │
│  Log Aggregator (Elasticsearch/Loki)          │
│         ↓                                      │
│  Visualization (Kibana/Grafana)               │
└────────────────────────────────────────────────┘
```

## ELK Stack

### Install Elasticsearch

```bash
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace
```

### Install Kibana

```bash
helm install kibana elastic/kibana \
  --namespace logging
```

### Install Fluentd

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch
      port 9200
      logstash_format true
      logstash_prefix kubernetes
    </match>
```

## Loki Stack

### Install Loki

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  --set promtail.enabled=true \
  --set grafana.enabled=true
```

### Promtail Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
data:
  promtail.yaml: |
    server:
      http_listen_port: 9080
    
    clients:
      - url: http://loki:3100/loki/api/v1/push
    
    scrape_configs:
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_label_app]
            target_label: app
```

## Application Logging

### Structured Logging

```go
// Go example
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
defer logger.Sync()

logger.Info("User logged in",
    zap.String("user_id", "123"),
    zap.String("ip", "192.168.1.1"),
)
```

### JSON Logging

```json
{
  "timestamp": "2024-01-01T10:00:00Z",
  "level": "INFO",
  "message": "Request processed",
  "request_id": "abc123",
  "user_id": "user456",
  "duration_ms": 45
}
```

## Log Queries

### kubectl logs

```bash
# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Previous container
kubectl logs <pod-name> --previous

# Specific container
kubectl logs <pod-name> -c <container-name>

# Tail logs
kubectl logs <pod-name> --tail=100

# Since time
kubectl logs <pod-name> --since=1h
```

### Loki Queries

```
# All logs from app
{app="myapp"}

# Error logs
{app="myapp"} |= "error"

# JSON parsing
{app="myapp"} | json | level="error"

# Rate
rate({app="myapp"}[5m])
```

## Best Practices

1. **Log to stdout/stderr**
2. **Use Structured Logging**
3. **Include Context**
4. **Set Log Levels**
5. **Rotate Logs**
6. **Centralize Logs**

## References

- [Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [Loki](https://grafana.com/oss/loki/)
- [ELK Stack](https://www.elastic.co/elastic-stack)
