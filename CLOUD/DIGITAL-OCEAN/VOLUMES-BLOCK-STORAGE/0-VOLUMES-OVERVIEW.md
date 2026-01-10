# DigitalOcean Volumes (Block Storage) Overview

## Introduction

DigitalOcean Volumes provide highly available block storage that can be attached to Droplets. They offer persistent, scalable storage independent of Droplet lifecycle, perfect for databases, file storage, and applications requiring persistent data.

## Key Features

- **Persistent Storage**: Data persists independently of Droplets
- **Scalable**: 1 GB to 16 TB per volume
- **High Performance**: SSD-backed storage
- **Snapshots**: Point-in-time backups
- **Resizable**: Increase size without downtime
- **Highly Available**: Replicated across multiple drives
- **Flexible Attachment**: Attach/detach from Droplets
- **Kubernetes Integration**: Use as Persistent Volumes
- **Affordable**: $0.10/GB/month
- **Regional**: Available in all regions


## Volume Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DigitalOcean Region                       │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Block Storage System                       │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │  Volume: db-data (100 GB)                        │  │ │
│  │  │  ├─> Replicated across multiple drives           │  │ │
│  │  │  ├─> SSD-backed                                   │  │ │
│  │  │  └─> Highly available                             │  │ │
│  │  └──────────────────────────────────────────────────┘  │ │
│  └────────────────────────────┬───────────────────────────┘ │
│                                │                             │
│                       ┌────────▼────────┐                    │
│                       │  Attached to    │                    │
│                       └────────┬────────┘                    │
│                                │                             │
│  ┌────────────────────────────▼───────────────────────────┐ │
│  │              Droplet (Database Server)                  │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │  Local SSD: 25 GB (OS, apps)                     │  │ │
│  │  └──────────────────────────────────────────────────┘  │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │  Volume: /mnt/db-data (100 GB)                   │  │ │
│  │  │  └─> PostgreSQL data directory                   │  │ │
│  │  └──────────────────────────────────────────────────┘  │ │
│  └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘

Volume can be detached and reattached to different Droplets
```

## Volume vs Local Storage

| Feature | Volume (Block Storage) | Local Droplet Storage |
|---------|----------------------|---------------------|
| **Persistence** | Independent of Droplet | Tied to Droplet |
| **Size** | 1 GB - 16 TB | Fixed with Droplet |
| **Resizable** | Yes (increase only) | No |
| **Snapshots** | Yes | Droplet snapshots only |
| **Attachment** | Detach/reattach | Cannot detach |
| **Performance** | SSD, consistent | SSD, local |
| **Cost** | $0.10/GB/month | Included with Droplet |
| **Use Case** | Databases, persistent data | OS, applications |

## Use Cases

### 1. Database Storage
```
PostgreSQL/MySQL/MongoDB:
├─> Store database files on volume
├─> Separate data from OS
├─> Easy backup with snapshots
├─> Resize as data grows
└─> Migrate between Droplets

Benefits:
├─> Data persistence
├─> Independent scaling
├─> Disaster recovery
└─> Performance isolation
```

### 2. File Storage
```
Application Files:
├─> User uploads
├─> Media files
├─> Document storage
├─> Shared storage
└─> Log files

Benefits:
├─> Scalable capacity
├─> Persistent storage
├─> Easy backup
└─> Flexible attachment
```

### 3. Kubernetes Persistent Volumes
```
Container Storage:
├─> StatefulSets
├─> Database pods
├─> Shared volumes
├─> Configuration storage
└─> Log aggregation

Benefits:
├─> Pod-independent storage
├─> Dynamic provisioning
├─> Snapshot support
└─> Automatic attachment
```

### 4. Backup and Archive
```
Data Protection:
├─> Database backups
├─> Application backups
├─> Log archives
├─> Disaster recovery
└─> Compliance storage

Benefits:
├─> Cost-effective
├─> Snapshot capability
├─> Long-term retention
└─> Easy restoration
```

### 5. Development Environments
```
Dev/Test Data:
├─> Test databases
├─> Development files
├─> Shared datasets
├─> CI/CD artifacts
└─> Build caches

