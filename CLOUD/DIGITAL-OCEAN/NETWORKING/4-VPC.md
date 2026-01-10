# DigitalOcean Virtual Private Cloud (VPC)

## Overview

A Virtual Private Cloud (VPC) is a private network for your DigitalOcean resources, providing network isolation and secure communication between your Droplets, databases, and other services. VPCs are regional, free, and automatically created for new accounts.

## Key Features

- **Network Isolation**: Private IP space isolated from other customers
- **Free**: No additional cost for VPC usage
- **Regional**: Scoped to a specific datacenter region
- **Automatic**: Default VPC created automatically
- **Customizable**: Define your own IP ranges (CIDR blocks)
- **Secure**: Traffic stays within DigitalOcean's network
- **Flexible**: Multiple VPCs per region
- **Cross-Resource**: Connect Droplets, databases, Kubernetes, etc.

## VPC Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DigitalOcean Region (NYC3)                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              VPC: production-vpc                        │ │
│  │              CIDR: 10.10.0.0/16                        │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │         Public Subnet: 10.10.1.0/24              │  │ │
│  │  │                                                   │  │ │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │ │
│  │  │  │ Droplet  │  │ Droplet  │  │   Load   │      │  │ │
│  │  │  │  Web 1   │  │  Web 2   │  │ Balancer │      │  │ │
│  │  │  │ Public   │  │ Public   │  │          │      │  │ │
│  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘      │  │ │
│  │  └───────┼─────────────┼─────────────┼────────────┘  │ │
│  │          │             │             │                │ │
│  │  ┌───────┼─────────────┼─────────────┼────────────┐  │ │
│  │  │       │  Private Subnet: 10.10.2.0/24          │  │ │
│  │  │       │             │             │             │  │ │
│  │  │  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐     │  │ │
│  │  │  │ Droplet  │  │ Droplet  │  │ Droplet  │     │  │ │
│  │  │  │  App 1   │  │  App 2   │  │  App 3   │     │  │ │
│  │  │  │ Private  │  │ Private  │  │ Private  │     │  │ │
│  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘     │  │ │
│  │  └───────┼─────────────┼─────────────┼────────────┘  │ │
│  │          │             │             │                │ │
│  │  ┌───────┼─────────────┼─────────────┼────────────┐  │ │
│  │  │       │  Database Subnet: 10.10.3.0/24         │  │ │
│  │  │       │             │             │             │  │ │
│  │  │  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐     │  │ │
│  │  │  │ Database │  │ Database │  │  Redis   │     │  │ │
│  │  │  │ Primary  │  │ Replica  │  │  Cache   │     │  │ │
│  │  │  │ Private  │  │ Private  │  │ Private  │     │  │ │
│  │  │  └──────────┘  └──────────┘  └──────────┘     │  │ │
│  │  └──────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## VPC vs Traditional Networking

| Feature | VPC Network | Traditional Network |
|---------|-------------|-------------------|
| **Isolation** | Private, isolated network | Shared network space |
| **IP Range** | Customizable CIDR | Fixed ranges |
| **Security** | Network-level isolation | Firewall-only |
| **Communication** | Private IPs within VPC | Public or private IPs |
| **Cost** | Free | Free |
| **Flexibility** | Multiple VPCs per region | Single network |
| **Cross-Region** | Requires VPN/peering | Same limitation |

## IP Address Ranges (CIDR Blocks)

### Recommended Private IP Ranges (RFC 1918)

```
10.0.0.0/8        (10.0.0.0 - 10.255.255.255)
172.16.0.0/12     (172.16.0.0 - 172.31.255.255)
192.168.0.0/16    (192.168.0.0 - 192.168.255.255)
```

### Common VPC CIDR Configurations

```
Small VPC:     10.10.0.0/24    (256 IPs)
Medium VPC:    10.10.0.0/20    (4,096 IPs)
Large VPC:     10.10.0.0/16    (65,536 IPs)
Extra Large:   10.0.0.0/8      (16,777,216 IPs)
```

