# 6️⃣ Networking

Complete guide to Google Cloud Platform networking - one of the most critical skills for cloud architects.

---

## 📚 What You'll Learn

Master GCP networking to build secure, scalable, and high-performance cloud architectures:

- **VPC Fundamentals**: Virtual Private Cloud design and implementation
- **Network Connectivity**: Connect resources securely
- **Traffic Management**: Load balancing and routing
- **Security**: Firewall rules and network isolation
- **Hybrid Cloud**: Connect on-premises to GCP
- **Performance**: CDN, DNS, and optimization

---

## 📖 Table of Contents

### [1. VPC (Virtual Private Cloud)](./1-VPC.md)
**Foundation of GCP Networking**

```
Topics Covered:
  • VPC architecture and concepts
  • Auto mode vs Custom mode VPCs
  • VPC network characteristics
  • Shared VPC
  • VPC peering
  • VPC network design patterns
  • Best practices
```

**Key Concepts:**
- Global VPC networks
- Regional subnets
- Software-defined networking
- Network isolation

---

### [2. Subnets](./2-Subnets.md)
**IP Address Management**

```
Topics Covered:
  • Subnet creation and management
  • Primary and secondary IP ranges
  • Subnet expansion
  • Regional subnets
  • Private Google Access
  • Subnet design patterns
  • CIDR planning
```

**Key Concepts:**
- Regional scope
- IP address allocation
- Subnet sizing
- Secondary ranges for GKE

---

### [3. Firewall Rules](./3-Firewall-Rules.md)
**Network Security**

```
Topics Covered:
  • Firewall rule structure
  • Ingress and egress rules
  • Priority and evaluation
  • Target tags and service accounts
  • Firewall logs
  • Common firewall patterns
  • Security best practices
```

**Key Concepts:**
- Stateful firewall
- Implicit deny
- Rule priority
- Network tags

---

### [4. IP Addressing](./4-IP-Addressing.md)
**Public and Private IPs**

```
Topics Covered:
  • Internal (private) IP addresses
  • External (public) IP addresses
  • Ephemeral vs static IPs
  • IP address reservation
  • Alias IP ranges
  • IPv6 support
  • IP address planning
```

**Key Concepts:**
- RFC 1918 private ranges
- External IP costs
- Static IP reservation
- Bring Your Own IP (BYOIP)

---

### [5. Routing](./5-Routing.md)
**Traffic Direction**

```
Topics Covered:
  • Route types (system, custom, peering)
  • Route priority
  • Next hop types
  • Policy-based routing
  • Route advertisements
  • Multi-NIC routing
  • Troubleshooting routes
```

**Key Concepts:**
- Default internet gateway
- Route tables
- Next hop selection
- Route propagation

---

### [6. Cloud NAT](./6-Cloud-NAT.md)
**Outbound Internet Access**

```
Topics Covered:
  • Cloud NAT architecture
  • NAT gateway configuration
  • IP address allocation
  • Port allocation
  • Logging and monitoring
  • High availability
  • Cost optimization
```

**Key Concepts:**
- Managed NAT service
- No external IPs needed
- Regional service
- Automatic scaling

---

### [7. Load Balancing](./7-Load-Balancing.md)
**Traffic Distribution**

```
Topics Covered:
  • Load balancer types
  • Global vs Regional LBs
  • HTTP(S) Load Balancing
  • TCP/UDP Load Balancing
  • Internal Load Balancing
  • Backend services
  • Health checks
```

**Key Concepts:**
- Anycast IP
- Cross-region load balancing
- SSL termination
- Session affinity

---

### [8. Cloud DNS](./8-Cloud-DNS.md)
**Domain Name System**

```
Topics Covered:
  • Public DNS zones
  • Private DNS zones
  • DNS records management
  • DNSSEC
  • DNS policies
  • Split-horizon DNS
  • Performance optimization
```

**Key Concepts:**
- Managed DNS service
- 100% SLA
- Global anycast network
- Low latency

---

### [9. Cloud CDN](./9-Cloud-CDN.md)
**Content Delivery Network**

