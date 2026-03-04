# Cost Optimization

Complete guide to reducing and optimizing Google Cloud Platform costs through strategic resource management and discount programs.

---

## 📚 Overview

Cost optimization in GCP is about getting the most value from your cloud spend through:

- **Committed Use Discounts (CUD)**: Up to 57% savings with 1 or 3-year commitments
- **Sustained Use Discounts (SUD)**: Automatic discounts up to 30% based on usage
- **Preemptible and Spot VMs**: Up to 91% discount for fault-tolerant workloads
- **Right-Sizing**: Match resources to actual needs
- **Idle Resource Management**: Identify and eliminate waste
- **Storage Optimization**: Use appropriate storage classes
- **Network Optimization**: Reduce data transfer costs

---

## 💰 Discount Programs

### 1. Committed Use Discounts (CUD)

```
┌────────────────────────────────────────────────────────┐
│  Committed Use Discounts Overview                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  What: Commit to use resources for 1 or 3 years       │
│  Savings: Up to 57% off on-demand pricing             │
│  Types: Spend-based or Resource-based                  │
│                                                         │
│  Spend-Based CUD:                                      │
│  • Commit to minimum spend amount                      │
│  • Flexible across machine types                       │
│  • Applies to Compute Engine, GKE, Cloud SQL          │
│  • 1-year: 25% discount                                │
│  • 3-year: 52% discount                                │
│                                                         │
│  Resource-Based CUD:                                   │
│  • Commit to specific vCPU and memory                  │
│  • Higher discounts                                    │
│  • Less flexible                                       │
│  • 1-year: 37% discount                                │
│  • 3-year: 55% discount                                │
│                                                         │
│  Best For:                                             │
│  • Predictable workloads                               │
│  • Production environments                             │
│  • Long-term projects                                  │
└────────────────────────────────────────────────────────┘
```

### 2. Sustained Use Discounts (SUD)


```
┌────────────────────────────────────────────────────────┐
│  Sustained Use Discounts (Automatic)                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  What: Automatic discounts for consistent usage        │
│  Savings: Up to 30% off on-demand pricing             │
│  Applies: Compute Engine, GKE node pools               │
│  No Action Required: Automatically applied             │
│                                                         │
│  Discount Tiers:                                       │
│  • 25% of month: 20% discount                          │
│  • 50% of month: 40% discount                          │
│  • 75% of month: 60% discount                          │
│  • 100% of month: 100% discount (30% effective)        │
│                                                         │
│  How It Works:                                         │
│  ┌──────────────────────────────────────────┐         │
│  │ Month Usage Timeline                     │         │
│  ├──────────────────────────────────────────┤         │
│  │ 0-25%  │ Full price                      │         │
│  │ 25-50% │ 20% discount                    │         │
│  │ 50-75% │ 40% discount                    │         │
│  │ 75-100%│ 60% discount                    │         │
│  └──────────────────────────────────────────┘         │
│                                                         │
│  Example:                                              │
│  VM running 24/7 for entire month                     │
│  • Base cost: $100                                     │
│  • With SUD: $70 (30% savings)                         │
│  • Automatic - no commitment needed                    │
└────────────────────────────────────────────────────────┘
```

### 3. Preemptible and Spot VMs

```
┌────────────────────────────────────────────────────────┐
│  Preemptible and Spot VMs                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  What: Short-lived VMs at massive discount             │
│  Savings: Up to 91% off on-demand pricing             │
│  Limitation: Can be terminated anytime                 │
│  Max Runtime: 24 hours                                 │
│                                                         │
│  Preemptible VMs (Legacy):                             │
│  • Fixed pricing (60-91% discount)                     │
│  • 30-second termination notice                        │
│  • No live migration                                   │
│  • No automatic restart                                │
│                                                         │
│  Spot VMs (Recommended):                               │
│  • Dynamic pricing (60-91% discount)                   │
│  • Same termination behavior                           │
│  • Better availability                                 │
│  • Pricing can vary                                    │
│                                                         │
│  Best Use Cases:                                       │
│  ✓ Batch processing jobs                               │
│  ✓ Data analysis pipelines                             │
│  ✓ CI/CD build agents                                  │
│  ✓ Rendering workloads                                 │
│  ✓ Machine learning training                           │
│  ✓ Fault-tolerant applications                         │
│                                                         │
│  Not Suitable For:                                     │
│  ✗ Production web servers                              │
│  ✗ Databases                                           │
│  ✗ Stateful applications                               │
│  ✗ Long-running processes                              │
└────────────────────────────────────────────────────────┘
```

