# Storage Services - Detailed Comparison

Comprehensive comparison of all GCP storage options to help you choose the right service.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Feature Comparison](#feature-comparison)
3. [Use Case Matrix](#use-case-matrix)
4. [Performance Comparison](#performance-comparison)
5. [Cost Comparison](#cost-comparison)
6. [Migration Paths](#migration-paths)
7. [Decision Framework](#decision-framework)

---

## Overview

### Storage Services Summary

| Service | Type | Access Method | Best For |
|---------|------|---------------|----------|
| **Cloud Storage** | Object | HTTP/API | Unstructured data, backups |
| **Persistent Disk** | Block | Block device | VM storage, databases |
| **Filestore** | File (NFS) | NFS mount | Shared files, legacy apps |
| **Local SSD** | Block | Block device | Temporary high-performance |

---

## Feature Comparison

### Core Features

| Feature | Cloud Storage | Persistent Disk | Filestore | Local SSD |
|---------|--------------|-----------------|-----------|-----------|
| **Storage Type** | Object | Block | File (NFS) | Block |
| **Max Capacity** | Unlimited | 64 TB/disk | 100 TB/instance | 9 TB/VM |
| **Durability** | 99.999999999% | 99.9999% | 99.99% | None |
| **Availability** | 99.95% | 99.99% | 99.9% | VM dependent |
| **Sharing** | Public/Private | Single VM | Multiple VMs | Single VM |
| **Persistence** | Yes | Yes | Yes | No |
| **Snapshots** | Versioning | Yes | Backups | No |
| **Encryption** | Yes | Yes | Yes | Yes |

### Access Patterns

| Feature | Cloud Storage | Persistent Disk | Filestore | Local SSD |
|---------|--------------|-----------------|-----------|-----------|
| **Protocol** | HTTP/HTTPS | Block I/O | NFS | Block I/O |
| **API** | REST/gRPC | N/A | NFS | N/A |
| **CLI** | gsutil | gcloud | mount | N/A |
| **SDK** | Multiple | Multiple | NFS client | N/A |
| **Console** | Yes | Yes | Yes | Yes |
| **Terraform** | Yes | Yes | Yes | Yes |

### Performance Characteristics

| Feature | Cloud Storage | Persistent Disk | Filestore | Local SSD |
|---------|--------------|-----------------|-----------|-----------|
| **Latency** | 10-100ms | <1ms | <1ms | <1ms |
| **Throughput** | 5 Gbps/bucket | Up to 4,800 MB/s | Up to 1,200 MB/s | Up to 9,600 MB/s |
| **IOPS** | N/A | Up to 160,000 | Up to 100,000 | Up to 680,000 |
| **Consistency** | Strong | Strong | Strong | Strong |
| **Caching** | CDN | OS cache | NFS cache | N/A |

### Data Management

| Feature | Cloud Storage | Persistent Disk | Filestore | Local SSD |
|---------|--------------|-----------------|-----------|-----------|
| **Versioning** | Yes | Via snapshots | Via backups | No |
| **Lifecycle** | Yes | Manual | Manual | N/A |
| **Replication** | Multi-region | Regional PD | Enterprise tier | No |
| **Backup** | Versioning | Snapshots | Backups | Manual |
| **Restore** | Version restore | Snapshot restore | Backup restore | N/A |

### Cost Structure

| Feature | Cloud Storage | Persistent Disk | Filestore | Local SSD |
|---------|--------------|-----------------|-----------|-----------|
| **Pricing Model** | Per GB stored | Per GB provisioned | Per GB provisioned | Per GB provisioned |
| **Storage Classes** | 4 classes | 4 types | 4 tiers | 1 type |
| **Operations Cost** | Yes | No | No | No |
| **Egress Cost** | Yes | No | No | No |
| **Minimum Duration** | Varies by class | None | None | None |

---

## Use Case Matrix

### Application Workloads

| Workload | Recommended | Alternative | Why |
|----------|-------------|-------------|-----|
| **Web application** | Cloud Storage + PD | Filestore | Static assets in Storage, app data on PD |
| **Database** | Persistent Disk (SSD) | Local SSD | Persistent, high IOPS |
| **File sharing** | Filestore | Cloud Storage | NFS protocol, shared access |
| **Backup/Archive** | Cloud Storage | Persistent Disk | Cost-effective, unlimited capacity |
| **Media streaming** | Cloud Storage + CDN | - | Global distribution, CDN integration |
| **Analytics** | Cloud Storage | Persistent Disk | Data lake, BigQuery integration |
| **Container storage** | Persistent Disk | Filestore | Block storage for containers |
| **Temporary data** | Local SSD | Persistent Disk | Highest performance, ephemeral |

### Data Characteristics

| Data Type | Recommended | Alternative | Why |
|-----------|-------------|-------------|-----|
| **Unstructured** | Cloud Storage | - | Object storage, unlimited capacity |
| **Structured** | Persistent Disk | - | Block storage for databases |
| **Shared files** | Filestore | Cloud Storage | NFS protocol, POSIX compliance |
| **Large files** | Cloud Storage | Persistent Disk | Unlimited size, cost-effective |
| **Small files** | Persistent Disk | Filestore | Lower latency, better performance |
| **Frequently accessed** | Persistent Disk | Local SSD | Low latency, high IOPS |
| **Infrequently accessed** | Cloud Storage (Nearline) | - | Lower cost, retrieval fee |
| **Archive** | Cloud Storage (Archive) | - | Lowest cost, long-term retention |

### Access Patterns

| Pattern | Recommended | Alternative | Why |
|---------|-------------|-------------|-----|
| **Sequential read** | Cloud Storage | pd-standard | Good throughput, cost-effective |
| **Random read** | Persistent Disk (SSD) | Local SSD | Low latency, high IOPS |
| **Sequential write** | Cloud Storage | pd-standard | Good throughput |
| **Random write** | Persistent Disk (SSD) | Local SSD | Low latency, high IOPS |
| **Read-heavy** | Cloud Storage + CDN | Persistent Disk | Caching, global distribution |
| **Write-heavy** | Persistent Disk (SSD) | Local SSD | High write IOPS |
| **Mixed workload** | Persistent Disk (balanced) | - | Balanced performance |

### Sharing Requirements

| Requirement | Recommended | Alternative | Why |
|-------------|-------------|-------------|-----|
| **Single VM** | Persistent Disk | Local SSD | Direct attachment, high performance |
| **Multiple VMs** | Filestore | Cloud Storage | NFS sharing, concurrent access |
| **Public access** | Cloud Storage | - | HTTP access, signed URLs |
| **Private access** | Persistent Disk | Filestore | VPC-only access |
| **Cross-region** | Cloud Storage (multi-region) | - | Global replication |
| **Cross-zone** | Regional Persistent Disk | Filestore Enterprise | Zone redundancy |

---

## Performance Comparison

### Throughput Comparison

**Sequential Read (MB/s):**

| Service | Configuration | Throughput |
|---------|--------------|------------|
| **Cloud Storage** | Standard class | 5,000 MB/s (per bucket) |
| **pd-standard** | 1 TB | 240 MB/s |
| **pd-balanced** | 1 TB | 480 MB/s |
| **pd-ssd** | 1 TB | 960 MB/s |
| **pd-extreme** | 1 TB | 4,800 MB/s |
| **Local SSD** | 375 GB × 8 | 9,600 MB/s |
| **Filestore Basic HDD** | 1 TB | 180 MB/s |
| **Filestore Basic SSD** | 2.5 TB | 480 MB/s |
| **Filestore High Scale** | 10 TB | 1,200 MB/s |

### IOPS Comparison

**Random Read IOPS:**

| Service | Configuration | IOPS |
|---------|--------------|------|
| **pd-standard** | 1 TB | 750 |
| **pd-balanced** | 1 TB | 6,000 |
| **pd-ssd** | 1 TB | 30,000 |
| **pd-extreme** | 1 TB | 160,000 (configurable) |
| **Local SSD** | 375 GB | 680,000 |
| **Filestore Basic** | 1 TB | 60,000 |
| **Filestore High Scale** | 10 TB | 100,000 |

### Latency Comparison

| Service | Typical Latency | Use Case |
|---------|----------------|----------|
| **Cloud Storage** | 10-100ms | Bulk data, backups |
| **Persistent Disk** | <1ms | Databases, applications |
| **Filestore** | <1ms | Shared files, NFS |
| **Local SSD** | <1ms | High-performance computing |

---

## Cost Comparison

### Storage Cost (per GB/month)

**Cloud Storage:**
- Standard: $0.020
- Nearline: $0.010
- Coldline: $0.004
- Archive: $0.0012

**Persistent Disk:**
- pd-standard: $0.040
- pd-balanced: $0.100
- pd-ssd: $0.170
- pd-extreme: $0.125 + IOPS cost
- Local SSD: $0.080

**Filestore:**
- Basic HDD: $0.200
- Basic SSD: $0.300
- High Scale SSD: $0.600
- Enterprise: $0.350

### Monthly Cost Examples

**Scenario 1: 1 TB General Purpose Storage**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **Cloud Storage** | Standard | $20 |
| **Cloud Storage** | Nearline | $10 |
| **Persistent Disk** | pd-balanced | $100 |
| **Filestore** | Basic HDD | $200 |

**Scenario 2: 500 GB High-Performance Storage**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **Persistent Disk** | pd-ssd | $85 |
| **Persistent Disk** | pd-extreme | $125+ |
| **Local SSD** | 375 GB × 2 | $160 |
| **Filestore** | Basic SSD (2.5 TB min) | $768 |

**Scenario 3: 10 TB Archive Storage**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| **Cloud Storage** | Archive | $12 |
| **Cloud Storage** | Coldline | $40 |
| **Persistent Disk** | pd-standard | $400 |
| **Filestore** | Not suitable | - |

### Total Cost of Ownership

**Factors to consider:**
- Storage cost
- Operations cost (Cloud Storage)
- Egress cost (Cloud Storage)
- Snapshot/backup cost
- Management overhead
- Performance requirements

**Example: 1 TB database storage for 1 year**

```
Option 1: pd-ssd
- Storage: $85/month × 12 = $1,020
- Snapshots: $20/month × 12 = $240
- Total: $1,260/year

Option 2: pd-balanced
- Storage: $50/month × 12 = $600
- Snapshots: $20/month × 12 = $240
- Total: $840/year
- Savings: 33%

Option 3: Local SSD (if acceptable)
- Storage: $80/month × 12 = $960
- Backups to Storage: $10/month × 12 = $120
- Total: $1,080/year
- Savings: 14%
```

---

## Migration Paths

### From On-Premises

```
On-Premises Storage
    |
    ├─> File Server ──────────> Filestore
    |
    ├─> SAN/NAS ──────────────> Persistent Disk
    |
    ├─> Object Storage ───────> Cloud Storage
    |
    └─> Backup System ────────> Cloud Storage (Archive)
```

### Between GCP Services

```
Cloud Storage
    |
    ├─> Need block storage ───> Persistent Disk
    |
    └─> Need NFS ─────────────> Filestore

Persistent Disk
    |
    ├─> Need sharing ─────────> Filestore
    |
    └─> Archive old data ─────> Cloud Storage

Filestore
    |
    ├─> Reduce cost ──────────> Cloud Storage
    |
    └─> Need block storage ───> Persistent Disk
```

### Migration Strategies

**Cloud Storage to Persistent Disk:**
```bash
# Download from Cloud Storage
gsutil -m cp -r gs://my-bucket/data/ /tmp/data/

# Copy to mounted persistent disk
cp -r /tmp/data/ /mnt/pd/
```

**Persistent Disk to Cloud Storage:**
```bash
# Copy from persistent disk
gsutil -m cp -r /mnt/pd/data/ gs://my-bucket/
```

**Filestore to Cloud Storage:**
```bash
# Sync from Filestore
gsutil -m rsync -r /mnt/filestore/ gs://my-bucket/
```

---

## Decision Framework

### Step 1: Determine Storage Type

```
What type of storage do you need?
    |
    ├─> Object storage (files, media, backups)
    |   └─> Cloud Storage
    |
    ├─> Block storage (VM disks, databases)
    |   ├─> Persistent? → Persistent Disk
    |   └─> Temporary? → Local SSD
    |
    └─> File storage (shared files, NFS)
        └─> Filestore
```

### Step 2: Evaluate Requirements

**Performance:**
- High IOPS needed? → pd-ssd, Local SSD, Filestore High Scale
- High throughput needed? → pd-extreme, Local SSD, Filestore High Scale
- Low latency critical? → Persistent Disk, Local SSD, Filestore
- Moderate performance? → pd-balanced, Filestore Basic

**Capacity:**
- Unlimited? → Cloud Storage
- Up to 64 TB? → Persistent Disk
- Up to 100 TB? → Filestore
- Up to 9 TB temporary? → Local SSD

**Sharing:**
- Single VM? → Persistent Disk, Local SSD
- Multiple VMs? → Filestore, Cloud Storage
- Public access? → Cloud Storage
- NFS required? → Filestore

**Durability:**
- 11 nines? → Cloud Storage
- 6 nines? → Persistent Disk
- 4 nines? → Filestore
- Ephemeral OK? → Local SSD

### Step 3: Consider Cost

**Budget-conscious:**
- Cloud Storage (appropriate class)
- pd-standard or pd-balanced
- Filestore Basic HDD

**Performance-focused:**
- pd-ssd or pd-extreme
- Local SSD
- Filestore High Scale

**Balanced:**
- pd-balanced
- Filestore Basic SSD
- Cloud Storage Standard

### Step 4: Choose Service

```
Decision Matrix:

Unstructured data + Cost-effective
    → Cloud Storage

VM storage + High performance
    → Persistent Disk (SSD)

Shared files + NFS required
    → Filestore

Temporary + Extreme performance
    → Local SSD

Archive + Long-term retention
    → Cloud Storage (Archive)
```

---

## Summary

### Quick Reference

**Choose Cloud Storage when:**
✅ Storing unstructured data  
✅ Need unlimited capacity  
✅ Cost is primary concern  
✅ Global access required  
✅ Backup and archival  
✅ Static website hosting  
✅ Data lake storage  

**Choose Persistent Disk when:**
✅ VM boot and data disks  
✅ Database storage  
✅ Need block storage  
✅ Single VM access  
✅ High IOPS required  
✅ Persistent storage needed  
✅ Snapshot support required  

**Choose Filestore when:**
✅ Need NFS protocol  
✅ Shared file access  
✅ POSIX compliance required  
✅ Multiple VM access  
✅ Legacy application support  
✅ Content management  
✅ Media workflows  

**Choose Local SSD when:**
✅ Temporary storage  
✅ Extreme performance needed  
✅ Caching layer  
✅ Scratch space  
✅ High-performance computing  
✅ Data loss acceptable  

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
