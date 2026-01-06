
## 🧠 What is AWS Backup?

**AWS Backup** is a **fully managed backup service** that lets you **automate, centralize, and monitor** backups across a wide range of AWS resources (EC2, EBS, RDS, DynamoDB, EFS, FSx, etc.) from a **single place**.

> ✅ It ensures that your backup and restore strategies meet compliance, business continuity, and disaster recovery requirements.

---

## 💡 Why Use AWS Backup?

|Benefit|Description|
|---|---|
|✅ Centralized management|Manage backups across services and regions from one dashboard|
|✅ Policy-driven automation|Use **backup plans** to enforce backup schedules and retention|
|✅ Cross-region backup|Copy backups across regions for DR|
|✅ Compliance tracking|Use **AWS Backup Audit Manager** for compliance reports|
|✅ Cost-effective|Pay only for storage used; supports lifecycle rules|

---

## 📦 Supported AWS Resources

|Service|Backup Type|
|---|---|
|**EBS Volumes**|Volume snapshots|
|**RDS/Aurora**|Automated snapshots|
|**DynamoDB**|Table backups|
|**EFS**|File system backups|
|**FSx**|File system backups|
|**EC2**|AMIs via AWS Backup|
|**S3** (Preview)|Object-level backup (granular)|

---

## 🏗️ Core Concepts

|Component|Description|
|---|---|
|**Backup Plan**|A policy defining backup frequency and retention|
|**Backup Vault**|Encrypted storage container for backups|
|**Recovery Point**|A completed backup (e.g., snapshot or archive)|
|**Backup Selection**|Defines what resources are protected by a backup plan|
|**Cross-Region Backup**|Automatically replicate recovery points to another region|

---

## 🧪 Example Backup Plan

```json
{
  "BackupPlanName": "DailyBackupPlan",
  "Rules": [
    {
      "RuleName": "DailyBackup",
      "TargetBackupVaultName": "MyBackupVault",
      "ScheduleExpression": "cron(0 5 * * ? *)",
      "StartWindowMinutes": 60,
      "CompletionWindowMinutes": 180,
      "Lifecycle": {
        "DeleteAfterDays": 30,
        "MoveToColdStorageAfterDays": 7
      }
    }
  ]
}
```

🕔 This plan:

- Takes backups daily at **5 AM UTC**
    
- Moves them to cold storage after 7 days
    
- Deletes them after 30 days
    

---

## 🔐 Security & Compliance

|Feature|Description|
|---|---|
|**IAM-based access**|Fine-grained access to backup plans/vaults|
|**Encryption**|KMS support for vault encryption|
|**Cross-account backup**|Use AWS Organizations for delegated backups|
|**Audit Manager**|Compliance checks and backup reporting|
|**Resource Locking**|Prevent deletion of vaults with legal holds|

---

## 🔁 Cross-Region & Cross-Account Backup

✅ Replicate backups **automatically** to:

- A different **AWS region** for disaster recovery
    
- A different **AWS account** for separation of duties
    

### Example Use Case:

- Region A (primary) → Region B (DR) every 24 hours
    

---

## 🔧 Restore Options

|Resource|Restore Method|
|---|---|
|**EBS**|Create new volume from snapshot|
|**RDS**|Restore to new DB instance|
|**EFS/FSx**|Restore to new file system or existing|
|**DynamoDB**|Table-level restore|
|**EC2**|Restore AMI into new EC2 instance|

---

## 📋 Terraform Example

### Backup Vault & Plan (Terraform)

```hcl
resource "aws_backup_vault" "default" {
  name = "default-vault"
}

resource "aws_backup_plan" "daily" {
  name = "daily-plan"
  rule {
    rule_name         = "daily-rule"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 6 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}
```

### Backup Selection

```hcl
resource "aws_backup_selection" "efs" {
  name          = "select-efs"
  iam_role_arn  = aws_iam_role.backup.arn
  plan_id       = aws_backup_plan.daily.id
  resources     = ["arn:aws:elasticfilesystem:...:file-system/fs-12345678"]
}
```

---

## 📊 Monitoring & Notifications

|Tool|Purpose|
|---|---|
|**CloudWatch**|Monitor backup job metrics, logs|
|**SNS**|Send success/failure alerts via notifications|
|**Backup Audit Manager**|Track policy compliance and exceptions|

---

## 💰 Pricing

|Resource Type|Backup Pricing Example|
|---|---|
|**EBS**|~$0.05/GB-month (standard)|
|**Cold Storage**|~$0.0125/GB-month|
|**Restore Cost**|Free for most; some FSx restore has cost|
|**Audit Manager**|~$1.25 per report (varies by use)|

✅ **No charge** for backup jobs themselves — only storage consumed and data transfer out.

---

## ✅ TL;DR Summary

|Feature|AWS Backup|
|---|---|
|Multi-service support|✅ EC2, EBS, RDS, DynamoDB, EFS, FSx, S3|
|Centralized backup|✅ Yes|
|Lifecycle policies|✅ Cold storage + retention control|
|Cross-region/account backup|✅ Yes|
|Restore support|✅ Fast, service-specific|
|IAM & encryption|✅ Secure and auditable|
|Terraform support|✅ Full resource support|

---
