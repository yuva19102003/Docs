# Cloud SQL - Managed Relational Database

Complete guide to Google Cloud SQL - fully managed MySQL, PostgreSQL, and SQL Server.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Database Engines](#database-engines)
3. [Instance Configuration](#instance-configuration)
4. [High Availability](#high-availability)
5. [Replication](#replication)
6. [Backup and Recovery](#backup-and-recovery)
7. [Security](#security)
8. [Performance](#performance)
9. [Migration](#migration)
10. [Cost Optimization](#cost-optimization)
11. [Best Practices](#best-practices)

---

## Introduction

Cloud SQL is a fully managed relational database service for MySQL, PostgreSQL, and SQL Server.

### Key Features

✅ Fully managed service  
✅ Automatic backups  
✅ High availability (99.95% SLA)  
✅ Read replicas  
✅ Point-in-time recovery  
✅ Automatic storage increase  
✅ Integrated with GCP services  
✅ Private IP connectivity  
✅ Automatic encryption  
✅ Maintenance windows  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│              Cloud SQL Instance                     │
├─────────────────────────────────────────────────────┤
│  Primary Instance (us-central1-a)                   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Database Engine                             │   │
│  │  - MySQL / PostgreSQL / SQL Server           │   │
│  │  - Compute resources                         │   │
│  │  - Storage (SSD/HDD)                         │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Standby Instance (us-central1-b)                   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Synchronous replication                     │   │
│  │  - Automatic failover                        │   │
│  │  - Same zone or different zone               │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Read Replicas (Optional)                           │
│  ┌──────────────────────────────────────────────┐   │
│  │  Asynchronous replication                    │   │
│  │  - Read-only access                          │   │
│  │  - Cross-region support                      │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Database Engines

### MySQL

**Supported Versions:**
- MySQL 5.7
- MySQL 8.0 (recommended)

**Features:**
- InnoDB storage engine
- Binary logging
- GTID replication
- Performance Schema
- JSON support
- Full-text search

**Create MySQL Instance:**

```bash
gcloud sql instances create mysql-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --root-password=YOUR_PASSWORD \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --maintenance-window-day=SUN \
  --maintenance-window-hour=4
```

### PostgreSQL

**Supported Versions:**
- PostgreSQL 12
- PostgreSQL 13
- PostgreSQL 14
- PostgreSQL 15 (recommended)

**Features:**
- Advanced data types (JSON, Arrays, hstore)
- Full-text search
- PostGIS extension
- Logical replication
- Partitioning
- Parallel queries

**Create PostgreSQL Instance:**

```bash
gcloud sql instances create postgres-instance \
  --database-version=POSTGRES_15 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --root-password=YOUR_PASSWORD \
  --backup-start-time=03:00 \
  --database-flags=max_connections=200
```

### SQL Server

**Supported Versions:**
- SQL Server 2017 Standard
- SQL Server 2019 Standard
- SQL Server 2022 Standard (recommended)
- SQL Server 2019 Enterprise
- SQL Server 2022 Enterprise

**Features:**
- Always On Availability Groups
- SQL Server Agent
- Full-text search
- Integration Services
- Reporting Services
- Analysis Services

**Create SQL Server Instance:**

```bash
gcloud sql instances create sqlserver-instance \
  --database-version=SQLSERVER_2022_STANDARD \
  --tier=db-custom-4-16384 \
  --region=us-central1 \
  --root-password=YOUR_PASSWORD \
  --backup-start-time=03:00
```

---

## Instance Configuration

### Machine Types

**Shared-core machines (Development/Testing):**

| Type | vCPUs | Memory | Use Case |
|------|-------|--------|----------|
| **db-f1-micro** | 0.6 | 0.6 GB | Development |
| **db-g1-small** | 1.7 | 1.7 GB | Small apps |

**Standard machines:**

| Type | vCPUs | Memory | Price/month |
|------|-------|--------|-------------|
| **db-n1-standard-1** | 1 | 3.75 GB | $50 |
| **db-n1-standard-2** | 2 | 7.5 GB | $100 |
| **db-n1-standard-4** | 4 | 15 GB | $200 |
| **db-n1-standard-8** | 8 | 30 GB | $400 |
| **db-n1-standard-16** | 16 | 60 GB | $800 |

**High-memory machines:**

| Type | vCPUs | Memory | Price/month |
|------|-------|--------|-------------|
| **db-n1-highmem-2** | 2 | 13 GB | $130 |
| **db-n1-highmem-4** | 4 | 26 GB | $260 |
| **db-n1-highmem-8** | 8 | 52 GB | $520 |
| **db-n1-highmem-16** | 16 | 104 GB | $1,040 |

**Custom machines:**

```bash
# Create custom machine type
gcloud sql instances create custom-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-custom-4-16384 \
  --region=us-central1
```

### Storage Configuration

**Storage Types:**

| Type | Performance | Use Case | Price |
|------|-------------|----------|-------|
| **SSD** | High IOPS | Production | $0.17/GB/month |
| **HDD** | Standard | Development | $0.09/GB/month |

**Storage Limits:**
- Minimum: 10 GB
- Maximum: 64 TB (MySQL/PostgreSQL), 10 TB (SQL Server)

**Configure Storage:**

```bash
# Create instance with storage
gcloud sql instances create my-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --storage-type=SSD \
  --storage-size=100GB \
  --storage-auto-increase \
  --storage-auto-increase-limit=500
```

### Terraform Configuration

```hcl
resource "google_sql_database_instance" "main" {
  name             = "my-instance"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  
  settings {
    tier = "db-n1-standard-2"
    
    disk_type = "PD_SSD"
    disk_size = 100
    disk_autoresize = true
    disk_autoresize_limit = 500
    
    backup_configuration {
      enabled            = true
      start_time         = "03:00"
      binary_log_enabled = true
      transaction_log_retention_days = 7
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
      require_ssl     = true
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 4
      update_track = "stable"
    }
    
    database_flags {
      name  = "max_connections"
      value = "200"
    }
    
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }
  }
  
  deletion_protection = true
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  name     = "app-user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
```

---

## High Availability

### HA Configuration

```
┌─────────────────────────────────────────┐
│     High Availability Setup             │
├─────────────────────────────────────────┤
│  Zone A (us-central1-a)                 │
│  ┌──────────────────────────────────┐   │
│  │  Primary Instance                │   │
│  │  - Active                        │   │
│  │  - Read/Write                    │   │
│  └──────────────────────────────────┘   │
│           │                             │
│           │ Synchronous                 │
│           │ Replication                 │
│           v                             │
│  Zone B (us-central1-b)                 │
│  ┌──────────────────────────────────┐   │
│  │  Standby Instance                │   │
│  │  - Passive                       │   │
│  │  - Automatic Failover            │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Enable HA:**

```bash
# Create HA instance
gcloud sql instances create ha-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --availability-type=REGIONAL \
  --backup-start-time=03:00

# Enable HA on existing instance
gcloud sql instances patch my-instance \
  --availability-type=REGIONAL
```

**HA Features:**
- 99.95% availability SLA
- Automatic failover (30-120 seconds)
- Synchronous replication
- Zero data loss
- Same region, different zones
- Transparent to applications

---

## Replication

### Read Replicas

```
┌─────────────────────────────────────────┐
│        Primary Instance                 │
│        (us-central1)                    │
└──────────────┬──────────────────────────┘
               │
               │ Asynchronous
               │ Replication
               │
    ┌──────────┼──────────┐
    v          v          v
┌────────┐ ┌────────┐ ┌────────┐
│Replica │ │Replica │ │Replica │
│ (Read) │ │ (Read) │ │(Cross- │
│        │ │        │ │region) │
└────────┘ └────────┘ └────────┘
```

**Create Read Replica:**

```bash
# Create read replica (same region)
gcloud sql instances create replica-1 \
  --master-instance-name=my-instance \
  --tier=db-n1-standard-2 \
  --region=us-central1

# Create cross-region replica
gcloud sql instances create replica-eu \
  --master-instance-name=my-instance \
  --tier=db-n1-standard-2 \
  --region=europe-west1
```

**Replica Features:**
- Read-only access
- Asynchronous replication
- Cross-region support
- Promote to standalone
- Cascade replicas
- Up to 10 replicas per instance

**Python Example:**

```python
from google.cloud.sql.connector import Connector
import sqlalchemy

# Initialize Connector
connector = Connector()

# Connection to primary (read/write)
def getconn_primary():
    conn = connector.connect(
        "project:region:instance",
        "pymysql",
        user="user",
        password="password",
        db="database"
    )
    return conn

# Connection to replica (read-only)
def getconn_replica():
    conn = connector.connect(
        "project:region:replica-1",
        "pymysql",
        user="user",
        password="password",
        db="database"
    )
    return conn

# Create connection pools
primary_pool = sqlalchemy.create_engine(
    "mysql+pymysql://",
    creator=getconn_primary,
)

replica_pool = sqlalchemy.create_engine(
    "mysql+pymysql://",
    creator=getconn_replica,
)

# Write to primary
with primary_pool.connect() as conn:
    conn.execute("INSERT INTO users (name) VALUES ('John')")

# Read from replica
with replica_pool.connect() as conn:
    result = conn.execute("SELECT * FROM users")
    for row in result:
        print(row)
```

---

## Backup and Recovery

### Automated Backups

```
┌─────────────────────────────────────────┐
│        Backup Strategy                  │
├─────────────────────────────────────────┤
│  Automated Backups                      │
│  - Daily backups                        │
│  - 7-365 days retention                 │
│  - Binary logs (MySQL)                  │
│  - Transaction logs (PostgreSQL)        │
│                                         │
│  Point-in-Time Recovery                 │
│  - Restore to any point in time         │
│  - Within retention period              │
│  - Creates new instance                 │
│                                         │
│  On-Demand Backups                      │
│  - Manual backups                       │
│  - Custom retention                     │
│  - Export to Cloud Storage              │
└─────────────────────────────────────────┘
```

**Configure Backups:**

```bash
# Enable automated backups
gcloud sql instances patch my-instance \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --retained-backups-count=30 \
  --retained-transaction-log-days=7

# Create on-demand backup
gcloud sql backups create \
  --instance=my-instance \
  --description="Pre-migration backup"

# List backups
gcloud sql backups list --instance=my-instance

# Restore from backup
gcloud sql backups restore BACKUP_ID \
  --backup-instance=my-instance \
  --backup-id=BACKUP_ID
```

### Point-in-Time Recovery

```bash
# Restore to specific time
gcloud sql instances clone my-instance restored-instance \
  --point-in-time='2026-03-05T10:30:00.000Z'

# Restore to latest
gcloud sql instances clone my-instance restored-instance
```

### Export and Import

**Export Database:**

```bash
# Export to Cloud Storage
gcloud sql export sql my-instance gs://my-bucket/backup.sql \
  --database=my-database

# Export specific tables
gcloud sql export sql my-instance gs://my-bucket/backup.sql \
  --database=my-database \
  --table=users,orders

# Export as CSV
gcloud sql export csv my-instance gs://my-bucket/data.csv \
  --database=my-database \
  --query="SELECT * FROM users WHERE created_at > '2026-01-01'"
```

**Import Database:**

```bash
# Import from Cloud Storage
gcloud sql import sql my-instance gs://my-bucket/backup.sql \
  --database=my-database

# Import CSV
gcloud sql import csv my-instance gs://my-bucket/data.csv \
  --database=my-database \
  --table=users
```

---

## Security

### Network Security

**Private IP Configuration:**

```bash
# Create instance with private IP
gcloud sql instances create private-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --network=projects/PROJECT_ID/global/networks/default \
  --no-assign-ip

# Add authorized network (public IP)
gcloud sql instances patch my-instance \
  --authorized-networks=203.0.113.0/24
```

**SSL/TLS Configuration:**

```bash
# Require SSL
gcloud sql instances patch my-instance \
  --require-ssl

# Create client certificate
gcloud sql ssl-certs create my-cert \
  --instance=my-instance

# Download certificate
gcloud sql ssl-certs describe my-cert \
  --instance=my-instance \
  --format="get(cert)" > client-cert.pem
```

### IAM Authentication

**Enable IAM Authentication:**

```bash
# Create IAM user
gcloud sql users create user@example.com \
  --instance=my-instance \
  --type=CLOUD_IAM_USER

# Create IAM service account
gcloud sql users create sa@project.iam.gserviceaccount.com \
  --instance=my-instance \
  --type=CLOUD_IAM_SERVICE_ACCOUNT
```

**Connect with IAM:**

```python
from google.cloud.sql.connector import Connector
import sqlalchemy

connector = Connector()

def getconn():
    conn = connector.connect(
        "project:region:instance",
        "pymysql",
        user="user@example.com",
        db="database",
        enable_iam_auth=True,
    )
    return conn

pool = sqlalchemy.create_engine(
    "mysql+pymysql://",
    creator=getconn,
)
```

### Encryption

**Encryption at Rest:**
- Automatic encryption with Google-managed keys
- Customer-managed encryption keys (CMEK)

```bash
# Create instance with CMEK
gcloud sql instances create cmek-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --disk-encryption-key=projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/KEY
```

**Encryption in Transit:**
- SSL/TLS encryption
- Automatic for Cloud SQL Proxy
- Required for public IP connections

---

## Performance

### Query Insights

```bash
# Enable Query Insights
gcloud sql instances patch my-instance \
  --insights-config-query-insights-enabled \
  --insights-config-query-string-length=1024 \
  --insights-config-record-application-tags
```

**View Query Insights:**
- Top queries by execution time
- Query frequency
- Query latency
- Lock wait time
- Rows examined

### Performance Optimization

**Database Flags:**

```bash
# MySQL optimization
gcloud sql instances patch my-instance \
  --database-flags=\
max_connections=200,\
innodb_buffer_pool_size=4294967296,\
innodb_log_file_size=536870912,\
query_cache_size=0

# PostgreSQL optimization
gcloud sql instances patch postgres-instance \
  --database-flags=\
max_connections=200,\
shared_buffers=2GB,\
effective_cache_size=6GB,\
work_mem=10MB
```

**Connection Pooling:**

```python
import sqlalchemy

# Create connection pool
pool = sqlalchemy.create_engine(
    "mysql+pymysql://user:password@/database",
    pool_size=5,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=1800,
)

# Use connection
with pool.connect() as conn:
    result = conn.execute("SELECT * FROM users")
```

### Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/cpu/utilization"' \
  --format=json

# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s
```

---

## Migration

### Database Migration Service

```
┌─────────────────────────────────────────┐
│     Migration Flow                      │
├─────────────────────────────────────────┤
│  Source Database                        │
│  (On-premises / Other cloud)            │
│           │                             │
│           v                             │
│  ┌──────────────────────────────────┐   │
│  │  Database Migration Service      │   │
│  │  - Continuous replication        │   │
│  │  - Minimal downtime              │   │
│  │  - Data validation               │   │
│  └──────────────────────────────────┘   │
│           │                             │
│           v                             │
│  Cloud SQL Instance                     │
│  (Target)                               │
└─────────────────────────────────────────┘
```

**Migration Steps:**

```bash
# 1. Create migration job
gcloud database-migration migration-jobs create my-migration \
  --region=us-central1 \
  --type=CONTINUOUS \
  --source=SOURCE_CONNECTION_PROFILE \
  --destination=DESTINATION_CONNECTION_PROFILE

# 2. Start migration
gcloud database-migration migration-jobs start my-migration \
  --region=us-central1

# 3. Promote (cutover)
gcloud database-migration migration-jobs promote my-migration \
  --region=us-central1
```

### Manual Migration

**Export from source:**

```bash
# MySQL export
mysqldump -h SOURCE_HOST -u USER -p \
  --databases DATABASE_NAME \
  --single-transaction \
  --quick \
  --lock-tables=false \
  > backup.sql

# Upload to Cloud Storage
gsutil cp backup.sql gs://my-bucket/
```

**Import to Cloud SQL:**

```bash
# Import
gcloud sql import sql my-instance gs://my-bucket/backup.sql \
  --database=DATABASE_NAME
```

---

## Cost Optimization

### Pricing Components

**Instance costs:**
- vCPU: $0.0413/hour per vCPU
- Memory: $0.0070/hour per GB
- Storage (SSD): $0.17/GB/month
- Storage (HDD): $0.09/GB/month
- Backups: $0.08/GB/month
- Network egress: Standard rates

### Optimization Strategies

**1. Right-size instances:**

```bash
# Monitor CPU/Memory usage
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/cpu/utilization"'

# Resize instance
gcloud sql instances patch my-instance \
  --tier=db-n1-standard-1
```

**2. Use committed use discounts:**
- 1-year: 25% discount
- 3-year: 52% discount

**3. Optimize storage:**

```bash
# Use HDD for non-production
gcloud sql instances patch dev-instance \
  --storage-type=HDD

# Set auto-increase limit
gcloud sql instances patch my-instance \
  --storage-auto-increase-limit=500
```

**4. Optimize backups:**

```bash
# Reduce retention
gcloud sql instances patch my-instance \
  --retained-backups-count=7

# Delete old backups
gcloud sql backups delete BACKUP_ID \
  --instance=my-instance
```

**5. Use read replicas efficiently:**
- Only create replicas when needed
- Delete unused replicas
- Use smaller tiers for replicas

### Cost Example

**Scenario:** Production MySQL instance

```
Configuration:
- db-n1-standard-4 (4 vCPU, 15 GB RAM)
- 500 GB SSD storage
- 1 read replica (db-n1-standard-2)
- 7 days backup retention

Monthly Cost:
- Primary instance: $200
- Storage: 500 GB × $0.17 = $85
- Replica: $100
- Backups: ~50 GB × $0.08 = $4
- Total: $389/month

With 1-year CUD:
- Instance costs: ($200 + $100) × 0.75 = $225
- Storage: $85
- Backups: $4
- Total: $314/month
- Savings: 19%
```

---

## Best Practices

### High Availability

✅ Enable regional HA for production  
✅ Use read replicas for read-heavy workloads  
✅ Configure maintenance windows  
✅ Test failover procedures  
✅ Monitor replication lag  
✅ Use connection pooling  
✅ Implement retry logic  
✅ Use Cloud SQL Proxy  

### Security

✅ Use private IP when possible  
✅ Enable SSL/TLS  
✅ Use IAM authentication  
✅ Implement least privilege  
✅ Enable audit logging  
✅ Regular security audits  
✅ Use secrets management  
✅ Rotate credentials regularly  

### Performance

✅ Enable Query Insights  
✅ Optimize queries and indexes  
✅ Use connection pooling  
✅ Configure appropriate flags  
✅ Monitor slow queries  
✅ Use read replicas  
✅ Implement caching  
✅ Regular performance testing  

### Backup and Recovery

✅ Enable automated backups  
✅ Test restore procedures  
✅ Use point-in-time recovery  
✅ Export critical data  
✅ Document recovery procedures  
✅ Monitor backup success  
✅ Retain backups appropriately  
✅ Use multiple backup strategies  

### Cost Management

✅ Right-size instances  
✅ Use committed use discounts  
✅ Delete unused instances  
✅ Optimize storage  
✅ Monitor usage  
✅ Use labels for tracking  
✅ Regular cost reviews  
✅ Implement auto-scaling where possible  

---

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
gcloud sql connect my-instance --user=root

# Check authorized networks
gcloud sql instances describe my-instance \
  --format="get(settings.ipConfiguration.authorizedNetworks)"

# Use Cloud SQL Proxy
cloud_sql_proxy -instances=PROJECT:REGION:INSTANCE=tcp:3306
```

### Performance Issues

```bash
# Check Query Insights
gcloud sql operations list --instance=my-instance

# View slow queries (MySQL)
mysql> SELECT * FROM mysql.slow_log ORDER BY query_time DESC LIMIT 10;

# Check connections
mysql> SHOW PROCESSLIST;
```

### Replication Lag

```bash
# Check replica status
gcloud sql instances describe replica-1 \
  --format="get(replicaConfiguration.replicationLag)"

# Monitor replication
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/replication/replica_lag"'
```

---

## Next Steps

- **[Cloud Spanner](2-Cloud-Spanner.md)** - Global relational database
- **[Firestore](3-Firestore.md)** - Document database
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
