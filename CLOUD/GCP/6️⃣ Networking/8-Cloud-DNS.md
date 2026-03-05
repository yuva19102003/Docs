# Cloud DNS

## Overview

Cloud DNS is a scalable, reliable, and managed authoritative Domain Name System (DNS) service running on Google's infrastructure. It translates domain names to IP addresses and provides low-latency DNS responses.

---

## Table of Contents

1. [DNS Fundamentals](#dns-fundamentals)
2. [Creating DNS Zones](#creating-dns-zones)
3. [DNS Records](#dns-records)
4. [Private DNS](#private-dns)
5. [Best Practices](#best-practices)

---

## DNS Fundamentals

### How Cloud DNS Works

```
┌────────────────────────────────────────────────────────┐
│              Cloud DNS Architecture                    │
└────────────────────────────────────────────────────────┘

User Query: example.com
    │
    ├─→ DNS Resolver
    │   └─→ Cloud DNS (Authoritative)
    │       ├─→ Managed Zone: example.com
    │       └─→ DNS Records
    │           ├─ A: 34.123.45.67
    │           ├─ AAAA: 2001:db8::1
    │           ├─ MX: mail.example.com
    │           └─ CNAME: www → example.com
    │
    └─→ Response: 34.123.45.67
```

### Key Features

```yaml
features:
  - 100% uptime SLA
  - Global anycast network
  - Low latency responses
  - DNSSEC support
  - Private DNS zones
  - Automatic scaling
```

---

## Creating DNS Zones

### Public DNS Zone

```bash
# Create public DNS zone
gcloud dns managed-zones create example-zone \
    --dns-name=example.com. \
    --description="Public zone for example.com"

# List zones
gcloud dns managed-zones list

# Describe zone
gcloud dns managed-zones describe example-zone

# Get name servers
gcloud dns managed-zones describe example-zone \
    --format="get(nameServers)"

# Delete zone
gcloud dns managed-zones delete example-zone
```

### Terraform

```hcl
# Public DNS zone
resource "google_dns_managed_zone" "public" {
  name        = "example-zone"
  dns_name    = "example.com."
  description = "Public DNS zone for example.com"

  dnssec_config {
    state = "on"
  }
}

# Output name servers
output "name_servers" {
  value = google_dns_managed_zone.public.name_servers
}
```

---

## DNS Records

### Record Types

```yaml
# Common DNS record types
A:
  description: "IPv4 address"
  example: "example.com. → 34.123.45.67"

AAAA:
  description: "IPv6 address"
  example: "example.com. → 2001:db8::1"

CNAME:
  description: "Canonical name (alias)"
  example: "www.example.com. → example.com."

MX:
  description: "Mail exchange"
  example: "example.com. → 10 mail.example.com."

TXT:
  description: "Text record"
  example: "example.com. → 'v=spf1 include:_spf.google.com ~all'"

NS:
  description: "Name server"
  example: "example.com. → ns-cloud-a1.googledomains.com."

SOA:
  description: "Start of authority"
  example: "Automatically managed by Cloud DNS"
```

### Creating Records

```bash
# Create A record
gcloud dns record-sets create example.com. \
    --zone=example-zone \
    --type=A \
    --ttl=300 \
    --rrdatas=34.123.45.67

# Create CNAME record
gcloud dns record-sets create www.example.com. \
    --zone=example-zone \
    --type=CNAME \
    --ttl=300 \
    --rrdatas=example.com.

# Create MX record
gcloud dns record-sets create example.com. \
    --zone=example-zone \
    --type=MX \
    --ttl=300 \
    --rrdatas="10 mail.example.com."

# Create TXT record
gcloud dns record-sets create example.com. \
    --zone=example-zone \
    --type=TXT \
    --ttl=300 \
    --rrdatas="v=spf1 include:_spf.google.com ~all"

# List records
gcloud dns record-sets list --zone=example-zone

# Update record
gcloud dns record-sets update example.com. \
    --zone=example-zone \
    --type=A \
    --ttl=600 \
    --rrdatas=34.123.45.68

# Delete record
gcloud dns record-sets delete example.com. \
    --zone=example-zone \
    --type=A
```

### Terraform

```hcl
# A record
resource "google_dns_record_set" "a" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["34.123.45.67"]
}

# AAAA record (IPv6)
resource "google_dns_record_set" "aaaa" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "AAAA"
  ttl          = 300
  rrdatas      = ["2001:db8::1"]
}

# CNAME record
resource "google_dns_record_set" "www" {
  name         = "www.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["example.com."]
}

# MX records
resource "google_dns_record_set" "mx" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "MX"
  ttl          = 3600
  rrdatas      = [
    "10 mail1.example.com.",
    "20 mail2.example.com."
  ]
}

# TXT record (SPF)
resource "google_dns_record_set" "spf" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"v=spf1 include:_spf.google.com ~all\""]
}

# TXT record (DKIM)
resource "google_dns_record_set" "dkim" {
  name         = "google._domainkey.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA...\""]
}

# Load balancer A record
resource "google_dns_record_set" "lb" {
  name         = "app.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]
}
```

---

## Private DNS

### Private DNS Zone

```bash
# Create private DNS zone
gcloud dns managed-zones create private-zone \
    --dns-name=internal.example.com. \
    --description="Private DNS zone" \
    --visibility=private \
    --networks=my-vpc

# Create private record
gcloud dns record-sets create db.internal.example.com. \
    --zone=private-zone \
    --type=A \
    --ttl=300 \
    --rrdatas=10.0.1.10
```

### Terraform

```hcl
# Private DNS zone
resource "google_dns_managed_zone" "private" {
  name        = "private-zone"
  dns_name    = "internal.example.com."
  description = "Private DNS zone for internal services"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

# Private DNS records
resource "google_dns_record_set" "db" {
  name         = "db.internal.example.com."
  managed_zone = google_dns_managed_zone.private.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["10.0.1.10"]
}

resource "google_dns_record_set" "cache" {
  name         = "cache.internal.example.com."
  managed_zone = google_dns_managed_zone.private.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["10.0.1.20"]
}

resource "google_dns_record_set" "api" {
  name         = "api.internal.example.com."
  managed_zone = google_dns_managed_zone.private.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["10.0.1.30"]
}
```

---

## Best Practices

### 1. Use Appropriate TTL Values

```hcl
# Short TTL for frequently changing records
resource "google_dns_record_set" "dynamic" {
  name         = "app.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 60  # 1 minute
  rrdatas      = [var.app_ip]
}

# Long TTL for stable records
resource "google_dns_record_set" "stable" {
  name         = "example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 86400  # 24 hours
  rrdatas      = ["34.123.45.67"]
}
```

### 2. Enable DNSSEC

```hcl
resource "google_dns_managed_zone" "secure" {
  name        = "example-zone"
  dns_name    = "example.com."
  description = "DNS zone with DNSSEC"

  dnssec_config {
    state         = "on"
    non_existence = "nsec3"
  }
}
```

### 3. Use Private DNS for Internal Services

```hcl
# Private zone for internal services
resource "google_dns_managed_zone" "internal" {
  name        = "internal-zone"
  dns_name    = "internal.company.com."
  description = "Internal services DNS"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}
```

### 4. Organize with Subdomains

```hcl
# Production subdomain
resource "google_dns_record_set" "prod" {
  name         = "prod.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.prod_lb.address]
}

# Staging subdomain
resource "google_dns_record_set" "staging" {
  name         = "staging.example.com."
  managed_zone = google_dns_managed_zone.public.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.staging_lb.address]
}
```

---

## Summary

Cloud DNS provides:
- Managed DNS service
- Global anycast network
- Low latency responses
- DNSSEC support
- Private DNS zones

### Quick Reference

```bash
# Create zone
gcloud dns managed-zones create ZONE \
    --dns-name=DOMAIN. --description="DESC"

# Create record
gcloud dns record-sets create NAME. \
    --zone=ZONE --type=TYPE --ttl=TTL --rrdatas=DATA

# List records
gcloud dns record-sets list --zone=ZONE

# Delete record
gcloud dns record-sets delete NAME. --zone=ZONE --type=TYPE
```

---

## Next Steps

- [Cloud CDN](./9-Cloud-CDN.md) - Content delivery
- [Load Balancing](./7-Load-Balancing.md) - Traffic distribution
- [Network Security](./12-Network-Security.md) - Security features

---

**Last Updated:** March 2026
