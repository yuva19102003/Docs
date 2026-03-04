# 1️⃣ GCP Fundamentals

Complete guide to Google Cloud Platform fundamentals covering core concepts, architecture, and management tools.

---

## 📚 Table of Contents

### [1. Regions & Zones](./1-regions-zones.md)
**Global Infrastructure & High Availability**

```
Topics Covered:
  • GCP global infrastructure overview
  • Regions and zones explained
  • High availability architecture patterns
  • Multi-zone deployment strategies
  • Network tiers (Premium vs Standard)
  • Global load balancing
  • Latency optimization with Cloud CDN
  • Cost optimization by region
```

**Key Concepts:**
- 40+ regions with 120+ zones globally
- Multi-zone deployment for 99.99% SLA
- Google's private fiber network
- Edge locations and PoPs

---

### [2. Resource Hierarchy](./2-Resource-hierarchy.md)
**Organization Structure & Management**

```
Topics Covered:
  • Resource hierarchy model
  • Organization node setup
  • Folder structure patterns
  • Project management
  • Resource organization
  • Policy inheritance
  • IAM structure
  • Best practices for hierarchy design
```

**Key Concepts:**
- Organization → Folders → Projects → Resources
- Policy inheritance flows downward
- Projects as billing and isolation boundaries
- Folder patterns for environments and teams

---

### [3. Shared Responsibility Model](./3-Shared-responsibility-model.md)
**Security & Compliance**

```
Topics Covered:
  • Shared responsibility overview
  • Google's security responsibilities
  • Customer security responsibilities
  • Responsibility by service model (IaaS/PaaS/SaaS)
  • Encryption options
  • Compliance certifications
  • Security best practices
  • Defense in depth strategy
```

**Key Concepts:**
- Google secures infrastructure (OF the cloud)
- Customers secure workloads (IN the cloud)
- Varies by service model
- Multiple layers of security controls

---

### [4. Google Cloud Console](./4-google-console.md)
**Web-Based Management Interface**

```
Topics Covered:
  • Console interface overview
  • Navigation and layout
  • Common tasks and workflows
  • Cloud Shell integration
  • Monitoring and logging
  • Billing and cost management
  • Mobile app features
  • Keyboard shortcuts
```

**Key Concepts:**
- Visual resource management
- Real-time monitoring dashboards
- Cloud Shell (CLI in browser)
- Activity tracking and recommendations

---

### [5. Google Cloud SDK](./5-google-cloud-sdk.md)
**Command-Line Tools & Automation**

```
Topics Covered:
  • SDK installation and setup
  • gcloud CLI commands
  • gsutil for Cloud Storage
  • bq for BigQuery
  • Configuration profiles
  • Authentication methods
  • Scripting and automation
  • CI/CD integration
```

**Key Concepts:**
- gcloud for resource management
- Configuration profiles for multiple environments
- Service accounts for automation
- Output formatting and filtering

---

## 🎯 Learning Path

### Beginner Level
1. Start with **Regions & Zones** to understand GCP's global infrastructure
2. Learn **Resource Hierarchy** to organize your resources effectively
3. Understand **Shared Responsibility Model** for security basics

### Intermediate Level
4. Master **Google Cloud Console** for visual management
5. Learn **Google Cloud SDK** for automation and scripting

### Advanced Level
6. Implement multi-region architectures
7. Automate infrastructure with Terraform
8. Integrate with CI/CD pipelines

---

## 🏗️ Architecture Patterns

### Pattern 1: Single Region, Multi-Zone (High Availability)

```
┌────────────────────────────────────────────────────────┐
│  Region: us-central1                                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │ Zone A       │  │ Zone B       │  │ Zone C       ││
│  │              │  │              │  │              ││
│  │ • GKE Nodes  │  │ • GKE Nodes  │  │ • GKE Nodes  ││
│  │ • DB Primary │  │ • DB Replica │  │              ││
│  │ • Cache      │  │ • Cache      │  │ • Cache      ││
│  └──────────────┘  └──────────────┘  └──────────────┘│
│           ▲               ▲               ▲           │
│           └───────────────┴───────────────┘           │
│              Regional Load Balancer                    │
└────────────────────────────────────────────────────────┘

Use Case: Production applications requiring HA
SLA: 99.99% uptime
Cost: Moderate (single region pricing)
```

