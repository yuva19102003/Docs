
## 📌 1. **What is DynamoDB?**

**Amazon DynamoDB** is a **fully managed NoSQL database service** that delivers:

- **Single-digit millisecond latency**
    
- **Auto-scaling** read/write throughput
    
- **Built-in replication**, **encryption**, and **backup**
    
- **Serverless**, with no provisioning required
    

---

## 🗃️ 2. **Core Concepts**

|Concept|Description|
|---|---|
|**Table**|Collection of items (like a SQL table)|
|**Item**|A row in the table|
|**Attribute**|A column or field in an item|
|**Primary Key**|Uniquely identifies an item (Partition Key or Partition + Sort Key)|
|**Secondary Index**|Enables querying by non-key attributes|
|**Provisioned / On-Demand**|Controls read/write capacity mode|

---

## 🔑 3. **Primary Key Types**

|Key Type|Description|Example|
|---|---|---|
|Partition Key|Simple key (hashed)|`UserID`|
|Partition + Sort Key|Composite key (hashed + range)|`UserID` + `Date`|

---

## 🔍 4. **Query vs Scan**

|Operation|Description|Performance|
|---|---|---|
|Query|Retrieve items by primary or secondary key|Efficient|
|Scan|Reads every item in the table|Costly|

---

## 🧱 5. **Capacity Modes**

|Mode|Description|Use Case|
|---|---|---|
|Provisioned|Set read/write units manually|Predictable workloads|
|On-Demand|Scales automatically based on traffic|Unpredictable or spiky loads|

---

## 🧠 6. **DynamoDB Read/Write Units**

|Operation|Definition|
|---|---|
|1 RCU (Read)|1 strongly consistent read per second for 4 KB|
|1 WCU (Write)|1 write per second for 1 KB|

---

## 🔄 7. **Global Secondary Index (GSI)**

- Allows queries using **non-key attributes**
    
- Supports different **partition/sort key**
    
- Must be defined when creating the table or later
    

---

## ⏱️ 8. **DynamoDB Streams**

- Captures table change logs (insert/update/delete)
    
- Use with **AWS Lambda** for event-driven architecture
    
- Retention: 24 hours
    

---

## 🔐 9. **DynamoDB Security**

|Feature|Description|
|---|---|
|IAM Policies|Fine-grained access control|
|KMS Encryption|Encryption at rest (AWS-owned or CMK)|
|VPC Endpoints|Secure private access via VPC|

---

## ♻️ 10. **Backup & Restore**

- **On-demand backup** and **point-in-time restore**
    
- Up to **35 days of PITR**
    
- Cross-region backups supported
    

---

## 📈 11. **Monitoring & Metrics**

|Tool|Monitored Metrics|
|---|---|
|CloudWatch|ThrottledRequests, ReadThrottleEvents|
|DynamoDB Console|Capacity usage, Item count, Latency|
|AWS X-Ray|Query tracing and debugging|

---

## 🧪 12. **Use Cases**

✅ Real-time gaming  
✅ E-commerce carts  
✅ Serverless backends  
✅ Leaderboards  
✅ Sensor data collection  
✅ IAM session tokens (like AWS does internally)

---

## ⚙️ 13. **Creating DynamoDB Table (Console)**

1. Go to **DynamoDB Console**
    
2. Click **"Create Table"**
    
3. Enter:
    
    - Table name (e.g., `Users`)
        
    - Primary key: `UserID` (partition) or `UserID + Timestamp` (composite)
        
4. Choose:
    
    - On-demand or provisioned mode
        
    - Encryption (default: AWS-owned KMS)
        
5. Click **Create**
    

---

## 🛠️ 14. **Terraform Example**

