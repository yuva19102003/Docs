# Creating DigitalOcean Droplets

## Overview

This guide covers everything you need to know about creating Droplets, from choosing the right configuration to advanced creation options and automation.

## Creation Methods

### 1. Control Panel (Web UI)
- Most user-friendly
- Visual interface
- Good for beginners
- One-time deployments

### 2. doctl CLI
- Command-line interface
- Scriptable and repeatable
- Good for automation
- Requires installation

### 3. API
- Full programmatic control
- Integration with applications
- Advanced automation
- Requires API token

### 4. Terraform
- Infrastructure as Code
- Version controlled
- Team collaboration
- Reproducible infrastructure

## Creating via Control Panel

### Step-by-Step Guide

```
┌─────────────────────────────────────────────────────────────┐
│              Droplet Creation Workflow                       │
└─────────────────────────────────────────────────────────────┘

1. Choose Image
   ├─> Distribution (Ubuntu, Debian, etc.)
   ├─> Marketplace Apps (WordPress, Docker, etc.)
   ├─> Custom Images (Your snapshots)
   └─> Backups (Restore from backup)

2. Choose Plan
   ├─> Basic ($4-$96/mo)
   ├─> General Purpose ($63-$1,008/mo)
   ├─> CPU-Optimized ($42-$672/mo)
   ├─> Memory-Optimized ($126-$2,016/mo)
   └─> Storage-Optimized ($168-$2,688/mo)

3. Choose Datacenter Region
   ├─> North America (NYC, SFO, TOR)
   ├─> Europe (LON, AMS, FRA)
   ├─> Asia (SGP, BLR, SYD)
   └─> Consider latency to users

4. Add Options
   ├─> VPC Network
   ├─> IPv6
   ├─> User Data (cloud-init)
   ├─> Monitoring
   └─> Backups

5. Authentication
   ├─> SSH Keys (Recommended)
   └─> Password (Not recommended)

6. Finalize
   ├─> Choose hostname
   ├─> Add tags
   ├─> Select project
   └─> Create Droplet
```

### Detailed Steps

#### 1. Navigate to Create Droplet

```
Dashboard → Create → Droplets
```

#### 2. Choose an Image

**Distributions**
```
Ubuntu 24.04 LTS (Recommended)
├─> Most popular
├─> Long-term support
├─> Large community
└─> Extensive documentation

Ubuntu 22.04 LTS
├─> Stable and mature
├─> Wide software support
└─> Production-ready

Debian 12
├─> Very stable
├─> Minimal by default
└─> Good for servers

Rocky Linux 9
├─> RHEL-compatible
├─> Enterprise-focused
└─> CentOS replacement
```

**Marketplace Apps** (One-Click Install)
```
Popular Apps:
├─> WordPress
├─> Docker
├─> LAMP Stack
├─> LEMP Stack
├─> Node.js
├─> MongoDB
├─> PostgreSQL
├─> GitLab
├─> Jenkins
└─> Kubernetes
```

#### 3. Choose a Plan

**Basic Droplets** (Shared CPU)
```
$6/mo   - 1 vCPU, 1 GB RAM, 25 GB SSD, 1 TB transfer
$12/mo  - 1 vCPU, 2 GB RAM, 50 GB SSD, 2 TB transfer
$18/mo  - 2 vCPU, 2 GB RAM, 60 GB SSD, 3 TB transfer
$24/mo  - 2 vCPU, 4 GB RAM, 80 GB SSD, 4 TB transfer
$48/mo  - 4 vCPU, 8 GB RAM, 160 GB SSD, 5 TB transfer

Best for:
├─> Development
├─> Testing
├─> Low-traffic websites
└─> Learning
```

**General Purpose** (Dedicated CPU)
```
$63/mo   - 2 vCPU, 8 GB RAM, 25 GB SSD, 4 TB transfer
$126/mo  - 4 vCPU, 16 GB RAM, 50 GB SSD, 5 TB transfer
$252/mo  - 8 vCPU, 32 GB RAM, 100 GB SSD, 6 TB transfer

Best for:
├─> Production applications
├─> Medium-traffic websites
├─> API servers
└─> Microservices
```

