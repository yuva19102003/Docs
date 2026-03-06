# Database Comparison - Detailed Analysis

Comprehensive comparison of GCP database services to help you choose the right solution.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Feature Comparison](#feature-comparison)
3. [Performance Comparison](#performance-comparison)
4. [Cost Comparison](#cost-comparison)
5. [Use Case Matrix](#use-case-matrix)
6. [Migration Paths](#migration-paths)
7. [Decision Framework](#decision-framework)

---

## Overview

### Database Services Summary

| Service | Type | Best For | Starting Price |
|---------|------|----------|----------------|
| **Cloud SQL** | Relational | Traditional apps | $15/month |
| **Cloud Spanner** | Relational | Global apps | $657/month |
| **Firestore** | Document | Mobile/web apps | $1/month |
| **Bigtable** | Wide-column | Analytics, IoT | $474/month |
| **Memorystore** | Key-value | Caching | $35/month |

---

## Feature Comparison

### Data Model

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **Data Model** | Tables/Rows | Tables/Rows | Collections/Docs | Row/Column | Key-Value |
| **Schema** | Fixed | Fixed | Flexible | Flexible | None |
| **Query Language** | SQL | SQL | NoSQL | NoSQL | Commands |
| **Joins** | Yes | Yes | No | No | No |
| **Transactions** | ACID | ACID | ACID | Single-row | No |
| **Indexes** | Yes | Yes | Yes | No | No |

### Scalability

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **Scaling Type** | Vertical | Horizontal | Automatic | Horizontal | Vertical |
| **Max Size** | 64 TB | Unlimited | Unlimited | Petabytes | 300 GB |
| **Max QPS** | 10K | 100K+ | 10K | 1M+ | 1M+ |
| **Auto-scaling** | Storage only | Yes | Yes | Yes | No |
| **Read Replicas** | Yes | Yes | No | Yes | Yes (Standard) |

### Availability

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **SLA** | 99.95% | 99.999% | 99.99% | 99.9% | 99.9% |
| **Multi-region** | No | Yes | Yes | No | No |
| **Automatic Failover** | Yes | Yes | N/A | Yes | Yes (Standard) |
| **Backup** | Yes | Yes | No | Yes | No |
| **Point-in-time Recovery** | Yes | Yes | No | No | No |

### Performance

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **Read Latency** | 5-10ms | 5-10ms | 10-20ms | <10ms | <1ms |
| **Write Latency** | 5-10ms | 5-10ms | 10-20ms | <10ms | <1ms |
| **Consistency** | Strong | Strong | Strong | Eventual | Strong |
| **Throughput/Node** | 10K QPS | 10K QPS | N/A | 10K QPS | 100K+ QPS |

### Integration

| Feature | Cloud SQL | Cloud Spanner | Firestore | Bigtable | Memorystore |
|---------|-----------|---------------|-----------|----------|-------------|
| **BigQuery** | Yes | Yes | Yes | Yes | No |
| **Dataflow** | Yes | Yes | Yes | Yes | No |
| **Cloud Functions** | Yes | Yes | Yes | Yes | Yes |
| **App Engine** | Yes | Yes | Yes | Yes | Yes |
| **GKE** | Yes | Yes | Yes | Yes | Yes |
| **Mobile SDKs** | No | No | Yes | No | No |

---

## Performance Comparison

### Latency Benchmarks

```
Read Latency (p50):
Memorystore: ▓ 0.5ms
Bigtable:    ▓▓▓▓▓ 5ms
Cloud SQL:   ▓▓▓▓▓▓ 6ms
Spanner:     ▓▓▓▓▓▓▓ 7ms
Firestore:   ▓▓▓▓▓▓▓▓▓▓ 10ms

Write Latency (p50):
Memorystore: ▓ 0.5ms
Bigtable:    ▓▓▓▓▓ 5ms
Cloud SQL:   ▓▓▓▓▓▓▓ 7ms
Spanner:     ▓▓▓▓▓▓▓▓ 8ms
Firestore:   ▓▓▓▓▓▓▓▓▓▓▓▓ 12ms
```

### Throughput Comparison

| Database | Single Node QPS | 10 Nodes QPS | Scaling |
|----------|----------------|--------------|---------|
| **Memorystore** | 1M+ | N/A | Vertical |
| **Bigtable** | 10K | 100K | Linear |
| **Cloud Spanner** | 10K | 100K | Linear |
| **Cloud SQL** | 10K | 100K (replicas) | Vertical + Replicas |
| **Firestore** | 10K | N/A | Automatic |

### Storage Performance

| Database | IOPS/GB | Throughput | Storage Type |
|----------|---------|------------|--------------|
| **Cloud SQL (SSD)** | 30 | 480 MB/s | Block |
| **Cloud SQL (HDD)** | 1.5 | 120 MB/s | Block |
| **Cloud Spanner** | High | High | Distributed |
| **Firestore** | N/A | N/A | Document |
| **Bigtable (SSD)** | Very High | Very High | Columnar |
| **Bigtable (HDD)** | Medium | Medium | Columnar |
| **Memorystore** | Extreme | Extreme | Memory |

---

## Cost Comparison

### Small Application (Development)

**Requirements:**
- 10 GB storage
- 1,000 QPS
- Single region
- Development workload

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-f1-micro, 10 GB | $15 |
| **Firestore** | 1 GB, 100K reads/day | $1 |
| **Memorystore** | 1 GB Redis Basic | $35 |
| **Bigtable** | 1 node (dev) | $47 (HDD) |
| **Cloud Spanner** | 100 PUs | $66 |

**Winner:** Firestore ($1/month)

### Medium Application (Production)

**Requirements:**
- 100 GB storage
- 10,000 QPS
- High availability
- Production workload

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-n1-standard-4, 100 GB, HA | $500 |
| **Firestore** | 10 GB, 1M reads/day | $10 |
| **Memorystore** | 5 GB Redis Standard | $281 |
| **Bigtable** | 3 nodes SSD | $1,422 |
| **Cloud Spanner** | 3 nodes | $1,971 |

**Winner:** Firestore ($10/month) for document data, Cloud SQL ($500/month) for relational

### Large Application (Enterprise)

**Requirements:**
- 1 TB storage
- 100,000 QPS
- Multi-region
- Enterprise workload

| Database | Configuration | Monthly Cost |
|----------|--------------|--------------|
| **Cloud SQL** | db-n1-highmem-16, 1 TB, replicas | $3,000+ |
| **Firestore** | 100 GB, 10M reads/day | $100 |
| **Memorystore** | 100 GB Redis Standard | $5,616 |
| **Bigtable** | 10 nodes SSD | $4,740 |
| **Cloud Spanner** | 10 nodes multi-region | $7,300 |

**Winner:** Depends on requirements (Firestore for document, Bigtable for analytics)

### Cost Per Operation

| Database | Read Cost | Write Cost | Storage Cost |
|----------|-----------|------------|--------------|
| **Cloud SQL** | Included | Included | $0.17/GB (SSD) |
| **Cloud Spanner** | Included | Included | $0.30/GB |
| **Firestore** | $0.06/100K | $0.18/100K | $0.18/GB |
| **Bigtable** | Included | Included | $0.17/GB (SSD) |
| **Memorystore** | Included | Included | $35-56/GB |

---

## Use Case Matrix

### Web Applications

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **Traditional CRUD** | Cloud SQL | Cloud Spanner | SQL support, ACID |
| **Global users** | Cloud Spanner | Firestore | Multi-region, consistency |
| **Session storage** | Memorystore | Firestore | Low latency |
| **User profiles** | Firestore | Cloud SQL | Flexible schema |
| **Shopping cart** | Memorystore | Firestore | Fast access |

### Mobile Applications

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **User data** | Firestore | Cloud SQL | Offline support, SDKs |
| **Real-time chat** | Firestore | Bigtable | Real-time sync |
| **Analytics** | Bigtable | BigQuery | High throughput |
| **Leaderboards** | Memorystore | Cloud Spanner | Low latency |
| **Content** | Firestore | Cloud SQL | Flexible schema |

### Analytics & IoT

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **Time-series data** | Bigtable | Cloud SQL | Scale, performance |
| **IoT telemetry** | Bigtable | Firestore | High throughput |
| **Clickstream** | Bigtable | BigQuery | Real-time ingestion |
| **Logs** | Bigtable | BigQuery | High volume |
| **Metrics** | Bigtable | Cloud SQL | Fast writes |

### Financial Services

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **Transactions** | Cloud Spanner | Cloud SQL | Global ACID |
| **Trading data** | Bigtable | Cloud Spanner | Low latency |
| **User accounts** | Cloud SQL | Cloud Spanner | ACID, SQL |
| **Audit logs** | Bigtable | Cloud SQL | Immutable |
| **Real-time pricing** | Memorystore | Bigtable | Sub-ms latency |

### Gaming

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **Player profiles** | Firestore | Cloud SQL | Flexible schema |
| **Leaderboards** | Memorystore | Cloud Spanner | Low latency |
| **Game state** | Firestore | Memorystore | Real-time sync |
| **Analytics** | Bigtable | BigQuery | High volume |
| **Matchmaking** | Memorystore | Cloud Spanner | Fast access |

---

## Migration Paths

### From MySQL/PostgreSQL

```
Current: MySQL/PostgreSQL
    |
    ├─> Cloud SQL (Lift & Shift)
    │   - Minimal changes
    │   - Quick migration
    │   - Same features
    │
    ├─> Cloud Spanner (Modernize)
    │   - Schema changes required
    │   - Global scale
    │   - Higher cost
    │
    └─> Firestore (Replatform)
        - Application rewrite
        - NoSQL model
        - Lower cost
```

### From MongoDB

```
Current: MongoDB
    |
    ├─> Firestore (Similar model)
    │   - Document database
    │   - Managed service
    │   - Real-time features
    │
    ├─> Bigtable (Scale)
    │   - Higher throughput
    │   - Different model
    │   - Analytics workloads
    │
    └─> Cloud SQL (Relational)
        - Schema required
        - SQL queries
        - ACID transactions
```

### From Cassandra/HBase

```
Current: Cassandra/HBase
    |
    ├─> Bigtable (Direct migration)
    │   - HBase API compatible
    │   - Similar model
    │   - Managed service
    │
    ├─> Cloud Spanner (Relational)
    │   - SQL support
    │   - ACID transactions
    │   - Schema required
    │
    └─> Firestore (Document)
        - Flexible schema
        - Real-time features
        - Lower throughput
```

### From Redis/Memcached

```
Current: Redis/Memcached
    |
    ├─> Memorystore (Lift & Shift)
    │   - Same API
    │   - Managed service
    │   - No changes
    │
    ├─> Firestore (Persistent)
    │   - Durable storage
    │   - Flexible schema
    │   - Higher latency
    │
    └─> Bigtable (Scale)
        - Higher throughput
        - Persistent storage
        - Different API
```

---

## Decision Framework

### Step 1: Data Model

```
What type of data?
    |
    ├─> Structured + SQL → Cloud SQL or Cloud Spanner
    ├─> Document/JSON → Firestore
    ├─> Time-series → Bigtable
    └─> Key-value → Memorystore
```

### Step 2: Scale Requirements

```
Expected scale?
    |
    ├─> < 1 TB, < 10K QPS → Cloud SQL
    ├─> < 10 TB, < 100K QPS → Cloud Spanner or Bigtable
    ├─> > 10 TB, > 100K QPS → Bigtable
    └─> Caching → Memorystore
```

### Step 3: Geographic Distribution

```
Geographic requirements?
    |
    ├─> Single region → Cloud SQL, Bigtable, Memorystore
    ├─> Multi-region → Cloud Spanner, Firestore
    └─> Global → Cloud Spanner
```

### Step 4: Consistency Requirements

```
Consistency needs?
    |
    ├─> Strong consistency + SQL → Cloud SQL or Cloud Spanner
    ├─> Strong consistency + NoSQL → Firestore
    ├─> Eventual consistency → Bigtable
    └─> No persistence → Memorystore
```

### Step 5: Budget

```
Budget constraints?
    |
    ├─> < $100/month → Firestore or Cloud SQL (small)
    ├─> < $1,000/month → Cloud SQL or Firestore
    ├─> < $5,000/month → Bigtable or Cloud Spanner
    └─> > $5,000/month → Any service
```

### Decision Matrix

| If you need... | Choose... | Because... |
|----------------|-----------|------------|
| SQL + Regional | Cloud SQL | Cost-effective, familiar |
| SQL + Global | Cloud Spanner | Multi-region, consistency |
| Document + Mobile | Firestore | SDKs, offline support |
| Time-series + Scale | Bigtable | Throughput, latency |
| Caching | Memorystore | Sub-ms latency |
| Flexible + Cheap | Firestore | Pay per operation |
| ACID + Scale | Cloud Spanner | Horizontal scaling |
| Analytics | Bigtable | High throughput |

---

## Hybrid Architectures

### Pattern 1: SQL + Cache

```
Application
    |
    v
┌─────────────────┐
│  Memorystore    │ ← Cache layer
│  (Redis)        │
└────────┬────────┘
         │ Cache miss
         v
┌─────────────────┐
│  Cloud SQL      │ ← Primary database
│  (PostgreSQL)   │
└─────────────────┘
```

**Use Case:** Web application with frequent reads

### Pattern 2: Relational + Document

```
Application
    |
    ├─> Cloud SQL (Transactions)
    │   - Orders
    │   - Payments
    │   - Inventory
    │
    └─> Firestore (User data)
        - Profiles
        - Preferences
        - Activity
```

**Use Case:** E-commerce with user profiles

### Pattern 3: Operational + Analytics

```
Application
    |
    v
┌─────────────────┐
│  Cloud SQL      │ ← Operational
│  (OLTP)         │
└────────┬────────┘
         │ ETL
         v
┌─────────────────┐
│  Bigtable       │ ← Analytics
│  (OLAP)         │
└─────────────────┘
```

**Use Case:** Real-time analytics on operational data

### Pattern 4: Multi-Database

```
Application
    |
    ├─> Cloud SQL (Core data)
    ├─> Firestore (User profiles)
    ├─> Bigtable (Analytics)
    └─> Memorystore (Cache)
```

**Use Case:** Large-scale application with diverse requirements

---

## Summary

### Quick Reference

**Choose Cloud SQL when:**
- You need SQL
- Regional deployment
- Traditional application
- Budget < $1,000/month

**Choose Cloud Spanner when:**
- You need SQL + global scale
- Strong consistency required
- Multi-region deployment
- Budget > $2,000/month

**Choose Firestore when:**
- Document data model
- Mobile/web application
- Real-time features needed
- Budget < $100/month

**Choose Bigtable when:**
- Time-series data
- High throughput required
- Analytics workload
- Budget > $1,000/month

**Choose Memorystore when:**
- Caching layer
- Sub-ms latency required
- Session storage
- Budget > $50/month

---

## Next Steps

- **[Best Practices](7-Best-Practices.md)** - Production guidelines
- **[Cloud SQL](1-Cloud-SQL.md)** - Relational database details
- **[Cloud Spanner](2-Cloud-Spanner.md)** - Global database details

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
