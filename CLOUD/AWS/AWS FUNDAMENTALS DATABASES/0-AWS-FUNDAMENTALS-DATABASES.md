

| Contents          | page                     |
| ----------------- | ------------------------ |
| AWS RDS           | [1-AWS-RDS](1-AWS-RDS.md)            |
| AWS AURORA        | [2-AWS-AURORA](2-AWS-AURORA.md)         |
| AWS ElastiCache   | [3-AWS-ElastiCache](3-AWS-ElastiCache.md)    |
| AWS DYNAMODB      | [4-AWS-DynamoDB](4-AWS-DynamoDB.md)       |
| AWS S3            | [5-AWS-S3](5-AWS-S3.md)             |
| AWS DOCUMENTDB    | [6-AWS-DOCUMENTDB](6-AWS-DOCUMENTDB.md)     |
| AWS Neptune       | [7-AWS-Neptune](7-AWS-Neptune.md)        |
| Amazon Keyspaces  | [8-Amazon-Keyspaces](8-Amazon-Keyspaces.md)   |
| Amazon QLDB       | [9- Amazon-QLDB](9-%20Amazon-QLDB.md)       |
| Amazon Timestream | [10-Amazon-Timestream](10-Amazon-Timestream.md) |

# 🗂️ **Core Database Types Explained**

---

## 1. 🔢 **RDBMS (Relational Databases)**

**Structure:** Tables (rows & columns)  
**Language:** SQL (Structured Query Language)  
**Strengths:** ACID compliance, strong consistency  
**Use Cases:** OLTP systems, financial apps, CRM, ERP

**Examples:**

- MySQL
    
- PostgreSQL
    
- Oracle
    
- Microsoft SQL Server
    
- Amazon RDS / Aurora
    

---

## 2. 📦 **NoSQL (Non-Relational Databases)**

**Structure:** Key-Value, Document, Column, or Graph  
**Strengths:** Horizontal scalability, flexible schema  
**Use Cases:** Big data, real-time apps, IoT, user profiles

**Types & Examples:**

- **Key-Value:** Redis, DynamoDB
    
- **Document:** MongoDB, CouchDB
    
- **Column:** Cassandra, HBase
    
- **Graph:** Neo4j
    
---

## 3. 🪣 **Object Storage**

**Structure:** Flat namespace with objects (data + metadata)  
**Not a traditional database**, but used for big data and archiving  
**Use Cases:** Backups, data lakes, static files, ML training data

**Examples:**

- Amazon S3
    
- Azure Blob Storage
    
- Google Cloud Storage
    
---

## 4. 🏢 **Data Warehouses**

**Structure:** Optimized for analytics (OLAP)  
**Strengths:** Massive read/query performance, columnar storage  
**Use Cases:** BI, reporting, analytics over huge datasets

**Examples:**

- Amazon Redshift
    
- Snowflake
    
- Google BigQuery
    
- Azure Synapse
    
---

## 5. 🔍 **Search Databases**

**Structure:** Inverted index + JSON document  
**Strengths:** Full-text search, real-time indexing  
**Use Cases:** Log analysis, search engines, observability

**Examples:**

- Elasticsearch
    
- OpenSearch
    
- Solr
    
---

## 6. 🕸️ **Graph Databases**

**Structure:** Nodes + Edges  
**Strengths:** Relationship-first queries, fast joins  
**Use Cases:** Social networks, fraud detection, recommendations

**Examples:**

- Neo4j
    
- Amazon Neptune
    
- ArangoDB
    
---

## 7. 🧾 **Ledger Databases**

**Structure:** Immutable journal with cryptographic integrity  
**Strengths:** Tamper-evidence, transparent audit trails  
**Use Cases:** Financial transactions, compliance, audit logs

**Examples:**

- Amazon QLDB
    
- Hyperledger Fabric (blockchain-like ledger)
    
---

## 8. 📈 **Time-Series Databases**

**Structure:** Time-ordered data points  
**Strengths:** High-write throughput, fast range queries  
**Use Cases:** Monitoring (metrics/logs), IoT, trading systems

**Examples:**

- InfluxDB
    
- Prometheus
    
- Amazon Timestream
    
---