---

## 🎯 Right-Sizing Strategies

### 1. VM Right-Sizing

```
┌────────────────────────────────────────────────────────┐
│  VM Right-Sizing Process                               │
└────────────────────────────────────────────────────────┘

Step 1: Identify Over-Provisioned VMs
┌─────────────────────────────────┐
│ • CPU utilization < 50%         │
│ • Memory utilization < 50%      │
│ • Disk I/O underutilized        │
│ • Network bandwidth unused      │
└────────────┬────────────────────┘
             │
             ▼
Step 2: Analyze Usage Patterns
┌─────────────────────────────────┐
│ • Review 30-day metrics         │
│ • Check peak vs average usage   │
│ • Identify usage patterns       │
│ • Consider growth projections   │
└────────────┬────────────────────┘
             │
             ▼
Step 3: Select Appropriate Size
┌─────────────────────────────────┐
│ • Match to actual needs         │
│ • Leave 20% headroom            │
│ • Consider burstable options    │
│ • Use custom machine types      │
└────────────┬────────────────────┘
             │
             ▼
Step 4: Test and Validate
┌─────────────────────────────────┐
│ • Test in non-production first  │
│ • Monitor performance           │
│ • Validate application behavior │
│ • Adjust if needed              │
└────────────┬────────────────────┘
             │
             ▼
Step 5: Implement and Monitor
┌─────────────────────────────────┐
│ • Schedule downtime             │
│ • Resize VMs                    │
│ • Monitor post-change           │
│ • Document savings              │
└─────────────────────────────────┘

Example Savings:
  Before: n1-standard-8 (8 vCPU, 30 GB RAM) = $243/month
  After:  n1-standard-4 (4 vCPU, 15 GB RAM) = $121/month
  Savings: $122/month (50%)
```

### 2. Custom Machine Types

```
┌────────────────────────────────────────────────────────┐
│  Custom Machine Types for Cost Optimization            │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Standard Machine: n1-standard-4                       │
│  • 4 vCPU                                              │
│  • 15 GB RAM (fixed ratio)                             │
│  • Cost: $121/month                                    │
│                                                         │
│  Custom Machine: n1-custom-4-8192                      │
│  • 4 vCPU                                              │
│  • 8 GB RAM (custom ratio)                             │
│  • Cost: $93/month                                     │
│  • Savings: $28/month (23%)                            │
│                                                         │
│  When to Use Custom:                                   │
│  ✓ Need specific CPU/memory ratio                      │
│  ✓ Standard types are over-provisioned                 │
│  ✓ Workload has unique requirements                    │
│  ✓ Cost optimization is priority                       │
│                                                         │
│  Constraints:                                          │
│  • 1 vCPU minimum                                      │
│  • 0.9 GB to 6.5 GB RAM per vCPU                       │
│  • Must be in 256 MB increments                        │
└────────────────────────────────────────────────────────┘
```

---

## 🗑️ Idle Resource Management

### 1. Identifying Idle Resources

```
┌────────────────────────────────────────────────────────┐
│  Common Idle Resources                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Stopped VMs:                                          │
│  • Still incur disk storage costs                      │
│  • Delete if not needed                                │
│  • Use snapshots for backup                            │
│                                                         │
│  Unattached Persistent Disks:                          │
│  • Full storage cost                                   │
│  • Often forgotten after VM deletion                   │
│  • Review and delete unused disks                      │
│                                                         │
│  Old Snapshots:                                        │
│  • Accumulate over time                                │
│  • Implement retention policy                          │
│  • Delete snapshots older than X days                  │
│                                                         │
│  Unused Static IPs:                                    │
│  • $0.01/hour ($7.30/month) each                       │
│  • Release if not in use                               │
│  • Reserve only when needed                            │
│                                                         │
│  Idle Load Balancers:                                  │
│  • Hourly charges even with no traffic                 │
│  • Delete if not serving traffic                       │
│  • Consolidate where possible                          │
│                                                         │
│  Empty Cloud SQL Instances:                            │
│  • Full instance cost                                  │
│  • Delete or downsize                                  │
│  • Use on-demand backups                               │
└────────────────────────────────────────────────────────┘
```

