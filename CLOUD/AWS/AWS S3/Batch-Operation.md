
## 📦 What is S3 Batch Operation?

**Amazon S3 Batch Operations** allow you to perform **bulk actions on many S3 objects** (from thousands to billions) using a **single job**.

> Instead of writing a loop or running manual scripts, Batch Operations let you:
> 
> - Copy
>     
> - Delete
>     
> - Restore
>     
> - Modify tags
>     
> - Modify ACLs
>     
> - Invoke Lambda on each object
>     

---

## 🎯 Real-World Use Cases

|Use Case|Operation Type|
|---|---|
|Migrate objects to a new bucket|Copy|
|Remove outdated data|Delete|
|Restore objects from Glacier|Restore|
|Tag archived objects for compliance|Set Object Tags|
|Apply new ACL or permissions|Set Object ACLs|
|Run virus scan or compression using Lambda|Invoke Lambda|
|Trigger **Replication** on existing objects|Batch Replication|

---

## 🧠 How It Works

1. **Create a manifest file** – A CSV or JSON list of objects you want to operate on.
    
2. **Define job settings** – What operation to run (e.g., copy, delete, lambda)
    
3. **Choose IAM role** – Used to execute actions on your behalf
    
4. **Submit the job** – AWS will run it **asynchronously**
    
5. **Monitor status** – Track progress and logs via AWS Console or CloudWatch
    

---

## 📘 Sample Manifest File (CSV Format)

```csv
bucket,key
my-source-bucket,images/photo1.jpg
my-source-bucket,images/photo2.jpg
```

- Stored in an **S3 bucket**
    
- Must be in the same region as the job
    

---

## ✅ Supported Operations

|Operation|Description|
|---|---|
|**Copy**|Copy objects to new bucket/prefix|
|**Delete**|Delete selected objects|
|**Set Object Tags**|Add/update tags|
|**Set Object ACLs**|Change object-level permissions|
|**Restore**|Restore Glacier/Deep Archive objects|
|**Lambda Invoke**|Custom logic per object (e.g., scan, resize)|
|**Batch Replication**|Replicate pre-existing objects|

---

## 🔐 IAM Role Requirements

The execution role must include permissions like:

```json
{
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject"
  ],
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```

Also needs:

```json
"iam:PassRole" and "s3:CreateJob"
```

---

## 🛠️ Terraform Example – Batch Operation to **Delete Objects**

```hcl
resource "aws_s3control_batch_job" "delete_job" {
  account_id          = "123456789012"
  manifest {
    format = "S3BatchOperations_CSV_20180820"
    location {
      bucket = "arn:aws:s3:::my-batch-manifests"
      key    = "manifests/delete-list.csv"
    }
  }

  operation {
    s3_delete_object {}
  }

  report {
    bucket         = "arn:aws:s3:::my-batch-reports"
    format         = "Report_CSV_20180820"
    enabled        = true
    prefix         = "batch-reports/"
    report_scope   = "AllTasks"
  }

  priority       = 10
  role_arn       = "arn:aws:iam::123456789012:role/S3BatchOpsExecutionRole"
  job_status     = "Active"
}
```

---

## 🧾 Pricing

|Item|Cost|
|---|---|
|Batch Job Fee|**$0.25 per 1,000 operations**|
|Lambda Invocation|Standard Lambda pricing applies|
|S3 PUT/GET/Delete|Billed per usual rates|
|Glacier Restore|Extra cost for retrieval + batch fees|

---

## 📋 Monitoring & Reporting

|Tool|Purpose|
|---|---|
|**CloudWatch**|View job status, failures, duration|
|**Reports**|CSV of success/failure per object|
|**AWS Console**|Visualize job progress|

---

## ⚠️ Limitations

|Limitation|Detail|
|---|---|
|Manifest must be in S3|Cannot upload from local|
|Region-locked|Must run in the same region as the manifest|
|Not real-time|Jobs run asynchronously|
|Size limit|1,000,000,000 objects max per job|

---

## ✅ TL;DR Summary

|Feature|Description|
|---|---|
|What is it?|Bulk processing of S3 objects via a job|
|Key operations|Copy, Delete, Restore, Tag, Lambda|
|Manifest file|List of S3 objects (CSV or JSON)|
|Job control|IAM role executes the batch actions|
|Use cases|Migration, cleanup, tagging, replication|
|Cost|$0.25 per 1,000 operations + usage fees|

---

## 📂 Example Use Case: Replicate Existing Objects

Want to replicate files uploaded **before replication rules** were added? Use:

1. S3 Inventory → to generate list
    
2. S3 Batch Job → with `Replication` operation
    

---
