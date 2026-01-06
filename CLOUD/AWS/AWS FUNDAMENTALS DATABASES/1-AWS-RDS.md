
## 🔹 1. **What is Amazon RDS?**

**Amazon RDS (Relational Database Service)** is a managed service for relational databases like:

- **MySQL**
    
- **PostgreSQL**
    
- **MariaDB**
    
- **Oracle**
    
- **SQL Server**
    
- **Amazon Aurora**
    

It automates:

- Database provisioning
    
- Backup and patching
    
- Monitoring and scaling
    

---

## 🔹 2. **RDS Database Engines**

|Engine|Best For|
|---|---|
|MySQL|Lightweight open-source apps|
|PostgreSQL|Advanced open-source apps, GIS|
|MariaDB|MySQL-compatible with more storage engines|
|Oracle|Enterprise apps with complex needs|
|SQL Server|Windows/.NET enterprise workloads|
|Aurora|AWS-native engine, MySQL/PostgreSQL compatible|

---

## 🔹 3. **Key Concepts**

- **Instance Class**: Type of VM used (`db.t3.micro`, `db.m5.large`, etc.)
    
- **Storage Type**: General Purpose (gp2/gp3), Provisioned IOPS (io1)
    
- **Multi-AZ**: Synchronous standby for HA
    
- **Read Replica**: Async copies for read scaling
    
- **Backups**: Automated + manual snapshots
    
- **Parameter/Option Groups**: DB-level configurations
    

---

## 🔹 4. **Create RDS Instance (Console)**

1. Open **AWS Console → RDS**
    
2. Choose **"Create Database"**
    
3. Select:
    
    - Engine (e.g., PostgreSQL)
        
    - Use case: Production/Dev
        
4. Choose instance size (`db.t3.micro`)
    
5. Set:
    
    - DB Name, username, password
        
    - Storage (e.g., 20 GB gp2)
        
6. Enable/disable:
    
    - Public access
        
    - Multi-AZ
        
7. Click **"Create Database"**
    

---

## 🔹 5. **RDS Security**

|Feature|Description|
|---|---|
|VPC|RDS runs inside a VPC|
|Security Groups|Acts as a firewall for DB access|
|KMS Encryption|Encrypts data at rest|
|IAM Auth|Passwordless auth using IAM|
|SSL|Encrypts data in transit|

---

## 🔹 6. **Backups & Snapshots**

- **Automated Backups**:
    
    - Daily backups
        
    - Point-in-time recovery (PITR)
        
    - Retention: 1–35 days
        
- **Manual Snapshots**:
    
    - User-initiated
        
    - Persistent until deleted
        

---

## 🔹 7. **Monitoring & Logging**

|Tool|What it Does|
|---|---|
|CloudWatch|CPU, RAM, storage, latency, etc.|
|Enhanced Monitoring|OS-level metrics|
|RDS Events|Auto-logs lifecycle events|
|Performance Insights|SQL-level performance|

---

## 🔹 8. **Scaling RDS**

- **Vertical Scaling**: Change instance type (e.g., from `t3.micro` → `m5.large`)
    
- **Storage Scaling**: Increase allocated storage
    
- **Horizontal Scaling**: Use Read Replicas
    

---

## 🔹 9. **Multi-AZ (High Availability)**

### 🔁 Synchronous Replication

|Feature|Value|
|---|---|
|Use Case|High Availability (HA)|
|Replication Type|**Synchronous**|
|Failover|Automatic with DNS endpoint switch|
|Read Access|❌ Not allowed|
|Supported Engines|MySQL, PostgreSQL, Oracle, SQL Server|
|Billing|You pay for both primary and standby|

---

## 🔹 10. **Read Replica (Scaling Reads)**

### 🔄 Asynchronous Replication

|Feature|Value|
|---|---|
|Use Case|Scaling reads, reporting, analytics|
|Replication Type|**Asynchronous**|
|Failover|Manual (can promote replica)|
|Read Access|✅ Allowed|
|Cross-region|✅ Supported|
|Engines Supported|MySQL, PostgreSQL, MariaDB, Aurora|

**Creation (Console):**

- RDS → Select DB → Actions → "Create Read Replica"
    

---

## 🔹 11. **Synchronous vs Asynchronous (Side-by-Side)**

