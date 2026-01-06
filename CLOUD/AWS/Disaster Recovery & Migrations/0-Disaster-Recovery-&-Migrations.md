
| Content                           | page                                  |
| --------------------------------- | ------------------------------------- |
| AWS DMS                           | [AWS DMS](AWS-DMS.md)                           |
| AWS Backup                        | [AWS Backup](AWS-Backup.md)                        |
| AWS Application Discovery Service | [AWS Application Discovery Service](AWS-Application-Discovery-Service.md) |
| AWS Application Migration Service | [AWS Application Migration Service](AWS-Application-Migration-Service.md) |
| VMC on AWS                        | [VMC on AWS](VMC-on-AWS.md)                        |

## 🧠 What Is Disaster Recovery (DR)?

**Disaster Recovery (DR)** is the practice of planning for and recovering from **unexpected events** that disrupt business operations — like hardware failures, cyberattacks, accidental deletions, natural disasters, etc.

In the **cloud**, DR focuses on **resilience**, **automation**, and **cost-effective replication** of critical systems and data.

---

## 📏 RTO and RPO: The Core Metrics

|Metric|Definition|
|---|---|
|**RTO** (Recovery Time Objective)|How quickly you must restore service after a disruption|
|**RPO** (Recovery Point Objective)|How much **data loss** (time window) you can tolerate|

> For example:
> 
> - If RTO = 4 hours → system must be back online within 4 hours
>     
> - If RPO = 15 minutes → you can lose at most 15 minutes of data
>     

---

## 🧪 Common RTO/RPO Requirements by Industry

|Industry|RTO|RPO|
|---|---|---|
|Banking|≤ 1 hour|≤ 5 minutes|
|Healthcare|1–2 hours|≤ 15 mins|
|SaaS Startups|4–8 hours|1–4 hours|
|Non-critical apps|24–48 hours|12–24 hours|

---

## 🏗️ Disaster Recovery Strategies in AWS

AWS offers **4 standard DR architectures**:

|Strategy|RTO|RPO|Cost|Description|
|---|---|---|---|---|
|**Backup & Restore**|Hours|Hours|Low|Backup data & config, restore manually after disaster|
|**Pilot Light**|Minutes|<1 hour|Medium|Core services (DB, AMIs) always running, others launched on fail|
|**Warm Standby**|<30 min|<30 min|High|Scaled-down version always running, scaled up when needed|
|**Multi-site (Hot)**|Seconds|Seconds|Very High|Fully duplicated system in multiple regions or AZs|

---

## 🔁 Migration vs DR

|Aspect|Migration|Disaster Recovery|
|---|---|---|
|Purpose|Move workload permanently|Restore workload temporarily|
|Involves Cutover|✅ Yes|❌ Not unless disaster occurs|
|Downtime allowed|Often scheduled|Must be minimized|
|Data replication|One-time or phased|Continuous or periodic|
|Tooling|AWS DMS, SMS, Application Migration Service|Snapshots, Replication, CloudEndure|

---

## ☁️ AWS Services for DR

|Category|Services|Description|
|---|---|---|
|**Compute**|EC2 AMIs, Auto Scaling|Pre-baked backups, scale after restore|
|**Storage**|EBS snapshots, S3 versioning|Durable backups|
|**Database**|RDS Multi-AZ, Aurora Global|Automatic failover, cross-region replicas|
|**DNS**|Route 53|Health checks, failover routing|
|**Replication**|AWS DMS, CloudEndure|Live or scheduled data replication|
|**Automation**|Lambda, CloudFormation|Automate failover & restore|

---

## 🔄 Sample DR Workflow: Backup & Restore

1. Use **AWS Backup** to schedule daily EBS and RDS backups
    
2. Replicate backups across **regions**
    
3. Store application configs (env vars, IAM, templates) in **S3 or SSM**
    
4. When disaster occurs:
    
    - Spin up EC2 instances using **AMIs**
        
    - Restore RDS from snapshot
        
    - Repoint DNS via **Route 53**
        

---

## 💡 DR Best Practices & Tips

|Category|Tip|
|---|---|
|**Automation**|Use CloudFormation + Lambda to automate restoration & infra setup|
|**Immutable Infra**|Use AMIs and containers for fast deployments|
|**Testing**|Perform **regular DR drills** using sandbox accounts or test AZs|
|**Backups**|Enable versioning for S3, schedule backups for EBS, RDS|
|**Encryption**|Use KMS to secure backups and replicas|
|**Monitoring**|Use CloudWatch + SNS for outage alerts and triggering failover|
|**Documentation**|Maintain clear SOPs (Standard Operating Procedures) for DR|

---

## 📦 Tooling for Migrations & DR

|Tool/Service|Use Case|
|---|---|
|**AWS DMS**|Migrate live databases|
|**AWS CloudEndure / MGN**|Lift-and-shift of full apps/VMs|
|**AWS Backup**|Scheduled backup + cross-region copy|
|**S3 Replication**|DR for object storage|
|**RDS Multi-AZ / Read Replica**|Hot standby for databases|
|**Route 53 Failover**|DNS-based failover|
|**Step Functions**|Recovery workflows orchestration|

---

## 🧱 Terraform Tip for Cross-Region DR (S3 Example)

```hcl
resource "aws_s3_bucket" "primary" {
  bucket = "my-primary-bucket"
  versioning {
    enabled = true
  }
  replication_configuration {
    role = aws_iam_role.replication.arn
    rules {
      id     = "replication-rule"
      status = "Enabled"
      destination {
        bucket        = aws_s3_bucket.secondary.arn
        storage_class = "STANDARD"
      }
    }
  }
}
```

---

## ✅ TL;DR Summary

|Term|Meaning|
|---|---|
|**RTO**|Max acceptable downtime (e.g., 1 hr)|
|**RPO**|Max acceptable data loss (e.g., 15 min of data)|
|**DR Plan Types**|Backup-Restore, Pilot Light, Warm Standby, Multi-site|
|**Tools**|DMS, MGN, S3 replication, Route 53, CloudFormation|
|**Key Advice**|Automate everything, test regularly, document recovery steps|

---
