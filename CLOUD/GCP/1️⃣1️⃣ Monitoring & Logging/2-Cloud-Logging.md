# Cloud Logging

Centralized log management and analysis service.

---

## Overview

Cloud Logging (formerly Stackdriver Logging) stores, searches, analyzes, monitors, and alerts on log data and events from GCP and AWS.

### Key Features

```
┌─────────────────────────────────────┐
│       Cloud Logging                 │
├─────────────────────────────────────┤
│  • Centralized log storage          │
│  • Real-time log streaming          │
│  • Advanced log queries             │
│  • Log-based metrics                │
│  • Log sinks (export)               │
│  • Audit logging                    │
│  • Error reporting integration      │
│  • 30-day retention (default)       │
└─────────────────────────────────────┘
```

---

## Log Types

### 1. Audit Logs

**Admin Activity Logs:**
- Who did what, where, and when
- Always enabled
- Free (no charge)
- 400-day retention

**Data Access Logs:**
- Read/write operations on data
- Disabled by default
- Chargeable
- 30-day retention (default)

**System Event Logs:**
- GCP system events
- Always enabled
- Free
- 400-day retention

**Policy Denied Logs:**
- Security policy violations
- Enabled by default
- Free
- 30-day retention

```bash
# Enable Data Access logs
gcloud logging settings update \
  --organization=ORG_ID \
  --enable-data-access-logs
```

### 2. Application Logs

**Structured Logging:**

```python
# Python example
import google.cloud.logging
import logging

client = google.cloud.logging.Client()
client.setup_logging()

logging.info('Application started', extra={
    'user_id': '12345',
    'action': 'login'
})
```

**Node.js example:**

```javascript
const {Logging} = require('@google-cloud/logging');
const logging = new Logging();
const log = logging.log('my-log');

const metadata = {
  resource: {type: 'global'},
  severity: 'INFO',
};

const entry = log.entry(metadata, {
  message: 'Application started',
  user_id: '12345',
  action: 'login'
});

await log.write(entry);
```

### 3. System Logs

Automatically collected from GCP services:
- Compute Engine
- GKE
- Cloud Run
- App Engine
- Cloud Functions
- Load Balancers

---

## Log Explorer

### Querying Logs

**Basic Query:**

```
resource.type="gce_instance"
severity>=ERROR
timestamp>="2026-03-01T00:00:00Z"
```

**Advanced Query:**

```
resource.type="cloud_run_revision"
AND resource.labels.service_name="my-service"
AND jsonPayload.message=~"error.*"
AND timestamp>="2026-03-09T00:00:00Z"
```

**Using gcloud:**

```bash
# View recent logs
gcloud logging read "resource.type=gce_instance" --limit=10

# Filter by severity
gcloud logging read "severity>=ERROR" --limit=50

# Filter by time range
gcloud logging read \
  "timestamp>=\"2026-03-09T00:00:00Z\"" \
  --limit=100 \
  --format=json
```

### Query Operators

```
Comparison:
  = (equals)
  != (not equals)
  > < >= <= (numeric comparison)
  =~ (regex match)
  !~ (regex not match)

Logical:
  AND
  OR
  NOT

Functions:
  timestamp()
  resource.type
  severity
  jsonPayload.*
  textPayload
```

---

## Log Sinks

### Exporting Logs

**To BigQuery:**

```bash
# Create BigQuery sink
gcloud logging sinks create my-bq-sink \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/logs_dataset \
  --log-filter='resource.type="gce_instance" AND severity>=ERROR'
```

**To Cloud Storage:**

```bash
# Create GCS sink
gcloud logging sinks create my-gcs-sink \
  storage.googleapis.com/my-logs-bucket \
  --log-filter='resource.type="cloud_run_revision"'
```

**To Pub/Sub:**

```bash
# Create Pub/Sub sink
gcloud logging sinks create my-pubsub-sink \
  pubsub.googleapis.com/projects/PROJECT_ID/topics/logs-topic \
  --log-filter='severity>=WARNING'
```

### Sink Configuration

```json
{
  "name": "my-sink",
  "destination": "bigquery.googleapis.com/projects/PROJECT_ID/datasets/logs",
  "filter": "resource.type=\"gce_instance\" AND severity>=ERROR",
  "includeChildren": true,
  "bigqueryOptions": {
    "usePartitionedTables": true
  }
}
```

---

## Log-Based Metrics

### Creating Metrics

**Counter Metric:**

```bash
# Create counter metric
gcloud logging metrics create error_count \
  --description="Count of error logs" \
  --log-filter='severity>=ERROR'
```

**Distribution Metric:**

```bash
# Create distribution metric
gcloud logging metrics create request_latency \
  --description="Request latency distribution" \
  --log-filter='resource.type="cloud_run_revision"' \
  --value-extractor='EXTRACT(jsonPayload.latency)' \
  --metric-kind=DELTA \
  --value-type=DISTRIBUTION
```

### Using Log-Based Metrics

```bash
# Query metric
gcloud monitoring time-series list \
  --filter='metric.type="logging.googleapis.com/user/error_count"' \
  --format=json

# Create alert on log-based metric
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Error Count" \
  --condition-threshold-value=100 \
  --condition-filter='metric.type="logging.googleapis.com/user/error_count"'
```

---

## Log Sampling

### Reducing Log Volume

**Exclusion Filters:**

```bash
# Exclude debug logs
gcloud logging exclusions create exclude-debug \
  --log-filter='severity<WARNING'

# Exclude specific resources
gcloud logging exclusions create exclude-test \
  --log-filter='resource.labels.namespace_name="test"'
```

**Sampling:**

```bash
# Sample 10% of logs
gcloud logging sinks create sampled-logs \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/logs \
  --log-filter='sample(insertId, 0.1)'
```

---

## Best Practices

### Logging Strategy

```
✓ Use structured logging
✓ Include correlation IDs
✓ Set appropriate log levels
✓ Implement log sampling for high-volume logs
✓ Use log sinks for long-term retention
✓ Exclude sensitive data from logs
✓ Regular log analysis
✓ Monitor log ingestion costs
```

### Performance

```
✓ Use appropriate log levels
✓ Avoid excessive logging
✓ Use async logging
✓ Batch log writes
✓ Implement sampling
✓ Use exclusion filters
```

---

## Additional Resources

- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Query Language](https://cloud.google.com/logging/docs/view/logging-query-language)
- [Log Sinks](https://cloud.google.com/logging/docs/export)
- [Best Practices](https://cloud.google.com/logging/docs/best-practices)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
