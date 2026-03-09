# 1️⃣4️⃣ Data Analytics - Overview

Learn big data and analytics on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Analytics Services](#analytics-services)
3. [Services Comparison](#services-comparison)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Considerations](#cost-considerations)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP provides a comprehensive suite of services for data analytics, from data warehousing to real-time stream processing.

### Analytics Stack

```
┌─────────────────────────────────────────────────────┐
│           Data Analytics Services                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ BigQuery │  │ Dataflow │  │ Dataproc │        │
│  │(Warehouse│  │(Streaming│  │ (Hadoop/ │        │
│  │    )     │  │   ETL)   │  │  Spark)  │        │
│  └──────────┘  └──────────┘  └──────────┘        │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Pub/Sub  │  │ Dataprep │  │  Data    │        │
│  │(Ingest)  │  │(Prep)    │  │ Fusion   │        │
│  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────┘
```

---

## Analytics Services

### 1. BigQuery

**Serverless data warehouse**

```
┌─────────────────────────────────────┐
│          BigQuery                   │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Petabyte-scale analytics         │
│  • SQL queries                      │
│  • Real-time analytics              │
│  • Machine learning (BQML)          │
│  • Geospatial analysis              │
│  • BI Engine (in-memory)            │
├─────────────────────────────────────┤
│  Features:                          │
│  • Serverless                       │
│  • Auto-scaling                     │
│  • Columnar storage                 │
│  • Partitioning & clustering        │
│  • Streaming inserts                │
│  • Federated queries                │
└─────────────────────────────────────┘
```

**Characteristics:**
- Serverless data warehouse
- SQL-based analytics
- Petabyte scale
- Sub-second queries
- Pay-per-query or flat-rate

**Use Cases:**
- Data warehousing
- Business intelligence
- Log analytics
- Real-time dashboards
- Machine learning

### 2. Dataflow

**Stream and batch data processing**

```
┌─────────────────────────────────────┐
│          Dataflow                   │
├─────────────────────────────────────┤
│  Apache Beam Pipelines:             │
│  ┌─────────────────────────────┐   │
│  │ Read → Transform → Write    │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Processing Modes:                  │
│  • Batch processing                 │
│  • Stream processing                │
│  • Unified (batch + stream)         │
├─────────────────────────────────────┤
│  Features:                          │
│  • Auto-scaling                     │
│  • Exactly-once processing          │
│  • Windowing                        │
│  • State management                 │
│  • Flexible scheduling              │
└─────────────────────────────────────┘
```

**Characteristics:**
- Unified batch and stream
- Apache Beam SDK
- Auto-scaling
- Serverless
- Exactly-once semantics

**Use Cases:**
- ETL pipelines
- Real-time analytics
- Data transformation
- Stream processing
- Event processing

### 3. Dataproc

**Managed Hadoop and Spark**

```
┌─────────────────────────────────────┐
│          Dataproc                   │
├─────────────────────────────────────┤
│  Cluster Components:                │
│  • Apache Hadoop                    │
│  • Apache Spark                     │
│  • Apache Hive                      │
│  • Apache Pig                       │
│  • Presto                           │
├─────────────────────────────────────┤
│  Features:                          │
│  • Fast cluster creation (90s)      │
│  • Auto-scaling                     │
│  • Preemptible workers              │
│  • Integration with GCS             │
│  • Workflow templates               │
│  • Component gateway                │
└─────────────────────────────────────┘
```

**Characteristics:**
- Managed Hadoop/Spark
- Fast provisioning
- Cost-effective
- Open-source ecosystem
- Lift-and-shift friendly

**Use Cases:**
- Hadoop/Spark migrations
- Batch processing
- Machine learning
- Data science
- Legacy workloads

### 4. Pub/Sub

**Real-time messaging for analytics**

```
┌─────────────────────────────────────┐
│          Pub/Sub                    │
├─────────────────────────────────────┤
│  Data Ingestion:                    │
│  IoT Devices → Pub/Sub              │
│  Applications → Pub/Sub             │
│  Logs → Pub/Sub                     │
├─────────────────────────────────────┤
│  Targets:                           │
│  • Dataflow (processing)            │
│  • BigQuery (direct)                │
│  • Cloud Storage (archival)         │
│  • Cloud Functions (triggers)       │
├─────────────────────────────────────┤
│  Features:                          │
│  • At-least-once delivery           │
│  • Global availability              │
│  • Message ordering                 │
│  • Dead letter topics               │
└─────────────────────────────────────┘
```

**Characteristics:**
- Real-time ingestion
- Scalable messaging
- Global availability
- Multiple targets
- Reliable delivery

**Use Cases:**
- Data ingestion
- Event streaming
- IoT data collection
- Log aggregation
- Real-time pipelines

### 5. Dataprep

**Visual data preparation**

```
┌─────────────────────────────────────┐
│          Dataprep                   │
│        (by Trifacta)                │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Visual data exploration          │
│  • Data cleaning                    │
│  • Data transformation              │
│  • Recipe-based workflows           │
│  • Automatic schema detection       │
├─────────────────────────────────────┤
│  Features:                          │
│  • No-code interface                │
│  • Intelligent suggestions          │
│  • Data profiling                   │
│  • Collaboration                    │
│  • Integration with Dataflow        │
└─────────────────────────────────────┘
```

**Characteristics:**
- Visual interface
- No-code data prep
- Intelligent suggestions
- Powered by Dataflow
- Collaborative

**Use Cases:**
- Data cleaning
- Data exploration
- ETL preparation
- Business users
- Data quality

### 6. Data Fusion

**Code-free data integration**

```
┌─────────────────────────────────────┐
│         Data Fusion                 │
│         (by CDAP)                   │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Visual pipeline builder          │
│  • 150+ connectors                  │
│  • Data lineage                     │
│  • Metadata management              │
│  • Reusable pipelines               │
├─────────────────────────────────────┤
│  Features:                          │
│  • Drag-and-drop interface          │
│  • Pre-built transformations        │
│  • Powered by Dataproc              │
│  • Enterprise edition               │
│  • Wrangler for data prep           │
└─────────────────────────────────────┘
```

**Characteristics:**
- Code-free ETL
- Visual pipelines
- Many connectors
- Enterprise features
- Powered by Dataproc

**Use Cases:**
- Data integration
- ETL pipelines
- Data migration
- Enterprise data management
- Multi-source integration

---

## Services Comparison

### Feature Matrix

| Feature | BigQuery | Dataflow | Dataproc | Pub/Sub | Dataprep | Data Fusion |
|---------|----------|----------|----------|---------|----------|-------------|
| **Type** | Warehouse | Processing | Processing | Ingestion | Prep | Integration |
| **Interface** | SQL | Code | Code/UI | API | Visual | Visual |
| **Serverless** | Yes | Yes | No | Yes | Yes | No |
| **Real-time** | Yes | Yes | Yes | Yes | No | No |
| **Scale** | Petabytes | Unlimited | Cluster-based | Unlimited | GB-TB | TB-PB |
| **Pricing** | Query/Storage | Per hour | Per hour | Per GB | Per hour | Per hour |
| **Learning Curve** | Low | Medium | High | Low | Low | Low |

### Performance Comparison

| Service | Latency | Throughput | Best For |
|---------|---------|------------|----------|
| **BigQuery** | Seconds | TB/sec | Ad-hoc queries |
| **Dataflow** | Sub-second | GB/sec | Stream processing |
| **Dataproc** | Minutes | TB/hour | Batch processing |
| **Pub/Sub** | Milliseconds | GB/sec | Data ingestion |
| **Dataprep** | Minutes | GB/hour | Data preparation |
| **Data Fusion** | Minutes | GB/hour | ETL pipelines |

---

## Decision Framework

### Service Selection

```
What do you need?
    |
    ├─> Query large datasets?
    |   └─> BigQuery
    |
    ├─> Real-time stream processing?
    |   └─> Dataflow
    |
    ├─> Hadoop/Spark workloads?
    |   └─> Dataproc
    |
    ├─> Data ingestion?
    |   └─> Pub/Sub
    |
    ├─> Visual data preparation?
    |   └─> Dataprep
    |
    └─> Enterprise ETL?
        └─> Data Fusion
```

### Use Case Matrix

| Requirement | Recommended | Alternative |
|-------------|-------------|-------------|
| **Data warehouse** | BigQuery | Dataproc + Hive |
| **Real-time analytics** | BigQuery + Dataflow | Dataproc Streaming |
| **Batch ETL** | Dataflow | Dataproc |
| **Stream processing** | Dataflow | Dataproc Streaming |
| **Hadoop migration** | Dataproc | Dataflow |
| **Data ingestion** | Pub/Sub | Cloud Storage |
| **Data preparation** | Dataprep | Dataflow |
| **Visual ETL** | Data Fusion | Dataprep |

---

## Architecture Patterns

### Pattern 1: Real-Time Analytics

```
IoT Devices / Apps
    |
    v
┌─────────────────────┐
│     Pub/Sub         │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌──────────┐  ┌──────────┐
│ Dataflow │  │BigQuery  │
│(Process) │  │(Direct)  │
└────┬─────┘  └────┬─────┘
     |             |
     └──────┬──────┘
            v
     ┌──────────────┐
     │  BigQuery    │
     │ (Analytics)  │
     └──────────────┘
```

### Pattern 2: Batch Data Warehouse

```
Data Sources
    |
    v
┌─────────────────────┐
│  Cloud Storage      │
│  (Data Lake)        │
└──────────┬──────────┘
           v
┌─────────────────────┐
│    Dataflow         │
│  (ETL Pipeline)     │
└──────────┬──────────┘
           v
┌─────────────────────┐
│    BigQuery         │
│  (Data Warehouse)   │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Looker / Data      │
│  Studio (BI)        │
└─────────────────────┘
```

### Pattern 3: Lambda Architecture

```
Data Sources
    |
    ├─────────────────┐
    v                 v
┌──────────┐    ┌──────────┐
│  Batch   │    │ Stream   │
│  Layer   │    │  Layer   │
│          │    │          │
│Dataproc  │    │Dataflow  │
└────┬─────┘    └────┬─────┘
     |               |
     └───────┬───────┘
             v
      ┌──────────────┐
      │  BigQuery    │
      │ (Serving)    │
      └──────────────┘
```

### Pattern 4: Data Lake to Warehouse

```
┌─────────────────────┐
│  Cloud Storage      │
│  (Raw Data Lake)    │
└──────────┬──────────┘
           v
┌─────────────────────┐
│   Dataprep          │
│  (Data Cleaning)    │
└──────────┬──────────┘
           v
┌─────────────────────┐
│   Dataflow          │
│  (Transformation)   │
└──────────┬──────────┘
           v
┌─────────────────────┐
│   BigQuery          │
│  (Curated Data)     │
└─────────────────────┘
```

### Pattern 5: Multi-Source Integration

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│Database  │  │  APIs    │  │  Files   │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     |             |             |
     └─────────────┼─────────────┘
                   v
          ┌─────────────────┐
          │  Data Fusion    │
          │  (Integration)  │
          └────────┬────────┘
                   v
          ┌─────────────────┐
          │   BigQuery      │
          └─────────────────┘
```

---

## Cost Considerations

### Pricing Overview

**BigQuery:**
- Storage: $0.02 per GB/month (active), $0.01 (long-term)
- Queries: $5 per TB processed (on-demand)
- Flat-rate: Starting at $2,000/month (100 slots)
- Streaming: $0.01 per 200 MB

**Dataflow:**
- Compute: Based on vCPU and memory hours
- Typical: $0.056 per vCPU-hour
- Streaming: 5% premium
- Shuffle: Additional cost for large shuffles

**Dataproc:**
- Compute: VM pricing + 1% Dataproc fee
- Preemptible workers: Up to 80% savings
- Typical: $0.01 per vCPU-hour (Dataproc fee)

**Pub/Sub:**
- First 10 GB/month: Free
- Additional: $0.04 per GB

### Cost Optimization

```sql
-- BigQuery: Use partitioning
CREATE TABLE dataset.table
PARTITION BY DATE(timestamp)
CLUSTER BY user_id
AS SELECT * FROM source_table;

-- BigQuery: Use clustering
CREATE TABLE dataset.table
CLUSTER BY country, city
AS SELECT * FROM source_table;

-- BigQuery: Limit query data
SELECT *
FROM `project.dataset.table`
WHERE _PARTITIONDATE = '2026-03-09'
LIMIT 1000;
```

```bash
# Dataproc: Use preemptible workers
gcloud dataproc clusters create my-cluster \
  --num-workers=2 \
  --num-preemptible-workers=10 \
  --preemptible-worker-boot-disk-size=50GB

# Dataflow: Use appropriate machine types
gcloud dataflow jobs run my-job \
  --gcs-location=gs://dataflow-templates/latest/Word_Count \
  --worker-machine-type=n1-standard-2 \
  --max-workers=10
```

---

## Quick Reference

### BigQuery

```sql
-- Create dataset
CREATE SCHEMA my_dataset;

-- Create table
CREATE TABLE my_dataset.my_table (
  id INT64,
  name STRING,
  created_at TIMESTAMP
)
PARTITION BY DATE(created_at);

-- Query data
SELECT 
  DATE(created_at) as date,
  COUNT(*) as count
FROM my_dataset.my_table
WHERE DATE(created_at) >= '2026-01-01'
GROUP BY date
ORDER BY date DESC;

-- Streaming insert
INSERT INTO my_dataset.my_table (id, name, created_at)
VALUES (1, 'John', CURRENT_TIMESTAMP());
```

### Dataflow

```bash
# Run template
gcloud dataflow jobs run my-job \
  --gcs-location=gs://dataflow-templates/latest/PubSub_to_BigQuery \
  --region=us-central1 \
  --parameters inputTopic=projects/PROJECT/topics/TOPIC,outputTableSpec=PROJECT:DATASET.TABLE

# List jobs
gcloud dataflow jobs list --region=us-central1

# Cancel job
gcloud dataflow jobs cancel JOB_ID --region=us-central1
```

### Dataproc

```bash
# Create cluster
gcloud dataproc clusters create my-cluster \
  --region=us-central1 \
  --num-workers=2

# Submit Spark job
gcloud dataproc jobs submit spark \
  --cluster=my-cluster \
  --region=us-central1 \
  --jar=gs://my-bucket/my-job.jar

# Delete cluster
gcloud dataproc clusters delete my-cluster --region=us-central1
```

---

## Best Practices

### BigQuery

✅ Use partitioning and clustering  
✅ Avoid SELECT *  
✅ Use appropriate data types  
✅ Implement incremental loads  
✅ Use materialized views  
✅ Monitor query costs  
✅ Use BI Engine for dashboards  
✅ Implement data lifecycle policies  

### Dataflow

✅ Use windowing appropriately  
✅ Implement idempotent transforms  
✅ Monitor pipeline metrics  
✅ Use side inputs efficiently  
✅ Implement error handling  
✅ Use appropriate machine types  
✅ Enable autoscaling  
✅ Test with sample data  

### Dataproc

✅ Use preemptible workers  
✅ Right-size clusters  
✅ Use ephemeral clusters  
✅ Store data in GCS  
✅ Enable autoscaling  
✅ Use workflow templates  
✅ Monitor cluster utilization  
✅ Implement graceful decommissioning  

### General

✅ Implement data quality checks  
✅ Use appropriate storage tiers  
✅ Monitor costs regularly  
✅ Implement data governance  
✅ Use IAM for access control  
✅ Enable audit logging  
✅ Document data pipelines  
✅ Implement disaster recovery  

---

## Next Steps

1. **[BigQuery](1-BigQuery.md)** - Data warehouse
2. **[Dataflow](2-Dataflow.md)** - Stream and batch processing
3. **[Dataproc](3-Dataproc.md)** - Hadoop and Spark
4. **[Pub/Sub](4-Pub-Sub.md)** - Data ingestion
5. **[Data Preparation](5-Data-Preparation.md)** - Dataprep and Data Fusion
6. **[Best Practices](6-Best-Practices.md)** - Analytics guidelines

---

## Additional Resources

- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Dataflow Documentation](https://cloud.google.com/dataflow/docs)
- [Dataproc Documentation](https://cloud.google.com/dataproc/docs)
- [Analytics Hub](https://cloud.google.com/analytics-hub)
- [Data Analytics Solutions](https://cloud.google.com/solutions/data-analytics)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
