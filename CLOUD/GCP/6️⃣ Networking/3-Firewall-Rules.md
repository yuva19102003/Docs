# Firewall Rules

## Overview

GCP firewall rules control traffic to and from VM instances. They are stateful, meaning return traffic for allowed connections is automatically permitted. Firewall rules are defined at the VPC network level and apply to all resources in that network.

---

## Table of Contents

1. [Firewall Fundamentals](#firewall-fundamentals)
2. [Rule Components](#rule-components)
3. [Creating Firewall Rules](#creating-firewall-rules)
4. [Rule Priorities](#rule-priorities)
5. [Common Patterns](#common-patterns)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Firewall Fundamentals

### How Firewall Rules Work

```
┌────────────────────────────────────────────────────────┐
│           Firewall Rule Evaluation                     │
└────────────────────────────────────────────────────────┘

Incoming Traffic
    │
    ├─→ Check Firewall Rules (by priority)
    │   ├─ Rule 1 (priority 1000): DENY
    │   ├─ Rule 2 (priority 1100): ALLOW ✓
    │   └─ Rule 3 (priority 2000): ALLOW
    │
    └─→ First matching rule applies
        └─→ Traffic allowed/denied

Stateful Connection:
├─ Outbound request allowed
└─ Return traffic automatically allowed
```

### Key Concepts

**Stateful**
- Return traffic automatically allowed
- No need for separate egress rules for responses

**Implied Rules**
```
Every VPC has two implied rules:

1. Implied Allow Egress (priority 65535)
   - Allows all outbound traffic
   - Can be overridden with lower priority deny rules

2. Implied Deny Ingress (priority 65535)
   - Denies all inbound traffic
   - Must create allow rules for needed traffic
```

**Direction**
- Ingress: Traffic coming into instances
- Egress: Traffic leaving instances

---

## Rule Components

### Firewall Rule Structure

```yaml
firewall_rule:
  name: "allow-ssh"
  network: "my-vpc"
  direction: "INGRESS"  # or EGRESS
  priority: 1000
  action: "ALLOW"  # or DENY
  
  # What traffic
  protocols:
    - protocol: "tcp"
      ports: ["22"]
  
  # From where (ingress) or to where (egress)
  source_ranges: ["0.0.0.0/0"]  # Ingress
  # destination_ranges: ["0.0.0.0/0"]  # Egress
  
  # Apply to which instances
  target_tags: ["ssh-enabled"]
  # target_service_accounts: ["sa@project.iam.gserviceaccount.com"]
  
  # Logging
  log_config:
    enable: true
    metadata: "INCLUDE_ALL_METADATA"
```

### Target Selection

```
Target Options:
├─ All instances in network
├─ Instances with specific tags
├─ Instances using specific service accounts
└─ Specific instances (via tags)

Source/Destination Options:
├─ IP ranges (CIDR)
├─ Tags (for internal traffic)
├─ Service accounts
└─ Source tags (ingress only)
```

---

## Creating Firewall Rules

### Using gcloud

```bash
# Allow SSH from anywhere
gcloud compute firewall-rules create allow-ssh \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-enabled

# Allow SSH from IAP only (recommended)
gcloud compute firewall-rules create allow-ssh-iap \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=ssh-enabled

# Allow HTTP/HTTPS
gcloud compute firewall-rules create allow-web \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# Allow internal traffic
gcloud compute firewall-rules create allow-internal \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:0-65535,udp:0-65535,icmp \
    --source-ranges=10.0.0.0/8

# Deny specific traffic
gcloud compute firewall-rules create deny-telnet \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=900 \
    --action=DENY \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0

# Allow with service account
gcloud compute firewall-rules create allow-app-traffic \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=app@project.iam.gserviceaccount.com \
    --target-service-accounts=backend@project.iam.gserviceaccount.com

# Enable logging
gcloud compute firewall-rules create allow-ssh-logged \
    --network=my-vpc \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-enabled \
    --enable-logging

# List rules
gcloud compute firewall-rules list --filter="network:my-vpc"

# Describe rule
gcloud compute firewall-rules describe allow-ssh

# Update rule
gcloud compute firewall-rules update allow-ssh \
    --source-ranges=10.0.0.0/8

# Delete rule
gcloud compute firewall-rules delete allow-ssh
```

### Using Terraform

```hcl
# Allow SSH from IAP
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

  description = "Allow SSH from Identity-Aware Proxy"
}

# Allow HTTP/HTTPS
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  priority      = 1000

  description = "Allow HTTP and HTTPS traffic"
}

# Allow internal traffic
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

  description = "Allow all internal traffic"
}

# Deny specific traffic
resource "google_compute_firewall" "deny_telnet" {
  name    = "deny-telnet"
  network = google_compute_network.vpc.name

  deny {
    protocol = "tcp"
    ports    = ["23"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 900  # Higher priority than allow rules

  description = "Deny Telnet traffic"
}

# Allow with service accounts
resource "google_compute_firewall" "allow_app_traffic" {
  name    = "allow-app-traffic"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_service_accounts = [google_service_account.app.email]
  target_service_accounts = [google_service_account.backend.email]
  priority                = 1000

  description = "Allow app to backend traffic"
}

# Egress rule
resource "google_compute_firewall" "deny_egress_internet" {
  name      = "deny-egress-internet"
  network   = google_compute_network.vpc.name
  direction = "EGRESS"

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["no-internet"]
  priority           = 1000

  description = "Deny internet access for specific instances"
}

# Dynamic rules from variable
variable "firewall_rules" {
  type = list(object({
    name          = string
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
    target_tags   = list(string)
  }))
}

resource "google_compute_firewall" "dynamic_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name    = each.value.name
  network = google_compute_network.vpc.name

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }

  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags
  priority      = 1000
}
```

### Using Python

```python
# Create firewall rules with Python
from google.cloud import compute_v1

def create_firewall_rule(
    project_id: str,
    network_name: str,
    rule_name: str,
    protocol: str,
    ports: list,
    source_ranges: list,
    target_tags: list = None
):
    """
    Create a firewall rule
    """
    client = compute_v1.FirewallsClient()
    
    firewall = compute_v1.Firewall()
    firewall.name = rule_name
    firewall.network = f"projects/{project_id}/global/networks/{network_name}"
    firewall.direction = "INGRESS"
    firewall.priority = 1000
    
    # Allow rule
    allowed = compute_v1.Allowed()
    allowed.I_p_protocol = protocol
    allowed.ports = ports
    firewall.allowed = [allowed]
    
    firewall.source_ranges = source_ranges
    
    if target_tags:
        firewall.target_tags = target_tags
    
    # Enable logging
    firewall.log_config = compute_v1.FirewallLogConfig()
    firewall.log_config.enable = True
    firewall.log_config.metadata = "INCLUDE_ALL_METADATA"
    
    operation = client.insert(
        project=project_id,
        firewall_resource=firewall
    )
    
    operation.result()
    print(f"Firewall rule {rule_name} created")
    return firewall

def create_deny_rule(
    project_id: str,
    network_name: str,
    rule_name: str,
    protocol: str,
    ports: list,
    source_ranges: list
):
    """
    Create a deny firewall rule
    """
    client = compute_v1.FirewallsClient()
    
    firewall = compute_v1.Firewall()
    firewall.name = rule_name
    firewall.network = f"projects/{project_id}/global/networks/{network_name}"
    firewall.direction = "INGRESS"
    firewall.priority = 900  # Higher priority than allow rules
    
    # Deny rule
    denied = compute_v1.Denied()
    denied.I_p_protocol = protocol
    denied.ports = ports
    firewall.denied = [denied]
    
    firewall.source_ranges = source_ranges
    
    operation = client.insert(
        project=project_id,
        firewall_resource=firewall
    )
    
    operation.result()
    print(f"Deny rule {rule_name} created")
    return firewall

# Usage
create_firewall_rule(
    "my-project",
    "my-vpc",
    "allow-ssh-iap",
    "tcp",
    ["22"],
    ["35.235.240.0/20"],
    ["ssh-enabled"]
)

create_deny_rule(
    "my-project",
    "my-vpc",
    "deny-telnet",
    "tcp",
    ["23"],
    ["0.0.0.0/0"]
)
```

---

## Rule Priorities

### Priority System

```
Priority Range: 0 - 65535
├─ 0: Highest priority
├─ 1000: Default for custom rules
└─ 65535: Lowest priority (implied rules)

Evaluation:
├─ Rules evaluated in priority order (lowest number first)
├─ First matching rule applies
└─ Remaining rules ignored
```

### Priority Examples

```bash
# High priority deny (blocks everything else)
gcloud compute firewall-rules create high-priority-deny \
    --network=my-vpc \
    --priority=100 \
    --action=DENY \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0

# Normal priority allow
gcloud compute firewall-rules create normal-allow \
    --network=my-vpc \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=10.0.0.0/8

# Low priority catch-all
gcloud compute firewall-rules create low-priority-log \
    --network=my-vpc \
    --priority=60000 \
    --action=DENY \
    --rules=all \
    --source-ranges=0.0.0.0/0 \
    --enable-logging
```

### Priority Strategy

```yaml
# Recommended priority ranges
security_rules:
  priority: 100-999
  purpose: "Critical security rules (deny dangerous traffic)"
  examples:
    - Deny known malicious IPs
    - Deny insecure protocols

standard_rules:
  priority: 1000-9999
  purpose: "Standard application rules"
  examples:
    - Allow SSH from IAP
    - Allow HTTP/HTTPS
    - Allow internal traffic

logging_rules:
  priority: 60000-64999
  purpose: "Catch-all logging rules"
  examples:
    - Log denied traffic
    - Monitor unusual patterns
```

---

## Common Patterns

### 1. Web Server Rules

```hcl
# Allow HTTP/HTTPS from internet
resource "google_compute_firewall" "web_public" {
  name    = "allow-web-public"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  priority      = 1000
}

# Allow SSH from IAP
resource "google_compute_firewall" "web_ssh" {
  name    = "allow-web-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["web-server"]
  priority      = 1000
}

# Allow health checks
resource "google_compute_firewall" "web_health" {
  name    = "allow-web-health"
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
```

### 2. Database Server Rules

```hcl
# Allow database access from app tier only
resource "google_compute_firewall" "db_from_app" {
  name    = "allow-db-from-app"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]  # MySQL
  }

  source_tags = ["app-server"]
  target_tags = ["db-server"]
  priority    = 1000
}

# Deny database access from internet
resource "google_compute_firewall" "db_deny_internet" {
  name    = "deny-db-internet"
  network = google_compute_network.vpc.name

  deny {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db-server"]
  priority      = 900  # Higher priority
}
```

### 3. Internal Communication

```hcl
# Allow all internal traffic
resource "google_compute_firewall" "internal" {
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

### 4. Egress Control

```hcl
# Deny all egress except to specific destinations
resource "google_compute_firewall" "deny_egress_default" {
  name      = "deny-egress-default"
  network   = google_compute_network.vpc.name
  direction = "EGRESS"

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["restricted"]
  priority           = 65534  # Just above implied allow
}

# Allow egress to specific services
resource "google_compute_firewall" "allow_egress_google" {
  name      = "allow-egress-google"
  network   = google_compute_network.vpc.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.8/30"]  # Google APIs
  target_tags        = ["restricted"]
  priority           = 1000
}
```

---

## Best Practices

### 1. Principle of Least Privilege

✓ **Allow only necessary traffic**
```bash
# Good: Specific ports and sources
gcloud compute firewall-rules create allow-app \
    --rules=tcp:8080 \
    --source-ranges=10.0.1.0/24 \
    --target-tags=app-server

# Bad: Allow all
gcloud compute firewall-rules create allow-all \
    --rules=all \
    --source-ranges=0.0.0.0/0
```

### 2. Use IAP for SSH/RDP

✓ **Use Identity-Aware Proxy instead of public SSH**
```bash
# Good: SSH via IAP
gcloud compute firewall-rules create allow-ssh-iap \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20

# Bad: SSH from anywhere
gcloud compute firewall-rules create allow-ssh-all \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
```

### 3. Use Tags or Service Accounts

✓ **Target specific instances**
```hcl
# Good: Use tags
resource "google_compute_firewall" "web" {
  name        = "allow-web"
  network     = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  target_tags = ["web-server"]
}

# Better: Use service accounts
resource "google_compute_firewall" "web_sa" {
  name    = "allow-web-sa"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  target_service_accounts = [google_service_account.web.email]
}
```

### 4. Enable Logging

✓ **Log important rules**
```bash
# Enable logging for security monitoring
gcloud compute firewall-rules create allow-ssh \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --enable-logging
```

### 5. Document Rules

```hcl
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  description = "Allow HTTP/HTTPS to web servers. Required for public website access."
}
```

---

## Troubleshooting

### Check Firewall Rules

```bash
# List all rules
gcloud compute firewall-rules list

# List rules for specific network
gcloud compute firewall-rules list --filter="network:my-vpc"

# Describe specific rule
gcloud compute firewall-rules describe allow-ssh

# Check rules affecting instance
gcloud compute instances describe INSTANCE \
    --zone=ZONE \
    --format="get(tags.items)"

# Then check rules with those tags
gcloud compute firewall-rules list \
    --filter="targetTags:TAG"
```

### Test Connectivity

```bash
# From instance, test connection
curl -v http://10.0.1.5:80
telnet 10.0.1.5 22

# Check if port is listening
sudo netstat -tlnp | grep :80

# Test from external
curl -v http://EXTERNAL_IP
```

### View Firewall Logs

```bash
# Query firewall logs
gcloud logging read \
    'resource.type="gce_subnetwork"
     AND logName:"compute.googleapis.com/firewall"
     AND jsonPayload.disposition="DENIED"' \
    --limit=50 \
    --format=json

# Monitor denied traffic
gcloud logging read \
    'resource.type="gce_subnetwork"
     AND logName:"compute.googleapis.com/firewall"
     AND jsonPayload.disposition="DENIED"' \
    --limit=10 \
    --format='table(timestamp,jsonPayload.connection.src_ip,jsonPayload.connection.dest_ip,jsonPayload.connection.dest_port)'
```

### Common Issues

**Issue 1: Traffic blocked unexpectedly**
```bash
# Check rule priority
gcloud compute firewall-rules list \
    --filter="network:my-vpc" \
    --sort-by=priority

# Look for deny rules with higher priority
```

**Issue 2: Rule not applying**
```bash
# Verify instance has correct tags
gcloud compute instances describe INSTANCE \
    --zone=ZONE \
    --format="get(tags.items)"

# Verify rule targets those tags
gcloud compute firewall-rules describe RULE \
    --format="get(targetTags)"
```

---

## Summary

Firewall rules provide:
- Stateful traffic control
- Priority-based evaluation
- Flexible targeting
- Comprehensive logging

### Quick Reference

```bash
# Create allow rule
gcloud compute firewall-rules create RULE \
    --network=VPC --action=ALLOW --rules=PROTOCOL:PORT \
    --source-ranges=CIDR --target-tags=TAG

# Create deny rule
gcloud compute firewall-rules create RULE \
    --network=VPC --action=DENY --rules=PROTOCOL:PORT \
    --source-ranges=CIDR --priority=900

# Enable logging
gcloud compute firewall-rules update RULE --enable-logging

# List rules
gcloud compute firewall-rules list --filter="network:VPC"

# Delete rule
gcloud compute firewall-rules delete RULE
```

---

## Next Steps

- [IP Addressing](./4-IP-Addressing.md) - IP management
- [Routing](./5-Routing.md) - Traffic routing
- [Network Security](./12-Network-Security.md) - Advanced security

---

**Last Updated:** March 2026
