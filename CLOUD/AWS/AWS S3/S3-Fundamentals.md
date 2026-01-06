
## ☁️ What is Amazon S3?

**Amazon S3** is an **object storage** service that provides industry-leading scalability, availability, durability, and security.

> ✅ Store virtually unlimited objects like files, logs, images, backups, etc., in a **bucket**, which is like a container or folder.

---

## 📦 Core Concepts

| Concept             | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| **Bucket**          | A globally unique container for objects (like a folder)         |
| **Object**          | Any file/data stored in a bucket (e.g., `.jpg`, `.pdf`, `.zip`) |
| **Key**             | The unique identifier for an object within a bucket             |
| **Region**          | Buckets are created in a specific AWS region                    |
| **Storage Classes** | Optimize cost/performance: Standard, IA, Glacier, etc.          |

---

## 🛡️ 1. Bucket Policy

A **Bucket Policy** is a **JSON-based resource policy** that controls access to a specific S3 bucket.

### 🔹 Example: Allow public read access

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::mybucket/*"
  }]
}
```

> 📛 Be careful: Public access must also be enabled (see section 3).

### 🔹 Use Cases:

- Grant access to IAM users/roles
    
- Allow CloudFront access
    
- Allow cross-account access
    
- Define conditions using IPs, user agents, etc.
    

---

## 🪪 2. ACL (Access Control List)

**ACLs** are legacy access controls that define **read/write permissions per grantee** (e.g., specific AWS account, everyone).

### 🔹 ACL Types:

- **Bucket ACL**: Controls access to the bucket
    
- **Object ACL**: Controls access to specific files
    

### 🔹 Example: Make object publicly readable

```bash
aws s3api put-object-acl --bucket mybucket --key myphoto.jpg --acl public-read
```

> ⚠️ ACLs are not recommended for fine-grained control. Use **Bucket Policies or IAM**.

---

## 🔓 3. Public Access Settings

Even if a bucket policy or ACL grants public access, **S3 Public Access Block Settings** can **override and block it**.

### 🔹 Block Public Access Options:

- Block public ACLs
    
- Block public bucket policies
    
- Block new public ACLs
    
- Ignore public ACLs
    

> 🔒 These settings are **enabled by default** for new buckets (to prevent accidental exposure).

### 🔹 Disable (CLI Example):

```bash
aws s3api put-public-access-block \
  --bucket mybucket \
  --public-access-block-configuration \
  BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false
```

---

## 🌐 4. Static Website Hosting

You can **host a static website** (HTML/CSS/JS) using Amazon S3.

### 🔹 Steps:

1. Enable static hosting:
    
    - Set index document (e.g., `index.html`)
        
    - (Optional) Set error document (e.g., `error.html`)
        
2. Make your files publicly readable (via policy or ACL)
    
3. Access via S3 website endpoint:
    
    ```
    http://<bucket-name>.s3-website-<region>.amazonaws.com
    ```
    

### 🔹 Example Static Hosting Policy:

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::mywebsitebucket/*"
  }]
}
```

> ✅ Use CloudFront for HTTPS + domain support.

---

## 🕓 5. Versioning

**Versioning** keeps **multiple versions of an object** in the same bucket.

### 🔹 Enable Versioning:

```bash
aws s3api put-bucket-versioning \
  --bucket mybucket \
  --versioning-configuration Status=Enabled
```

### 🔹 Benefits:

- Restore accidentally deleted or overwritten files
    
- Protect against ransomware/data corruption
    

### 🔹 Notes:

- Deleted objects still remain (you get a delete marker)
    
- Can be combined with **Lifecycle Policies** for cost savings
    

---

## 🔸 1. **Maximum Size of an Object in Amazon S3**

|Operation|Limit|
|---|---|
|**Single PUT upload**|**5 GB maximum**|
|**Maximum object size**|**5 TB** (via multipart upload)|

> ✅ If your file is **larger than 5 GB**, you **must use multipart upload**.

---

## 🔸 2. **What is Multipart Upload?**

**Multipart upload** lets you upload a **large object in parts** (chunks), in **parallel**, and **resume** if a part fails.

### 🧠 Why Use Multipart Upload?

- Upload files **larger than 5 GB** (up to 5 TB)
    
- Faster uploads (upload parts in parallel)
    
- Resume uploads after failure (only re-upload failed parts)
    
- Pause and resume support
    

---

## 🔸 3. **How Multipart Upload Works**

1. **Initiate upload** – Get an `uploadId`
    
2. **Upload parts** – Each part (5 MB – 5 GB) is uploaded separately
    
3. **Complete upload** – S3 assembles all parts into a single object
    

> 💡 Parts are numbered (1–10,000). So **max parts = 10,000**.

---

## 🔸 4. **Multipart Upload Size Rule**

|Object Size|Recommended Upload Method|
|---|---|
|≤ 5 GB|Single `PUT` upload|
|> 5 GB & ≤ 5 TB|Use **Multipart Upload**|
|> 5 TB|❌ Not supported in S3|

Each **part must be at least 5 MB**, **except the last part**.

---

## 🔧 Example: AWS CLI Multipart Upload

```bash
aws s3 cp largefile.zip s3://mybucket/ --storage-class STANDARD
```

> CLI will **automatically use multipart upload** for files > 8 MB.

---

## 🔚 Summary

|Feature|Value|
|---|---|
|Max object size|5 TB|
|PUT upload limit|5 GB|
|Multipart required|For > 5 GB objects|
|Part size|≥ 5 MB (last part can be less)|
|Max parts|10,000|

---
