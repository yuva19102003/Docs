# Cloud Interconnect

## Overview

Cloud Interconnect provides low-latency, highly available connections between your on-premises network and Google Cloud. It offers dedicated physical connections with higher bandwidth and lower latency than VPN.

---

## Table of Contents

1. [Interconnect Types](#interconnect-types)
2. [Dedicated Interconnect](#dedicated-interconnect)
3. [Partner Interconnect](#partner-interconnect)
4. [Comparison](#comparison)
5. [Best Practices](#best-practices)

---

## Interconnect Types

### Overview

```
┌────────────────────────────────────────────────────────┐
│          Cloud Interconnect Options                    │
└────────────────────────────────────────────────────────┘

DEDICATED INTERCONNECT
├─ Direct physical connection to Google
├─ 10 Gbps or 100 Gbps per link
├─ Requires colocation facility
└─ Use for: High bandwidth, low latency

PARTNER INTERCONNECT
├─ Connection through service provider
├─ 50 Mbps to 50 Gbps per connection
├─ No colocation required
└─ Use for: Flexible bandwidth, easier setup

CLOUD VPN (for comparison)
├─ IPsec over internet
├─ Up to 3 Gbps per tunnel
├─ No physical infrastructure
└─ Use for: Quick setup, lower bandwidth
```

### Selection Guide

```yaml
dedicated_interconnect:
  bandwidth: "10 Gbps or 100 Gbps"
  latency: "< 2ms (typical)"
  sla: "99.9% or 99.99%"
  use_when:
    - Need > 10 Gbps bandwidth
    - Have colocation facility
    - Require lowest latency
    - Enterprise workloads

partner_interconnect:
  bandwidth: "50 Mbps to 50 Gbps"
  latency: "< 5ms (typical)"
  sla: "Varies by partner"
  use_when:
    - Need flexible bandwidth
    - No colocation facility
    - Want easier setup
    - Medium bandwidth needs

cloud_vpn:
  bandwidth: "Up to 3 Gbps per tunnel"
  latency: "Variable (internet)"
  sla: "99.9% or 99.99%"
  use_when:
    - Quick setup needed
    - Lower bandwidth OK
    - Cost-sensitive
    - Backup connectivity
```

---

## Dedicated Interconnect

### Architecture

```
On-Premises Network
    │
    ├─→ Your Router
    │   └─→ Cross-Connect
    │       └─→ Google Edge Router
    │           └─→ VLAN Attachment
    │               └─→ Cloud Router
    │                   └─→ VPC Network
    │                       └─→ Resources

Requirements:
├─ Colocation facility
├─ 10GBASE-LR or 100GBASE-LR optics
├─ BGP configuration
└─ VLAN 802.1Q support
```

### Creating Dedicated Interconnect

```bash
# 1. Create Cloud Router
gcloud compute routers create interconnect-router \
    --network=my-vpc \
    --region=us-central1 \
    --asn=65001

# 2. Create Interconnect
gcloud compute interconnects create my-interconnect \
    --customer-name="My Company" \
    --interconnect-type=DEDICATED \
    --link-type=LINK_TYPE_ETHERNET_10G_LR \
    --location=lax-zone1-1 \
    --requested-link-count=2

# 3. Create VLAN attachment
gcloud compute interconnects attachments create vlan-attachment-1 \
    --region=us-central1 \
    --router=interconnect-router \
    --interconnect=my-interconnect \
    --vlan=100

# 4. Configure BGP
gcloud compute routers add-interface interconnect-router \
    --interface-name=if-vlan-1 \
    --interconnect-attachment=vlan-attachment-1 \
    --region=us-central1

gcloud compute routers add-bgp-peer interconnect-router \
    --peer-name=bgp-peer-1 \
    --peer-asn=65002 \
    --interface=if-vlan-1 \
    --region=us-central1
```

### Terraform

```hcl
# Cloud Router
resource "google_compute_router" "interconnect_router" {
  name    = "interconnect-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"

  bgp {
    asn = 65001
  }
}

# Dedicated Interconnect
resource "google_compute_interconnect_attachment" "vlan_attachment" {
  name   = "vlan-attachment-1"
  region = "us-central1"
  router = google_compute_router.interconnect_router.id

  type                     = "DEDICATED"
  bandwidth                = "BPS_10G"
  vlan_tag8021q            = 100
  candidate_subnets        = ["169.254.0.0/29"]
  
  # Reference to interconnect (created separately)
  interconnect = "projects/${var.project_id}/global/interconnects/${var.interconnect_name}"
}

# Router Interface
resource "google_compute_router_interface" "interconnect_interface" {
  name       = "if-vlan-1"
  router     = google_compute_router.interconnect_router.name
  region     = "us-central1"
  ip_range   = "169.254.0.1/29"
  interconnect_attachment = google_compute_interconnect_attachment.vlan_attachment.id
}

# BGP Peer
resource "google_compute_router_peer" "interconnect_peer" {
  name                      = "bgp-peer-1"
  router                    = google_compute_router.interconnect_router.name
  region                    = "us-central1"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 65002
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.interconnect_interface.name
}
```

---

## Partner Interconnect

### Architecture

```
On-Premises Network
    │
    ├─→ Your Router
    │   └─→ Service Provider Network
    │       └─→ Google Edge Router
    │           └─→ VLAN Attachment
    │               └─→ Cloud Router
    │                   └─→ VPC Network
    │                       └─→ Resources

Benefits:
├─ No colocation needed
├─ Flexible bandwidth
├─ Easier setup
└─ Multiple provider options
```

### Creating Partner Interconnect

```bash
# 1. Create Cloud Router
gcloud compute routers create partner-router \
    --network=my-vpc \
    --region=us-central1 \
    --asn=65001

# 2. Create Partner VLAN attachment
gcloud compute interconnects attachments partner create partner-attachment \
    --region=us-central1 \
    --router=partner-router \
    --edge-availability-domain=AVAILABILITY_DOMAIN_1

# 3. Get pairing key (share with service provider)
gcloud compute interconnects attachments describe partner-attachment \
    --region=us-central1 \
    --format="get(pairingKey)"

# 4. After provider activates, configure BGP
gcloud compute routers add-interface partner-router \
    --interface-name=if-partner-1 \
    --interconnect-attachment=partner-attachment \
    --region=us-central1

gcloud compute routers add-bgp-peer partner-router \
    --peer-name=bgp-peer-partner \
    --peer-asn=65002 \
    --interface=if-partner-1 \
    --region=us-central1
```

### Terraform

```hcl
# Cloud Router
resource "google_compute_router" "partner_router" {
  name    = "partner-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"

  bgp {
    asn = 65001
  }
}

# Partner VLAN Attachment
resource "google_compute_interconnect_attachment" "partner_attachment" {
  name   = "partner-attachment"
  region = "us-central1"
  router = google_compute_router.partner_router.id

  type                     = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  admin_enabled            = true
  bandwidth                = "BPS_1G"
}

# Output pairing key for service provider
output "pairing_key" {
  value     = google_compute_interconnect_attachment.partner_attachment.pairing_key
  sensitive = true
}

# Router Interface (after activation)
resource "google_compute_router_interface" "partner_interface" {
  name       = "if-partner-1"
  router     = google_compute_router.partner_router.name
  region     = "us-central1"
  ip_range   = "169.254.0.1/29"
  interconnect_attachment = google_compute_interconnect_attachment.partner_attachment.id
}

# BGP Peer (after activation)
resource "google_compute_router_peer" "partner_peer" {
  name                      = "bgp-peer-partner"
  router                    = google_compute_router.partner_router.name
  region                    = "us-central1"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 65002
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.partner_interface.name
}
```

---

## Comparison

### Feature Comparison

```yaml
dedicated_interconnect:
  bandwidth: "10 Gbps or 100 Gbps per link"
  latency: "< 2ms"
  sla: "99.9% (single) or 99.99% (dual)"
  setup_time: "2-4 weeks"
  cost: "Higher (port fees + data transfer)"
  colocation: "Required"
  best_for: "Enterprise, high bandwidth"

partner_interconnect:
  bandwidth: "50 Mbps to 50 Gbps"
  latency: "< 5ms"
  sla: "Varies by partner"
  setup_time: "1-2 weeks"
  cost: "Lower (no port fees)"
  colocation: "Not required"
  best_for: "Flexible, medium bandwidth"

cloud_vpn:
  bandwidth: "Up to 3 Gbps per tunnel"
  latency: "Variable"
  sla: "99.9% or 99.99%"
  setup_time: "Minutes to hours"
  cost: "Lowest"
  colocation: "Not required"
  best_for: "Quick setup, backup"
```

### Cost Comparison

```yaml
# Monthly costs (example)
dedicated_interconnect:
  port_fee: "$1,700/month (10 Gbps)"
  data_egress: "$0.02/GB"
  total_10tb: "$1,700 + $200 = $1,900"

partner_interconnect:
  port_fee: "$0 (included in provider fee)"
  provider_fee: "$500-1000/month (1 Gbps)"
  data_egress: "$0.02/GB"
  total_10tb: "$700 + $200 = $900"

cloud_vpn:
  tunnel_fee: "$0.05/hour = $36/month"
  data_egress: "$0.12/GB (internet)"
  total_10tb: "$36 + $1,200 = $1,236"
```

---

## Best Practices

### 1. Use Redundant Connections

✓ **Configure dual attachments for HA**
```hcl
# Primary attachment
resource "google_compute_interconnect_attachment" "primary" {
  name                     = "primary-attachment"
  region                   = "us-central1"
  router                   = google_compute_router.router.id
  type                     = "DEDICATED"
  bandwidth                = "BPS_10G"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
}

# Secondary attachment
resource "google_compute_interconnect_attachment" "secondary" {
  name                     = "secondary-attachment"
  region                   = "us-central1"
  router                   = google_compute_router.router.id
  type                     = "DEDICATED"
  bandwidth                = "BPS_10G"
  edge_availability_domain = "AVAILABILITY_DOMAIN_2"
}
```

### 2. Configure BGP Properly

```hcl
resource "google_compute_router" "router" {
  name    = "interconnect-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"

  bgp {
    asn               = 65001
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    
    # Advertise specific ranges
    advertised_ip_ranges {
      range       = "10.0.0.0/16"
      description = "VPC primary range"
    }
  }
}
```

### 3. Monitor Connection Health

```python
# Monitor Interconnect health
from google.cloud import monitoring_v3

def monitor_interconnect(project_id, region):
    """
    Monitor Interconnect attachment status
    """
    client = monitoring_v3.MetricServiceClient()
    
    results = client.list_time_series(
        request={
            "name": f"projects/{project_id}",
            "filter": f'metric.type="interconnect.googleapis.com/network/attachment/capacity" AND resource.labels.region="{region}"',
        }
    )
    
    for result in results:
        attachment = result.resource.labels['attachment_name']
        for point in result.points:
            capacity = point.value.double_value
            print(f"Attachment {attachment}: {capacity} Gbps")

monitor_interconnect("my-project", "us-central1")
```

### 4. Plan for Capacity

```yaml
# Capacity planning
current_usage: "5 Gbps"
growth_rate: "20% per year"
planning_horizon: "3 years"

calculation:
  year_1: "5 * 1.2 = 6 Gbps"
  year_2: "6 * 1.2 = 7.2 Gbps"
  year_3: "7.2 * 1.2 = 8.64 Gbps"

recommendation: "Deploy 10 Gbps Dedicated Interconnect"
```

---

## Summary

Cloud Interconnect provides:
- Dedicated physical connectivity
- Low latency (< 2-5ms)
- High bandwidth (up to 100 Gbps)
- 99.9% or 99.99% SLA

### Quick Reference

```bash
# Create Dedicated Interconnect attachment
gcloud compute interconnects attachments create ATTACHMENT \
    --region=REGION --router=ROUTER \
    --interconnect=INTERCONNECT --vlan=VLAN

# Create Partner Interconnect attachment
gcloud compute interconnects attachments partner create ATTACHMENT \
    --region=REGION --router=ROUTER \
    --edge-availability-domain=DOMAIN

# Check attachment status
gcloud compute interconnects attachments describe ATTACHMENT \
    --region=REGION
```

---

## Next Steps

- [Cloud VPN](./10-Cloud-VPN.md) - VPN connectivity
- [Network Security](./12-Network-Security.md) - Security features
- [VPC](./1-VPC.md) - VPC fundamentals

---

**Last Updated:** March 2026