**CPU-Optimized** (High-frequency CPU)
```
$42/mo   - 2 vCPU, 4 GB RAM, 25 GB SSD, 4 TB transfer
$84/mo   - 4 vCPU, 8 GB RAM, 50 GB SSD, 5 TB transfer
$168/mo  - 8 vCPU, 16 GB RAM, 100 GB SSD, 6 TB transfer

Best for:
├─> CI/CD pipelines
├─> Video encoding
├─> Machine learning
└─> High-performance computing
```

**Memory-Optimized** (High RAM)
```
$126/mo  - 2 vCPU, 16 GB RAM, 50 GB SSD, 4 TB transfer
$252/mo  - 4 vCPU, 32 GB RAM, 100 GB SSD, 5 TB transfer
$504/mo  - 8 vCPU, 64 GB RAM, 200 GB SSD, 6 TB transfer

Best for:
├─> In-memory databases (Redis, Memcached)
├─> Big data analytics
├─> Caching layers
└─> Data processing
```

#### 4. Choose a Datacenter Region

**North America**
```
New York (NYC1, NYC2, NYC3)
├─> East Coast USA
├─> Low latency to US/Canada
└─> 3 availability zones

San Francisco (SFO2, SFO3)
├─> West Coast USA
├─> Low latency to West US/Asia
└─> 2 availability zones

Toronto (TOR1)
├─> Canada
├─> Data residency compliance
└─> Low latency to Canada
```

**Europe**
```
London (LON1)
├─> United Kingdom
├─> GDPR compliant
└─> Low latency to UK/Europe

Amsterdam (AMS3)
├─> Netherlands
├─> GDPR compliant
└─> Central Europe hub

Frankfurt (FRA1)
├─> Germany
├─> GDPR compliant
└─> Low latency to Central Europe
```

**Asia-Pacific**
```
Singapore (SGP1)
├─> Southeast Asia hub
├─> Low latency to APAC
└─> Growing region

Bangalore (BLR1)
├─> India
├─> Data residency
└─> Growing market

Sydney (SYD1)
├─> Australia
├─> Low latency to Oceania
└─> Data residency
```

#### 5. VPC Network

```
Default VPC (Automatic)
├─> Created automatically
├─> Private networking included
└─> Free

Custom VPC
├─> Create your own VPC
├─> Custom IP ranges
├─> Network isolation
└─> Free
```

#### 6. Additional Options

**IPv6**
```
Enable IPv6: Yes/No
├─> Free
├─> Future-proof
├─> Better connectivity
└─> Recommended: Enable
```

**User Data (cloud-init)**
```bash
#!/bin/bash
# Runs on first boot
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
```

**Monitoring**
```
Enable Monitoring: Yes/No
├─> Free
├─> CPU, memory, disk, bandwidth metrics
├─> Alerting capabilities
└─> Recommended: Enable
```

**Backups**
```
Enable Backups: Yes/No
├─> Cost: 20% of Droplet price
├─> Weekly automated backups
├─> 4 backups retained
└─> Recommended for production
```

#### 7. Authentication

**SSH Keys (Recommended)**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to DigitalOcean
# Paste in "New SSH Key" field
```

**Password**
```
Not recommended for production
├─> Less secure
├─> Emailed to you
├─> Should be changed immediately
└─> Use SSH keys instead
```

#### 8. Finalize and Create

**Hostname**
```
Examples:
├─> web-prod-01
├─> api-staging-02
├─> db-primary
└─> worker-01

Best practices:
├─> Use descriptive names
├─> Include environment
├─> Include purpose
└─> Use numbering for multiples
```

**Tags**
```
Examples:
├─> production
├─> staging
├─> web
├─> database
└─> api

