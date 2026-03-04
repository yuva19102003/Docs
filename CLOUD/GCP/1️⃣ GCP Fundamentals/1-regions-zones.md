## 1️⃣ GCP Fundamentals — Deep Dive

---

## 🌍 Google Cloud Platform Overview

Google Cloud Platform (GCP) is a **global cloud infrastructure** that provides computing, storage, networking, and advanced services to build, deploy, and scale applications.

### Core Service Categories

| Category | Services | Use Cases |
|----------|----------|-----------|
| **Compute** | Compute Engine, GKE, Cloud Run, App Engine | VMs, containers, serverless apps |
| **Storage** | Cloud Storage, Persistent Disk, Filestore | Object storage, block storage, file systems |
| **Networking** | VPC, Cloud Load Balancing, Cloud CDN | Network isolation, traffic distribution |
| **Databases** | Cloud SQL, Firestore, Bigtable, Spanner | Relational, NoSQL, wide-column, global DB |
| **AI/ML** | Vertex AI, AutoML, Vision API, Natural Language | Machine learning, computer vision, NLP |
| **DevOps** | Cloud Build, Artifact Registry, Cloud Deploy | CI/CD, container registry, deployment |
| **Security** | IAM, Secret Manager, Security Command Center | Identity, secrets, security posture |
| **Observability** | Cloud Monitoring, Cloud Logging, Cloud Trace | Metrics, logs, distributed tracing |

### Key Differentiators

```
┌─────────────────────────────────────────────────────────┐
│  Google's Infrastructure Advantages                     │
├─────────────────────────────────────────────────────────┤
│  ✓ Same infrastructure as Gmail, YouTube, Search       │
│  ✓ Private global fiber network (100+ Tbps)            │
│  ✓ Live migration of VMs (no downtime)                 │
│  ✓ Custom machine types (granular resource control)    │
│  ✓ Per-second billing (cost optimization)              │
│  ✓ Sustained use discounts (automatic savings)         │
│  ✓ Preemptible/Spot VMs (up to 91% discount)           │
└─────────────────────────────────────────────────────────┘
```

---

# 🌎 Regions & Zones

## What is a Region?

A **region** is an **independent geographic location** consisting of multiple zones. Each region is completely isolated from other regions for fault tolerance and stability.

### Global Region Coverage (2026)

| Region | Location | Zones | Key Features |
|--------|----------|-------|--------------|
| `us-central1` | Iowa, USA | 4 | Low latency to US central |
| `us-east1` | South Carolina, USA | 3 | Low latency to US east coast |
| `us-west1` | Oregon, USA | 3 | Low latency to US west coast |
| `europe-west1` | Belgium | 3 | EU data residency |
| `europe-west2` | London, UK | 3 | UK data residency |
| `asia-south1` | Mumbai, India | 3 | Low latency to India |
| `asia-southeast1` | Singapore | 3 | APAC hub |
| `asia-northeast1` | Tokyo, Japan | 3 | Low latency to Japan |
| `australia-southeast1` | Sydney | 3 | Australia data residency |
| `southamerica-east1` | São Paulo, Brazil | 3 | South America coverage |

**40+ regions globally** with continuous expansion.

### Region Selection Criteria

```
┌──────────────────────────────────────────────────────────┐
│  How to Choose a Region                                  │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. LATENCY                                              │
│     └─→ Choose region closest to your users             │
│                                                           │
│  2. DATA RESIDENCY & COMPLIANCE                          │
│     └─→ GDPR (EU), data sovereignty requirements        │
│                                                           │
│  3. SERVICE AVAILABILITY                                 │
│     └─→ Not all services available in all regions       │
│                                                           │
│  4. COST                                                 │
│     └─→ Pricing varies by region (Iowa < London)        │
│                                                           │
│  5. DISASTER RECOVERY                                    │
│     └─→ Multi-region for business continuity            │
└──────────────────────────────────────────────────────────┘
```

### Region Selection Example

```
Scenario: E-commerce app with global users

┌─────────────────────────────────────────────────────┐
│  User Base          →  Recommended Region           │
├─────────────────────────────────────────────────────┤
│  North America      →  us-central1 (primary)        │
│  Europe             →  europe-west1 (secondary)     │
│  Asia               →  asia-southeast1 (secondary)  │
└─────────────────────────────────────────────────────┘

Architecture:
  - Multi-region deployment
  - Global Load Balancer
  - Cloud CDN for static content
  - Cross-region replication for data
```

---

## What is a Zone?

A **zone** is a **deployment area within a region** that represents a single physical data center or a cluster of data centers.

### Zone Characteristics

```
Region: us-central1 (Iowa)
   │
   ├── us-central1-a  ← Zone A (Data Center 1)
   │   ├── Independent power supply
   │   ├── Independent cooling
   │   ├── Independent networking
   │   └── Isolated failure domain
   │
   ├── us-central1-b  ← Zone B (Data Center 2)
   │   └── Physically separate from Zone A
   │
   ├── us-central1-c  ← Zone C (Data Center 3)
   │   └── Physically separate from Zones A & B
   │
   └── us-central1-f  ← Zone F (Data Center 4)
       └── Additional capacity and redundancy
```

