
## 📁 What is AWS Transfer Family?

**AWS Transfer Family** is a **fully managed service** that enables secure **file transfers over SFTP, FTPS, and FTP** directly into and out of **Amazon S3 or EFS**.

> ✅ It helps you **modernize legacy data transfer workflows** without changing your existing clients or scripts.

---

## 📦 Protocols Supported

|Protocol|Description|Port|Encryption|
|---|---|---|---|
|**SFTP**|Secure File Transfer Protocol|TCP 22|✅ Encrypted|
|**FTPS**|FTP over SSL/TLS|TCP 990|✅ Encrypted|
|**FTP**|Plain FTP (not recommended)|TCP 21|❌ Unencrypted (use only if needed)|

---

## 🧠 Key Concepts

|Component|Description|
|---|---|
|**Server**|The managed Transfer Family endpoint|
|**User**|IAM- or directory-integrated account with access to the endpoint|
|**Home Directory**|Mapped to a path in S3 or EFS|
|**Authentication**|Can be done via IAM, custom identity provider, or AD|

---

## 🧰 Use Cases

|Scenario|Why Use Transfer Family?|
|---|---|
|📂 Legacy systems using SFTP/FTP|Migrate data to cloud without changing workflows|
|🔒 Secure partner file exchange|Provide external clients access to S3/EFS securely|
|🏢 B2B data interchange|Automate data uploads (e.g., invoices, logs)|
|💼 Financial/Healthcare transfer|PCI, HIPAA-compliant secure file storage|

---

## 🎯 Storage Backends

|Backend|Use Case|Protocols Supported|
|---|---|---|
|**S3**|Data ingestion, archival, backup|SFTP, FTPS, FTP|
|**EFS**|Low-latency, POSIX-based access|SFTP only|

---

## 🔐 Authentication Methods

|Method|Description|
|---|---|
|**Service-managed**|AWS manages user credentials (password or SSH key)|
|**Custom Identity**|Use AWS Lambda + external source (LDAP, RDS, DynamoDB, etc.)|
|**AWS Directory Service**|Integrate with Microsoft AD (for FTPS, FTP, and SFTP)|
|**API Gateway + Cognito**|For advanced identity brokering (custom logic)|

---

## 🧩 Architecture

```
[SFTP/FTP Client] → [AWS Transfer Family Server] → [S3 or EFS] → [Other AWS Services]
                         |
         +--------------+
         | Identity Provider (IAM / AD / Lambda)
```

- Fully managed, HA Transfer endpoint
    
- Authentication via IAM, AD, or Lambda
    
- Files stored in S3 or EFS
    
- Server logs available in CloudWatch
    

---

## 🔧 Terraform Example — SFTP to S3

### 1. Create S3 Bucket

```hcl
resource "aws_s3_bucket" "sftp_bucket" {
  bucket = "my-sftp-storage-bucket"
}
```

---

### 2. IAM Role for Transfer User

```hcl
resource "aws_iam_role" "transfer_user_role" {
  name = "TransferUserRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "transfer.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sftp_access_policy" {
  role = aws_iam_role.transfer_user_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      Resource = [
        "${aws_s3_bucket.sftp_bucket.arn}",
        "${aws_s3_bucket.sftp_bucket.arn}/*"
      ]
    }]
  })
}
```

---

### 3. Create Transfer Server

```hcl
resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  endpoint_type          = "PUBLIC"
  protocols               = ["SFTP"]

  tags = {
    Name = "my-sftp-server"
  }
}
```

---

### 4. Create User

```hcl
resource "aws_transfer_user" "sftp_user" {
  server_id   = aws_transfer_server.sftp_server.id
  user_name   = "testuser"
  role        = aws_iam_role.transfer_user_role.arn
  home_directory = "/${aws_s3_bucket.sftp_bucket.bucket}"

  ssh_public_key_body = file("~/.ssh/id_rsa.pub") # Optional
}
```

---

## 🪵 Monitoring and Logging

|Tool|What You See|
|---|---|
|**CloudWatch**|Connection status, uploads/downloads|
|**CloudTrail**|Track user access, create/delete activity|
|**S3 Access Logs**|Track file-level access|

---

## 💰 Pricing Summary (2024)

|Item|Cost|
|---|---|
|Per Hour per Server|~$0.30/hour (≈ $216/month)|
|Per Upload/Download GB|$0.04 per GB|
|Storage (S3 or EFS)|Charged separately|

---

## ✅ TL;DR Summary

|Feature|AWS Transfer Family|
|---|---|
|Protocols|SFTP, FTPS, FTP|
|Storage Backends|Amazon S3, EFS|
|Authentication|IAM, AD, or custom (Lambda/API Gateway)|
|Best For|Legacy apps, secure file exchange|
|Highly Available|✅ Yes|
|Terraform Support|✅ `aws_transfer_server`, `aws_transfer_user`|

---
