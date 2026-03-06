# Cloud Storage - Object Storage Service

Complete guide to Google Cloud Storage - scalable object storage.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Storage Classes](#storage-classes)
3. [Bucket Management](#bucket-management)
4. [Object Operations](#object-operations)
5. [Access Control](#access-control)
6. [Lifecycle Management](#lifecycle-management)
7. [Versioning](#versioning)
8. [Encryption](#encryption)
9. [Performance](#performance)
10. [Cost Optimization](#cost-optimization)
11. [Best Practices](#best-practices)

---

## Introduction

Cloud Storage is a scalable, durable object storage service for storing and accessing data on Google Cloud.

### Key Features

✅ Unlimited storage capacity  
✅ 99.999999999% (11 nines) durability  
✅ Multiple storage classes  
✅ Global accessibility  
✅ Versioning support  
✅ Lifecycle management  
✅ Strong consistency  
✅ Integrated with GCP services  
✅ HTTP/HTTPS access  
✅ Signed URLs  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│              Cloud Storage Bucket                   │
├─────────────────────────────────────────────────────┤
│  Objects (Immutable)                                │
│  ┌──────────────────────────────────────────────┐   │
│  │  Object: images/photo.jpg                    │   │
│  │  - Metadata                                  │   │
│  │  - Content                                   │   │
│  │  - ACL                                       │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Features:                                          │
│  - Versioning                                       │
│  - Lifecycle policies                               │
│  - Access control                                   │
│  - Encryption                                       │
└─────────────────────────────────────────────────────┘
```

---

## Storage Classes

### Standard Storage

**Best for:** Frequently accessed data

```
Characteristics:
- High availability (99.95% SLA)
- Low latency
- No minimum storage duration
- No retrieval cost
```

**Pricing (us-central1):**
- Storage: $0.020/GB/month
- Operations: $0.05/10,000 Class A, $0.004/10,000 Class B
- Network: Standard egress rates

**Use Cases:**
- Website content
- Streaming videos
- Mobile/gaming applications
- Analytics data

### Nearline Storage

**Best for:** Data accessed less than once per month

```
Characteristics:
- 99.9% availability SLA
- 30-day minimum storage duration
- Retrieval cost applies
- Lower storage cost
```

**Pricing:**
- Storage: $0.010/GB/month
- Retrieval: $0.01/GB
- Operations: Higher than Standard

**Use Cases:**
- Data backup
- Long-tail content
- Disaster recovery
- Infrequently accessed data

### Coldline Storage

**Best for:** Data accessed less than once per quarter

```
Characteristics:
- 99.9% availability SLA
- 90-day minimum storage duration
- Retrieval cost applies
- Very low storage cost
```

**Pricing:**
- Storage: $0.004/GB/month
- Retrieval: $0.02/GB
- Operations: Higher than Nearline

**Use Cases:**
- Disaster recovery
- Archival storage
- Compliance data
- Cold data backup

### Archive Storage

**Best for:** Data accessed less than once per year

```
Characteristics:
- 99.9% availability SLA
- 365-day minimum storage duration
- Retrieval cost applies
- Lowest storage cost
```

**Pricing:**
- Storage: $0.0012/GB/month
- Retrieval: $0.05/GB
- Operations: Highest cost

**Use Cases:**
- Long-term archival
- Regulatory archives
- Digital preservation
- Historical records

### Storage Class Comparison

| Class | Access Frequency | Min Duration | Storage Cost | Retrieval Cost |
|-------|-----------------|--------------|--------------|----------------|
| **Standard** | Frequent | None | $0.020/GB | None |
| **Nearline** | < 1/month | 30 days | $0.010/GB | $0.01/GB |
| **Coldline** | < 1/quarter | 90 days | $0.004/GB | $0.02/GB |
| **Archive** | < 1/year | 365 days | $0.0012/GB | $0.05/GB |

---

## Bucket Management

### Create Bucket

```bash
# Create bucket with default settings
gsutil mb gs://my-bucket

# Create bucket with location
gsutil mb -l us-central1 gs://my-bucket

# Create bucket with storage class
gsutil mb -c NEARLINE -l us-central1 gs://my-bucket

# Create bucket with uniform access
gsutil mb -b on gs://my-bucket
```

### Bucket Configuration

```bash
# Set default storage class
gsutil defstorageclass set NEARLINE gs://my-bucket

# Enable versioning
gsutil versioning set on gs://my-bucket

# Set CORS configuration
gsutil cors set cors.json gs://my-bucket

# Set website configuration
gsutil web set -m index.html -e 404.html gs://my-bucket

# Set labels
gsutil label set labels.json gs://my-bucket
```

### Terraform Example

```hcl
resource "google_storage_bucket" "default" {
  name          = "my-bucket"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access {
    enabled = true
  }
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  cors {
    origin          = ["https://example.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}
```

---

## Object Operations

### Upload Objects

```bash
# Upload single file
gsutil cp file.txt gs://my-bucket/

# Upload with metadata
gsutil -h "Content-Type:text/plain" \
  -h "Cache-Control:public, max-age=3600" \
  cp file.txt gs://my-bucket/

# Upload directory
gsutil cp -r directory/ gs://my-bucket/

# Parallel upload
gsutil -m cp -r large-directory/ gs://my-bucket/

# Upload with storage class
gsutil cp -s NEARLINE file.txt gs://my-bucket/
```

### Download Objects

```bash
# Download single file
gsutil cp gs://my-bucket/file.txt .

# Download directory
gsutil cp -r gs://my-bucket/directory/ .

# Parallel download
gsutil -m cp -r gs://my-bucket/large-directory/ .

# Download specific version
gsutil cp gs://my-bucket/file.txt#1234567890 .
```

### List Objects

```bash
# List all objects
gsutil ls gs://my-bucket/

# List with details
gsutil ls -l gs://my-bucket/

# List recursively
gsutil ls -r gs://my-bucket/

# List with versions
gsutil ls -a gs://my-bucket/
```

### Delete Objects

```bash
# Delete single object
gsutil rm gs://my-bucket/file.txt

# Delete directory
gsutil rm -r gs://my-bucket/directory/

# Delete all objects
gsutil rm gs://my-bucket/**

# Delete specific version
gsutil rm gs://my-bucket/file.txt#1234567890
```

### Python SDK Example

```python
from google.cloud import storage

# Initialize client
client = storage.Client()

# Upload file
bucket = client.bucket('my-bucket')
blob = bucket.blob('file.txt')
blob.upload_from_filename('local-file.txt')

# Set metadata
blob.metadata = {'key': 'value'}
blob.patch()

# Download file
blob.download_to_filename('downloaded-file.txt')

# List objects
blobs = bucket.list_blobs(prefix='directory/')
for blob in blobs:
    print(blob.name)

# Delete object
blob.delete()
```

---

## Access Control

### IAM Permissions

```bash
# Grant bucket access
gsutil iam ch user:user@example.com:objectViewer gs://my-bucket

# Grant object access
gsutil iam ch user:user@example.com:objectCreator gs://my-bucket

# Remove access
gsutil iam ch -d user:user@example.com:objectViewer gs://my-bucket

# View IAM policy
gsutil iam get gs://my-bucket
```

### Common IAM Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Storage Admin** | Full control | Bucket management |
| **Storage Object Admin** | Full object control | Application access |
| **Storage Object Creator** | Create objects | Upload only |
| **Storage Object Viewer** | Read objects | Download only |
| **Storage Legacy Bucket Reader** | List and read | Legacy apps |

### Signed URLs

```bash
# Generate signed URL (gsutil)
gsutil signurl -d 1h key.json gs://my-bucket/file.txt
```

**Python Example:**
```python
from google.cloud import storage
from datetime import timedelta

client = storage.Client()
bucket = client.bucket('my-bucket')
blob = bucket.blob('file.txt')

# Generate signed URL (valid for 1 hour)
url = blob.generate_signed_url(
    version='v4',
    expiration=timedelta(hours=1),
    method='GET'
)

print(url)
```

### Public Access

```bash
# Make bucket public
gsutil iam ch allUsers:objectViewer gs://my-bucket

# Make object public
gsutil acl ch -u AllUsers:R gs://my-bucket/file.txt

# Remove public access
gsutil iam ch -d allUsers:objectViewer gs://my-bucket
```

---

## Lifecycle Management

### Lifecycle Policy

**lifecycle.json:**
```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "NEARLINE"
        },
        "condition": {
          "age": 30,
          "matchesStorageClass": ["STANDARD"]
        }
      },
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "COLDLINE"
        },
        "condition": {
          "age": 90,
          "matchesStorageClass": ["NEARLINE"]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "age": 365,
          "matchesStorageClass": ["COLDLINE"]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "numNewerVersions": 3
        }
      }
    ]
  }
}
```

```bash
# Set lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-bucket

# Get lifecycle policy
gsutil lifecycle get gs://my-bucket

# Remove lifecycle policy
gsutil lifecycle set /dev/null gs://my-bucket
```

### Lifecycle Conditions

| Condition | Description |
|-----------|-------------|
| **age** | Days since creation |
| **createdBefore** | Date before which created |
| **isLive** | Live vs noncurrent versions |
| **matchesStorageClass** | Current storage class |
| **numNewerVersions** | Number of newer versions |
| **daysSinceNoncurrentTime** | Days since became noncurrent |

---

## Versioning

### Enable Versioning

```bash
# Enable versioning
gsutil versioning set on gs://my-bucket

# Check versioning status
gsutil versioning get gs://my-bucket

# Disable versioning
gsutil versioning set off gs://my-bucket
```

### Work with Versions

```bash
# List all versions
gsutil ls -a gs://my-bucket/file.txt

# Download specific version
gsutil cp gs://my-bucket/file.txt#1234567890 .

# Delete specific version
gsutil rm gs://my-bucket/file.txt#1234567890

# Restore previous version
gsutil cp gs://my-bucket/file.txt#1234567890 gs://my-bucket/file.txt
```

### Python Example

```python
from google.cloud import storage

client = storage.Client()
bucket = client.bucket('my-bucket')

# List all versions
blobs = bucket.list_blobs(prefix='file.txt', versions=True)
for blob in blobs:
    print(f'{blob.name} - Generation: {blob.generation}')

# Get specific version
blob = bucket.blob('file.txt', generation=1234567890)
content = blob.download_as_text()
```

---

## Encryption

### Encryption at Rest

**Default encryption:**
- Google-managed keys (automatic)
- No configuration needed

**Customer-managed encryption keys (CMEK):**

```bash
# Create key
gcloud kms keyrings create my-keyring --location=us-central1
gcloud kms keys create my-key \
  --location=us-central1 \
  --keyring=my-keyring \
  --purpose=encryption

# Use CMEK for bucket
gsutil kms encryption \
  -k projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key \
  gs://my-bucket
```

**Customer-supplied encryption keys (CSEK):**

```bash
# Generate key
python -c 'import base64; import os; print(base64.b64encode(os.urandom(32)).decode())'

# Upload with CSEK
gsutil -o "GSUtil:encryption_key=YOUR_KEY" \
  cp file.txt gs://my-bucket/
```

### Encryption in Transit

- All data encrypted in transit using TLS
- HTTPS endpoints by default
- No configuration needed

---

## Performance

### Upload Performance

```bash
# Parallel composite uploads
gsutil -o GSUtil:parallel_composite_upload_threshold=150M \
  cp large-file.dat gs://my-bucket/

# Parallel uploads
gsutil -m cp -r directory/ gs://my-bucket/

# Streaming uploads
cat large-file.dat | gsutil cp - gs://my-bucket/file.dat
```

### Download Performance

```bash
# Parallel downloads
gsutil -m cp -r gs://my-bucket/directory/ .

# Sliced object downloads
gsutil -o GSUtil:sliced_object_download_threshold=150M \
  cp gs://my-bucket/large-file.dat .
```

### Performance Tips

✅ Use parallel uploads/downloads (-m flag)  
✅ Use composite uploads for large files  
✅ Use Cloud CDN for frequently accessed content  
✅ Use regional buckets for better performance  
✅ Optimize object sizes (avoid very small objects)  
✅ Use appropriate storage class  
✅ Enable compression for text files  
✅ Use signed URLs to avoid authentication overhead  

---

## Cost Optimization

### Storage Costs

```bash
# Analyze storage usage
gsutil du -s gs://my-bucket/

# Check storage class distribution
gsutil ls -L -b gs://my-bucket/
```

### Optimization Strategies

✅ Use lifecycle policies to transition to cheaper classes  
✅ Delete old versions  
✅ Use appropriate storage class  
✅ Enable compression  
✅ Delete unused buckets  
✅ Use requester pays for public data  
✅ Monitor and optimize egress  
✅ Use Cloud CDN to reduce egress  

### Cost Example

**Scenario:** 1 TB data, accessed weekly

```
Standard Storage:
- Storage: 1000 GB × $0.020 = $20/month
- Operations: Minimal
- Total: ~$20/month

With Lifecycle (30 days → Nearline):
- Standard (30 days): 1000 GB × $0.020 × 1 = $20
- Nearline (11 months): 1000 GB × $0.010 × 11 = $110
- Total: $130/year = $10.83/month
- Savings: 46%
```

---

## Best Practices

### Security

✅ Use IAM for access control  
✅ Enable uniform bucket-level access  
✅ Use signed URLs for temporary access  
✅ Enable versioning for critical data  
✅ Use CMEK for sensitive data  
✅ Enable audit logging  
✅ Use VPC Service Controls  
✅ Regular access reviews  

### Performance

✅ Use regional buckets for better performance  
✅ Use Cloud CDN for static content  
✅ Enable parallel uploads/downloads  
✅ Optimize object sizes  
✅ Use appropriate storage class  
✅ Implement caching strategies  
✅ Use compression  

### Reliability

✅ Enable versioning  
✅ Use lifecycle policies  
✅ Regular backups  
✅ Test disaster recovery  
✅ Use multi-region for critical data  
✅ Monitor bucket health  
✅ Implement retry logic  

### Cost Management

✅ Use lifecycle policies  
✅ Delete old versions  
✅ Use appropriate storage class  
✅ Monitor storage usage  
✅ Use labels for cost tracking  
✅ Enable compression  
✅ Use requester pays when appropriate  

---

## Troubleshooting

### Common Issues

**Upload fails:**
```bash
# Check permissions
gsutil iam get gs://my-bucket

# Check quota
gcloud compute project-info describe --project=PROJECT_ID

# Retry with exponential backoff
gsutil -m cp -r directory/ gs://my-bucket/
```

**Slow performance:**
- Use parallel operations (-m flag)
- Check network bandwidth
- Use regional bucket
- Enable composite uploads

**Access denied:**
```bash
# Check IAM permissions
gsutil iam get gs://my-bucket

# Check bucket policy
gsutil iam ch user:user@example.com:objectViewer gs://my-bucket
```

---

## Next Steps

- **[Persistent Disk](2-Persistent-Disk.md)** - Block storage for VMs
- **[Filestore](3-Filestore.md)** - Managed NFS file storage
- **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
