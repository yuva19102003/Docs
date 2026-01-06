# 🔷 Azure Cloud Documentation

**Complete Azure Solution Architect Learning Path - From Fundamentals to Advanced**

---

## 📚 Table of Contents

1. [Getting Started](#getting-started)
2. [Core Services](#core-services)
3. [Learning Path](#learning-path)
4. [Service Categories](#service-categories)
5. [Hands-On Tasks](#hands-on-tasks)
6. [Quick Reference](#quick-reference)

---

## 🚀 Getting Started

### What is Azure?
Microsoft Azure is a comprehensive cloud computing platform offering 200+ services including compute, storage, databases, networking, AI/ML, and more. It's one of the top 3 cloud providers alongside AWS and Google Cloud.

### Documentation Structure
```
CLOUD/AZURE/
├── README.md                           # This file - main navigation
├── 0-AZURE-CLOUD-TOPICS.md            # Service categories overview
├── 0-AZURE-SERVICE-cleaned.md         # Complete service comparison with AWS
├── AZURE-DOTNET-ROADMAP.md            # .NET development on Azure
├── Azure-Learning-Architecture-Task-Based.md  # Task-based learning
│
├── SERVICES/                           # Detailed service documentation
│   ├── RESOURCE-GROUPS/               # Resource management
│   ├── AZURE-STATIC-WEB-APP/          # Static web hosting
│   ├── AZURE-WEB-APP-SERVICE/         # App Service (PaaS)
│   ├── AZURE VM/                      # Virtual Machines
│   ├── MICROSOFT-INTRA-ID/            # Identity & Access Management
│   ├── Networking Services/           # VNet, NSG, Load Balancers, etc.
│   └── Hybrid & Multicloud/           # Azure Arc, Hybrid solutions
│
└── Docs/                              # Topic-based documentation
    ├── 1-Resource-groups/             # Resource organization
    ├── 2-IAM-Security/                # Identity & Security
    ├── 3-CLI/                         # Azure CLI
    ├── 4-PaaS/                        # Platform as a Service
    ├── 5-DB/                          # Databases
    ├── 6-Storage/                     # Storage solutions
    ├── 7-Networking/                  # Networking deep dive
    └── 8-Virtual-Machines/            # VM management
```

---

## 🎯 Core Services

### Compute Services
| Service | Purpose | AWS Equivalent | Documentation |
|---------|---------|----------------|---------------|
| **Virtual Machines** | IaaS compute | EC2 | [SERVICES/AZURE VM/](SERVICES/AZURE%20VM/) |
| **App Service** | PaaS web hosting | Elastic Beanstalk | [SERVICES/AZURE-WEB-APP-SERVICE/](SERVICES/AZURE-WEB-APP-SERVICE/) |
| **Static Web Apps** | Static site hosting | Amplify/S3+CloudFront | [SERVICES/AZURE-STATIC-WEB-APP/](SERVICES/AZURE-STATIC-WEB-APP/) |
| **AKS** | Managed Kubernetes | EKS | [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) |
| **Functions** | Serverless compute | Lambda | [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) |
| **Container Instances** | Serverless containers | Fargate | [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) |

### Storage & Databases
| Service | Purpose | AWS Equivalent | Documentation |
|---------|---------|----------------|---------------|
| **Blob Storage** | Object storage | S3 | [Docs/6-Storage/](Docs/6-Storage/) |
| **Azure Files** | File shares | EFS | [Docs/6-Storage/](Docs/6-Storage/) |
| **Disk Storage** | Block storage | EBS | [Docs/6-Storage/](Docs/6-Storage/) |
| **SQL Database** | Managed SQL | RDS | [Docs/5-DB/](Docs/5-DB/) |
| **Cosmos DB** | NoSQL database | DynamoDB | [Docs/5-DB/](Docs/5-DB/) |
| **PostgreSQL** | Managed PostgreSQL | RDS PostgreSQL | [Docs/5-DB/](Docs/5-DB/) |

### Networking
| Service | Purpose | AWS Equivalent | Documentation |
|---------|---------|----------------|---------------|
| **Virtual Network (VNet)** | Isolated network | VPC | [SERVICES/Networking Services/Azure-VNet.md](SERVICES/Networking%20Services/Azure-VNet.md) |
| **NSG** | Network security | Security Groups | [SERVICES/Networking Services/NSG.md](SERVICES/Networking%20Services/NSG.md) |
| **ASG** | Application security | Security Groups | [SERVICES/Networking Services/ASG.md](SERVICES/Networking%20Services/ASG.md) |
| **Load Balancer** | L4 load balancing | NLB | [SERVICES/Networking Services/Azure-Load-Balancer.md](SERVICES/Networking%20Services/Azure-Load-Balancer.md) |
| **Application Gateway** | L7 load balancing + WAF | ALB + WAF | [SERVICES/Networking Services/Azure-Application-Gateway-WAF.md](SERVICES/Networking%20Services/Azure-Application-Gateway-WAF.md) |
| **Azure Firewall** | Managed firewall | Network Firewall | [SERVICES/Networking Services/Azure-Firewall.md](SERVICES/Networking%20Services/Azure-Firewall.md) |
| **VPN Gateway** | Site-to-Site VPN | VPN Gateway | [SERVICES/Networking Services/Azure-VPN-Gateway.md](SERVICES/Networking%20Services/Azure-VPN-Gateway.md) |
| **Azure DNS** | DNS management | Route 53 | [SERVICES/Networking Services/Azure-DNS.md](SERVICES/Networking%20Services/Azure-DNS.md) |
| **VNet Peering** | VNet connectivity | VPC Peering | [SERVICES/Networking Services/VNet-Peering.md](SERVICES/Networking%20Services/VNet-Peering.md) |

### Identity & Security
| Service | Purpose | AWS Equivalent | Documentation |
|---------|---------|----------------|---------------|
| **Microsoft Entra ID** | Identity management | IAM | [SERVICES/MICROSOFT-INTRA-ID/](SERVICES/MICROSOFT-INTRA-ID/) |
| **Key Vault** | Secrets management | Secrets Manager + KMS | [Docs/2-IAM-Security/](Docs/2-IAM-Security/) |
| **RBAC** | Role-based access | IAM Roles | [Docs/2-IAM-Security/](Docs/2-IAM-Security/) |
| **Managed Identity** | Service authentication | IAM Roles | [Docs/2-IAM-Security/](Docs/2-IAM-Security/) |

### Management & Governance
| Service | Purpose | AWS Equivalent | Documentation |
|---------|---------|----------------|---------------|
| **Resource Groups** | Resource organization | Resource Groups | [SERVICES/RESOURCE-GROUPS/](SERVICES/RESOURCE-GROUPS/) |
| **Azure CLI** | Command-line tool | AWS CLI | [Docs/3-CLI/](Docs/3-CLI/) |
| **Azure Monitor** | Monitoring & logging | CloudWatch | [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) |
| **Azure Policy** | Governance | Config Rules | [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) |

---

## 📖 Learning Path

### Beginner (0-3 months)
**Goal:** Understand Azure fundamentals and core services

1. **Start Here:**
   - Read [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md) - Service overview
   - Read [0-AZURE-SERVICE-cleaned.md](0-AZURE-SERVICE-cleaned.md) - AWS comparison

2. **Core Concepts:**
   - [Resource Groups](SERVICES/RESOURCE-GROUPS/) - Resource organization
   - [Azure CLI](Docs/3-CLI/) - Command-line basics
   - [IAM & Security](Docs/2-IAM-Security/) - Identity management

3. **First Services:**
   - [Static Web Apps](SERVICES/AZURE-STATIC-WEB-APP/) - Deploy a static site
   - [Storage](Docs/6-Storage/) - Blob storage basics
   - [Virtual Network](SERVICES/Networking%20Services/Azure-VNet.md) - Networking fundamentals

4. **Hands-On Tasks:**
   - ✅ Create Resource Group
   - ✅ Deploy Static Web App
   - ✅ Create Storage Account
   - ✅ Set up Virtual Network

### Intermediate (3-6 months)
**Goal:** Deploy and manage applications

1. **Application Platform:**
   - [App Service](SERVICES/AZURE-WEB-APP-SERVICE/) - PaaS hosting
   - [Virtual Machines](SERVICES/AZURE%20VM/) - IaaS compute
   - [Databases](Docs/5-DB/) - SQL & NoSQL

2. **Networking:**
   - [NSG & ASG](SERVICES/Networking%20Services/) - Network security
   - [Load Balancer](SERVICES/Networking%20Services/Azure-Load-Balancer.md) - Traffic distribution
   - [VPN Gateway](SERVICES/Networking%20Services/Azure-VPN-Gateway.md) - Hybrid connectivity

3. **Security:**
   - [Microsoft Entra ID](SERVICES/MICROSOFT-INTRA-ID/) - Advanced IAM
   - Key Vault - Secrets management
   - Managed Identity - Service authentication

4. **Hands-On Tasks:**
   - ✅ Deploy App Service with CI/CD
   - ✅ Configure PostgreSQL database
   - ✅ Set up VNet with subnets
   - ✅ Implement NSG rules
   - ✅ Configure Key Vault

### Advanced (6-12 months)
**Goal:** Architect enterprise solutions

1. **Advanced Networking:**
   - Hub-Spoke topology
   - Azure Firewall
   - Application Gateway + WAF
   - VNet Peering

2. **High Availability:**
   - Multi-region deployment
   - Traffic Manager
   - Site Recovery
   - Backup strategies

3. **Containers & Kubernetes:**
   - AKS (Azure Kubernetes Service)
   - Container Registry
   - Service Mesh

4. **Hybrid & Multicloud:**
   - [Azure Arc](SERVICES/Hybrid%20&%20Multicloud/)
   - Site-to-Site VPN
   - ExpressRoute

5. **Infrastructure as Code:**
   - Bicep templates
   - Terraform on Azure
   - CI/CD pipelines

6. **Hands-On Tasks:**
   - ✅ Design multi-region architecture
   - ✅ Implement Hub-Spoke network
   - ✅ Deploy AKS cluster
   - ✅ Configure Azure Arc
   - ✅ Build IaC with Bicep/Terraform

---

## 🗂️ Service Categories

### 1. Compute
- Virtual Machines (IaaS)
- App Service (PaaS)
- Static Web Apps
- Azure Functions (Serverless)
- AKS (Kubernetes)
- Container Instances

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-1-compute-services)

### 2. Storage & Databases
- Blob Storage (Object)
- Azure Files (File shares)
- Disk Storage (Block)
- SQL Database
- Cosmos DB (NoSQL)
- PostgreSQL/MySQL

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-2-storage--database-services)

### 3. Networking
- Virtual Network (VNet)
- NSG & ASG
- Load Balancer
- Application Gateway + WAF
- Azure Firewall
- VPN Gateway
- Azure DNS

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-3-networking-services)

### 4. Identity & Security
- Microsoft Entra ID
- Key Vault
- RBAC
- Managed Identity
- Azure Policy

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-6-security--identity-devsecops-focus)

### 5. Monitoring & Logging
- Azure Monitor
- Log Analytics
- Application Insights
- Azure Alerts

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-5-monitoring--logging)

### 6. CI/CD & DevOps
- Azure DevOps
- GitHub Actions
- Container Registry
- Bicep/ARM Templates

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-4-cicd--code-management)

