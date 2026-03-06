# Database Best Practices - Production Guidelines

Comprehensive best practices for running databases in production on Google Cloud Platform.

---

## 📋 Table of Contents

1. [General Best Practices](#general-best-practices)
2. [Cloud SQL Best Practices](#cloud-sql-best-practices)
3. [Cloud Spanner Best Practices](#cloud-spanner-best-practices)
4. [Firestore Best Practices](#firestore-best-practices)
5. [Bigtable Best Practices](#bigtable-best-practices)
6. [Memorystore Best Practices](#memorystore-best-practices)
7. [Security Best Practices](#security-best-practices)
8. [Performance Best Practices](#performance-best-practices)
9. [Cost Optimization](#cost-optimization)
10. [Disaster Recovery](#disaster-recovery)

---

## General Best Practices

### Architecture

✅ **Choose the right database for your use case**
- Use decision framework from comparison guide
- Consider data model, scale, and budget
- Don't force-fit a database to your needs

✅ **Design for failure**
- Implement retry logic with exponential backoff
- Handle transient errors gracefully
- Use circuit breakers for cascading failures
- Test failure scenarios regularly

✅ **Implement proper monitoring**
- Set up alerts for critical metrics
- Monitor performance trends
- Track error rates and latency
- Use Cloud Monitoring dashboards

✅ **Use connection pooling**
- Reuse database connections
- Configure appropriate pool sizes
- Monitor connection usage
- Handle connection failures

✅ **Implement caching strategically**
- Cache frequently accessed data
- Use appropriate TTLs
- Implement cache invalidation
- Monitor cache hit ratios

### Development Workflow

```
Development → Testing → Staging → Production
    ↓           ↓          ↓           ↓
  Dev DB    Test DB    Stage DB    Prod DB
  (Small)   (Medium)   (Similar)   (Full)
```

✅ **Use separate environments**
- Development: Small instances, relaxed security
- Testing: Medium instances, test data
- Staging: Production-like, real data subset
- Production: Full scale, strict security

✅ **Version control schema changes**
- Use migration tools (Liquibase, Flyway)
- Test migrations in non-production first
- Have rollback plans
- Document all changes

✅ **Automate deployments**
- Use Infrastructure as Code (Terraform)
- Implement CI/CD pipelines
- Automate testing
- Use blue-green deployments

---

## Cloud SQL Best Practices

### High Availability

```hcl
resource "google_sql_database_instance" "main" {
  name             = "prod-instance"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  
  settings {
    tier = "db-n1-standard-4"
    
    # Enable HA
    availability_type = "REGIONAL"
    
    # Backup configuration
    backup_configuration {
      enabled            = true
      start_time         = "03:00"
      binary_log_enabled = true
      transaction_log_retention_days = 7
    }
    
    # Maintenance window
    maintenance_window {
      day  = 7  # Sunday
      hour = 4
    }
    
    # Private IP
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
      require_ssl     = true
    }
  }
  
  deletion_protection = true
}
```

### Performance

✅ **Optimize queries**
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM users WHERE email = 'john@example.com';

-- Create appropriate indexes
CREATE INDEX idx_users_email ON users(email);

-- Avoid SELECT *
SELECT id, name, email FROM users WHERE status = 'active';

-- Use LIMIT for large result sets
SELECT * FROM orders ORDER BY created_at DESC LIMIT 100;
```

✅ **Use read replicas**
```python
from google.cloud.sql.connector import Connector
import sqlalchemy

# Primary connection (writes)
def getconn_primary():
    return connector.connect(
        "project:region:instance",
        "pymysql",
        user="user",
        password="password",
        db="database"
    )

# Replica connection (reads)
def getconn_replica():
    return connector.connect(
        "project:region:replica",
        "pymysql",
        user="user",
        password="password",
        db="database"
    )

primary_pool = sqlalchemy.create_engine("mysql+pymysql://", creator=getconn_primary)
replica_pool = sqlalchemy.create_engine("mysql+pymysql://", creator=getconn_replica)

# Write to primary
with primary_pool.connect() as conn:
    conn.execute("INSERT INTO users (name) VALUES ('John')")

# Read from replica
with replica_pool.connect() as conn:
    result = conn.execute("SELECT * FROM users")
```

✅ **Configure database flags**
```bash
# MySQL optimization
gcloud sql instances patch my-instance \
  --database-flags=\
max_connections=200,\
innodb_buffer_pool_size=4294967296,\
query_cache_size=0,\
slow_query_log=ON

# PostgreSQL optimization
gcloud sql instances patch postgres-instance \
  --database-flags=\
max_connections=200,\
shared_buffers=2GB,\
effective_cache_size=6GB,\
work_mem=10MB
```

### Backup and Recovery

✅ **Automated backups**
- Enable automated backups
- Set appropriate retention period (7-365 days)
- Enable binary logs for point-in-time recovery
- Test restore procedures regularly

✅ **Export critical data**
```bash
# Export to Cloud Storage
gcloud sql export sql my-instance gs://my-bucket/backup-$(date +%Y%m%d).sql \
  --database=my-database

# Automate with Cloud Scheduler
gcloud scheduler jobs create http daily-backup \
  --schedule="0 3 * * *" \
  --uri="https://sqladmin.googleapis.com/sql/v1beta4/projects/PROJECT/instances/INSTANCE/export" \
  --http-method=POST
```

---

## Cloud Spanner Best Practices

### Schema Design

✅ **Avoid hot spots**
```sql
-- Bad: Sequential primary key
CREATE TABLE Orders (
  OrderId INT64 NOT NULL,  -- Sequential, creates hot spot
  ...
) PRIMARY KEY (OrderId);

-- Good: UUID or hash-based key
CREATE TABLE Orders (
  OrderId STRING(36) NOT NULL,  -- UUID
  ...
) PRIMARY KEY (OrderId);

-- Good: Composite key with distribution
CREATE TABLE Orders (
  ShardId INT64 NOT NULL,  -- Hash of customer ID
  OrderId INT64 NOT NULL,
  ...
) PRIMARY KEY (ShardId, OrderId);
```

✅ **Use interleaved tables**
```sql
-- Parent table
CREATE TABLE Users (
  UserId INT64 NOT NULL,
  Name STRING(100),
  Email STRING(100)
) PRIMARY KEY (UserId);

-- Child table (interleaved)
CREATE TABLE Orders (
  UserId INT64 NOT NULL,
  OrderId INT64 NOT NULL,
  Amount FLOAT64,
  Status STRING(20)
) PRIMARY KEY (UserId, OrderId),
  INTERLEAVE IN PARENT Users ON DELETE CASCADE;
```

### Performance

✅ **Use batch operations**
```python
from google.cloud import spanner

# Batch insert
with database.batch() as batch:
    batch.insert(
        table='Users',
        columns=('UserId', 'Name', 'Email'),
        values=[
            (1, 'User 1', 'user1@example.com'),
            (2, 'User 2', 'user2@example.com'),
            (3, 'User 3', 'user3@example.com'),
        ]
    )
```

✅ **Optimize queries**
```sql
-- Use indexes
CREATE INDEX UserEmailIndex ON Users(Email);

-- Use STORING clause for covering indexes
CREATE INDEX UserEmailNameIndex ON Users(Email) STORING (Name);

-- Analyze query plans
@{EXPLAIN_ANALYZE=TRUE}
SELECT * FROM Users WHERE Email = 'john@example.com';
```

✅ **Use autoscaling**
```hcl
resource "google_spanner_instance" "main" {
  name = "my-instance"
  config = "regional-us-central1"
  
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

---

## Firestore Best Practices

### Data Modeling

✅ **Denormalize data**
```javascript
// Bad: Normalized (requires multiple reads)
users/{userId}
  - name: "John"
  - email: "john@example.com"

orders/{orderId}
  - userId: "user123"
  - total: 100

// Good: Denormalized (single read)
orders/{orderId}
  - userId: "user123"
  - userName: "John"
  - userEmail: "john@example.com"
  - total: 100
```

✅ **Use subcollections**
```javascript
// Good: Subcollections for large datasets
users/{userId}
  - name: "John"
  - email: "john@example.com"
  
  orders/{orderId}
    - total: 100
    - status: "pending"
    
    items/{itemId}
      - productId: "prod123"
      - quantity: 2
```

### Performance

✅ **Implement pagination**
```javascript
import { collection, query, orderBy, limit, startAfter, getDocs } from 'firebase/firestore';

// First page
const first = query(
  collection(db, 'users'),
  orderBy('name'),
  limit(25)
);
const documentSnapshots = await getDocs(first);

// Next page
const lastVisible = documentSnapshots.docs[documentSnapshots.docs.length-1];
const next = query(
  collection(db, 'users'),
  orderBy('name'),
  startAfter(lastVisible),
  limit(25)
);
```

✅ **Use batch operations**
```javascript
import { writeBatch, doc } from 'firebase/firestore';

const batch = writeBatch(db);

// Add operations to batch (max 500)
for (let i = 0; i < 100; i++) {
  const docRef = doc(db, 'users', `user${i}`);
  batch.set(docRef, { name: `User ${i}`, index: i });
}

// Commit batch
await batch.commit();
```

✅ **Enable offline persistence**
```javascript
import { enableIndexedDbPersistence } from 'firebase/firestore';

enableIndexedDbPersistence(db)
  .catch((err) => {
    if (err.code == 'failed-precondition') {
      console.log('Multiple tabs open');
    } else if (err.code == 'unimplemented') {
      console.log('Browser not supported');
    }
  });
```

### Security

✅ **Implement security rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
      
      // Subcollection: orders
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## Bigtable Best Practices

### Schema Design

✅ **Design row keys carefully**
```python
import hashlib
import time

# Bad: Sequential (hot spot)
row_key = f"{timestamp}#{user_id}"

# Good: Distributed
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

✅ **Use column families appropriately**
```python
from google.cloud import bigtable
from google.cloud.bigtable import column_family
import datetime

# Create column families with GC policies
table = instance.table('my-table')

# Profile data (keep forever)
cf_profile = table.column_family('profile')
cf_profile.create()

# Activity data (keep 30 days)
max_age_rule = column_family.MaxAgeGCRule(datetime.timedelta(days=30))
cf_activity = table.column_family('activity', gc_rule=max_age_rule)
cf_activity.create()

# History (keep 3 versions)
max_versions_rule = column_family.MaxVersionsGCRule(3)
cf_history = table.column_family('history', gc_rule=max_versions_rule)
cf_history.create()
```

### Performance

✅ **Use batch operations**
```python
# Batch write
rows = []
for i in range(1000):
    row_key = f'user#{i}#{timestamp}'.encode()
    row = table.direct_row(row_key)
    row.set_cell('profile', 'name', f'User {i}')
    row.set_cell('profile', 'email', f'user{i}@example.com')
    rows.append(row)

# Commit in batches
table.mutate_rows(rows)
```

✅ **Use appropriate filters**
```python
from google.cloud.bigtable import row_filters

# Chain filters for efficiency
chain = row_filters.RowFilterChain(filters=[
    row_filters.FamilyNameRegexFilter('profile'),
    row_filters.ColumnQualifierRegexFilter(b'name'),
    row_filters.CellsColumnLimitFilter(1)
])

rows = table.read_rows(filter_=chain)
```

✅ **Monitor and prevent hot spots**
```bash
# Use Key Visualizer
# Navigate to: Cloud Console > Bigtable > Instance > Key Visualizer

# Check for:
# - Dark vertical lines (hot spots)
# - Uneven distribution
# - Sequential access patterns
```

---

## Memorystore Best Practices

### Configuration

✅ **Use Standard tier for production**
```bash
# Production instance
gcloud redis instances create prod-redis \
  --size=5 \
  --region=us-central1 \
  --tier=standard \
  --redis-version=redis_7_0 \
  --replica-count=1
```

✅ **Configure eviction policies**
```bash
# Set LRU eviction
gcloud redis instances update my-redis \
  --update-redis-config=maxmemory-policy=allkeys-lru
```

### Performance

✅ **Use connection pooling**
```python
import redis

# Create connection pool
pool = redis.ConnectionPool(
    host='10.0.0.3',
    port=6379,
    max_connections=50,
    decode_responses=True
)

# Use pool
r = redis.Redis(connection_pool=pool)
```

✅ **Use pipelining**
```python
# Batch operations with pipeline
pipe = r.pipeline()
for i in range(1000):
    pipe.set(f'key{i}', f'value{i}')
pipe.execute()
```

✅ **Set appropriate TTLs**
```python
# Set expiration
r.setex('session:123', 3600, 'data')  # 1 hour

# Set expiration on existing key
r.expire('key', 3600)
```

---

## Security Best Practices

### Network Security

✅ **Use private IP addresses**
```hcl
# Cloud SQL with private IP
resource "google_sql_database_instance" "main" {
  settings {
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }
  }
}

# Bigtable (always private)
# Memorystore (always private)
```

✅ **Use VPC Service Controls**
```bash
# Create service perimeter
gcloud access-context-manager perimeters create db_perimeter \
  --title="Database Perimeter" \
  --resources=projects/PROJECT_ID \
  --restricted-services=sqladmin.googleapis.com,spanner.googleapis.com
```

### Access Control

✅ **Use IAM for authentication**
```bash
# Cloud SQL IAM user
gcloud sql users create user@example.com \
  --instance=my-instance \
  --type=CLOUD_IAM_USER

# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:user@example.com \
  --role=roles/cloudsql.client
```

✅ **Implement least privilege**
```sql
-- Create application user with minimal permissions
CREATE USER 'app_user'@'%' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON app_db.* TO 'app_user'@'%';

-- Read-only user
CREATE USER 'readonly_user'@'%' IDENTIFIED BY 'password';
GRANT SELECT ON app_db.* TO 'readonly_user'@'%';
```

### Encryption

✅ **Enable encryption at rest**
```bash
# Cloud SQL with CMEK
gcloud sql instances create my-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --disk-encryption-key=projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/KEY
```

✅ **Require SSL/TLS**
```bash
# Require SSL for Cloud SQL
gcloud sql instances patch my-instance \
  --require-ssl
```

### Audit Logging

✅ **Enable audit logs**
```bash
# Enable Cloud SQL audit logs
gcloud logging sinks create sql-audit-sink \
  storage.googleapis.com/audit-logs-bucket \
  --log-filter='resource.type="cloudsql_database"'
```

---

## Performance Best Practices

### Query Optimization

✅ **Use EXPLAIN to analyze queries**
```sql
-- MySQL
EXPLAIN SELECT * FROM users WHERE email = 'john@example.com';

-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'john@example.com';

-- Cloud Spanner
@{EXPLAIN_ANALYZE=TRUE}
SELECT * FROM users WHERE email = 'john@example.com';
```

✅ **Create appropriate indexes**
```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Covering index (Cloud Spanner)
CREATE INDEX idx_users_email_name ON users(email) STORING (name);
```

### Connection Management

✅ **Use connection pooling**
```python
import sqlalchemy

# Create connection pool
engine = sqlalchemy.create_engine(
    "mysql+pymysql://user:password@host/database",
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=1800,
    pool_pre_ping=True
)

# Use connection
with engine.connect() as conn:
    result = conn.execute("SELECT * FROM users")
```

### Caching Strategy

✅ **Implement multi-level caching**
```
Application
    |
    v
┌─────────────────┐
│  Application    │ ← L1: In-memory cache
│  Cache          │
└────────┬────────┘
         │ Miss
         v
┌─────────────────┐
│  Memorystore    │ ← L2: Distributed cache
│  (Redis)        │
└────────┬────────┘
         │ Miss
         v
┌─────────────────┐
│  Database       │ ← L3: Persistent storage
│  (Cloud SQL)    │
└─────────────────┘
```

```python
import redis
from functools import lru_cache

# L1: Application cache
@lru_cache(maxsize=1000)
def get_user_from_app_cache(user_id):
    return None  # Placeholder

# L2: Redis cache
r = redis.Redis(host='10.0.0.3', port=6379)

def get_user(user_id):
    # Try L1 cache
    user = get_user_from_app_cache(user_id)
    if user:
        return user
    
    # Try L2 cache
    user = r.get(f'user:{user_id}')
    if user:
        return user
    
    # Query database
    user = db.query(f'SELECT * FROM users WHERE id = {user_id}')
    
    # Update caches
    r.setex(f'user:{user_id}', 3600, user)
    
    return user
```

---

## Cost Optimization

### Right-Sizing

✅ **Monitor and adjust instance sizes**
```bash
# Check CPU usage
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/cpu/utilization"'

# Resize if usage < 50%
gcloud sql instances patch my-instance \
  --tier=db-n1-standard-2
```

✅ **Use autoscaling**
```hcl
# Cloud Spanner autoscaling
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

# Bigtable autoscaling
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

### Storage Optimization

✅ **Implement data lifecycle policies**
```sql
-- Delete old data
DELETE FROM logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Archive to Cloud Storage
SELECT * INTO OUTFILE 'gs://bucket/archive.csv'
FROM logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 365 DAY);
```

✅ **Use appropriate storage types**
```bash
# Use HDD for cold data (Bigtable)
gcloud bigtable clusters create cold-cluster \
  --instance=my-instance \
  --zone=us-central1-b \
  --num-nodes=3 \
  --storage-type=HDD

# Use HDD for dev/test (Cloud SQL)
gcloud sql instances create dev-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --storage-type=HDD
```

### Committed Use Discounts

✅ **Use CUDs for predictable workloads**
```bash
# 1-year commitment: 25% discount
# 3-year commitment: 52% discount

# Purchase commitment
gcloud compute commitments create my-commitment \
  --region=us-central1 \
  --resources=vcpu=10,memory=40GB \
  --plan=12-month
```

---

## Disaster Recovery

### Backup Strategy

✅ **Implement 3-2-1 backup rule**
- 3 copies of data
- 2 different storage types
- 1 off-site backup

```bash
# Automated backups (Cloud SQL)
gcloud sql instances patch my-instance \
  --backup-start-time=03:00 \
  --retained-backups-count=30

# Export to Cloud Storage
gcloud sql export sql my-instance gs://backup-bucket/backup-$(date +%Y%m%d).sql

# Cross-region backup
gsutil rsync -r gs://backup-bucket gs://backup-bucket-eu
```

### Recovery Testing

✅ **Test recovery procedures regularly**
```bash
# Test restore (Cloud SQL)
gcloud sql instances clone my-instance test-restore \
  --point-in-time='2026-03-05T10:30:00.000Z'

# Verify data
gcloud sql connect test-restore --user=root

# Delete test instance
gcloud sql instances delete test-restore
```

### High Availability

✅ **Multi-region deployment**
```
Primary Region (us-central1)
    |
    ├─> Cloud SQL (HA)
    ├─> Read Replicas
    └─> Backups
    
Secondary Region (us-east1)
    |
    ├─> Read Replica
    └─> Backups (Cross-region)
    
Disaster Recovery Region (europe-west1)
    |
    └─> Backups (Cross-region)
```

---

## Monitoring and Alerting

### Key Metrics

✅ **Monitor critical metrics**
```bash
# CPU utilization
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/cpu/utilization"'

# Memory utilization
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/memory/utilization"'

# Disk utilization
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/disk/utilization"'

# Connection count
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/network/connections"'
```

✅ **Set up alerts**
```bash
# High CPU alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Database CPU" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s

# Low disk space alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Low Disk Space" \
  --condition-display-name="Disk > 90%" \
  --condition-threshold-value=0.9 \
  --condition-threshold-duration=300s
```

---

## Summary

### Production Checklist

**Before Going Live:**

- [ ] High availability configured
- [ ] Automated backups enabled
- [ ] Monitoring and alerting set up
- [ ] Security rules implemented
- [ ] Performance testing completed
- [ ] Disaster recovery plan documented
- [ ] Cost optimization reviewed
- [ ] Connection pooling configured
- [ ] Indexes created
- [ ] SSL/TLS enabled
- [ ] IAM permissions configured
- [ ] Audit logging enabled
- [ ] Documentation updated
- [ ] Team trained

**After Going Live:**

- [ ] Monitor performance metrics
- [ ] Review slow queries
- [ ] Test backup restoration
- [ ] Review security logs
- [ ] Optimize costs
- [ ] Update documentation
- [ ] Regular security audits
- [ ] Capacity planning

---

## Next Steps

- **[Overview](0-Overview.md)** - Database services overview
- **[Database Comparison](6-Database-Comparison.md)** - Detailed comparison
- **[Cloud SQL](1-Cloud-SQL.md)** - Relational database details

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
