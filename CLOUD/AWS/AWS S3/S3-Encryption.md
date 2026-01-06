
## 🔐 Why S3 Encryption?

S3 encryption ensures that your data is **secure and compliant** by:

- Preventing unauthorized access to data at rest
    
- Meeting compliance requirements (HIPAA, PCI-DSS, etc.)
    
- Protecting sensitive objects like backups, logs, user uploads
    

> 🛡️ Encryption in S3 is supported both **at rest** and **in transit**.

---

## 🔒 Types of Encryption in S3

|Type|Description|
|---|---|
|**SSE-S3** (Server-Side, S3)|AWS manages keys automatically|
|**SSE-KMS** (Server-Side, KMS)|Uses AWS KMS for encryption, allows key policies, audit logs|
|**SSE-C** (Server-Side, Customer-provided)|You manage the key and provide it with each request|
|**Client-side encryption**|You encrypt objects yourself before uploading|

---

## 🧊 1. Server-Side Encryption (SSE-S3)

- Uses **AES-256** encryption
    
- Key is managed by **Amazon S3**
    
- No need for manual configuration
    

### ✅ Use Case:

Low-risk environments where **compliance is not strict**.

### Terraform Example:

```hcl
resource "aws_s3_bucket" "sse_s3" {
  bucket = "yuva-encrypted-sse-s3"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

---

## 🔐 2. Server-Side Encryption with KMS (SSE-KMS)

- Uses **AWS Key Management Service (KMS)**
    
- Offers **fine-grained access control**, audit logs, and key rotation
    

### ✅ Use Case:

Sensitive data, HIPAA/PCI/ISO compliance, auditing required

### Terraform Example:

```hcl
resource "aws_kms_key" "s3_key" {
  description = "KMS key for S3 encryption"
}

resource "aws_s3_bucket" "sse_kms" {
  bucket = "yuva-encrypted-sse-kms"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_key.arn
      }
    }
  }
}
```

> 💡 You can also use the **default AWS KMS key** (`alias/aws/s3`) if you don’t want a custom key.

---

## 🔐 3. Server-Side Encryption with Customer-Provided Key (SSE-C)

- You **supply your own encryption key** in every request
    
- AWS **doesn't store the key**
    
- Suitable only for advanced use cases
    

> ⚠️ Not supported by **AWS CLI sync**, **S3 Lifecycle**, or **multi-part uploads**

---

## 🔐 4. Client-Side Encryption

- You **encrypt data before uploading**
    
- AWS only stores encrypted data
    
- You manage keys, software, and key rotation
    

### ✅ Use Case:

Highly sensitive, regulated workloads (e.g., banks, defense)

> Example: Encrypt files using AWS SDK or tools like `aws-encryption-sdk`.

---

## ✅ S3 Encryption in Practice

|Feature|SSE-S3|SSE-KMS|SSE-C|Client-Side|
|---|---|---|---|---|
|Key managed by|AWS S3|AWS KMS|You|You|
|Audit logging|❌|✅ CloudTrail|❌|Depends on you|
|Lifecycle rules support|✅|✅|❌|❌|
|Multipart upload|✅|✅|❌ (manual)|❌ (manual)|
|S3 Select support|✅|✅|❌|❌|

---

## 🛡️ Enforce Bucket Encryption

To **ensure no unencrypted objects** are uploaded:

### Bucket Policy to Enforce SSE-KMS:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnEncryptedUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::yuva-encrypted-sse-kms/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
```

---

## 🚨 Security Best Practices

✅ Always enable encryption by default  
✅ Use SSE-KMS if you need auditing and access control  
✅ Enforce encryption via bucket policy  
✅ Rotate KMS keys annually  
✅ Enable CloudTrail for S3 and KMS operations

---

## ✅ TL;DR Summary

|Encryption Type|Managed By|Use Case|Terraform Support|
|---|---|---|---|
|SSE-S3|AWS S3|Default, simple protection|✅ Yes|
|SSE-KMS|AWS KMS|Compliance, audit, key control|✅ Yes|
|SSE-C|You|Extreme security, edge cases|❌ Not via TF|
|Client-side|You|Max control, regulated data|❌ Manual|

---