### Subnet Planning Example

```
VPC: 10.10.0.0/16 (65,536 IPs)
├─> Public Subnet:    10.10.1.0/24   (256 IPs)
├─> App Subnet:       10.10.2.0/24   (256 IPs)
├─> Database Subnet:  10.10.3.0/24   (256 IPs)
├─> Cache Subnet:     10.10.4.0/24   (256 IPs)
└─> Reserved:         10.10.5.0/19   (8,192 IPs for future use)
```

## Creating a VPC

### Via Control Panel

1. Navigate to **Networking** → **VPC**
2. Click **Create VPC Network**
3. Configure:
   - **Name**: production-vpc
   - **Region**: Select datacenter
   - **IP Range**: 10.10.0.0/16 (or custom)
   - **Description**: Optional description
4. Click **Create VPC Network**

### Via API

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "production-vpc",
    "description": "Production environment VPC",
    "region": "nyc3",
    "ip_range": "10.10.0.0/16"
  }' \
  "https://api.digitalocean.com/v2/vpcs"
```

### Via doctl CLI

```bash
doctl vpcs create \
  --name production-vpc \
  --region nyc3 \
  --ip-range 10.10.0.0/16 \
  --description "Production environment VPC"
```

## Adding Resources to VPC

### Droplets

#### During Creation
```bash
doctl compute droplet create web-server \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid vpc-uuid-here
```

#### Existing Droplet
Droplets cannot be moved between VPCs after creation. You must:
1. Create snapshot of Droplet
2. Create new Droplet from snapshot in target VPC
3. Migrate data and DNS
4. Delete old Droplet

### Databases

```bash
doctl databases create postgres-prod \
  --engine pg \
  --region nyc3 \
  --size db-s-1vcpu-1gb \
  --vpc-uuid vpc-uuid-here
```

### Kubernetes Clusters

```bash
doctl kubernetes cluster create k8s-prod \
  --region nyc3 \
  --vpc-uuid vpc-uuid-here \
  --node-pool "name=worker-pool;size=s-2vcpu-2gb;count=3"
```

### Load Balancers

```bash
doctl compute load-balancer create \
  --name web-lb \
  --region nyc3 \
  --vpc-uuid vpc-uuid-here \
  --forwarding-rules entry_protocol:http,entry_port:80,target_protocol:http,target_port:80
```

## VPC Communication Patterns

### Same VPC Communication

```
┌─────────────────────────────────────────┐
│           VPC: 10.10.0.0/16             │
│                                         │
│  Droplet A (10.10.1.5)                 │
│      │                                  │
│      │ Private IP Communication         │
│      │ (Fast, Secure, Free)            │
│      │                                  │
│      └──────> Droplet B (10.10.1.6)    │
│                                         │
└─────────────────────────────────────────┘

Traffic stays within VPC - No internet routing
```

### Cross-VPC Communication

```
┌─────────────────────────┐    ┌─────────────────────────┐
│  VPC A: 10.10.0.0/16    │    │  VPC B: 10.20.0.0/16    │
│                         │    │                         │
│  Droplet A (10.10.1.5)  │    │  Droplet B (10.20.1.5)  │
│      │                  │    │      ▲                  │
│      │                  │    │      │                  │
└──────┼──────────────────┘    └──────┼──────────────────┘
       │                              │
       │  Public IP: 203.0.113.10    │
       └──────────────────────────────┘

Requires public IPs or VPN tunnel
```

### Internet Access from VPC

```
┌─────────────────────────────────────────┐
│           VPC: 10.10.0.0/16             │
│                                         │
│  Droplet (10.10.1.5)                   │
│      │                                  │
│      │ Has Public IP: 203.0.113.10     │
│      │                                  │
└──────┼──────────────────────────────────┘
       │
       └──────> Internet
