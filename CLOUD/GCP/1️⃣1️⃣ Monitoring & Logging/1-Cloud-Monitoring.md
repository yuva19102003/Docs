# Cloud Monitoring

Comprehensive metrics collection, monitoring, and alerting service.

---

## Overview

Cloud Monitoring (formerly Stackdriver Monitoring) provides visibility into the performance, availability, and health of your applications and infrastructure.

### Key Features

```
┌─────────────────────────────────────┐
│      Cloud Monitoring               │
├─────────────────────────────────────┤
│  • Metrics collection               │
│  • Custom dashboards                │
│  • Alerting policies                │
│  • Uptime checks                    │
│  • SLO monitoring                   │
│  • Metrics Explorer                 │
│  • PromQL support                   │
│  • Integration with GCP services    │
└─────────────────────────────────────┘
```

---

## Metrics Types

### 1. System Metrics (Automatic)

**Collected automatically from GCP services**

```
GCE Metrics:
  • CPU utilization
  • Disk I/O
  • Network traffic
  • Memory usage (with agent)

GKE Metrics:
  • Pod CPU/Memory
  • Container metrics
  • Node metrics
  • Cluster health

Cloud SQL Metrics:
  • Database connections
  • Query performance
  • Replication lag
  • Storage usage
```

### 2. Application Metrics

**Custom metrics from your applications**

```python
# Python example
from google.cloud import monitoring_v3
import time

client = monitoring_v3.MetricServiceClient()
project_name = f"projects/{project_id}"

series = monitoring_v3.TimeSeries()
series.metric.type = "custom.googleapis.com/my_metric"
series.resource.type = "global"

point = series.points.add()
point.value.double_value = 42.0
point.interval.end_time.seconds = int(time.time())

client.create_time_series(name=project_name, time_series=[series])
```

### 3. Log-Based Metrics

**Metrics derived from logs**

```bash
# Create log-based metric
gcloud logging metrics create error_count \
  --description="Count of error logs" \
  --log-filter='severity>=ERROR'

# Create distribution metric
gcloud logging metrics create request_latency \
  --description="Request latency distribution" \
  --log-filter='resource.type="cloud_run_revision"' \
  --value-extractor='EXTRACT(jsonPayload.latency)'
```

---

## Dashboards

### Creating Dashboards

**Via Console:**
1. Navigate to Monitoring → Dashboards
2. Click "Create Dashboard"
3. Add charts and widgets
4. Configure metrics and filters
5. Save dashboard

**Via gcloud:**

```bash
# Create dashboard from JSON
gcloud monitoring dashboards create --config-from-file=dashboard.json
```

**Dashboard JSON Example:**

```json
{
  "displayName": "Application Dashboard",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "CPU Utilization",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"gce_instance\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        }
      }
    ]
  }
}
```

### Dashboard Best Practices

```
✓ Group related metrics
✓ Use consistent time ranges
✓ Add meaningful titles
✓ Use appropriate chart types
✓ Include SLO indicators
✓ Add links to runbooks
✓ Use filters effectively
✓ Share with team
```

---

## Alerting Policies

### Creating Alert Policies

**Basic Alert:**

```bash
# Create CPU alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Alert" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s \
  --condition-filter='resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization"'
```

**Alert Policy JSON:**

```json
{
  "displayName": "High Error Rate",
  "conditions": [{
    "displayName": "Error rate > 5%",
    "conditionThreshold": {
      "filter": "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.label.response_code_class=\"5xx\"",
      "comparison": "COMPARISON_GT",
      "thresholdValue": 0.05,
      "duration": "60s",
      "aggregations": [{
        "alignmentPeriod": "60s",
        "perSeriesAligner": "ALIGN_RATE"
      }]
    }
  }],
  "notificationChannels": ["projects/PROJECT_ID/notificationChannels/CHANNEL_ID"],
  "alertStrategy": {
    "autoClose": "1800s"
  }
}
```

### Notification Channels

**Supported channels:**
- Email
- SMS
- Slack
- PagerDuty
- Webhooks
- Pub/Sub
- Mobile app

```bash
# Create email notification channel
gcloud alpha monitoring channels create \
  --display-name="Team Email" \
  --type=email \
  --channel-labels=email_address=team@example.com

# Create Slack channel
gcloud alpha monitoring channels create \
  --display-name="Slack Alerts" \
  --type=slack \
  --channel-labels=channel_name=#alerts,url=WEBHOOK_URL
```

### Alert Conditions

**Threshold Conditions:**

