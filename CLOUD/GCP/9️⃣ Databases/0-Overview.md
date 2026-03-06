# 9️⃣ Databases - Overview

Learn database options on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Database Types](#database-types)
3. [Database Services Comparison](#database-services-comparison)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Comparison](#cost-comparison)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP offers multiple database options for different use cases, from traditional relational databases to NoSQL and caching solutions.

### Database Spectrum

```
Relational          NoSQL              Wide-Column        In-Memory
    |                 |                     |                 |
    v                 v                     v                 v
┌──────────┐    ┌──────────┐        ┌──────────┐      ┌──────────┐
│  Cloud   │    │Firestore │        │ Bigtable │      │Memorystore│
│   SQL    │    │(Document)│        │ (NoSQL)  │      │  (Cache) │
└──────────┘    └──────────┘        └──────────┘      └──────────┘
┌──────────┐
│  Cloud   │
│  Spanner │
│(Global)  │
└──────────┘
```

---

## Database Types

### 1. Relational Databases

**Cloud SQL - Managed MySQL, PostgreSQL, SQL Server**

```
┌─────────────────────────────────────┐
│        Cloud SQL Instance           │
├─────────────────────────────────────┤
│  Database Engine                    │
│  - MySQL 5.7, 8.0                   │
│  - PostgreSQL 12, 13, 14, 15        │
│  - SQL Server 2017, 2019, 2022      │
├─────────────────────────────────────┤
│  Features:                          │
│  - Automatic backups                │
│  - High availability                │
│  - Read replicas                    │
│  - Point-in-time recovery           │
└─────────────────────────────────────┘
```

**Characteristics:**
- ACID transactions
- SQL queries
- Structured data
- Up to 64 TB storage
- Vertical scaling
- Read replicas

**Use Cases:**
- Web applications
- E-commerce
- CRM systems
- ERP systems
- Traditional applications

### 2. Globally Distributed Database

**Cloud Spanner - Horizontally scalable relational database**

```
┌─────────────────────────────────────┐
│        Cloud Spanner                │
├─────────────────────────────────────┤
│  Global Distribution                │
│  ┌─────────┐  ┌─────────┐          │
│  │Region 1 │  │Region 2 │          │
│  │ Node 1  │  │ Node 3  │          │
│  │ Node 2  │  │ Node 4  │          │
│  └─────────┘  └─────────┘          │
├─────────────────────────────────────┤
│  Features:                          │
│  - Strong consistency               │
│  - Horizontal scaling               │
│  - 99.999% availability             │
│  - Global transactions              │
└─────────────────────────────────────┘
```

**Characteristics:**
- ACID transactions
- SQL queries
- Horizontal scaling
- Global distribution
- Strong consistency
- 99.999% availability

**Use Cases:**
- Global applications
- Financial services
- Gaming leaderboards
- Supply chain
- Inventory management

### 3. Document Database

**Firestore - Serverless NoSQL document database**

```
┌─────────────────────────────────────┐
│          Firestore                  │
├─────────────────────────────────────┤
│  Collections & Documents            │
│  /users/{userId}                    │
│    - name: "John"                   │
│    - email: "john@example.com"      │
│    /orders/{orderId}                │
│      - items: [...]                 │
│      - total: 100                   │
├─────────────────────────────────────┤
│  Features:                          │
│  - Real-time sync                   │
│  - Offline support                  │
│  - Automatic scaling                │
│  - Mobile/web SDKs                  │
└─────────────────────────────────────┘
```

**Characteristics:**
- Document model
- Real-time updates
- Offline support
- Automatic scaling
- Mobile/web SDKs
- Serverless

**Use Cases:**
- Mobile applications
- Real-time apps
- User profiles
- Chat applications
- Collaborative apps

### 4. Wide-Column Database

**Bigtable - Petabyte-scale NoSQL database**

```
┌─────────────────────────────────────┐
│          Bigtable                   │
├─────────────────────────────────────┤
│  Row Key | Column Family            │
│  user#1  | profile:name             │
│          | profile:email            │
│          | activity:last_login      │
│  user#2  | profile:name             │
│          | activity:page_views      │
├─────────────────────────────────────┤
│  Features:                          │
│  - Petabyte scale                   │
│  - Low latency (<10ms)              │
│  - High throughput                  │
│  - HBase compatible                 │
└─────────────────────────────────────┘
```

**Characteristics:**
- Wide-column store
- Petabyte scale
- Low latency
- High throughput
- HBase API
- Time-series data

**Use Cases:**
- Time-series data
- IoT data
- Analytics
- Financial data
- AdTech

### 5. In-Memory Cache

**Memorystore - Managed Redis and Memcached**

```
┌─────────────────────────────────────┐
│        Memorystore                  │
├─────────────────────────────────────┤
│  Redis / Memcached                  │
│  ┌─────────────────────────────┐   │
│  │  Key-Value Store            │   │
│  │  - session:user123          │   │
│  │  - cache:product_list       │   │
│  │  - counter:page_views       │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Features:                          │
│  - Sub-millisecond latency          │
│  - High availability                │
│  - Automatic failover               │
│  - Up to 300 GB                     │
└─────────────────────────────────────┘
```

**Characteristics:**
- In-memory storage
- Sub-millisecond latency
- Key-value store
- Pub/Sub support (Redis)
- High availability
- Automatic failover

**Use Cases:**
- Session storage
- Caching layer
- Real-time analytics
- Leaderboards
- Rate limiting

---

## Database Services Comparison

### Feature Matrix

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **Type** | Relational | Relational | Document | Wide-column | Key-value |
| **Model** | SQL | SQL | NoSQL | NoSQL | NoSQL |
| **Transactions** | ACID | ACID | ACID | Single-row | No |
| **Scaling** | Vertical | Horizontal | Automatic | Horizontal | Vertical |
| **Max Size** | 64 TB | Unlimited | Unlimited | Petabytes | 300 GB |
| **Latency** | 5-10ms | 5-10ms | 10-20ms | <10ms | <1ms |
| **Consistency** | Strong | Strong | Strong | Eventual | Strong |
| **Global** | No | Yes | Yes | No | No |

### Performance Comparison

| Database | Read Latency | Write Latency | Throughput | Best For |
|----------|-------------|---------------|------------|----------|
| **Cloud SQL** | 5-10ms | 5-10ms | 10K QPS | Traditional apps |
| **Cloud Spanner** | 5-10ms | 5-10ms | 100K+ QPS | Global apps |
| **Firestore** | 10-20ms | 10-20ms | 10K QPS | Mobile/web apps |
| **Bigtable** | <10ms | <10ms | 1M+ QPS | Analytics, IoT |
| **Memorystore** | <1ms | <1ms | 1M+ QPS | Caching |

---

## Decision Framework

### Decision Tree

```
What type of data?
    |
    ├─> Structured + SQL needed?
    |   ├─> Global distribution? → Cloud Spanner
    |   └─> Regional? → Cloud SQL
    |
    ├─> Document/JSON data?
    |   ├─> Mobile/web app? → Firestore
    |   └─> Large scale? → Bigtable
    |
    ├─> Time-series/Analytics?
    |   └─> Bigtable
    |
    └─> Caching/Session?
        └─> Memorystore
```

### Use Case Matrix

| Requirement | Recommended | Alternative |
|-------------|-------------|-------------|
| **Web application** | Cloud SQL | Cloud Spanner |
| **Mobile app** | Firestore | Cloud SQL |
| **Global app** | Cloud Spanner | Firestore |
| **Analytics** | Bigtable | BigQuery |
| **Time-series** | Bigtable | Cloud SQL |
| **IoT data** | Bigtable | Firestore |
| **Caching** | Memorystore | - |
| **Session store** | Memorystore | Firestore |
| **E-commerce** | Cloud SQL | Cloud Spanner |
| **Gaming** | Cloud Spanner | Firestore |

---

## Architecture Patterns

### Pattern 1: Traditional Web Application

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer           │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌────────┐   ┌────────┐
│ App    │   │ App    │
│ Server │   │ Server │
└────┬───┘   └───┬────┘
     |           |
     └─────┬─────┘
           v
    ┌──────────────┐
    │  Cloud SQL   │
    │  (Primary)   │
    └──────┬───────┘
           |
    ┌──────┴───────┐
    v              v
┌─────────┐  ┌─────────┐
│ Replica │  │ Replica │
│ (Read)  │  │ (Read)  │
└─────────┘  └─────────┘
```

### Pattern 2: Global Application

```
┌─────────────────────────────────────┐
│        Cloud Spanner                │
│  (Multi-region, Global)             │
└──────────┬──────────────────────────┘
           |
    ┌──────┼──────┐
    v      v      v
┌──────┐┌──────┐┌──────┐
│ US   ││ EU   ││ Asia │
│ App  ││ App  ││ App  │
└──────┘└──────┘└──────┘
```

### Pattern 3: Mobile Application

```
Mobile Clients
    |
    v
┌─────────────────────┐
│    Firestore        │
│  (Real-time sync)   │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌──────────┐  ┌──────────┐
│ Cloud    │  │ Cloud    │
│ Functions│  │ Run      │
└──────────┘  └──────────┘
```

### Pattern 4: Analytics Pipeline

```
IoT Devices
    |
    v
┌─────────────────────┐
│    Pub/Sub          │
└──────────┬──────────┘
           v
    ┌──────────────┐
    │  Dataflow    │
    └──────┬───────┘
           v
    ┌──────────────┐
    │  Bigtable    │
    │  (Hot data)  │
    └──────┬───────┘
           |
           v (Archive)
    ┌──────────────┐
    │  BigQuery    │
    │  (Analytics) │
    └──────────────┘
```

### Pattern 5: Caching Layer

```
Application
    |
    v
┌─────────────────────┐
│  Memorystore        │
│  (Redis Cache)      │
└──────────┬──────────┘
           |
    Cache Miss
           v
    ┌──────────────┐
    │  Cloud SQL   │
    │  (Database)  │
    └──────────────┘
```

---

## Cost Comparison

### Monthly Cost Examples (us-central1)

**Scenario 1: Small Web Application**

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-f1-micro, 10 GB | $15 |
| **Cloud SQL** | db-n1-standard-1, 10 GB | $50 |
| **Cloud Spanner** | 1 node | $730 |
| **Firestore** | 1 GB, 100K reads/day | $1 |
| **Memorystore** | 1 GB Redis | $50 |

**Scenario 2: Medium Application**

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-n1-standard-4, 100 GB | $300 |
| **Cloud Spanner** | 3 nodes | $2,190 |
| **Firestore** | 10 GB, 1M reads/day | $10 |
| **Bigtable** | 3 nodes, 1 TB | $1,500 |
| **Memorystore** | 5 GB Redis | $250 |

**Scenario 3: Large Scale Application**

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-n1-highmem-16, 1 TB | $2,000 |
| **Cloud Spanner** | 10 nodes | $7,300 |
| **Bigtable** | 10 nodes, 10 TB | $5,000 |
| **Memorystore** | 100 GB Redis | $5,000 |

### Cost Optimization Strategies

**Cloud SQL:**
- Use appropriate machine type
- Enable automatic storage increase
- Use committed use discounts
- Delete unused instances
- Use read replicas for read-heavy workloads

**Cloud Spanner:**
- Use regional instead of multi-region when possible
- Right-size node count
- Use processing units for fine-grained scaling
- Monitor and optimize queries

**Firestore:**
- Optimize document structure
- Use composite indexes efficiently
- Implement caching
- Batch operations
- Monitor read/write operations

**Bigtable:**
- Right-size cluster nodes
- Use HDD instead of SSD when appropriate
- Implement data lifecycle policies
- Optimize row key design
- Use replication only when needed

**Memorystore:**
- Right-size instance
- Use Basic tier for dev/test
- Use Standard tier for production
- Monitor memory usage
- Implement eviction policies

---

## Quick Reference

### Cloud SQL

```bash
# Create instance
gcloud sql instances create my-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-1 \
  --region=us-central1

# Create database
gcloud sql databases create my-db --instance=my-instance

# Connect
gcloud sql connect my-instance --user=root
```

### Cloud Spanner

```bash
# Create instance
gcloud spanner instances create my-instance \
  --config=regional-us-central1 \
  --nodes=1 \
  --description="My Spanner instance"

# Create database
gcloud spanner databases create my-db \
  --instance=my-instance
```

### Firestore

```bash
# Initialize (via console or Firebase CLI)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### Bigtable

```bash
# Create instance
gcloud bigtable instances create my-instance \
  --cluster=my-cluster \
  --cluster-zone=us-central1-a \
  --cluster-num-nodes=3 \
  --display-name="My Bigtable instance"
```

### Memorystore

```bash
# Create Redis instance
gcloud redis instances create my-redis \
  --size=1 \
  --region=us-central1 \
  --tier=basic
```

---

## Best Practices

### General

✅ Choose the right database for your use case  
✅ Implement proper indexing  
✅ Use connection pooling  
✅ Enable backups  
✅ Monitor performance  
✅ Implement security best practices  
✅ Use IAM for access control  
✅ Enable encryption at rest  
✅ Plan for disaster recovery  
✅ Regular performance testing  

### Performance

✅ Optimize queries  
✅ Use appropriate indexes  
✅ Implement caching  
✅ Use read replicas  
✅ Monitor slow queries  
✅ Optimize data model  
✅ Use connection pooling  
✅ Implement pagination  

### Security

✅ Use private IP when possible  
✅ Enable SSL/TLS  
✅ Use IAM authentication  
✅ Implement least privilege  
✅ Enable audit logging  
✅ Regular security audits  
✅ Use VPC Service Controls  
✅ Encrypt sensitive data  

### Cost Optimization

✅ Right-size instances  
✅ Delete unused resources  
✅ Use committed use discounts  
✅ Monitor usage  
✅ Implement data lifecycle policies  
✅ Use appropriate storage tiers  
✅ Optimize queries  
✅ Regular cost reviews  

---

## Next Steps

1. **[Cloud SQL](1-Cloud-SQL.md)** - Managed relational databases
2. **[Cloud Spanner](2-Cloud-Spanner.md)** - Global relational database
3. **[Firestore](3-Firestore.md)** - Document database
4. **[Bigtable](4-Bigtable.md)** - Wide-column NoSQL database
5. **[Memorystore](5-Memorystore.md)** - In-memory cache
6. **[Database Comparison](6-Database-Comparison.md)** - Detailed comparison
7. **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud Spanner Documentation](https://cloud.google.com/spanner/docs)
- [Firestore Documentation](https://cloud.google.com/firestore/docs)
- [Bigtable Documentation](https://cloud.google.com/bigtable/docs)
- [Memorystore Documentation](https://cloud.google.com/memorystore/docs)
- [Database Pricing](https://cloud.google.com/products/calculator)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
