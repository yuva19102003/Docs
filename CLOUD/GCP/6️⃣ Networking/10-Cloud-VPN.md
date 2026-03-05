# Cloud VPN

## Overview

Cloud VPN securely connects your on-premises network to your GCP VPC network through an IPsec VPN connection. It provides encrypted connectivity over the public internet.

---

## Table of Contents

1. [VPN Fundamentals](#vpn-fundamentals)
2. [HA VPN](#ha-vpn)
3. [Classic VPN](#classic-vpn)
4. [Configuration](#configuration)
5. [Best Practices](#best-practices)

---

## VPN Fundamentals

### How Cloud VPN Works

```
┌────────────────────────────────────────────────────────┐
│              Cloud VPN Architecture                    │
└────────────────────────────────────────────────────────┘

On-Premises Network (192.168.0.0/16)
    │
    ├─→ On-Premises VPN Gateway
    │   └─→ IPsec Tunnel (encrypted)
    │       └─→ Internet
    │           └─→ Cloud VPN Gateway
    │               └─→ GCP VPC (10.0.0.0/16)
    │                   └─→ VM Instances
    │
    └─→ Secure, encrypted connection

Features:
├─ IPsec encryption
├─ Up to 3 Gbps per tunnel
├─ Multiple tunnels for HA
└─ Dynamic routing (BGP)
```

### VPN Types

```yaml
# HA VPN (Recommended)
ha_vpn:
  sla: "99.99% availability"
  interfaces: "2 (for redundancy)"
  routing: "Dynamic (BGP)"
  use_case: "Production workloads"

# Classic VPN
classic_vpn:
  sla: "99.9% availability"
  interfaces: "1"
  routing: "Static or dynamic"
  use_case: "Legacy or simple setups"
  status: "Being phased out"
```

---

## HA VPN

### Architecture

```
On-Premises
├─ VPN Device 1
│  ├─→ Tunnel 1 → HA VPN Interface 0
│  └─→ Tunnel 2 → HA VPN Interface 1
│
└─ VPN Device 2
   ├─→ Tunnel 3 → HA VPN Interface 0
   └─→ Tunnel 4 → HA VPN Interface 1

Result: 99.99% SLA with 4 tunnels
```

### Creating HA VPN

```bash
# 1. Create HA VPN gateway
gcloud compute vpn-gateways create ha-vpn-gateway \
    --network=my-vpc \
    --region=us-central1

# 2. Create Cloud Router
gcloud compute routers create vpn-router \
    --network=my-vpc \
    --region=us-central1 \
    --asn=65001

# 3. Create external VPN gateway (on-premises)
gcloud compute external-vpn-gateways create onprem-gateway \
    --interfaces=0=203.0.113.1,1=203.0.113.2

# 4. Create VPN tunnels
gcloud compute vpn-tunnels create tunnel-1 \
    --peer-external-gateway=onprem-gateway \
    --peer-external-gateway-interface=0 \
    --region=us-central1 \
    --ike-version=2 \
    --shared-secret=SECRET \
    --router=vpn-router \
    --vpn-gateway=ha-vpn-gateway \
    --interface=0

gcloud compute vpn-tunnels create tunnel-2 \
    --peer-external-gateway=onprem-gateway \
    --peer-external-gateway-interface=1 \
    --region=us-central1 \
    --ike-version=2 \
    --shared-secret=SECRET \
    --router=vpn-router \
    --vpn-gateway=ha-vpn-gateway \
    --interface=1

# 5. Configure BGP sessions
gcloud compute routers add-interface vpn-router \
    --interface-name=if-tunnel-1 \
    --vpn-tunnel=tunnel-1 \
    --region=us-central1

gcloud compute routers add-bgp-peer vpn-router \
    --peer-name=bgp-peer-1 \
    --peer-asn=65002 \
    --interface=if-tunnel-1 \
    --region=us-central1

# Repeat for tunnel-2
```

### Terraform

```hcl
# HA VPN Gateway
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = "ha-vpn-gateway"
  network = google_compute_network.vpc.id
  region  = "us-central1"
}

# Cloud Router
resource "google_compute_router" "vpn_router" {
  name    = "vpn-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"

  bgp {
    asn = 65001
  }
}

# External VPN Gateway (on-premises)
resource "google_compute_external_vpn_gateway" "onprem" {
  name            = "onprem-gateway"
  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id         = 0
    ip_address = "203.0.113.1"
  }

  interface {
    id         = 1
    ip_address = "203.0.113.2"
  }
}

# VPN Tunnels
resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "tunnel-1"
  region                          = "us-central1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.onprem.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.shared_secret
  router                          = google_compute_router.vpn_router.id
  vpn_gateway_interface           = 0
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                            = "tunnel-2"
  region                          = "us-central1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.onprem.id
  peer_external_gateway_interface = 1
  shared_secret                   = var.shared_secret
  router                          = google_compute_router.vpn_router.id
  vpn_gateway_interface           = 1
  ike_version                     = 2
}

# Router Interfaces
resource "google_compute_router_interface" "interface1" {
  name       = "if-tunnel-1"
  router     = google_compute_router.vpn_router.name
  region     = "us-central1"
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_interface" "interface2" {
  name       = "if-tunnel-2"
  router     = google_compute_router.vpn_router.name
  region     = "us-central1"
  ip_range   = "169.254.0.5/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

# BGP Peers
resource "google_compute_router_peer" "peer1" {
  name                      = "bgp-peer-1"
  router                    = google_compute_router.vpn_router.name
  region                    = "us-central1"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 65002
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.interface1.name
}

resource "google_compute_router_peer" "peer2" {
  name                      = "bgp-peer-2"
  router                    = google_compute_router.vpn_router.name
  region                    = "us-central1"
  peer_ip_address           = "169.254.0.6"
  peer_asn                  = 65002
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.interface2.name
}
```

---

## Classic VPN

### Creating Classic VPN

```bash
# 1. Reserve static IP
gcloud compute addresses create vpn-ip \
    --region=us-central1

# 2. Create VPN gateway
gcloud compute target-vpn-gateways create vpn-gateway \
    --network=my-vpc \
    --region=us-central1

# 3. Create forwarding rules
gcloud compute forwarding-rules create vpn-rule-esp \
    --region=us-central1 \
    --address=vpn-ip \
    --ip-protocol=ESP \
    --target-vpn-gateway=vpn-gateway

gcloud compute forwarding-rules create vpn-rule-udp500 \
    --region=us-central1 \
    --address=vpn-ip \
    --ip-protocol=UDP \
    --ports=500 \
    --target-vpn-gateway=vpn-gateway

gcloud compute forwarding-rules create vpn-rule-udp4500 \
    --region=us-central1 \
    --address=vpn-ip \
    --ip-protocol=UDP \
    --ports=4500 \
    --target-vpn-gateway=vpn-gateway

# 4. Create VPN tunnel
gcloud compute vpn-tunnels create vpn-tunnel \
    --region=us-central1 \
    --peer-address=203.0.113.1 \
    --shared-secret=SECRET \
    --ike-version=2 \
    --target-vpn-gateway=vpn-gateway \
    --local-traffic-selector=0.0.0.0/0 \
    --remote-traffic-selector=0.0.0.0/0

# 5. Create route
gcloud compute routes create vpn-route \
    --network=my-vpc \
    --destination-range=192.168.0.0/16 \
    --next-hop-vpn-tunnel=vpn-tunnel \
    --next-hop-vpn-tunnel-region=us-central1
```

---

## Configuration

### Monitoring VPN

```bash
# Check VPN tunnel status
gcloud compute vpn-tunnels describe tunnel-1 \
    --region=us-central1 \
    --format="get(status)"

# List all tunnels
gcloud compute vpn-tunnels list

# Check BGP session status
gcloud compute routers get-status vpn-router \
    --region=us-central1
```

### Troubleshooting

```bash
# View VPN logs
gcloud logging read \
    'resource.type="vpn_gateway"' \
    --limit=50 \
    --format=json

# Check tunnel statistics
gcloud compute vpn-tunnels describe tunnel-1 \
    --region=us-central1 \
    --format=yaml
```

---

## Best Practices

### 1. Use HA VPN for Production

✓ **HA VPN provides 99.99% SLA**
```hcl
# Use HA VPN instead of Classic VPN
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = "ha-vpn-gateway"
  network = google_compute_network.vpc.id
  region  = "us-central1"
}
```

### 2. Use Dynamic Routing (BGP)

```hcl
# Configure BGP for automatic route updates
resource "google_compute_router" "vpn_router" {
  name    = "vpn-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"

  bgp {
    asn               = 65001
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    
    advertised_ip_ranges {
      range = "10.0.0.0/16"
    }
  }
}
```

### 3. Monitor VPN Health

```python
# Monitor VPN tunnel status
from google.cloud import monitoring_v3

def monitor_vpn_health(project_id, region):
    """
    Monitor VPN tunnel health
    """
    client = monitoring_v3.MetricServiceClient()
    
    # Query tunnel status
    results = client.list_time_series(
        request={
            "name": f"projects/{project_id}",
            "filter": f'metric.type="vpn.googleapis.com/tunnel_established" AND resource.labels.region="{region}"',
        }
    )
    
    for result in results:
        tunnel = result.resource.labels['tunnel_name']
        for point in result.points:
            status = point.value.bool_value
            print(f"Tunnel {tunnel}: {'UP' if status else 'DOWN'}")

monitor_vpn_health("my-project", "us-central1")
```

### 4. Use Strong Encryption

```hcl
resource "google_compute_vpn_tunnel" "tunnel" {
  name          = "secure-tunnel"
  region        = "us-central1"
  shared_secret = var.strong_shared_secret  # Use strong secret
  ike_version   = 2  # Use IKEv2
  
  # Additional security settings
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.onprem.id
  peer_external_gateway_interface = 0
  router                          = google_compute_router.vpn_router.id
  vpn_gateway_interface           = 0
}
```

---

## Summary

Cloud VPN provides:
- Secure IPsec connectivity
- HA VPN with 99.99% SLA
- Dynamic routing with BGP
- Up to 3 Gbps per tunnel

### Quick Reference

```bash
# Create HA VPN gateway
gcloud compute vpn-gateways create GATEWAY \
    --network=VPC --region=REGION

# Create VPN tunnel
gcloud compute vpn-tunnels create TUNNEL \
    --peer-external-gateway=PEER \
    --shared-secret=SECRET \
    --router=ROUTER \
    --vpn-gateway=GATEWAY

# Check tunnel status
gcloud compute vpn-tunnels describe TUNNEL \
    --region=REGION --format="get(status)"
```

---

## Next Steps

- [Cloud Interconnect](./11-Cloud-Interconnect.md) - Dedicated connectivity
- [Network Security](./12-Network-Security.md) - Security features
- [VPC](./1-VPC.md) - VPC fundamentals

---

**Last Updated:** March 2026