### Zone Isolation Benefits

```
┌────────────────────────────────────────────────────┐
│  Why Multiple Zones Matter                         │
├────────────────────────────────────────────────────┤
│                                                     │
│  ⚡ Power Failure in Zone A                        │
│     → Zones B, C, F continue operating            │
│                                                     │
│  🔥 Fire/Natural Disaster in Zone B               │
│     → Zones A, C, F unaffected                    │
│                                                     │
│  🔧 Maintenance in Zone C                         │
│     → Zones A, B, F handle traffic                │
│                                                     │
│  🌐 Network Issue in Zone F                       │
│     → Zones A, B, C maintain connectivity         │
└────────────────────────────────────────────────────┘
```

---

## High Availability Architecture

### Single Zone Deployment (NOT RECOMMENDED)

```
┌─────────────────────────────────────┐
│  Region: us-central1                │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Zone: us-central1-a          │ │
│  │                               │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │  Application Instances  │ │ │
│  │  │  • VM-1                 │ │ │
│  │  │  • VM-2                 │ │ │
│  │  │  • Database             │ │ │
│  │  └─────────────────────────┘ │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘

❌ Single Point of Failure
❌ No redundancy
❌ Downtime during zone failure
```

### Multi-Zone Deployment (RECOMMENDED)

```
┌──────────────────────────────────────────────────────────────┐
│  Region: us-central1                                         │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────┐│
│  │ Zone A           │  │ Zone B           │  │ Zone C     ││
│  │                  │  │                  │  │            ││
│  │ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌────────┐││
│  │ │ VM-1         │ │  │ │ VM-2         │ │  │ │ VM-3   │││
│  │ │ App Instance │ │  │ │ App Instance │ │  │ │ App    │││
│  │ └──────────────┘ │  │ └──────────────┘ │  │ └────────┘││
│  │                  │  │                  │  │            ││
│  │ ┌──────────────┐ │  │ ┌──────────────┐ │  │            ││
│  │ │ DB Primary   │◄─┼──┼─┤ DB Replica   │ │  │            ││
│  │ └──────────────┘ │  │ └──────────────┘ │  │            ││
│  └──────────────────┘  └──────────────────┘  └────────────┘│
│           ▲                     ▲                    ▲      │
│           └─────────────────────┴────────────────────┘      │
│                    Load Balancer (Regional)                 │
└──────────────────────────────────────────────────────────────┘

✓ High Availability (99.99% SLA)
✓ Automatic failover
✓ Zero downtime during zone failure
✓ Load distribution across zones
```

### Real-World HA Pattern

```
┌─────────────────────────────────────────────────────────────┐
│  Production Architecture: E-commerce Platform               │
└─────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │  Global Load         │
                    │  Balancer            │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼────────┐ ┌────▼──────────┐ ┌──▼──────────┐
    │ Zone A           │ │ Zone B        │ │ Zone C      │
    │                  │ │               │ │             │
    │ ┌──────────────┐ │ │ ┌───────────┐│ │ ┌─────────┐ │
    │ │ GKE Node     │ │ │ │ GKE Node  ││ │ │ GKE Node│ │
    │ │ • Frontend   │ │ │ │ • Frontend││ │ │ •Frontend│ │
    │ │ • Backend    │ │ │ │ • Backend ││ │ │ •Backend│ │
    │ └──────────────┘ │ │ └───────────┘│ │ └─────────┘ │
    │                  │ │               │ │             │
    │ ┌──────────────┐ │ │ ┌───────────┐│ │             │
    │ │ Cloud SQL    │◄┼─┼─┤ Read      ││ │             │
    │ │ Primary      │ │ │ │ Replica   ││ │             │
    │ └──────────────┘ │ │ └───────────┘│ │             │
    │                  │ │               │ │             │
    │ ┌──────────────┐ │ │ ┌───────────┐│ │ ┌─────────┐ │
    │ │ Redis        │ │ │ │ Redis     ││ │ │ Redis   │ │
    │ │ Cache        │ │ │ │ Cache     ││ │ │ Cache   │ │
    │ └──────────────┘ │ │ └───────────┘│ │ └─────────┘ │
    └──────────────────┘ └───────────────┘ └─────────────┘

Benefits:
  • 99.99% uptime SLA
  • Automatic failover in seconds
  • Load balanced across zones
  • Database replication for reads
  • Distributed caching
```

---

# 🌐 Global Infrastructure

Google Cloud operates one of the **largest and most advanced private networks** in the world.

## Network Architecture

