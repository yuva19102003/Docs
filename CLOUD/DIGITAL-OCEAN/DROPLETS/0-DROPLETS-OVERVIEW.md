# DigitalOcean Droplets Overview

## Introduction

Droplets are DigitalOcean's virtual machines (VMs) that provide scalable compute capacity in the cloud. They are the foundation of DigitalOcean's infrastructure, offering flexible, cost-effective, and easy-to-use cloud computing resources.

## What are Droplets?

Droplets are Linux or BSD-based virtual machines running on top of virtualized hardware. Each Droplet you create is a new server you can use independently or as part of a larger cloud-based infrastructure.

## Key Features

- **Fast Deployment**: Launch in under 55 seconds
- **SSD Storage**: All Droplets use SSD storage for better performance
- **Flexible Sizing**: Scale vertically with ease
- **Multiple OS Options**: Linux distributions and BSD variants
- **Global Datacenters**: Deploy in 15+ regions worldwide
- **VPC Integration**: Private networking included
- **Snapshots & Backups**: Easy disaster recovery
- **Monitoring**: Built-in metrics and alerting
- **Team Management**: Collaborate with team members
- **API & CLI**: Full automation support

## Droplet Types

### 1. Basic Droplets
**Best for**: Development, testing, low-traffic websites

```
CPU: Shared
RAM: 512 MB - 16 GB
Storage: 10 GB - 320 GB SSD
Transfer: 500 GB - 5 TB
Price: $4/month - $96/month
```

### 2. General Purpose Droplets
**Best for**: Production applications, medium-traffic websites

```
CPU: Dedicated
RAM: 8 GB - 160 GB
Storage: 25 GB - 500 GB SSD
Transfer: 4 TB - 9 TB
Price: $63/month - $1,008/month
```

### 3. CPU-Optimized Droplets
**Best for**: High-performance computing, video encoding, machine learning

```
CPU: Dedicated (High-frequency)
RAM: 4 GB - 64 GB
Storage: 25 GB - 400 GB SSD
Transfer: 4 TB - 9 TB
Price: $42/month - $672/month
```

### 4. Memory-Optimized Droplets
**Best for**: In-memory databases, caching, big data analytics

```
CPU: Dedicated
RAM: 16 GB - 256 GB
Storage: 50 GB - 500 GB SSD
Transfer: 4 TB - 9 TB
Price: $126/month - $2,016/month
```

### 5. Storage-Optimized Droplets
**Best for**: Data warehousing, log processing, large databases

```
CPU: Dedicated
RAM: 16 GB - 256 GB
Storage: 600 GB - 7,680 GB SSD
Transfer: 5 TB - 10 TB
Price: $168/month - $2,688/month
```

## Droplet Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DigitalOcean Datacenter                   │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Hypervisor Layer (KVM)                    │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                  Your Droplet                          │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Operating System (Ubuntu, Debian, etc.)         │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Your Applications & Services                    │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Resources:                                            │ │
│  │  ├─> vCPU: 1-32 cores                                 │ │
│  │  ├─> RAM: 512 MB - 256 GB                             │ │
│  │  ├─> Storage: 10 GB - 7,680 GB SSD                    │ │
│  │  ├─> Network: Public + Private IPs                    │ │
│  │  └─> Bandwidth: 500 GB - 10 TB                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Networking Layer                          │ │
│  │  ├─> Public IPv4                                       │ │
│  │  ├─> Public IPv6                                       │ │
│  │  ├─> Private VPC Network                              │ │
│  │  └─> Reserved IPs (optional)                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Storage Layer                             │ │
│  │  ├─> Local SSD (included)                             │ │
│  │  ├─> Block Storage Volumes (optional)                 │ │
│  │  └─> Spaces Object Storage (optional)                 │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Supported Operating Systems

### Linux Distributions

**Ubuntu** (Most Popular)
- Ubuntu 24.04 LTS
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS

**Debian**
- Debian 12
- Debian 11
- Debian 10

**CentOS / Rocky Linux / AlmaLinux**
- Rocky Linux 9
- AlmaLinux 9
- CentOS Stream 9

**Fedora**
- Fedora 39
- Fedora 38

**Other**
- openSUSE Leap
- Arch Linux

### BSD Systems
- FreeBSD 14
- FreeBSD 13

### Container-Optimized
- RancherOS
- Flatcar Container Linux

## Droplet Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    Droplet Lifecycle                         │
└─────────────────────────────────────────────────────────────┘

1. Creation
   ├─> Choose region
   ├─> Select size
   ├─> Pick OS image
   ├─> Configure options
   └─> Launch (< 55 seconds)