Benefits:
├─> Organization
├─> Firewall rules
├─> Billing reports
└─> Automation
```

**Project**
```
Assign to project:
├─> Better organization
├─> Team collaboration
├─> Resource grouping
└─> Billing separation
```

## Creating via doctl CLI

### Installation

```bash
# macOS
brew install doctl

# Linux (snap)
sudo snap install doctl

# Linux (manual)
cd ~
wget https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz
tar xf doctl-1.104.0-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin

# Windows (Chocolatey)
choco install doctl
```

### Authentication

```bash
# Initialize authentication
doctl auth init

# Enter your API token when prompted
# Get token from: https://cloud.digitalocean.com/account/api/tokens

# Verify authentication
doctl account get
```

### Basic Creation

```bash
# Create basic Droplet
doctl compute droplet create my-droplet \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header)

# Output:
# ID           Name         Public IPv4    Private IPv4    Status
# 123456789    my-droplet   203.0.113.10   10.10.0.5      new
```

### Advanced Creation

```bash
# Create Droplet with all options
doctl compute droplet create web-prod-01 \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid vpc-uuid-here \
  --enable-ipv6 \
  --enable-monitoring \
  --enable-backups \
  --ssh-keys 12345678,87654321 \
  --tag-names production,web \
  --user-data-file cloud-init.yaml \
  --wait

# Wait for creation to complete
doctl compute droplet get web-prod-01 --format ID,Name,Status,PublicIPv4
```

### User Data Example

```yaml
# cloud-init.yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - git
  - curl
  - ufw

runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Welcome to my Droplet!</h1>
    owner: www-data:www-data
    permissions: '0644'
```

### Multiple Droplets

```bash
# Create multiple Droplets at once
doctl compute droplet create web-{01..03} \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header) \
  --tag-names web,production

# Creates: web-01, web-02, web-03
```

## Creating via API

### Using curl

```bash
# Set API token
export DO_TOKEN="your_api_token_here"

# Create Droplet
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DO_TOKEN" \
  -d '{
    "name": "api-server-01",
    "region": "nyc3",
    "size": "s-2vcpu-4gb",
    "image": "ubuntu-22-04-x64",
    "ssh_keys": [12345678],
    "backups": false,
    "ipv6": true,
    "monitoring": true,
    "tags": ["api", "production"],
    "vpc_uuid": "vpc-uuid-here",
    "user_data": "#!/bin/bash\napt-get update\napt-get install -y nginx"
  }' \
  "https://api.digitalocean.com/v2/droplets"

# Response includes Droplet ID and details
```

### Using Python

```python
import requests
import json

API_TOKEN = "your_api_token_here"
API_URL = "https://api.digitalocean.com/v2/droplets"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_TOKEN}"
}

droplet_config = {
    "name": "python-app-01",
    "region": "nyc3",
    "size": "s-1vcpu-2gb",
    "image": "ubuntu-22-04-x64",
    "ssh_keys": [12345678],
    "backups": False,
    "ipv6": True,
    "monitoring": True,
    "tags": ["python", "app"],
    "user_data": """#!/bin/bash
apt-get update
apt-get install -y python3-pip
pip3 install flask gunicorn
"""
}

response = requests.post(API_URL, headers=headers, json=droplet_config)
droplet = response.json()

print(f"Droplet created: {droplet['droplet']['name']}")
print(f"ID: {droplet['droplet']['id']}")
print(f"Status: {droplet['droplet']['status']}")
```

## Creating via Terraform

### Basic Configuration

```hcl
# main.tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# SSH Key
resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# VPC
resource "digitalocean_vpc" "main" {
  name     = "production-vpc"
  region   = "nyc3"
  ip_range = "10.10.0.0/16"
}

# Droplet
resource "digitalocean_droplet" "web" {
  name   = "web-server-01"
  region = "nyc3"
  size   = "s-2vcpu-4gb"
  image  = "ubuntu-22-04-x64"
  
  vpc_uuid = digitalocean_vpc.main.id
  ssh_keys = [digitalocean_ssh_key.default.id]
  
  ipv6       = true
  monitoring = true
  backups    = false
  
  tags = ["web", "production"]
  
  user_data = file("cloud-init.yaml")
}

