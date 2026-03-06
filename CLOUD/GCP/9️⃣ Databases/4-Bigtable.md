# Bigtable - Wide-Column NoSQL Database

Complete guide to Google Cloud Bigtable - petabyte-scale, low-latency NoSQL database.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Instance Configuration](#instance-configuration)
4. [Schema Design](#schema-design)
5. [Data Operations](#data-operations)
6. [Performance](#performance)
7. [Replication](#replication)
8. [Backup and Recovery](#backup-and-recovery)
9. [Cost Optimization](#cost-optimization)
10. [Best Practices](#best-practices)

---

## Introduction

Bigtable is a fully managed, scalable NoSQL database service for large analytical and operational workloads.

### Key Features

✅ Petabyte-scale storage  
✅ Sub-10ms latency  
✅ High throughput (millions of QPS)  
✅ Automatic scaling  
✅ HBase API compatible  
✅ Strong consistency  
✅ Replication support  
✅ Time-series data  
✅ Integrated with GCP services  
✅ No downtime scaling  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Bigtable Instance                          │
├─────────────────────────────────────────────────────┤
│  Cluster 1 (us-central1-a)                          │
│  ┌──────────────────────────────────────────────┐   │
│  │  Node 1    Node 2    Node 3                  │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐                 │   │
│  │  │Tablet│ │Tablet│ │Tablet│                 │   │
│  │  │  A   │ │  B   │ │  C   │                 │   │
│  │  └──────┘ └──────┘ └──────┘                 │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Colossus (Distributed Storage)                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  SSTable Files                               │   │
│  │  - Immutable                                 │   │
│  │  - Sorted by row key                         │   │
│  │  - Compressed                                │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Use Cases

- Time-series data (IoT, monitoring)
- Financial data (trading, transactions)
- Analytics (clickstream, logs)
- AdTech (user profiles, campaigns)
- Personalization (recommendations)
- Graph data
- Genomics data

---

## Architecture

### Data Model

```
┌─────────────────────────────────────────┐
│        Bigtable Data Model              │
├─────────────────────────────────────────┤
│  Row Key: user#123#2026-03-05           │
│  ┌──────────────────────────────────┐   │
│  │  Column Family: profile          │   │
│  │  ├─ name: "John Doe"             │   │
│  │  ├─ email: "john@example.com"    │   │
│  │  └─ age: 30                      │   │
│  │                                  │   │
│  │  Column Family: activity         │   │
│  │  ├─ last_login: timestamp        │   │
│  │  ├─ page_views: 100              │   │
│  │  └─ clicks: 50                   │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Each cell can have multiple versions   │
│  with timestamps                        │
└─────────────────────────────────────────┘
```

### Storage Architecture

```
┌─────────────────────────────────────────┐
│        Storage Layers                   │
├─────────────────────────────────────────┤
│  Memtable (In-memory)                   │
│  - Recent writes                        │
│  - Sorted by row key                    │
│           │                             │
│           v (Flush)                     │
│  SSTable (Colossus)                     │
│  - Immutable files                      │
│  - Sorted by row key                    │
│  - Compressed                           │
│           │                             │
│           v (Compaction)                │
│  Merged SSTables                        │
│  - Removes deleted data                 │
│  - Merges versions                      │
└─────────────────────────────────────────┘
```

---

## Instance Configuration

### Create Instance

```bash
# Create production instance
gcloud bigtable instances create my-instance \
  --display-name="My Bigtable Instance" \
  --cluster=my-cluster \
  --cluster-zone=us-central1-a \
  --cluster-num-nodes=3 \
  --cluster-storage-type=SSD

# Create development instance
gcloud bigtable instances create dev-instance \
  --display-name="Dev Instance" \
  --cluster=dev-cluster \
  --cluster-zone=us-central1-a \
  --cluster-num-nodes=1 \
  --cluster-storage-type=HDD \
  --instance-type=DEVELOPMENT
```

### Instance Types

| Type | Description | Use Case | Min Nodes |
|------|-------------|----------|-----------|
| **Production** | High availability | Production workloads | 3 |
| **Development** | Single-node | Development/testing | 1 |

### Storage Types

| Type | Performance | Cost | Use Case |
|------|-------------|------|----------|
| **SSD** | High IOPS | $0.17/GB/month | Production |
| **HDD** | Standard | $0.026/GB/month | Cold data |

### Scaling

```bash
# Scale cluster nodes
gcloud bigtable clusters update my-cluster \
  --instance=my-instance \
  --num-nodes=5

# Autoscaling (via Terraform)
resource "google_bigtable_instance" "instance" {
  name = "my-instance"
  
  cluster {
    cluster_id   = "my-cluster"
    zone         = "us-central1-a"
    storage_type = "SSD"
    
    autoscaling_config {
      min_nodes      = 3
      max_nodes      = 10
      cpu_target     = 60
      storage_target = 70
    }
  }
}
```

### Terraform Configuration

```hcl
resource "google_bigtable_instance" "production" {
  name = "my-instance"
  
  cluster {
    cluster_id   = "my-cluster"
    zone         = "us-central1-a"
    num_nodes    = 3
    storage_type = "SSD"
  }
  
  deletion_protection = true
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}

resource "google_bigtable_table" "table" {
  name          = "my-table"
  instance_name = google_bigtable_instance.production.name
  
  column_family {
    family = "profile"
  }
  
  column_family {
    family = "activity"
    
    # Garbage collection policy
    gc_policy {
      max_age {
        days = 30
      }
    }
  }
}
```

---

## Schema Design

### Row Key Design

**Critical for performance!**

```
Good Row Key Patterns:
✅ user#123#2026-03-05T10:30:00
✅ device#abc#1234567890
✅ reverse_domain#timestamp
✅ hash(user_id)#user_id#timestamp

Bad Row Key Patterns:
❌ timestamp#user_id (sequential, hot spot)
❌ user_id (no time component)
❌ sequential_id (hot spot)
```

### Row Key Strategies

**1. Reverse Timestamp:**
```python
import time

# Reverse timestamp to get recent data first
reverse_timestamp = 9999999999 - int(time.time())
row_key = f"user#{user_id}#{reverse_timestamp}"
```

**2. Field Promotion:**
```python
# Promote frequently queried fields to row key
row_key = f"{region}#{device_id}#{timestamp}"
```

**3. Salting:**
```python
# Add salt to distribute load
import hashlib

salt = int(hashlib.md5(user_id.encode()).hexdigest(), 16) % 100
row_key = f"{salt:02d}#{user_id}#{timestamp}"
```

### Column Families

```python
from google.cloud import bigtable

client = bigtable.Client(project='my-project', admin=True)
instance = client.instance('my-instance')
table = instance.table('my-table')

# Create column families
cf_profile = table.column_family('profile')
cf_profile.create()

cf_activity = table.column_family('activity')
cf_activity.create()

# With garbage collection
from google.cloud.bigtable import column_family
import datetime

max_age_rule = column_family.MaxAgeGCRule(datetime.timedelta(days=30))
cf_logs = table.column_family('logs', gc_rule=max_age_rule)
cf_logs.create()

# Max versions rule
max_versions_rule = column_family.MaxVersionsGCRule(3)
cf_history = table.column_family('history', gc_rule=max_versions_rule)
cf_history.create()
```

---

## Data Operations

### Write Data

```python
from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters
import datetime

client = bigtable.Client(project='my-project', admin=True)
instance = client.instance('my-instance')
table = instance.table('my-table')

# Write single row
row_key = 'user#123#2026-03-05'.encode()
row = table.direct_row(row_key)

row.set_cell(
    'profile',
    'name',
    'John Doe',
    timestamp=datetime.datetime.utcnow()
)
row.set_cell('profile', 'email', 'john@example.com')
row.set_cell('activity', 'last_login', str(datetime.datetime.utcnow()))

row.commit()

# Batch write
rows = []
for i in range(100):
    row_key = f'user#{i}#2026-03-05'.encode()
    row = table.direct_row(row_key)
    row.set_cell('profile', 'name', f'User {i}')
    row.set_cell('profile', 'email', f'user{i}@example.com')
    rows.append(row)

# Commit in batches
table.mutate_rows(rows)
```

### Read Data

```python
# Read single row
row_key = 'user#123#2026-03-05'.encode()
row = table.read_row(row_key)

if row:
    print(row.cells['profile'][b'name'][0].value.decode('utf-8'))
    print(row.cells['profile'][b'email'][0].value.decode('utf-8'))

# Read multiple rows
row_set = bigtable.row_set.RowSet()
row_set.add_row_key('user#123#2026-03-05'.encode())
row_set.add_row_key('user#124#2026-03-05'.encode())

rows = table.read_rows(row_set=row_set)
for row in rows:
    print(f'Row key: {row.row_key.decode("utf-8")}')
    for cf, cols in row.cells.items():
        for col, cells in cols.items():
            for cell in cells:
                print(f'{cf}/{col.decode("utf-8")}: {cell.value.decode("utf-8")}')

# Read row range
row_range = bigtable.row_set.RowRange(
    start_key='user#100'.encode(),
    end_key='user#200'.encode()
)
row_set = bigtable.row_set.RowSet()
row_set.add_row_range(row_range)

rows = table.read_rows(row_set=row_set)
```

### Filters

```python
from google.cloud.bigtable import row_filters

# Column filter
col_filter = row_filters.ColumnQualifierRegexFilter(b'name')
rows = table.read_rows(filter_=col_filter)

# Value filter
value_filter = row_filters.ValueRegexFilter(b'John.*')
rows = table.read_rows(filter_=value_filter)

# Timestamp filter
import datetime
time_range = row_filters.TimestampRange(
    start=datetime.datetime(2026, 3, 1),
    end=datetime.datetime(2026, 3, 31)
)
time_filter = row_filters.TimestampRangeFilter(time_range)
rows = table.read_rows(filter_=time_filter)

# Chain filters
chain = row_filters.RowFilterChain(filters=[
    row_filters.FamilyNameRegexFilter('profile'),
    row_filters.ColumnQualifierRegexFilter(b'name'),
    row_filters.CellsColumnLimitFilter(1)
])
rows = table.read_rows(filter_=chain)

# Conditional filter
condition = row_filters.ConditionalRowFilter(
    base_filter=row_filters.ValueRegexFilter(b'active'),
    true_filter=row_filters.PassAllFilter(True),
    false_filter=row_filters.BlockAllFilter(True)
)
rows = table.read_rows(filter_=condition)
```

### Delete Data

```python
# Delete specific cells
row_key = 'user#123#2026-03-05'.encode()
row = table.direct_row(row_key)
row.delete_cell('profile', 'email')
row.commit()

# Delete entire row
row.delete()
row.commit()

# Delete column family
row.delete_cells('activity', row_filters.TimestampRange())
row.commit()
```

---

## Performance

### Throughput

**Per Node Capacity:**
- SSD: ~10,000 QPS per node
- HDD: ~500 QPS per node
- Storage: 8 TB per node (SSD), 16 TB per node (HDD)

**Scaling Example:**
```
3 nodes (SSD):
- Read: 30,000 QPS
- Write: 30,000 QPS
- Storage: 24 TB

10 nodes (SSD):
- Read: 100,000 QPS
- Write: 100,000 QPS
- Storage: 80 TB
```

### Latency

**Typical Latencies:**
- Single row read: 5-10ms (p50), 10-20ms (p99)
- Batch read: 10-20ms (p50), 20-50ms (p99)
- Write: 5-10ms (p50), 10-20ms (p99)

### Optimization Tips

✅ Design row keys to avoid hot spots  
✅ Use batch operations  
✅ Implement connection pooling  
✅ Use appropriate filters  
✅ Limit row size to < 100 MB  
✅ Use column qualifiers efficiently  
✅ Implement garbage collection  
✅ Monitor performance metrics  

### Hot Spot Prevention

```python
# Bad: Sequential row keys
row_key = f"{timestamp}#{user_id}"  # Creates hot spot

# Good: Distributed row keys
import hashlib

# Option 1: Hash prefix
hash_prefix = hashlib.md5(user_id.encode()).hexdigest()[:4]
row_key = f"{hash_prefix}#{user_id}#{timestamp}"

# Option 2: Reverse timestamp
reverse_ts = 9999999999 - int(time.time())
row_key = f"{user_id}#{reverse_ts}"

# Option 3: Salting
salt = int(hashlib.md5(user_id.encode()).hexdigest(), 16) % 100
row_key = f"{salt:02d}#{user_id}#{timestamp}"
```

---

## Replication

### Multi-Cluster Replication

```bash
# Add replication cluster
gcloud bigtable clusters create replica-cluster \
  --instance=my-instance \
  --zone=us-east1-a \
  --num-nodes=3 \
  --storage-type=SSD
```

**Replication Architecture:**

```
┌─────────────────────────────────────────┐
│     Multi-Cluster Replication           │
├─────────────────────────────────────────┤
│  Cluster 1 (us-central1-a)              │
│  ┌──────────────────────────────────┐   │
│  │  3 nodes                         │   │
│  │  Read/Write                      │   │
│  └──────────────────────────────────┘   │
│           │                             │
│           │ Asynchronous                │
│           │ Replication                 │
│           v                             │
│  Cluster 2 (us-east1-a)                 │
│  ┌──────────────────────────────────┐   │
│  │  3 nodes                         │   │
│  │  Read/Write                      │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Features:                              │
│  - Eventual consistency                 │
│  - Automatic failover                   │
│  - Load balancing                       │
└─────────────────────────────────────────┘
```

### App Profile Configuration

```bash
# Create single-cluster routing
gcloud bigtable app-profiles create single-cluster-profile \
  --instance=my-instance \
  --route-to=my-cluster

# Create multi-cluster routing
gcloud bigtable app-profiles create multi-cluster-profile \
  --instance=my-instance \
  --route-any
```

---

## Backup and Recovery

### Create Backups

```bash
# Create backup
gcloud bigtable backups create my-backup \
  --instance=my-instance \
  --cluster=my-cluster \
  --table=my-table \
  --retention-period=7d

# List backups
gcloud bigtable backups list \
  --instance=my-instance \
  --cluster=my-cluster

# Restore from backup
gcloud bigtable tables restore \
  --source-instance=my-instance \
  --source-cluster=my-cluster \
  --source-backup=my-backup \
  --destination-instance=my-instance \
  --destination-table=restored-table

# Delete backup
gcloud bigtable backups delete my-backup \
  --instance=my-instance \
  --cluster=my-cluster
```

### Terraform Backup Configuration

```hcl
resource "google_bigtable_table" "table" {
  name          = "my-table"
  instance_name = google_bigtable_instance.production.name
  
  column_family {
    family = "data"
  }
  
  # Automated backups
  automated_backup_policy {
    retention_period = "7d"
    frequency        = "24h"
  }
}
```

---

## Cost Optimization

### Pricing Components

**Compute:**
- Node (SSD): $0.65/hour ($474/month)
- Node (HDD): $0.065/hour ($47/month)

**Storage:**
- SSD: $0.17/GB/month
- HDD: $0.026/GB/month

**Backups:**
- $0.10/GB/month

**Network:**
- Standard egress rates

### Optimization Strategies

**1. Use HDD for cold data:**

```bash
# Create HDD cluster
gcloud bigtable clusters create cold-cluster \
  --instance=my-instance \
  --zone=us-central1-b \
  --num-nodes=3 \
  --storage-type=HDD
```

**2. Right-size nodes:**

```bash
# Monitor CPU usage
gcloud monitoring time-series list \
  --filter='metric.type="bigtable.googleapis.com/cluster/cpu_load"'

# Scale down if CPU < 50%
gcloud bigtable clusters update my-cluster \
  --instance=my-instance \
  --num-nodes=2
```

**3. Implement garbage collection:**

```python
# Delete old data automatically
from google.cloud.bigtable import column_family
import datetime

max_age_rule = column_family.MaxAgeGCRule(datetime.timedelta(days=90))
cf = table.column_family('logs', gc_rule=max_age_rule)
cf.create()
```

**4. Use autoscaling:**

```hcl
resource "google_bigtable_instance" "instance" {
  cluster {
    autoscaling_config {
      min_nodes      = 3
      max_nodes      = 10
      cpu_target     = 60
      storage_target = 70
    }
  }
}
```

**5. Delete unused backups:**

```bash
# List old backups
gcloud bigtable backups list \
  --instance=my-instance \
  --cluster=my-cluster \
  --filter="expireTime<2026-01-01"

# Delete old backups
gcloud bigtable backups delete old-backup \
  --instance=my-instance \
  --cluster=my-cluster
```

### Cost Example

**Scenario:** IoT time-series data

```
Configuration:
- 5 nodes (SSD)
- 10 TB storage
- 7-day backup retention

Monthly Cost:
- Nodes: 5 × $474 = $2,370
- Storage: 10,000 GB × $0.17 = $1,700
- Backups: ~2,000 GB × $0.10 = $200
- Total: $4,270/month

With HDD for cold data:
- 3 nodes (SSD): 3 × $474 = $1,422
- 2 nodes (HDD): 2 × $47 = $94
- Storage (SSD): 2,000 GB × $0.17 = $340
- Storage (HDD): 8,000 GB × $0.026 = $208
- Backups: $200
- Total: $2,264/month
- Savings: 47%
```

---

## Best Practices

### Schema Design

✅ Design row keys to avoid hot spots  
✅ Use reverse timestamps for time-series  
✅ Implement salting for high-write workloads  
✅ Keep row size under 100 MB  
✅ Use column families appropriately  
✅ Implement garbage collection  
✅ Plan for data growth  
✅ Test schema at scale  

### Performance

✅ Use batch operations  
✅ Implement connection pooling  
✅ Use appropriate filters  
✅ Monitor hot spots  
✅ Right-size clusters  
✅ Use autoscaling  
✅ Optimize row key design  
✅ Regular performance testing  

### High Availability

✅ Use multi-cluster replication  
✅ Configure app profiles  
✅ Implement retry logic  
✅ Monitor cluster health  
✅ Test failover procedures  
✅ Use appropriate consistency levels  
✅ Plan for disaster recovery  

### Security

✅ Use IAM for access control  
✅ Enable audit logging  
✅ Use VPC Service Controls  
✅ Encrypt sensitive data  
✅ Implement least privilege  
✅ Regular security audits  
✅ Use customer-managed encryption keys  

### Cost Management

✅ Use autoscaling  
✅ Right-size clusters  
✅ Use HDD for cold data  
✅ Implement garbage collection  
✅ Delete unused backups  
✅ Monitor usage  
✅ Regular cost reviews  
✅ Optimize data retention  

---

## Troubleshooting

### High Latency

```python
# Check for hot spots
from google.cloud import monitoring_v3

client = monitoring_v3.MetricServiceClient()
project_name = f"projects/{project_id}"

# Query CPU load per node
interval = monitoring_v3.TimeInterval({
    "end_time": {"seconds": int(time.time())},
    "start_time": {"seconds": int(time.time()) - 3600},
})

results = client.list_time_series(
    request={
        "name": project_name,
        "filter": 'metric.type="bigtable.googleapis.com/cluster/cpu_load"',
        "interval": interval,
    }
)
```

### Hot Spots

```bash
# Check key visualizer
# Navigate to: Cloud Console > Bigtable > Instance > Key Visualizer

# Look for:
# - Dark vertical lines (hot spots)
# - Uneven distribution
# - Sequential access patterns
```

### High CPU Usage

```bash
# Check CPU metrics
gcloud monitoring time-series list \
  --filter='metric.type="bigtable.googleapis.com/cluster/cpu_load"'

# Scale up
gcloud bigtable clusters update my-cluster \
  --instance=my-instance \
  --num-nodes=7
```

---

## Next Steps

- **[Memorystore](5-Memorystore.md)** - In-memory cache
- **[Database Comparison](6-Database-Comparison.md)** - Detailed comparison
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