```yaml
Condition Types:
  • Metric threshold
  • Metric absence
  • Forecast threshold
  • Process health
  • Uptime check

Comparison Operators:
  • Greater than (>)
  • Less than (<)
  • Equal to (=)
  • Not equal to (!=)

Aggregation:
  • Mean
  • Sum
  • Min/Max
  • Count
  • Percentiles
```

---

## Uptime Checks

### HTTP/HTTPS Checks

```bash
# Create uptime check
gcloud monitoring uptime-checks create my-check \
  --display-name="Website Uptime" \
  --resource-type=uptime-url \
  --monitored-resource=https://example.com \
  --check-interval=60s \
  --timeout=10s
```

**Uptime Check Configuration:**

```json
{
  "displayName": "API Health Check",
  "monitoredResource": {
    "type": "uptime_url",
    "labels": {
      "host": "api.example.com"
    }
  },
  "httpCheck": {
    "path": "/health",
    "port": 443,
    "useSsl": true,
    "validateSsl": true,
    "requestMethod": "GET",
    "acceptedResponseStatusCodes": [{
      "statusClass": "STATUS_CLASS_2XX"
    }]
  },
  "period": "60s",
  "timeout": "10s",
  "selectedRegions": [
    "USA",
    "EUROPE",
    "ASIA_PACIFIC"
  ]
}
```

### TCP Checks

```bash
# Create TCP check
gcloud monitoring uptime-checks create db-check \
  --display-name="Database Connection" \
  --resource-type=uptime-url \
  --monitored-resource=tcp://db.example.com:5432 \
  --check-interval=300s
```

---

## SLO Monitoring

### Service Level Objectives

**Creating SLOs:**

```yaml
SLO Components:
  • SLI (Service Level Indicator)
  • Target (e.g., 99.9%)
  • Time window (rolling or calendar)
  • Error budget

Common SLIs:
  • Availability
  • Latency
  • Error rate
  • Throughput
```

**SLO Configuration:**

```json
{
  "displayName": "API Availability SLO",
  "serviceLevelIndicator": {
    "requestBased": {
      "goodTotalRatio": {
        "goodServiceFilter": "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.label.response_code_class=\"2xx\"",
        "totalServiceFilter": "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\""
      }
    }
  },
  "goal": 0.999,
  "rollingPeriod": "2592000s"
}
```

### Error Budget Alerts

```bash
# Create error budget alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Error Budget Alert" \
  --condition-display-name="Error budget < 10%" \
  --condition-threshold-value=0.1 \
  --condition-threshold-duration=300s
```

---

## Metrics Explorer

### Query Builder

**Using Metrics Explorer:**

```
1. Select resource type (e.g., GCE Instance)
2. Select metric (e.g., CPU utilization)
3. Add filters (e.g., zone, labels)
4. Configure aggregation
5. Set time range
6. View chart
```

**MQL (Monitoring Query Language):**

```
fetch gce_instance
| metric 'compute.googleapis.com/instance/cpu/utilization'
| group_by 1m, [value_utilization_mean: mean(value.utilization)]
| every 1m
| filter zone == 'us-central1-a'
```

**PromQL Support:**

```promql
# Average CPU by instance
avg by (instance_name) (
  compute_googleapis_com:instance_cpu_utilization
)

# Request rate
rate(
  run_googleapis_com:request_count[5m]
)

# 95th percentile latency
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[5m])
)
```

---

## Monitoring Agent

### Installing the Agent

**Compute Engine:**

```bash
# Install monitoring agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure agent
sudo nano /etc/google-cloud-ops-agent/config.yaml
```

**Agent Configuration:**

```yaml
# /etc/google-cloud-ops-agent/config.yaml
metrics:
  receivers:
    hostmetrics:
      type: hostmetrics
      collection_interval: 60s
  processors:
    metrics_filter:
      type: exclude_metrics
      metrics_pattern:
        - system.network.dropped
  exporters:
    google:
      type: google_cloud_monitoring
  service:
    pipelines:
      default_pipeline:
        receivers: [hostmetrics]
        processors: [metrics_filter]
        exporters: [google]
```

---

## Custom Metrics

### Creating Custom Metrics

**Python SDK:**