### 2. Automated Cleanup Scripts

```bash
#!/bin/bash
# Automated idle resource cleanup script

PROJECT_ID="your-project-id"
DAYS_IDLE=30

echo "=== GCP Idle Resource Cleanup ==="
echo "Project: $PROJECT_ID"
echo "Idle threshold: $DAYS_IDLE days"
echo ""

# 1. Find unattached disks
echo "Finding unattached disks..."
gcloud compute disks list \
  --project=$PROJECT_ID \
  --filter="NOT users:*" \
  --format="table(name,zone,sizeGb,creationTimestamp)"

# 2. Find old snapshots
echo ""
echo "Finding old snapshots (>$DAYS_IDLE days)..."
CUTOFF_DATE=$(date -d "$DAYS_IDLE days ago" +%Y-%m-%d)
gcloud compute snapshots list \
  --project=$PROJECT_ID \
  --filter="creationTimestamp<$CUTOFF_DATE" \
  --format="table(name,diskSizeGb,creationTimestamp)"

# 3. Find unused static IPs
echo ""
echo "Finding unused static IP addresses..."
gcloud compute addresses list \
  --project=$PROJECT_ID \
  --filter="status:RESERVED" \
  --format="table(name,region,address,status)"

# 4. Find stopped VMs (still incurring disk costs)
echo ""
echo "Finding stopped VMs..."
gcloud compute instances list \
  --project=$PROJECT_ID \
  --filter="status:TERMINATED" \
  --format="table(name,zone,machineType,status)"

# 5. Find idle load balancers (no traffic in 7 days)
echo ""
echo "Review load balancers with low traffic manually in Console"
echo "Navigation: Network Services → Load Balancing"

echo ""
echo "=== Cleanup Complete ==="
echo "Review the above resources and delete if not needed"

# Delete unattached disks (uncomment to execute)
# gcloud compute disks delete DISK_NAME --zone=ZONE --quiet

# Delete old snapshots (uncomment to execute)
# gcloud compute snapshots delete SNAPSHOT_NAME --quiet

# Release unused static IPs (uncomment to execute)
# gcloud compute addresses delete ADDRESS_NAME --region=REGION --quiet
```

---

## 💾 Storage Optimization

### 1. Storage Class Selection

```
┌────────────────────────────────────────────────────────┐
│  Cloud Storage Classes and Pricing                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Standard Storage:                                     │
│  • $0.020/GB/month                                     │
│  • Best for: Frequently accessed data                  │
│  • Use case: Active databases, hot data               │
│  • No retrieval cost                                   │
│                                                         │
│  Nearline Storage:                                     │
│  • $0.010/GB/month (50% cheaper)                       │
│  • Best for: Data accessed < once/month               │
│  • Use case: Backups, disaster recovery               │
│  • Retrieval cost: $0.01/GB                            │
│  • Minimum storage: 30 days                            │
│                                                         │
│  Coldline Storage:                                     │
│  • $0.004/GB/month (80% cheaper)                       │
│  • Best for: Data accessed < once/quarter             │
│  • Use case: Long-term backups, archives              │
│  • Retrieval cost: $0.02/GB                            │
│  • Minimum storage: 90 days                            │
│                                                         │
│  Archive Storage:                                      │
│  • $0.0012/GB/month (94% cheaper)                      │
│  • Best for: Data accessed < once/year                │
│  • Use case: Compliance archives, cold data           │
│  • Retrieval cost: $0.05/GB                            │
│  • Minimum storage: 365 days                           │
│                                                         │
│  Example Savings (1 TB for 1 year):                   │
│  • Standard: $240/year                                 │
│  • Nearline: $120/year (50% savings)                  │
│  • Coldline: $48/year (80% savings)                   │
│  • Archive: $14.40/year (94% savings)                 │
└────────────────────────────────────────────────────────┘
```