```

## Multi-VPC Architecture

### Environment Separation

```
┌─────────────────────────────────────────────────────────────┐
│                  Region: NYC3                                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Production VPC (10.10.0.0/16)                         │ │
│  │  ├─> Web Tier                                          │ │
│  │  ├─> App Tier                                          │ │
│  │  └─> Database Tier                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Staging VPC (10.20.0.0/16)                            │ │
│  │  ├─> Web Tier                                          │ │
│  │  ├─> App Tier                                          │ │
│  │  └─> Database Tier                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Development VPC (10.30.0.0/16)                        │ │
│  │  ├─> Web Tier                                          │ │
│  │  ├─> App Tier                                          │ │
│  │  └─> Database Tier                                     │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Service Separation

```
┌─────────────────────────────────────────────────────────────┐
│                  Region: NYC3                                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Web Services VPC (10.10.0.0/16)                       │ │
│  │  ├─> Frontend Droplets                                 │ │
│  │  ├─> API Gateway                                       │ │
│  │  └─> Load Balancers                                    │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Application VPC (10.20.0.0/16)                        │ │
│  │  ├─> Microservices                                     │ │
│  │  ├─> Background Workers                                │ │
│  │  └─> Message Queues                                    │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Data VPC (10.30.0.0/16)                               │ │
│  │  ├─> Databases                                         │ │
│  │  ├─> Cache Clusters                                    │ │
│  │  └─> Analytics                                         │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## VPC Peering (via VPN)

Connect VPCs across regions using VPN:

```
┌─────────────────────────┐         ┌─────────────────────────┐
│  VPC NYC3               │         │  VPC SFO3               │
│  10.10.0.0/16           │         │  10.20.0.0/16           │
│                         │         │                         │
│  ┌──────────────────┐   │         │   ┌──────────────────┐ │
│  │ VPN Gateway      │   │         │   │ VPN Gateway      │ │
│  │ (Droplet)        │◄──┼─────────┼──►│ (Droplet)        │ │
│  └──────────────────┘   │         │   └──────────────────┘ │
│           │             │         │           │             │
│  ┌────────▼─────────┐   │         │   ┌───────▼──────────┐ │
│  │ Internal         │   │         │   │ Internal         │ │
│  │ Resources        │   │         │   │ Resources        │ │
│  └──────────────────┘   │         │   └──────────────────┘ │
└─────────────────────────┘         └─────────────────────────┘
```

## Security with VPC

### Network Isolation

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                           │
└─────────────────────────────────────────────────────────────┘

Layer 1: VPC Isolation
├─> Private IP space
├─> Isolated from other customers
└─> No cross-VPC communication by default

Layer 2: Cloud Firewalls
├─> Inbound rules
├─> Outbound rules
└─> Tag-based policies

Layer 3: Droplet Firewalls (iptables/ufw)
├─> Host-level rules
├─> Application-specific
└─> Defense in depth

Layer 4: Application Security
├─> Authentication
├─> Authorization
└─> Encryption
```

### Best Practice Architecture

```
                    Internet
                        │
                        │ (HTTPS only)
                        │
                ┌───────▼────────┐
                │  Cloud Firewall │
                │  Allow: 443, 80 │
                └───────┬────────┘
                        │
                ┌───────▼────────┐
                │ Load Balancer  │
                │  (Public VPC)  │
                └───────┬────────┘
                        │
                ┌───────▼────────┐
                │  Cloud Firewall │
                │  Allow: 80 from │
                │  Load Balancer  │
                └───────┬────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐     ┌────▼────┐    ┌────▼────┐
   │  Web    │     │  Web    │    │  Web    │
   │ Droplet │     │ Droplet │    │ Droplet │
   └────┬────┘     └────┬────┘    └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                ┌───────▼────────┐
                │  Cloud Firewall │
                │  Allow: 5432    │
                │  from Web tier  │
                └───────┬────────┘
                        │
                ┌───────▼────────┐
                │   Database     │
                │  (Private VPC) │
                │  No Public IP  │
                └────────────────┘
```

