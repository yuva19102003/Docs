
## 🗄️ What is AWS Storage Gateway?

**AWS Storage Gateway** is a hybrid cloud storage service that allows your on-premises applications to seamlessly use **AWS cloud storage** for backup, disaster recovery, archiving, and more — using **standard protocols (NFS, SMB, iSCSI)**.

> ✅ Think of it as a **bridge between on-prem infrastructure and AWS storage services** like S3, Glacier, and EBS.

---

## 🧠 Gateway Types (Modes)

AWS Storage Gateway comes in **3 modes** depending on your use case:

|Gateway Type|Protocol|Use Case|Backed By|
|---|---|---|---|
|**File Gateway**|NFS/SMB|File-based backup and archival to S3|Amazon S3|
|**Volume Gateway**|iSCSI|Block-level storage with snapshots to AWS|Amazon EBS/S3|
|**Tape Gateway**|iSCSI|Replace physical tape libraries with virtual|Amazon S3 + Glacier|

---

## 📦 1. File Gateway (Most Common)

- **Exposes S3 buckets as NFS/SMB file shares**
    
- Acts like a file server caching frequently accessed files
    
- All files are **stored as objects in S3** (with optional S3 storage class selection)
    

🎯 **Use Cases**:

- Cloud-based file sharing
    
- On-prem apps writing to S3 (log backups, analytics pipelines)
    
- Replacing file servers or NAS appliances
    

---

## 📦 2. Volume Gateway

Comes in two modes:

- **Cached volumes** (minimal on-prem storage, data in S3)
    
- **Stored volumes** (primary data stored on-prem, snapshots to S3)
    

🎯 **Use Cases**:

- Block storage for VMware or Hyper-V
    
- Backup volumes to AWS
    
- Disaster recovery with EBS Snapshots
    

---

## 📦 3. Tape Gateway

- **Virtual Tape Library (VTL)** that replaces physical tapes
    
- Compatible with **iSCSI tape backup software** (e.g., Veeam, NetBackup)
    
- Backed by **Amazon S3 (active)** and **Glacier / Deep Archive (cold)**
    

🎯 **Use Cases**:

- Legacy tape-based backup modernization
    
- Regulatory data archival
    
- Air-gap backup with restore from cloud
    

---

## 🧰 Deployment Options

|Option|Description|
|---|---|
|**VMware or Hyper-V**|Deploy as a virtual appliance on-prem|
|**Amazon EC2**|Deploy in AWS (for cloud-to-cloud use cases)|
|**Hardware Appliance**|AWS Snowball Edge with Storage Gateway pre-installed|

---

## 🔐 Security Features

|Layer|Security Features|
|---|---|
|**At Rest**|S3/KMS encryption|
|**In Transit**|TLS encryption between client and gateway|
|**Access Control**|IAM policies on the S3 bucket / SMB share permissions|
|**AD Integration**|SMB access via Active Directory (for File Gateway)|

---

## 🔄 Architecture – File Gateway

```
[On-Prem App] → [Storage Gateway Appliance (NFS/SMB)] → [AWS S3 Bucket]
                           ↑
                   (local cache disk)
```

- Uses **local disk** as a cache for frequently accessed files
    
- Data asynchronously uploaded to **S3 in object format**
    
- Compatible with **S3 Lifecycle**, **S3 Replication**, **S3 Glacier**
    

---

## 📊 Monitoring

|Tool|Metric/Log|
|---|---|
|CloudWatch|CacheHitRate, UploadBytes, ErrorCount|
|CloudTrail|API calls like `CreateTape`, `DeleteVolume`|
|Gateway Console|Health, file share status|

---

## 🛠️ Terraform Example – File Gateway + S3

While AWS doesn’t currently support full lifecycle of Storage Gateway in Terraform (only partial), here’s a snippet using `aws_storagegateway_gateway`:

```hcl
resource "aws_storagegateway_gateway" "example" {
  gateway_name       = "file-gateway"
  gateway_timezone   = "GMT"
  gateway_type       = "FILE_S3"
  medium_changer_type = "AWS-Gateway-VTL"
  tape_drive_type     = "IBM-ULT3580-TD5"

  activation_key     = var.activation_key
  gateway_ip_address = var.gateway_ip
}
```

> ⚠️ You still need to **manually deploy the VM and get the activation key** before Terraform can configure the gateway.

---

## 💰 Pricing Summary

|Item|Cost (Approx.)|
|---|---|
|File/Volume Gateway|$0.01/GB per month (storage in S3)|
|Tape Gateway|S3 + Glacier pricing|
|Snapshots (Volume Gateway)|~$0.05/GB-month (EBS Snapshot)|
|Cache storage (local disk)|You provide (local SSD or HDD)|

> AWS does **not charge** for the gateway appliance itself (you host it), only for data usage.

---

## ✅ TL;DR Summary

|Feature|File Gateway|Volume Gateway|Tape Gateway|
|---|---|---|---|
|Protocol|SMB / NFS|iSCSI|iSCSI|
|Cloud Backend|S3|EBS + S3|S3 + Glacier|
|Use Case|File sharing & backup|Block storage + backup|Tape archiving|
|Deployment|On-prem VM or EC2|On-prem VM or EC2|On-prem VM or EC2|
|Caching|Yes|Yes|No|
|Access Control|IAM + AD|iSCSI initiators|Tape access policies|

---

### 🔄 Related AWS Services

|You Want...|Use This|
|---|---|
|File-level sync|AWS DataSync|
|One-time data transfer (offline)|AWS Snowball|
|FTP/SFTP support|AWS Transfer Family|
|NFS shared mount in cloud|Amazon FSx for OpenZFS|

---