```python
from google.cloud import monitoring_v3
from google.api import metric_pb2 as ga_metric
from google.api import label_pb2 as ga_label

def create_metric_descriptor(project_id):
    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{project_id}"
    
    descriptor = ga_metric.MetricDescriptor()
    descriptor.type = "custom.googleapis.com/my_metric"
    descriptor.metric_kind = ga_metric.MetricDescriptor.MetricKind.GAUGE
    descriptor.value_type = ga_metric.MetricDescriptor.ValueType.DOUBLE
    descriptor.description = "My custom metric"
    
    descriptor = client.create_metric_descriptor(
        name=project_name, metric_descriptor=descriptor
    )
    print(f"Created {descriptor.name}")

def write_time_series(project_id):
    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{project_id}"
    
    series = monitoring_v3.TimeSeries()
    series.metric.type = "custom.googleapis.com/my_metric"
    series.resource.type = "global"
    
    now = time.time()
    seconds = int(now)
    nanos = int((now - seconds) * 10 ** 9)
    interval = monitoring_v3.TimeInterval(
        {"end_time": {"seconds": seconds, "nanos": nanos}}
    )
    point = monitoring_v3.Point(
        {"interval": interval, "value": {"double_value": 42.0}}
    )
    series.points = [point]
    
    client.create_time_series(name=project_name, time_series=[series])
```

**Node.js SDK:**

```javascript
const monitoring = require('@google-cloud/monitoring');
const client = new monitoring.MetricServiceClient();

async function writeTimeSeriesData(projectId) {
  const dataPoint = {
    interval: {
      endTime: {
        seconds: Date.now() / 1000,
      },
    },
    value: {
      doubleValue: 42.0,
    },
  };

  const timeSeriesData = {
    metric: {
      type: 'custom.googleapis.com/my_metric',
    },
    resource: {
      type: 'global',
    },
    points: [dataPoint],
  };

  const request = {
    name: client.projectPath(projectId),
    timeSeries: [timeSeriesData],
  };

  await client.createTimeSeries(request);
  console.log('Done writing time series data.');
}
```

---

## Integration with Services

### GKE Integration

```yaml
# Deploy Prometheus to GKE
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      external_labels:
        cluster: my-cluster
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
```

### Cloud Run Integration

```bash
# Cloud Run automatically exports metrics
# View in Monitoring console or query via API

# Example: Query request count
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_count"' \
  --format=json
```

---

## Best Practices

### Monitoring Strategy

```
✓ Define clear SLIs and SLOs
✓ Monitor golden signals (latency, traffic, errors, saturation)
✓ Set up meaningful alerts
✓ Avoid alert fatigue
✓ Use dashboards effectively
✓ Implement custom metrics for business KPIs
✓ Regular review of monitoring setup
✓ Document alert response procedures
```

### Alert Configuration

```
✓ Set appropriate thresholds
✓ Use multiple notification channels
✓ Configure alert auto-close
✓ Add documentation links
✓ Test alerts regularly
✓ Use alert grouping
✓ Implement escalation policies
✓ Monitor alert effectiveness
```

### Performance

```
✓ Use appropriate aggregation periods
✓ Limit metric cardinality
✓ Use metric filters
✓ Optimize dashboard queries
✓ Archive old metrics
✓ Use sampling for high-volume metrics
```

---

## Troubleshooting

### Common Issues

**Missing Metrics:**
```bash
# Check if service is enabled
gcloud services list --enabled | grep monitoring

# Verify IAM permissions
gcloud projects get-iam-policy PROJECT_ID

# Check agent status
sudo systemctl status google-cloud-ops-agent
```

**Alert Not Firing:**
```bash
# Verify alert policy
gcloud alpha monitoring policies list

# Check notification channels
gcloud alpha monitoring channels list

# Test notification channel
gcloud alpha monitoring channels verify CHANNEL_ID
```

---

## Cost Optimization

### Pricing

```
Free Tier (per month):
  • First 150 MB of metrics: Free
  • API calls: 1 million free

Paid Tier:
  • Metrics ingestion: $0.2580 per MB
  • API calls: $0.01 per 1,000 calls
```

### Optimization Tips

```bash
# Reduce metric cardinality
# Use metric filters
# Increase collection intervals
# Archive old metrics
# Use log-based metrics sparingly

# Example: Filter metrics
gcloud monitoring time-series list \
  --filter='metric.type="compute.googleapis.com/instance/cpu/utilization" AND resource.labels.zone="us-central1-a"'
```

---

## Additional Resources

- [Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Metrics List](https://cloud.google.com/monitoring/api/metrics_gcp)
- [MQL Reference](https://cloud.google.com/monitoring/mql)
- [PromQL Support](https://cloud.google.com/stackdriver/docs/managed-prometheus/query)
- [Best Practices](https://cloud.google.com/monitoring/best-practices)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