Benefits:
├─> Quick provisioning
├─> Easy cloning
├─> Cost-effective
└─> Flexible sizing
```

## Creating Volumes

### Via Control Panel

```
1. Navigate to Volumes
2. Click "Create Volume"
3. Configure:
   ├─> Name: db-data
   ├─> Size: 100 GB
   ├─> Region: NYC3 (match Droplet)
   └─> Attach to Droplet (optional)
4. Click "Create Volume"
5. Format and mount (if new)
```

### Via doctl CLI

```bash
# Create volume
doctl compute volume create db-data \
  --region nyc3 \
  --size 100GiB \
  --desc "Database storage"

# List volumes
doctl compute volume list

# Attach to Droplet
doctl compute volume-action attach VOLUME_ID DROPLET_ID

# Detach from Droplet
doctl compute volume-action detach VOLUME_ID DROPLET_ID
```

### Via API

```bash
# Create volume
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DO_TOKEN" \
  -d '{
    "size_gigabytes": 100,
    "name": "db-data",
    "description": "Database storage",
    "region": "nyc3",
    "filesystem_type": "ext4"
  }' \
  "https://api.digitalocean.com/v2/volumes"

# Attach volume
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DO_TOKEN" \
  -d '{
    "type": "attach",
    "droplet_id": 12345678,
    "region": "nyc3"
  }' \
  "https://api.digitalocean.com/v2/volumes/VOLUME_ID/actions"
```

## Formatting and Mounting

### First-Time Setup (New Volume)

```bash
# SSH into Droplet
ssh root@droplet-ip

# Find volume device
lsblk

# Format volume (ext4)
sudo mkfs.ext4 /dev/disk/by-id/scsi-0DO_Volume_db-data

# Create mount point
sudo mkdir -p /mnt/db-data

# Mount volume
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data

# Verify mount
df -h /mnt/db-data

# Make permanent (add to /etc/fstab)
echo '/dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
```

### Mounting Existing Volume

```bash
# Create mount point
sudo mkdir -p /mnt/db-data

# Mount volume (already formatted)
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data

# Add to /etc/fstab for auto-mount
echo '/dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
```

## Resizing Volumes

### Increase Volume Size

```bash
# Via doctl
doctl compute volume-action resize VOLUME_ID --size 200 --region nyc3

# Via API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DO_TOKEN" \
  -d '{
    "type": "resize",
    "size_gigabytes": 200,
    "region": "nyc3"
  }' \
  "https://api.digitalocean.com/v2/volumes/VOLUME_ID/actions"
```

### Resize Filesystem

```bash
# For ext4 filesystem
sudo resize2fs /dev/disk/by-id/scsi-0DO_Volume_db-data

# For XFS filesystem
sudo xfs_growfs /mnt/db-data

# Verify new size
df -h /mnt/db-data
```

**Note**: Volumes can only be increased in size, not decreased.

## Snapshots

### Creating Snapshots

```bash
# Via doctl
doctl compute volume-snapshot create \
  --volume-id VOLUME_ID \
  --snapshot-name "db-data-backup-2026-01-10"

# List snapshots
doctl compute volume-snapshot list

# Delete snapshot
doctl compute volume-snapshot delete SNAPSHOT_ID
```

### Restoring from Snapshot

```bash
# Create new volume from snapshot
doctl compute volume create db-data-restored \
  --region nyc3 \
  --snapshot-id SNAPSHOT_ID

# Attach to Droplet
doctl compute volume-action attach VOLUME_ID DROPLET_ID

# Mount volume
sudo mount /dev/disk/by-id/scsi-0DO_Volume_db-data-restored /mnt/restored
```

## Kubernetes Integration

### Storage Class

```yaml
# Default storage class (pre-configured)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: do-block-storage
provisioner: dobs.csi.digitalocean.com
parameters:
  type: pd-ssd
allowVolumeExpansion: true
```

### Persistent Volume Claim

```yaml
# Request persistent storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: do-block-storage
```

### Using in Pod

```yaml
# StatefulSet with persistent storage
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          value: "password"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: do-block-storage
      resources:
        requests:
          storage: 10Gi
