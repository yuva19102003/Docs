
## 🚀 What is AWS DataSync?

**AWS DataSync** is a **fully managed data transfer service** for moving large amounts of data **between on-premises storage** and **AWS services** (like Amazon S3, EFS, FSx), or between AWS services across regions and accounts.

> ✅ It automates data transfer, scales to **10+ Gbps**, and supports **incremental sync**, **metadata preservation**, **file permissions**, and **scheduling**.

---

## 📦 Use Cases

|Use Case|Why DataSync?|
|---|---|
|📤 Migrate on-prem NAS to S3/EFS|Lift-and-shift storage to AWS|
|🔁 Recurring backups to AWS|Schedule syncs (hourly/daily)|
|🔄 Inter-region EFS/FSx replication|Move data across regions securely|
|📁 One-time S3 to FSx transfer|Data prep for HPC, ML, analytics|
|🔐 DR setup|Replicate critical file systems to secondary regions|

---

## 🧠 Supported Transfer Endpoints

|Source or Destination|Supported Types|
|---|---|
|On-Prem Storage|NFS, SMB (Windows shares)|
|AWS Storage|S3, EFS, FSx for Windows File Server, FSx Lustre|
|S3 ↔ S3 (same or cross account/region)|✅|
|AWS GovCloud|✅ Supported|

---

## 🛠️ How It Works

1. **Install the DataSync Agent** (on-premises, VM or EC2)
    
2. **Create Source Location** (e.g., on-prem NFS or SMB)
    
3. **Create Destination Location** (e.g., S3, EFS, FSx)
    
4. **Create and Start Task**
    
    - Specify transfer options: filters, permissions, schedule
        
5. **Monitor Transfer** via console or CloudWatch
    

---

## 🧱 Architecture Diagram

```
[On-Prem NFS/SMB] ←→ [AWS DataSync Agent (VM)] ←→ [AWS Service (S3, EFS, FSx)]
                                          ↓
                               Management via AWS Console/API
```

- Transfers are encrypted **in-transit via TLS**
    
- **Agent** handles scanning, filtering, retry logic, data validation
    

---

## 🧩 Features

|Feature|Description|
|---|---|
|**Incremental Sync**|Only changed files are re-synced (after first transfer)|
|**Metadata Preservation**|Timestamps, POSIX/NTFS ACLs, symlinks (where applicable)|
|**Bandwidth Throttling**|Control transfer speed|
|**Task Scheduling**|Hourly, daily, or cron-based|
|**File Filtering**|Include/exclude patterns|
|**Monitoring**|CloudWatch metrics, logs, and events|
|**Data Validation**|Optional checksum-based comparison post-transfer|

---

## 🔐 Security

|Feature|Details|
|---|---|
|In-Transit Encryption|TLS 1.2 between agent and AWS|
|Access Control|IAM policies for DataSync + bucket/file share permissions|
|VPC Support|Yes, agent can run in VPC-connected EC2|
|Logs|CloudWatch + CloudTrail|
|Agent Security|Only communicates with AWS DataSync service endpoints|

---

## 📊 Performance

- Up to **10+ Gbps** throughput (optimized, multi-threaded)
    
- Parallelized file transfers
    
- Performance depends on network, agent specs, and source/destination
    

---

## 💰 Pricing (as of 2024)

|Item|Cost|
|---|---|
|Data Transfer|**$0.0125/GB** (within AWS)|
|On-Prem to AWS|**$0.04/GB** (region dependent)|
|Agent Usage|No extra charge|
|Egress from AWS (to on-prem)|Standard AWS egress applies|

---

## 🛠️ Terraform Example: On-Prem NFS → S3

> ⚠️ You must manually deploy the DataSync agent and activate it to get the `agent_arn`.

### 1. Create Source Location (NFS)

```hcl
resource "aws_datasync_location_nfs" "source" {
  server_hostname = "10.0.0.10"
  subdirectory    = "/data"

  on_prem_config {
    agent_arns = ["arn:aws:datasync:us-east-1:123456789012:agent/agent-12345678"]
  }
}
```

---

### 2. Create Destination Location (S3)

```hcl
resource "aws_datasync_location_s3" "destination" {
  s3_bucket_arn = "arn:aws:s3:::my-s3-bucket"
  subdirectory  = "/backup"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role.arn
  }
}
```

---

### 3. Create Task

```hcl
resource "aws_datasync_task" "nfs_to_s3" {
  source_location_arn      = aws_datasync_location_nfs.source.arn
  destination_location_arn = aws_datasync_location_s3.destination.arn

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.datasync_logs.arn

  options {
    preserve_deleted_files = "PRESERVE"
    overwrite_mode         = "ALWAYS"
    verify_mode            = "ONLY_FILES_TRANSFERRED"
  }

  name = "nfs-to-s3-backup"
}
```

---

## 🧪 Related Tools

|Need This|Use This|
|---|---|
|Offline transfer|AWS Snow Family|
|One-time bulk S3 upload|AWS CLI `aws s3 sync`|
|Continuous sync over FTP|AWS Transfer Family|
|NFS/SMB mount in cloud|Amazon FSx or EFS|

---

## ✅ TL;DR Summary

|Feature|AWS DataSync|
|---|---|
|Source/Target Support|On-Prem, S3, EFS, FSx, S3 (cross-account/region)|
|Performance|10+ Gbps, scalable|
|Secure|TLS in transit, IAM roles, agent auth|
|Automation|Scheduling, filtering, metadata copy|
|Terraform Support|✅ Fully supported|
|Use Case|Backup, migration, DR, inter-region sync|

---
