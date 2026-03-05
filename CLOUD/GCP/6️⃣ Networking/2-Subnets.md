# Subnets

## Overview

Subnets are regional resources that define IP address ranges within a VPC network. Each subnet is associated with a specific region and can span multiple zones within that region.

---

## Table of Contents

1. [Subnet Fundamentals](#subnet-fundamentals)
2. [Creating Subnets](#creating-subnets)
3. [IP Range Management](#ip-range-management)
4. [Secondary IP Ranges](#secondary-ip-ranges)
5. [Subnet Features](#subnet-features)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Subnet Fundamentals

### Subnet Architecture

```
VPC: my-vpc (Global)
│
├─── Region: us-central1
│    ├─ Subnet: web-subnet
│    │  ├─ Primary Range: 10.0.1.0/24 (254 usable IPs)
│    │  ├─ Secondary Range: pods (10.1.0.0/16)
│    │  └─ Secondary Range: services (10.2.0.0/20)
│    │
│    └─ Subnet: db-subnet
│       └─ Primary Range: 10.0.2.0/24
│
├─── Region: us-east1
│    └─ Subnet: web-subnet
│       └─ Primary Range: 10.0.3.0/24
│
└─── Region: europe-west1
     └─ Subnet: web-subnet
        └─ Primary Range: 10.0.4.0/24
```

### Key Concepts

**Primary IP Range**
- Main CIDR block for the subnet
- Used for VM primary interfaces
- Cannot overlap with other subnets in VPC

**Secondary IP Ranges**
- Additional CIDR blocks
- Used for GKE pods and services
- Alias IP ranges

**Reserved IPs**
```
Subnet: 10.0.1.0/24
├─ 10.0.1.0   - Network address (reserved)
├─ 10.0.1.1   - Default gateway (reserved)
├─ 10.0.1.2   - Reserved by GCP
├─ 10.0.1.3   - Reserved by GCP
├─ 10.0.1.4   - First usable IP
├─ ...
├─ 10.0.1.254 - Last usable IP
└─ 10.0.1.255 - Broadcast address (reserved)

Usable IPs: 250 (256 - 4 reserved - 2 network/broadcast)
```

---

## Creating Subnets

### Using gcloud

```bash
# Create basic subnet
gcloud compute networks subnets create web-subnet \
    --network=my-vpc \
    --region=us-central1 \
    --range=10.0.1.0/24

# Create subnet with all features
gcloud compute networks subnets create app-subnet \
    --network=my-vpc \
    --region=us-central1 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs \
    --logging-aggregation-interval=interval-5-sec \
    --logging-flow-sampling=0.5 \
    --logging-metadata=include-all \
    --purpose=PRIVATE

# Create subnet with secondary ranges (for GKE)
gcloud compute networks subnets create gke-subnet \
    --network=my-vpc \
    --region=us-central1 \
    --range=10.0.3.0/24 \
    --secondary-range=pods=10.1.0.0/16 \
    --secondary-range=services=10.2.0.0/20 \
    --enable-private-ip-google-access

# List subnets
gcloud compute networks subnets list --network=my-vpc

# Describe subnet
gcloud compute networks subnets describe web-subnet \
    --region=us-central1

# Update subnet
gcloud compute networks subnets update web-subnet \
    --region=us-central1 \
    --enable-private-ip-google-access

# Delete subnet
gcloud compute networks subnets delete web-subnet \
    --region=us-central1
```

### Using Terraform

```hcl
# Basic subnet
resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  
  description = "Subnet for web tier"
}

# Subnet with all features
resource "google_compute_subnetwork" "app" {
  name          = "app-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
  purpose                  = "PRIVATE"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  description = "Subnet for application tier"
}

# GKE subnet with secondary ranges
resource "google_compute_subnetwork" "gke" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  description = "Subnet for GKE cluster"
}

# Multi-region subnets
locals {
  regions = ["us-central1", "us-east1", "europe-west1"]
}

resource "google_compute_subnetwork" "regional" {
  for_each = toset(local.regions)

  name          = "${each.value}-subnet"
  ip_cidr_range = cidrsubnet("10.0.0.0/16", 8, index(local.regions, each.value))
  region        = each.value
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
```

### Using Python

```python
# Create subnet with Python
from google.cloud import compute_v1

def create_subnet(
    project_id: str,
    region: str,
    network_name: str,
    subnet_name: str,
    ip_range: str
):
    """
    Create a subnet in a VPC network
    """
    client = compute_v1.SubnetworksClient()
    
    subnet = compute_v1.Subnetwork()
    subnet.name = subnet_name
    subnet.ip_cidr_range = ip_range
    subnet.network = f"projects/{project_id}/global/networks/{network_name}"
    subnet.private_ip_google_access = True
    subnet.enable_flow_logs = True
    
    # Configure flow logs
    subnet.log_config = compute_v1.SubnetworkLogConfig()
    subnet.log_config.enable = True
    subnet.log_config.aggregation_interval = "INTERVAL_5_SEC"
    subnet.log_config.flow_sampling = 0.5
    subnet.log_config.metadata = "INCLUDE_ALL_METADATA"
    
    operation = client.insert(
        project=project_id,
        region=region,
        subnetwork_resource=subnet
    )
    
    operation.result()
    print(f"Subnet {subnet_name} created in {region}")
    return subnet

def create_gke_subnet(
    project_id: str,
    region: str,
    network_name: str,
    subnet_name: str,
    primary_range: str,
    pods_range: str,
    services_range: str
):
    """
    Create a subnet with secondary ranges for GKE
    """
    client = compute_v1.SubnetworksClient()
    
    subnet = compute_v1.Subnetwork()
    subnet.name = subnet_name
    subnet.ip_cidr_range = primary_range
    subnet.network = f"projects/{project_id}/global/networks/{network_name}"
    subnet.private_ip_google_access = True
    
    # Add secondary ranges
    subnet.secondary_ip_ranges = [
        compute_v1.SubnetworkSecondaryRange(
            range_name="pods",
            ip_cidr_range=pods_range
        ),
        compute_v1.SubnetworkSecondaryRange(
            range_name="services",
            ip_cidr_range=services_range
        )
    ]
    
    operation = client.insert(
        project=project_id,
        region=region,
        subnetwork_resource=subnet
    )
    
    operation.result()
    print(f"GKE subnet {subnet_name} created with secondary ranges")
    return subnet

# Usage
create_subnet(
    "my-project",
    "us-central1",
    "my-vpc",
    "web-subnet",
    "10.0.1.0/24"
)

create_gke_subnet(
    "my-project",
    "us-central1",
    "my-vpc",
    "gke-subnet",
    "10.0.3.0/24",
    "10.1.0.0/16",
    "10.2.0.0/20"
)
```

---

## IP Range Management

### CIDR Block Sizing

```yaml
# Common subnet sizes
/24: 256 IPs (251 usable)
  - Good for: Small deployments, single application tier
  - Example: 10.0.1.0/24

/23: 512 IPs (507 usable)
  - Good for: Medium deployments
  - Example: 10.0.0.0/23

/22: 1,024 IPs (1,019 usable)
  - Good for: Large deployments
  - Example: 10.0.0.0/22

/20: 4,096 IPs (4,091 usable)
  - Good for: Very large deployments, GKE clusters
  - Example: 10.0.0.0/20

/16: 65,536 IPs (65,531 usable)
  - Good for: GKE pod ranges
  - Example: 10.1.0.0/16
```

### IP Range Planning

```python
# Calculate subnet requirements
def calculate_subnet_size(num_hosts):
    """
    Calculate required subnet size
    """
    import math
    
    # Add 5 for reserved IPs
    total_needed = num_hosts + 5
    
    # Calculate prefix length
    prefix = 32 - math.ceil(math.log2(total_needed))
    
    # Calculate actual capacity
    capacity = 2 ** (32 - prefix) - 5
    
    return {
        'prefix': prefix,
        'total_ips': 2 ** (32 - prefix),
        'usable_ips': capacity,
        'cidr_notation': f'/{prefix}'
    }

# Examples
print(calculate_subnet_size(50))   # /26 (64 IPs, 59 usable)
print(calculate_subnet_size(100))  # /25 (128 IPs, 123 usable)
print(calculate_subnet_size(250))  # /24 (256 IPs, 251 usable)
print(calculate_subnet_size(500))  # /23 (512 IPs, 507 usable)
```

### Expanding Subnets

```bash
# Expand subnet IP range
gcloud compute networks subnets expand-ip-range web-subnet \
    --region=us-central1 \
    --prefix-length=23  # Expand from /24 to /23

# Note: Can only expand, cannot shrink
# New range must include old range
```

```hcl
# Terraform: Expanding subnet
resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.0.0/23"  # Expanded from /24
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  lifecycle {
    # Prevent accidental shrinking
    prevent_destroy = true
  }
}
```

---

## Secondary IP Ranges

### Use Cases

```
Primary Range: 10.0.1.0/24
├─ VM primary interfaces
└─ Standard workloads

Secondary Ranges:
├─ pods: 10.1.0.0/16
│  └─ GKE pod IPs
│
├─ services: 10.2.0.0/20
│  └─ GKE service IPs
│
└─ alias-ips: 10.3.0.0/24
   └─ Alias IP ranges for VMs
```

### GKE Configuration

```hcl
# Subnet for GKE with proper sizing
resource "google_compute_subnetwork" "gke" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/22"  # 1,024 IPs for nodes
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  # Pod range: 65,536 IPs
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  # Service range: 4,096 IPs
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# GKE cluster using secondary ranges
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1"

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.gke.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
}
```

### Adding Secondary Ranges

```bash
# Add secondary range to existing subnet
gcloud compute networks subnets update gke-subnet \
    --region=us-central1 \
    --add-secondary-ranges=pods=10.1.0.0/16,services=10.2.0.0/20

# Remove secondary range
gcloud compute networks subnets update gke-subnet \
    --region=us-central1 \
    --remove-secondary-ranges=pods
```

---

## Subnet Features

### 1. Private Google Access

```bash
# Enable Private Google Access
gcloud compute networks subnets update web-subnet \
    --region=us-central1 \
    --enable-private-ip-google-access

# Verify
gcloud compute networks subnets describe web-subnet \
    --region=us-central1 \
    --format="get(privateIpGoogleAccess)"
```

**What it enables:**
- VMs without external IPs can access Google APIs
- Access to Cloud Storage, BigQuery, etc.
- No internet gateway required

### 2. VPC Flow Logs

```bash
# Enable flow logs with custom settings
gcloud compute networks subnets update web-subnet \
    --region=us-central1 \
    --enable-flow-logs \
    --logging-aggregation-interval=interval-5-sec \
    --logging-flow-sampling=0.5 \
    --logging-metadata=include-all \
    --logging-filter-expr='true'

# Disable flow logs
gcloud compute networks subnets update web-subnet \
    --region=us-central1 \
    --no-enable-flow-logs
```

**Flow log configuration:**
```yaml
aggregation_interval:
  - INTERVAL_5_SEC   # Most detailed
  - INTERVAL_30_SEC
  - INTERVAL_1_MIN
  - INTERVAL_5_MIN
  - INTERVAL_10_MIN
  - INTERVAL_15_MIN

flow_sampling:
  - 0.0 to 1.0  # Percentage of flows to log

metadata:
  - INCLUDE_ALL_METADATA
  - EXCLUDE_ALL_METADATA
  - CUSTOM_METADATA
```

### 3. Subnet IAM

```bash
# Grant subnet-level permissions
gcloud compute networks subnets add-iam-policy-binding web-subnet \
    --region=us-central1 \
    --member="serviceAccount:sa@project.iam.gserviceaccount.com" \
    --role="roles/compute.networkUser"

# List IAM bindings
gcloud compute networks subnets get-iam-policy web-subnet \
    --region=us-central1

# Remove IAM binding
gcloud compute networks subnets remove-iam-policy-binding web-subnet \
    --region=us-central1 \
    --member="serviceAccount:sa@project.iam.gserviceaccount.com" \
    --role="roles/compute.networkUser"
```

---

## Best Practices

### 1. Plan IP Ranges Carefully

✓ **Use non-overlapping ranges**
```yaml
# Good: Non-overlapping
us-central1: 10.0.0.0/20   # 10.0.0.0 - 10.0.15.255
us-east1:    10.0.16.0/20  # 10.0.16.0 - 10.0.31.255
eu-west1:    10.0.32.0/20  # 10.0.32.0 - 10.0.47.255

# Bad: Overlapping
us-central1: 10.0.0.0/24
us-east1:    10.0.0.0/24  # Overlaps!
```

### 2. Size Appropriately

✓ **Leave room for growth**
```python
# Calculate with growth factor
def size_subnet_with_growth(current_hosts, growth_factor=2.0):
    """
    Size subnet with growth factor
    """
    future_hosts = int(current_hosts * growth_factor)
    return calculate_subnet_size(future_hosts)

# Example: 100 hosts now, plan for 200
result = size_subnet_with_growth(100, 2.0)
print(f"Use {result['cidr_notation']} for future growth")
```

### 3. Use Consistent Naming

```yaml
# Naming convention
format: "<region>-<purpose>-subnet"

examples:
  - us-central1-web-subnet
  - us-central1-app-subnet
  - us-central1-db-subnet
  - us-east1-web-subnet
```

### 4. Enable Private Google Access

```bash
# Always enable for private subnets
gcloud compute networks subnets update SUBNET \
    --region=REGION \
    --enable-private-ip-google-access
```

### 5. Enable Flow Logs Selectively

```yaml
# Enable for:
production_subnets:
  - flow_logs: enabled
  - sampling: 0.5
  - interval: INTERVAL_10_MIN

# Disable for:
development_subnets:
  - flow_logs: disabled  # Reduce costs
```

---

## Troubleshooting

### Check Subnet Configuration

```bash
# List all subnets
gcloud compute networks subnets list

# Describe specific subnet
gcloud compute networks subnets describe web-subnet \
    --region=us-central1 \
    --format=yaml

# Check IP usage
gcloud compute networks subnets list-usable \
    --project=PROJECT_ID \
    --filter="network:my-vpc"
```

### IP Address Exhaustion

```python
# Check subnet utilization
from google.cloud import compute_v1

def check_subnet_utilization(project_id, region, subnet_name):
    """
    Check how many IPs are used in subnet
    """
    subnet_client = compute_v1.SubnetworksClient()
    instance_client = compute_v1.InstancesClient()
    
    # Get subnet
    subnet = subnet_client.get(
        project=project_id,
        region=region,
        subnetwork=subnet_name
    )
    
    # Calculate total IPs
    import ipaddress
    network = ipaddress.ip_network(subnet.ip_cidr_range)
    total_ips = network.num_addresses - 4  # Reserved IPs
    
    # Count used IPs (simplified)
    # In reality, query all resources using this subnet
    used_ips = 0  # Implement actual counting
    
    utilization = (used_ips / total_ips) * 100
    
    print(f"Subnet: {subnet_name}")
    print(f"Total IPs: {total_ips}")
    print(f"Used IPs: {used_ips}")
    print(f"Utilization: {utilization:.2f}%")
    
    if utilization > 80:
        print("⚠️  WARNING: Subnet is over 80% utilized")
        print("Consider expanding the subnet")

check_subnet_utilization("my-project", "us-central1", "web-subnet")
```

### Expand Subnet

```bash
# Check current size
gcloud compute networks subnets describe web-subnet \
    --region=us-central1 \
    --format="get(ipCidrRange)"

# Expand subnet
gcloud compute networks subnets expand-ip-range web-subnet \
    --region=us-central1 \
    --prefix-length=23

# Verify expansion
gcloud compute networks subnets describe web-subnet \
    --region=us-central1 \
    --format="get(ipCidrRange)"
```

---

## Summary

Subnets provide:
- Regional IP address ranges
- Network segmentation
- Resource isolation
- Flexible IP management

### Quick Reference

```bash
# Create subnet
gcloud compute networks subnets create SUBNET \
    --network=VPC --region=REGION --range=CIDR

# Enable Private Google Access
gcloud compute networks subnets update SUBNET \
    --region=REGION --enable-private-ip-google-access

# Enable flow logs
gcloud compute networks subnets update SUBNET \
    --region=REGION --enable-flow-logs

# Expand subnet
gcloud compute networks subnets expand-ip-range SUBNET \
    --region=REGION --prefix-length=PREFIX

# Delete subnet
gcloud compute networks subnets delete SUBNET --region=REGION
```

---

## Next Steps

- [Firewall Rules](./3-Firewall-Rules.md) - Network security
- [IP Addressing](./4-IP-Addressing.md) - IP management
- [Routing](./5-Routing.md) - Traffic routing

---

**Last Updated:** March 2026
