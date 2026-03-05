# IP Addressing

## Overview

GCP provides both internal and external IP addresses for your resources. Understanding IP addressing is crucial for network design, connectivity, and cost optimization.

---

## Table of Contents

1. [IP Address Types](#ip-address-types)
2. [Internal IP Addresses](#internal-ip-addresses)
3. [External IP Addresses](#external-ip-addresses)
4. [IP Address Management](#ip-address-management)
5. [Alias IP Ranges](#alias-ip-ranges)
6. [Best Practices](#best-practices)

---

## IP Address Types

### Overview

```
┌────────────────────────────────────────────────────────┐
│              IP Address Types in GCP                   │
└────────────────────────────────────────────────────────┘

INTERNAL IPs (RFC 1918)
├─ Primary: Assigned to VM network interface
├─ Alias: Additional IPs on same interface
├─ Range: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
└─ Cost: Free

EXTERNAL IPs (Public)
├─ Ephemeral: Temporary, released when VM stops
├─ Static: Reserved, persists when VM stops
├─ Range: Public IP addresses
└─ Cost: Charged when not attached to running VM
```

---

## Internal IP Addresses

### Assignment

```bash
# Create VM with automatic internal IP
gcloud compute instances create my-vm \
    --zone=us-central1-a \
    --subnet=my-subnet

# Create VM with specific internal IP
gcloud compute instances create my-vm \
    --zone=us-central1-a \
    --subnet=my-subnet \
    --private-network-ip=10.0.1.10

# Check internal IP
gcloud compute instances describe my-vm \
    --zone=us-central1-a \
    --format="get(networkInterfaces[0].networkIP)"
```

### Terraform

```hcl
# VM with automatic internal IP
resource "google_compute_instance" "vm_auto" {
  name         = "vm-auto-ip"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # Internal IP assigned automatically
  }
}

# VM with specific internal IP
resource "google_compute_instance" "vm_static" {
  name         = "vm-static-ip"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    network_ip = "10.0.1.10"  # Specific internal IP
  }
}
```

---

## External IP Addresses

### Ephemeral IPs

```bash
# Create VM with ephemeral external IP
gcloud compute instances create my-vm \
    --zone=us-central1-a \
    --subnet=my-subnet

# Create VM without external IP
gcloud compute instances create my-vm \
    --zone=us-central1-a \
    --subnet=my-subnet \
    --no-address

# Add external IP to existing VM
gcloud compute instances add-access-config my-vm \
    --zone=us-central1-a

# Remove external IP
gcloud compute instances delete-access-config my-vm \
    --zone=us-central1-a
```

### Static IPs

```bash
# Reserve static IP
gcloud compute addresses create my-static-ip \
    --region=us-central1

# Reserve global static IP (for load balancers)
gcloud compute addresses create my-global-ip \
    --global

# List static IPs
gcloud compute addresses list

# Describe static IP
gcloud compute addresses describe my-static-ip \
    --region=us-central1

# Assign static IP to VM
gcloud compute instances delete-access-config my-vm \
    --zone=us-central1-a

gcloud compute instances add-access-config my-vm \
    --zone=us-central1-a \
    --address=STATIC_IP_ADDRESS

# Release static IP
gcloud compute addresses delete my-static-ip \
    --region=us-central1
```

### Terraform

```hcl
# Reserve static external IP
resource "google_compute_address" "static" {
  name   = "my-static-ip"
  region = "us-central1"
}

# VM with static external IP
resource "google_compute_instance" "vm_static_external" {
  name         = "vm-static-external"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

# VM without external IP
resource "google_compute_instance" "vm_no_external" {
  name         = "vm-no-external"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # No access_config = no external IP
  }
}

# Global static IP for load balancer
resource "google_compute_global_address" "lb" {
  name = "lb-static-ip"
}
```

---

## IP Address Management

### IP Address Inventory

```python
# List all IP addresses
from google.cloud import compute_v1

def list_all_ips(project_id):
    """
    List all IP addresses in project
    """
    address_client = compute_v1.AddressesClient()
    global_address_client = compute_v1.GlobalAddressesClient()
    instance_client = compute_v1.InstancesClient()
    
    print("REGIONAL STATIC IPs:")
    print("=" * 60)
    
    # List regional addresses
    for region in ["us-central1", "us-east1", "europe-west1"]:
        try:
            addresses = address_client.list(project=project_id, region=region)
            for addr in addresses:
                status = "IN_USE" if addr.users else "RESERVED"
                print(f"{addr.name}: {addr.address} ({status})")
        except:
            pass
    
    print("\nGLOBAL STATIC IPs:")
    print("=" * 60)
    
    # List global addresses
    global_addresses = global_address_client.list(project=project_id)
    for addr in global_addresses:
        status = "IN_USE" if addr.users else "RESERVED"
        print(f"{addr.name}: {addr.address} ({status})")
    
    print("\nVM INSTANCE IPs:")
    print("=" * 60)
    
    # List instance IPs
    for zone in ["us-central1-a", "us-east1-b"]:
        try:
            instances = instance_client.list(project=project_id, zone=zone)
            for instance in instances:
                for interface in instance.network_interfaces:
                    internal_ip = interface.network_i_p
                    external_ip = "None"
                    if interface.access_configs:
                        external_ip = interface.access_configs[0].nat_i_p
                    print(f"{instance.name}: Internal={internal_ip}, External={external_ip}")
        except:
            pass

list_all_ips("my-project")
```

### Cost Optimization

```yaml
# IP Address Costs (2026 pricing)
static_ip_unused:
  cost: "$0.01/hour ($7.30/month)"
  recommendation: "Release unused static IPs"

static_ip_in_use:
  cost: "Free (when attached to running VM)"
  recommendation: "Use static IPs for production"

ephemeral_ip:
  cost: "Free (when VM is running)"
  note: "Changes when VM stops/starts"

# Cost optimization script
```

```python
# Find unused static IPs
def find_unused_static_ips(project_id):
    """
    Find static IPs not attached to any resource
    """
    address_client = compute_v1.AddressesClient()
    
    unused = []
    for region in ["us-central1", "us-east1", "europe-west1"]:
        try:
            addresses = address_client.list(project=project_id, region=region)
            for addr in addresses:
                if not addr.users:  # Not in use
                    age_days = calculate_age(addr.creation_timestamp)
                    monthly_cost = 7.30
                    unused.append({
                        'name': addr.name,
                        'address': addr.address,
                        'region': region,
                        'age_days': age_days,
                        'monthly_cost': monthly_cost
                    })
        except:
            pass
    
    print(f"\nFound {len(unused)} unused static IPs")
    print(f"Total monthly cost: ${len(unused) * 7.30:.2f}")
    
    for ip in unused:
        print(f"\n{ip['name']}:")
        print(f"  Address: {ip['address']}")
        print(f"  Region: {ip['region']}")
        print(f"  Age: {ip['age_days']} days")
        print(f"  Monthly cost: ${ip['monthly_cost']:.2f}")
    
    return unused

def calculate_age(timestamp):
    from datetime import datetime
    # Implementation
    return 30  # Placeholder

unused = find_unused_static_ips("my-project")
```

---

## Alias IP Ranges

### Overview

```
VM with Alias IPs
├─ Primary IP: 10.0.1.10
├─ Alias IP 1: 10.0.1.11
├─ Alias IP 2: 10.0.1.12
└─ Alias IP Range: 10.0.1.20/28 (16 IPs)

Use Cases:
├─ Multiple services on one VM
├─ Container IPs (GKE)
└─ High availability configurations
```

### Configuration

```bash
# Create VM with alias IP
gcloud compute instances create my-vm \
    --zone=us-central1-a \
    --subnet=my-subnet \
    --network-interface="subnet=my-subnet,aliases=10.0.1.11;10.0.1.12"

# Add alias IP to existing VM
gcloud compute instances network-interfaces update my-vm \
    --zone=us-central1-a \
    --aliases=10.0.1.11,10.0.1.12
```

### Terraform

```hcl
# VM with alias IPs
resource "google_compute_instance" "vm_alias" {
  name         = "vm-with-alias"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    network_ip = "10.0.1.10"
    
    # Alias IP ranges
    alias_ip_range {
      ip_cidr_range = "10.0.1.11/32"
    }
    
    alias_ip_range {
      ip_cidr_range = "10.0.1.12/32"
    }
    
    # Range of IPs
    alias_ip_range {
      ip_cidr_range         = "10.0.1.20/28"
      subnetwork_range_name = "alias-range"
    }
  }
}
```

---

## Best Practices

### 1. Minimize External IPs

✓ **Use Cloud NAT for outbound**
```hcl
# VMs without external IPs
resource "google_compute_instance" "private_vm" {
  name         = "private-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # No external IP
  }
}

# Cloud NAT for outbound internet
resource "google_compute_router_nat" "nat" {
  name   = "my-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

### 2. Use Static IPs for Production

✓ **Reserve static IPs for stable endpoints**
```hcl
resource "google_compute_address" "prod_web" {
  name   = "prod-web-ip"
  region = "us-central1"
}

resource "google_compute_instance" "prod_web" {
  name         = "prod-web"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    
    access_config {
      nat_ip = google_compute_address.prod_web.address
    }
  }
}
```

### 3. Release Unused Static IPs

```bash
# Find and release unused IPs
gcloud compute addresses list --filter="status:RESERVED"

# Release unused IP
gcloud compute addresses delete UNUSED_IP --region=REGION
```

### 4. Use Private Google Access

```bash
# Enable for subnets without external IPs
gcloud compute networks subnets update my-subnet \
    --region=us-central1 \
    --enable-private-ip-google-access
```

### 5. Document IP Assignments

```yaml
# IP address documentation
production_ips:
  web_frontend:
    static_ip: "34.123.45.67"
    internal_ip: "10.0.1.10"
    purpose: "Production web server"
  
  api_backend:
    static_ip: "34.123.45.68"
    internal_ip: "10.0.1.20"
    purpose: "Production API server"

reserved_ranges:
  - range: "10.0.1.0/28"
    purpose: "Web tier"
  - range: "10.0.1.16/28"
    purpose: "App tier"
  - range: "10.0.1.32/28"
    purpose: "Database tier"
```

---

## Summary

IP addressing in GCP:
- Internal IPs for private communication
- External IPs for internet access
- Static IPs for stable endpoints
- Alias IPs for multiple services

### Quick Reference

```bash
# Reserve static IP
gcloud compute addresses create NAME --region=REGION

# Assign to VM
gcloud compute instances add-access-config VM \
    --zone=ZONE --address=IP

# List IPs
gcloud compute addresses list

# Release IP
gcloud compute addresses delete NAME --region=REGION
```

---

## Next Steps

- [Routing](./5-Routing.md) - Traffic routing
- [Cloud NAT](./6-Cloud-NAT.md) - Outbound internet access
- [Load Balancing](./7-Load-Balancing.md) - Distribute traffic

---

**Last Updated:** March 2026
