# Monitoring & Logging Best Practices

Production-ready observability guidelines.

---

## Monitoring Best Practices

### Golden Signals

Monitor the four golden signals:

```
1. Latency
   • Request duration
   • Response time
   • Processing time

2. Traffic
   • Requests per second
   • Concurrent users
   • Bandwidth usage

3. Errors
   • Error rate
   • Failed requests
   • Exception count

4. Saturation
   • CPU utilization
   • Memory usage
   • Disk I/O
   • Network capacity
```

### SLO Definition

```yaml
Define clear SLOs:
  Availability: 99.9%
  Latency: p95 < 200ms
  Error Rate: < 0.1%
  
Calculate error budget:
  Monthly downtime: 43.2 minutes
  Failed requests: 0.1% of total
```

### Alert Configuration

```
✓ Set meaningful thresholds
✓ Avoid alert fatigue
✓ Use multiple severity levels
✓ Include runbook links
✓ Test alerts regularly
✓ Configure escalation
✓ Auto-close resolved alerts
✓ Group related alerts
```

---

## Logging Best Practices

### Structured Logging

```json
{
  "timestamp": "2026-03-09T12:00:00Z",
  "severity": "ERROR",
  "message": "Database connection failed",
  "context": {
    "user_id": "12345",
    "request_id": "abc-123",
    "service": "api",
    "version": "1.0.0"
  },
  "error": {
    "type": "ConnectionError",
    "message": "Timeout after 30s",
    "stack_trace": "..."
  }
}
```

### Log Levels

```
Use appropriate log levels:

CRITICAL: System unusable
ERROR: Error events
WARNING: Warning messages
INFO: Informational messages
DEBUG: Debug information (dev only)

Production: INFO and above
Development: DEBUG and above
```

### Correlation IDs

```python
# Add correlation ID to all logs
import uuid
import logging

correlation_id = str(uuid.uuid4())

logging.info('Request started', extra={
    'correlation_id': correlation_id,
    'user_id': user_id
})
```

---

## Cost Optimization

### Monitoring Costs

```bash
# Reduce metric cardinality
# Use metric filters
# Increase collection intervals
# Sample high-volume metrics

# Example: Sample 10% of metrics
gcloud monitoring time-series list \
  --filter='sample(metric.label.instance_id, 0.1)'
```

### Logging Costs

```bash
# Exclude verbose logs
gcloud logging exclusions create exclude-debug \
  --log-filter='severity<WARNING'

# Sample high-volume logs
gcloud logging sinks create sampled-logs \
  bigquery.googleapis.com/projects/PROJECT/datasets/logs \
  --log-filter='sample(insertId, 0.1)'

# Set retention policies
gcloud logging buckets update _Default \
  --location=global \
  --retention-days=30
```

---

## Security Best Practices

### Audit Logging

```bash
# Enable Data Access logs for sensitive resources
gcloud logging settings update \
  --organization=ORG_ID \
  --enable-data-access-logs

# Export audit logs
gcloud logging sinks create audit-logs \
  bigquery.googleapis.com/projects/PROJECT/datasets/audit \
  --log-filter='logName:"cloudaudit.googleapis.com"'
```

### Access Control

```bash
# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:analyst@example.com \
  --role=roles/logging.viewer

# Separate read and write access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:app@PROJECT.iam.gserviceaccount.com \
  --role=roles/logging.logWriter
```

---

## Dashboard Design

### Effective Dashboards

```
✓ Group related metrics
✓ Use consistent time ranges
✓ Add meaningful titles
✓ Include SLO indicators
✓ Add links to runbooks
✓ Use appropriate chart types
✓ Implement drill-down capability
✓ Share with team
```

### Dashboard Example

```json
{
  "displayName": "Service Health Dashboard",
  "mosaicLayout": {
    "tiles": [
      {
        "widget": {
          "title": "Request Rate",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"run.googleapis.com/request_count\""
                }
              }
            }]
          }
        }
      },
      {
        "widget": {
          "title": "Error Rate",
          "scorecard": {
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"run.googleapis.com/request_count\" AND metric.label.response_code_class=\"5xx\""
              }
            }
          }
        }
      }
    ]
  }
}
```

---

## Incident Response

### Runbook Template

```markdown
# Service: API Gateway
# Alert: High Error Rate

## Symptoms
- Error rate > 5%
- Increased latency
- User complaints

## Investigation Steps
1. Check service status
2. Review recent deployments
3. Check dependencies
4. Review error logs
5. Check resource utilization

## Resolution Steps
1. Rollback if recent deployment
2. Scale up if resource constrained
3. Restart if memory leak
4. Contact on-call if needed

## Prevention
- Add more tests
- Improve monitoring
- Update documentation
```

---

## Checklist

### Monitoring Checklist

- [ ] Golden signals monitored
- [ ] SLOs defined and tracked
- [ ] Alerts configured
- [ ] Dashboards created
- [ ] Uptime checks enabled
- [ ] Custom metrics implemented
- [ ] Notification channels configured
- [ ] Runbooks documented

### Logging Checklist

- [ ] Structured logging implemented
- [ ] Correlation IDs added
- [ ] Appropriate log levels used
- [ ] Sensitive data excluded
- [ ] Log sinks configured
- [ ] Retention policies set
- [ ] Audit logging enabled
- [ ] Log-based metrics created

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
