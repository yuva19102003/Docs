
## 🔍 What is S3 Storage Lens?

**S3 Storage Lens** is an **analytics dashboard** built into AWS that gives you **organization-wide visibility** into your S3 usage and activity.

> It helps you **analyze storage trends**, **identify cost optimization opportunities**, and **improve data protection** practices.

---

## 🧠 Why Use S3 Storage Lens?

|Benefit|Description|
|---|---|
|🔎 **Storage insights**|Track number of objects, size, versions, and growth|
|💰 **Cost optimization**|Identify infrequent access objects or non-current versions|
|🛡 **Data protection**|Find buckets without encryption, versioning, MFA delete|
|👥 **Organization-wide visibility**|View all buckets in all accounts via AWS Organizations|
|📊 **Export metrics**|Export to S3 in CSV or Parquet for detailed analysis|

---

## 📈 What Metrics Does It Show?

|Category|Key Metrics Example|
|---|---|
|**Storage**|Total storage, object count, avg object size|
|**Cost efficiency**|Current version bytes, noncurrent version bytes|
|**Data protection**|% buckets with encryption, versioning, MFA delete|
|**Activity**|PUT, GET, DELETE request counts (Advanced tier)|
|**Replication status**|Replicated bytes and failed replications|

> 🚨 Advanced metrics (including request activity) are **paid**.

---

## 🗂 Storage Lens Structure

|Term|Description|
|---|---|
|**Dashboard**|The UI-based view with visual charts|
|**Configuration**|The rules defining which buckets to monitor|
|**Scope**|AWS account, AWS Organization, or region|
|**Metrics Export**|Optional export of raw data to S3|

---

## 🔧 How to Enable Storage Lens (Console)

1. Go to **S3 → Storage Lens**
    
2. Click **Create dashboard**
    
3. Define:
    
    - Dashboard name
        
    - Scope: All buckets, or filtered (prefix/account)
        
    - Enable **metrics export** (optional)
        
    - Choose **Advanced metrics** (optional)
        

---

## 📂 Use Cases

|Goal|How Storage Lens Helps|
|---|---|
|Reduce S3 cost|Find old/stale/noncurrent data|
|Ensure security|Detect unencrypted or unversioned buckets|
|Monitor growth|View weekly/monthly usage trends|
|Audit replication|Track objects that failed to replicate|
|Optimize storage class usage|Spot frequently accessed objects in Glacier|

---

## 📄 Sample Output Metrics (CSV Export)

|Date|Bucket|TotalBytes|ObjectCount|NoncurrentBytes|Encrypted?|
|---|---|---|---|---|---|
|2025-06-14|yuva-prod-logs|5000000000|240000|70000000|Yes|
|2025-06-14|yuva-temp-assets|200000000|3000|0|No|

---

## 🛠️ Terraform Example – Enable S3 Storage Lens

```hcl
resource "aws_s3control_storage_lens_configuration" "lens" {
  config_id = "yuva-storage-lens"

  storage_lens_configuration {
    enabled = true
    id      = "yuva-storage-lens"

    account_level {
      activity_metrics {
        is_enabled = true
      }
      bucket_level {
        activity_metrics {
          is_enabled = true
        }
        prefix_level {
          storage_metrics {
            is_enabled = true
          }
        }
      }
    }

    data_export {
      cloud_watch_metrics {
        is_enabled = true
      }
      s3_bucket_destination {
        account_id = "123456789012"
        arn        = "arn:aws:s3:::yuva-storage-lens-reports"
        format     = "CSV"
        output_schema_version = "V_1"
        prefix     = "lens-reports/"
      }
    }

    aws_org {
      arn = "arn:aws:organizations::123456789012:organization/o-exampleorgid"
    }
  }
}
```

---

## 💰 Pricing

|Feature|Cost|
|---|---|
|Basic metrics|✅ Free|
|Advanced metrics|$0.20 per million objects/month|
|CloudWatch metrics export|Standard CloudWatch pricing applies|
|CSV export to S3|Standard S3 PUT/GET charges apply|

---

## ✅ TL;DR Summary

|Feature|Value|
|---|---|
|What is it?|Org-wide dashboard for S3 usage analytics|
|Free version?|Yes, with basic metrics only|
|Use cases|Cost reduction, governance, compliance|
|Export options|CSV to S3, or CloudWatch dashboard|
|Terraform support|Yes, via `aws_s3control_storage_lens_configuration`|
