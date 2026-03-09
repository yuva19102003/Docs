# GCP Cost Optimization Guide

Comprehensive strategies to reduce GCP costs while maintaining performance.

---

## Table of Contents

1. [Cost Analysis](#cost-analysis)
2. [Compute Optimization](#compute-optimization)
3. [Storage Optimization](#storage-optimization)
4. [Network Optimization](#network-optimization)
5. [Database Optimization](#database-optimization)
6. [Monitoring & Alerts](#monitoring--alerts)

---

## Cost Analysis

### Understanding Your Bill

```bash
# Export billing to BigQuery
gcloud billing accounts list

# Query costs by service
SELECT
  service.description as service,
  SUM(cost) as total_cost
FROM `project.billing_export.gcp_billing_export_v1_XXXXXX`
WHERE DATE(_PARTITIONTIME) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service
ORDER BY total_cost DESC;

# Query costs by project
SELECT
  project.name as project,
  SUM(cost) as total_cost
FROM `project.billing_export.gcp_billing_export_v1_XXXXXX`
WHERE DATE(_PARTITIONTIME) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY project
ORDER BY total_cost DESC;
```

### Set Up Budgets

```bash
# Create budget alert
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget" \
  --budget-amount=1000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100
```

---

## Compute Optimization

### 1. Right-Sizing VMs

**Identify Underutilized VMs:**
```sql
-- Query VM utilization
SELECT
  resource.labels.instance_id,
  AVG(value.double_value) as avg_cpu
FROM `project.monitoring.metrics`
WHERE metric.type = 'compute.googleapis.com/instance/cpu/utilization'
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY resource.labels.instance_id
HAVING avg_cpu < 0.2
ORDER BY avg_cpu;
```

**Recommendations:**
```bash
# Get rightsizing recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --location=us-central1 \
  --recommender=google.compute.instance.MachineTypeRecommender

# Apply recommendation
gcloud compute instances set-machine-type INSTANCE \
  --machine-type=e2-medium \
  --zone=us-central1-a
```

### 2. Committed Use Discounts

**Savings: Up to 57%**

```bash
# Purchase 1-year commitment
gcloud compute commitments create my-commitment \
  --region=us-central1 \
  --resources=vcpu=100,memory=400GB \
  --plan=12-month

# Purchase 3-year commitment (higher discount)
gcloud compute commitments create my-commitment-3y \
  --region=us-central1 \
  --resources=vcpu=100,memory=400GB \
  --plan=36-month
```

**When to Use:**
- Predictable workloads
- Long-term projects
- Production environments

### 3. Preemptible/Spot VMs

**Savings: Up to 91%**

```bash
# Create preemptible VM
gcloud compute instances create preemptible-vm \
  --zone=us-central1-a \
  --machine-type=n1-standard-4 \
  --preemptible

# Create spot VM
gcloud compute instances create spot-vm \
  --zone=us-central1-a \
  --machine-type=n1-standard-4 \
  --provisioning-model=SPOT
```

**Best For:**
- Batch processing
- Data analysis
- CI/CD pipelines
- Fault-tolerant workloads

### 4. Auto-Scaling

```yaml
# GKE HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 5. Idle Resource Detection

```bash
# Find idle VMs (low CPU for 7 days)
gcloud compute instances list \
  --filter="status=RUNNING" \
  --format="table(name,zone,machineType)"

# Stop idle VMs
gcloud compute instances stop INSTANCE_NAME \
  --zone=us-central1-a

# Delete unused disks
gcloud compute disks list \
  --filter="NOT users:*" \
  --format="table(name,zone,sizeGb)"
```

---

## Storage Optimization

### 1. Cloud Storage Lifecycle

**Savings: Up to 90%**

```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "ARCHIVE"},
        "condition": {"age": 365}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 730}
      }
    ]
  }
}
```

```bash
# Apply lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-bucket
```

### 2. Storage Class Selection

**Cost Comparison (per GB/month):**
```
Standard:    $0.020
Nearline:    $0.010 (30-day minimum)
Coldline:    $0.004 (90-day minimum)
Archive:     $0.0012 (365-day minimum)
```

**Decision Matrix:**
```
Frequently accessed (>1/month)     → Standard
Monthly access                     → Nearline
Quarterly access                   → Coldline
Yearly access / Compliance         → Archive
```

### 3. Persistent Disk Optimization

```bash
# Use balanced persistent disk (cheaper than SSD)
gcloud compute disks create my-disk \
  --size=100GB \
  --type=pd-balanced \
  --zone=us-central1-a

# Resize disk
gcloud compute disks resize my-disk \
  --size=200GB \
  --zone=us-central1-a

# Delete unused snapshots
gcloud compute snapshots list \
  --filter="creationTimestamp<-P30D" \
  --format="table(name,creationTimestamp)"
```

---

## Network Optimization

### 1. Network Tier Selection

**Savings: 50%**

```bash
# Use Standard tier (vs Premium)
gcloud compute addresses create my-ip \
  --region=us-central1 \
  --network-tier=STANDARD

# Create VM with Standard tier
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --network-tier=STANDARD
```

**When to Use Standard:**
- Regional traffic only
- Cost-sensitive applications
- Non-latency-critical workloads

### 2. Cloud CDN

**Reduces egress costs**

```bash
# Enable Cloud CDN
gcloud compute backend-services update my-backend \
  --enable-cdn \
  --global
