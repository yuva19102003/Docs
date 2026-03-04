# API Monitoring

Complete guide to monitoring, tracking, and optimizing Google Cloud API usage and performance.

---

## 📚 Overview

Effective API monitoring ensures reliability, performance, and cost optimization. This guide covers metrics, logging, alerting, and troubleshooting for GCP APIs.

**Key Areas:**
- **Usage Metrics**: Track API calls, quotas, and limits
- **Performance**: Monitor latency and error rates
- **Cost Tracking**: Understand API-related costs
- **Alerting**: Get notified of issues
- **Troubleshooting**: Debug API problems

---

## 📊 API Metrics

### 1. Key Metrics to Monitor

```
┌────────────────────────────────────────────────────────┐
│  Essential API Metrics                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Request Metrics:                                      │
│  • Request count (total API calls)                     │
│  • Requests per second (RPS)                           │
│  • Request size (bytes)                                │
│  • Response size (bytes)                               │
│                                                         │
│  Performance Metrics:                                  │
│  • Latency (p50, p95, p99)                            │
│  • Response time                                       │
│  • Time to first byte (TTFB)                          │
│  • Backend latency                                     │
│                                                         │
│  Error Metrics:                                        │
│  • Error rate (4xx, 5xx)                              │
│  • Error count by type                                 │
│  • Quota exceeded errors                               │
│  • Authentication failures                             │
│                                                         │
│  Quota Metrics:                                        │
│  • Quota usage percentage                              │
│  • Quota limit                                         │
│  • Quota exceeded count                                │
│  • Rate limit hits                                     │
└────────────────────────────────────────────────────────┘
```

### 2. Viewing Metrics in Console

```
Navigation: APIs & Services → Dashboard

View:
• API requests (last 30 days)
• Traffic by API
• Errors by API
• Latency percentiles
• Quota usage

Filters:
• Time range
• Specific API
• Method
• Response code
```

### 3. Cloud Monitoring Metrics

```bash
# List API request metrics
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count"' \
  --format=json

# Query specific API
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND resource.labels.service="compute.googleapis.com"'

# View latency metrics
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_latencies"'

# View quota usage
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage"'

# View error rates
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND metric.labels.response_code_class="5xx"'
```

---

## 📝 API Logging

### 1. Enable API Audit Logs

```bash
# Enable audit logs for all services
# Via Console: IAM & Admin → Audit Logs

# Enable for specific service
gcloud projects set-iam-policy PROJECT_ID policy.json

# policy.json
{
  "auditConfigs": [
    {
      "service": "compute.googleapis.com",
      "auditLogConfigs": [
        {"logType": "ADMIN_READ"},
        {"logType": "DATA_READ"},
        {"logType": "DATA_WRITE"}
      ]
    }
  ]
}
```

### 2. Query API Logs

```bash
# View all API calls
gcloud logging read \
  'protoPayload.serviceName="compute.googleapis.com"' \
  --limit=50 \
  --format=json

# View failed API calls
gcloud logging read \
  'protoPayload.serviceName="compute.googleapis.com" AND protoPayload.status.code!=0' \
  --limit=50

# View specific method calls
gcloud logging read \
  'protoPayload.methodName="v1.compute.instances.insert"' \
  --limit=50

# View API calls by user
gcloud logging read \
  'protoPayload.authenticationInfo.principalEmail="alice@company.com"' \
  --limit=50

# View quota exceeded errors
gcloud logging read \
  'protoPayload.status.message=~"quota"' \
  --limit=50
```

### 3. Structured Logging Query

```bash
# Complex query with multiple filters
gcloud logging read '
  resource.type="api"
  AND protoPayload.serviceName="compute.googleapis.com"
  AND protoPayload.methodName=~"instances"
  AND timestamp>="2026-03-01T00:00:00Z"
  AND timestamp<"2026-03-31T23:59:59Z"
' --limit=100 --format=json
```

---

## 🚨 Alerting

### 1. Create Alert Policies

```bash
# Alert on high error rate
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High API Error Rate" \
  --condition-display-name="Error rate > 5%" \
  --condition-threshold-value=0.05 \
  --condition-threshold-duration=300s \
  --condition-filter='
    metric.type="serviceruntime.googleapis.com/api/request_count"
    AND metric.labels.response_code_class="5xx"
  '

# Alert on quota usage
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Quota Usage" \
  --condition-display-name="Quota usage > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s \
  --condition-filter='
    metric.type="serviceruntime.googleapis.com/quota/allocation/usage"
  '

# Alert on high latency
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High API Latency" \
  --condition-display-name="P95 latency > 1s" \
  --condition-threshold-value=1000 \
  --condition-threshold-duration=300s \
  --condition-filter='
    metric.type="serviceruntime.googleapis.com/api/request_latencies"
  '
```