```
┌────────────────────────────────────────────────────────────────┐
│  Google's Global Network Infrastructure                        │
└────────────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────────────┐
    │  Edge Network (200+ Points of Presence)              │
    │  • CDN Edge Locations                                │
    │  • Cloud Armor (DDoS Protection)                     │
    │  • Global Load Balancing Entry Points                │
    └────────────────┬─────────────────────────────────────┘
                     │
    ┌────────────────▼─────────────────────────────────────┐
    │  Premium Tier Network (Google's Private Backbone)    │
    │  • 100+ Tbps capacity                                │
    │  • Subsea cables owned by Google                     │
    │  • Low latency, high reliability                     │
    │  • Traffic stays on Google network                   │
    └────────────────┬─────────────────────────────────────┘
                     │
    ┌────────────────▼─────────────────────────────────────┐
    │  Regional Networks (40+ Regions)                     │
    │  • VPC Networks                                      │
    │  • Regional Load Balancers                           │
    │  • Private Service Connect                           │
    └────────────────┬─────────────────────────────────────┘
                     │
    ┌────────────────▼─────────────────────────────────────┐
    │  Zonal Resources (120+ Zones)                        │
    │  • Compute Instances                                 │
    │  • Persistent Disks                                  │
    │  • GKE Clusters                                      │
    └──────────────────────────────────────────────────────┘
```

## Network Tiers

### Premium Tier (Default)

```
User Request Flow (Premium Tier):

┌──────────┐
│  User    │  (Mumbai, India)
│  Browser │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│  Nearest Edge   │  ← Enters Google network immediately
│  Location       │     (Mumbai PoP)
└────┬────────────┘
     │
     ▼  Google Private Network (Low latency, high reliability)
┌─────────────────┐
│  Google         │
│  Backbone       │  ← Traffic stays on Google's network
│  Network        │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Destination    │  (us-central1)
│  Region         │
└─────────────────┘

Benefits:
  ✓ Lowest latency
  ✓ Highest reliability
  ✓ Global load balancing
  ✓ Better performance
  ✓ SLA guarantees
```

### Standard Tier

```
User Request Flow (Standard Tier):

┌──────────┐
│  User    │  (Mumbai, India)
│  Browser │
└────┬─────┘
     │
     ▼  Public Internet
┌─────────────────┐
│  ISP Network    │  ← Uses public internet
│  (Multiple hops)│
└────┬────────────┘
     │
     ▼  Public Internet
┌─────────────────┐
│  Regional       │  ← Enters Google network at region
│  Entry Point    │     (us-central1)
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Destination    │
│  Region         │
└─────────────────┘

Trade-offs:
  ✓ Lower cost
  ✗ Higher latency
  ✗ Less reliable
  ✗ Regional load balancing only
```

## Global Load Balancing

```
┌────────────────────────────────────────────────────────────┐
│  Global HTTP(S) Load Balancer Architecture                 │
└────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │  Anycast IP      │
                    │  (Single Global  │
                    │   IP Address)    │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼─────┐        ┌────▼─────┐        ┌────▼─────┐
   │ us-east1 │        │ eu-west1 │        │ asia-se1 │
   │          │        │          │        │          │
   │ Backend  │        │ Backend  │        │ Backend  │
   │ Services │        │ Services │        │ Services │
   └──────────┘        └──────────┘        └──────────┘

Features:
  • Automatic routing to nearest healthy backend
  • Cross-region failover
  • SSL termination at edge
  • Cloud CDN integration
  • DDoS protection with Cloud Armor
```

---

## Latency Optimization

### Edge Caching with Cloud CDN

```
Without CDN:
┌──────┐                                    ┌──────────┐
│ User │──────── 200ms latency ────────────▶│ Origin   │
│      │◀─────── Full content ──────────────│ Server   │
└──────┘                                    └──────────┘

With CDN:
┌──────┐         ┌─────────┐               ┌──────────┐
│ User │─ 5ms ──▶│ CDN     │─── Cache ────▶│ Origin   │
│      │◀────────│ Edge    │    Miss       │ Server   │
└──────┘         └─────────┘               └──────────┘
                      │
                      └─ Cache Hit (5ms response)

Performance Improvement:
  • 95% faster response time
  • Reduced origin load
  • Lower bandwidth costs
  • Better user experience
```

---

## Best Practices

### 1. Multi-Zone Deployment

```bash
# Deploy across multiple zones for HA
gcloud compute instance-groups managed create web-group \
  --base-instance-name web \
  --template web-template \
  --size 3 \
  --zones us-central1-a,us-central1-b,us-central1-c
```

### 2. Regional Resources

```bash
# Use regional resources for automatic zone distribution
gcloud compute addresses create web-ip \
  --region us-central1 \
  --network-tier PREMIUM
```

### 3. Health Checks

```bash
# Configure health checks for automatic failover
gcloud compute health-checks create http web-health-check \
  --port 80 \
  --check-interval 10s \
  --timeout 5s \
  --unhealthy-threshold 3 \
  --healthy-threshold 2
```

---

## Cost Optimization

### Region Pricing Comparison

| Region | Compute (n1-standard-1/month) | Storage (GB/month) |
|--------|-------------------------------|-------------------|
| us-central1 (Iowa) | $24.27 | $0.020 |
| us-east1 (S. Carolina) | $24.27 | $0.020 |
| europe-west2 (London) | $28.18 | $0.023 |
| asia-southeast1 (Singapore) | $28.67 | $0.023 |

**Tip**: Use Iowa (us-central1) for cost-effective deployments when latency permits.

---