## VPC Management

### List VPCs

```bash
# Via API
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/vpcs"

# Via doctl
doctl vpcs list
```

### Get VPC Details

```bash
# Via API
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/vpcs/vpc-uuid"

# Via doctl
doctl vpcs get vpc-uuid
```

### Update VPC

```bash
# Via API
curl -X PATCH \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "production-vpc-updated",
    "description": "Updated description"
  }' \
  "https://api.digitalocean.com/v2/vpcs/vpc-uuid"

# Via doctl
doctl vpcs update vpc-uuid --name production-vpc-updated
```

### Delete VPC

```bash
# Via API
curl -X DELETE \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/vpcs/vpc-uuid"

# Via doctl
doctl vpcs delete vpc-uuid
```

**Note**: VPC must be empty (no resources) before deletion.

## Best Practices

1. **IP Range Planning**
   - Use non-overlapping CIDR blocks
   - Plan for future growth
   - Document IP allocations
   - Avoid conflicts with on-premises networks

2. **VPC Organization**
   - Separate environments (prod, staging, dev)
   - One VPC per environment or service
   - Use descriptive names
   - Tag resources appropriately

3. **Security**
   - Use private IPs for internal communication
   - Implement Cloud Firewalls
   - Minimize public IP exposure
   - Regular security audits
   - Principle of least privilege

4. **Resource Management**
   - Group related resources in same VPC
   - Use tags for organization
   - Document VPC architecture
   - Monitor resource usage

5. **High Availability**
   - Distribute resources across availability zones
   - Use Load Balancers
   - Implement redundancy
   - Plan for failover

## Common Use Cases

### 1. Three-Tier Web Application
```
VPC: 10.10.0.0/16
├─> Web Tier (10.10.1.0/24): Public-facing web servers
├─> App Tier (10.10.2.0/24): Application servers
└─> Data Tier (10.10.3.0/24): Databases and caches
```

### 2. Microservices Architecture
```
VPC: 10.10.0.0/16
├─> API Gateway (10.10.1.0/24)
├─> Service Mesh (10.10.2.0/23)
├─> Data Layer (10.10.4.0/24)
└─> Monitoring (10.10.5.0/24)
```

### 3. Development Environments
```
Production VPC: 10.10.0.0/16
Staging VPC: 10.20.0.0/16
Development VPC: 10.30.0.0/16
```

## Troubleshooting

### Cannot Connect Between Droplets

```bash
# Check VPC membership
doctl compute droplet get droplet-id --format ID,Name,VPC

# Verify private IPs
ip addr show

# Test connectivity
ping 10.10.1.5

# Check firewall rules
sudo ufw status
sudo iptables -L
```

### IP Address Conflicts

```bash
# List all resources in VPC
doctl vpcs get vpc-uuid --format Name,IPRange,Resources

# Check for overlapping ranges
# Ensure CIDR blocks don't overlap
```

### Resource Cannot Join VPC

- Verify resource is in same region as VPC
- Check if VPC has available IP addresses
- Ensure resource type supports VPC
- Review API error messages

## Pricing

- **VPC Networks**: Free
- **Data Transfer**: Within VPC is free
- **Resources**: Standard pricing applies (Droplets, databases, etc.)

## Limitations

- VPCs are regional (cannot span regions)
- Cannot change VPC after resource creation
- Maximum IP range: /16 (65,536 IPs)
- Minimum IP range: /24 (256 IPs)
- No native VPC peering (use VPN)

## Related Services

- [Cloud Firewalls](./5-CLOUD-FIREWALLS.md) - Secure VPC resources
- [Load Balancers](./3-LOAD-BALANCERS.md) - Distribute traffic within VPC
- [Multi-Cloud Integration](./7-MULTI-CLOUD-INTEGRATION.md) - Connect VPC to other clouds
