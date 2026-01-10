# DigitalOcean Network File Storage Overview

## Introduction

Network File Storage provides scalable NFS-based shared storage accessible from multiple Droplets.

## Key Features

- NFS protocol support
- Shared across Droplets
- Scalable capacity (100 GB - 16 TB)
- High availability
- Regional storage
- $0.10/GB/month

## Use Cases

```
Shared Storage:
├─> Web server content
├─> Application files
├─> User uploads
├─> Shared datasets
└─> Log aggregation

Benefits:
├─> Multiple Droplet access
├─> Centralized storage
├─> Easy scaling
└─> High availability
```

## Quick Start

```bash
# Create file storage
doctl compute file-system create my-nfs \
  --region nyc3 \
  --size 100GiB

# Mount on Droplet
sudo apt-get install nfs-common
sudo mkdir -p /mnt/nfs
sudo mount -t nfs <nfs-host>:/path /mnt/nfs

# Make permanent
echo '<nfs-host>:/path /mnt/nfs nfs defaults 0 0' | sudo tee -a /etc/fstab
```

## Performance

```
Throughput:
├─> Up to 1 GB/s
├─> Concurrent access
└─> Low latency

IOPS:
├─> Optimized for shared workloads
└─> Consistent performance
```

## Pricing

```
$0.10/GB/month
├─> 100 GB: $10/month
├─> 1 TB: $100/month
└─> 16 TB: $1,600/month
```
