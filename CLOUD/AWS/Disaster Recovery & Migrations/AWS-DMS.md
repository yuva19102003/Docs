
## 🧠 What is AWS DMS?

**AWS Database Migration Service (DMS)** helps you **migrate databases** from on-premises, cloud, or hybrid environments **to AWS**, **between AWS services**, or even **from AWS to other clouds**.

> ✅ It supports both **homogeneous** (e.g., MySQL to MySQL) and **heterogeneous** (e.g., Oracle to Aurora) migrations with near-zero downtime.

---

## 🚀 Common Use Cases

|Use Case|Example|
|---|---|
|Cloud adoption|Migrate Oracle from on-prem to Amazon RDS|
|Cross-engine migration|Migrate SQL Server to Aurora PostgreSQL|
|Continuous replication|Sync data from on-prem to AWS in real-time|
|Analytics|Migrate transactional DB to Amazon Redshift|
|Disaster recovery|Maintain DR copy in another region|

---

## 🔁 DMS Supports

|Source DBs|Target DBs|
|---|---|
|MySQL, PostgreSQL|RDS (Aurora, MySQL, PostgreSQL, etc.)|
|Oracle, SQL Server|Amazon S3, Redshift, DynamoDB|
|MariaDB, MongoDB|Kinesis, OpenSearch, DocumentDB|
|SAP ASE, IBM DB2, etc.|Snowflake (via Kinesis or S3)|

---

## ⚙️ How DMS Works

### Basic Components:

1. **Replication Instance**  
    → EC2-based instance that runs the migration
    
2. **Source Endpoint**  
    → Connection configuration to your source database
    
3. **Target Endpoint**  
    → Connection configuration to your target database
    
4. **Migration Task**  
    → Defines what to move, how, and with what rules
    

---

## 🔄 Migration Modes

|Mode|Description|
|---|---|
|**Full Load**|One-time copy of existing data|
|**CDC (Change Data Capture)**|Replicate ongoing changes|
|**Full Load + CDC**|Initial data load + continuous sync|

> 🔄 **CDC** uses the source DB's **transaction logs** to replicate changes.

---

## 📋 DMS Migration Flow

```text
Source DB → DMS Replication Instance → Target DB
                  |
       (via VPC, IAM, Endpoints, KMS)
```

---

## 🧪 Example Terraform Snippet for DMS

```hcl
resource "aws_dms_replication_instance" "example" {
  replication_instance_id = "example-dms-instance"
  replication_instance_class = "dms.t3.micro"
  allocated_storage = 50
}

resource "aws_dms_endpoint" "source" {
  endpoint_id = "source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = "admin"
  password      = "password"
  server_name   = "source-db.mycompany.com"
  port          = 3306
}

resource "aws_dms_endpoint" "target" {
  endpoint_id = "target-endpoint"
  endpoint_type = "target"
  engine_name   = "aurora"
  username      = "admin"
  password      = "password"
  server_name   = "aurora-cluster.endpoint.rds.amazonaws.com"
  port          = 3306
}

resource "aws_dms_replication_task" "task" {
  replication_task_id = "my-task"
  replication_instance_arn = aws_dms_replication_instance.example.replication_instance_arn
  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn
  migration_type = "full-load-and-cdc"
  table_mappings = <<EOF
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "1",
      "object-locator": {
        "schema-name": "%",
        "table-name": "%"
      },
      "rule-action": "include"
    }
  ]
}
EOF
}
```

---

## 🧾 Pricing (2024)

|Resource|Cost|
|---|---|
|Replication instance|Starts at ~$0.018/hr (dms.t3.micro)|
|Data transfer|Free between AWS services in same region|
|Storage (logs/checkpoints)|Based on allocated volume|
|Free tier|750 hours/month for 2 months (for t3.micro)|

---

## 🔐 Security

|Feature|Supported|
|---|---|
|IAM Role-based access|✅ Yes|
|KMS Encryption|✅ Yes (at rest)|
|SSL for DB Connections|✅ Yes|
|VPC/Private Subnet|✅ Yes (best practice)|
|CloudWatch & SNS|✅ Logs + alerts|

---

## 🛠️ Best Practices

- Place replication instance **in same region and subnet** as target
    
- Enable **multi-AZ** for replication if needed
    
- Use **parameter groups** to adjust retry/timeouts
    
- **Pre-create target schema** (DMS won’t create them in all engines)
    
- Monitor task health using **CloudWatch metrics and logs**
    

---

## 🚨 Limitations

|Area|Details|
|---|---|
|Schema conversion|Not automatic → Use AWS SCT (Schema Conversion Tool)|
|Triggers, SPs|Not migrated; only data + indexes|
|Data types|Some conversions require mapping (e.g., BLOB to JSON)|
|CDC dependencies|CDC needs binary logs (e.g., `binlog` for MySQL)|

---

## ✅ TL;DR Summary

|Feature|AWS DMS|
|---|---|
|Migration types|Full Load, CDC, or both|
|Source/Target support|SQL, NoSQL, S3, Redshift, etc.|
|Real-time replication|✅ Yes (CDC)|
|Fully managed|✅ Yes|
|Terraform support|✅ Yes (with full component coverage)|
|Free tier|✅ 2 months (750 hours on t3.micro)|
|Schema migration|❌ Use AWS SCT separately|

---
