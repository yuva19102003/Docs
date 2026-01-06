
## 🔗 What is a Pre-Signed URL?

A **Pre-Signed URL** is a **temporary, secure URL** that grants time-limited access to an S3 object **without requiring AWS credentials**.

> ✅ Great for sharing private files, user uploads, and limited-time downloads.

---

## 🧠 How It Works

When you generate a pre-signed URL, you:

- Specify:
    
    - S3 bucket and object
        
    - Operation (`GET`, `PUT`, or `DELETE`)
        
    - Expiration time (in seconds)
        
- Use your **IAM credentials** to sign the URL
    
- The recipient can then **perform the operation** with that URL until it expires
    

---

## 🎯 Use Cases

|Use Case|Method|Purpose|
|---|---|---|
|Share a private file (download)|`GET`|Allow a user to download a file|
|Allow users to upload content|`PUT`|Let a frontend upload files directly|
|Secure temporary delete access|`DELETE`|Time-bound deletion of files|
|Upload via API securely|`PUT`|Avoid exposing AWS credentials|

---

## 🛠️ AWS CLI Example (GET)

Generate a pre-signed URL to **download** a file (valid for 1 hour):

```bash
aws s3 presign s3://yuva-demo-bucket/myfile.pdf --expires-in 3600
```

> Output:

```
https://yuva-demo-bucket.s3.amazonaws.com/myfile.pdf?X-Amz-Algorithm=...
```

---

## 🛠️ Python (Boto3) – Generate URL for Upload (`PUT`)

```python
import boto3

s3 = boto3.client("s3")

url = s3.generate_presigned_url(
    "put_object",
    Params={
        "Bucket": "yuva-demo-bucket",
        "Key": "uploads/image.jpg",
        "ContentType": "image/jpeg"
    },
    ExpiresIn=3600
)

print("Upload URL:", url)
```

> ✅ Frontend can then upload directly with:

```http
PUT {url}
Content-Type: image/jpeg
<body>
```

---

## 🛠️ Python (Boto3) – Generate URL for Download (`GET`)

```python
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": "yuva-demo-bucket", "Key": "files/report.pdf"},
    ExpiresIn=600
)
print("Download URL:", url)
```

---

## 🔐 Security Best Practices

|Practice|Why|
|---|---|
|⏱ Use short expiry times|Prevent reuse and limit exposure|
|🔑 Use IAM policies to restrict|Prevent unauthorized signing of URLs|
|🛑 Never use with public buckets|Public buckets don’t need signed URLs|
|✅ Limit to allowed HTTP methods|Don’t allow `PUT` if only `GET` is needed|

---

## 📘 Terraform + Lambda Pattern (for dynamic signing)

Terraform doesn’t directly generate pre-signed URLs (that’s runtime), but you can:

- Deploy a **Lambda** to generate pre-signed URLs
    
- Call the Lambda from your app (Node.js/Python)
    

Example Node.js snippet inside Lambda:

```javascript
const AWS = require("aws-sdk");
const s3 = new AWS.S3();

exports.handler = async (event) => {
  const url = s3.getSignedUrl("getObject", {
    Bucket: "yuva-demo-bucket",
    Key: "private/data.txt",
    Expires: 900, // 15 minutes
  });

  return {
    statusCode: 200,
    body: JSON.stringify({ url }),
  };
};
```

---

## ✅ TL;DR Cheat Sheet

|Field|Description|
|---|---|
|Operation|`GET`, `PUT`, `DELETE`|
|Expiration|1–604800 seconds (max 7 days for SDK)|
|Auth Required|Only to **generate** the URL|
|URL Usage|Anonymous users can access using the link|
|IAM Role Needed|Must allow `s3:GetObject` or `s3:PutObject`|

---

## 📁 IAM Policy Example (for pre-signed use)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3GetObject",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::yuva-demo-bucket/*"
    }
  ]
}
```

---
