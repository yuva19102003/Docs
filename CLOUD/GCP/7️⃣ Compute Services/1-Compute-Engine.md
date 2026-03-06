# Compute Engine - Virtual Machines on GCP

Complete guide to Google Compute Engine (GCE) - Infrastructure as a Service.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Machine Types](#machine-types)
3. [Instance Creation](#instance-creation)
4. [Storage Options](#storage-options)
5. [Networking](#networking)
6. [Instance Management](#instance-management)
7. [Auto Scaling](#auto-scaling)
8. [Cost Optimization](#cost-optimization)
9. [Security](#security)
10. [Monitoring](#monitoring)
11. [Best Practices](#best-practices)

---

## Introduction

Google Compute Engine provides scalable, high-performance virtual machines running in Google's data centers.

### Key Features

✅ Custom machine types  
✅ Preemptible and Spot VMs  
✅ Live migration  
✅ Automatic sustained use discounts  
✅ Per-second billing  
✅ Global load balancing  
✅ Persistent disks  
✅ Local SSDs  
✅ GPU and TPU support  
✅ Windows and Linux support  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│              Compute Engine Instance                │
├─────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────┐   │
│  │  Your Application                            │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Operating System (Linux/Windows)            │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Virtual Hardware                            │   │
│  │  - vCPUs (up to 416)                         │   │
│  │  - Memory (up to 12 TB)                      │   │
│  │  - GPUs (optional)                           │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Storage                                     │   │
│  │  - Boot disk (Persistent)                    │   │
│  │  - Additional disks                          │   │
│  │  - Local SSDs (optional)                     │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Networking                                  │   │
│  │  - VPC network                               │   │
│  │  - Internal/External IP                      │   │
│  │  - Firewall rules                            │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Machine Types

### Machine Type Families

**General Purpose (E2, N2, N2D, N1)**
- Balanced CPU and memory
- Web servers, small databases
- Development environments

**Compute Optimized (C2, C2D, C3)**
- High CPU-to-memory ratio
- Gaming servers, HPC
- Batch processing

**Memory Optimized (M1, M2, M3)**
- High memory-to-CPU ratio
- In-memory databases
- SAP HANA, analytics

**Accelerator Optimized (A2, A3, G2)**
- GPU/TPU attached
- Machine learning
- Graphics rendering

### Machine Type Comparison

| Family | vCPUs | Memory | Use Case | Cost |
|--------|-------|--------|----------|------|
| **e2-micro** | 0.25-2 | 0.5-8 GB | Free tier, dev | $ |
| **e2-standard** | 2-32 | 8-128 GB | General purpose | $$ |
| **n2-standard** | 2-128 | 8-512 GB | Balanced workloads | $$$ |
| **c2-standard** | 4-60 | 16-240 GB | Compute intensive | $$$$ |
| **m2-ultramem** | 208-416 | 5.9-12 TB | Memory intensive | $$$$$ |

### Custom Machine Types

Create machines with specific vCPU and memory combinations:

```bash
# Create custom machine type
gcloud compute instances create custom-vm \
  --custom-cpu=4 \
  --custom-memory=15GB \
  --zone=us-central1-a
```

**Custom Machine Rules:**
- 1 vCPU per 0.9 GB to 8 GB memory
- Must be in 256 MB increments
- Available in most machine families

---

## Instance Creation

### Basic Instance Creation

```bash
# Create basic instance
gcloud compute instances create my-instance \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-standard
```

### Advanced Instance Creation

```bash
# Create instance with all options
gcloud compute instances create advanced-instance \
  --zone=us-central1-a \
  --machine-type=n2-standard-4 \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=50GB \
  --boot-disk-type=pd-ssd \
  --network=my-vpc \
  --subnet=my-subnet \
  --private-network-ip=10.0.1.10 \
  --no-address \
  --tags=web-server,https-server \
  --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx' \
  --service-account=my-sa@project.iam.gserviceaccount.com \
  --scopes=cloud-platform \
  --labels=env=prod,team=backend
```

### Terraform Example

```hcl
resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("startup.sh")

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  tags = ["web-server", "http-server"]

  labels = {
    environment = "production"
    team        = "backend"
  }
}
```

---

## Storage Options

### Persistent Disks

**Standard Persistent Disk (pd-standard)**
- HDD-backed storage
- $0.04/GB/month
- Good for sequential I/O
- Up to 64 TB per disk

**SSD Persistent Disk (pd-ssd)**
- SSD-backed storage
- $0.17/GB/month
- High IOPS
- Up to 64 TB per disk

**Balanced Persistent Disk (pd-balanced)**
- SSD-backed storage
- $0.10/GB/month
- Balance of performance and cost
- Up to 64 TB per disk

**Extreme Persistent Disk (pd-extreme)**
- Highest performance SSD
- $0.125/GB/month + $0.065/provisioned IOPS
- Configurable IOPS
- Up to 64 TB per disk

### Local SSDs

```bash
# Create instance with local SSD
gcloud compute instances create ssd-instance \
  --zone=us-central1-a \
  --machine-type=n2-standard-4 \
  --local-ssd=interface=NVME \
  --local-ssd=interface=NVME
```

**Local SSD Characteristics:**
- 375 GB per device
- Up to 24 devices (9 TB total)
- Very high IOPS (680,000 read, 360,000 write)
- Data lost on instance stop/delete
- $0.08/GB/month

### Disk Management

```bash
# Create persistent disk
gcloud compute disks create my-disk \
  --size=100GB \
  --type=pd-ssd \
  --zone=us-central1-a

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
  --disk=my-disk \
  --zone=us-central1-a

# Detach disk
gcloud compute instances detach-disk my-instance \
  --disk=my-disk \
  --zone=us-central1-a

# Resize disk
gcloud compute disks resize my-disk \
  --size=200GB \
  --zone=us-central1-a

# Create snapshot
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a

# Create disk from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a
```

### Storage Performance

| Disk Type | Read IOPS | Write IOPS | Throughput | Use Case |
|-----------|-----------|------------|------------|----------|
| **pd-standard** | 0.75/GB | 1.5/GB | 120-240 MB/s | Backups, archives |
| **pd-balanced** | 6/GB | 6/GB | 240-480 MB/s | General purpose |
| **pd-ssd** | 30/GB | 30/GB | 480-960 MB/s | Databases |
| **pd-extreme** | Configurable | Configurable | 2,400-4,800 MB/s | High performance |
| **Local SSD** | 680,000 | 360,000 | 2,400-9,600 MB/s | Caching, temp data |

---

## Networking

### Network Interfaces

```bash
# Create instance with multiple NICs
gcloud compute instances create multi-nic-instance \
  --zone=us-central1-a \
  --machine-type=n2-standard-4 \
  --network-interface=network=vpc1,subnet=subnet1 \
  --network-interface=network=vpc2,subnet=subnet2,no-address
```

**Network Interface Limits:**
- Depends on machine type
- e2-micro: 2 NICs
- n2-standard-4: 4 NICs
- n2-standard-32: 8 NICs

### IP Addressing

**Internal IP:**
- Assigned from subnet range
- Used for VPC communication
- Can be ephemeral or static

**External IP:**
- Public IP address
- Optional (can use Cloud NAT instead)
- Can be ephemeral or static

```bash
# Reserve static external IP
gcloud compute addresses create my-static-ip \
  --region=us-central1

# Assign to instance
gcloud compute instances add-access-config my-instance \
  --access-config-name="External NAT" \
  --address=STATIC_IP_ADDRESS \
  --zone=us-central1-a

# Reserve static internal IP
gcloud compute addresses create my-internal-ip \
  --region=us-central1 \
  --subnet=my-subnet \
  --addresses=10.0.1.100
```

### Firewall Rules

```bash
# Allow HTTP traffic
gcloud compute firewall-rules create allow-http \
  --network=default \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

# Allow SSH from specific IP
gcloud compute firewall-rules create allow-ssh-admin \
  --network=default \
  --allow=tcp:22 \
  --source-ranges=203.0.113.0/24 \
  --target-tags=admin-access

# Allow internal communication
gcloud compute firewall-rules create allow-internal \
  --network=my-vpc \
  --allow=tcp,udp,icmp \
  --source-ranges=10.0.0.0/8
```

---

## Instance Management

### Start, Stop, Reset

```bash
# Stop instance
gcloud compute instances stop my-instance \
  --zone=us-central1-a

# Start instance
gcloud compute instances start my-instance \
  --zone=us-central1-a

# Reset instance (hard reboot)
gcloud compute instances reset my-instance \
  --zone=us-central1-a

# Suspend instance (save RAM to disk)
gcloud compute instances suspend my-instance \
  --zone=us-central1-a

# Resume instance
gcloud compute instances resume my-instance \
  --zone=us-central1-a
```

### SSH Access

```bash
# SSH into instance
gcloud compute ssh my-instance \
  --zone=us-central1-a

# SSH with specific user
gcloud compute ssh user@my-instance \
  --zone=us-central1-a

# SSH with port forwarding
gcloud compute ssh my-instance \
  --zone=us-central1-a \
  -- -L 8080:localhost:80

# Copy files to instance
gcloud compute scp local-file.txt my-instance:~/remote-file.txt \
  --zone=us-central1-a

# Copy files from instance
gcloud compute scp my-instance:~/remote-file.txt ./local-file.txt \
  --zone=us-central1-a
```

### Metadata and Startup Scripts

```bash
# Set metadata
gcloud compute instances add-metadata my-instance \
  --zone=us-central1-a \
  --metadata=key1=value1,key2=value2

# Set startup script
gcloud compute instances add-metadata my-instance \
  --zone=us-central1-a \
  --metadata-from-file=startup-script=startup.sh

# View metadata from instance
curl -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/
```

**Startup Script Example:**

```bash
#!/bin/bash
# startup.sh

# Update system
apt-get update
apt-get upgrade -y

# Install packages
apt-get install -y nginx docker.io

# Configure application
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    location / {
        proxy_pass http://localhost:8080;
    }
}
EOF

# Start services
systemctl enable nginx
systemctl start nginx

# Log completion
echo "Startup script completed" >> /var/log/startup.log
```

### Instance Templates

```bash
# Create instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --network=default \
  --tags=web-server \
  --metadata-from-file=startup-script=startup.sh

# Create instance from template
gcloud compute instances create web-1 \
  --source-instance-template=web-template \
  --zone=us-central1-a

# Update template (create new version)
gcloud compute instance-templates create web-template-v2 \
  --machine-type=e2-standard-2 \
  --image-family=debian-11 \
  --image-project=debian-cloud
```

---

## Auto Scaling

### Managed Instance Groups (MIG)

```bash
# Create instance group
gcloud compute instance-groups managed create web-group \
  --base-instance-name=web \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a

# Set autoscaling
gcloud compute instance-groups managed set-autoscaling web-group \
  --zone=us-central1-a \
  --min-num-replicas=2 \
  --max-num-replicas=10 \
  --target-cpu-utilization=0.6 \
  --cool-down-period=90

# Update instances (rolling update)
gcloud compute instance-groups managed rolling-action start-update web-group \
  --version=template=web-template-v2 \
  --zone=us-central1-a \
  --max-surge=3 \
  --max-unavailable=0
```

### Regional MIG (Multi-Zone)

```bash
# Create regional instance group
gcloud compute instance-groups managed create web-group-regional \
  --base-instance-name=web \
  --template=web-template \
  --size=6 \
  --region=us-central1 \
  --distribution-policy-zones=us-central1-a,us-central1-b,us-central1-c

# Set autoscaling
gcloud compute instance-groups managed set-autoscaling web-group-regional \
  --region=us-central1 \
  --min-num-replicas=3 \
  --max-num-replicas=30 \
  --target-cpu-utilization=0.6
```

### Health Checks

```bash
# Create health check
gcloud compute health-checks create http web-health-check \
  --port=80 \
  --request-path=/ \
  --check-interval=10s \
  --timeout=5s \
  --unhealthy-threshold=3 \
  --healthy-threshold=2

# Apply health check to MIG
gcloud compute instance-groups managed set-autohealing web-group \
  --health-check=web-health-check \
  --initial-delay=300 \
  --zone=us-central1-a
```

### Load Balancing

```bash
# Create backend service
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --health-checks=web-health-check \
  --global

# Add instance group to backend
gcloud compute backend-services add-backend web-backend \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --balancing-mode=UTILIZATION \
  --max-utilization=0.8 \
  --global

# Create URL map
gcloud compute url-maps create web-map \
  --default-service=web-backend

# Create HTTP proxy
gcloud compute target-http-proxies create web-proxy \
  --url-map=web-map

# Create forwarding rule
gcloud compute forwarding-rules create web-forwarding-rule \
  --global \
  --target-http-proxy=web-proxy \
  --ports=80
```

---

## Cost Optimization

### Pricing Models

**On-Demand Pricing:**
- Pay per second (minimum 1 minute)
- No upfront commitment
- Most flexible

**Committed Use Discounts (CUD):**
- 1-year or 3-year commitment
- Up to 57% discount
- Applies automatically

**Sustained Use Discounts (SUD):**
- Automatic discounts
- Up to 30% off
- Based on monthly usage

**Spot VMs (formerly Preemptible):**
- Up to 91% discount
- Can be terminated anytime
- 24-hour maximum runtime (preemptible)
- No maximum runtime (Spot)

### Cost Comparison Example

**n2-standard-4 in us-central1:**

| Pricing Model | Hourly Cost | Monthly Cost | Savings |
|---------------|-------------|--------------|---------|
| On-Demand | $0.194 | $141.62 | 0% |
| 1-Year CUD | $0.126 | $91.98 | 35% |
| 3-Year CUD | $0.090 | $65.70 | 54% |
| Spot VM | $0.046 | $33.58 | 76% |

### Spot VMs

```bash
# Create Spot VM
gcloud compute instances create spot-instance \
  --zone=us-central1-a \
  --machine-type=n2-standard-4 \
  --provisioning-model=SPOT \
  --instance-termination-action=STOP

# Create preemptible VM (legacy)
gcloud compute instances create preemptible-instance \
  --zone=us-central1-a \
  --machine-type=n2-standard-4 \
  --preemptible
```

**Spot VM Best Practices:**
- Use for fault-tolerant workloads
- Implement checkpointing
- Use with batch processing
- Handle termination gracefully
- Use instance groups for automatic restart

### Right-Sizing Recommendations

```bash
# Get recommendations
gcloud recommender recommendations list \
  --project=my-project \
  --location=us-central1-a \
  --recommender=google.compute.instance.MachineTypeRecommender

# Apply recommendation
gcloud compute instances stop my-instance --zone=us-central1-a
gcloud compute instances set-machine-type my-instance \
  --machine-type=e2-medium \
  --zone=us-central1-a
gcloud compute instances start my-instance --zone=us-central1-a
```

### Cost Optimization Strategies

✅ Use committed use discounts for predictable workloads
✅ Use Spot VMs for batch processing
✅ Right-size instances based on actual usage
✅ Use sustained use discounts (automatic)
✅ Stop instances when not needed
✅ Use preemptible VMs for dev/test
✅ Use custom machine types for exact requirements
✅ Use appropriate disk types
✅ Delete unused persistent disks
✅ Use snapshots for backups (cheaper than disks)

---

## Security

### Service Accounts

```bash
# Create service account
gcloud iam service-accounts create compute-sa \
  --display-name="Compute Service Account"

# Grant roles
gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:compute-sa@my-project.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Create instance with service account
gcloud compute instances create secure-instance \
  --zone=us-central1-a \
  --service-account=compute-sa@my-project.iam.gserviceaccount.com \
  --scopes=cloud-platform
```

### Shielded VMs

```bash
# Create shielded VM
gcloud compute instances create shielded-instance \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring
```

**Shielded VM Features:**
- Secure Boot: Verify boot components
- vTPM: Virtual Trusted Platform Module
- Integrity Monitoring: Detect boot-level malware

### OS Login

```bash
# Enable OS Login
gcloud compute project-info add-metadata \
  --metadata enable-oslogin=TRUE

# Grant OS Login role
gcloud projects add-iam-policy-binding my-project \
  --member="user:user@example.com" \
  --role="roles/compute.osLogin"

# SSH with OS Login
gcloud compute ssh my-instance --zone=us-central1-a
```

### Confidential VMs

```bash
# Create confidential VM
gcloud compute instances create confidential-instance \
  --zone=us-central1-a \
  --machine-type=n2d-standard-2 \
  --confidential-compute \
  --maintenance-policy=TERMINATE
```

**Confidential VM Features:**
- Memory encryption
- AMD SEV protection
- No Google access to data
- Compliance requirements

### Security Best Practices

✅ Use service accounts with least privilege
✅ Enable Shielded VMs
✅ Use OS Login instead of SSH keys
✅ Implement network segmentation
✅ Use private Google access
✅ Enable VPC Flow Logs
✅ Use Cloud Armor for DDoS protection
✅ Implement security scanning
✅ Use Secret Manager for credentials
✅ Enable audit logging

---

## Monitoring

### Cloud Monitoring

```bash
# Install monitoring agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="compute.googleapis.com/instance/cpu/utilization"'
```

### Cloud Logging

```bash
# Install logging agent (included in Ops Agent)
# View logs
gcloud logging read "resource.type=gce_instance" \
  --limit=50 \
  --format=json

# Create log-based metric
gcloud logging metrics create error_count \
  --description="Count of error logs" \
  --log-filter='severity>=ERROR'
```

### Alerting

```bash
# Create alert policy (via console or API)
# Example: CPU utilization > 80%
```

**Python Example:**

```python
from google.cloud import monitoring_v3

client = monitoring_v3.AlertPolicyServiceClient()
project_name = f"projects/{project_id}"

alert_policy = monitoring_v3.AlertPolicy(
    display_name="High CPU Usage",
    conditions=[
        monitoring_v3.AlertPolicy.Condition(
            display_name="CPU > 80%",
            condition_threshold=monitoring_v3.AlertPolicy.Condition.MetricThreshold(
                filter='metric.type="compute.googleapis.com/instance/cpu/utilization" resource.type="gce_instance"',
                comparison=monitoring_v3.ComparisonType.COMPARISON_GT,
                threshold_value=0.8,
                duration={"seconds": 300},
            ),
        )
    ],
    notification_channels=[channel_name],
)

policy = client.create_alert_policy(name=project_name, alert_policy=alert_policy)
```

---

## Best Practices

### High Availability

✅ Use regional managed instance groups
✅ Distribute across multiple zones
✅ Implement health checks
✅ Use load balancing
✅ Enable auto-healing
✅ Use persistent disks for data
✅ Implement backup strategy
✅ Test failover procedures

### Performance

✅ Choose appropriate machine types
✅ Use SSD persistent disks for databases
✅ Use local SSDs for temporary data
✅ Enable CPU overcommit for burstable workloads
✅ Use placement policies for low latency
✅ Optimize network throughput
✅ Use committed use discounts

### Operations

✅ Use instance templates
✅ Implement infrastructure as code
✅ Use labels for organization
✅ Enable monitoring and logging
✅ Automate patching
✅ Document runbooks
✅ Implement CI/CD
✅ Regular security audits

---

## Troubleshooting

### Common Issues

**Instance won't start:**
```bash
# Check serial port output
gcloud compute instances get-serial-port-output my-instance \
  --zone=us-central1-a

# Check quota
gcloud compute project-info describe --project=my-project
```

**Can't SSH:**
```bash
# Check firewall rules
gcloud compute firewall-rules list

# Use IAP tunnel
gcloud compute ssh my-instance \
  --zone=us-central1-a \
  --tunnel-through-iap
```

**High costs:**
```bash
# Check running instances
gcloud compute instances list

# Check persistent disks
gcloud compute disks list

# Check snapshots
gcloud compute snapshots list

# Get cost recommendations
gcloud recommender recommendations list \
  --project=my-project \
  --recommender=google.compute.instance.MachineTypeRecommender
```

---

## Next Steps

- **[Google Kubernetes Engine](2-GKE.md)** - Container orchestration
- **[Cloud Run](3-Cloud-Run.md)** - Serverless containers
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026
**Status:** ✅ Complete

