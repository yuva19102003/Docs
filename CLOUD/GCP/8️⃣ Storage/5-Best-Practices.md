# Storage Services - Best Practices

Production-ready guidelines for all GCP storage services.

---

## 📋 Table of Contents

1. [General Best Practices](#general-best-practices)
2. [Cloud Storage](#cloud-storage)
3. [Persistent Disk](#persistent-disk)
4. [Filestore](#filestore)
5. [Security](#security)
6. [Performance](#performance)
7. [Cost Optimization](#cost-optimization)
8. [Disaster Recovery](#disaster-recovery)
9. [Monitoring & Operations](#monitoring--operations)

---

## General Best Practices

### Architecture

✅ Choose the right storage type for your use case  
✅ Design for failure and redundancy  
✅ Implement proper backup strategies  
✅ Use appropriate storage classes/tiers  
✅ Plan for data growth  
✅ Implement lifecycle management  
✅ Use encryption at rest  
✅ Enable versioning for critical data  
✅ Tag resources for cost tracking  
✅ Document storage architecture  

### Data Management

✅ Implement data retention policies  
✅ Regular data cleanup  
✅ Use lifecycle policies  
✅ Monitor storage usage  
✅ Implement data classification  
✅ Use appropriate access controls  
✅ Regular backup testing  
✅ Plan for disaster recovery  
✅ Document data flows  
✅ Implement data governance  

### Operations

✅ Automate storage provisioning  
✅ Use infrastructure as code  
✅ Implement monitoring and alerting  
✅ Regular capacity planning  
✅ Performance testing  
✅ Security audits  
✅ Cost optimization reviews  
✅ Disaster recovery drills  
✅ Documentation updates  
✅ Team training  

---

## Cloud Storage

### Bucket Configuration

```bash
# Create production bucket with best practices
gsutil mb -l us-central1 -c STANDARD gs://prod-bucket

# Enable versioning
gsutil versioning set on gs://prod-bucket

# Set lifecycle policy
gsutil lifecycle set lifecycle.json gs://prod-bucket

# Enable uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://prod-bucket

# Set labels
gsutil label set labels.json gs://prod-bucket
```

**lifecycle.json:**
```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30, "matchesStorageClass": ["STANDARD"]}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90, "matchesStorageClass": ["NEARLINE"]}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 365, "matchesStorageClass": ["COLDLINE"]}
      }
    ]
  }
}
```

### Access Control

✅ Use IAM for access control  
✅ Enable uniform bucket-level access  
✅ Use signed URLs for temporary access  
✅ Implement least privilege  
✅ Regular access reviews  
✅ Use service accounts  
✅ Enable audit logging  
✅ Use VPC Service Controls  

### Performance

✅ Use regional buckets for better performance  
✅ Use Cloud CDN for static content  
✅ Enable parallel uploads/downloads  
✅ Optimize object sizes  
✅ Use appropriate storage class  
✅ Implement caching strategies  
✅ Use compression  
✅ Monitor performance metrics  

### Cost Optimization

```bash
# Analyze storage usage
gsutil du -sh gs://my-bucket/

# Check storage class distribution
gsutil ls -L -b gs://my-bucket/

# Set lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-bucket

# Enable requester pays (for public data)
gsutil requesterpays set on gs://my-bucket
```

✅ Use lifecycle policies  
✅ Delete old versions  
✅ Use appropriate storage class  
✅ Enable compression  
✅ Delete unused buckets  
✅ Use requester pays for public data  
✅ Monitor and optimize egress  
✅ Use Cloud CDN to reduce egress  

### Terraform Example

```hcl
resource "google_storage_bucket" "production" {
  name          = "prod-bucket"
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
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
  
  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_key.id
  }
  
  labels = {
    environment = "production"
    team        = "platform"
    cost_center = "engineering"
  }
}
```

---

## Persistent Disk

### Disk Configuration

```bash
# Create production disk with best practices
gcloud compute disks create prod-disk \
  --size=500GB \
  --type=pd-ssd \
  --zone=us-central1-a \
  --labels=env=prod,team=backend

# Create snapshot schedule
gcloud compute resource-policies create snapshot-schedule daily-backup \
  --region=us-central1 \
  --max-retention-days=7 \
  --on-source-disk-delete=keep-auto-snapshots \
  --daily-schedule \
  --start-time=02:00

# Attach schedule to disk
gcloud compute disks add-resource-policies prod-disk \
  --resource-policies=daily-backup \
  --zone=us-central1-a
```

### Performance

✅ Use SSD for databases  
✅ Size disk for required IOPS  
✅ Use Local SSD for temporary high-performance needs  
✅ Use pd-extreme for highest performance  
✅ Monitor disk performance  
✅ Use appropriate machine type  
✅ Enable discard/TRIM  
✅ Use multiple disks for higher throughput  

### Reliability

✅ Use regional disks for critical data  
✅ Implement automated snapshots  
✅ Test restore procedures  
✅ Use snapshot schedules  
✅ Keep snapshots in multiple regions  
✅ Monitor disk health  
✅ Plan for disaster recovery  
✅ Document backup procedures  

### Security

```bash
# Create disk with CMEK
gcloud compute disks create encrypted-disk \
  --size=100GB \
  --type=pd-ssd \
  --zone=us-central1-a \
  --kms-key=projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key

# Grant service account access to key
gcloud kms keys add-iam-policy-binding my-key \
  --location=us-central1 \
  --keyring=my-keyring \
  --member="serviceAccount:service-PROJECT_NUMBER@compute-system.iam.gserviceaccount.com" \
  --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
```

✅ Use CMEK for sensitive data  
✅ Enable audit logging  
✅ Use IAM for access control  
✅ Regular security audits  
✅ Encrypt snapshots  
✅ Use VPC Service Controls  
✅ Implement least privilege  

### Cost Optimization

✅ Right-size disk capacity  
✅ Delete unused disks  
✅ Use appropriate disk type  
✅ Use snapshots for backups  
✅ Monitor costs  
✅ Use committed use discounts  
✅ Implement lifecycle policies  
✅ Use pd-balanced instead of pd-ssd when possible  

### Terraform Example

```hcl
resource "google_compute_disk" "production" {
  name  = "prod-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size  = 500
  
  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.disk_key.id
  }
  
  labels = {
    environment = "production"
    team        = "backend"
    backup      = "daily"
  }
}

resource "google_compute_resource_policy" "daily_backup" {
  name   = "daily-backup"
  region = "us-central1"
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "02:00"
      }
    }
    
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    
    snapshot_properties {
      labels = {
        backup_type = "automated"
      }
      storage_locations = ["us"]
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name = google_compute_resource_policy.daily_backup.name
  disk = google_compute_disk.production.name
  zone = "us-central1-a"
}
```

---

## Filestore

### Instance Configuration

```bash
# Create production Filestore instance
gcloud filestore instances create prod-filestore \
  --zone=us-central1-a \
  --tier=BASIC_SSD \
  --file-share=name=vol1,capacity=2560GB \
  --network=name=prod-vpc \
  --labels=env=prod,team=backend

# Create backup
gcloud filestore backups create prod-backup \
  --instance=prod-filestore \
  --instance-zone=us-central1-a \
  --file-share=vol1 \
  --region=us-central1
```

### Mounting

```bash
# Production mount script
#!/bin/bash

# Install NFS client
apt-get update
apt-get install -y nfs-common

# Create mount point
mkdir -p /mnt/filestore

# Get Filestore IP
FILESTORE_IP=$(gcloud filestore instances describe prod-filestore \
  --zone=us-central1-a \
  --format="value(networks[0].ipAddresses[0])")

# Mount with recommended options
mount -t nfs \
  -o rw,hard,intr,timeo=600,retrans=2,_netdev \
  ${FILESTORE_IP}:/vol1 /mnt/filestore

# Add to fstab
echo "${FILESTORE_IP}:/vol1 /mnt/filestore nfs rw,hard,intr,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab

# Set permissions
chmod 755 /mnt/filestore
```

### Performance

✅ Use appropriate tier for workload  
✅ Use multiple clients for higher throughput  
✅ Use recommended mount options  
✅ Monitor performance metrics  
✅ Optimize file operations  
✅ Use parallel operations  
✅ Test performance before production  
✅ Use High Scale for extreme performance  

### Reliability

✅ Use Enterprise tier for critical data  
✅ Implement regular backups  
✅ Test restore procedures  
✅ Monitor instance health  
✅ Use multiple mount points  
✅ Implement retry logic  
✅ Plan for disaster recovery  
✅ Document procedures  

### Security

```bash
# Create Filestore in custom VPC
gcloud filestore instances create secure-filestore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB \
  --network=name=secure-vpc

# Create firewall rule
gcloud compute firewall-rules create allow-nfs-from-clients \
  --network=secure-vpc \
  --allow=tcp:2049,tcp:111,udp:2049,udp:111 \
  --source-ranges=10.0.0.0/24 \
  --target-tags=filestore-client
```

✅ Use custom VPC  
✅ Implement firewall rules  
✅ Use IAM for access control  
✅ Set appropriate file permissions  
✅ Enable audit logging  
✅ Regular security audits  
✅ Use VPN for remote access  
✅ Implement least privilege  

### Cost Optimization

✅ Right-size capacity  
✅ Use appropriate tier  
✅ Delete unused instances  
✅ Monitor utilization  
✅ Implement lifecycle policies  
✅ Regular cost reviews  
✅ Use committed use discounts  
✅ Use Basic HDD when possible  

---

## Security

### Encryption

**Cloud Storage:**
```bash
# Use CMEK
gsutil kms encryption \
  -k projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key \
  gs://my-bucket
```

**Persistent Disk:**
```bash
# Create disk with CMEK
gcloud compute disks create encrypted-disk \
  --size=100GB \
  --kms-key=projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key \
  --zone=us-central1-a
```

### Access Control

**IAM Best Practices:**
```bash
# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:app-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Use conditions
gcloud storage buckets add-iam-policy-binding gs://my-bucket \
  --member="user:user@example.com" \
  --role="roles/storage.objectViewer" \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=temporary-access'
```

### Audit Logging

```bash
# Enable audit logs
gcloud logging read "resource.type=gcs_bucket" --limit=50

# Create log-based metric
gcloud logging metrics create storage_access_count \
  --description="Count of storage access" \
  --log-filter='resource.type="gcs_bucket" AND protoPayload.methodName="storage.objects.get"'
```

### VPC Service Controls

```bash
# Create access policy
gcloud access-context-manager policies create \
  --organization=ORGANIZATION_ID \
  --title="Storage Access Policy"

# Create service perimeter
gcloud access-context-manager perimeters create storage_perimeter \
  --policy=POLICY_ID \
  --title="Storage Perimeter" \
  --resources=projects/PROJECT_NUMBER \
  --restricted-services=storage.googleapis.com
```

---

## Performance

### Cloud Storage

```bash
# Parallel uploads
gsutil -m cp -r directory/ gs://my-bucket/

# Composite uploads for large files
gsutil -o GSUtil:parallel_composite_upload_threshold=150M \
  cp large-file.dat gs://my-bucket/

# Sliced downloads
gsutil -o GSUtil:sliced_object_download_threshold=150M \
  cp gs://my-bucket/large-file.dat .
```

### Persistent Disk

```bash
# Create high-performance disk
gcloud compute disks create high-perf-disk \
  --size=1000GB \
  --type=pd-ssd \
  --zone=us-central1-a

# Use multiple disks for RAID
gcloud compute instances create high-perf-vm \
  --zone=us-central1-a \
  --machine-type=n2-standard-16 \
  --create-disk=size=500GB,type=pd-ssd \
  --create-disk=size=500GB,type=pd-ssd \
  --create-disk=size=500GB,type=pd-ssd
```

### Filestore

```bash
# Use High Scale for extreme performance
gcloud filestore instances create high-perf-filestore \
  --zone=us-central1-a \
  --tier=HIGH_SCALE_SSD \
  --file-share=name=vol1,capacity=10TB \
  --network=name=default
```

---

## Cost Optimization

### Storage Cost Analysis

```bash
# Cloud Storage usage
gsutil du -sh gs://my-bucket/

# Persistent Disk usage
gcloud compute disks list --format="table(name,sizeGb,type,zone)"

# Filestore usage
gcloud filestore instances list --format="table(name,tier,fileShares[0].capacityGb,zone)"
```

### Optimization Strategies

**Cloud Storage:**
```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 365, "numNewerVersions": 0}
      }
    ]
  }
}
```

**Persistent Disk:**
```bash
# Delete unused disks
gcloud compute disks list --filter="users:*" --format="value(name,zone)" | \
  while read disk zone; do
    if [ -z "$disk" ]; then
      gcloud compute disks delete $disk --zone=$zone --quiet
    fi
  done

# Use snapshots instead of full copies
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a
```

---

## Disaster Recovery

### Backup Strategy

**Cloud Storage:**
```bash
# Enable versioning
gsutil versioning set on gs://my-bucket

# Cross-region replication (manual)
gsutil -m rsync -r gs://source-bucket/ gs://backup-bucket/
```

**Persistent Disk:**
```bash
# Automated snapshots
gcloud compute resource-policies create snapshot-schedule dr-backup \
  --region=us-central1 \
  --max-retention-days=30 \
  --on-source-disk-delete=keep-auto-snapshots \
  --daily-schedule \
  --start-time=02:00 \
  --storage-location=us
```

**Filestore:**
```bash
# Regular backups
gcloud filestore backups create backup-$(date +%Y%m%d) \
  --instance=my-filestore \
  --instance-zone=us-central1-a \
  --file-share=vol1 \
  --region=us-central1
```

### Recovery Testing

```bash
# Test Cloud Storage restore
gsutil cp gs://my-bucket/file.txt#VERSION .

# Test Persistent Disk restore
gcloud compute disks create test-restore \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a

# Test Filestore restore
gcloud filestore instances create test-restore \
  --zone=us-central1-a \
  --tier=BASIC_HDD \
  --file-share=name=vol1,capacity=1TB,source-backup=my-backup \
  --network=name=default
```

---

## Monitoring & Operations

### Cloud Monitoring

```bash
# View storage metrics
gcloud monitoring time-series list \
  --filter='metric.type="storage.googleapis.com/storage/total_bytes"'

# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Storage Usage" \
  --condition-display-name="Storage > 80%" \
  --condition-threshold-value=0.8
```

### Logging

```bash
# View Cloud Storage logs
gcloud logging read "resource.type=gcs_bucket" --limit=50

# View Persistent Disk logs
gcloud logging read "resource.type=gce_disk" --limit=50

# Create log sink
gcloud logging sinks create storage-logs \
  storage.googleapis.com/my-logs-bucket \
  --log-filter='resource.type="gcs_bucket"'
```

### Automation

**Terraform Module:**
```hcl
module "storage" {
  source = "./modules/storage"
  
  project_id = var.project_id
  region     = var.region
  
  buckets = {
    prod = {
      location      = "US"
      storage_class = "STANDARD"
      versioning    = true
      lifecycle_rules = [
        {
          age           = 30
          storage_class = "NEARLINE"
        }
      ]
    }
  }
  
  disks = {
    prod = {
      size = 500
      type = "pd-ssd"
      zone = "us-central1-a"
    }
  }
}
```

---

## Summary

### Key Takeaways

✅ Choose the right storage type for your use case  
✅ Implement proper security controls  
✅ Use lifecycle management  
✅ Regular backups and testing  
✅ Monitor performance and costs  
✅ Automate operations  
✅ Document procedures  
✅ Regular reviews and optimization  

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