2. Running
   ├─> Access via SSH
   ├─> Install applications
   ├─> Configure services
   └─> Monitor performance

3. Management
   ├─> Resize (scale up/down)
   ├─> Create snapshots
   ├─> Enable backups
   ├─> Add volumes
   └─> Configure networking

4. Maintenance
   ├─> Power off/on
   ├─> Reboot
   ├─> Rebuild
   └─> Restore from backup

5. Termination
   ├─> Create final snapshot (optional)
   ├─> Backup data
   ├─> Destroy Droplet
   └─> Resources released
```

## Pricing Model

### Hourly Billing
- Charged per hour of usage
- Billed monthly
- Minimum charge: 1 hour
- Maximum charge: Monthly cap

### Example Pricing (as of 2026)

| Type | vCPU | RAM | Storage | Transfer | Price/Month |
|------|------|-----|---------|----------|-------------|
| Basic | 1 | 1 GB | 25 GB | 1 TB | $6 |
| Basic | 2 | 2 GB | 50 GB | 2 TB | $12 |
| Basic | 2 | 4 GB | 80 GB | 4 TB | $24 |
| General Purpose | 2 | 8 GB | 25 GB | 4 TB | $63 |
| CPU-Optimized | 2 | 4 GB | 25 GB | 4 TB | $42 |
| Memory-Optimized | 2 | 16 GB | 50 GB | 4 TB | $126 |

## Use Cases

### 1. Web Hosting
```
Droplet Configuration:
├─> Type: Basic or General Purpose
├─> Size: 1-2 GB RAM
├─> OS: Ubuntu 22.04 LTS
├─> Software: NGINX, PHP, MySQL
└─> Add-ons: Managed Database, Spaces
```

### 2. Application Server
```
Droplet Configuration:
├─> Type: General Purpose
├─> Size: 4-8 GB RAM
├─> OS: Ubuntu 22.04 LTS
├─> Software: Node.js, Python, Java
└─> Add-ons: Load Balancer, VPC
```

### 3. Database Server
```
Droplet Configuration:
├─> Type: Memory-Optimized
├─> Size: 16-32 GB RAM
├─> OS: Ubuntu 22.04 LTS
├─> Software: PostgreSQL, MongoDB
└─> Add-ons: Block Storage, Backups
```

### 4. Development Environment
```
Droplet Configuration:
├─> Type: Basic
├─> Size: 2-4 GB RAM
├─> OS: Ubuntu 22.04 LTS
├─> Software: Docker, Git, IDE
└─> Add-ons: Snapshots
```

### 5. CI/CD Pipeline
```
Droplet Configuration:
├─> Type: CPU-Optimized
├─> Size: 4-8 GB RAM
├─> OS: Ubuntu 22.04 LTS
├─> Software: Jenkins, GitLab Runner
└─> Add-ons: Block Storage, VPC
```

## Key Concepts

### Regions & Availability
- **15+ Global Regions**: NYC, SFO, LON, AMS, SGP, BLR, etc.
- **Multiple Datacenters**: NYC1, NYC2, NYC3
- **Low Latency**: Choose region closest to users
- **Data Residency**: Comply with local regulations

### Networking
- **Public IPv4**: Included with every Droplet
- **Public IPv6**: Free, optional
- **Private Networking**: VPC included
- **Reserved IPs**: Static IPs that can be remapped
- **Bandwidth**: Generous transfer allowances

### Storage
- **Local SSD**: Fast, included storage
- **Block Storage**: Attach additional volumes
- **Snapshots**: Point-in-time backups
- **Backups**: Automated weekly backups
- **Spaces**: Object storage (S3-compatible)

### Security
- **Cloud Firewalls**: Network-level security
- **SSH Keys**: Secure authentication
- **VPC**: Network isolation
- **Monitoring**: Built-in metrics
- **Team Access**: Role-based permissions

## Getting Started

### Quick Start (5 Minutes)

```bash
# 1. Install doctl CLI
brew install doctl  # macOS
# or
snap install doctl  # Linux

# 2. Authenticate
doctl auth init

# 3. Create SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# 4. Add SSH key to DigitalOcean
doctl compute ssh-key import my-key --public-key-file ~/.ssh/id_ed25519.pub

# 5. Create Droplet
doctl compute droplet create my-droplet \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header)

# 6. Get Droplet IP
doctl compute droplet list --format Name,PublicIPv4

