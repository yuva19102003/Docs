
## 🧾 1. **What is S3?**

**Amazon S3** is an object storage service that offers:

- **Scalability**: Store unlimited data
    
- **Durability**: 99.999999999% (11 9’s)
    
- **Availability**: 99.99%
    
- **Access control**, **encryption**, **versioning**, **lifecycle rules**, etc.
    

---

## 🧱 2. **Core Concepts**

|Concept|Description|
|---|---|
|**Bucket**|Top-level container for objects|
|**Object**|File + metadata|
|**Key**|Unique identifier of object (like filepath)|
|**Prefix**|Virtual folder path (e.g., `images/2024/file.png`)|
|**Region**|Bucket lives in a single AWS region|

---

## 🔒 3. **Access Control Options**

|Method|Purpose|
|---|---|
|**Bucket Policies**|JSON policies for entire bucket|
|**IAM Policies**|Identity-based access|
|**ACLs (legacy)**|Object-level permissions|
|**Block Public Access**|Global safety toggle (enabled by default)|

---

## 🔁 4. **Versioning**

- Enable to keep **all versions** of an object (helps with recovery).
    
- Cannot be disabled, only **suspended**.
    
- Works well with **MFA Delete** for extra security.
    

---

## 🧯 5. **Lifecycle Rules**

Automate transitions and deletions:

|Transition|Example|
|---|---|
|S3 → Glacier|After 30 days (archival)|
|S3 → Delete|After 365 days|
|Noncurrent version → Delete|After 90 days|

---

## 🔐 6. **Encryption Options**

|Method|Description|
|---|---|
|**SSE-S3**|Server-side AES-256 (default)|
|**SSE-KMS**|Server-side with AWS KMS (auditable)|
|**SSE-C**|Customer-provided keys|
|**Client-side**|Encrypt before uploading (you manage it)|

---

## 🌐 7. **Static Website Hosting**

- Enable **"Static website hosting"** in bucket settings
    
- Upload `index.html`, `error.html`
    
- Make objects **public** (with policy)
    
- Use S3 URL or attach **Route53/CloudFront**
    

---

## 📥 8. **Presigned URLs**

- Temporarily allow **uploads/downloads**
    
- Valid for specific time (e.g., 10 mins)
    
- Use SDKs or CLI to generate
    

✅ Example (Boto3):

```python
url = s3.generate_presigned_url(
    'get_object',
    Params={'Bucket': 'my-bucket', 'Key': 'file.txt'},
    ExpiresIn=600
)
```

---

## 📊 9. **Monitoring Tools**

|Tool|Purpose|
|---|---|
|**CloudTrail**|Track access requests|
|**CloudWatch**|S3 request metrics, errors|
|**S3 Access Logs**|Detailed access logs|
|**AWS Config**|Compliance auditing|

---

## 💸 10. **Pricing Components**

|Metric|Pricing Basis|
|---|---|
|Storage|GB/month per storage class|
|Requests|PUT/GET/DELETE costs vary|
|Data transfer|Outbound to Internet costs|
|Lifecycle|Transitioning also costs|

---

## 📂 11. **Storage Classes**

|Class|Use Case|Durability|Availability|Notes|
|---|---|---|---|---|
|**Standard**|General purpose|11 9's|99.99%|Default|
|**Intelligent-Tiering**|Auto-cost optimization|11 9's|99.9–99.99%|Great for unpredictable workloads|
|**Standard-IA**|Infrequent Access|11 9's|99.9%|Cheaper, but retrieval fee|
|**Glacier**|Archival|11 9's|Variable|Retrieval: minutes to hours|
|**Glacier Deep Archive**|Long-term archiving|11 9's|Variable|Cheapest, slowest retrieval|

---

## 🧪 12. **Common CLI Commands**

```bash
# Create bucket
aws s3 mb s3://my-bucket --region us-east-1

# Upload file
aws s3 cp file.txt s3://my-bucket/

# Sync local folder
aws s3 sync ./local-folder/ s3://my-bucket/

# Enable versioning
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration Status=Enabled

# Set public read
aws s3api put-bucket-policy --bucket my-bucket --policy file://policy.json
```

---

## 📐 13. **Terraform Example**

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-old-versions"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

---

## 💡 14. **Best Practices**

✅ Enable **versioning**  
✅ Use **SSE-KMS** for encryption  
✅ Use **Block Public Access** by default  
✅ Tag buckets for billing  
✅ Set **lifecycle rules** to control costs  
✅ Use **CloudFront + S3** for CDN use case  
✅ Avoid hardcoding access — use IAM roles

---

## 🧠 15. **S3 vs EBS vs EFS**

|Feature|S3|EBS|EFS|
|---|---|---|---|
|Type|Object store|Block storage|File system|
|Access Method|HTTP(S)|EC2 mount|NFS mount|
|Use Case|Backup, archive, CDN|OS, DB storage|Shared web files|
|Max Size|Unlimited|Up to 16 TB|Unlimited|
|Multi-AZ|Yes (by design)|No (except io2)|Yes|

---