```
Topics Covered:
  • CDN architecture
  • Cache configuration
  • Cache invalidation
  • Signed URLs and cookies
  • Custom origins
  • Performance optimization
  • Cost management
```

**Key Concepts:**
- Edge caching
- Global distribution
- Cache hit ratio
- Origin shielding

---

### [10. Cloud VPN](./10-Cloud-VPN.md)
**Hybrid Connectivity**

```
Topics Covered:
  • Classic VPN
  • HA VPN (recommended)
  • VPN tunnels
  • BGP routing
  • IPsec configuration
  • Redundancy and HA
  • Troubleshooting
```

**Key Concepts:**
- Site-to-site VPN
- 99.99% SLA (HA VPN)
- Encrypted tunnels
- Hybrid cloud

---

### [11. Cloud Interconnect](./11-Cloud-Interconnect.md)
**Dedicated Connectivity**

```
Topics Covered:
  • Dedicated Interconnect
  • Partner Interconnect
  • VLAN attachments
  • Bandwidth options
  • Redundancy design
  • Cost comparison
  • Use cases
```

**Key Concepts:**
- Private connectivity
- Higher bandwidth
- Lower latency
- Predictable performance

---

### [12. Network Security](./12-Network-Security.md)
**Advanced Security**

```
Topics Covered:
  • Cloud Armor (DDoS protection)
  • VPC Service Controls
  • Private Service Connect
  • SSL policies
  • Network security best practices
  • Zero-trust networking
  • Compliance
```

**Key Concepts:**
- Defense in depth
- Security perimeters
- Private connectivity
- DDoS mitigation

---

## 🌐 GCP Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP Global Network                            │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │  Internet        │
                    │  Users           │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Cloud CDN       │  ← Edge caching
                    │  (Global)        │     200+ PoPs
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Global Load     │  ← Anycast IP
                    │  Balancer        │     SSL termination
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
        │ Region 1  │  │Region 2 │  │ Region 3  │
        │ us-cent1  │  │eu-west1 │  │asia-se1   │
        └─────┬─────┘  └────┬────┘  └─────┬─────┘
              │             │              │
        ┌─────▼─────┐  ┌───▼────┐   ┌────▼─────┐
        │    VPC    │  │  VPC   │   │   VPC    │
        │  Network  │  │ Network│   │  Network │
        └─────┬─────┘  └───┬────┘   └────┬─────┘
              │            │              │
        ┌─────▼─────┐  ┌──▼─────┐   ┌───▼──────┐
        │  Subnets  │  │Subnets │   │ Subnets  │
        │  10.0.x.x │  │10.1.x.x│   │10.2.x.x  │
        └─────┬─────┘  └───┬────┘   └────┬─────┘
              │            │              │
        ┌─────▼─────┐  ┌──▼─────┐   ┌───▼──────┐
        │    VMs    │  │  VMs   │   │   VMs    │
        │  GKE      │  │  GKE   │   │   GKE    │
        │  Services │  │Services│   │ Services │
        └───────────┘  └────────┘   └──────────┘

Key Features:
  • Global VPC (spans all regions)
  • Regional subnets
  • Private Google network
  • No inter-region bandwidth charges
  • Software-defined networking
```

---

## 💡 Key Networking Concepts

### 1. VPC Network Scope

```
┌────────────────────────────────────────────────────────┐
│  VPC Network Characteristics                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Global Scope:                                         │
│  • VPC spans all GCP regions                           │
│  • Single VPC across multiple regions                  │
│  • No region boundaries                                │
│                                                         │
│  Regional Subnets:                                     │
│  • Subnets are regional resources                      │
│  • Each subnet in one region                           │
│  • Multiple subnets per region                         │
│                                                         │
│  Benefits:                                             │
│  • Simplified network architecture                     │
│  • Easy multi-region deployment                        │
│  • No VPN between regions                              │
│  • Consistent security policies                        │
│                                                         │
│  Example:                                              │
│  VPC: prod-vpc (global)                                │
│  ├─ Subnet: us-central1 (10.0.1.0/24)                 │
│  ├─ Subnet: europe-west1 (10.0.2.0/24)                │
│  └─ Subnet: asia-southeast1 (10.0.3.0/24)             │
│                                                         │
│  VMs in different regions can communicate directly     │
│  using internal IPs without VPN or peering             │
└────────────────────────────────────────────────────────┘
```

### 2. Network Tiers

```
┌────────────────────────────────────────────────────────┐
│  Premium Tier vs Standard Tier                         │
└────────────────────────────────────────────────────────┘

