
## 🚀 What is Amazon Keyspaces?

**Amazon Keyspaces** is a **fully managed** service for running **Apache Cassandra** workloads on AWS without needing to manage servers, clusters, or tuning.

It offers:

|Feature|Description|
|---|---|
|**Serverless**|No provisioning, automatic scaling|
|**Cassandra-compatible**|Supports **CQL (Cassandra Query Language)**|
|**Highly available**|Built-in replication across multiple AZs|
|**Secure**|IAM-based auth, encryption at rest/in transit|
|**On-demand pricing**|Pay per request (read/write capacity used)|

---

## 🧾 Use Cases

- Time-series data (IoT, telemetry)
    
- User activity logs and metrics
    
- Catalogs and metadata stores
    
- Large-scale session or state storage
    
- Migrating Cassandra workloads to AWS
    

---

## 🛠️ Key Concepts

|Cassandra Term|Keyspaces Equivalent|
|---|---|
|**Keyspace**|Top-level namespace (like DB)|
|**Table**|Collection of rows and columns|
|**Partition Key**|Determines data distribution|
|**Cluster**|Fully managed by AWS (invisible)|
|**Replication**|Multi-AZ built-in (no config)|

---

## 🏗️ How to Create a Keyspace and Table

### 🔹 Step 1: Create a Keyspace

Using **CQL (Cassandra Query Language)**:

```sql
CREATE KEYSPACE IF NOT EXISTS my_keyspace
WITH replication = {'class': 'SingleRegionStrategy'};
```

> `SingleRegionStrategy` is used in Keyspaces, unlike Cassandra's `SimpleStrategy` or `NetworkTopologyStrategy`.

---

### 🔹 Step 2: Create a Table

```sql
CREATE TABLE IF NOT EXISTS my_keyspace.users (
  user_id UUID,
  name TEXT,
  email TEXT,
  signup_date DATE,
  PRIMARY KEY (user_id)
);
```

---

### 🔹 Step 3: Insert and Query Data

```sql
INSERT INTO my_keyspace.users (user_id, name, email, signup_date)
VALUES (uuid(), 'Alice', 'alice@example.com', '2024-01-01');

SELECT * FROM my_keyspace.users;
```

---

## 🧪 Query Examples

```sql
-- Get user by ID
SELECT * FROM my_keyspace.users WHERE user_id = 1234;

-- Get all users who signed up after a certain date (requires proper primary key design)
```

> Keyspaces is optimized for **known-partition** reads — no full table scans.

---

## 🔐 Security

|Security Feature|Description|
|---|---|
|**IAM Authentication**|Control access via IAM policies|
|**Encryption at Rest**|Uses AWS KMS|
|**Encryption in Transit**|TLS by default|
|**VPC endpoints (PrivateLink)**|Optional for private access|
|**Audit logs**|Enable via CloudTrail + CloudWatch|

---

## 💡 IAM Policy Example

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cassandra:Select",
        "cassandra:Insert",
        "cassandra:Update",
        "cassandra:Delete"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 🧩 Integration with SDKs

Amazon Keyspaces is **compatible with all standard Cassandra drivers**:

|Language|Driver|
|---|---|
|Python|`cassandra-driver`|
|Java|`DataStax Java Driver`|
|Node.js|`cassandra-driver` from DataStax|
|Go|`gocql` with custom TLS config|

> Just update the **service endpoint** and enable **TLS**.

### Example: Python Connection

```python
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider

cloud_config = {
    'secure_connect_bundle': 'path/to/secure-connect.zip'
}

auth_provider = PlainTextAuthProvider('your-aws-access-key', 'your-secret-key')
cluster = Cluster(['cassandra.us-east-1.amazonaws.com'], port=9142, auth_provider=auth_provider, ssl=True)
session = cluster.connect('my_keyspace')
```

---

## 📈 Monitoring & Metrics

|Tool|Metrics|
|---|---|
|**CloudWatch**|Read/write throughput, latency, errors|
|**CloudTrail**|Logs API calls (auth, table creation)|
|**Amazon EventBridge**|Monitor key events|

---

## 💲 Pricing

Amazon Keyspaces offers **on-demand pricing**:

|Operation|Price (approx)*|
|---|---|
|**Write**|$1.45 per million writes|
|**Read**|$0.28 per million reads|
|**Storage**|$0.25 per GB-month|
|**Snapshots**|Free (stored in S3)|

> Use **provisioned capacity mode** for consistent workloads

---

## ⚙️ Terraform Example

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_keyspaces_keyspace" "my_keyspace" {
  name = "my_keyspace"
}

resource "aws_keyspaces_table" "users" {
  keyspace_name = aws_keyspaces_keyspace.my_keyspace.name
  table_name    = "users"

  schema_definition {
    all_columns {
      name = "user_id"
      type = "uuid"
    }
    all_columns {
      name = "name"
      type = "text"
    }
    all_columns {
      name = "email"
      type = "text"
    }

    partition_keys {
      name = "user_id"
    }
  }

  capacity_specification {
    throughput_mode = "PAY_PER_REQUEST"
  }
}
```

---

## 🧠 Key Design Tips

- Design tables **around your access pattern**
    
- Denormalization is okay — joins are not supported
    
- Avoid unbounded partitions
    
- Use UUIDs for uniqueness
    
- Plan primary key carefully for efficient reads
    

---

## ❗ Limitations

|Limitation|Details|
|---|---|
|No secondary indexes|Must query via primary/partition key|
|No batch writes|No Cassandra-style `BATCH` support|
|No full table scans|Scan operations not supported|
|No materialized views|Not available in Keyspaces|
|Max row size|1 MB|
|Max TTL|2 years|

---

## ✅ Summary

|Feature|Description|
|---|---|
|Service Type|Fully managed Cassandra (NoSQL)|
|Query Language|CQL (Cassandra Query Language)|
|Scaling|Serverless + on-demand or provisioned capacity|
|Security|IAM, TLS, VPC, KMS encryption|
|Monitoring|CloudWatch, CloudTrail|
|Integrations|Lambda, SDKs, Analytics pipelines|
|Pricing|Pay-per-request + storage|

---