### 2. Object Lifecycle Management

```yaml
# lifecycle-policy.json
# Automatically transition objects to cheaper storage classes

{
  "lifecycle": {
    "rule": [
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "NEARLINE"
        },
        "condition": {
          "age": 30,
          "matchesStorageClass": ["STANDARD"]
        }
      },
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "COLDLINE"
        },
        "condition": {
          "age": 90,
          "matchesStorageClass": ["NEARLINE"]
        }
      },
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "ARCHIVE"
        },
        "condition": {
          "age": 365,
          "matchesStorageClass": ["COLDLINE"]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "age": 2555,
          "matchesStorageClass": ["ARCHIVE"]
        }
      }
    ]
  }
}

# Apply lifecycle policy
gsutil lifecycle set lifecycle-policy.json gs://my-bucket

# Savings Example:
# 1 TB data lifecycle over 3 years:
# - Year 1: Standard → Nearline (after 30 days)
# - Year 2: Nearline → Coldline (after 90 days)
# - Year 3: Coldline → Archive (after 365 days)
# Total savings: ~70% compared to keeping in Standard
```

### 3. Persistent Disk Optimization

```
┌────────────────────────────────────────────────────────┐
│  Persistent Disk Types and Costs                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Standard Persistent Disk (HDD):                       │
│  • $0.040/GB/month                                     │
│  • Sequential throughput: 120 MB/s                     │
│  • IOPS: 0.75 per GB                                   │
│  • Best for: Large sequential workloads                │
│                                                         │
│  Balanced Persistent Disk (SSD):                       │
│  • $0.100/GB/month                                     │
│  • Sequential throughput: 240 MB/s                     │
│  • IOPS: 6 per GB                                      │
│  • Best for: Most workloads (recommended)              │
│                                                         │
│  SSD Persistent Disk:                                  │
│  • $0.170/GB/month                                     │
│  • Sequential throughput: 400 MB/s                     │
│  • IOPS: 30 per GB                                     │
│  • Best for: High-performance databases                │
│                                                         │
│  Optimization Tips:                                    │
│  ✓ Use Balanced PD for most workloads                  │
│  ✓ Use Standard PD for cold data                       │
│  ✓ Right-size disk capacity                            │
│  ✓ Delete unused disks                                 │
│  ✓ Use snapshots for backups (cheaper)                 │
│                                                         │
│  Example Savings (500 GB):                             │
│  • SSD PD: $85/month                                   │
│  • Balanced PD: $50/month (41% savings)                │
│  • Standard PD: $20/month (76% savings)                │
└────────────────────────────────────────────────────────┘
```

---

## 🌐 Network Cost Optimization

### 1. Data Transfer Costs

```
┌────────────────────────────────────────────────────────┐
│  Network Egress Pricing                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Free:                                                 │
│  • Ingress (incoming) - Always free                    │
│  • Same zone (internal IP)                             │
│  • Between zones in same region (internal IP)          │
│  • To Google products (YouTube, Maps, etc.)            │
│                                                         │
│  Charged:                                              │
│  • Internet egress (to users)                          │
│    - First 1 GB/month: Free                            │
│    - 1-10 TB: $0.12/GB                                 │
│    - 10-150 TB: $0.11/GB                               │
│    - 150+ TB: $0.08/GB                                 │
│                                                         │
│  • Cross-region (between GCP regions)                  │
│    - $0.01/GB (same continent)                         │
│    - $0.05-0.08/GB (cross-continent)                   │
│                                                         │
│  • External IP within same zone                        │
│    - $0.01/GB                                          │
│                                                         │
│  Optimization Strategies:                              │
│  ✓ Use Cloud CDN for static content                    │
│  ✓ Keep resources in same region                       │
│  ✓ Use internal IPs for inter-VM communication         │
│  ✓ Compress data before transfer                       │
│  ✓ Use Premium Network Tier strategically              │
└────────────────────────────────────────────────────────┘
```

### 2. Cloud CDN for Cost Reduction

