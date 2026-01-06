
## 💰 What is S3 "Requester Pays"?

**Requester Pays** is a feature that **shifts the data transfer and request costs from the bucket owner to the requester**.

> 🧾 Normally, the **bucket owner** pays for all requests and downloads.  
> But with **Requester Pays enabled**, the **user downloading or accessing data pays** instead.

---

## 🎯 When to Use Requester Pays

|Scenario|Benefit|
|---|---|
|Public data lakes (e.g., Open Government Data)|Owner avoids bandwidth costs|
|Cross-account access for partners/vendors|Each account pays its own usage|
|High-traffic archives (e.g., ML datasets, research)|Avoid unexpected bills on the owner|
|Shared team resources in enterprise|Ensures chargeback by usage|

---

## 🔐 Key Requirements

- Bucket owner **must enable requester pays**
    
- Requester **must use AWS CLI/SDK and include `RequestPayer=requester`**
    
- **No anonymous access** is allowed
    
- **Requester’s account will be billed** for data transfer and GET/list requests
    

---

## 📋 What Gets Charged?

|Action|Charged to Requester?|
|---|---|
|GET Object|✅ Yes|
|LIST Objects|✅ Yes|
|HEAD Object|✅ Yes|
|PUT/DELETE Object|❌ No (still billed to owner)|
|Storage (per GB/month)|❌ No (always paid by owner)|

---

## 🔧 How to Enable Requester Pays

### ✅ AWS CLI

```bash
aws s3api put-bucket-request-payment \
  --bucket my-bucket \
  --request-payment-configuration Payer=Requester
```

### 🔍 Check if enabled

```bash
aws s3api get-bucket-request-payment --bucket my-bucket
```

### 🧑‍💻 Requester must use:

```bash
aws s3 cp s3://my-bucket/data.csv ./ --request-payer requester
```

---

## 🛠️ Terraform Example

```hcl
resource "aws_s3_bucket" "requester_bucket" {
  bucket = "yuva-requester-pays-demo"
}

resource "aws_s3_bucket_request_payment_configuration" "rp" {
  bucket = aws_s3_bucket.requester_bucket.id
  payer  = "Requester"
}
```

---

## 🚫 Limitations

|Limitation|Description|
|---|---|
|❌ No anonymous public access|All requests must be authenticated|
|❌ No access via S3 website endpoint|Only supported via AWS SDK/CLI/REST|
|❌ Not for S3 Glacier objects|Only works with Standard/IA classes|
|❗ Billing granularity|Only requester’s AWS account is billed|

---

## 🧠 Best Practices

- Use **bucket policies** to allow `s3:GetObject` only if `RequestPayer = requester`
    
- Document usage expectations in shared/public datasets
    
- Combine with **cost allocation tags** for tracking
    

---

## 🧾 Sample Bucket Policy (for requesters)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGetWithRequesterPays",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringEquals": {
          "s3:RequestObjectTag/requester": "true"
        }
      }
    }
  ]
}
```

---

## ✅ TL;DR Summary

|Feature|Description|
|---|---|
|What is it?|Requester pays for data access (not owner)|
|Who uses it?|Public datasets, shared buckets, cross-account|
|Owner pays?|Only for storage, not for GET/LIST requests|
|Requester pays?|For GET, LIST, HEAD, etc.|
|Anonymous?|❌ Not allowed|
|Access Method?|SDK, CLI, REST only|

---
