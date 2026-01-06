
## 🔄 What are Lifecycle Rules in S3?

S3 **Lifecycle Rules** allow you to **automate management of objects** in a bucket by:

| Action                              | Description                                                 |
| ----------------------------------- | ----------------------------------------------------------- |
| **Transition**                      | Move objects to a cheaper storage class (e.g., IA, Glacier) |
| **Expiration**                      | Delete objects automatically after a set time               |
| **Noncurrent Version Expiration**   | Delete older versions of versioned objects after X days     |
| **Incomplete Multipart Expiration** | Remove failed/incomplete uploads that consume storage       |

> ✅ Lifecycle rules **reduce cost**, improve **data hygiene**, and enforce **compliance**.

---

## 🧠 Key Concepts

| Concept                      | Description                                              |
| ---------------------------- | -------------------------------------------------------- |
| **Rule**                     | Each lifecycle configuration is defined by a rule        |
| **Filter**                   | Defines which objects the rule applies to (prefix, tags) |
| **Transition**               | Move objects to other storage classes                    |
| **Expiration**               | Delete objects or old versions                           |
| **Abort Incomplete Uploads** | Cleans up incomplete multipart uploads                   |

---

## 🎯 Real-Life Use Cases

| Scenario                                   | Rule Strategy                              |
| ------------------------------------------ | ------------------------------------------ |
| Logs older than 30 days → IA, then Glacier | Use **transitions**                        |
| Delete images after 90 days                | Use **expiration**                         |
| Clean up old versions after 60 days        | Use **noncurrent version expiration**      |
| Remove incomplete uploads after 7 days     | Use **abort incomplete multipart uploads** |

---

## 📘 Example: JSON Lifecycle Policy

```json
{
  "Rules": [
    {
      "ID": "archive-logs",
      "Prefix": "logs/",
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
      ],
      "Expiration": {
        "Days": 365
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 60
      },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 7
      }
    }
  ]
}
```

---

## 🛠️ Terraform Example: S3 Lifecycle Rules

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "yuva-lifecycle-bucket"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "archive-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

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

    noncurrent_version_expiration {
      noncurrent_days = 60
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
```

---

## 📋 Terraform Options Explained

| Block                               | Purpose                                     |
| ----------------------------------- | ------------------------------------------- |
| `transition`                        | Move object to another storage class        |
| `expiration`                        | Deletes current version of object           |
| `noncurrent_version_expiration`     | Deletes older versions of versioned objects |
| `abort_incomplete_multipart_upload` | Deletes incomplete uploads after X days     |
| `filter` with `prefix` or `tags`    | Limit rule to specific objects              |

---

## 🧮 Cost Optimization Strategy (Best Practice)

| Phase      | Time            | Action                  |
| ---------- | --------------- | ----------------------- |
| 0–30 days  | Frequent access | Keep in STANDARD        |
| 30–90 days | Rare access     | Move to IA              |
| >90 days   | Archive         | Move to GLACIER         |
| >365 days  | Delete          | Auto-delete from bucket |

---

## ✅ TL;DR Cheat Sheet

| Feature                             | Use Case                                |
| ----------------------------------- | --------------------------------------- |
| `transition`                        | Move to cheaper storage (IA/Glacier)    |
| `expiration`                        | Auto-delete data                        |
| `noncurrent_version_expiration`     | Clean old versions                      |
| `abort_incomplete_multipart_upload` | Clean broken uploads                    |
| `filter`                            | Apply rules only to specific paths/tags |

---

