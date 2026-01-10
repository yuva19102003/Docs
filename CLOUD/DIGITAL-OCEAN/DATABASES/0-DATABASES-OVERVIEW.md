# DigitalOcean Managed Databases Overview

## Introduction

DigitalOcean Managed Databases provide fully managed database clusters with automated backups, high availability, and easy scaling. Focus on your application while DigitalOcean handles database administration, maintenance, and security.

## Supported Database Engines

### PostgreSQL
```
Versions: 12, 13, 14, 15, 16
Use Cases:
├─> Web applications
├─> Analytics
├─> Geospatial data
└─> JSON workloads

Features:
├─> ACID compliance
├─> Advanced indexing
├─> Full-text search
└─> Extensions support
```

### MySQL
```
Versions: 8.0
Use Cases:
├─> WordPress
├─> E-commerce
├─> CMS platforms
└─> Legacy applications

Features:
├─> InnoDB engine
├─> Replication
├─> ACID compliance
└─> Wide compatibility
```

### Redis
```
Versions: 6, 7
Use Cases:
├─> Caching
├─> Session storage
├─> Real-time analytics
└─> Message queues

Features:
├─> In-memory storage
├─> Pub/Sub
├─> Data structures
└─> High performance
```

### MongoDB
```
Versions: 5, 6, 7
Use Cases:
├─> Document storage
├─> Content management
├─> Real-time analytics
└─> IoT applications

Features:
├─> Flexible schema
├─> Horizontal scaling
├─> Aggregation framework
└─> Geospatial queries
```

### Kafka
```
Versions: 3.5, 3.6
Use Cases:
├─> Event streaming
├─> Log aggregation
├─> Real-time pipelines
└─> Microservices communication

Features:
├─> High throughput
├─> Fault tolerance
├─> Scalability
└─> Stream processing
```

### OpenSearch
```
Versions: 1.x, 2.x
Use Cases:
├─> Full-text search
├─> Log analytics
├─> Application monitoring
└─> Security analytics

Features:
├─> RESTful API
├─> Distributed search
├─> Real-time indexing
└─> Visualization (Dashboards)
```

## Key Features

- **Automated Backups**: Daily backups with point-in-time recovery
- **High Availability**: Standby nodes for failover
- **Auto-Scaling**: Vertical and horizontal scaling
- **Monitoring**: Built-in metrics and alerts
- **Security**: Encrypted connections, VPC support
- **Maintenance**: Automated updates and patches
- **Connection Pooling**: PgBouncer for PostgreSQL
- **Read Replicas**: Scale read operations
- **Migration Tools**: Easy data import
- **99.99% SLA**: Production-ready reliability


## Database Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Managed Database Cluster                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Primary Node (Read/Write)                      │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Database Engine (PostgreSQL/MySQL/etc.)         │ │ │
│  │  │  ├─> Active connections                          │ │ │
│  │  │  ├─> Write operations                            │ │ │
│  │  │  └─> Read operations                             │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────┬───────────────────────────┘ │
│                                │                             │
│                         Replication                          │
│                                │                             │
│  ┌────────────────────────────┼───────────────────────────┐ │
│  │         Standby Node (High Availability)              │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Replica Database                                │ │ │
│  │  │  ├─> Synchronous replication                     │ │ │
│  │  │  ├─> Automatic failover                          │ │ │
│  │  │  └─> Promoted on primary failure                 │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Read Replicas (Optional)                       │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │ │
│  │  │ Replica  │  │ Replica  │  │ Replica  │           │ │
│  │  │    #1    │  │    #2    │  │    #3    │           │ │
│  │  └──────────┘  └──────────┘  └──────────┘           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Automated Services                             │ │
│  │  ├─> Daily backups (retained 7 days)                  │ │
│  │  ├─> Point-in-time recovery                           │ │
│  │  ├─> Monitoring & alerts                              │ │
│  │  ├─> Automatic updates                                │ │
│  │  └─> Connection pooling (PostgreSQL)                  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Cluster Configurations

### Basic Plans
```
db-s-1vcpu-1gb    - $15/month  - Development
db-s-1vcpu-2gb    - $30/month  - Small apps
db-s-2vcpu-4gb    - $60/month  - Medium apps
db-s-4vcpu-8gb    - $120/month - Production
```

