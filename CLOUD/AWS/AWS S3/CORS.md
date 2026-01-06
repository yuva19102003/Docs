
## 🌐 What is CORS?

**CORS** (Cross-Origin Resource Sharing) is a browser security feature that **controls access to resources** (like images, fonts, JSON) across different domains.

> Without CORS, your frontend (e.g. `example.com`) **cannot access S3** (e.g. `s3.amazonaws.com`) if they’re on different origins.

---

## 💡 Why Use CORS in S3?

|Use Case|Example|
|---|---|
|Frontend uploads to S3 via JavaScript|A React app uploads user photos to an S3 bucket|
|Frontend reads files (PDF, JSON, images)|A Vue app reads images or JSON from S3|
|Pre-signed URLs used in browser|Allow direct file access without exposing the bucket|
|Static website hosting (e.g., fonts, CSS)|Serving cross-origin assets like fonts from S3|

---

## 🧠 Key CORS Concepts

|Element|Purpose|
|---|---|
|`AllowedOrigins`|Which domains can make requests (`https://example.com`)|
|`AllowedMethods`|HTTP methods allowed (GET, PUT, POST, etc.)|
|`AllowedHeaders`|Headers browsers are allowed to send (e.g., `Content-Type`)|
|`ExposeHeaders`|Response headers that browsers can access (e.g., `ETag`)|
|`MaxAgeSeconds`|How long the CORS response is cached by the browser|

---

## 🧾 Sample CORS Configuration (JSON)

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "POST", "PUT"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```

> ⚠️ `*` for `AllowedOrigins` is fine for public buckets, but **not secure** for private uploads.

---

## 🔧 How to Add CORS (AWS Console)

1. Go to **S3 → Bucket → Permissions tab**
    
2. Scroll to **CORS configuration**
    
3. Paste your JSON and **Save**
    

---

## 🛠️ Terraform Example – CORS on Bucket

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "yuva-cors-demo"
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://example.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
```

---

## 📁 Example Use Cases

### ✅ Allow file upload from browser:

```json
"AllowedOrigins": ["https://app.mysite.com"],
"AllowedMethods": ["PUT", "POST"],
"AllowedHeaders": ["Content-Type", "Authorization"]
```

### ✅ Publicly host assets for frontend:

```json
"AllowedOrigins": ["*"],
"AllowedMethods": ["GET"]
```

---

## 🚨 Common CORS Errors

|Error Message|Likely Cause|
|---|---|
|`No 'Access-Control-Allow-Origin' header`|CORS not configured or origin mismatch|
|`Method not allowed by Access-Control-Allow-Methods`|Method like PUT not allowed|
|`CORS preflight failed`|Missing response to OPTIONS request|

---

## 🔐 Security Best Practices

- ✅ Avoid `*` for `AllowedOrigins` unless public
    
- ✅ Limit to only required `AllowedMethods`
    
- ✅ Don’t allow `PUT` or `POST` unless necessary
    
- ✅ Use pre-signed URLs for private access with tighter control
    

---

## ✅ TL;DR Cheat Sheet

|Field|Meaning|Example|
|---|---|---|
|`AllowedOrigins`|Who can access|`["https://myapp.com"]`|
|`AllowedMethods`|What HTTP methods to allow|`["GET", "POST"]`|
|`AllowedHeaders`|What headers client can send|`["Authorization", "Content-Type"]`|
|`ExposeHeaders`|What headers can be read by browser|`["ETag", "x-amz-meta-*"]`|
|`MaxAgeSeconds`|Cache duration of CORS response (in sec)|`3000`|

---
