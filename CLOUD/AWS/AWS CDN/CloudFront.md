
## 🚀 What is Amazon CloudFront?

**Amazon CloudFront** is a **Content Delivery Network (CDN)** that securely delivers data, videos, web apps, and APIs to users with **low latency and high transfer speed**.

> CloudFront caches content **at edge locations worldwide**, reducing the load on your origin (S3, EC2, ALB, etc.).

---

## 🌍 Key Components

|Component|Description|
|---|---|
|**Origin**|Where your content lives (S3, ALB, EC2, API Gateway, etc.)|
|**Edge Locations**|400+ global cache nodes near users|
|**Distribution**|The CloudFront configuration that maps requests to origins|
|**Cache Behavior**|Rules to route paths (like `/images/*` to S3, `/api/*` to ALB)|
|**OAI/OAC**|Control access to S3 (Origin Access Identity or Control)|

---

## ✅ Use Cases

|Use Case|Details|
|---|---|
|🌐 Static site hosting|Use CloudFront + S3 for fast website delivery|
|📦 Software/file distribution|Speed up downloads of large files globally|
|🧊 API Acceleration|Cache and deliver API responses|
|🎥 Video streaming|Low-latency live and VOD streaming|
|🔐 Security layer|Use WAF + Shield + SSL termination at edge|

---

## 🧠 Caching Concepts

|Term|Description|
|---|---|
|**TTL (Time to Live)**|How long content is cached at the edge (default 24h)|
|**Invalidation**|Manually clear cache for updated objects|
|**Cache Key**|What CloudFront uses to determine uniqueness (URL, query, headers, etc.)|

---

## 🔐 Security Features

|Feature|Description|
|---|---|
|**HTTPS**|Free TLS certificates with ACM|
|**Origin Access Control (OAC)**|Replaces legacy OAI to securely connect to S3|
|**AWS WAF Integration**|Protect against XSS, SQLi, and bots|
|**Geo-blocking**|Restrict content by country|
|**Signed URLs/Cookies**|Control access to private content|

---

## 🛠️ Terraform Example – CloudFront + S3 Static Site

```hcl
resource "aws_s3_bucket" "site_bucket" {
  bucket = "yuva-static-site"
  acl    = "private"
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "cf-s3-access"
  description                       = "OAC for static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "static_site" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_regional_domain_name}"
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "StaticSiteCF"
  }
}
```

---

## 📦 Invalidations (Cache Purge)

Manually remove stale objects:

```bash
aws cloudfront create-invalidation \
  --distribution-id EXAMPLEDISTID \
  --paths "/index.html"
```

> ⚠️ Limited to 1,000 free invalidations/month. Use versioning if you exceed this.

---

## 💸 Pricing Breakdown

|Cost Item|Description|
|---|---|
|Data transfer (out)|Based on region, first 1 TB/month is free|
|Requests|Charged per 10,000 HTTP/HTTPS requests|
|Invalidations|First 1,000 paths/month free|
|Field-level encryption|Additional cost|

> 📌 Check [CloudFront pricing page](https://aws.amazon.com/cloudfront/pricing/) for full details.

---

## 🧪 Advanced Features

|Feature|Description|
|---|---|
|🔐 Origin Shield|Adds a mid-tier cache layer for large scale sites|
|🔄 Lambda@Edge / Functions|Modify requests/responses at edge nodes|
|🛡️ AWS Shield & WAF|Integrated DDoS and application-layer protection|
|📊 Real-time logs|Stream access logs to Kinesis or CloudWatch|

---

## ✅ TL;DR Summary

|Feature|CloudFront CDN|
|---|---|
|What is it?|Edge-cached content delivery for S3, APIs, apps|
|SSL/TLS Support|Free via ACM|
|S3 Integration|Use with **OAC** for secure static site delivery|
|Caching|Automatic, configurable via TTL and headers|
|WAF/Shield Support|Yes (built-in)|
|Common Use Cases|Static sites, APIs, video, software downloads|
