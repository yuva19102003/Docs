# 🏢 Resource Hierarchy

Google Cloud uses a **hierarchical structure** to organize and manage resources, providing centralized control over access, billing, and policies.

## Hierarchy Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Hierarchy                        │
└─────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │  Organization    │  ← Root node (company.com)
                    │  (Root Node)     │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
        │  Folder   │  │ Folder  │  │  Folder   │  ← Departments/Teams
        │  (Prod)   │  │  (Dev)  │  │  (Shared) │
        └─────┬─────┘  └────┬────┘  └─────┬─────┘
              │             │              │
        ┌─────▼─────┐  ┌───▼────┐   ┌────▼─────┐
        │  Project  │  │Project │   │ Project  │  ← Billing & isolation
        │  (App-1)  │  │(App-2) │   │(Network) │
        └─────┬─────┘  └───┬────┘   └────┬─────┘
              │            │              │
        ┌─────▼─────┐  ┌──▼─────┐   ┌───▼──────┐
        │ Resources │  │Resources│  │Resources │  ← VMs, DBs, etc.
        │ • VM      │  │• Cloud  │  │• VPC     │
        │ • DB      │  │  Run    │  │• Firewall│
        │ • Bucket  │  │• Storage│  │• Routes  │
        └───────────┘  └─────────┘  └──────────┘
```

---

## 1. Organization Node

The **Organization** is the **root node** representing your company or domain.

### Key Characteristics

```
┌────────────────────────────────────────────────────────┐
│  Organization: company.com                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose:                                              │
│    • Top-level container for all GCP resources        │
│    • Centralized policy management                     │
│    • Organization-wide IAM roles                       │
│    • Consolidated billing                              │
│                                                         │
│  Created when:                                         │
│    • Google Workspace account exists                   │
│    • Cloud Identity account is set up                  │
│                                                         │
│  Organization Admin:                                   │
│    • Full control over all resources                   │
│    • Can grant/revoke access                           │
│    • Manages organization policies                     │
└────────────────────────────────────────────────────────┘
```

### Organization Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| `Organization Admin` | Full control over organization | IT administrators |
| `Organization Viewer` | Read-only access to organization | Auditors, compliance |
| `Folder Admin` | Manage folders and projects | Department leads |
| `Project Creator` | Create new projects | Development teams |

### Setup Organization

```bash
# Check if organization exists
gcloud organizations list

# Get organization ID
gcloud organizations describe ORGANIZATION_ID

# Grant organization admin role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='user:admin@company.com' \
  --role='roles/resourcemanager.organizationAdmin'
```

---

## 2. Folders

**Folders** provide a grouping mechanism for projects, enabling hierarchical organization and policy inheritance.

### Folder Structure Patterns

#### Pattern 1: Environment-Based

```
Organization (company.com)
   │
   ├── Production Folder
   │   ├── ecommerce-prod
   │   ├── analytics-prod
   │   └── api-gateway-prod
   │
   ├── Staging Folder
   │   ├── ecommerce-staging
   │   └── analytics-staging
   │
   ├── Development Folder
   │   ├── ecommerce-dev
   │   └── analytics-dev
   │
   └── Sandbox Folder
       └── experimental-projects
```

#### Pattern 2: Department-Based

```
Organization (company.com)
   │
   ├── Engineering Folder
   │   ├── Backend Team
   │   │   ├── api-services-prod
   │   │   └── api-services-dev
   │   └── Frontend Team
   │       ├── web-app-prod
   │       └── web-app-dev
   │
   ├── Data Science Folder
   │   ├── ml-models-prod
   │   └── data-pipelines
   │
   ├── Security Folder
   │   ├── security-monitoring
   │   └── compliance-logs
   │
   └── Shared Services Folder
       ├── networking-hub
       └── monitoring-central
```

#### Pattern 3: Business Unit-Based

```
Organization (company.com)
   │
   ├── E-commerce BU
   │   ├── Production
   │   │   ├── web-frontend
   │   │   ├── payment-service
   │   │   └── inventory-service
   │   └── Development
   │       └── dev-projects
   │
   ├── Analytics BU
   │   ├── Data Warehouse
   │   └── BI Tools
   │
   └── Infrastructure BU
       ├── Networking
       └── Security
```

### Folder Benefits

```
┌────────────────────────────────────────────────────────┐
│  Why Use Folders?                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. POLICY INHERITANCE                                 │
│     └─→ Policies applied at folder level cascade      │
│         down to all projects within                    │
│                                                         │
│  2. ACCESS CONTROL                                     │
│     └─→ Grant IAM roles at folder level for           │
│         multiple projects at once                      │
│                                                         │
│  3. ORGANIZATION                                       │
│     └─→ Logical grouping by environment, team,        │
│         or business unit                               │
│                                                         │
│  4. BILLING SEPARATION                                 │
│     └─→ Track costs by folder/department              │
│                                                         │
│  5. COMPLIANCE                                         │
│     └─→ Enforce security policies per environment     │
└────────────────────────────────────────────────────────┘
```

### Folder Management

```bash
# Create folder
gcloud resource-manager folders create \
  --display-name="Production" \
  --organization=ORGANIZATION_ID

