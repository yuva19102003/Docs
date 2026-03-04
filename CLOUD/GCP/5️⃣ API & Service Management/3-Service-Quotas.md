# Service Quotas

Complete guide to understanding, managing, and requesting quota increases for Google Cloud Platform services.

---

## 📚 Overview

Quotas protect GCP infrastructure and users by preventing unexpected resource consumption. Understanding and managing quotas is essential for scaling applications and avoiding service disruptions.

**Key Concepts:**
- **Rate Quotas**: Requests per time period (per minute, per day)
- **Allocation Quotas**: Total resources you can have (VMs, CPUs, disk space)
- **Regional vs Global**: Some quotas are per-region, others project-wide
- **Quota Increases**: Request higher limits when needed

---

## 🎯 Understanding Quotas

### 1. Quota Types

```
┌────────────────────────────────────────────────────────┐
│  Quota Categories                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Rate Quotas (Time-based):                            │
│  • API requests per minute                             │
│  • Queries per day                                     │
│  • Writes per second                                   │
│  • Resets automatically                                │
│  • Example: 1,000 API calls/minute                     │
│                                                         │
│  Allocation Quotas (Resource-based):                   │
│  • Number of VMs                                       │
│  • Total CPUs                                          │
│  • Persistent disk size                                │
│  • Requires quota increase request                     │
│  • Example: 24 CPUs per region                        │
│                                                         │
│  Regional Quotas:                                      │
│  • Per-region limits                                   │
│  • Independent across regions                          │
│  • Example: 24 CPUs in us-central1                    │
│                                                         │
│  Global Quotas:                                        │
│  • Project-wide limits                                 │
│  • Across all regions                                  │
│  • Example: 100 Cloud SQL instances                    │
└────────────────────────────────────────────────────────┘
```

### 2. Common Default Quotas

```
┌────────────────────────────────────────────────────────┐
│  Default Quotas (Examples - March 2026)                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine (per region):                         │
│  • CPUs: 24                                            │
│  • Persistent Disk SSD: 500 GB                         │
│  • Persistent Disk Standard: 10 TB                     │
│  • In-use IP addresses: 8                              │
│  • VM instances: Varies by machine type                │
│                                                         │
│  Cloud Storage:                                        │
│  • Buckets: 10,000 per project                         │
│  • Objects: Unlimited                                  │
│  • Bandwidth: 200 Gbps egress                          │
│  • Operations: 5,000 writes/second per bucket          │
│                                                         │
│  BigQuery:                                             │
│  • Queries per day: Unlimited                          │
│  • Concurrent queries: 100                             │
│  • Slots (on-demand): 2,000                            │
│  • Storage: Unlimited                                  │
│                                                         │
│  Cloud SQL:                                            │
│  • Instances: 100 per project                          │
│  • Storage: 30 TB per instance                         │
│  • Connections: Varies by tier                         │
│  • Read replicas: 10 per instance                      │
│                                                         │
│  GKE:                                                  │
│  • Clusters: 50 per project per region                 │
│  • Nodes: 5,000 per cluster                            │
│  • Pods: 110 per node (default)                        │
│                                                         │
│  Note: Quotas vary by project age, usage, and region  │
└────────────────────────────────────────────────────────┘
```

---

## 🔍 Viewing Quotas

### 1. Via Console

```
Navigation: IAM & Admin → Quotas

Features:
• View all quotas for project
• Filter by service, region, metric
• See current usage vs limit
• Request quota increases
• Track quota increase requests

Filters:
• Service: Compute Engine, Cloud Storage, etc.
• Dimensions: Region, zone, global
• Metric: CPUs, Disks, IP addresses, etc.
• Status: Usage percentage
```

### 2. Via gcloud CLI

```bash
# View Compute Engine quotas
gcloud compute project-info describe \
  --project=PROJECT_ID

# View quotas for specific region
gcloud compute regions describe us-central1

# View specific quota
gcloud compute project-info describe \
  --project=PROJECT_ID \
  --format="value(quotas.filter(metric:CPUS))"

# List all quotas with usage
gcloud compute project-info describe \
  --project=PROJECT_ID \
  --format="table(quotas.metric,quotas.limit,quotas.usage)"

# Check quota for specific service
gcloud services quota list \
  --service=compute.googleapis.com \
  --consumer=projects/PROJECT_ID
```

### 3. Via API

```python
from google.cloud import compute_v1

def get_project_quotas(project_id):
    """Get all project quotas"""
    client = compute_v1.ProjectsClient()
    
    project = client.get(project=project_id)
    
    print(f"Quotas for project: {project_id}\n")
    
    for quota in project.quotas:
        usage_percent = (quota.usage / quota.limit * 100) if quota.limit > 0 else 0
        print(f"{quota.metric}:")
        print(f"  Limit: {quota.limit}")
        print(f"  Usage: {quota.usage}")
        print(f"  Usage: {usage_percent:.1f}%")
        print()

# Usage
get_project_quotas("my-project-123")
```