```
┌────────────────────────────────────────────────────────┐
│  Cloud CDN Cost Savings                                │
└────────────────────────────────────────────────────────┘

Without Cloud CDN:
┌─────────────────────────────────────────────────────┐
│  User → Origin Server (every request)              │
│                                                     │
│  1 TB egress from origin                            │
│  Cost: $120 (internet egress)                       │
└─────────────────────────────────────────────────────┘

With Cloud CDN:
┌─────────────────────────────────────────────────────┐
│  User → CDN Edge (cached) → Origin (cache miss)    │
│                                                     │
│  Assuming 90% cache hit rate:                       │
│  • 900 GB served from CDN: $40                      │
│  • 100 GB from origin: $12                          │
│  • CDN cache fill: $10                              │
│  Total Cost: $62                                    │
│                                                     │
│  Savings: $58/month (48%)                           │
│  Additional benefit: Lower latency for users        │
└─────────────────────────────────────────────────────┘

Best Practices:
  ✓ Enable CDN for static content
  ✓ Set appropriate cache TTLs
  ✓ Use cache keys effectively
  ✓ Monitor cache hit ratio
  ✓ Invalidate cache strategically
```

---

## 🔧 Practical Optimization Examples

### Example 1: Purchase Committed Use Discount

```bash
# View CUD recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.compute.commitment.UsageCommitmentRecommender \
  --location=us-central1

# Purchase spend-based CUD
gcloud compute commitments create my-commitment \
  --plan=12-month \
  --resources=vcpu=100,memory=400 \
  --region=us-central1

# View active commitments
gcloud compute commitments list

# Expected savings: 25-57% depending on term
```

### Example 2: Convert to Spot VMs

```bash
# Create instance template with Spot VMs
gcloud compute instance-templates create batch-spot-template \
  --machine-type=n1-standard-4 \
  --provisioning-model=SPOT \
  --instance-termination-action=DELETE \
  --metadata=startup-script='#!/bin/bash
    # Your batch job here
    echo "Running batch job..."
    # Handle termination gracefully
  '

# Create managed instance group
gcloud compute instance-groups managed create batch-spot-group \
  --template=batch-spot-template \
  --size=10 \
  --zone=us-central1-a

# Savings: Up to 91% compared to on-demand
```

### Example 3: Implement Storage Lifecycle

```bash
# Create bucket with lifecycle policy
gsutil mb -c STANDARD -l us-central1 gs://my-archive-bucket

# Create lifecycle configuration
cat > lifecycle.json << EOF
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
        "action": {"type": "Delete"},
        "condition": {"age": 730}
      }
    ]
  }
}
EOF

# Apply lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-archive-bucket

# Verify policy
gsutil lifecycle get gs://my-archive-bucket

# Expected savings: 50-80% over 2 years
```

### Example 4: Right-Size VMs

```bash
# Get VM recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a

# Stop VM
gcloud compute instances stop my-vm --zone=us-central1-a

# Change machine type
gcloud compute instances set-machine-type my-vm \
  --machine-type=n1-standard-2 \
  --zone=us-central1-a

# Start VM
gcloud compute instances start my-vm --zone=us-central1-a

# Expected savings: 30-50% depending on over-provisioning
```

---

## 📊 Cost Optimization Dashboard

### BigQuery Cost Analysis

```sql
-- Monthly cost by service
SELECT
  service.description AS service,
  SUM(cost) AS total_cost,
  SUM(CASE WHEN cost_type = 'regular' THEN cost ELSE 0 END) AS regular_cost,
  SUM(CASE WHEN cost_type = 'tax' THEN cost ELSE 0 END) AS tax_cost
FROM `project.dataset.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service
ORDER BY total_cost DESC;

-- Identify optimization opportunities
SELECT
  project.name AS project,
  service.description AS service,
  sku.description AS sku,
  SUM(cost) AS total_cost,
  SUM(usage.amount) AS usage_amount,
  usage.unit AS unit