# List folders
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID

# Move project to folder
gcloud projects move PROJECT_ID \
  --folder=FOLDER_ID

# Set IAM policy on folder
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='group:engineering@company.com' \
  --role='roles/editor'
```

---

## 3. Projects

**Projects** are the **core organizational unit** in GCP. All resources must belong to a project.

### Project Characteristics

```
┌────────────────────────────────────────────────────────┐
│  Project: ecommerce-prod-2026                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Project ID:      ecommerce-prod-2026                  │
│  Project Number:  123456789012                         │
│  Project Name:    E-commerce Production                │
│                                                         │
│  Purpose:                                              │
│    • Billing boundary (separate billing account)       │
│    • Resource namespace (unique resource names)        │
│    • IAM boundary (access control isolation)           │
│    • API enablement (enable services per project)      │
│    • Quota management (resource limits per project)    │
└────────────────────────────────────────────────────────┘
```

### Project Naming Conventions

```
Pattern: <service>-<environment>-<region>-<purpose>

Examples:
  ✓ ecommerce-prod-us-web
  ✓ analytics-dev-eu-pipeline
  ✓ payment-staging-asia-api
  ✓ shared-prod-global-network
  ✓ ml-training-dev-us-gpu

Best Practices:
  • Use lowercase and hyphens
  • Include environment (prod/staging/dev)
  • Keep it descriptive but concise
  • Project ID is immutable (choose carefully)
```

### Project Structure Example

```
Project: ecommerce-prod-us
├── Compute Resources
│   ├── GKE Cluster (web-cluster)
│   ├── Compute Engine VMs (batch-processors)
│   └── Cloud Run Services (api-gateway)
│
├── Storage Resources
│   ├── Cloud Storage Buckets (product-images)
│   ├── Persistent Disks (database-volumes)
│   └── Filestore (shared-files)
│
├── Database Resources
│   ├── Cloud SQL (postgres-primary)
│   ├── Cloud Spanner (global-inventory)
│   └── Firestore (user-sessions)
│
├── Networking Resources
│   ├── VPC Network (prod-vpc)
│   ├── Subnets (web-subnet, db-subnet)
│   ├── Firewall Rules (allow-http, allow-ssh)
│   └── Load Balancers (global-lb)
│
└── Security & Monitoring
    ├── IAM Policies
    ├── Service Accounts
    ├── Cloud Monitoring
    └── Cloud Logging
```

### Project Management

```bash
# Create project
gcloud projects create ecommerce-prod-2026 \
  --name="E-commerce Production" \
  --folder=FOLDER_ID

# List projects
gcloud projects list

# Set active project
gcloud config set project ecommerce-prod-2026

# Enable APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com

# Get project details
gcloud projects describe ecommerce-prod-2026

# Delete project (soft delete, 30-day recovery)
gcloud projects delete ecommerce-prod-2026
```

---

## 4. Resources

**Resources** are the actual GCP services and components that run within projects.

### Resource Categories

```
┌────────────────────────────────────────────────────────┐
│  Resource Types in GCP                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  COMPUTE                                               │
│    • Compute Engine VMs                                │
│    • GKE Clusters & Nodes                              │
│    • Cloud Run Services                                │
│    • App Engine Applications                           │
│    • Cloud Functions                                   │
│                                                         │
│  STORAGE                                               │
│    • Cloud Storage Buckets                             │
│    • Persistent Disks                                  │
│    • Filestore Instances                               │
│                                                         │
│  DATABASES                                             │
│    • Cloud SQL Instances                               │
│    • Cloud Spanner Databases                           │
│    • Firestore Databases                               │
│    • Bigtable Instances                                │
│                                                         │
│  NETWORKING                                            │
│    • VPC Networks                                      │
│    • Subnets                                           │
│    • Firewall Rules                                    │
│    • Load Balancers                                    │
│    • Cloud NAT                                         │
│                                                         │
│  SECURITY                                              │
│    • Service Accounts                                  │
│    • IAM Policies                                      │
│    • Secrets (Secret Manager)                          │
│    • Encryption Keys (Cloud KMS)                       │
└────────────────────────────────────────────────────────┘
```

### Resource Scope

| Scope | Description | Examples |
|-------|-------------|----------|
| **Global** | Available across all regions | VPC networks, Global load balancers, IAM |
| **Regional** | Specific to a region | Cloud SQL, GKE clusters, Regional disks |
| **Zonal** | Specific to a zone | Compute Engine VMs, Zonal disks, GKE nodes |

---

## Policy Inheritance

Policies and IAM permissions **flow down** the hierarchy.

```
┌────────────────────────────────────────────────────────┐
│  Policy Inheritance Flow                               │
└────────────────────────────────────────────────────────┘

