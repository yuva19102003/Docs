# Filestore - Managed NFS File Storage

Complete guide to Google Cloud Filestore - fully managed NFS file storage.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Service Tiers](#service-tiers)
3. [Instance Management](#instance-management)
4. [Mounting File Shares](#mounting-file-shares)
5. [Backups](#backups)
6. [Performance](#performance)
7. [High Availability](#high-availability)
8. [Security](#security)
9. [Cost Optimization](#cost-optimization)
10. [Best Practices](#best-practices)

---

## Introduction

Filestore is a fully managed NFS file storage service for applications requiring a file system interface.

### Key Features

✅ Fully managed NFS service  
✅ High performance (up to 1,200 MB/s)  
✅ POSIX compliant  
✅ Shared file access  
✅ Multiple tiers  
✅ Automatic backups  
✅ Snapshots support  
✅ VPC integration  
✅ Scalable capacity  
✅ Low latency (<1ms)  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│         Filestore Instance                          │
├─────────────────────────────────────────────────────┤
│  File Share: /vol1                                  │
│  - Capacity: 1 TB                                   │
│  - Tier: Basic HDD                                  │
│  - Network: default VPC                             │
└──────────────────┬──────────────────────────────────┘
                   |
        ┌──────────┼──────────┐
        v          v          v
    ┌──────┐   ┌──────┐   ┌──────┐
    │ VM 1 │   │ VM 2 │   │ VM 3 │
    │ App  │   │ App  │   │ App  │
    └──────┘   └──────┘   └──────┘
    
    All VMs can read/write simultaneously
```

---

## Service Tiers

### Basic HDD

**Standard tier for general workloads**

```
Characteristics:
- HDD-backed storage
- Good for most workloads
- Lower cost
- 1 TB - 63.9 TB capacity
```

**Performance:**
- Throughput: 180 MB/s (read), 120 MB/s (write)
- IOPS: 60,000 (read), 40,000 (write)
- Latency: <1ms

**Pricing:** $0.20/GB/month

**Use Cases:**
- File sharing
- Content management
- Web serving
- Development environments

### Basic SSD

**SSD tier for higher performance**

```
Characteristics:
- SSD-backed storage
- Higher performance
- Higher cost
- 2.5 TB - 63.9 TB capacity
```

**Performance:**
- Throughput: 480 MB/s (read), 350 MB/s (write)
- IOPS: 60,000 (read), 40,000 (write)
- Latency: <1ms

**Pricing:** $0.30/GB/month

**Use Cases:**
- Databases
- Analytics
- Media processing
- High-performance applications

### High Scale SSD

**Premium tier for extreme performance**

```
Characteristics:
- High-performance SSD
- Highest throughput
- Premium pricing
- 10 TB - 100 TB capacity
```

**Performance:**
- Throughput: 1,200 MB/s (read), 1,200 MB/s (write)
- IOPS: 100,000 (read), 100,000 (write)
- Latency: <1ms

**Pricing:** $0.60/GB/month

**Use Cases:**
- High-performance computing
- Genomics
- Financial modeling
- Large-scale rendering

### Enterprise

**Multi-zone tier for high availability**

```
Characteristics:
- Multi-zone replication
- High availability
- Automatic failover
- 1 TB - 10 TB capacity
```

**Performance:**
- Throughput: 1,200 MB/s
- IOPS: 100,000
- Latency: <1ms
- 99.99% availability SLA

**Pricing:** $0.35/GB/month

**Use Cases:**
- Mission-critical applications
- Production databases
- Enterprise applications
- High availability requirements

### Tier Comparison

| Tier | Storage | Throughput | IOPS | Latency | Cost/GB | HA |
|------|---------|------------|------|---------|---------|-----|
| **Basic HDD** | 1-63.9 TB | 180 MB/s | 60K | <1ms | $0.20 | No |
| **Basic SSD** | 2.5-63.9 TB | 480 MB/s | 60K | <1ms | $0.30 | No |
| **High Scale** | 10-100 TB | 1,200 MB/s | 100K | <1ms | $0.60 | No |
| **Enterprise** | 1-10 TB | 1,200 MB/s | 100K | <1ms | $0.35 | Yes |

---

## Instance Management

### Create Instance

```bash
# Create Basic HDD instance
gcloud filestore instances create my-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default

# Create Basic SSD instance
gcloud filestore instances create my-ssd-filestore \
  --zone=us-central1-a \
  --tier=BASIC_SSD \
  --file-share=name=vol1,capacity=2560GB \
  --network=name=default

# Create High Scale instance
gcloud filestore instances create my-highscale-filestore \
  --zone=us-central1-a \
  --tier=HIGH_SCALE_SSD \
  --file-share=name=vol1,capacity=10TB \
  --network=name=default

# Create Enterprise instance
gcloud filestore instances create my-enterprise-filestore \
  --region=us-central1 \
  --tier=ENTERPRISE \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default
```

### Instance Configuration

```bash
# Create with labels
gcloud filestore instances create my-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default \
  --labels=env=prod,team=backend

# Create with description
gcloud filestore instances create my-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default \
  --description="Production file storage"
```

### Terraform Example

```hcl
resource "google_filestore_instance" "default" {
  name     = "my-filestore"
  location = "us-central1-a"
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "vol1"
  }

  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }

  labels = {
    environment = "production"
    team        = "backend"
  }
}

# High Scale instance
resource "google_filestore_instance" "highscale" {
  name     = "my-highscale-filestore"
  location = "us-central1-a"
  tier     = "HIGH_SCALE_SSD"

  file_shares {
    capacity_gb = 10240
    name        = "vol1"
  }

  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }
}

# Enterprise instance (multi-zone)
resource "google_filestore_instance" "enterprise" {
  name     = "my-enterprise-filestore"
  location = "us-central1"
  tier     = "ENTERPRISE"

  file_shares {
    capacity_gb = 1024
    name        = "vol1"
  }

  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }
}
```

### Update Instance

```bash
# Resize file share
gcloud filestore instances update my-filestore \
  --zone=us-central1-a \
  --file-share=name=vol1,capacity=2TB

# Update labels
gcloud filestore instances update my-filestore \
  --zone=us-central1-a \
  --update-labels=env=staging

# Update description
gcloud filestore instances update my-filestore \
  --zone=us-central1-a \
  --description="Updated description"
```

### List and Describe

```bash
# List instances
gcloud filestore instances list

# Describe instance
gcloud filestore instances describe my-filestore \
  --zone=us-central1-a

# Get IP address
gcloud filestore instances describe my-filestore \
  --zone=us-central1-a \
  --format="value(networks[0].ipAddresses[0])"
```

### Delete Instance

```bash
# Delete instance
gcloud filestore instances delete my-filestore \
  --zone=us-central1-a
```

---

## Mounting File Shares

### Mount on Linux

```bash
# Install NFS client
sudo apt-get update
sudo apt-get install nfs-common

# Create mount point
sudo mkdir -p /mnt/filestore

# Get Filestore IP
FILESTORE_IP=$(gcloud filestore instances describe my-filestore \
  --zone=us-central1-a \
  --format="value(networks[0].ipAddresses[0])")

# Mount file share
sudo mount -t nfs ${FILESTORE_IP}:/vol1 /mnt/filestore

# Verify mount
df -h /mnt/filestore

# Test write
echo "Hello Filestore" | sudo tee /mnt/filestore/test.txt
```

### Persistent Mount

```bash
# Add to /etc/fstab
echo "${FILESTORE_IP}:/vol1 /mnt/filestore nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Test fstab
sudo mount -a

# Verify
df -h /mnt/filestore
```

### Mount Options

```bash
# Mount with specific options
sudo mount -t nfs \
  -o rw,hard,intr,timeo=600,retrans=2,_netdev \
  ${FILESTORE_IP}:/vol1 /mnt/filestore
```

**Recommended mount options:**
- `rw`: Read-write access
- `hard`: Hard mount (recommended)
- `intr`: Allow interruption
- `timeo=600`: Timeout (60 seconds)
- `retrans=2`: Retransmission attempts
- `_netdev`: Wait for network

### Mount on Windows

```powershell
# Enable NFS client
Enable-WindowsOptionalFeature -Online -FeatureName ServicesForNFS-ClientOnly

# Mount file share
mount -o anon \\FILESTORE_IP\vol1 Z:

# Verify
dir Z:
```

### Startup Script

```bash
#!/bin/bash
# startup-script.sh

# Install NFS client
apt-get update
apt-get install -y nfs-common

# Create mount point
mkdir -p /mnt/filestore

# Get Filestore IP from metadata
FILESTORE_IP="10.0.0.2"  # Replace with actual IP

# Mount file share
mount -t nfs ${FILESTORE_IP}:/vol1 /mnt/filestore

# Add to fstab
echo "${FILESTORE_IP}:/vol1 /mnt/filestore nfs defaults,_netdev 0 0" >> /etc/fstab
```

---

## Backups

### Create Backup

```bash
# Create backup
gcloud filestore backups create my-backup \
  --instance=my-filestore \
  --instance-zone=us-central1-a \
  --file-share=vol1 \
  --region=us-central1

# Create backup with description
gcloud filestore backups create my-backup \
  --instance=my-filestore \
  --instance-zone=us-central1-a \
  --file-share=vol1 \
  --region=us-central1 \
  --description="Daily backup"
```

### Backup Schedule

```bash
# Create backup schedule (via console or API)
# Automated backups not yet available via gcloud
```

### Restore from Backup

```bash
# Create instance from backup
gcloud filestore instances create restored-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB,source-backup=my-backup \
  --network=name=default
```

### Backup Management

```bash
# List backups
gcloud filestore backups list --region=us-central1

# Describe backup
gcloud filestore backups describe my-backup --region=us-central1

# Delete backup
gcloud filestore backups delete my-backup --region=us-central1
```

---

## Performance

### Performance Characteristics

**Basic HDD:**
```
Throughput: 180 MB/s read, 120 MB/s write
IOPS: 60,000 read, 40,000 write
Latency: <1ms
```

**Basic SSD:**
```
Throughput: 480 MB/s read, 350 MB/s write
IOPS: 60,000 read, 40,000 write
Latency: <1ms
```

**High Scale SSD:**
```
Throughput: 1,200 MB/s read/write
IOPS: 100,000 read/write
Latency: <1ms
```

### Performance Testing

```bash
# Install fio
sudo apt-get install fio

# Sequential read test
fio --name=seqread --rw=read --bs=1M --size=1G \
  --numjobs=1 --directory=/mnt/filestore

# Sequential write test
fio --name=seqwrite --rw=write --bs=1M --size=1G \
  --numjobs=1 --directory=/mnt/filestore

# Random read test
fio --name=randread --rw=randread --bs=4k --size=1G \
  --numjobs=4 --directory=/mnt/filestore

# Random write test
fio --name=randwrite --rw=randwrite --bs=4k --size=1G \
  --numjobs=4 --directory=/mnt/filestore
```

### Performance Optimization

✅ Use appropriate tier for workload  
✅ Use multiple clients for higher throughput  
✅ Use appropriate mount options  
✅ Optimize file sizes  
✅ Use parallel operations  
✅ Monitor performance metrics  
✅ Use High Scale for extreme performance  
✅ Consider Enterprise for HA  

---

## High Availability

### Enterprise Tier

```bash
# Create Enterprise instance (multi-zone)
gcloud filestore instances create ha-filestore \
  --region=us-central1 \
  --tier=ENTERPRISE \
  --file-share=name=vol1,capacity=1TB \
  --network=name=default
```

**Benefits:**
- Multi-zone replication
- Automatic failover
- 99.99% availability SLA
- No data loss on zone failure

**Limitations:**
- Higher cost
- 1-10 TB capacity range
- Regional deployment only

### Backup Strategy

```bash
# Regular backups
gcloud filestore backups create daily-backup-$(date +%Y%m%d) \
  --instance=my-filestore \
  --instance-zone=us-central1-a \
  --file-share=vol1 \
  --region=us-central1

# Cross-region backup (manual)
# 1. Create backup in source region
# 2. Copy data to Cloud Storage
# 3. Restore in target region
```

---

## Security

### Network Security

```bash
# Create instance in custom VPC
gcloud filestore instances create secure-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=my-vpc

# Use VPC firewall rules
gcloud compute firewall-rules create allow-nfs \
  --network=my-vpc \
  --allow=tcp:2049,tcp:111,udp:2049,udp:111 \
  --source-ranges=10.0.0.0/8 \
  --target-tags=filestore-client
```

### Access Control

**NFS permissions:**
```bash
# Set permissions on mount
sudo chmod 755 /mnt/filestore

# Set ownership
sudo chown user:group /mnt/filestore

# Create directory with permissions
sudo mkdir -p /mnt/filestore/shared
sudo chmod 770 /mnt/filestore/shared
sudo chown :developers /mnt/filestore/shared
```

### Encryption

- Encryption at rest (automatic)
- Encryption in transit (NFS over TLS not yet supported)
- Use VPN or Interconnect for secure transit

### IAM Permissions

```bash
# Grant Filestore admin role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:user@example.com" \
  --role="roles/file.editor"

# Grant Filestore viewer role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:user@example.com" \
  --role="roles/file.viewer"
```

---

## Cost Optimization

### Pricing Comparison

**Monthly cost for 1 TB:**
- Basic HDD: $200
- Basic SSD: $300
- High Scale SSD: $600
- Enterprise: $350

### Optimization Strategies

✅ Choose appropriate tier  
✅ Right-size capacity  
✅ Delete unused instances  
✅ Use Basic HDD when possible  
✅ Monitor utilization  
✅ Use committed use discounts  
✅ Implement lifecycle policies  
✅ Regular capacity reviews  

### Cost Example

**Scenario:** 2 TB shared file storage

```
Option 1: Basic HDD
- Cost: 2000 GB × $0.20 = $400/month

Option 2: Basic SSD
- Cost: 2560 GB × $0.30 = $768/month
- Use only if performance needed

Option 3: Cloud Storage (not NFS)
- Cost: 2000 GB × $0.020 = $40/month
- But no NFS protocol support
```

---

## Best Practices

### Performance

✅ Use appropriate tier for workload  
✅ Use multiple clients for higher throughput  
✅ Use recommended mount options  
✅ Monitor performance metrics  
✅ Optimize file operations  
✅ Use parallel operations  
✅ Test performance before production  

### Reliability

✅ Use Enterprise tier for critical data  
✅ Implement regular backups  
✅ Test restore procedures  
✅ Monitor instance health  
✅ Use multiple mount points  
✅ Implement retry logic  
✅ Plan for disaster recovery  

### Security

✅ Use custom VPC  
✅ Implement firewall rules  
✅ Use IAM for access control  
✅ Set appropriate file permissions  
✅ Enable audit logging  
✅ Regular security audits  
✅ Use VPN for remote access  

### Cost Management

✅ Right-size capacity  
✅ Use appropriate tier  
✅ Delete unused instances  
✅ Monitor utilization  
✅ Implement lifecycle policies  
✅ Regular cost reviews  
✅ Use committed use discounts  

---

## Troubleshooting

### Mount Issues

```bash
# Check NFS client
sudo systemctl status nfs-client.target

# Check connectivity
ping FILESTORE_IP

# Check NFS ports
telnet FILESTORE_IP 2049

# Check mount
mount | grep filestore

# Remount
sudo umount /mnt/filestore
sudo mount -t nfs FILESTORE_IP:/vol1 /mnt/filestore
```

### Performance Issues

```bash
# Check mount options
mount | grep filestore

# Test performance
fio --name=test --rw=read --bs=1M --size=1G \
  --directory=/mnt/filestore

# Check network
iperf3 -c FILESTORE_IP
```

### Permission Issues

```bash
# Check permissions
ls -la /mnt/filestore

# Fix permissions
sudo chmod 755 /mnt/filestore
sudo chown user:group /mnt/filestore
```

---

## Next Steps

- **[Storage Comparison](4-Storage-Comparison.md)** - Detailed comparison
- **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