### General Purpose
```
db-s-6vcpu-16gb   - $240/month - High traffic
db-s-8vcpu-32gb   - $480/month - Enterprise
```

### Dedicated CPU
```
gd-2vcpu-8gb      - $90/month  - Consistent performance
gd-4vcpu-16gb     - $180/month - High performance
gd-8vcpu-32gb     - $360/month - Mission critical
```

### Memory-Optimized
```
m-2vcpu-16gb      - $180/month - In-memory workloads
m-4vcpu-32gb      - $360/month - Large datasets
m-8vcpu-64gb      - $720/month - Big data
```

## Quick Start

### Create PostgreSQL Database

```bash
# Via doctl
doctl databases create my-postgres-db \
  --engine pg \
  --version 16 \
  --region nyc3 \
  --size db-s-2vcpu-4gb \
  --num-nodes 2

# Get connection details
doctl databases connection my-postgres-db

# Create database
doctl databases db create my-postgres-db app_db

# Create user
doctl databases user create my-postgres-db app_user
```

### Connect to Database

```bash
# PostgreSQL
psql "postgresql://username:password@host:port/database?sslmode=require"

# MySQL
mysql -h host -P port -u username -p database

# Redis
redis-cli -h host -p port -a password --tls

# MongoDB
mongosh "mongodb+srv://username:password@host/database"
```

## Connection Pooling (PostgreSQL)

```
PgBouncer (Built-in):
├─> Reduces connection overhead
├─> Improves performance
├─> Handles connection limits
└─> Automatic configuration

Connection String:
postgresql://user:pass@host:25061/db?sslmode=require

Benefits:
├─> Up to 10x more connections
├─> Lower memory usage
├─> Better resource utilization
└─> Improved scalability
```

## High Availability

### Automatic Failover

```
Normal Operation:
Primary Node (Active) → Standby Node (Syncing)

Failure Detected:
Primary Node (Failed) → Standby Node (Promoting)

After Failover:
New Primary (Active) → Old Primary (Recovering)

Downtime: < 30 seconds
```

### Read Replicas

```bash
# Add read replica
doctl databases replica create my-postgres-db \
  --name read-replica-1 \
  --region nyc3 \
  --size db-s-2vcpu-4gb

# Get replica connection
doctl databases replica connection my-postgres-db read-replica-1

# Use for read-only queries
# Reduces load on primary
```

## Backups and Recovery

### Automated Backups

```
Daily Backups:
├─> Automatic daily backups
├─> Retained for 7 days
├─> No performance impact
└─> Free (included)

Point-in-Time Recovery:
├─> Restore to any point in last 7 days
├─> Granularity: 1 second
├─> Creates new cluster
└─> No data loss
```

### Manual Backups

```bash
# Create backup (fork)
doctl databases fork my-postgres-db \
  --name backup-2026-01-10 \
  --region nyc3

# Restore from backup
# Creates new cluster from fork
```

## Monitoring

### Built-in Metrics

```
Available Metrics:
├─> CPU usage
├─> Memory usage
├─> Disk usage
├─> Network I/O
├─> Connection count
├─> Query performance
└─> Replication lag

Alerts:
├─> High CPU (>80%)
├─> High memory (>90%)
├─> Disk space low (<10%)
├─> Connection limit reached
└─> Replication lag high
```

### Query Performance

```sql
-- PostgreSQL: Slow queries
SELECT * FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- MySQL: Slow queries
SELECT * FROM mysql.slow_log
ORDER BY query_time DESC
LIMIT 10;
```

## Security

### Encryption

```
In-Transit:
├─> TLS/SSL required
├─> Certificate verification
└─> Encrypted connections

At-Rest:
├─> AES-256 encryption
├─> Encrypted backups
└─> Encrypted replicas
```

### Access Control

```
VPC Integration:
├─> Private network access
├─> No public internet exposure
├─> Secure communication
└─> Network isolation

Trusted Sources:
├─> IP whitelist
├─> Restrict access by IP
├─> Multiple IPs supported
└─> CIDR notation
```

### User Management

```bash
# Create user with specific privileges
doctl databases user create my-postgres-db app_user

# Reset password
doctl databases user reset my-postgres-db app_user

# Delete user
doctl databases user delete my-postgres-db app_user
```

## Migration

### From External Database