```

### Volume Expansion

```bash
# Edit PVC to increase size
kubectl edit pvc postgres-pvc

# Change storage request
spec:
  resources:
    requests:
      storage: 20Gi  # Increased from 10Gi

# Verify expansion
kubectl get pvc postgres-pvc
```

## Database Configuration

### PostgreSQL

```bash
# Stop PostgreSQL
sudo systemctl stop postgresql

# Move data to volume
sudo rsync -av /var/lib/postgresql/ /mnt/db-data/

# Update PostgreSQL config
sudo nano /etc/postgresql/15/main/postgresql.conf
# Change: data_directory = '/mnt/db-data/15/main'

# Update permissions
sudo chown -R postgres:postgres /mnt/db-data

# Start PostgreSQL
sudo systemctl start postgresql
```

### MySQL/MariaDB

```bash
# Stop MySQL
sudo systemctl stop mysql

# Move data to volume
sudo rsync -av /var/lib/mysql/ /mnt/db-data/

# Update MySQL config
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Change: datadir = /mnt/db-data

# Update AppArmor (Ubuntu)
sudo nano /etc/apparmor.d/usr.sbin.mysqld
# Add: /mnt/db-data/ r,
#      /mnt/db-data/** rwk,

sudo systemctl reload apparmor

# Start MySQL
sudo systemctl start mysql
```

### MongoDB

```bash
# Stop MongoDB
sudo systemctl stop mongod

# Move data to volume
sudo rsync -av /var/lib/mongodb/ /mnt/db-data/

# Update MongoDB config
sudo nano /etc/mongod.conf
# Change: dbPath: /mnt/db-data

# Update permissions
sudo chown -R mongodb:mongodb /mnt/db-data

# Start MongoDB
sudo systemctl start mongod
```

## Performance Optimization

### Best Practices

```
1. Use Appropriate Filesystem
   ├─> ext4: General purpose
   ├─> XFS: Large files, databases
   └─> Avoid: FAT32, NTFS

2. Enable Discard/TRIM
   ├─> Mount option: discard
   ├─> Improves performance
   └─> Reduces wear

3. Optimize I/O Scheduler
   ├─> Use deadline or noop
   ├─> Better for SSDs
   └─> Reduces latency

4. Monitor Performance
   ├─> iostat
   ├─> iotop
   └─> DigitalOcean metrics

5. Right-Size Volumes
   ├─> Don't over-provision
   ├─> Monitor usage
   └─> Resize as needed
```

### I/O Scheduler Configuration

```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler

# Set to deadline (recommended for volumes)
echo deadline | sudo tee /sys/block/sda/queue/scheduler

# Make permanent
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="deadline"' | sudo tee /etc/udev/rules.d/60-scheduler.rules
```

## Monitoring

### Check Volume Usage

```bash
# Disk usage
df -h /mnt/db-data

# Inode usage
df -i /mnt/db-data

