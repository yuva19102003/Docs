# Persistent Disk - Block Storage for VMs

Complete guide to Persistent Disk - durable block storage for Compute Engine.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Disk Types](#disk-types)
3. [Disk Management](#disk-management)
4. [Snapshots](#snapshots)
5. [Performance](#performance)
6. [High Availability](#high-availability)
7. [Encryption](#encryption)
8. [Cost Optimization](#cost-optimization)
9. [Best Practices](#best-practices)

---

## Introduction

Persistent Disk provides durable, high-performance block storage for Compute Engine VMs.

### Key Features

✅ Durable and reliable (99.9999% durability)  
✅ Multiple disk types  
✅ Up to 64 TB per disk  
✅ Snapshots for backup  
✅ Encryption at rest  
✅ Regional persistent disks  
✅ Resize without downtime  
✅ Independent of VM lifecycle  
✅ Automatic encryption  
✅ High IOPS and throughput  

### Architecture

```
┌─────────────────────────────────────┐
│    Compute Engine Instance          │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │  Boot Disk (pd-balanced)     │   │
│  │  - OS and system files       │   │
│  │  - 20 GB                     │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  Data Disk (pd-ssd)          │   │
│  │  - Application data          │   │
│  │  - 500 GB                    │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  Local SSD (temporary)       │   │
│  │  - Cache/temp data           │   │
│  │  - 375 GB                    │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## Disk Types

### Standard Persistent Disk (pd-standard)

**HDD-backed storage**

```
Characteristics:
- Sequential I/O optimized
- Lower cost
- Good for throughput
- Up to 64 TB
```

**Performance:**
- Read IOPS: 0.75 per GB (max 7,500)
- Write IOPS: 1.5 per GB (max 15,000)
- Throughput: 120-240 MB/s

**Pricing:** $0.040/GB/month

**Use Cases:**
- Batch processing
- Sequential workloads
- Cold storage
- Backup targets

### Balanced Persistent Disk (pd-balanced)

**SSD-backed storage with balanced performance**

```
Characteristics:
- Balance of performance and cost
- Good for most workloads
- Recommended default
- Up to 64 TB
```

**Performance:**
- Read/Write IOPS: 6 per GB (max 80,000)
- Throughput: 240-480 MB/s

**Pricing:** $0.100/GB/month

**Use Cases:**
- General purpose workloads
- Boot disks
- Development environments
- Most applications

### SSD Persistent Disk (pd-ssd)

**High-performance SSD storage**

```
Characteristics:
- High IOPS
- Low latency
- Consistent performance
- Up to 64 TB
```

**Performance:**
- Read/Write IOPS: 30 per GB (max 100,000)
- Throughput: 480-960 MB/s

**Pricing:** $0.170/GB/month

**Use Cases:**
- Databases
- High-performance applications
- Analytics workloads
- Latency-sensitive apps

### Extreme Persistent Disk (pd-extreme)

**Highest performance SSD storage**

```
Characteristics:
- Configurable IOPS
- Highest performance
- Premium pricing
- Up to 64 TB
```

**Performance:**
- IOPS: Configurable up to 160,000
- Throughput: Up to 4,800 MB/s

**Pricing:** $0.125/GB/month + $0.065/provisioned IOPS

**Use Cases:**
- High-end databases
- SAP HANA
- Mission-critical applications
- Extreme performance needs

### Local SSD

**Ephemeral high-performance storage**

```
Characteristics:
- Physically attached to server
- Very high performance
- Data lost on VM stop
- 375 GB per device
```

**Performance:**
- Read IOPS: 680,000
- Write IOPS: 360,000
- Throughput: 2,400-9,600 MB/s

**Pricing:** $0.080/GB/month

**Use Cases:**
- Caching
- Temporary data
- Scratch space
- High-performance computing

### Disk Type Comparison

| Type | IOPS/GB | Max IOPS | Throughput | Cost/GB | Use Case |
|------|---------|----------|------------|---------|----------|
| **pd-standard** | 0.75-1.5 | 15,000 | 240 MB/s | $0.040 | Sequential |
| **pd-balanced** | 6 | 80,000 | 480 MB/s | $0.100 | General |
| **pd-ssd** | 30 | 100,000 | 960 MB/s | $0.170 | High perf |
| **pd-extreme** | Custom | 160,000 | 4,800 MB/s | $0.125+ | Extreme |
| **Local SSD** | N/A | 680,000 | 9,600 MB/s | $0.080 | Temporary |

---

## Disk Management

### Create Disk

```bash
# Create standard disk
gcloud compute disks create my-disk \
  --size=100GB \
  --type=pd-standard \
  --zone=us-central1-a

# Create SSD disk
gcloud compute disks create my-ssd-disk \
  --size=500GB \
  --type=pd-ssd \
  --zone=us-central1-a

# Create from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a

# Create from image
gcloud compute disks create boot-disk \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --zone=us-central1-a
```

### Attach/Detach Disk

```bash
# Attach disk to VM
gcloud compute instances attach-disk my-vm \
  --disk=my-disk \
  --zone=us-central1-a

# Attach in read-only mode
gcloud compute instances attach-disk my-vm \
  --disk=my-disk \
  --mode=ro \
  --zone=us-central1-a

# Detach disk
gcloud compute instances detach-disk my-vm \
  --disk=my-disk \
  --zone=us-central1-a
```

### Format and Mount

```bash
# Format disk (on VM)
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb

# Create mount point
sudo mkdir -p /mnt/disks/data

# Mount disk
sudo mount -o discard,defaults /dev/sdb /mnt/disks/data

# Add to /etc/fstab for automatic mounting
echo UUID=$(sudo blkid -s UUID -o value /dev/sdb) /mnt/disks/data ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
```

### Resize Disk

```bash
# Resize disk
gcloud compute disks resize my-disk \
  --size=200GB \
  --zone=us-central1-a

# Resize filesystem (on VM)
sudo resize2fs /dev/sdb
```

### Terraform Example

```hcl
resource "google_compute_disk" "default" {
  name  = "my-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size  = 500
  
  labels = {
    environment = "production"
    team        = "backend"
  }
  
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = google_compute_instance.default.id
}
```

---

## Snapshots

### Create Snapshots

```bash
# Create snapshot
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a

# Create snapshot with description
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --description="Daily backup" \
  --zone=us-central1-a

# Create snapshot with labels
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --labels=env=prod,type=backup \
  --zone=us-central1-a
```

### Snapshot Schedule

```bash
# Create snapshot schedule
gcloud compute resource-policies create snapshot-schedule daily-backup \
  --region=us-central1 \
  --max-retention-days=7 \
  --on-source-disk-delete=keep-auto-snapshots \
  --daily-schedule \
  --start-time=02:00

# Attach schedule to disk
gcloud compute disks add-resource-policies my-disk \
  --resource-policies=daily-backup \
  --zone=us-central1-a
```

### Restore from Snapshot

```bash
# Create disk from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a

# Create disk in different zone
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-west1-a
```

### Snapshot Management

```bash
# List snapshots
gcloud compute snapshots list

# Delete snapshot
gcloud compute snapshots delete my-snapshot

# Copy snapshot to different region
gcloud compute snapshots create my-snapshot-copy \
  --source-snapshot=my-snapshot \
  --storage-location=us-west1
```

---

## Performance

### IOPS Calculation

**pd-balanced:**
```
IOPS = min(disk_size_gb × 6, 80000)

Example: 500 GB disk
IOPS = min(500 × 6, 80000) = 3,000 IOPS
```

**pd-ssd:**
```
IOPS = min(disk_size_gb × 30, 100000)

Example: 500 GB disk
IOPS = min(500 × 30, 100000) = 15,000 IOPS
```

### Throughput Calculation

**Per VM limits:**
- Read: 1,200 MB/s (n2, n2d, c2, c2d)
- Write: 800 MB/s (n2, n2d, c2, c2d)

**Per disk limits:**
- pd-standard: 240 MB/s
- pd-balanced: 480 MB/s
- pd-ssd: 960 MB/s
- pd-extreme: 4,800 MB/s

### Performance Optimization

```bash
# Use SSD for high IOPS
gcloud compute disks create high-iops-disk \
  --size=1000GB \
  --type=pd-ssd \
  --zone=us-central1-a

# Use larger disk for more IOPS
gcloud compute disks create large-disk \
  --size=2000GB \
  --type=pd-balanced \
  --zone=us-central1-a

# Use Local SSD for extreme performance
gcloud compute instances create high-perf-vm \
  --zone=us-central1-a \
  --machine-type=n2-standard-8 \
  --local-ssd=interface=NVME \
  --local-ssd=interface=NVME
```

### Performance Tips

✅ Use SSD for databases  
✅ Size disk for required IOPS  
✅ Use Local SSD for temporary high-performance needs  
✅ Use pd-extreme for highest performance  
✅ Monitor disk performance  
✅ Use appropriate machine type  
✅ Enable discard/TRIM  
✅ Use multiple disks for higher throughput  

---

## High Availability

### Regional Persistent Disks

```bash
# Create regional disk
gcloud compute disks create regional-disk \
  --size=500GB \
  --type=pd-ssd \
  --region=us-central1 \
  --replica-zones=us-central1-a,us-central1-b

# Attach to VM
gcloud compute instances attach-disk my-vm \
  --disk=regional-disk \
  --zone=us-central1-a
```

**Benefits:**
- Synchronous replication across zones
- Automatic failover
- 99.99% availability SLA
- No data loss on zone failure

**Limitations:**
- 2x cost
- Slightly higher latency
- Limited to 2 zones in same region

### Backup Strategy

```bash
# Automated snapshots
gcloud compute resource-policies create snapshot-schedule backup-policy \
  --region=us-central1 \
  --max-retention-days=30 \
  --on-source-disk-delete=keep-auto-snapshots \
  --daily-schedule \
  --start-time=02:00 \
  --storage-location=us

# Apply to disk
gcloud compute disks add-resource-policies my-disk \
  --resource-policies=backup-policy \
  --zone=us-central1-a
```

---

## Encryption

### Google-Managed Encryption

- Default encryption
- No configuration needed
- Automatic key rotation

### Customer-Managed Encryption Keys (CMEK)

```bash
# Create key
gcloud kms keyrings create my-keyring --location=us-central1
gcloud kms keys create my-key \
  --location=us-central1 \
  --keyring=my-keyring \
  --purpose=encryption

# Create disk with CMEK
gcloud compute disks create encrypted-disk \
  --size=100GB \
  --type=pd-ssd \
  --zone=us-central1-a \
  --kms-key=projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key
```

### Customer-Supplied Encryption Keys (CSEK)

```bash
# Generate key
openssl rand -base64 32 > disk-key.txt

# Create disk with CSEK
gcloud compute disks create csek-disk \
  --size=100GB \
  --csek-key-file=disk-key.txt \
  --zone=us-central1-a
```

---

## Cost Optimization

### Pricing Comparison

**Monthly cost for 1 TB:**
- pd-standard: $40
- pd-balanced: $100
- pd-ssd: $170
- pd-extreme: $125 + IOPS cost
- Local SSD: $80

### Optimization Strategies

✅ Use pd-balanced instead of pd-ssd when possible  
✅ Right-size disk capacity  
✅ Delete unused disks  
✅ Use snapshots for backups (cheaper than disks)  
✅ Use committed use discounts  
✅ Use Local SSD for temporary data  
✅ Monitor disk utilization  
✅ Use lifecycle policies for snapshots  

### Cost Example

**Scenario:** Database with 500 GB storage

```
Option 1: pd-ssd
- Cost: 500 GB × $0.170 = $85/month

Option 2: pd-balanced
- Cost: 500 GB × $0.100 = $50/month
- Savings: 41%

Option 3: pd-standard
- Cost: 500 GB × $0.040 = $20/month
- Savings: 76% (if performance acceptable)
```

---

## Best Practices

### Performance

✅ Use SSD for databases and high-IOPS workloads  
✅ Size disks for required IOPS  
✅ Use Local SSD for temporary high-performance needs  
✅ Monitor disk performance metrics  
✅ Use multiple disks for higher throughput  
✅ Enable discard/TRIM  
✅ Use appropriate machine type  

### Reliability

✅ Use regional disks for critical data  
✅ Implement automated snapshots  
✅ Test restore procedures  
✅ Use snapshot schedules  
✅ Keep snapshots in multiple regions  
✅ Monitor disk health  
✅ Plan for disaster recovery  

### Security

✅ Use CMEK for sensitive data  
✅ Enable audit logging  
✅ Use IAM for access control  
✅ Regular security audits  
✅ Encrypt snapshots  
✅ Use VPC Service Controls  

### Cost Management

✅ Right-size disk capacity  
✅ Delete unused disks  
✅ Use appropriate disk type  
✅ Use snapshots for backups  
✅ Monitor costs  
✅ Use committed use discounts  
✅ Implement lifecycle policies  

---

## Troubleshooting

**Disk full:**
```bash
# Check disk usage
df -h

# Resize disk
gcloud compute disks resize my-disk --size=200GB --zone=us-central1-a
sudo resize2fs /dev/sdb
```

**Performance issues:**
```bash
# Check IOPS
iostat -x 1

# Monitor disk metrics
gcloud monitoring time-series list \
  --filter='metric.type="compute.googleapis.com/instance/disk/read_ops_count"'
```

**Cannot attach disk:**
- Check if disk is already attached
- Verify zone matches VM
- Check IAM permissions
- Verify disk exists

---

## Next Steps

- **[Filestore](3-Filestore.md)** - Managed NFS file storage
- **[Storage Comparison](4-Storage-Comparison.md)** - Detailed comparison
- **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
