
## 🎯 1. What is an **S3 Access Point**?

An **S3 Access Point** is a **customized entry point** to an S3 bucket that:

- Has its **own DNS name**
    
- Can restrict access by **VPC**, **IAM policy**, or **prefix**
    
- Simplifies managing permissions at scale
    

> Instead of managing complex bucket policies for all users, you create **one access point per application or team**.

---

### ✅ Why Use Access Points?

|Benefit|Description|
|---|---|
|🔐 Fine-grained control|Limit access to specific prefixes or objects|
|🛡️ Scoped by VPC|Restrict access to **only from within a VPC**|
|🚀 Multiple entry points|Serve different teams/apps with different policies|
|🌍 Unique DNS per point|Like: `my-ap-123.s3-accesspoint.region.amazonaws.com`|

---

### 🛠️ Terraform Example – S3 Access Point

```hcl
resource "aws_s3_bucket" "yuva_bucket" {
  bucket = "yuva-access-point-demo"
}

resource "aws_s3_access_point" "my_ap" {
  name   = "app-read-only"
  bucket = aws_s3_bucket.yuva_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.yuva_bucket.arn}/readonly/*"
      }
    ]
  })
}
```

> 🔎 Access points **do not change the bucket** — they’re just controlled lenses for how it's accessed.

---

## 🧠 Key Properties of Access Points

|Feature|Value|
|---|---|
|Name|Unique within AWS account and region|
|Policy|Attached directly to the access point|
|VPC Restrictions|Limit access only to a specified VPC|
|DNS Name|Used to address objects (not the bucket URL)|

---

## 🌟 2. What is **S3 Object Lambda**?

**S3 Object Lambda** allows you to **modify S3 object data on the fly** before it’s returned to the application — using a Lambda function.

> You intercept a GET request, process the object (e.g., redact, format, compress), and return the transformed version — **without storing a copy**.

---

### ✅ Use Cases for Object Lambda

|Use Case|Description|
|---|---|
|🕵️‍♂️ Redact sensitive info|Mask PII in logs or documents|
|🗜️ Compress data on-the-fly|Zip large files before download|
|🧪 JSON filter/transformation|Filter JSON keys based on user roles|
|🌐 Localization|Modify content based on language/country|

---

## 🔧 How Object Lambda Works

1. Create a standard S3 Access Point.
    
2. Create an Object Lambda Access Point that **wraps** it.
    
3. Attach a Lambda function that transforms the object.
    
4. Your app calls the Object Lambda endpoint → Lambda transforms → Object returned.
    

---

### 🔄 Example Flow

```
Application → Object Lambda Access Point → Lambda → S3 Object → Response
```

---

### 🛠️ Terraform – Object Lambda + Lambda Integration

```hcl
# 1. Lambda function
resource "aws_lambda_function" "redact_lambda" {
  filename      = "lambda.zip"
  function_name = "redact-response"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
}

# 2. Supporting Access Point
resource "aws_s3_access_point" "supporting_ap" {
  bucket = aws_s3_bucket.yuva_bucket.id
  name   = "base-access"
}

# 3. Object Lambda Access Point
resource "aws_s3control_object_lambda_access_point" "olap" {
  name       = "redact-object"
  account_id = "123456789012"

  configuration {
    supporting_access_point = aws_s3_access_point.supporting_ap.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = aws_lambda_function.redact_lambda.arn
        }
      }
    }
  }
}
```

> 📝 Your Lambda must return transformed object content as `application/octet-stream` or JSON.

---

## 🛡️ Security and IAM

You can restrict access to Object Lambda endpoints via:

- IAM policies
    
- VPC endpoint restrictions
    
- Bucket-level permissions (via access points)
    

---

## ⚠️ Limitations

|Feature|Limitation|
|---|---|
|Only GET requests supported|No PUT, DELETE, or LIST|
|Max Lambda response = 6MB|Best for JSON, text, or small binary|
|Extra latency|Due to Lambda invocation and transformation|
|Only one Lambda per OLAP|You cannot use multiple functions|

---

## ✅ TL;DR Summary

|Feature|S3 Access Point|S3 Object Lambda|
|---|---|---|
|Use Case|Scoped access to bucket|On-the-fly object transformation|
|VPC Integration|✅ Yes|✅ Yes (via Lambda VPC)|
|Custom DNS Name|✅ Yes|✅ Yes|
|IAM Policies|Applied per access point|Lambda + Access Point based|
|Operations Supported|GET, PUT, etc.|Only `GETObject`|
|Data Transforms|❌ No|✅ Yes (via Lambda)|

---