---

## 📈 Monitoring Quotas

### 1. Quota Metrics

```bash
# View quota usage in Cloud Monitoring
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage"' \
  --format=json

# Query specific quota
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage" AND metric.labels.quota_metric="compute.googleapis.com/cpus"'

# View quota exceeded errors
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/quota/exceeded"'
```

### 2. Quota Alerts

```bash
# Create alert for high quota usage
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Quota Usage" \
  --condition-display-name="CPU usage > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s \
  --condition-filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage" AND metric.labels.quota_metric="compute.googleapis.com/cpus"'

# Alert when quota is exceeded
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Quota Exceeded" \
  --condition-display-name="Quota exceeded" \
  --condition-filter='metric.type="serviceruntime.googleapis.com/quota/exceeded"'
```

### 3. Dashboard for Quota Monitoring

```python
# Create custom dashboard for quota monitoring
from google.cloud import monitoring_dashboard_v1

def create_quota_dashboard(project_id):
    """Create dashboard for quota monitoring"""
    client = monitoring_dashboard_v1.DashboardsServiceClient()
    
    dashboard = monitoring_dashboard_v1.Dashboard(
        display_name="Quota Usage Dashboard",
        grid_layout=monitoring_dashboard_v1.GridLayout(
            widgets=[
                monitoring_dashboard_v1.Widget(
                    title="CPU Quota Usage",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter='metric.type="serviceruntime.googleapis.com/quota/allocation/usage" AND metric.labels.quota_metric="compute.googleapis.com/cpus"'
                                    )
                                )
                            )
                        ]
                    )
                ),
                # Add more widgets for other quotas
            ]
        )
    )
    
    parent = f"projects/{project_id}"
    response = client.create_dashboard(parent=parent, dashboard=dashboard)
    print(f"Dashboard created: {response.name}")

# Usage
create_quota_dashboard("my-project-123")
```

---

## 📝 Requesting Quota Increases

### 1. Via Console

```
Navigation: IAM & Admin → Quotas

Steps:
1. Find the quota you want to increase
2. Select the checkbox next to the quota
3. Click "Edit Quotas" button
4. Enter new quota limit
5. Provide justification:
   • Why you need the increase
   • Expected usage pattern
   • Business impact
6. Submit request
7. Wait for approval (usually 2-3 business days)

Tips for Approval:
✓ Provide detailed justification
✓ Show current usage trends
✓ Explain business need
✓ Request reasonable increases
✓ Have billing enabled
✓ Good account standing
```

### 2. Via Support Case

```
For large quota increases or special cases:

1. Create support case
   Navigation: Support → Create Case

2. Select category: "Quota increase"

3. Provide details:
   • Project ID
   • Quota metric name
   • Current limit
   • Requested limit
   • Region (if applicable)
   • Detailed justification
   • Timeline/urgency

4. Submit and wait for response

Response Time:
• Standard: 2-3 business days
• Urgent: 1 business day (with justification)
• Very large increases: May take longer
```

### 3. Quota Increase Best Practices

```
✓ Request in advance (don't wait until you hit limit)
✓ Provide detailed business justification
✓ Show usage trends and projections
✓ Request reasonable increases (not 100x)
✓ Explain why default quota is insufficient
✓ Mention any time constraints
✓ Include expected growth pattern
✓ Reference similar approved requests (if any)

❌ Don't request without justification
❌ Don't request excessive increases
❌ Don't wait until quota is blocking production
❌ Don't submit duplicate requests
```

---

## ⚠️ Handling Quota Errors

### 1. Common Quota Errors

```bash
# Error: Quota exceeded
Error: Quota 'CPUS' exceeded. Limit: 24.0 in region us-central1.

# Solutions:
# 1. Delete unused resources
gcloud compute instances list --filter="status:TERMINATED"
gcloud compute instances delete INSTANCE_NAME --zone=ZONE

# 2. Use different region
gcloud compute instances create my-vm \
  --zone=us-east1-b  # Try different region

# 3. Request quota increase
# Via Console: IAM & Admin → Quotas

# 4. Use smaller machine types
gcloud compute instances create my-vm \
  --machine-type=e2-medium  # Instead of n1-standard-8
```

### 2. Rate Limit Errors

```python
# Error: Rate limit exceeded
# HTTP 429: Too Many Requests

# Solution: Implement exponential backoff
import time
import random
from google.api_core import retry
from google.api_core import exceptions

@retry.Retry(
    predicate=retry.if_exception_type(
        exceptions.ResourceExhausted,
        exceptions.TooManyRequests
    ),
    initial=1.0,
    maximum=60.0,
    multiplier=2.0,
    deadline=300.0
)
def api_call_with_retry():
    """API call with automatic retry on rate limit"""
    # Your API call here
    pass

# Or manual exponential backoff
def call_api_with_backoff(max_retries=5):
    """Manual exponential backoff"""
    for attempt in range(max_retries):
        try:
            # Your API call
            return result
        except Exception as e:
            if "quota" in str(e).lower() or "rate" in str(e).lower():
                if attempt < max_retries - 1:
                    wait_time = (2 ** attempt) + random.uniform(0, 1)
                    print(f"Rate limited. Waiting {wait_time:.2f}s...")
                    time.sleep(wait_time)
                else:
                    raise
            else:
                raise
```