# 7. SSH into Droplet
ssh root@<droplet-ip>
```

## Best Practices

### 1. Security
- Use SSH keys (not passwords)
- Enable Cloud Firewall
- Keep OS and software updated
- Use VPC for internal communication
- Enable monitoring and alerts

### 2. Performance
- Choose appropriate Droplet size
- Use local SSD for databases
- Enable IPv6 for better connectivity
- Monitor resource usage
- Scale vertically when needed

### 3. Reliability
- Enable automated backups
- Create regular snapshots
- Use multiple Droplets with Load Balancer
- Deploy across multiple regions
- Test disaster recovery procedures

### 4. Cost Optimization
- Right-size your Droplets
- Use Basic Droplets for development
- Delete unused Droplets
- Use snapshots instead of keeping idle Droplets
- Monitor bandwidth usage

### 5. Management
- Use tags for organization
- Implement naming conventions
- Use doctl or API for automation
- Document your infrastructure
- Use Infrastructure as Code (Terraform)

## Comparison with Other Providers

| Feature | DigitalOcean | AWS EC2 | Azure VM | GCP Compute |
|---------|--------------|---------|----------|-------------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Pricing** | Simple, predictable | Complex | Complex | Complex |
| **Setup Time** | < 1 minute | 2-5 minutes | 2-5 minutes | 2-5 minutes |
| **Min Price** | $4/month | ~$8/month | ~$13/month | ~$7/month |
| **Free Tier** | $200 credit | 12 months | 12 months | 90 days |
| **Support** | Community + Paid | Paid tiers | Paid tiers | Paid tiers |

## Documentation Structure

This documentation covers:

1. **[Droplets Overview](./0-DROPLETS-OVERVIEW.md)** - This page
2. **[Creating Droplets](./1-CREATING-DROPLETS.md)** - How to create and configure
3. **[Managing Droplets](./2-MANAGING-DROPLETS.md)** - Day-to-day operations
4. **[Droplet Images](./3-DROPLET-IMAGES.md)** - OS images, snapshots, backups
5. **[Droplet Networking](./4-DROPLET-NETWORKING.md)** - Network configuration
6. **[Droplet Storage](./5-DROPLET-STORAGE.md)** - Storage options and management
7. **[Droplet Security](./6-DROPLET-SECURITY.md)** - Security best practices
8. **[Droplet Monitoring](./7-DROPLET-MONITORING.md)** - Monitoring and alerts
9. **[Droplet Automation](./8-DROPLET-AUTOMATION.md)** - API, CLI, Terraform
10. **[Droplet Troubleshooting](./9-DROPLET-TROUBLESHOOTING.md)** - Common issues

## Quick Reference

### Common Commands

```bash
# List Droplets
doctl compute droplet list

# Create Droplet
doctl compute droplet create NAME --size SIZE --image IMAGE --region REGION

# Get Droplet info
doctl compute droplet get DROPLET_ID

# Power operations
doctl compute droplet-action power-off DROPLET_ID
doctl compute droplet-action power-on DROPLET_ID
doctl compute droplet-action reboot DROPLET_ID

# Resize Droplet
doctl compute droplet-action resize DROPLET_ID --size NEW_SIZE

# Create snapshot
doctl compute droplet-action snapshot DROPLET_ID --snapshot-name NAME

# Delete Droplet
doctl compute droplet delete DROPLET_ID
```

### Common Sizes

```
s-1vcpu-1gb      # 1 vCPU, 1 GB RAM, 25 GB SSD - $6/mo
s-1vcpu-2gb      # 1 vCPU, 2 GB RAM, 50 GB SSD - $12/mo
s-2vcpu-2gb      # 2 vCPU, 2 GB RAM, 60 GB SSD - $18/mo
s-2vcpu-4gb      # 2 vCPU, 4 GB RAM, 80 GB SSD - $24/mo
s-4vcpu-8gb      # 4 vCPU, 8 GB RAM, 160 GB SSD - $48/mo
```

## Next Steps

- [Create your first Droplet](./1-CREATING-DROPLETS.md)
- [Learn about Droplet management](./2-MANAGING-DROPLETS.md)
- [Explore networking options](./4-DROPLET-NETWORKING.md)
- [Set up monitoring](./7-DROPLET-MONITORING.md)
- [Automate with API/CLI](./8-DROPLET-AUTOMATION.md)

## Additional Resources

- [DigitalOcean Documentation](https://docs.digitalocean.com/products/droplets/)
- [Community Tutorials](https://www.digitalocean.com/community/tutorials)
- [API Reference](https://docs.digitalocean.com/reference/api/)
- [doctl CLI Reference](https://docs.digitalocean.com/reference/doctl/)
- [Terraform Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
