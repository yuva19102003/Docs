# Virtual Private Cloud (VPC)

## Overview

Google Cloud VPC (Virtual Private Cloud) provides networking functionality for your cloud resources. VPC is a global resource that spans all regions, providing a unified network infrastructure for your applications.

---

## Table of Contents

1. [VPC Fundamentals](#vpc-fundamentals)
2. [VPC Architecture](#vpc-architecture)
3. [Creating VPCs](#creating-vpcs)
4. [VPC Features](#vpc-features)
5. [Shared VPC](#shared-vpc)
6. [VPC Peering](#vpc-peering)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## VPC Fundamentals

### What is a VPC?

A VPC is a virtual version of a physical network implemented inside Google's production network.

```
┌────────────────────────────────────────────────────────┐
│              VPC Architecture                          │
└────────────────────────────────────────────────────────┘

VPC: my-vpc (Global Resource)
│
├─── Region: us-central1
│    ├─ Subnet: us-central1-subnet (10.0.1.0/24)
│    │  └─ VM Instances
│    └─ Subnet: us-central1-db-subnet (10.0.2.0/24)
│       └─ Database Instances
│
├─── Region: us-east1
│    └─ Subnet: us-east1-subnet (10.0.3.0/24)
│       └─ VM Instances
│
└─── Region: europe-west1
     └─ Subnet: europe-west1-subnet (10.0.4.0/24)
        └─ VM Instances

Features:
├─ Global routing
├─ Private Google Access
├─ Cloud NAT
└─ Firewall rules
```

### Key Concepts

**VPC Network**
- Global resource spanning all regions
- Contains subnets
- Provides connectivity between resources

**Subnets**
- Regional resources
- IP address ranges (CIDR blocks)
- Resources attach to subnets

**Routes**
- Define paths for network traffic
- Automatically created for subnets
- Custom routes for specific needs

**Firewall Rules**
- Control traffic to/from instances
- Stateful (return traffic allowed)
- Applied at VPC level

---

## VPC Architecture

### Default vs Custom VPC

**Default VPC:**
```
Default VPC (auto mode)
├─ One subnet per region
├─ Predefined IP ranges (10.128.0.0/9)
├─ Default firewall rules
└─ Automatic subnet creation in new regions
```

**Custom VPC:**
```
Custom VPC (custom mode)
├─ You define subnets
├─ You choose IP ranges
├─ You create firewall rules
└─ Full control over network design
```

### VPC Modes

```yaml
# Auto Mode VPC
mode: auto
subnets:
  - automatically created in each region
  - IP ranges: 10.128.0.0/9
  - new subnets added as regions launch

# Custom Mode VPC
mode: custom
subnets:
  - manually created
  - you specify IP ranges
  - full control over network topology
```

---

## Creating VPCs

### Using gcloud

```bash
# Create custom VPC
gcloud compute networks create my-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=global \
    --mtu=1460

# Create subnets
gcloud compute networks subnets create us-central1-subnet \
    --network=my-vpc \
    --region=us-central1 \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs

gcloud compute networks subnets create us-east1-subnet \
    --network=my-vpc \
    --region=us-east1 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access

# List VPCs
gcloud compute networks list

# Describe VPC
gcloud compute networks describe my-vpc

# List subnets
gcloud compute networks subnets list --network=my-vpc
```

### Using Terraform

```hcl
# VPC Network
resource "google_compute_network" "vpc" {
  name                            = "my-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  mtu                             = 1460
  delete_default_routes_on_create = false

  description = "Custom VPC for production workloads"
}

# Subnets
resource "google_compute_subnetwork" "us_central1" {
  name          = "us-central1-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

resource "google_compute_subnetwork" "us_east1" {
  name          = "us-east1-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "europe_west1" {
  name          = "europe-west1-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
  priority      = 1000
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # IAP range
  priority      = 1000
}
```

### Using Python

```python
# Create VPC with Python
from google.cloud import compute_v1

def create_vpc(project_id, network_name):
    """
    Create a custom VPC network
    """
    client = compute_v1.NetworksClient()
    
    network = compute_v1.Network()
    network.name = network_name
    network.auto_create_subnetworks = False
    network.routing_config = compute_v1.NetworkRoutingConfig()
    network.routing_config.routing_mode = "GLOBAL"
    network.mtu = 1460
    
    operation = client.insert(
        project=project_id,
        network_resource=network
    )
    
    # Wait for operation to complete
    operation.result()
    
    print(f"VPC {network_name} created successfully")
    return network

def create_subnet(project_id, region, subnet_name, network_name, ip_range):
    """
    Create a subnet in the VPC
    """
    client = compute_v1.SubnetworksClient()
    
    subnet = compute_v1.Subnetwork()
    subnet.name = subnet_name
    subnet.ip_cidr_range = ip_range
    subnet.network = f"projects/{project_id}/global/networks/{network_name}"
    subnet.private_ip_google_access = True
    
    operation = client.insert(
        project=project_id,
        region=region,
        subnetwork_resource=subnet
    )
    
    operation.result()
    
    print(f"Subnet {subnet_name} created in {region}")
    return subnet

# Usage
create_vpc("my-project", "my-vpc")
create_subnet("my-project", "us-central1", "us-central1-subnet", "my-vpc", "10.0.1.0/24")
```

---

## VPC Features

### 1. Private Google Access

Allows VMs without external IPs to access Google APIs:

```bash
# Enable Private Google Access
gcloud compute networks subnets update us-central1-subnet \
    --region=us-central1 \
    --enable-private-ip-google-access

# Verify
gcloud compute networks subnets describe us-central1-subnet \
    --region=us-central1 \
    --format="get(privateIpGoogleAccess)"
```

### 2. VPC Flow Logs

Monitor network traffic:

```bash
# Enable flow logs
gcloud compute networks subnets update us-central1-subnet \
    --region=us-central1 \
    --enable-flow-logs \
    --logging-aggregation-interval=interval-5-sec \
    --logging-flow-sampling=0.5 \
    --logging-metadata=include-all

# Query flow logs
gcloud logging read \
    'resource.type="gce_subnetwork"
     AND logName:"compute.googleapis.com/vpc_flows"' \
    --limit=10 \
    --format=json
```

### 3. Global Routing

```
Global VPC Routing
├─ VM in us-central1 (10.0.1.5)
│  └─ Can directly reach VM in europe-west1 (10.0.3.5)
│
└─ No need for VPN or peering between regions
   └─ Traffic stays on Google's network
```

### 4. MTU Configuration

```bash
# Set MTU (Maximum Transmission Unit)
gcloud compute networks create my-vpc \
    --subnet-mode=custom \
    --mtu=1460  # Default
    # --mtu=1500  # For better performance (if supported)
```

---

## Shared VPC

### Architecture

```
Host Project: shared-vpc-host
├─ VPC Network: shared-vpc
│  ├─ Subnet: us-central1-subnet
│  └─ Subnet: us-east1-subnet
│
└─ Service Projects (attached):
   ├─ Project: eng-prod-web
   │  └─ Uses shared-vpc subnets
   ├─ Project: eng-prod-api
   │  └─ Uses shared-vpc subnets
   └─ Project: mkt-prod-analytics
      └─ Uses shared-vpc subnets
```

### Setup Shared VPC

```bash
# 1. Enable Shared VPC on host project
gcloud compute shared-vpc enable shared-vpc-host

# 2. Attach service projects
gcloud compute shared-vpc associated-projects add eng-prod-web \
    --host-project=shared-vpc-host

gcloud compute shared-vpc associated-projects add eng-prod-api \
    --host-project=shared-vpc-host

# 3. Grant IAM permissions
gcloud projects add-iam-policy-binding shared-vpc-host \
    --member="serviceAccount:SERVICE_PROJECT_NUMBER@cloudservices.gserviceaccount.com" \
    --role="roles/compute.networkUser"

# 4. Grant subnet-level permissions
gcloud compute networks subnets add-iam-policy-binding us-central1-subnet \
    --region=us-central1 \
    --member="serviceAccount:SERVICE_PROJECT_NUMBER@cloudservices.gserviceaccount.com" \
    --role="roles/compute.networkUser"

# List shared VPC configuration
gcloud compute shared-vpc get-host-project eng-prod-web
gcloud compute shared-vpc list-associated-resources shared-vpc-host
```

### Terraform Shared VPC

```hcl
# Host project
resource "google_compute_shared_vpc_host_project" "host" {
  project = "shared-vpc-host"
}

# Service project
resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = "eng-prod-web"
}

# Grant permissions
resource "google_project_iam_member" "network_user" {
  project = "shared-vpc-host"
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.service.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "subnet_user" {
  project    = "shared-vpc-host"
  region     = "us-central1"
  subnetwork = "us-central1-subnet"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.service.number}@cloudservices.gserviceaccount.com"
}
```

---

## VPC Peering

### Architecture

```
VPC Peering Connection

VPC A (Project A)              VPC B (Project B)
├─ 10.0.0.0/16                ├─ 10.1.0.0/16
│                             │
└─────── Peering ──────────────┘
         │
         ├─ Private connectivity
         ├─ No overlapping IPs
         └─ Transitive peering not supported
```

### Setup VPC Peering

```bash
# Create peering from VPC A to VPC B
gcloud compute networks peerings create peer-a-to-b \
    --network=vpc-a \
    --peer-project=project-b \
    --peer-network=vpc-b \
    --auto-create-routes

# Create peering from VPC B to VPC A
gcloud compute networks peerings create peer-b-to-a \
    --network=vpc-b \
    --peer-project=project-a \
    --peer-network=vpc-a \
    --auto-create-routes

# List peerings
gcloud compute networks peerings list --network=vpc-a

# Delete peering
gcloud compute networks peerings delete peer-a-to-b \
    --network=vpc-a
```

### Terraform VPC Peering

```hcl
# Peering from VPC A to VPC B
resource "google_compute_network_peering" "peering_a_to_b" {
  name         = "peer-a-to-b"
  network      = google_compute_network.vpc_a.id
  peer_network = google_compute_network.vpc_b.id

  export_custom_routes = true
  import_custom_routes = true
}

# Peering from VPC B to VPC A
resource "google_compute_network_peering" "peering_b_to_a" {
  name         = "peer-b-to-a"
  network      = google_compute_network.vpc_b.id
  peer_network = google_compute_network.vpc_a.id

  export_custom_routes = true
  import_custom_routes = true
}
```

---

## Best Practices

### 1. Use Custom Mode VPCs

✓ **Custom mode provides better control**
```bash
# Good: Custom VPC
gcloud compute networks create my-vpc \
    --subnet-mode=custom

# Avoid: Auto mode for production
```

### 2. Plan IP Address Space

✓ **Use RFC 1918 private ranges**
```yaml
# Recommended IP ranges
ranges:
  - 10.0.0.0/8      # Large deployments
  - 172.16.0.0/12   # Medium deployments
  - 192.168.0.0/16  # Small deployments

# Avoid overlapping with:
  - On-premises networks
  - Other VPCs (if peering)
  - Google's reserved ranges
```

### 3. Enable Private Google Access

```bash
# Always enable for subnets without external IPs
gcloud compute networks subnets update SUBNET \
    --region=REGION \
    --enable-private-ip-google-access
```

### 4. Use Shared VPC for Multi-Project

```
# Good: Shared VPC
Host Project
└─ Centralized network management
   ├─ Service Project 1
   ├─ Service Project 2
   └─ Service Project 3

# Avoid: Separate VPCs requiring peering
```

### 5. Enable Flow Logs

```bash
# Enable for security and troubleshooting
gcloud compute networks subnets update SUBNET \
    --region=REGION \
    --enable-flow-logs
```

---

## Troubleshooting

### Check VPC Configuration

```bash
# List all VPCs
gcloud compute networks list

# Describe VPC
gcloud compute networks describe my-vpc

# List subnets
gcloud compute networks subnets list --network=my-vpc

# Check routes
gcloud compute routes list --filter="network:my-vpc"

# Check firewall rules
gcloud compute firewall-rules list --filter="network:my-vpc"
```

### Test Connectivity

```bash
# From VM, test connectivity
ping 10.0.2.5  # Internal IP

# Check routes
ip route show

# Test DNS
nslookup google.com

# Check firewall
sudo iptables -L
```

### Common Issues

**Issue 1: Cannot reach other subnets**
```bash
# Check routes
gcloud compute routes list --filter="network:my-vpc"

# Verify firewall rules allow internal traffic
gcloud compute firewall-rules list \
    --filter="network:my-vpc AND allowed.ports:*"
```

**Issue 2: Cannot access Google APIs**
```bash
# Enable Private Google Access
gcloud compute networks subnets update SUBNET \
    --region=REGION \
    --enable-private-ip-google-access
```

---

## Summary

VPC provides:
- Global network infrastructure
- Regional subnets
- Private connectivity
- Flexible routing
- Integrated security

### Quick Reference

```bash
# Create VPC
gcloud compute networks create VPC_NAME --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create SUBNET_NAME \
    --network=VPC_NAME --region=REGION --range=CIDR

# Enable Private Google Access
gcloud compute networks subnets update SUBNET_NAME \
    --region=REGION --enable-private-ip-google-access

# List VPCs
gcloud compute networks list

# Delete VPC
gcloud compute networks delete VPC_NAME
```

---

## Next Steps

- [Subnets](./2-Subnets.md) - Subnet configuration
- [Firewall Rules](./3-Firewall-Rules.md) - Network security
- [IP Addressing](./4-IP-Addressing.md) - IP management

---

**Last Updated:** March 2026