|Feature|Multi-AZ (Sync)|Read Replica (Async)|
|---|---|---|
|Purpose|High Availability|Read scalability|
|Type of Replication|Synchronous|Asynchronous|
|Read Access|❌ No|✅ Yes|
|Failover|✅ Auto|❌ Manual|
|Lag|None|Possible|
|Cross-region Support|❌ No|✅ Yes|
|Writes|Only Primary|Only Primary|

---

## 🔹 12. **Amazon RDS Custom**

### 🛠️ Fully Managed with OS-Level Access

|Feature|Value|
|---|---|
|OS Access|✅ Yes (via SSH)|
|Use Case|Legacy apps, custom monitoring, BYOL|
|Engines Supported|Oracle, SQL Server|
|Backup/Patching|You manage|
|CloudWatch|Integrated|
|IAM/KMS|Required for setup|

**Ideal For:**

- Installing agents (Oracle APEX, Splunk, DataDog)
    
- Full control of DB config + OS
    
- Audit/Compliance heavy systems
    

---

### 🔧 Create RDS Custom (High Level Steps):

1. Create:
    
    - Custom parameter group
        
    - Option group
        
    - Subnet group
        
2. Launch DB with:
    
    - KMS Key
        
    - IAM Role
        
    - SSH Key
        
3. Connect via SSH to EC2 backing the RDS Custom
    

---

### 📌 RDS Custom vs Standard RDS

|Feature|Standard RDS|RDS Custom|
|---|---|---|
|SSH Access|❌ No|✅ Yes|
|Managed by AWS|✅ Full|⚠️ Partial|
|Custom Agents|❌ No|✅ Yes|
|DB/OS Config|Limited|Full|
|Use Case|Cloud-native|Legacy/custom DB|

---

## 🔹 13. **Terraform Sample (MySQL + Read Replica)**

```hcl
resource "aws_db_instance" "primary" {
  identifier          = "mydb"
  allocated_storage   = 20
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "pass1234"
  publicly_accessible = true
  skip_final_snapshot = true
}

resource "aws_db_instance" "read_replica" {
  replicate_source_db = aws_db_instance.primary.id
  instance_class      = "db.t3.micro"
  publicly_accessible = true
  skip_final_snapshot = true
}
```

---

## 🔹 14. **Best Practices**

✅ Enable **Multi-AZ** for critical DBs  
✅ Use **Read Replicas** to scale reads  
✅ Encrypt with **KMS**  
✅ Use **CloudWatch Alarms** for:

- CPU > 80%
    
- Free storage < 10%
    
- Replica Lag > 30s  
    ✅ Rotate credentials with **IAM Auth**  
    ✅ Store secrets in **AWS Secrets Manager**  
    ✅ Enable **Performance Insights**  
    ✅ Apply **Security Group rules tightly**  
    ✅ Use **parameter groups** for tuning
    

---

## 🔹 15. **RDS Limitations**

|Limitation|Notes|
|---|---|
|Custom OS-level tasks|Only in **RDS Custom**|
|No cross-region Multi-AZ|Use Read Replica instead|
|Manual replica promotion|No auto failover (except Aurora)|
|No cron jobs|Use Lambda or EventBridge instead|

---
# 🔐 **AWS RDS Proxy (Quick Guide)**

## ✅ What is it?

A **fully managed connection pooler** for Amazon RDS and Aurora. It improves **performance**, **scalability**, and **availability** by sitting between your app and the database.

---

## 🚀 Benefits

- ✅ **Connection pooling** → reduce DB overhead
    
- ✅ **Auto failover** → faster Multi-AZ failover
    
- ✅ **IAM auth** support
    
- ✅ **Better app resiliency** under high load
    

---

## 🎯 Use Cases

- Serverless apps (e.g., Lambda)
    
- High-concurrency applications
    
- Auto-scaling environments
    

---

## 🔧 Setup Steps

1. Create IAM role + secrets in **Secrets Manager**
    
2. Enable RDS Proxy in **RDS Console**
    
3. Choose DB + secret + VPC/subnets
    
4. Use proxy **endpoint** in your app
    

---

## ⚠️ Limitations

- No support for MariaDB or RDS Custom
    
- Max 5000 concurrent connections per proxy
    
- Minor cold start when scaling initially
    

---

## 🛠️ Sample Terraform

```hcl
resource "aws_db_proxy" "example" {
  name                   = "my-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_subnet_ids         = ["subnet-123", "subnet-456"]
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_secret.arn
  }
}
```

---