### 2. Log-Based Alerts

```bash
# Alert on specific error messages
gcloud logging sinks create api-error-alert \
  --log-filter='
    protoPayload.status.code!=0
    AND protoPayload.serviceName="compute.googleapis.com"
  ' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/api-errors

# Alert on quota exceeded
gcloud logging sinks create quota-exceeded-alert \
  --log-filter='protoPayload.status.message=~"quota exceeded"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/quota-alerts

# Alert on authentication failures
gcloud logging sinks create auth-failure-alert \
  --log-filter='protoPayload.status.code=7' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/auth-failures
```

---

## 📈 Custom Dashboards

### 1. Create Monitoring Dashboard

```python
from google.cloud import monitoring_dashboard_v1

def create_api_monitoring_dashboard(project_id):
    """Create comprehensive API monitoring dashboard"""
    client = monitoring_dashboard_v1.DashboardsServiceClient()
    
    dashboard = monitoring_dashboard_v1.Dashboard(
        display_name="API Monitoring Dashboard",
        grid_layout=monitoring_dashboard_v1.GridLayout(
            widgets=[
                # Request count widget
                monitoring_dashboard_v1.Widget(
                    title="API Request Count",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter='metric.type="serviceruntime.googleapis.com/api/request_count"',
                                        aggregation=monitoring_dashboard_v1.Aggregation(
                                            alignment_period={'seconds': 60},
                                            per_series_aligner=monitoring_dashboard_v1.Aggregation.Aligner.ALIGN_RATE
                                        )
                                    )
                                )
                            )
                        ]
                    )
                ),
                # Error rate widget
                monitoring_dashboard_v1.Widget(
                    title="API Error Rate",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND metric.labels.response_code_class="5xx"'
                                    )
                                )
                            )
                        ]
                    )
                ),
                # Latency widget
                monitoring_dashboard_v1.Widget(
                    title="API Latency (P95)",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter='metric.type="serviceruntime.googleapis.com/api/request_latencies"'
                                    )
                                )
                            )
                        ]
                    )
                ),
                # Quota usage widget
                monitoring_dashboard_v1.Widget(
                    title="Quota Usage",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage"'
                                    )
                                )
                            )
                        ]
                    )
                ),
            ]
        )
    )
    
    parent = f"projects/{project_id}"
    response = client.create_dashboard(parent=parent, dashboard=dashboard)
    print(f"Dashboard created: {response.name}")
    return response

# Usage
create_api_monitoring_dashboard("my-project-123")
```

### 2. BigQuery Analysis

```sql
-- Export logs to BigQuery for analysis
-- Enable log export: Logging → Log Router → Create Sink

-- Analyze API usage by service
SELECT
  protopayload_auditlog.serviceName AS service,
  COUNT(*) AS request_count,
  COUNTIF(protopayload_auditlog.status.code != 0) AS error_count,
  ROUND(COUNTIF(protopayload_auditlog.status.code != 0) / COUNT(*) * 100, 2) AS error_rate_percent
FROM `project.dataset.cloudaudit_googleapis_com_activity`
WHERE DATE(timestamp) = CURRENT_DATE()
GROUP BY service
ORDER BY request_count DESC;

-- Analyze API usage by user
SELECT
  protopayload_auditlog.authenticationInfo.principalEmail AS user,
  protopayload_auditlog.serviceName AS service,
  COUNT(*) AS request_count
FROM `project.dataset.cloudaudit_googleapis_com_activity`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY user, service
ORDER BY request_count DESC
LIMIT 20;

-- Analyze quota exceeded errors
SELECT
  protopayload_auditlog.serviceName AS service,
  protopayload_auditlog.methodName AS method,
  COUNT(*) AS quota_exceeded_count
FROM `project.dataset.cloudaudit_googleapis_com_activity`
WHERE protopayload_auditlog.status.message LIKE '%quota%'
  AND DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service, method
ORDER BY quota_exceeded_count DESC;

-- Analyze API latency
SELECT
  protopayload_auditlog.serviceName AS service,
  APPROX_QUANTILES(
    TIMESTAMP_DIFF(
      protopayload_auditlog.response.timestamp,
      protopayload_auditlog.request.timestamp,
      MILLISECOND
    ), 100
  )[OFFSET(50)] AS p50_latency_ms,
  APPROX_QUANTILES(
    TIMESTAMP_DIFF(
      protopayload_auditlog.response.timestamp,
      protopayload_auditlog.request.timestamp,
      MILLISECOND
    ), 100
  )[OFFSET(95)] AS p95_latency_ms,
  APPROX_QUANTILES(
    TIMESTAMP_DIFF(
      protopayload_auditlog.response.timestamp,
      protopayload_auditlog.request.timestamp,
      MILLISECOND
    ), 100
  )[OFFSET(99)] AS p99_latency_ms
FROM `project.dataset.cloudaudit_googleapis_com_activity`
WHERE DATE(timestamp) = CURRENT_DATE()
GROUP BY service
ORDER BY p95_latency_ms DESC;
```