### 3. Quota Monitoring Script

```python
#!/usr/bin/env python3
"""
Monitor quotas and alert when approaching limits
"""

from google.cloud import compute_v1
from google.cloud import monitoring_v3
import smtplib
from email.mime.text import MIMEText

def check_quotas(project_id, threshold=0.8):
    """Check quotas and alert if usage > threshold"""
    client = compute_v1.ProjectsClient()
    project = client.get(project=project_id)
    
    alerts = []
    
    for quota in project.quotas:
        if quota.limit > 0:
            usage_percent = quota.usage / quota.limit
            
            if usage_percent >= threshold:
                alerts.append({
                    'metric': quota.metric,
                    'usage': quota.usage,
                    'limit': quota.limit,
                    'percent': usage_percent * 100
                })
    
    if alerts:
        send_alert_email(project_id, alerts)
    
    return alerts

def send_alert_email(project_id, alerts):
    """Send email alert for high quota usage"""
    message = f"High quota usage detected in project {project_id}:\n\n"
    
    for alert in alerts:
        message += f"{alert['metric']}: {alert['usage']}/{alert['limit']} ({alert['percent']:.1f}%)\n"
    
    # Send email (configure SMTP settings)
    print(message)  # Or send actual email

# Run daily via Cloud Scheduler
check_quotas("my-project-123", threshold=0.8)
```

---

## 🎯 Quota Optimization Strategies

### 1. Resource Cleanup

```bash
# Find and delete unused resources

# Stopped VMs (still using disk quota)
gcloud compute instances list \
  --filter="status:TERMINATED" \
  --format="table(name,zone,status)"

# Delete stopped VMs
gcloud compute instances delete INSTANCE_NAME --zone=ZONE

# Unattached disks
gcloud compute disks list \
  --filter="NOT users:*" \
  --format="table(name,zone,sizeGb)"

# Delete unattached disks
gcloud compute disks delete DISK_NAME --zone=ZONE

# Old snapshots
gcloud compute snapshots list \
  --filter="creationTimestamp<-P30D" \
  --format="table(name,diskSizeGb,creationTimestamp)"

# Delete old snapshots
gcloud compute snapshots delete SNAPSHOT_NAME

# Unused static IPs
gcloud compute addresses list \
  --filter="status:RESERVED" \
  --format="table(name,region,status)"

# Release unused IPs
gcloud compute addresses delete ADDRESS_NAME --region=REGION
```

### 2. Regional Distribution

```bash
# Spread resources across regions to avoid regional quotas

# Check quota in multiple regions
for region in us-central1 us-east1 us-west1; do
  echo "Region: $region"
  gcloud compute regions describe $region \
    --format="value(quotas.filter(metric:CPUS))"
done

# Deploy to region with available quota
gcloud compute instances create my-vm \
  --zone=us-east1-b  # Use region with available quota
```

### 3. Right-Sizing

```bash
# Use appropriate machine types to conserve quota

# ❌ BAD: Over-provisioned
gcloud compute instances create my-vm \
  --machine-type=n1-standard-32  # 32 CPUs

# ✓ GOOD: Right-sized
gcloud compute instances create my-vm \
  --machine-type=e2-medium  # 2 CPUs

# Use custom machine types
gcloud compute instances create my-vm \
  --custom-cpu=4 \
  --custom-memory=8GB
```

---

## 📋 Quota Management Checklist

### Monitoring
- [ ] Set up quota usage dashboards
- [ ] Configure alerts for 80% usage
- [ ] Regular quota reviews (monthly)
- [ ] Track quota trends
- [ ] Document quota limits

### Optimization
- [ ] Clean up unused resources regularly
- [ ] Right-size resources
- [ ] Distribute across regions
- [ ] Use appropriate machine types
- [ ] Implement resource lifecycle policies

### Planning
- [ ] Forecast quota needs
- [ ] Request increases in advance
- [ ] Plan for growth
- [ ] Document quota requirements
- [ ] Have contingency plans

### Incident Response
- [ ] Document quota error procedures
- [ ] Have escalation path
- [ ] Know how to request emergency increases
- [ ] Test quota limits in non-prod
- [ ] Train team on quota management

---

## 🎓 Next Steps

1. Explore [API Gateway](./4-API-Gateway.md) for API management
2. Use [Service Usage API](./5-Service-Usage-API.md) for automation
3. Set up [API Monitoring](./6-API-Monitoring.md) for observability
4. Return to [Enabling APIs](./2-Enabling-APIs.md) for API management

---

**Last Updated:** March 2026
**Version:** 2.0