Premium Tier (Default):
┌─────────────────────────────────────────────────────┐
│  User → Edge PoP → Google Network → Destination    │
│         (Enters Google network immediately)         │
│                                                     │
│  Benefits:                                          │
│  • Lowest latency                                   │
│  • Highest reliability                              │
│  • Global load balancing                            │
│  • Better performance                               │
│  • SLA guarantees                                   │
│                                                     │
│  Cost: Higher                                       │
└─────────────────────────────────────────────────────┘

Standard Tier:
┌─────────────────────────────────────────────────────┐
│  User → ISP → Internet → Region → Destination      │
│         (Uses public internet)                      │
│                                                     │
│  Trade-offs:                                        │
│  • Lower cost (50% cheaper)                         │
│  • Higher latency                                   │
│  • Less reliable                                    │
│  • Regional load balancing only                     │
│  • No global LB                                     │
│                                                     │
│  Cost: Lower                                        │
└─────────────────────────────────────────────────────┘

Use Cases:
  Premium: Production apps, global users, low latency
  Standard: Cost-sensitive, regional apps, batch jobs
```

### 3. Private vs Public IP

```
┌────────────────────────────────────────────────────────┐
│  IP Address Types                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Internal (Private) IP:                                │
│  • RFC 1918 ranges (10.x, 172.16-31.x, 192.168.x)     │
│  • Free (no cost)                                      │
│  • Not routable on internet                            │
│  • Used for internal communication                     │
│  • Assigned to all VMs                                 │
│                                                         │
│  External (Public) IP:                                 │
│  • Routable on internet                                │
│  • Costs money (charged per hour)                      │
│  • Optional (not required)                             │
│  • Ephemeral or static                                 │
│  • Used for internet access                            │
│                                                         │
│  Best Practice:                                        │
│  • Use internal IPs for inter-VM communication         │
│  • Use Cloud NAT for outbound internet                 │
│  • Minimize external IPs (cost + security)             │
│  • Use load balancers for inbound traffic              │
└────────────────────────────────────────────────────────┘
```

---

## 🏗️ Common Network Architectures

### 1. Single Region Architecture

```
┌────────────────────────────────────────────────────────────┐
│  Single Region Deployment                                  │
└────────────────────────────────────────────────────────────┘

Internet
    │
    ▼
┌─────────────────────┐
│  Global Load        │
│  Balancer           │
│  (External IP)      │
└──────────┬──────────┘
           │
    ┌──────▼──────┐
    │  Region:    │
    │  us-central1│
    └──────┬──────┘
           │
    ┌──────▼──────────────────────────┐
    │  VPC: prod-vpc                  │
    │                                 │
    │  ┌────────────────────────────┐│
    │  │ Subnet: web-tier           ││
    │  │ 10.0.1.0/24                ││
    │  │ ┌────┐ ┌────┐ ┌────┐      ││
    │  │ │VM-1│ │VM-2│ │VM-3│      ││
    │  │ └────┘ └────┘ └────┘      ││
    │  └────────────────────────────┘│
    │                                 │
    │  ┌────────────────────────────┐│
    │  │ Subnet: app-tier           ││
    │  │ 10.0.2.0/24                ││
    │  │ ┌────┐ ┌────┐             ││
    │  │ │VM-4│ │VM-5│             ││
    │  │ └────┘ └────┘             ││
    │  └────────────────────────────┘│
    │                                 │
    │  ┌────────────────────────────┐│
    │  │ Subnet: db-tier            ││
    │  │ 10.0.3.0/24                ││
    │  │ ┌──────────┐               ││
    │  │ │Cloud SQL │               ││
    │  │ └──────────┘               ││
    │  └────────────────────────────┘│
    └─────────────────────────────────┘