```

**Savings:**
- Reduces origin traffic by 60-90%
- Lower egress costs
- Better performance

### 3. Private Google Access

**Eliminates egress charges**

```bash
# Enable Private Google Access
gcloud compute networks subnets update my-subnet \
  --region=us-central1 \
  --enable-private-ip-google-access
```

**Benefits:**
- No egress charges to Google APIs
- Access Cloud Storage, BigQuery, etc.
- More secure

---

## Database Optimization

### 1. Cloud SQL

```bash
# Use appropriate machine type
gcloud sql instances patch my-instance \
  --tier=db-n1-standard-1

# Enable automatic storage increase
gcloud sql instances patch my-instance \
  --enable-storage-auto-increase \
  --storage-auto-increase-limit=100

# Use committed use discounts
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-n1-standard-4 \
  --region=us-central1 \
  --edition=ENTERPRISE_PLUS
```

### 2. BigQuery

**Partitioning & Clustering:**
```sql
-- Reduces data scanned = lower costs
CREATE TABLE dataset.optimized_table
PARTITION BY DATE(timestamp)
CLUSTER BY user_id, country
AS SELECT * FROM dataset.source_table;
```

**Query Optimization:**
```sql
-- Bad: Scans entire table
SELECT * FROM dataset.large_table;

-- Good: Scans only needed partition
SELECT id, name, amount
FROM dataset.large_table
WHERE DATE(timestamp) = '2026-03-09';
```

**Flat-Rate Pricing:**
```bash
# For consistent workloads
# $2,000/month for 100 slots
# vs $5 per TB on-demand
```

### 3. Firestore

```bash
# Use appropriate indexes
# Avoid composite indexes when not needed

# Monitor usage
gcloud firestore operations list
```

---

## Monitoring & Alerts

### Cost Anomaly Detection

```sql
-- Detect cost spikes
WITH daily_costs AS (
  SELECT
    DATE(_PARTITIONTIME) as date,
    service.description as service,
    SUM(cost) as daily_cost
  FROM `project.billing_export.gcp_billing_export_v1_XXXXXX`
  WHERE DATE(_PARTITIONTIME) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY date, service
),
avg_costs AS (
  SELECT
    service,
    AVG(daily_cost) as avg_cost,
    STDDEV(daily_cost) as stddev_cost
  FROM daily_costs
  GROUP BY service
)
SELECT
  d.date,
  d.service,
  d.daily_cost,
  a.avg_cost,
  (d.daily_cost - a.avg_cost) / a.stddev_cost as z_score
FROM daily_costs d
JOIN avg_costs a ON d.service = a.service
WHERE (d.daily_cost - a.avg_cost) / a.stddev_cost > 2
ORDER BY z_score DESC;
```

### Cost Alerts

```bash
# Create Pub/Sub topic for alerts
gcloud pubsub topics create cost-alerts

# Create budget with Pub/Sub notification
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Cost Alert" \
  --budget-amount=1000 \
  --threshold-rule=percent=80 \
  --pubsub-topic=projects/PROJECT/topics/cost-alerts
```

---

## Cost Optimization Checklist

### Compute
- [ ] Right-size VMs based on utilization
- [ ] Use committed use discounts
- [ ] Use preemptible/spot VMs for batch workloads
- [ ] Enable auto-scaling
- [ ] Stop/delete idle resources
- [ ] Use custom machine types
- [ ] Schedule VMs (stop during off-hours)

### Storage
- [ ] Implement lifecycle policies
- [ ] Use appropriate storage classes
- [ ] Delete old snapshots
- [ ] Compress data
- [ ] Use regional storage when possible
- [ ] Clean up unused disks

### Network
- [ ] Use Standard tier for regional traffic
- [ ] Enable Cloud CDN
- [ ] Use Private Google Access
- [ ] Minimize cross-region traffic
- [ ] Use Cloud NAT instead of external IPs

### Database
- [ ] Right-size database instances
- [ ] Use read replicas
- [ ] Implement query optimization
- [ ] Use partitioning and clustering
- [ ] Consider flat-rate pricing for BigQuery
- [ ] Enable automatic storage increase

### General
- [ ] Set up billing alerts
- [ ] Export billing to BigQuery
- [ ] Regular cost reviews
- [ ] Use labels for cost tracking
- [ ] Implement tagging strategy
- [ ] Review recommender suggestions

---

## Monthly Cost Review Template

```markdown
# Monthly Cost Review - [Month Year]

## Summary
- Total Cost: $X,XXX
- Change from last month: +/-X%
- Budget: $X,XXX
- Remaining: $XXX

## Top 5 Services by Cost
1. Service A: $XXX (X%)
2. Service B: $XXX (X%)
3. Service C: $XXX (X%)
4. Service D: $XXX (X%)
5. Service E: $XXX (X%)

## Cost Anomalies
- [Service]: Spike of $XXX on [date]
- Root cause: [explanation]
- Action taken: [resolution]

## Optimization Actions
- [ ] Action 1: Expected savings $XXX
- [ ] Action 2: Expected savings $XXX
- [ ] Action 3: Expected savings $XXX

## Next Month Goals
- Target cost: $X,XXX
- Key initiatives: [list]
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
