# 8️⃣ Storage - Overview

Learn how data is stored on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Storage Types](#storage-types)
3. [Storage Services Comparison](#storage-services-comparison)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Comparison](#cost-comparison)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP offers multiple storage options for different use cases, from object storage to block storage and file systems.

### Storage Spectrum

```
Object Storage          Block Storage         File Storage
     |                       |                      |
     v                       v                      v
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Cloud     │      │ Persistent  │      │  Filestore  │
│   Storage   │      │    Disk     │      │   (NFS)     │
│  (Buckets)  │      │  (Volumes)  │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
```

---

## Storage Types

### 1. Object Storage

**Cloud Storage - Scalable object storage**

```
┌─────────────────────────────────────┐
│        Cloud Storage Bucket         │
├─────────────────────────────────────┤
│  Objects (files)                    │
│  - images/photo.jpg                 │
│  - videos/movie.mp4                 │
│  - backups/db-backup.sql            │
│  - logs/app-2026-03-05.log          │
└─────────────────────────────────────┘
```

**Characteristics:**
- Unlimited storage capacity
- HTTP/HTTPS access
- Global accessibility
- Versioning support
- Lifecycle management
- Multiple storage classes

**Use Cases:**
- Static website hosting
- Media storage and delivery
- Backup and archival
- Data lakes
- Application assets

### 2. Block Storage

**Persistent Disk - Block storage for VMs**

```
┌─────────────────────────────────────┐
│      Compute Engine Instance        │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │  Boot Disk (pd-standard)     │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  Data Disk (pd-ssd)          │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  Local SSD (temporary)       │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Characteristics:**
- Attached to VM instances
- Block-level access
- Persistent or ephemeral
- Snapshots support
- Multiple disk types
- Up to 64 TB per disk

**Use Cases:**
- VM boot disks
- Database storage
- Application data
- High-performance workloads

### 3. File Storage

**Filestore - Managed NFS file storage**

```
┌─────────────────────────────────────┐
│         Filestore Instance          │
├─────────────────────────────────────┤
│  NFS Share: /vol1                   │
│  - Mounted on multiple VMs          │
│  - Shared file access               │
│  - POSIX compliant                  │
└─────────────────────────────────────┘
         |           |           |
         v           v           v
    ┌──────┐    ┌──────┐    ┌──────┐
    │ VM 1 │    │ VM 2 │    │ VM 3 │
    └──────┘    └──────┘    └──────┘
```

**Characteristics:**
- NFS protocol
- Shared file system
- POSIX compliant
- High performance
- Multiple tiers
- Automatic backups

**Use Cases:**
- Shared application data
- Content management
- Media rendering
- Home directories
- Legacy applications

---

## Storage Services Comparison

### Feature Matrix

| Feature | Cloud Storage | Persistent Disk | Filestore |
|---------|--------------|-----------------|-----------|
| **Type** | Object | Block | File (NFS) |
| **Access** | HTTP/API | Block device | NFS mount |
| **Capacity** | Unlimited | 64 TB/disk | 100 TB/instance |
| **Sharing** | Public/Private | Single VM | Multiple VMs |
| **Performance** | Variable | High | Very High |
| **Durability** | 99.999999999% | 99.9999% | 99.99% |
| **Pricing** | Per GB stored | Per GB provisioned | Per GB provisioned |
| **Use Case** | Unstructured data | VM storage | Shared files |

### Performance Comparison

| Storage Type | Throughput | IOPS | Latency |
|--------------|-----------|------|---------|
| **Cloud Storage** | 5 Gbps/bucket | N/A | 10-100ms |
| **pd-standard** | 240 MB/s | 7,500 | 5-10ms |
| **pd-balanced** | 480 MB/s | 15,000 | 1-5ms |
| **pd-ssd** | 960 MB/s | 100,000 | <1ms |
| **pd-extreme** | 4,800 MB/s | 160,000 | <1ms |
| **Local SSD** | 9,600 MB/s | 680,000 | <1ms |
| **Filestore Basic** | 180 MB/s | 60,000 | <1ms |
| **Filestore High Scale** | 1,200 MB/s | 100,000 | <1ms |

---

## Decision Framework

### Decision Tree

```
What type of data?
    |
    ├─> Unstructured (files, media, backups)
    |   └─> Cloud Storage
    |
    ├─> Structured (database, application)
    |   ├─> Single VM access?
    |   │   └─> Persistent Disk
    |   └─> Multiple VM access?
    |       └─> Filestore
    |
    └─> Temporary/Cache
        └─> Local SSD
```

### Use Case Matrix

| Requirement | Recommended | Alternative |
|-------------|-------------|-------------|
| **Static website** | Cloud Storage | Cloud CDN + Storage |
| **VM boot disk** | Persistent Disk | - |
| **Database storage** | Persistent Disk (SSD) | Local SSD |
| **Shared files** | Filestore | Cloud Storage |
| **Backup/Archive** | Cloud Storage | - |
| **Media streaming** | Cloud Storage + CDN | - |
| **Big data** | Cloud Storage | - |
| **Container storage** | Persistent Disk | Filestore |
| **High IOPS** | Local SSD | pd-extreme |
| **Multi-region** | Cloud Storage | - |

---

## Architecture Patterns

### Pattern 1: Web Application with Media

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer           │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌────────┐   ┌────────┐
│ VM 1   │   │ VM 2   │
│ + PD   │   │ + PD   │
└────┬───┘   └───┬────┘
     |           |
     └─────┬─────┘
           v
    ┌──────────────┐
    │  Cloud SQL   │
    │  + PD        │
    └──────────────┘

Static Assets:
┌──────────────┐      ┌──────────────┐
│  Cloud       │─────>│  Cloud CDN   │
│  Storage     │      └──────────────┘
└──────────────┘
```

### Pattern 2: Shared File System

```
┌─────────────────────────────────────┐
│         Filestore Instance          │
│         /shared-data                │
└──────────────┬──────────────────────┘
               |
    ┌──────────┼──────────┐
    v          v          v
┌──────┐   ┌──────┐   ┌──────┐
│ VM 1 │   │ VM 2 │   │ VM 3 │
│ App  │   │ App  │   │ App  │
└──────┘   └──────┘   └──────┘
```

### Pattern 3: Data Lake Architecture

```
Data Sources
    |
    v
┌─────────────────────┐
│  Cloud Storage      │
│  (Data Lake)        │
├─────────────────────┤
│  /raw/              │
│  /processed/        │
│  /curated/          │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌──────────┐  ┌──────────┐
│ BigQuery │  │ Dataflow │
└──────────┘  └──────────┘
```

### Pattern 4: Backup and DR

```
Production
┌──────────────┐
│  Compute     │
│  + PD        │
└──────┬───────┘
       |
       v (Snapshots)
┌──────────────┐
│  Snapshots   │
│  (Regional)  │
└──────┬───────┘
       |
       v (Export)
┌──────────────┐
│  Cloud       │
│  Storage     │
│  (Archive)   │
└──────────────┘
```

### Pattern 5: High Performance Computing

```
┌─────────────────────────────────────┐
│      Compute Engine Instances       │
├─────────────────────────────────────┤
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │ VM 1 │  │ VM 2 │  │ VM 3 │      │
│  │+SSD  │  │+SSD  │  │+SSD  │      │
│  └──┬───┘  └──┬───┘  └──┬───┘      │
└─────┼─────────┼─────────┼───────────┘
      |         |         |
      └─────────┼─────────┘
                v
        ┌──────────────┐
        │  Filestore   │
        │  High Scale  │
        └──────────────┘
```

---

## Cost Comparison

### Monthly Cost Examples (us-central1)

**Scenario 1: 1 TB Storage**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **Cloud Storage** | Standard class | $20 |
| **Cloud Storage** | Nearline class | $10 |
| **Cloud Storage** | Coldline class | $4 |
| **Cloud Storage** | Archive class | $1.20 |
| **Persistent Disk** | pd-standard | $40 |
| **Persistent Disk** | pd-balanced | $100 |
| **Persistent Disk** | pd-ssd | $170 |
| **Filestore** | Basic HDD | $200 |
| **Filestore** | Basic SSD | $300 |

**Scenario 2: Database Storage (500 GB, High IOPS)**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **pd-ssd** | 500 GB | $85 |
| **pd-extreme** | 500 GB + IOPS | $125+ |
| **Local SSD** | 375 GB × 2 | $160 |

**Scenario 3: Shared File System (2 TB)**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **Filestore Basic** | 2 TB HDD | $400 |
| **Filestore High Scale** | 2 TB SSD | $1,200 |
| **Cloud Storage** | 2 TB (not NFS) | $40 |

### Cost Optimization Strategies

**Cloud Storage:**
- Use appropriate storage class
- Enable lifecycle management
- Use Coldline/Archive for infrequent access
- Enable compression
- Use requester pays for public data

**Persistent Disk:**
- Right-size disk capacity
- Use pd-balanced instead of pd-ssd when possible
- Delete unused disks
- Use snapshots for backups (cheaper)
- Use committed use discounts

**Filestore:**
- Choose appropriate tier
- Right-size capacity
- Use Basic tier when possible
- Schedule backups efficiently
- Delete unused instances

---

## Quick Reference

### Cloud Storage

```bash
# Create bucket
gsutil mb -l us-central1 gs://my-bucket

# Upload file
gsutil cp file.txt gs://my-bucket/

# Download file
gsutil cp gs://my-bucket/file.txt .

# List objects
gsutil ls gs://my-bucket/

# Set lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-bucket/
```

### Persistent Disk

```bash
# Create disk
gcloud compute disks create my-disk \
  --size=100GB \
  --type=pd-ssd \
  --zone=us-central1-a

# Attach to VM
gcloud compute instances attach-disk my-vm \
  --disk=my-disk \
  --zone=us-central1-a

# Create snapshot
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a
```

### Filestore

```bash
# Create instance
gcloud filestore instances create my-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default

# Mount on VM
sudo mount -t nfs FILESTORE_IP:/vol1 /mnt/filestore
```

---

## Storage Limits

### Cloud Storage

| Resource | Limit |
|----------|-------|
| Bucket name length | 3-63 characters |
| Object size | 5 TB |
| Buckets per project | 10,000 (soft) |
| Objects per bucket | Unlimited |
| Upload bandwidth | 5 Gbps |

### Persistent Disk

| Resource | Limit |
|----------|-------|
| Disk size | 64 TB |
| Disks per VM | 128 |
| Total disk capacity per VM | 257 TB |
| Snapshots per disk | Unlimited |
| Local SSD per VM | 9 TB (24 × 375 GB) |

### Filestore

| Resource | Limit |
|----------|-------|
| Instance capacity | 1 TB - 100 TB |
| Instances per project | 10 (soft) |
| Shares per instance | 1 |
| Throughput (Basic) | 180 MB/s |
| Throughput (High Scale) | 1,200 MB/s |

---

## Best Practices

### General

✅ Choose the right storage type for your use case  
✅ Use appropriate storage class/tier  
✅ Implement lifecycle management  
✅ Enable versioning for critical data  
✅ Regular backups and snapshots  
✅ Monitor storage usage and costs  
✅ Use encryption at rest  
✅ Implement access controls  
✅ Tag resources for cost tracking  
✅ Test disaster recovery procedures  

### Performance

✅ Use SSD for high IOPS workloads  
✅ Use Local SSD for temporary high-performance needs  
✅ Use Cloud CDN with Cloud Storage  
✅ Implement caching strategies  
✅ Use parallel uploads/downloads  
✅ Optimize object sizes  
✅ Use regional storage for better performance  
✅ Monitor and optimize IOPS  

### Security

✅ Use IAM for access control  
✅ Enable encryption at rest  
✅ Use customer-managed encryption keys (CMEK)  
✅ Implement bucket policies  
✅ Use signed URLs for temporary access  
✅ Enable audit logging  
✅ Use VPC Service Controls  
✅ Regular security audits  

### Cost Optimization

✅ Use lifecycle policies  
✅ Delete unused resources  
✅ Use appropriate storage classes  
✅ Use committed use discounts  
✅ Monitor and optimize costs  
✅ Use compression  
✅ Right-size storage capacity  
✅ Use snapshots instead of full copies  

---

## Next Steps

1. **[Cloud Storage](1-Cloud-Storage.md)** - Object storage service
2. **[Persistent Disk](2-Persistent-Disk.md)** - Block storage for VMs
3. **[Filestore](3-Filestore.md)** - Managed NFS file storage
4. **[Storage Comparison](4-Storage-Comparison.md)** - Detailed comparison
5. **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Persistent Disk Documentation](https://cloud.google.com/compute/docs/disks)
- [Filestore Documentation](https://cloud.google.com/filestore/docs)
- [Storage Pricing](https://cloud.google.com/storage/pricing)
- [Storage Best Practices](https://cloud.google.com/storage/docs/best-practices)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