Firewall Rules:
  • Allow HTTP/HTTPS to web-tier
  • Allow app-tier to web-tier
  • Allow db-tier to app-tier
  • Deny all other traffic
```

### 2. Multi-Region Architecture

```
┌────────────────────────────────────────────────────────────┐
│  Multi-Region Global Deployment                            │
└────────────────────────────────────────────────────────────┘

                    Internet
                       │
                       ▼
            ┌──────────────────┐
            │  Global Load     │  ← Anycast IP
            │  Balancer        │     (1.2.3.4)
            │  + Cloud CDN     │
            └────────┬─────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼────┐  ┌───▼────┐  ┌───▼────┐
   │us-cent1 │  │eu-west1│  │asia-se1│
   │         │  │        │  │        │
   │Subnet:  │  │Subnet: │  │Subnet: │
   │10.0.1.x │  │10.0.2.x│  │10.0.3.x│
   │         │  │        │  │        │
   │┌──────┐ │  │┌──────┐│  │┌──────┐│
   ││ VMs  │ │  ││ VMs  ││  ││ VMs  ││
   ││ GKE  │ │  ││ GKE  ││  ││ GKE  ││
   │└──────┘ │  │└──────┘│  │└──────┘│
   └─────────┘  └────────┘  └────────┘
        │            │            │
        └────────────┴────────────┘
              Cloud Spanner
           (Global Database)

Benefits:
  • Low latency worldwide
  • High availability
  • Disaster recovery
  • Automatic failover
```

### 3. Hybrid Cloud Architecture

```
┌────────────────────────────────────────────────────────────┐
│  Hybrid Cloud with VPN                                     │
└────────────────────────────────────────────────────────────┘

On-Premises Data Center          Google Cloud Platform
┌─────────────────────┐          ┌─────────────────────┐
│                     │          │                     │
│  Network:           │          │  VPC: prod-vpc      │
│  192.168.0.0/16     │          │                     │
│                     │          │  Subnet:            │
│  ┌───────────────┐ │          │  10.0.1.0/24        │
│  │ Servers       │ │          │                     │
│  │ Databases     │ │          │  ┌───────────────┐ │
│  │ Applications  │ │          │  │ VMs           │ │
│  └───────────────┘ │          │  │ GKE           │ │
│         │           │          │  │ Cloud SQL     │ │
│         │           │          │  └───────────────┘ │
│  ┌──────▼────────┐ │          │         │           │
│  │ VPN Gateway   │◄┼──────────┼────────►│           │
│  │ (On-prem)     │ │  IPsec   │  Cloud VPN Gateway │
│  └───────────────┘ │  Tunnel  │  (HA VPN)          │
└─────────────────────┘          └─────────────────────┘

Features:
  • Secure encrypted tunnel
  • Private IP connectivity
  • BGP routing
  • 99.99% SLA (HA VPN)
  • Hybrid workloads
```

---

## 🚀 Quick Start Guide

### Step 1: Create VPC Network

```bash
# Create custom VPC
gcloud compute networks create prod-vpc \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

# Create subnet
gcloud compute networks subnets create web-subnet \
  --network=prod-vpc \
  --region=us-central1 \
  --range=10.0.1.0/24
```

### Step 2: Create Firewall Rules

```bash
# Allow SSH from specific IP
gcloud compute firewall-rules create allow-ssh \
  --network=prod-vpc \
  --allow=tcp:22 \
  --source-ranges=203.0.113.0/24

# Allow HTTP/HTTPS
gcloud compute firewall-rules create allow-web \
  --network=prod-vpc \
  --allow=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-server
```

### Step 3: Create VM with Network

```bash
# Create VM in custom network
gcloud compute instances create web-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --network=prod-vpc \
  --subnet=web-subnet \
  --tags=web-server \
  --no-address  # No external IP (use Cloud NAT)
