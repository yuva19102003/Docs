# Network Security

## Overview

GCP provides multiple layers of network security to protect your resources. This guide covers security features, best practices, and implementation strategies for securing your GCP network infrastructure.

---

## Table of Contents

1. [Security Layers](#security-layers)
2. [Firewall Security](#firewall-security)
3. [Private Google Access](#private-google-access)
4. [VPC Service Controls](#vpc-service-controls)
5. [Cloud Armor](#cloud-armor)
6. [Best Practices](#best-practices)

---

## Security Layers

### Defense in Depth

```
┌────────────────────────────────────────────────────────┐
│          Network Security Layers                       │
└────────────────────────────────────────────────────────┘

Layer 7 (Application)
├─ Cloud Armor (DDoS, WAF)
├─ Identity-Aware Proxy
└─ SSL/TLS Termination

Layer 4 (Transport)
├─ Firewall Rules
├─ Network Tags
└─ Service Accounts

Layer 3 (Network)
├─ VPC Isolation
├─ Private Google Access
├─ VPC Service Controls
└─ Cloud NAT

Layer 2 (Data Link)
├─ VPC Network
└─ Subnets

Physical
└─ Google's Infrastructure Security
```

---

## Firewall Security

### Least Privilege Firewall Rules

```hcl
# Deny all ingress by default (implied)
# Only allow necessary traffic

# Allow SSH from IAP only
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # IAP range
  target_tags   = ["ssh-enabled"]
  priority      = 1000

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow HTTP/HTTPS from load balancer only
resource "google_compute_firewall" "allow_lb_health" {
  name    = "allow-lb-health"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["web-server"]
  priority    = 1000
}

# Deny dangerous protocols
resource "google_compute_firewall" "deny_telnet" {
  name    = "deny-telnet"
  network = google_compute_network.vpc.name

  deny {
    protocol = "tcp"
    ports    = ["23"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 900  # Higher priority than allow rules
}

# Allow internal traffic only
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
```

### Service Account-Based Rules

```hcl
# More secure than tag-based rules
resource "google_compute_firewall" "app_to_db" {
  name    = "app-to-db"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_service_accounts = [google_service_account.app.email]
  target_service_accounts = [google_service_account.db.email]
  priority                = 1000
}
```

---

## Private Google Access

### Configuration

```hcl
# Enable Private Google Access on subnet
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# VMs without external IPs can access Google APIs
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
    subnetwork = google_compute_subnetwork.private.id
    # No access_config = no external IP
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }
}
```

---

## VPC Service Controls

### Service Perimeter

```hcl
# Create access policy
resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${var.org_id}"
  title  = "Security Policy"
}

# Create service perimeter
resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/servicePerimeters/secure_perimeter"
  title  = "Secure Perimeter"

  status {
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com"
    ]

    resources = [
      "projects/${var.project_number}"
    ]

    vpc_accessible_services {
      enable_restriction = true
      allowed_services = [
        "storage.googleapis.com",
        "bigquery.googleapis.com"
      ]
    }

    ingress_policies {
      ingress_from {
        sources {
          access_level = "*"
        }
        identity_type = "ANY_IDENTITY"
      }

      ingress_to {
        resources = ["*"]
        operations {
          service_name = "storage.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }

    egress_policies {
      egress_from {
        identity_type = "ANY_IDENTITY"
      }

      egress_to {
        resources = ["*"]
        operations {
          service_name = "storage.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }
  }
}
```

---

## Cloud Armor

### Security Policies

```hcl
# Cloud Armor security policy
resource "google_compute_security_policy" "policy" {
  name = "security-policy"

  # Default rule
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }

  # Block specific countries
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "origin.region_code == 'CN' || origin.region_code == 'RU'"
      }
    }
    description = "Block specific countries"
  }

  # Rate limiting
  rule {
    action   = "rate_based_ban"
    priority = "2000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Rate limit: 100 requests per minute"
  }

  # SQL injection protection
  rule {
    action   = "deny(403)"
    priority = "3000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "SQL injection protection"
  }

  # XSS protection
  rule {
    action   = "deny(403)"
    priority = "4000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "XSS protection"
  }

  # Allow specific IPs
  rule {
    action   = "allow"
    priority = "100"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["203.0.113.0/24"]
      }
    }
    description = "Allow office IPs"
  }
}

# Attach to backend service
resource "google_compute_backend_service" "web" {
  name          = "web-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.web.id]

  backend {
    group = google_compute_instance_group_manager.web.instance_group
  }

  security_policy = google_compute_security_policy.policy.id
}
```

---

## Best Practices

### 1. Zero Trust Architecture

```hcl
# No external IPs
resource "google_compute_instance" "app" {
  name         = "app-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
    # No external IP
  }

  service_account {
    email  = google_service_account.app.email
    scopes = ["cloud-platform"]
  }
}

# Access via IAP
resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Cloud NAT for outbound
resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

### 2. Network Segmentation

```hcl
# Separate subnets by tier
resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "db" {
  name          = "db-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

# Firewall rules between tiers
resource "google_compute_firewall" "web_to_app" {
  name    = "web-to-app"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_tags = ["web-tier"]
  target_tags = ["app-tier"]
}

resource "google_compute_firewall" "app_to_db" {
  name    = "app-to-db"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_tags = ["app-tier"]
  target_tags = ["db-tier"]
}
```

### 3. Enable Logging

```hcl
# Enable firewall logging
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Enable VPC Flow Logs
resource "google_compute_subnetwork" "monitored" {
  name          = "monitored-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
```

### 4. Regular Security Audits

```python
# Security audit script
from google.cloud import compute_v1

def audit_network_security(project_id):
    """
    Audit network security configuration
    """
    firewall_client = compute_v1.FirewallsClient()
    instance_client = compute_v1.InstancesClient()
    
    print("SECURITY AUDIT REPORT")
    print("=" * 60)
    
    # Check for overly permissive firewall rules
    print("\n1. Checking firewall rules...")
    firewalls = firewall_client.list(project=project_id)
    
    for fw in firewalls:
        if "0.0.0.0/0" in fw.source_ranges:
            if fw.allowed:
                for rule in fw.allowed:
                    if rule.I_p_protocol == "tcp" and "22" in rule.ports:
                        print(f"⚠️  WARNING: SSH open to internet: {fw.name}")
                    if rule.I_p_protocol == "all":
                        print(f"⚠️  WARNING: All protocols open: {fw.name}")
    
    # Check for instances with external IPs
    print("\n2. Checking instances with external IPs...")
    for zone in ["us-central1-a", "us-east1-b"]:
        try:
            instances = instance_client.list(project=project_id, zone=zone)
            for instance in instances:
                for interface in instance.network_interfaces:
                    if interface.access_configs:
                        print(f"⚠️  Instance with external IP: {instance.name}")
        except:
            pass
    
    # Check for Private Google Access
    print("\n3. Checking Private Google Access...")
    subnet_client = compute_v1.SubnetworksClient()
    for region in ["us-central1", "us-east1"]:
        try:
            subnets = subnet_client.list(project=project_id, region=region)
            for subnet in subnets:
                if not subnet.private_ip_google_access:
                    print(f"⚠️  Private Google Access disabled: {subnet.name}")
        except:
            pass
    
    print("\n" + "=" * 60)
    print("Audit complete")

audit_network_security("my-project")
```

### 5. Implement DDoS Protection

```hcl
# Cloud Armor with DDoS protection
resource "google_compute_security_policy" "ddos_protection" {
  name = "ddos-protection"

  # Adaptive protection
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }

  # Rate limiting
  rule {
    action   = "rate_based_ban"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 1000
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
  }

  # Default allow
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
```

---

## Summary

Network security in GCP:
- Multiple security layers
- Firewall rules and policies
- Private Google Access
- VPC Service Controls
- Cloud Armor protection

### Quick Reference

```bash
# Create firewall rule
gcloud compute firewall-rules create RULE \
    --network=VPC --action=ALLOW \
    --rules=PROTOCOL:PORT --source-ranges=CIDR

# Enable Private Google Access
gcloud compute networks subnets update SUBNET \
    --region=REGION --enable-private-ip-google-access

# Enable flow logs
gcloud compute networks subnets update SUBNET \
    --region=REGION --enable-flow-logs
```

---

## Next Steps

- [VPC](./1-VPC.md) - VPC fundamentals
- [Firewall Rules](./3-Firewall-Rules.md) - Detailed firewall configuration
- [Cloud Armor](https://cloud.google.com/armor/docs) - Advanced DDoS protection

---

**Last Updated:** March 2026
