
## 1. **What is AWS DocumentDB?**

- Fully managed **NoSQL document database service**
    
- Compatible with **MongoDB 3.6, 4.0, 5.0** APIs
    
- Designed for **JSON-like document** storage and queries
    
- Handles **scaling, backups, patching, and high availability** automatically
    
- Ideal for apps needing flexible, semi-structured data models
    

---

## 2. **Key Features**

|Feature|Description|
|---|---|
|**MongoDB compatible**|Supports MongoDB drivers and tools|
|**Multi-AZ replication**|Uses replicas for high availability|
|**Automatic backups**|Continuous backups with point-in-time restore|
|**Scalable read replicas**|Up to 15 read replicas|
|**Encryption**|Data encrypted at rest and in transit|
|**VPC-only access**|Runs inside your private VPC for security|

---

## 3. **Basic Architecture**

- **Cluster**: One primary node + multiple read replicas
    
- Storage: Distributed, fault-tolerant, automatically scaled
    
- Compute: Managed instance types (similar to EC2)
    
- Network: Runs inside your VPC, accessible via security groups
    

---

## 4. **Use Cases**

- Content management systems
    
- Catalogs and product data
    
- Mobile apps with dynamic schemas
    
- Real-time analytics on JSON data
    
- Any app using MongoDB API that wants managed service
    

---

## 5. **Supported Operations**

- CRUD operations using MongoDB shell or drivers
    
- Aggregation pipelines
    
- Indexing on fields
    
- Change streams (via some MongoDB compatibility)
    
- Transactions support on clusters (limited compared to native MongoDB)
    

---

## 6. **Provisioning DocumentDB**

**Via AWS Console:**

1. Go to **Amazon DocumentDB** service
    
2. Click **Create Cluster**
    
3. Configure:
    
    - Cluster identifier
        
    - Instance class (e.g., db.r6g.large)
        
    - Number of instances (primary + replicas)
        
    - VPC and subnet group
        
    - Security group for access
        
4. Enable backups and encryption as needed
    
5. Create cluster
    

---

## 7. **Connecting to DocumentDB**

- Use standard **MongoDB drivers** and **connection strings**
    
- Connection string example:
    

```plaintext
mongodb://username:password@docdb-cluster.cluster-xxxxxx.us-east-1.docdb.amazonaws.com:27017/?ssl=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false
```

- Requires SSL connection (DocumentDB uses TLS)
    
- Use AWS Certificate Bundle or download the root CA for SSL verification
    

---

## 8. **Replication in DocumentDB**

- Supports **asynchronous replication** across multiple Availability Zones for high availability
    
- One **primary instance** handles writes
    
- Multiple **read replicas** serve reads, offloading the primary
    
- Failover happens automatically within seconds if primary fails
    

---

## 9. **Backups and Restore**

- Automatic backups enabled by default with **7-day retention** (configurable up to 35 days)
    
- **Point-in-time recovery** (PITR) to any second within backup retention
    
- Manual snapshots possible
    
- Snapshots can be shared and copied across regions
    

---

## 10. **Scaling**

- Scale up by increasing instance size or adding replicas
    
- Storage is **auto-scaling** (starts at 10GB, can grow to 64TB)
    
- Use read replicas to improve read throughput
    
- No sharding support — single cluster only
    

---

## 11. **Security**

- Runs in **your VPC**, controlled by security groups
    
- Supports **IAM authentication** (optional)
    
- Data encrypted at rest with **KMS**
    
- TLS encrypted in transit
    
- Fine-grained access control via MongoDB users and roles
    

---

## 12. **Monitoring**

- Integrated with **CloudWatch** (CPU, memory, connections, disk usage)
    
- **Enhanced Monitoring** with OS metrics
    
- Alerts and alarms via CloudWatch Events
    
- Integration with AWS CloudTrail for auditing API calls
    

---

## 13. **Terraform Example**

```hcl
resource "aws_docdb_cluster" "example" {
  cluster_identifier      = "my-docdb-cluster"
  master_username         = "docdbuser"
  master_password         = "SuperSecret1234"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  db_subnet_group_name    = aws_docdb_subnet_group.example.name
  storage_encrypted       = true
  skip_final_snapshot     = true
}

resource "aws_docdb_cluster_instance" "example" {
  count              = 2
  identifier         = "my-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.example.id
  instance_class     = "db.r5.large"
  engine             = "docdb"
  engine_version     = "4.0.0"
  publicly_accessible = false
}

resource "aws_docdb_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb-security-group"
  description = "Allow inbound access on 27017"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # your app's CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## 14. **Limitations**

|Limitation|Notes|
|---|---|
|No support for MongoDB sharding|Scale by read replicas only|
|Some MongoDB features missing|Change streams, transactions limited|
|No support for direct on-premise access|Only via VPC or VPN|
|No free tier|Costs can add up with scaling|

---

## 15. **Summary**

|Topic|AWS DocumentDB|
|---|---|
|Type|Managed MongoDB-compatible NoSQL|
|Scalability|Auto storage, read replicas|
|Replication|Multi-AZ async replication|
|Backup|Continuous + snapshots|
|Security|VPC, KMS encryption, IAM auth|
|Use Case|JSON doc DB, flexible schema apps|

---