# Output
output "droplet_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
```

### Variables

```hcl
# variables.tf
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Datacenter region"
  type        = string
  default     = "nyc3"
}

variable "droplet_count" {
  description = "Number of Droplets to create"
  type        = number
  default     = 3
}
```

### Multiple Droplets

```hcl
# Multiple web servers
resource "digitalocean_droplet" "web" {
  count = var.droplet_count
  
  name   = "web-server-${count.index + 1}"
  region = var.region
  size   = "s-1vcpu-2gb"
  image  = "ubuntu-22-04-x64"
  
  vpc_uuid = digitalocean_vpc.main.id
  ssh_keys = [digitalocean_ssh_key.default.id]
  
  tags = ["web", "production"]
}

# Load Balancer
resource "digitalocean_loadbalancer" "web" {
  name   = "web-lb"
  region = var.region
  
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    
    target_port     = 80
    target_protocol = "http"
  }
  
  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"
  }
  
  droplet_ids = digitalocean_droplet.web[*].id
}
```

## Best Practices

### 1. Naming Conventions

```
Format: <purpose>-<environment>-<number>

Examples:
├─> web-prod-01
├─> api-staging-02
├─> db-primary
├─> cache-prod-01
└─> worker-dev-03

Benefits:
├─> Easy identification
├─> Clear purpose
├─> Environment separation
└─> Scalability
```

### 2. Tagging Strategy

```
Tag Categories:
├─> Environment: production, staging, development
├─> Purpose: web, api, database, cache
├─> Team: frontend, backend, devops
├─> Project: project-a, project-b
└─> Cost-center: engineering, marketing

Benefits:
├─> Organization
├─> Firewall rules
├─> Billing reports
└─> Automation
```

### 3. Security from Start

```
Initial Setup:
├─> Use SSH keys (not passwords)
├─> Enable Cloud Firewall
├─> Use VPC for private networking
├─> Enable monitoring
├─> Keep OS updated
└─> Implement least privilege
```

### 4. Documentation

```
Document:
├─> Purpose of each Droplet
├─> Installed software
├─> Configuration changes
├─> Network topology
├─> Access procedures
└─> Disaster recovery plan
```

## Common Patterns

### Web Application Stack

```bash
# Database server
doctl compute droplet create db-prod-01 \
  --region nyc3 \
  --size m-2vcpu-16gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid vpc-uuid \
  --tag-names database,production

# Application servers (3x)
doctl compute droplet create app-prod-{01..03} \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid vpc-uuid \
  --tag-names app,production

# Load balancer (created separately)
```

### Development Environment

```bash
# Single Droplet for development
doctl compute droplet create dev-env \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image ubuntu-22-04-x64 \
  --enable-ipv6 \
  --enable-monitoring \
  --tag-names development \
  --user-data-file dev-setup.sh
```

## Troubleshooting

### Creation Fails

```
Common Issues:
├─> Invalid SSH key format
├─> Region capacity limits
├─> API rate limits
├─> Invalid size/image combination
└─> VPC not in same region

Solutions:
├─> Verify SSH key format
├─> Try different region
├─> Wait and retry
├─> Check compatibility
└─> Match VPC region
```

### Droplet Not Accessible

```
Check:
├─> Droplet status (should be "active")
├─> SSH key added correctly
├─> Firewall rules allow SSH (port 22)
├─> Correct IP address
└─> Network connectivity

Wait:
├─> Initial boot takes 30-60 seconds
├─> Cloud-init may take 2-5 minutes
└─> Check Droplet console for errors
```

## Next Steps

- [Learn about managing Droplets](./2-MANAGING-DROPLETS.md)
- [Configure networking](./4-DROPLET-NETWORKING.md)
- [Set up monitoring](./7-DROPLET-MONITORING.md)
- [Automate with Terraform](./8-DROPLET-AUTOMATION.md)
