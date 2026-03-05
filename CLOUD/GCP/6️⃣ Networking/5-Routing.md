# Routing

## Overview

Routes define the paths network traffic takes from VM instances to destinations. GCP automatically creates routes for subnets and provides options for custom routes to control traffic flow.

---

## Table of Contents

1. [Routing Fundamentals](#routing-fundamentals)
2. [Route Types](#route-types)
3. [Custom Routes](#custom-routes)
4. [Route Priority](#route-priority)
5. [Best Practices](#best-practices)

---

## Routing Fundamentals

### How Routing Works

```
┌────────────────────────────────────────────────────────┐
│              Route Selection Process                   │
└────────────────────────────────────────────────────────┘

Packet Destination: 10.0.2.5
    │
    ├─→ Check Routes (by specificity, then priority)
    │   ├─ Route 1: 10.0.2.0/24 (priority 1000) ✓ Most specific
    │   ├─ Route 2: 10.0.0.0/16 (priority 1000)
    │   └─ Route 3: 0.0.0.0/0   (priority 1000)
    │
    └─→ Use Route 1 (most specific match)
```

### System-Generated Routes

```bash
# View all routes
gcloud compute routes list

# Routes automatically created:
# 1. Subnet routes (one per subnet)
# 2. Default internet gateway route
```

---

## Route Types

### 1. Subnet Routes

```yaml
# Automatically created for each subnet
route:
  name: "default-route-subnet"
  destination: "10.0.1.0/24"
  next_hop: "VPC network"
  priority: 1000
  
# Cannot be deleted
# Deleted only when subnet is deleted
```

### 2. Default Route

```yaml
# Default internet gateway route
route:
  name: "default-route-internet"
  destination: "0.0.0.0/0"
  next_hop: "default-internet-gateway"
  priority: 1000

# Can be deleted if needed
# Recreate with: gcloud compute routes create
```

### 3. Peering Routes

```yaml
# Automatically created for VPC peering
route:
  name: "peering-route"
  destination: "10.1.0.0/16"  # Peer VPC range
  next_hop: "peering-connection"
  priority: 1000
```

---

## Custom Routes

### Static Routes

```bash
# Create static route
gcloud compute routes create route-to-onprem \
    --network=my-vpc \
    --destination-range=192.168.0.0/16 \
    --next-hop-gateway=vpn-gateway \
    --priority=1000

# Route to specific instance
gcloud compute routes create route-to-appliance \
    --network=my-vpc \
    --destination-range=172.16.0.0/12 \
    --next-hop-instance=firewall-vm \
    --next-hop-instance-zone=us-central1-a \
    --priority=1000

# Route to IP address
gcloud compute routes create route-to-ip \
    --network=my-vpc \
    --destination-range=10.2.0.0/16 \
    --next-hop-address=10.0.1.10 \
    --priority=1000

# Delete route
gcloud compute routes delete route-to-onprem
```

### Terraform

```hcl
# Static route to on-premises
resource "google_compute_route" "to_onprem" {
  name             = "route-to-onprem"
  network          = google_compute_network.vpc.name
  dest_range       = "192.168.0.0/16"
  next_hop_gateway = "projects/${var.project_id}/global/gateways/vpn-gateway"
  priority         = 1000
  tags             = ["vpn-route"]
}

# Route through network appliance
resource "google_compute_route" "through_appliance" {
  name                   = "route-through-appliance"
  network                = google_compute_network.vpc.name
  dest_range             = "172.16.0.0/12"
  next_hop_instance      = google_compute_instance.firewall.id
  next_hop_instance_zone = "us-central1-a"
  priority               = 1000
}

# Route to internal IP
resource "google_compute_route" "to_internal_ip" {
  name         = "route-to-internal-ip"
  network      = google_compute_network.vpc.name
  dest_range   = "10.2.0.0/16"
  next_hop_ip  = "10.0.1.10"
  priority     = 1000
}

# Default route override
resource "google_compute_route" "custom_default" {
  name             = "custom-default-route"
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 900  # Higher priority than default
  tags             = ["internet-access"]
}
```

---

## Route Priority

### Priority Rules

```
Priority Range: 0 - 65535
├─ 0: Highest priority
├─ 1000: Default for system routes
└─ 65535: Lowest priority

Selection:
1. Most specific destination range
2. If equal specificity, lowest priority number wins
```

### Examples

```bash
# High priority route (overrides default)
gcloud compute routes create priority-route \
    --network=my-vpc \
    --destination-range=0.0.0.0/0 \
    --next-hop-gateway=custom-gateway \
    --priority=100

# Normal priority
gcloud compute routes create normal-route \
    --network=my-vpc \
    --destination-range=10.2.0.0/16 \
    --next-hop-address=10.0.1.10 \
    --priority=1000

# Low priority backup route
gcloud compute routes create backup-route \
    --network=my-vpc \
    --destination-range=10.2.0.0/16 \
    --next-hop-address=10.0.1.20 \
    --priority=2000
```

---

## Best Practices

### 1. Use Specific Routes

✓ **More specific routes take precedence**
```hcl
# Good: Specific routes
resource "google_compute_route" "specific" {
  name       = "route-to-subnet"
  network    = google_compute_network.vpc.name
  dest_range = "10.0.1.0/24"  # Specific
  next_hop_ip = "10.0.0.1"
  priority   = 1000
}

# Avoid: Overly broad routes
```

### 2. Document Routes

```hcl
resource "google_compute_route" "to_onprem" {
  name       = "route-to-onprem"
  network    = google_compute_network.vpc.name
  dest_range = "192.168.0.0/16"
  next_hop_gateway = google_compute_vpn_gateway.vpn.id
  priority   = 1000
  
  description = "Route to on-premises network via VPN. Required for hybrid connectivity."
}
```

### 3. Use Tags for Selective Routing

```hcl
# Route applies only to tagged instances
resource "google_compute_route" "selective" {
  name       = "route-for-specific-vms"
  network    = google_compute_network.vpc.name
  dest_range = "10.2.0.0/16"
  next_hop_ip = "10.0.1.10"
  priority   = 1000
  tags       = ["custom-routing"]
}
```

---

## Summary

Routing in GCP:
- Automatic subnet routes
- Custom static routes
- Priority-based selection
- Tag-based application

### Quick Reference

```bash
# List routes
gcloud compute routes list --filter="network:my-vpc"

# Create route
gcloud compute routes create ROUTE \
    --network=VPC --dest-range=CIDR \
    --next-hop-address=IP --priority=1000

# Delete route
gcloud compute routes delete ROUTE
```

---

## Next Steps

- [Cloud NAT](./6-Cloud-NAT.md) - Outbound internet access
- [Load Balancing](./7-Load-Balancing.md) - Traffic distribution
- [Cloud VPN](./10-Cloud-VPN.md) - Hybrid connectivity

---

**Last Updated:** March 2026