# Detailed usage
du -sh /mnt/db-data/*
```

### I/O Performance

```bash
# Install iostat
sudo apt-get install sysstat

# Monitor I/O
iostat -x 1

# Monitor specific device
iostat -x /dev/sda 1

# Top I/O processes
sudo iotop
```

### DigitalOcean Metrics

```bash
# Via doctl
doctl compute volume get VOLUME_ID

# View in control panel
# Navigate to Volumes → Select Volume → Graphs
```

## Backup Strategies

### 1. Volume Snapshots

```bash
# Automated snapshot script
#!/bin/bash
VOLUME_ID="your-volume-id"
DATE=$(date +%Y%m%d-%H%M%S)

doctl compute volume-snapshot create \
  --volume-id $VOLUME_ID \
  --snapshot-name "backup-$DATE"

# Keep only last 7 snapshots
doctl compute volume-snapshot list --format ID,Created | \
  tail -n +8 | \
  awk '{print $1}' | \
  xargs -I {} doctl compute volume-snapshot delete {}
```

### 2. Application-Level Backups

```bash
# PostgreSQL backup to volume
pg_dump dbname | gzip > /mnt/db-data/backups/db-$(date +%Y%m%d).sql.gz

# MySQL backup to volume
mysqldump --all-databases | gzip > /mnt/db-data/backups/db-$(date +%Y%m%d).sql.gz

# MongoDB backup to volume
mongodump --out /mnt/db-data/backups/mongo-$(date +%Y%m%d)
```

### 3. Sync to Spaces

```bash
# Install s3cmd
sudo apt-get install s3cmd

# Configure s3cmd
s3cmd --configure

# Sync volume to Spaces
s3cmd sync /mnt/db-data/ s3://my-bucket/backups/
```

## Cost Optimization

### Strategies

```
1. Right-Size Volumes
   ├─> Monitor actual usage
   ├─> Don't over-provision
   └─> Start small, grow as needed

2. Delete Unused Volumes
   ├─> Identify detached volumes
   ├─> Remove old test volumes
   └─> Clean up regularly

3. Manage Snapshots
   ├─> Delete old snapshots
   ├─> Keep only necessary backups
   └─> Automate retention policy

4. Use Appropriate Storage
   ├─> Volumes for persistent data
   ├─> Local storage for temporary
   └─> Spaces for archives

5. Monitor Costs
   ├─> Track volume count
   ├─> Monitor snapshot usage
   └─> Review monthly bills
```

### Cost Calculation

```
Volume Pricing: $0.10/GB/month

Examples:
├─> 10 GB volume: $1/month
├─> 100 GB volume: $10/month
├─> 1 TB volume: $100/month
└─> 16 TB volume: $1,600/month

Snapshots: $0.05/GB/month
├─> 100 GB snapshot: $5/month
└─> Cheaper than keeping volume
```

## Troubleshooting

### Volume Not Visible

```bash
# Check if attached
doctl compute volume list

# Check device
lsblk

# Check dmesg
dmesg | grep sd

# Rescan SCSI bus
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
```

### Mount Failures

```bash
# Check filesystem
sudo fsck /dev/disk/by-id/scsi-0DO_Volume_db-data

# Check fstab
cat /etc/fstab

# Try manual mount
sudo mount -v /dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data

# Check mount options
mount | grep db-data
```

### Performance Issues

```bash
# Check I/O wait
top
# Look for high %wa

# Check disk I/O
iostat -x 1

# Check for errors
dmesg | grep error

# Verify mount options
mount | grep db-data
# Should include: discard
```

## Limitations

- **Attachment**: One volume per Droplet at a time
- **Region**: Must be in same region as Droplet
- **Size**: 1 GB minimum, 16 TB maximum
- **Resize**: Can only increase, not decrease
- **Access Mode**: ReadWriteOnce (single Droplet)
- **Snapshots**: Charged at $0.05/GB/month

## Pricing

```
Volume Storage: $0.10/GB/month
├─> 10 GB: $1/month
├─> 100 GB: $10/month
└─> 1 TB: $100/month

Snapshots: $0.05/GB/month
├─> 50% of volume cost
└─> Good for backups

No additional charges for:
├─> Attachment/detachment
├─> I/O operations
└─> Data transfer
```

## Documentation Structure

1. **[Volumes Overview](./0-VOLUMES-OVERVIEW.md)** - This page
2. **[Creating Volumes](./1-CREATING-VOLUMES.md)** - Setup guide
3. **[Managing Volumes](./2-MANAGING-VOLUMES.md)** - Operations
4. **[Kubernetes Volumes](./3-KUBERNETES-VOLUMES.md)** - K8s integration

## Next Steps

- [Create your first volume](./1-CREATING-VOLUMES.md)
- [Learn volume management](./2-MANAGING-VOLUMES.md)
- [Use with Kubernetes](./3-KUBERNETES-VOLUMES.md)

## Additional Resources

- [Official Documentation](https://docs.digitalocean.com/products/volumes/)
- [API Reference](https://docs.digitalocean.com/reference/api/api-reference/#tag/Block-Storage)
- [Community Tutorials](https://www.digitalocean.com/community/tags/block-storage)