Organization Level
├─ Policy: Require MFA for all users
│  └─→ Applies to ALL folders and projects
│
Folder Level (Production)
├─ Policy: Restrict VM creation to specific machine types
│  └─→ Applies to ALL projects in Production folder
│
Project Level (ecommerce-prod)
├─ Policy: Enable VPC Flow Logs
│  └─→ Applies to ALL resources in this project
│
Resource Level (Compute Engine VM)
└─ Policy: Specific firewall rules
   └─→ Applies to THIS resource only

┌────────────────────────────────────────────────────────┐
│  Inheritance Rules                                     │
├────────────────────────────────────────────────────────┤
│  • Child inherits parent policies                     │
│  • Child can add more restrictive policies            │
│  • Child CANNOT override parent policies              │
│  • Policies are cumulative (union of all levels)      │
└────────────────────────────────────────────────────────┘
```

### IAM Inheritance Example

```
Organization: company.com
├─ IAM: alice@company.com → Organization Viewer
│  └─→ Alice can view ALL resources in organization
│
Folder: Production
├─ IAM: bob@company.com → Folder Editor
│  └─→ Bob can edit ALL projects in Production folder
│
Project: ecommerce-prod
├─ IAM: charlie@company.com → Project Owner
│  └─→ Charlie has full control over ecommerce-prod project
│
Resource: VM Instance
└─ IAM: dave@company.com → Compute Instance Admin
   └─→ Dave can manage THIS specific VM

Effective Permissions:
  • Alice: View all (inherited from org)
  • Bob: Edit all in Production (inherited from folder)
  • Charlie: Full control over ecommerce-prod
  • Dave: Manage specific VM
```

---

## Real-World Architecture Example

### Multi-Environment Setup

```
┌────────────────────────────────────────────────────────────┐
│  Organization: acme-corp.com                               │
└────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼─────┐       ┌────▼─────┐       ┌────▼─────┐
   │Production│       │ Staging  │       │   Dev    │
   │  Folder  │       │  Folder  │       │  Folder  │
   └────┬─────┘       └────┬─────┘       └────┬─────┘
        │                  │                   │
   ┌────▼──────────┐  ┌───▼────────┐    ┌────▼─────────┐
   │ web-prod-us   │  │web-staging │    │ web-dev-us   │
   │               │  │            │    │              │
   │ Resources:    │  │Resources:  │    │ Resources:   │
   │ • GKE (n1-std)│  │• GKE (e2)  │    │ • GKE (e2)   │
   │ • Cloud SQL   │  │• Cloud SQL │    │ • Cloud SQL  │
   │   (HA)        │  │  (single)  │    │   (dev)      │
   │ • 10 VMs      │  │• 3 VMs     │    │ • 1 VM       │
   │               │  │            │    │              │
   │ Policies:     │  │Policies:   │    │ Policies:    │
   │ • MFA required│  │• MFA req.  │    │ • Relaxed    │
   │ • Audit logs  │  │• Audit logs│    │ • No audit   │
   │ • Backup daily│  │• Backup    │    │ • No backup  │
   └───────────────┘  │  weekly    │    └──────────────┘
                      └────────────┘

IAM Structure:
  Production Folder:
    • SRE Team → Editor
    • Security Team → Viewer
    • Developers → No access
  
  Staging Folder:
    • SRE Team → Owner
    • Developers → Editor
  
  Dev Folder:
    • Developers → Owner
    • Everyone → Viewer
```

---

## Best Practices

### 1. Hierarchy Design

```
✓ DO:
  • Use folders for logical grouping
  • Separate environments (prod/staging/dev)
  • Apply policies at highest appropriate level
  • Use consistent naming conventions
  • Plan for growth and scalability

✗ DON'T:
  • Create flat structure (all projects at org level)
  • Mix environments in same folder
  • Grant broad permissions at org level
  • Use generic project names
  • Create too many nested folders (keep it simple)
```

### 2. Project Organization

```bash
# Good project structure
company-prod-us-web
company-prod-us-api
company-prod-us-data
company-staging-us-web
company-dev-us-web

# Bad project structure
project1
project2
test-project
my-project
```

### 3. IAM Management

```bash
# Grant access at folder level for multiple projects
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Use groups instead of individual users
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:sre-team@company.com' \
  --role='roles/owner'
```

### 4. Resource Labeling

```bash
# Apply labels for cost tracking and organization
gcloud compute instances create web-vm \
  --labels=environment=production,team=frontend,cost-center=engineering
```

---

## Migration Strategy

### Moving from Flat to Hierarchical Structure

```
Step 1: Current State (Flat)
Organization
├── project-1
├── project-2
├── project-3
└── project-4

Step 2: Create Folder Structure
Organization
├── Production Folder (created)
├── Staging Folder (created)
└── Development Folder (created)

Step 3: Move Projects
Organization
├── Production Folder
│   ├── project-1 (moved)
│   └── project-2 (moved)
├── Staging Folder
│   └── project-3 (moved)
└── Development Folder
    └── project-4 (moved)

Step 4: Apply Policies
Organization
├── Production Folder
│   ├── Policy: Require MFA
│   ├── Policy: Enable audit logs
│   └── Projects inherit policies
```

---




