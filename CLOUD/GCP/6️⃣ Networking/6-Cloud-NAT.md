# Cloud NAT

## Overview

Cloud NAT (Network Address Translation) enables VM instances without external IP addresses to access the internet for updates, patches, and external services while remaining secure from inbound internet connections.

---

## Table of Contents

1. [Cloud NAT Fundamentals](#cloud-nat-fundamentals)
2. [Creating Cloud NAT](#creating-cloud-nat)
3. [NAT Configuration](#nat-configuration)
4. [Monitoring](#monitoring)
5. [Best Practices](#best-practices)

---

## Cloud NAT Fundamentals

### How Cloud NAT Works

```
┌────────────────────────────────────────────────────────┐
│              Cloud NAT Architecture                    │
└────────────────────────────────────────────────────────┘

Private VM (no external IP)
    │
    ├─→ Outbound request to internet
    │   └─→ Cloud NAT Gateway
    │       ├─→ Translates private IP to public IP
    │       └─→ Forwards to internet
    │
    └─→ Response from internet
        └─→ Cloud NAT Gateway
            ├─→ Translates back to private IP
            └─→ Delivers to VM

Benefits:
├─ No external IPs needed
├─ Reduced attack surface
├─ Centralized internet access
└─ Cost-effective
```

### Key Features

```yaml
features:
  - Managed service (no VMs to maintain)
  - Regional resource
  - Automatic scaling
  - Static IP support
  - Logging and monitoring
  - Port allocation
```

---

## Creating Cloud NAT

### Prerequisites

```bash
# 1. Create Cloud Router (required for Cloud NAT)
gcloud compute routers create my-router \
    --network=my-vpc \
    --region=us-central1

# 2. Create Cloud NAT
gcloud compute routers nats create my-nat \
    --router=my-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
```

### Using gcloud

```bash
# Create NAT with automatic IP allocation
gcloud compute routers nats create my-nat \
    --router=my-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Create NAT with manual IP allocation
gcloud compute addresses create nat-ip-1 --region=us-central1
gcloud compute addresses create nat-ip-2 --region=us-central1

gcloud compute routers nats create my-nat \
    --router=my-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --nat-external-ip-pool=nat-ip-1,nat-ip-2

# Create NAT for specific subnets
gcloud compute routers nats create my-nat \
    --router=my-router \
    --region=us-central1 \
    --nat-custom-subnet-ip-ranges=subnet-1,subnet-2 \
    --auto-allocate-nat-external-ips

# Enable logging
gcloud compute routers nats update my-nat \
    --router=my-router \
    --region=us-central1 \
    --enable-logging \
    --log-filter=ALL

# List NAT gateways
gcloud compute routers nats list --router=my-router --region=us-central1

# Describe NAT
gcloud compute routers nats describe my-nat \
    --router=my-router \
    --region=us-central1

# Delete NAT
gcloud compute routers nats delete my-nat \
    --router=my-router \
    --region=us-central1
```

### Using Terraform

```hcl
# Cloud Router
resource "google_compute_router" "router" {
  name    = "my-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"
}

# Cloud NAT with automatic IPs
resource "google_compute_router_nat" "nat_auto" {
  name   = "my-nat-auto"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Cloud NAT with manual IPs
resource "google_compute_address" "nat_ips" {
  count  = 2
  name   = "nat-ip-${count.index + 1}"
  region = "us-central1"
}

resource "google_compute_router_nat" "nat_manual" {
  name   = "my-nat-manual"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_ips[*].self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# Cloud NAT for specific subnets
resource "google_compute_router_nat" "nat_selective" {
  name   = "my-nat-selective"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.app.id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Advanced configuration
resource "google_compute_router_nat" "nat_advanced" {
  name   = "my-nat-advanced"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Port allocation
  min_ports_per_vm                   = 64
  max_ports_per_vm                   = 65536
  enable_dynamic_port_allocation     = true
  enable_endpoint_independent_mapping = true

  # Timeouts
  icmp_idle_timeout_sec              = 30
  tcp_established_idle_timeout_sec   = 1200
  tcp_transitory_idle_timeout_sec    = 30
  udp_idle_timeout_sec               = 30

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
```

---

## NAT Configuration

### IP Allocation Options

```yaml
# Automatic allocation
auto_only:
  description: "GCP automatically allocates IPs"
  use_case: "Simple deployments"
  pros:
    - Easy to set up
    - Automatic scaling
  cons:
    - IPs may change
    - Less control

# Manual allocation
manual_only:
  description: "You specify static IPs"
  use_case: "Need stable IPs for allowlisting"
  pros:
    - Predictable IPs
    - Full control
  cons:
    - Manual management
    - Must provision enough IPs
```

### Subnet Selection

```yaml
# All subnets
all_subnets:
  config: "ALL_SUBNETWORKS_ALL_IP_RANGES"
  description: "NAT for all subnets in region"

# Specific subnets
specific_subnets:
  config: "LIST_OF_SUBNETWORKS"
  description: "NAT for selected subnets only"
  
# Primary IP ranges only
primary_only:
  config: "PRIMARY_IP_RANGE"
  description: "NAT for primary IPs, not secondary ranges"
```

### Port Allocation

```hcl
# Configure port allocation
resource "google_compute_router_nat" "nat_ports" {
  name   = "my-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Port configuration
  min_ports_per_vm               = 64    # Minimum ports per VM
  max_ports_per_vm               = 65536 # Maximum ports per VM
  enable_dynamic_port_allocation = true  # Dynamic allocation

  # Endpoint independent mapping
  enable_endpoint_independent_mapping = true
}
```

---

## Monitoring

### Cloud NAT Metrics

```bash
# View NAT metrics in Cloud Console
# Monitoring > Metrics Explorer

# Key metrics:
# - nat/sent_packets_count
# - nat/received_packets_count
# - nat/sent_bytes_count
# - nat/received_bytes_count
# - nat/dropped_sent_packets_count
# - nat/port_usage
# - nat/allocated_ports
```

### Logging

```bash
# Enable logging
gcloud compute routers nats update my-nat \
    --router=my-router \
    --region=us-central1 \
    --enable-logging \
    --log-filter=ALL

# Query NAT logs
gcloud logging read \
    'resource.type="nat_gateway"
     AND logName:"compute.googleapis.com/nat_flows"' \
    --limit=50 \
    --format=json

# Filter by specific VM
gcloud logging read \
    'resource.type="nat_gateway"
     AND jsonPayload.connection.src_ip="10.0.1.5"' \
    --limit=10
```

### Python Monitoring

```python
# Monitor NAT usage
from google.cloud import monitoring_v3
from datetime import datetime, timedelta

def monitor_nat_usage(project_id, region):
    """
    Monitor Cloud NAT port usage
    """
    client = monitoring_v3.MetricServiceClient()
    
    # Query port usage
    interval = monitoring_v3.TimeInterval({
        "end_time": {"seconds": int(datetime.now().timestamp())},
        "start_time": {"seconds": int((datetime.now() - timedelta(hours=1)).timestamp())},
    })
    
    results = client.list_time_series(
        request={
            "name": f"projects/{project_id}",
            "filter": f'metric.type="router.googleapis.com/nat/allocated_ports" AND resource.labels.region="{region}"',
            "interval": interval,
        }
    )
    
    for result in results:
        router = result.resource.labels['router_id']
        nat = result.resource.labels['nat_gateway_name']
        
        for point in result.points:
            value = point.value.int64_value
            print(f"NAT: {nat} on Router: {router}")
            print(f"Allocated Ports: {value}")
            
            if value > 60000:  # Alert threshold
                print("⚠️  WARNING: High port usage!")

monitor_nat_usage("my-project", "us-central1")
```

---

## Best Practices

### 1. Use Manual IPs for Allowlisting

✓ **Reserve static IPs when external services need allowlisting**
```hcl
# Reserve IPs
resource "google_compute_address" "nat_ips" {
  count  = 2
  name   = "nat-ip-${count.index + 1}"
  region = "us-central1"
}

# Use in NAT
resource "google_compute_router_nat" "nat" {
  name   = "my-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_ips[*].self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

### 2. Enable Logging for Troubleshooting

```hcl
resource "google_compute_router_nat" "nat" {
  name   = "my-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"  # or "ALL" for detailed logging
  }
}
```

### 3. Configure Appropriate Port Limits

```hcl
resource "google_compute_router_nat" "nat" {
  name   = "my-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Adjust based on workload
  min_ports_per_vm               = 64
  enable_dynamic_port_allocation = true
}
```

### 4. Use Separate NAT per Environment

```hcl
# Production NAT
resource "google_compute_router_nat" "prod_nat" {
  name   = "prod-nat"
  router = google_compute_router.prod_router.name
  region = "us-central1"

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.prod_nat_ips[*].self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.prod.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Development NAT
resource "google_compute_router_nat" "dev_nat" {
  name   = "dev-nat"
  router = google_compute_router.dev_router.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

---

## Summary

Cloud NAT provides:
- Secure internet access for private VMs
- Managed NAT service
- Automatic scaling
- Centralized control

### Quick Reference

```bash
# Create router
gcloud compute routers create ROUTER \
    --network=VPC --region=REGION

# Create NAT
gcloud compute routers nats create NAT \
    --router=ROUTER --region=REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Enable logging
gcloud compute routers nats update NAT \
    --router=ROUTER --region=REGION \
    --enable-logging

# Delete NAT
gcloud compute routers nats delete NAT \
    --router=ROUTER --region=REGION
```

---

## Next Steps

- [Load Balancing](./7-Load-Balancing.md) - Traffic distribution
- [Cloud VPN](./10-Cloud-VPN.md) - Hybrid connectivity
- [Network Security](./12-Network-Security.md) - Security features

---

**Last Updated:** March 2026