### Pattern 2: Multi-Region (Global Distribution)

```
┌────────────────────────────────────────────────────────┐
│  Global Architecture                                   │
└────────────────────────────────────────────────────────┘

                  Global Load Balancer
                  (Anycast IP: 1.2.3.4)
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼─────┐      ┌────▼─────┐      ┌────▼─────┐
   │ us-east1 │      │ eu-west1 │      │ asia-se1 │
   │          │      │          │      │          │
   │ • GKE    │      │ • GKE    │      │ • GKE    │
   │ • SQL    │◄────►│ • SQL    │◄────►│ • SQL    │
   │ • Cache  │      │ • Cache  │      │ • Cache  │
   └──────────┘      └──────────┘      └──────────┘
        │                  │                  │
        └──────────────────┴──────────────────┘
              Cloud Spanner (Global DB)

Use Case: Global applications with users worldwide
SLA: 99.99% uptime with automatic failover
Cost: Higher (multi-region pricing + data transfer)
```

### Pattern 3: Hybrid Cloud (On-Premises + GCP)

```
┌────────────────────────────────────────────────────────┐
│  Hybrid Architecture                                   │
└────────────────────────────────────────────────────────┘

On-Premises Data Center          Google Cloud Platform
┌─────────────────────┐          ┌─────────────────────┐
│                     │          │                     │
│  • Legacy Apps      │          │  • Modern Apps      │
│  • Databases        │◄────────►│  • Microservices    │
│  • File Servers     │  VPN/    │  • Managed Services │
│                     │  Inter-  │                     │
│                     │  connect │                     │
└─────────────────────┘          └─────────────────────┘

Use Case: Gradual cloud migration, compliance requirements
Connectivity: Cloud VPN or Cloud Interconnect
Security: Private connectivity, no public internet
```

---

## 🔐 Security Best Practices

### 1. Identity & Access Management

```
✓ Enable MFA for all user accounts
✓ Use service accounts for applications
✓ Implement least privilege principle
✓ Regular IAM audit and review
✓ Use groups instead of individual users
✓ Rotate service account keys regularly
```

### 2. Network Security

```
✓ Use VPC for network isolation
✓ Implement firewall rules (deny by default)
✓ Enable VPC Flow Logs
✓ Use Private Google Access
✓ Implement Cloud Armor for DDoS protection
✓ Use Cloud NAT for outbound traffic
```

### 3. Data Protection

```
✓ Enable encryption at rest (default)
✓ Use customer-managed keys (CMEK) for sensitive data
✓ Implement data classification
✓ Enable audit logging
✓ Regular backups and disaster recovery testing
✓ Use Secret Manager for credentials
```

### 4. Monitoring & Compliance

```
✓ Enable Cloud Audit Logs (Admin, Data, System)
✓ Set up alerting policies
✓ Implement Security Command Center
✓ Regular security assessments
✓ Compliance documentation
✓ Incident response procedures
```

---

## 💰 Cost Optimization

### 1. Compute Optimization

```
Strategy                          Savings
─────────────────────────────────────────────────────
Committed Use Discounts           Up to 57%
Sustained Use Discounts           Up to 30% (automatic)
Preemptible/Spot VMs             Up to 91%
Right-sizing VMs                  20-50%
Custom machine types              Varies
```

### 2. Storage Optimization

```
Strategy                          Savings
─────────────────────────────────────────────────────
Lifecycle policies                Up to 90%
Nearline/Coldline storage        50-80%
Regional vs Multi-regional        15-20%
Committed use (BigQuery)          Varies
```

### 3. Network Optimization

```
Strategy                          Savings
─────────────────────────────────────────────────────
Standard tier networking          50%
Cloud CDN                         Bandwidth costs
Regional resources                Data transfer costs
Private Google Access             Egress costs
```

### 4. Best Practices