### 7. Hybrid & Multicloud
- Azure Arc
- Azure Lighthouse
- Site-to-Site VPN
- ExpressRoute

**Documentation:** [0-AZURE-CLOUD-TOPICS.md](0-AZURE-CLOUD-TOPICS.md#-9-hybrid--multicloud)

---

## ✅ Hands-On Tasks

### Task Checklist
Complete hands-on tasks to build practical Azure skills. Track your progress:

#### 1. Application Platform
- [x] Create Resource Group
- [x] Deploy Static Web App
- [x] Configure App Service
- [x] Set up CI/CD with GitHub Actions
- [x] Configure custom domain
- [x] Enable authentication

#### 2. Database & Storage
- [x] Create PostgreSQL Flexible Server
- [x] Configure private endpoint
- [x] Create Cosmos DB
- [x] Set up Blob Storage
- [x] Configure lifecycle policies

#### 3. Networking
- [x] Create Hub VNet
- [x] Create Spoke VNets
- [x] Configure VNet peering
- [x] Set up NSGs
- [x] Create Azure Firewall
- [ ] Configure Application Gateway

#### 4. Security
- [x] Configure Entra ID
- [x] Create Key Vault
- [x] Enable Managed Identity
- [x] Configure RBAC
- [x] Set up Conditional Access

#### 5. Compute
- [ ] Create Linux VM
- [ ] Configure VM Scale Set
- [ ] Set up autoscaling
- [ ] Deploy AKS cluster

#### 6. Monitoring
- [ ] Set up Log Analytics
- [ ] Create dashboards
- [ ] Configure alerts
- [ ] Enable Application Insights

#### 7. Infrastructure as Code
- [ ] Write Bicep templates
- [ ] Deploy with Terraform
- [ ] Set up CI/CD pipeline
- [ ] Implement GitOps

**Full Task List:** [Azure-Learning-Architecture-Task-Based.md](Azure-Learning-Architecture-Task-Based.md)

---

## 🔍 Quick Reference

### Common Azure CLI Commands
```bash
# Login
az login

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "subscription-name"

# Create resource group
az group create --name myResourceGroup --location eastus

# List resources
az resource list --resource-group myResourceGroup

# Delete resource group
az group delete --name myResourceGroup
```

### Resource Naming Convention
```
<resource-type>-<app-name>-<environment>-<region>-<instance>

Examples:
- rg-webapp-prod-eastus-01      (Resource Group)
- vm-webserver-dev-westus-01    (Virtual Machine)
- st-data-prod-eastus-01        (Storage Account)
- vnet-hub-prod-eastus-01       (Virtual Network)
```

### Azure Regions
**US Regions:**
- East US, East US 2
- West US, West US 2, West US 3
- Central US, North Central US, South Central US

**Europe:**
- North Europe (Ireland)
- West Europe (Netherlands)
- UK South, UK West

**Asia Pacific:**
- Southeast Asia (Singapore)
- East Asia (Hong Kong)
- Japan East, Japan West

---

## 📊 Azure vs AWS Service Comparison

For detailed service-by-service comparison with AWS, see:
- **[0-AZURE-SERVICE-cleaned.md](0-AZURE-SERVICE-cleaned.md)** - Complete comparison table

### Quick Comparison

| Category | Azure | AWS |
|----------|-------|-----|
| **Compute** | Virtual Machines, App Service, AKS | EC2, Elastic Beanstalk, EKS |
| **Storage** | Blob Storage, Files, Disks | S3, EFS, EBS |
| **Database** | SQL Database, Cosmos DB | RDS, DynamoDB |
| **Networking** | VNet, NSG, Load Balancer | VPC, Security Groups, ELB |
| **Identity** | Entra ID, RBAC | IAM |
| **Serverless** | Functions, Logic Apps | Lambda, Step Functions |
| **Containers** | AKS, Container Instances | EKS, Fargate |
| **Monitoring** | Azure Monitor | CloudWatch |

---

## 🎓 Certification Path

### Fundamentals
- **AZ-900** - Azure Fundamentals

### Associate Level
- **AZ-104** - Azure Administrator
- **AZ-204** - Azure Developer
- **AZ-400** - DevOps Engineer

### Expert Level
- **AZ-305** - Azure Solutions Architect Expert

---

## 📚 Additional Resources

### Official Documentation
- [Azure Documentation](https://docs.microsoft.com/azure)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure)

### Learning Resources
- [Microsoft Learn](https://learn.microsoft.com/azure)
- [Azure Quickstart Templates](https://azure.microsoft.com/resources/templates)
- [Azure Architecture Patterns](https://docs.microsoft.com/azure/architecture/patterns)

### Tools
- [Azure Portal](https://portal.azure.com)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Azure PowerShell](https://docs.microsoft.com/powershell/azure)
- [Visual Studio Code Azure Extensions](https://marketplace.visualstudio.com/search?term=azure&target=VSCode)

---

## 🔗 Related Documentation

- **[AWS Documentation](../AWS/)** - Compare with AWS services
- **[DevOps Core](../../DEVOPS-CORE/)** - DevOps practices and tools
- **[System Design](../../DEVOPS-CORE/SYSTEM-DESIGN/)** - Architecture patterns

---

## 📈 Documentation Statistics

- **Total Service Categories:** 10+
- **Core Services Documented:** 50+
- **Hands-On Tasks:** 60+
- **Networking Services:** 9 detailed guides
- **Coverage:** Fundamentals to Solution Architect level

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete Azure learning path  
**Level:** Beginner to Solution Architect  
**Focus:** Hands-on, task-based learning

**Ready to start your Azure journey!** ☁️