---

## 🔧 Troubleshooting

### 1. High Error Rates

```bash
# Identify error patterns
gcloud logging read '
  protoPayload.status.code!=0
  AND timestamp>="2026-03-04T00:00:00Z"
' --limit=100 --format=json | \
  jq -r '.[] | "\(.protoPayload.status.code): \(.protoPayload.status.message)"' | \
  sort | uniq -c | sort -rn

# Check specific error details
gcloud logging read '
  protoPayload.status.code=7
' --limit=10 --format=json | \
  jq '.[] | {
    time: .timestamp,
    user: .protoPayload.authenticationInfo.principalEmail,
    service: .protoPayload.serviceName,
    method: .protoPayload.methodName,
    error: .protoPayload.status.message
  }'
```

### 2. Performance Issues

```bash
# Identify slow API calls
gcloud logging read '
  protoPayload.serviceName="compute.googleapis.com"
  AND jsonPayload.latency > 1000
' --limit=50

# Analyze latency by method
gcloud monitoring time-series list \
  --filter='
    metric.type="serviceruntime.googleapis.com/api/request_latencies"
    AND metric.labels.method=~".*"
  ' \
  --format=json | \
  jq -r '.[] | "\(.metric.labels.method): \(.points[0].value.distributionValue.mean)"'
```

### 3. Quota Issues

```bash
# Check current quota usage
gcloud compute project-info describe \
  --project=PROJECT_ID \
  --format="table(quotas.metric,quotas.limit,quotas.usage)"

# Find quota exceeded errors
gcloud logging read '
  protoPayload.status.message=~"quota"
' --limit=50 --format=json | \
  jq -r '.[] | {
    time: .timestamp,
    service: .protoPayload.serviceName,
    method: .protoPayload.methodName,
    error: .protoPayload.status.message
  }'
```

---

## 📋 Monitoring Checklist

### Setup
- [ ] Enable audit logging for all services
- [ ] Export logs to BigQuery
- [ ] Create monitoring dashboards
- [ ] Set up alert policies
- [ ] Configure notification channels
- [ ] Document monitoring procedures

### Daily Monitoring
- [ ] Check error rates
- [ ] Review quota usage
- [ ] Monitor latency metrics
- [ ] Check for alerts
- [ ] Review unusual patterns

### Weekly Reviews
- [ ] Analyze API usage trends
- [ ] Review cost implications
- [ ] Check for optimization opportunities
- [ ] Update dashboards as needed
- [ ] Review and tune alerts

### Monthly Analysis
- [ ] Comprehensive usage analysis
- [ ] Cost optimization review
- [ ] Quota planning
- [ ] Performance optimization
- [ ] Documentation updates

---

## ✅ Best Practices

### Monitoring
- [ ] Monitor all critical APIs
- [ ] Set up proactive alerts
- [ ] Track both usage and performance
- [ ] Regular dashboard reviews
- [ ] Document baseline metrics

### Logging
- [ ] Enable comprehensive audit logs
- [ ] Export logs for long-term analysis
- [ ] Use structured logging
- [ ] Implement log retention policies
- [ ] Regular log analysis

### Alerting
- [ ] Alert on error rate thresholds
- [ ] Alert on quota usage (80%+)
- [ ] Alert on latency degradation
- [ ] Use appropriate notification channels
- [ ] Test alert policies regularly

### Optimization
- [ ] Regular performance reviews
- [ ] Identify and fix bottlenecks
- [ ] Optimize API usage patterns
- [ ] Implement caching where appropriate
- [ ] Monitor cost implications

---

## 🎓 Summary

API monitoring is essential for:
- Ensuring reliability and performance
- Proactive issue detection
- Cost optimization
- Capacity planning
- Compliance and auditing

Key takeaways:
1. Monitor request counts, errors, and latency
2. Set up proactive alerts
3. Use dashboards for visualization
4. Export logs to BigQuery for analysis
5. Regular reviews and optimization

---

**Last Updated:** March 2026
**Version:** 2.0