FROM `project.dataset.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND cost > 0
GROUP BY project, service, sku, unit
HAVING total_cost > 100
ORDER BY total_cost DESC
LIMIT 20;

-- Spot VM vs On-Demand comparison
SELECT
  DATE(usage_start_time) AS date,
  SUM(CASE 
    WHEN sku.description LIKE '%Spot%' OR sku.description LIKE '%Preemptible%' 
    THEN cost 
    ELSE 0 
  END) AS spot_cost,
  SUM(CASE 
    WHEN sku.description NOT LIKE '%Spot%' AND sku.description NOT LIKE '%Preemptible%' 
    THEN cost 
    ELSE 0 
  END) AS ondemand_cost,
  SUM(cost) AS total_cost
FROM `project.dataset.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE service.description = 'Compute Engine'
  AND DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY date
ORDER BY date;
```

---

## ✅ Cost Optimization Checklist

### Immediate Actions (Week 1)
- [ ] Enable billing export to BigQuery
- [ ] Review Recommender insights
- [ ] Identify and delete idle resources
- [ ] Stop non-production VMs after hours
- [ ] Release unused static IP addresses
- [ ] Delete old snapshots
- [ ] Remove unattached disks

### Short-Term (Month 1)
- [ ] Right-size over-provisioned VMs
- [ ] Implement storage lifecycle policies
- [ ] Convert batch workloads to Spot VMs
- [ ] Enable Cloud CDN for static content
- [ ] Optimize persistent disk types
- [ ] Review and optimize network traffic
- [ ] Set up cost anomaly alerts

### Medium-Term (Quarter 1)
- [ ] Evaluate committed use discounts
- [ ] Implement autoscaling
- [ ] Consolidate underutilized projects
- [ ] Optimize database configurations
- [ ] Review cross-region traffic
- [ ] Implement resource scheduling
- [ ] Regular cost review meetings

### Long-Term (Year 1)
- [ ] Architect for cost efficiency
- [ ] Migrate to serverless where appropriate
- [ ] Implement FinOps practices
- [ ] Build cost-aware culture
- [ ] Automate cost optimization
- [ ] Continuous optimization process
- [ ] Annual commitment review

---

## 🎯 Cost Optimization Goals

### Target Savings by Category

```
┌────────────────────────────────────────────────────────┐
│  Realistic Savings Targets                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute (40% of typical spend):                       │
│  • Right-sizing: 20-30% savings                        │
│  • Spot VMs: 60-91% savings (for eligible workloads)   │
│  • CUDs: 25-57% savings                                │
│  • Target: 30% overall compute savings                 │
│                                                         │
│  Storage (25% of typical spend):                       │
│  • Lifecycle policies: 50-80% savings                  │
│  • Disk optimization: 30-50% savings                   │
│  • Snapshot management: 20-40% savings                 │
│  • Target: 40% overall storage savings                 │
│                                                         │
│  Network (15% of typical spend):                       │
│  • Cloud CDN: 30-50% savings                           │
│  • Regional optimization: 10-20% savings               │
│  • Internal IP usage: 5-10% savings                    │
│  • Target: 25% overall network savings                 │
│                                                         │
│  Overall Target: 25-35% total cost reduction           │
└────────────────────────────────────────────────────────┘
```

---

## 📚 Additional Resources

### Documentation
- [Cost Optimization Best Practices](https://cloud.google.com/architecture/cost-optimization)
- [Committed Use Discounts](https://cloud.google.com/compute/docs/instances/committed-use-discounts)
- [Spot VMs](https://cloud.google.com/compute/docs/instances/spot)
- [Storage Classes](https://cloud.google.com/storage/docs/storage-classes)

### Tools
- [Pricing Calculator](https://cloud.google.com/products/calculator)
- [Recommender](https://cloud.google.com/recommender)
- [Active Assist](https://cloud.google.com/solutions/active-assist)

### Training
- [Cost Optimization on Google Cloud](https://www.cloudskillsboost.google/course_templates/655)
- [FinOps Foundation](https://www.finops.org/)

---

## 🎓 Next Steps

1. Review [Recommender](./5-Recommender.md) for AI-powered optimization insights
2. Understand [Pricing Models](./6-Pricing-Models.md) in detail
3. Implement [Cost Allocation](./7-Cost-Allocation.md) strategies
4. Follow [Best Practices](./8-Best-Practices.md) for enterprise cost management

---

**Last Updated:** March 2026
**Version:** 2.0
