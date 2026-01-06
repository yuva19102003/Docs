
## 📦 What is a Storage Class in S3?

An **S3 Storage Class** defines **how your data is stored**, in terms of:

- **Availability**
    
- **Durability**
    
- **Access frequency**
    
- **Cost**
    

> ✅ Storage class is set **per object**, not per bucket.

---

## 🧾 All S3 Storage Classes — Comparison Table

| Storage Class                  | Use Case                                      | Durability            | Availability | Min Storage | Retrieval Fee | Key Notes                                 |
| ------------------------------ | --------------------------------------------- | --------------------- | ------------ | ----------- | ------------- | ----------------------------------------- |
| **Standard**                   | General-purpose storage (frequently accessed) | 99.999999999% (11 9s) | 99.99%       | None        | ❌ No          | Default class                             |
| **Intelligent-Tiering**        | Unknown or variable access patterns           | 99.999999999%         | 99.9–99.99%  | 30 days     | ❌ No          | Auto-moves to lower tiers                 |
| **Standard-IA**                | Infrequent but rapid access                   | 99.999999999%         | 99.9%        | 30 days     | ✅ Yes         | 128 KB min object size                    |
| **One Zone-IA**                | Infrequent + non-critical data                | 99.999999999%         | 99.5%        | 30 days     | ✅ Yes         | Stored in one AZ only                     |
| **Glacier Instant Retrieval**  | Archival with millisecond access              | 99.999999999%         | 99.9%        | 90 days     | ✅ Yes         | Cost-efficient alternative to Standard-IA |
| **Glacier Flexible Retrieval** | Archival, access within minutes-hours         | 99.999999999%         | Varies       | 90 days     | ✅ Yes         | Cheaper, restore in 1 min – 12 hrs        |
| **Glacier Deep Archive**       | Long-term archive (tapes replacement)         | 99.999999999%         | Varies       | 180 days    | ✅ Yes         | Cheapest — restore takes 12–48 hours      |
| **Reduced Redundancy (RR)**    | ❌ Deprecated                                  | Lower                 | Lower        | —           | ❌ No          | Use only for legacy cases                 |

---

## 🧠 When to Use Each Storage Class

|Use Case|Best Class|
|---|---|
|Frequently accessed web content|**Standard**|
|User-generated content (access varies)|**Intelligent-Tiering**|
|Backups / logs accessed monthly|**Standard-IA**|
|Non-critical backup (test environments)|**One Zone-IA**|
|Compliance archives (PDFs, logs, backups)|**Glacier Deep Archive**|
|Emails or reports accessed quarterly|**Glacier Flexible Retrieval**|

---

## 🔄 Lifecycle Policy (Automatic Transition)

You can **automatically move data** between classes using lifecycle rules.

### Example: Standard → IA → Glacier

```json
{
  "Rules": [{
    "ID": "TransitionToIA",
    "Filter": { "Prefix": "" },
    "Status": "Enabled",
    "Transitions": [
      {
        "Days": 30,
        "StorageClass": "STANDARD_IA"
      },
      {
        "Days": 90,
        "StorageClass": "GLACIER"
      }
    ]
  }]
}
```

> ✅ Use this to **optimize storage cost** over time.

---

## 🧪 Terraform Example: S3 with Storage Class Lifecycle

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "yuva-storage-demo"
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.example.id

  rule {
    id     = "lifecycle-transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
```

---

## 💰 Cost Consideration Summary

|Cost Component|Applies to...|
|---|---|
|Storage cost (per GB)|Based on class (Glacier < IA < Standard)|
|PUT request|Every transition creates a PUT request|
|Retrieval cost|Glacier, IA, etc.|
|Early deletion penalty|IA/Glacier (<30/90 days)|

---

## 🔐 Encryption & Storage Class

Storage class has **no impact on encryption** — you can use:

- SSE-S3 (default)
    
- SSE-KMS
    
- SSE-C
    

---

## ✅ TL;DR Cheat Sheet

|Storage Class|When to Use|Retrieval Time|
|---|---|---|
|Standard|Frequently accessed files|Immediate|
|Intelligent-Tiering|Access pattern unknown|Immediate|
|Standard-IA|Infrequent access, high durability|Immediate|
|One Zone-IA|Non-critical backup, cheaper|Immediate|
|Glacier Instant|Fast-access archive|Milliseconds|
|Glacier Flexible|Long-term storage|1–12 hours|
|Glacier Deep Archive|Compliance/rarely used archive|12–48 hours|

---
