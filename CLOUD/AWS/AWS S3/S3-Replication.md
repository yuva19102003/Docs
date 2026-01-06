
## 🔁 What is S3 Replication?

**S3 Replication** is a feature that **automatically copies objects** from one S3 bucket (source) to another (destination) — either in the **same region (SRR)** or **a different region (CRR)**.

> ✅ Works **asynchronously** and replicates **new objects** after enabling.

---

## 🎯 Why Use S3 Replication?

|Use Case|Benefit|
|---|---|
|Compliance (e.g., data residency)|Replicate to a specific region|
|Disaster Recovery|Maintain a copy in another region|
|Data Aggregation|Sync data from multiple accounts|
|Log retention|SRR to archive logs to another bucket|
|Analytics|Replicate data to analytics account/bucket|

---

## 🔀 Types of Replication

|Type|Description|
|---|---|
|**CRR** (Cross-Region)|Source and destination in **different** regions|
|**SRR** (Same-Region)|Source and destination in **same** region|

> Both CRR and SRR are configured using the same **replication rules** mechanism.

---

## 📋 Requirements

|Requirement|Description|
|---|---|
|Versioning|Must be **enabled on both** source & destination|
|Permissions|IAM role for S3 to replicate objects|
|Destination bucket|Can be same or different AWS account|
|SSE-KMS encrypted objects|Requires key access permissions|

---

## 🧱 Key Components

|Component|Description|
|---|---|
|**Replication Rule**|Defines filters (prefix/tags), destination, status|
|**IAM Role**|Allows S3 to replicate from source to destination|
|**Replication Time Control (RTC)**|Optional feature for **<15-minute delivery guarantee**|
|**Delete Marker Replication**|Optional — replicate delete markers (versioned only)|
|**Replica Modification Sync**|Optional — sync metadata updates (SRR only)|

---

## 🔧 How to Configure Replication (Console / CLI)

### ✅ Step 1: Enable Versioning

```bash
aws s3api put-bucket-versioning --bucket source-bucket --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket destination-bucket --versioning-configuration Status=Enabled
```

### ✅ Step 2: Create IAM Role for Replication

Example trust policy (for S3 service):

```json
{
  "Effect": "Allow",
  "Principal": { "Service": "s3.amazonaws.com" },
  "Action": "sts:AssumeRole"
}
```

> ✅ AWS can auto-create this role via the console.

### ✅ Step 3: Add Replication Configuration

You define:

- Rule ID
    
- Status (Enabled/Disabled)
    
- Prefix filter or tag filter
    
- Destination bucket ARN
    
- Optional settings like delete marker replication
    

---

## 📘 Sample Replication Rule (JSON)

```json
{
  "Role": "arn:aws:iam::123456789012:role/s3-replication-role",
  "Rules": [{
    "ID": "logs-replication",
    "Status": "Enabled",
    "Prefix": "logs/",
    "Destination": {
      "Bucket": "arn:aws:s3:::destination-bucket"
    }
  }]
}
```

---

## 🧠 Behavior and Considerations

|Action/Behavior|Replicated?|
|---|---|
|**New object uploads**|✅ Yes|
|**Existing objects (before rule)**|❌ No (use Batch Replication)|
|**DELETE requests (non-versioned)**|❌ No|
|**Delete markers (versioned)**|✅ Optional|
|**Metadata changes**|❌ (unless `Replica Modification Sync` is enabled in SRR)|

---

## 📤 Batch Replication

To replicate **existing objects**, use **Amazon S3 Batch Replication**:

- Set up a **Batch Operation** job
    
- Choose "replicate existing objects"
    
- Can replicate millions of existing files
    

---

## ⏱️ Replication Time Control (RTC)

|Feature|Value|
|---|---|
|Purpose|Guarantees replication within 15 minutes|
|Cost|Additional per-GB fee|
|Use Case|Compliance-sensitive replication|

---

## 🔐 Encryption Handling

|Encryption Type|Supported?|Notes|
|---|---|---|
|SSE-S3|✅|Works by default|
|SSE-KMS|✅|Destination bucket must have access to the KMS key|
|SSE-C|❌|Not supported|

---

## 📊 Monitoring Replication

|Tool|Metric / Log|
|---|---|
|CloudWatch|`BytesPendingReplication`, etc.|
|S3 Event Logging|Replication status via object metadata|
|S3 Inventory|Track replication status per object|

---

## 💰 Pricing

- No charge for enabling replication
    
- **Data transfer OUT** from source bucket is charged
    
- **RTC** and **Batch Replication** are additionally charged
    
- Storage in the **destination bucket** is billed normally
    

---

## ✅ TL;DR Summary

|Feature|Description|
|---|---|
|What is it?|Auto-copy objects between S3 buckets|
|Types|SRR (same-region), CRR (cross-region)|
|Versioning required?|✅ Yes (both buckets)|
|Sync updates to metadata?|❌ (unless SRR with sync enabled)|
|Support for KMS?|✅ Yes (needs permissions)|
|Sync deletes?|✅ Optional (only in versioned buckets)|
|Replicate old objects?|❌ Use S3 Batch Replication|

---

## 🛠️ 1. **Same-Region Replication (SRR)**

Use this when **source and destination buckets are in the same AWS region**.

### ✅ Terraform Code

```hcl
provider "aws" {
  region = "ap-south-1"
}

# 🔹 Destination Bucket (Same Region)
resource "aws_s3_bucket" "dst_bucket" {
  bucket = "yuva-srr-destination-bucket"
  versioning {
    enabled = true
  }
}

# 🔹 Source Bucket
resource "aws_s3_bucket" "src_bucket" {
  bucket = "yuva-srr-source-bucket"
  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rules {
      id     = "srr-replication"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.dst_bucket.arn
        storage_class = "STANDARD"
      }
    }
  }
}

# 🔹 IAM Role for Replication
resource "aws_iam_role" "replication_role" {
  name = "s3-srr-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  name = "replication-policy"
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.src_bucket.arn}/*"
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.dst_bucket.arn}/*"
      }
    ]
  })
}
```

---

## 🌎 2. **Cross-Region Replication (CRR)**

Use this when the **destination bucket is in a different region**, for example: source in `ap-south-1`, destination in `us-east-1`.

### ✅ Terraform Code

```hcl
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# 🔹 Destination Bucket in us-east-1
resource "aws_s3_bucket" "dst_bucket" {
  provider = aws.virginia
  bucket   = "yuva-crr-destination-bucket"
  versioning {
    enabled = true
  }
}

# 🔹 Source Bucket in ap-south-1
resource "aws_s3_bucket" "src_bucket" {
  provider = aws.mumbai
  bucket   = "yuva-crr-source-bucket"
  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rules {
      id     = "crr-rule"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.dst_bucket.arn
        storage_class = "STANDARD"
      }
    }
  }
}

# 🔹 IAM Role
resource "aws_iam_role" "replication_role" {
  name = "s3-crr-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  name = "crr-replication-policy"
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.src_bucket.arn}/*"
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.dst_bucket.arn}/*"
      }
    ]
  })
}
```

---
