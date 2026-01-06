
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