```bash
# Set up billing alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget" \
  --budget-amount=1000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90

# Use labels for cost tracking
gcloud compute instances create vm-1 \
  --labels=environment=prod,team=backend,cost-center=engineering

# Export billing data to BigQuery for analysis
gcloud billing accounts list
# Enable billing export in Console
```

---

## 🚀 Quick Start Guide

### Step 1: Set Up Account

```bash
# 1. Create Google Cloud account
# Visit: https://cloud.google.com

# 2. Install Cloud SDK
curl https://sdk.cloud.google.com | bash

# 3. Initialize SDK
gcloud init

# 4. Authenticate
gcloud auth login
```

### Step 2: Create First Project

```bash
# Create project
gcloud projects create my-first-project-2026 \
  --name="My First Project"

# Set as active project
gcloud config set project my-first-project-2026

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
```

### Step 3: Deploy First Resource

```bash
# Create a simple VM
gcloud compute instances create my-first-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud

# SSH into VM
gcloud compute ssh my-first-vm --zone=us-central1-a

# Clean up
gcloud compute instances delete my-first-vm --zone=us-central1-a
```

---

## 📊 Comparison with Other Cloud Providers

### Feature Comparison

| Feature | GCP | AWS | Azure |
|---------|-----|-----|-------|
| **Regions** | 40+ | 30+ | 60+ |
| **Network** | Private fiber | Public internet (mostly) | Public internet (mostly) |
| **Billing** | Per-second | Per-second | Per-minute |
| **Discounts** | Automatic sustained use | Reserved instances | Reserved instances |
| **Kubernetes** | GKE (native) | EKS | AKS |
| **Serverless** | Cloud Run, Functions | Lambda, Fargate | Functions, Container Apps |
| **Global DB** | Cloud Spanner | Aurora Global | Cosmos DB |

### When to Choose GCP

```
✓ Kubernetes-native workloads (GKE is best-in-class)
✓ Data analytics and ML (BigQuery, Vertex AI)
✓ Global applications (Cloud Spanner)
✓ Cost optimization (automatic discounts)
✓ Network performance (private fiber network)
✓ Container-first architecture
```

---

## 🔗 Additional Resources

### Official Documentation
- [GCP Documentation](https://cloud.google.com/docs)
- [Architecture Center](https://cloud.google.com/architecture)
- [Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)

### Training & Certification
- [Google Cloud Skills Boost](https://www.cloudskillsboost.google/)
- [Associate Cloud Engineer](https://cloud.google.com/certification/cloud-engineer)
- [Professional Cloud Architect](https://cloud.google.com/certification/cloud-architect)

### Community
- [Google Cloud Community](https://www.googlecloudcommunity.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/google-cloud-platform)
- [Reddit r/googlecloud](https://www.reddit.com/r/googlecloud/)

---

## ✅ Checklist: Fundamentals Mastery

### Core Concepts
- [ ] Understand regions, zones, and global infrastructure
- [ ] Know how to design multi-zone architectures
- [ ] Understand resource hierarchy and organization
- [ ] Master IAM and security best practices
- [ ] Know shared responsibility model

### Practical Skills
- [ ] Navigate Google Cloud Console effectively
- [ ] Use gcloud CLI for common tasks
- [ ] Create and manage projects
- [ ] Configure IAM permissions
- [ ] Set up billing and budgets

### Architecture
- [ ] Design high availability architectures
- [ ] Implement multi-region deployments
- [ ] Optimize costs effectively
- [ ] Implement security best practices
- [ ] Set up monitoring and logging

---

## 🎓 Next Steps

After mastering GCP Fundamentals, proceed to:

1. **Compute Services**
   - Compute Engine (VMs)
   - Google Kubernetes Engine (GKE)
   - Cloud Run (Serverless containers)
   - App Engine (PaaS)

2. **Storage & Databases**
   - Cloud Storage
   - Cloud SQL
   - Cloud Spanner
   - Firestore

3. **Networking**
   - VPC and subnets
   - Load balancing
   - Cloud CDN
   - Cloud Armor

4. **DevOps & CI/CD**
   - Cloud Build
   - Artifact Registry
   - Cloud Deploy
   - Infrastructure as Code (Terraform)

---

**Last Updated:** March 2026
**Version:** 2.0