```hcl
resource "aws_dynamodb_table" "users" {
  name           = "Users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

---

## 🧠 15. **Best Practices**

✅ Use **partition key with high cardinality**  
✅ Avoid **hot partitions** (don't use timestamps as partition key)  
✅ Prefer **On-Demand mode** for spiky workloads  
✅ Enable **Streams** for change data capture  
✅ Set **TTL** for expiring items automatically  
✅ Use **batch operations** for large data imports  
✅ Limit **Scan** operations — use **Query** where possible  
✅ Enable **auto-scaling** if using provisioned mode

---

## 🚫 16. **Limitations**

|Limitation|Notes|
|---|---|
|No joins|Denormalized structure is ideal|
|Item size limit|Max 400 KB per item|
|Table size|Unlimited, but watch partition limits|
|Query flexibility|Limited compared to RDS|

---

## 🚀 17. **Advanced Features**

|Feature|Description|
|---|---|
|PartiQL|SQL-like query language for DynamoDB|
|DAX (DynamoDB Accelerator)|In-memory caching for 10x performance boost|
|Global Tables|Multi-region replication and low-latency|
|Transaction API|ACID transactions for multiple items|
|Streams + Lambda|Event-driven data processing pipeline|

---

## 🧩 18. **DynamoDB vs RDS vs Aurora**

|Feature|DynamoDB|RDS/Aurora|
|---|---|---|
|Type|NoSQL (Key-Value/Doc)|Relational SQL|
|Schema|Schema-less|Schema-defined|
|Joins|❌ No|✅ Yes|
|Scaling|Auto-scaling|Vertical + Read Replica|
|Latency|< 10ms|Higher|
|Use Case|High-scale, flexible|Structured, relational|

---

## ⚡ What is DAX (DynamoDB Accelerator)?

**Amazon DAX (DynamoDB Accelerator)** is a **fully managed, in-memory cache** for DynamoDB that delivers **microsecond read latency** — ideal for read-heavy workloads.

> ✅ Think of DAX as **Redis for DynamoDB**, but fully managed and deeply integrated.

---

## 🚀 Why Use DAX?

|Benefit|Description|
|---|---|
|⚡ Ultra-low latency|Read latency drops from milliseconds → **microseconds**|
|📈 Offload reads|Reduces read pressure on your DynamoDB table|
|🛠️ Fully managed|No patching, setup, or replication to manage|
|🧠 Write-through cache|Writes go through DAX → DynamoDB automatically|
|☁️ Scalable + HA|Multi-AZ replication with auto-recovery|

---

## 🧠 How DAX Works (Architecture)

1. Your **application connects to the DAX cluster endpoint** instead of DynamoDB directly.
    
2. Reads are served from the **in-memory cache**.
    
3. If data is not present (cache miss), DAX fetches from DynamoDB and caches it.
    
4. **Writes are passed through to DynamoDB**, and DAX updates the cache.
    

📊 **Diagram (Simplified)**:

```
App ↔ DAX Cluster ↔ DynamoDB Table
```

---

## 📘 Use Cases

|Use Case|Why DAX?|
|---|---|
|📲 Mobile or gaming backend|High-volume, low-latency reads|
|📚 Catalog apps|Frequently accessed product/content info|
|🔎 Leaderboards, rankings|Real-time display, fast access|
|📑 Session or user profile|Rapid repeated reads with minimal write|

---

## 🛠️ Terraform Example – DAX Cluster with DynamoDB

```hcl
resource "aws_dynamodb_table" "products" {
  name           = "Products"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }
}

resource "aws_dax_subnet_group" "default" {
  name       = "dax-subnet-group"
  subnet_ids = ["subnet-abc123", "subnet-def456"]
}

resource "aws_dax_cluster" "example" {
  cluster_name           = "dax-products-cluster"
  node_type              = "dax.r5.large"
  replication_factor     = 2
  iam_role_arn           = aws_iam_role.dax.arn
  subnet_group_name      = aws_dax_subnet_group.default.name
  security_group_ids     = ["sg-12345678"]

  tags = {
    Name = "DAXCluster"
  }
}

resource "aws_iam_role" "dax" {
  name = "DAXAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "dax.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dax_policy" {
  role       = aws_iam_role.dax.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
```

> ⚠️ DAX clusters **must be in a VPC**, so your app must also run inside the same VPC (e.g., EC2, ECS, Lambda in VPC).

---

## 🔧 SDK Support (Not via normal DynamoDB SDK)

To use DAX, your app **must use DAX-enabled SDKs**:

|Language|SDK Package|
|---|---|
|Java|`AmazonDaxClient` from AWS SDK for Java|
|Python|`AmazonDAXClient` from `AmazonDAXClient-Python` (boto3 not supported directly)|
|Node.js|No native support — workaround is custom proxy|
|Go|No official DAX SDK|

---

## 📉 Limitations

|Limitation|Value / Notes|
|---|---|
|Writes always go to table|Not cached (write-through only)|
|TTL not supported|TTL expiration happens only on DynamoDB, not DAX|
|Not for multi-tenant apps|No per-tenant isolation|
|SDK required|Requires DAX-specific SDK — not drop-in for all apps|
|No support for transactions or conditional writes|Use DynamoDB directly if needed|

---

## 🧪 Monitoring (via CloudWatch)

|Metric|Meaning|
|---|---|
|`DaxQueryLatency`|Read latency|
|`DaxPutItem`|Number of writes|
|`DaxCacheHitRate`|Ratio of reads served from cache|
|`Evictions`|Number of items removed from cache|

---

## 🛡️ Security

|Feature|Description|
|---|---|
|IAM role for DAX|Needed to access DynamoDB on your behalf|
|VPC + SG|Access control for clients|
|Encryption|At rest (AWS-managed key) and in transit|

---

## 💸 Pricing (as of 2024)

|Resource|Pricing|
|---|---|
|dax.r5.large|~$0.278/hour per node (region-dependent)|
|Data transfer|Based on normal VPC rates|
|No per-request cost|All in-memory reads are "free" once provisioned|

> Cost = nodes * hours * node type — best used for **high-read applications**.

---

## ✅ TL;DR Summary

|Feature|DAX (DynamoDB Accelerator)|
|---|---|
|Type|Fully managed, in-memory cache for DynamoDB|
|Use Case|Microsecond read latency|
|Requires SDK|✅ Yes (DAX-specific SDK only)|
|Caching Strategy|Write-through|
|Write support|✅ Yes (passed to DynamoDB)|
|TTL in cache|❌ No|
|Terraform Support|✅ Yes (`aws_dax_cluster`)|

---