```

### Step 4: Set Up Cloud NAT

```bash
# Create Cloud Router
gcloud compute routers create nat-router \
  --network=prod-vpc \
  --region=us-central1

# Create Cloud NAT
gcloud compute routers nats create nat-config \
  --router=nat-router \
  --region=us-central1 \
  --auto-allocate-nat-external-ips \
  --nat-all-subnet-ip-ranges
```

### Step 5: Create Load Balancer

```bash
# Create instance group
gcloud compute instance-groups managed create web-group \
  --base-instance-name=web \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a

# Create health check
gcloud compute health-checks create http web-health-check \
  --port=80

# Create backend service
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --health-checks=web-health-check \
  --global

# Add instance group to backend
gcloud compute backend-services add-backend web-backend \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --global
```

---

## 📊 Network Performance

### Latency Optimization

```
┌────────────────────────────────────────────────────────┐
│  Latency Reduction Strategies                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. Use Premium Network Tier                           │
│     • Traffic on Google's network                      │
│     • Lower latency                                    │
│                                                         │
│  2. Deploy in Multiple Regions                         │
│     • Closer to users                                  │
│     • Global load balancing                            │
│                                                         │
│  3. Enable Cloud CDN                                   │
│     • Edge caching                                     │
│     • 200+ PoPs worldwide                              │
│                                                         │
│  4. Use Regional Resources                             │
│     • Reduce cross-region traffic                      │
│     • Keep data close to compute                       │
│                                                         │
│  5. Optimize DNS                                       │
│     • Use Cloud DNS                                    │
│     • Low TTL for failover                             │
└────────────────────────────────────────────────────────┘
```

---

## 💰 Network Costs

### Cost Components

```
┌────────────────────────────────────────────────────────┐
│  Network Pricing                                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Free:                                                 │
│  • Ingress (incoming traffic)                          │
│  • Traffic within same zone                            │
│  • Traffic between zones in same region (internal IP)  │
│  • Internal IP communication                           │
│                                                         │
│  Charged:                                              │
│  • Egress to internet ($0.12/GB)                       │
│  • Cross-region traffic ($0.01/GB)                     │
│  • External IP addresses ($0.004/hour)                 │
│  • Load balancer usage                                 │
│  • VPN tunnels ($0.05/hour)                            │
│  • Cloud NAT ($0.045/hour + data)                      │
│                                                         │
│  Cost Optimization:                                    │
│  ✓ Use internal IPs                                    │
│  ✓ Minimize external IPs                               │
│  ✓ Use Cloud CDN for static content                    │
│  ✓ Keep traffic in same region                         │
│  ✓ Use Standard tier for non-critical                  │
└────────────────────────────────────────────────────────┘
```

---

## ✅ Networking Checklist

### Design Phase
- [ ] Plan IP address ranges (avoid conflicts)
- [ ] Design VPC architecture
- [ ] Plan subnet layout
- [ ] Document network topology
- [ ] Plan firewall rules
- [ ] Design for high availability

### Implementation Phase
- [ ] Create VPC networks
- [ ] Create subnets
- [ ] Configure firewall rules
- [ ] Set up Cloud NAT
- [ ] Configure load balancers
- [ ] Set up DNS records

### Security Phase
- [ ] Implement least privilege firewall rules
- [ ] Enable VPC Flow Logs
- [ ] Configure Cloud Armor
- [ ] Set up VPC Service Controls
- [ ] Enable Private Google Access
- [ ] Audit network access

### Operations Phase
- [ ] Monitor network performance
- [ ] Set up alerting
- [ ] Regular security audits
- [ ] Document changes
- [ ] Test disaster recovery
- [ ] Optimize costs

---

## 🎓 Next Steps

After mastering GCP Networking:

1. **Compute Services** - Deploy workloads
2. **Storage & Databases** - Data management
3. **Security** - Advanced security features
4. **Monitoring** - Network observability
5. **Hybrid Cloud** - Connect on-premises

---

**Last Updated:** March 2026
**Version:** 2.0
