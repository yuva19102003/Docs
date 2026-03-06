# Cloud Spanner - Global Relational Database

Complete guide to Google Cloud Spanner - horizontally scalable, globally distributed relational database.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Instance Configuration](#instance-configuration)
4. [Database Schema](#database-schema)
5. [Data Operations](#data-operations)
6. [Transactions](#transactions)
7. [Performance](#performance)
8. [Replication](#replication)
9. [Backup and Recovery](#backup-and-recovery)
10. [Cost Optimization](#cost-optimization)
11. [Best Practices](#best-practices)

---

## Introduction

Cloud Spanner combines the benefits of relational database structure with non-relational horizontal scale.

### Key Features

✅ Horizontal scalability  
✅ Global distribution  
✅ Strong consistency  
✅ 99.999% availability SLA  
✅ ACID transactions  
✅ SQL queries  
✅ Automatic sharding  
✅ Synchronous replication  
✅ No planned downtime  
✅ Automatic scaling  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Cloud Spanner Instance                     │
├─────────────────────────────────────────────────────┤
│  Region 1 (us-central1)                             │
│  ┌──────────────────────────────────────────────┐   │
│  │  Node 1        Node 2        Node 3          │   │
│  │  ┌──────┐     ┌──────┐     ┌──────┐         │   │
│  │  │Split │     │Split │     │Split │         │   │
│  │  │  A   │     │  B   │     │  C   │         │   │
│  │  └──────┘     └──────┘     └──────┘         │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Region 2 (us-east1)                                │
│  ┌──────────────────────────────────────────────┐   │
│  │  Node 4        Node 5        Node 6          │   │
│  │  ┌──────┐     ┌──────┐     ┌──────┐         │   │
│  │  │Split │     │Split │     │Split │         │   │
│  │  │  A   │     │  B   │     │  C   │         │   │
│  │  └──────┘     └──────┘     └──────┘         │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Synchronous Replication                            │
│  - Paxos consensus                                  │
│  - Strong consistency                               │
│  - Automatic failover                               │
└─────────────────────────────────────────────────────┘
```

### Use Cases

- Global applications
- Financial services
- Gaming leaderboards
- Supply chain management
- Inventory systems
- Multi-region applications
- Mission-critical systems

---

## Architecture

### TrueTime

```
┌─────────────────────────────────────────┐
│          TrueTime API                   │
├─────────────────────────────────────────┤
│  Provides globally synchronized time    │
│  - GPS and atomic clocks                │
│  - Uncertainty bounds                   │
│  - Enables external consistency         │
│                                         │
│  Time Interval: [earliest, latest]     │
│  - Uncertainty: typically < 7ms         │
│  - Used for transaction ordering        │
└─────────────────────────────────────────┘
```

### Data Distribution

```
┌─────────────────────────────────────────┐
│        Data Sharding                    │
├─────────────────────────────────────────┤
│  Table: Users                           │
│  Primary Key: user_id                   │
│                                         │
│  Split 1: user_id [0, 1000)             │
│  ├─ Replica in us-central1              │
│  ├─ Replica in us-east1                 │
│  └─ Replica in us-west1                 │
│                                         │
│  Split 2: user_id [1000, 2000)          │
│  ├─ Replica in us-central1              │
│  ├─ Replica in us-east1                 │
│  └─ Replica in us-west1                 │
│                                         │
│  Automatic split/merge based on load    │
└─────────────────────────────────────────┘
```

---

## Instance Configuration

### Instance Types

**Regional Configuration:**
- Single region
- 3 zones within region
- 99.99% availability SLA
- Lower latency
- Lower cost

**Multi-region Configuration:**
- Multiple regions
- 99.999% availability SLA
- Global distribution
- Higher cost

### Available Configurations

| Configuration | Regions | Read-Write Latency | Use Case |
|--------------|---------|-------------------|----------|
| **regional-us-central1** | 1 | 5-10ms | Regional apps |
| **nam3** | 3 (US) | 10-15ms | North America |
| **nam6** | 6 (US) | 10-15ms | US-wide |
| **eur3** | 3 (EU) | 10-15ms | Europe |
| **asia1** | 3 (Asia) | 10-15ms | Asia Pacific |

### Create Instance

```bash
# Create regional instance
gcloud spanner instances create my-instance \
  --config=regional-us-central1 \
  --nodes=1 \
  --description="My Spanner instance"

# Create multi-region instance
gcloud spanner instances create global-instance \
  --config=nam3 \
  --nodes=3 \
  --description="Global Spanner instance"

# Create with processing units
gcloud spanner instances create my-instance \
  --config=regional-us-central1 \
  --processing-units=500 \
  --description="My Spanner instance"
```

### Scaling

**Nodes vs Processing Units:**
- 1 node = 1000 processing units
- Minimum: 100 processing units
- Granular scaling with processing units

```bash
# Scale nodes
gcloud spanner instances update my-instance \
  --nodes=3

# Scale processing units
gcloud spanner instances update my-instance \
  --processing-units=1500

# Autoscaling (via Terraform)
resource "google_spanner_instance" "main" {
  name         = "my-instance"
  config       = "regional-us-central1"
  display_name = "My Spanner Instance"
  
  autoscaling_config {
    autoscaling_limits {
      min_processing_units = 100
      max_processing_units = 2000
    }
    autoscaling_targets {
      high_priority_cpu_utilization_percent = 65
      storage_utilization_percent           = 95
    }
  }
}
```

### Terraform Configuration

```hcl
resource "google_spanner_instance" "main" {
  name         = "my-instance"
  config       = "regional-us-central1"
  display_name = "My Spanner Instance"
  num_nodes    = 1
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}

resource "google_spanner_database" "database" {
  instance = google_spanner_instance.main.name
  name     = "my-database"
  
  ddl = [
    "CREATE TABLE Users (UserId INT64 NOT NULL, Name STRING(100), Email STRING(100)) PRIMARY KEY (UserId)",
    "CREATE TABLE Orders (OrderId INT64 NOT NULL, UserId INT64 NOT NULL, Amount FLOAT64, CreatedAt TIMESTAMP) PRIMARY KEY (OrderId)",
    "CREATE INDEX UserEmailIndex ON Users(Email)",
  ]
  
  deletion_protection = true
}
```

---

## Database Schema

### Data Types

| Type | Description | Example |
|------|-------------|---------|
| **INT64** | 64-bit integer | 123456 |
| **FLOAT64** | 64-bit float | 123.45 |
| **BOOL** | Boolean | TRUE/FALSE |
| **STRING(n)** | Variable-length string | "Hello" |
| **BYTES(n)** | Variable-length bytes | b"data" |
| **DATE** | Date | "2026-03-05" |
| **TIMESTAMP** | Timestamp | "2026-03-05T10:30:00Z" |
| **ARRAY** | Array | [1, 2, 3] |
| **JSON** | JSON document | {"key": "value"} |

### Create Tables

```sql
-- Users table
CREATE TABLE Users (
  UserId INT64 NOT NULL,
  Name STRING(100),
  Email STRING(100),
  CreatedAt TIMESTAMP NOT NULL OPTIONS (
    allow_commit_timestamp = true
  ),
  UpdatedAt TIMESTAMP OPTIONS (
    allow_commit_timestamp = true
  )
) PRIMARY KEY (UserId);

-- Orders table with interleaving
CREATE TABLE Orders (
  UserId INT64 NOT NULL,
  OrderId INT64 NOT NULL,
  Amount FLOAT64,
  Status STRING(20),
  CreatedAt TIMESTAMP NOT NULL OPTIONS (
    allow_commit_timestamp = true
  )
) PRIMARY KEY (UserId, OrderId),
  INTERLEAVE IN PARENT Users ON DELETE CASCADE;

-- OrderItems table
CREATE TABLE OrderItems (
  UserId INT64 NOT NULL,
  OrderId INT64 NOT NULL,
  ItemId INT64 NOT NULL,
  ProductId INT64,
  Quantity INT64,
  Price FLOAT64
) PRIMARY KEY (UserId, OrderId, ItemId),
  INTERLEAVE IN PARENT Orders ON DELETE CASCADE;
```

### Indexes

```sql
-- Secondary index
CREATE INDEX UserEmailIndex ON Users(Email);

-- Composite index
CREATE INDEX OrderStatusDateIndex ON Orders(Status, CreatedAt DESC);

-- Storing clause (covering index)
CREATE INDEX UserEmailNameIndex ON Users(Email) STORING (Name);

-- NULL filtered index
CREATE NULL_FILTERED INDEX ActiveUsersIndex ON Users(Status)
WHERE Status IS NOT NULL;

-- Unique index
CREATE UNIQUE INDEX UniqueEmailIndex ON Users(Email);
```

### Interleaved Tables

```
┌─────────────────────────────────────────┐
│        Table Interleaving               │
├─────────────────────────────────────────┤
│  Users (Parent)                         │
│  ├─ UserId: 1                           │
│  │  ├─ Orders (Child)                   │
│  │  │  ├─ OrderId: 101                  │
│  │  │  │  └─ OrderItems (Grandchild)    │
│  │  │  │     ├─ ItemId: 1               │
│  │  │  │     └─ ItemId: 2               │
│  │  │  └─ OrderId: 102                  │
│  │  │     └─ OrderItems                 │
│  │  │        └─ ItemId: 1               │
│  └─ UserId: 2                           │
│     └─ Orders                           │
│        └─ OrderId: 103                  │
│                                         │
│  Benefits:                              │
│  - Co-located data                      │
│  - Faster joins                         │
│  - Atomic operations                    │
└─────────────────────────────────────────┘
```

---

## Data Operations

### Insert Data

```sql
-- Single insert
INSERT INTO Users (UserId, Name, Email, CreatedAt)
VALUES (1, 'John Doe', 'john@example.com', PENDING_COMMIT_TIMESTAMP());

-- Multiple inserts
INSERT INTO Users (UserId, Name, Email, CreatedAt)
VALUES 
  (2, 'Jane Smith', 'jane@example.com', PENDING_COMMIT_TIMESTAMP()),
  (3, 'Bob Johnson', 'bob@example.com', PENDING_COMMIT_TIMESTAMP());
```

### Query Data

```sql
-- Simple query
SELECT * FROM Users WHERE UserId = 1;

-- Join query
SELECT u.Name, o.OrderId, o.Amount
FROM Users u
JOIN Orders o ON u.UserId = o.UserId
WHERE u.UserId = 1;

-- Aggregation
SELECT Status, COUNT(*) as Count, SUM(Amount) as Total
FROM Orders
GROUP BY Status;

-- Window functions
SELECT 
  UserId,
  OrderId,
  Amount,
  ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY CreatedAt DESC) as RowNum
FROM Orders;
```

### Update Data

```sql
-- Single update
UPDATE Users
SET Name = 'John Smith', UpdatedAt = PENDING_COMMIT_TIMESTAMP()
WHERE UserId = 1;

-- Conditional update
UPDATE Orders
SET Status = 'SHIPPED', UpdatedAt = PENDING_COMMIT_TIMESTAMP()
WHERE OrderId = 101 AND Status = 'PENDING';
```

### Delete Data

```sql
-- Single delete
DELETE FROM Users WHERE UserId = 1;

-- Conditional delete
DELETE FROM Orders WHERE CreatedAt < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY);
```

### Python Client

```python
from google.cloud import spanner

# Initialize client
spanner_client = spanner.Client()
instance = spanner_client.instance('my-instance')
database = instance.database('my-database')

# Insert data
def insert_user(user_id, name, email):
    with database.batch() as batch:
        batch.insert(
            table='Users',
            columns=('UserId', 'Name', 'Email', 'CreatedAt'),
            values=[
                (user_id, name, email, spanner.COMMIT_TIMESTAMP)
            ]
        )

# Query data
def get_user(user_id):
    with database.snapshot() as snapshot:
        results = snapshot.execute_sql(
            'SELECT UserId, Name, Email FROM Users WHERE UserId = @user_id',
            params={'user_id': user_id},
            param_types={'user_id': spanner.param_types.INT64}
        )
        for row in results:
            print(f'User: {row[0]}, {row[1]}, {row[2]}')

# Update data
def update_user(user_id, name):
    with database.batch() as batch:
        batch.update(
            table='Users',
            columns=('UserId', 'Name', 'UpdatedAt'),
            values=[
                (user_id, name, spanner.COMMIT_TIMESTAMP)
            ]
        )

# Delete data
def delete_user(user_id):
    with database.batch() as batch:
        batch.delete(
            table='Users',
            keyset=spanner.KeySet(keys=[(user_id,)])
        )
```

---

## Transactions

### Read-Write Transactions

```python
def transfer_money(from_user, to_user, amount):
    def update_balances(transaction):
        # Read current balances
        row = transaction.execute_sql(
            'SELECT Balance FROM Accounts WHERE UserId = @user_id',
            params={'user_id': from_user},
            param_types={'user_id': spanner.param_types.INT64}
        ).one()
        from_balance = row[0]
        
        row = transaction.execute_sql(
            'SELECT Balance FROM Accounts WHERE UserId = @user_id',
            params={'user_id': to_user},
            param_types={'user_id': spanner.param_types.INT64}
        ).one()
        to_balance = row[0]
        
        # Check sufficient funds
        if from_balance < amount:
            raise ValueError('Insufficient funds')
        
        # Update balances
        transaction.update(
            table='Accounts',
            columns=('UserId', 'Balance', 'UpdatedAt'),
            values=[
                (from_user, from_balance - amount, spanner.COMMIT_TIMESTAMP),
                (to_user, to_balance + amount, spanner.COMMIT_TIMESTAMP)
            ]
        )
    
    database.run_in_transaction(update_balances)
```

### Read-Only Transactions

```python
# Strong read (latest data)
with database.snapshot() as snapshot:
    results = snapshot.execute_sql('SELECT * FROM Users')
    for row in results:
        print(row)

# Stale read (15 seconds old, lower latency)
from datetime import timedelta

with database.snapshot(exact_staleness=timedelta(seconds=15)) as snapshot:
    results = snapshot.execute_sql('SELECT * FROM Users')
    for row in results:
        print(row)

# Read at timestamp
import datetime

timestamp = datetime.datetime(2026, 3, 5, 10, 30, 0)
with database.snapshot(read_timestamp=timestamp) as snapshot:
    results = snapshot.execute_sql('SELECT * FROM Users')
    for row in results:
        print(row)
```

### Batch Operations

```python
# Batch insert
with database.batch() as batch:
    batch.insert(
        table='Users',
        columns=('UserId', 'Name', 'Email', 'CreatedAt'),
        values=[
            (1, 'User 1', 'user1@example.com', spanner.COMMIT_TIMESTAMP),
            (2, 'User 2', 'user2@example.com', spanner.COMMIT_TIMESTAMP),
            (3, 'User 3', 'user3@example.com', spanner.COMMIT_TIMESTAMP),
        ]
    )

# Batch update
with database.batch() as batch:
    batch.update(
        table='Users',
        columns=('UserId', 'Status', 'UpdatedAt'),
        values=[
            (1, 'ACTIVE', spanner.COMMIT_TIMESTAMP),
            (2, 'ACTIVE', spanner.COMMIT_TIMESTAMP),
            (3, 'INACTIVE', spanner.COMMIT_TIMESTAMP),
        ]
    )
```

---

## Performance

### Query Optimization

**Use Query Execution Plans:**

```sql
-- Explain query
@{EXPLAIN_ANALYZE=TRUE}
SELECT u.Name, o.OrderId, o.Amount
FROM Users u
JOIN Orders o ON u.UserId = o.UserId
WHERE u.Email = 'john@example.com';
```

**Optimization Tips:**

✅ Use indexes for WHERE clauses  
✅ Use STORING clause for covering indexes  
✅ Avoid SELECT *  
✅ Use LIMIT for large result sets  
✅ Use batch operations  
✅ Optimize JOIN order  
✅ Use interleaved tables  
✅ Avoid hot spots  

### Hot Spot Prevention

**Bad Primary Key (Sequential):**
```sql
-- Creates hot spot
CREATE TABLE Orders (
  OrderId INT64 NOT NULL,  -- Sequential IDs
  ...
) PRIMARY KEY (OrderId);
```

**Good Primary Key (Distributed):**
```sql
-- Distributes load
CREATE TABLE Orders (
  OrderId STRING(36) NOT NULL,  -- UUID
  ...
) PRIMARY KEY (OrderId);

-- Or use hash
CREATE TABLE Orders (
  ShardId INT64 NOT NULL,  -- Hash of customer ID
  OrderId INT64 NOT NULL,
  ...
) PRIMARY KEY (ShardId, OrderId);
```

### Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="spanner.googleapis.com/instance/cpu/utilization"' \
  --format=json

# Query statistics
gcloud spanner databases execute-sql my-database \
  --instance=my-instance \
  --sql="SELECT * FROM SPANNER_SYS.QUERY_STATS_TOP_MINUTE ORDER BY avg_latency_seconds DESC LIMIT 10"
```

---

## Replication

### Multi-Region Replication

```
┌─────────────────────────────────────────┐
│     Multi-Region Configuration          │
├─────────────────────────────────────────┤
│  nam3 (North America)                   │
│  ┌──────────────────────────────────┐   │
│  │  us-central1 (Iowa)              │   │
│  │  - Read-write replicas           │   │
│  │  - Leader region                 │   │
│  └──────────────────────────────────┘   │
│  ┌──────────────────────────────────┐   │
│  │  us-east1 (South Carolina)       │   │
│  │  - Read-write replicas           │   │
│  └──────────────────────────────────┘   │
│  ┌──────────────────────────────────┐   │
│  │  us-west1 (Oregon)               │   │
│  │  - Read-write replicas           │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Synchronous replication via Paxos      │
│  - Strong consistency                   │
│  - Automatic failover                   │
│  - No data loss                         │
└─────────────────────────────────────────┘
```

### Read-Only Replicas

```bash
# Add read-only replica
gcloud spanner instances update my-instance \
  --read-only-replica-count=1 \
  --read-only-replica-location=us-west1
```

---

## Backup and Recovery

### Automated Backups

```bash
# Create backup
gcloud spanner backups create my-backup \
  --instance=my-instance \
  --database=my-database \
  --retention-period=7d

# List backups
gcloud spanner backups list --instance=my-instance

# Restore from backup
gcloud spanner databases create restored-database \
  --instance=my-instance \
  --backup=my-backup \
  --backup-instance=my-instance

# Delete backup
gcloud spanner backups delete my-backup \
  --instance=my-instance
```

### Point-in-Time Recovery

```bash
# Restore to specific time
gcloud spanner databases create restored-database \
  --instance=my-instance \
  --source-database=my-database \
  --version-time='2026-03-05T10:30:00Z'
```

### Terraform Backup Configuration

```hcl
resource "google_spanner_backup" "backup" {
  instance    = google_spanner_instance.main.name
  database    = google_spanner_database.database.name
  backup_id   = "my-backup"
  retention_period = "7d"
}

resource "google_spanner_backup_schedule" "full_backup" {
  instance = google_spanner_instance.main.name
  database = google_spanner_database.database.name
  
  retention_duration = "7d"
  
  spec {
    cron_spec {
      text = "0 2 * * *"  # Daily at 2 AM
    }
  }
  
  full_backup_spec {}
}
```

---

## Cost Optimization

### Pricing Components

**Instance costs:**
- Node: $0.90/hour ($657/month)
- Processing unit: $0.0009/hour ($0.657/month)
- Storage: $0.30/GB/month
- Backups: $0.10/GB/month
- Network egress: Standard rates

### Optimization Strategies

**1. Use processing units for fine-grained scaling:**

```bash
# Scale to 500 PUs instead of 1 node (1000 PUs)
gcloud spanner instances update my-instance \
  --processing-units=500
```

**2. Use regional instead of multi-region:**

```
Regional (1 node):
- Instance: $657/month
- Storage: 100 GB × $0.30 = $30
- Total: $687/month

Multi-region (3 nodes):
- Instance: $657 × 3 = $1,971/month
- Storage: 100 GB × $0.30 = $30
- Total: $2,001/month
```

**3. Optimize storage:**

```sql
-- Delete old data
DELETE FROM Orders WHERE CreatedAt < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY);

-- Drop unused indexes
DROP INDEX UnusedIndex;
```

**4. Use autoscaling:**

```hcl
resource "google_spanner_instance" "main" {
  autoscaling_config {
    autoscaling_limits {
      min_processing_units = 100
      max_processing_units = 2000
    }
    autoscaling_targets {
      high_priority_cpu_utilization_percent = 65
    }
  }
}
```

**5. Monitor and optimize queries:**

```sql
-- Find expensive queries
SELECT 
  text,
  avg_latency_seconds,
  avg_cpu_seconds
FROM SPANNER_SYS.QUERY_STATS_TOP_HOUR
ORDER BY avg_cpu_seconds DESC
LIMIT 10;
```

### Cost Example

**Scenario:** E-commerce application

```
Configuration:
- Regional instance (us-central1)
- 3 nodes
- 500 GB storage
- 7-day backup retention

Monthly Cost:
- Nodes: 3 × $657 = $1,971
- Storage: 500 GB × $0.30 = $150
- Backups: ~100 GB × $0.10 = $10
- Total: $2,131/month

With autoscaling (avg 1500 PUs):
- Processing units: 1500 × $0.657 = $986
- Storage: $150
- Backups: $10
- Total: $1,146/month
- Savings: 46%
```

---

## Best Practices

### Schema Design

✅ Use UUIDs or hash-based primary keys  
✅ Avoid sequential primary keys  
✅ Use interleaved tables for parent-child relationships  
✅ Create indexes for frequently queried columns  
✅ Use STORING clause for covering indexes  
✅ Avoid hot spots  
✅ Normalize data appropriately  
✅ Use appropriate data types  

### Performance

✅ Use batch operations  
✅ Optimize query execution plans  
✅ Use stale reads when appropriate  
✅ Implement connection pooling  
✅ Monitor query performance  
✅ Use indexes effectively  
✅ Avoid large transactions  
✅ Use partitioned DML for bulk operations  

### High Availability

✅ Use multi-region for global applications  
✅ Configure backups  
✅ Test failover procedures  
✅ Monitor instance health  
✅ Implement retry logic  
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
✅ Right-size instances  
✅ Use regional when possible  
✅ Monitor usage  
✅ Delete unused backups  
✅ Optimize queries  
✅ Use processing units for fine-grained scaling  
✅ Regular cost reviews  

---

## Troubleshooting

### High Latency

```sql
-- Check query performance
@{EXPLAIN_ANALYZE=TRUE}
SELECT * FROM Users WHERE Email = 'john@example.com';

-- Check for missing indexes
SELECT * FROM INFORMATION_SCHEMA.INDEXES
WHERE TABLE_NAME = 'Users';
```

### Hot Spots

```sql
-- Check for hot spots
SELECT 
  interval_end,
  split_count,
  avg_cpu_utilization
FROM SPANNER_SYS.SPLIT_STATS_TOP_HOUR
ORDER BY avg_cpu_utilization DESC;
```

### High CPU Usage

```bash
# Check CPU metrics
gcloud monitoring time-series list \
  --filter='metric.type="spanner.googleapis.com/instance/cpu/utilization"'

# Scale up
gcloud spanner instances update my-instance \
  --nodes=5
```

---

## Next Steps

- **[Firestore](3-Firestore.md)** - Document database
- **[Bigtable](4-Bigtable.md)** - Wide-column NoSQL
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