```bash
# PostgreSQL migration
pg_dump -h old-host -U user -d database | \
  psql "postgresql://user:pass@new-host:port/database?sslmode=require"

# MySQL migration
mysqldump -h old-host -u user -p database | \
  mysql -h new-host -P port -u user -p database

# MongoDB migration
mongodump --uri="mongodb://old-host/database" --archive | \
  mongorestore --uri="mongodb+srv://new-host/database" --archive
```

### From DigitalOcean Droplet

```bash
# 1. Create managed database
# 2. Export from Droplet database
# 3. Import to managed database
# 4. Update application connection strings
# 5. Test thoroughly
# 6. Switch traffic
```

## Scaling

### Vertical Scaling

```bash
# Resize cluster
doctl databases resize my-postgres-db \
  --size db-s-4vcpu-8gb

# Downtime: 1-5 minutes
# Automatic failover to standby
```

### Horizontal Scaling

```bash
# Add read replicas
doctl databases replica create my-postgres-db \
  --name replica-2

# Distribute read traffic
# Primary handles writes
# Replicas handle reads
```

## Best Practices

### 1. Connection Management

```python
# Use connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@host:port/db',
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True
)
```

### 2. Query Optimization

```sql
-- Create indexes
CREATE INDEX idx_user_email ON users(email);

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- Use prepared statements
PREPARE user_query AS SELECT * FROM users WHERE id = $1;
EXECUTE user_query(123);
```

### 3. Monitoring

```
Regular Checks:
├─> Monitor slow queries
├─> Check connection count
├─> Review disk usage
├─> Monitor replication lag
└─> Set up alerts
```

### 4. Security

```
Best Practices:
├─> Use VPC for private access
├─> Rotate passwords regularly
├─> Use least privilege users
├─> Enable SSL/TLS
└─> Whitelist trusted IPs
```

## Pricing

### PostgreSQL/MySQL
```
Basic: $15-120/month
General Purpose: $240-480/month
Dedicated: $90-360/month
Memory-Optimized: $180-720/month

Additional Costs:
├─> Read replicas: Same as node size
├─> Backups: Included (7 days)
└─> Bandwidth: Included
```

### Redis
```
Basic: $15-120/month
Dedicated: $90-360/month

Features:
├─> In-memory caching
├─> Persistence options
└─> High availability
```

### MongoDB
```
Basic: $15-120/month
General Purpose: $240-480/month

Features:
├─> Document storage
├─> Flexible schema
└─> Horizontal scaling
```

## Use Cases

### 1. Web Applications
```
Stack:
├─> PostgreSQL: User data, transactions
├─> Redis: Session storage, caching
└─> Read replicas: Scale read operations
```

### 2. E-commerce
```
Stack:
├─> MySQL: Product catalog, orders
├─> Redis: Shopping cart, cache
└─> High availability: Zero downtime
```

### 3. Analytics
```
Stack:
├─> PostgreSQL: Time-series data
├─> OpenSearch: Log analytics
└─> MongoDB: Flexible event data
```

### 4. Microservices
```
Stack:
├─> PostgreSQL: Per-service databases
├─> Kafka: Event streaming
└─> Redis: Shared cache
```

## Troubleshooting

### Connection Issues

```bash
# Test connection
psql "postgresql://user:pass@host:port/db?sslmode=require"

# Check firewall rules
doctl databases firewalls list my-postgres-db

# Add trusted source
doctl databases firewalls append my-postgres-db \
  --rule ip_addr:203.0.113.10
```

### Performance Issues

```sql
-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Find slow queries
SELECT * FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check locks
SELECT * FROM pg_locks;
```

### High CPU/Memory

```
Solutions:
├─> Optimize queries
├─> Add indexes
├─> Use connection pooling
├─> Scale vertically
└─> Add read replicas
```

## Documentation Structure

1. **[Databases Overview](./0-DATABASES-OVERVIEW.md)** - This page
2. **[PostgreSQL Guide](./1-POSTGRESQL.md)** - PostgreSQL specifics
3. **[MySQL Guide](./2-MYSQL.md)** - MySQL specifics
4. **[Redis Guide](./3-REDIS.md)** - Redis caching

## Additional Resources

- [Official Documentation](https://docs.digitalocean.com/products/databases/)
- [Connection Strings](https://docs.digitalocean.com/products/databases/postgresql/how-to/connect/)
- [Pricing](https://www.digitalocean.com/pricing/managed-databases)
