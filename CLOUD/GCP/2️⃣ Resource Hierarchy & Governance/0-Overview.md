# 2️⃣ Resource Hierarchy & Governance

Complete guide to organizing, managing, and governing Google Cloud Platform resources at scale.

---

## 📚 What You'll Learn

This section covers how GCP structures and governs resources through a hierarchical model that enables:

- **Centralized Management**: Control resources across your entire organization
- **Policy Enforcement**: Apply security and compliance policies consistently
- **Cost Management**: Track and optimize spending by department or project
- **Access Control**: Implement least privilege at scale
- **Compliance**: Meet regulatory requirements through governance

---

## 📖 Table of Contents

### [1. Organization Node](./1-Organization.md)
**Root of Your GCP Hierarchy**

```
Topics Covered:
  • What is an Organization node
  • Organization setup and requirements
  • Organization roles and permissions
  • Organization policies
  • Super Admin vs Organization Admin
  • Multi-organization strategies
  • Organization migration
```

**Key Services:**
- Google Cloud Organization
- Cloud Identity / Google Workspace
- Resource Manager API

---

### [2. Folders](./2-Folders.md)
**Grouping and Organizing Projects**

```
Topics Covered:
  • Folder structure and hierarchy
  • Folder design patterns
  • Nested folders (up to 10 levels)
  • Folder-level IAM
  • Folder-level policies
  • Moving resources between folders
  • Best practices for folder organization
```

**Key Services:**
- Resource Manager (Folders)
- IAM for Folders
- Organization Policy Service

---

### [3. Projects](./3-Projects.md)
**Core Resource Container**

```
Topics Covered:
  • Project structure and components
  • Project ID vs Project Number vs Project Name
  • Project lifecycle management
  • Project quotas and limits
  • Billing account association
  • Project migration and transfer
  • Project deletion and recovery
```

**Key Services:**
- Resource Manager (Projects)
- Cloud Billing
- Service Usage API

---

### [4. Resource Manager](./4-Resource-Manager.md)
**Programmatic Resource Management**

```
Topics Covered:
  • Resource Manager API overview
  • Creating and managing resources
  • Resource hierarchy operations
  • Searching and filtering resources
  • Resource metadata and labels
  • Bulk operations
  • Automation with Terraform
```

**Key Services:**
- Resource Manager API
- Cloud Asset Inventory
- Resource Search

---

### [5. Organization Policies](./5-Organization-Policies.md)
**Governance and Compliance**

```
Topics Covered:
  • Policy types (List, Boolean)
  • Policy constraints
  • Policy inheritance and evaluation
  • Custom organization policies
  • Policy enforcement
  • Common policy use cases
  • Policy testing and validation
```

**Key Services:**
- Organization Policy Service
- Policy Analyzer
- Policy Simulator

---

### [6. IAM Hierarchy](./6-IAM-Hierarchy.md)
**Access Control at Scale**

```
Topics Covered:
  • IAM inheritance model
  • Role binding at different levels
  • Service accounts in hierarchy
  • IAM conditions
  • Policy troubleshooting
  • Least privilege implementation
  • IAM recommender
```

**Key Services:**
- Cloud IAM
- IAM Policy Analyzer
- IAM Recommender

---

### [7. Tags & Labels](./7-Tags-Labels.md)
**Resource Organization and Cost Tracking**

```
Topics Covered:
  • Tags vs Labels comparison
  • Tag keys and values
  • Tag-based access control
  • Label-based cost allocation
  • Tagging strategies
  • Automation and enforcement
  • Best practices
```

**Key Services:**
- Resource Manager (Tags)
- Cloud Billing (Labels)
- Cloud Asset Inventory

---

### [8. Best Practices](./8-Best-Practices.md)
**Enterprise-Grade Governance**

```
Topics Covered:
  • Hierarchy design patterns
  • Naming conventions
  • Security best practices
  • Cost optimization strategies
  • Compliance frameworks
  • Disaster recovery planning
  • Migration strategies
```

---

## 🏗️ Complete Hierarchy Visualization

```
┌─────────────────────────────────────────────────────────────────┐
│                    Google Cloud Hierarchy                        │
└─────────────────────────────────────────────────────────────────┘

                        ┌──────────────────┐
                        │  Organization    │  ← company.com
                        │  (Root Node)     │    • Org-level policies
                        └────────┬─────────┘    • Org-level IAM
                                 │              • Billing accounts
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
        ┌─────▼─────┐      ┌────▼────┐      ┌─────▼─────┐
        │  Folder   │      │ Folder  │      │  Folder   │  ← Departments
        │  (Prod)   │      │  (Dev)  │      │  (Shared) │    • Folder policies
        └─────┬─────┘      └────┬────┘      └─────┬─────┘    • Folder IAM
              │                 │                  │
        ┌─────▼─────┐      ┌───▼────┐       ┌────▼─────┐
        │  Folder   │      │ Folder │       │  Folder  │  ← Teams/Apps
        │  (Web)    │      │ (API)  │       │(Network) │
        └─────┬─────┘      └───┬────┘       └────┬─────┘
              │                │                  │
        ┌─────▼─────┐      ┌───▼────┐       ┌────▼─────┐
        │  Project  │      │Project │       │ Project  │  ← Workloads
        │  (App-1)  │      │(App-2) │       │(Network) │    • Billing boundary
        └─────┬─────┘      └───┬────┘       └────┬─────┘    • API enablement
              │                │                  │          • Quotas
        ┌─────▼─────┐      ┌───▼────┐       ┌────▼─────┐
        │ Resources │      │Resources│      │Resources │  ← Services
        │ • VM      │      │• Cloud  │      │• VPC     │
        │ • DB      │      │  Run    │      │• Firewall│
        │ • Bucket  │      │• Storage│      │• Routes  │
        └───────────┘      └─────────┘      └──────────┘

Policy Inheritance: Organization → Folders → Projects → Resources
IAM Inheritance: Permissions flow downward (additive)
```

---

## 🎯 Key Concepts

### 1. Hierarchy Levels

| Level | Purpose | Limit | Billing | IAM Boundary |
|-------|---------|-------|---------|--------------|
| **Organization** | Root container | 1 per domain | Billing accounts | Yes |
| **Folder** | Logical grouping | 10 levels deep | No | Yes |
| **Project** | Resource container | Unlimited | Yes | Yes |
| **Resource** | Actual services | Varies by quota | No | Some resources |

### 2. Policy Inheritance

```
┌────────────────────────────────────────────────────────┐
│  How Policies Flow Down the Hierarchy                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Organization Level                                    │
│  ├─ Policy: Require MFA                               │
│  └─ Applies to: ALL resources                         │
│                                                         │
│  Folder Level (Production)                             │
│  ├─ Policy: Restrict VM types to n1-standard          │
│  └─ Applies to: All projects in folder                │
│                                                         │
│  Project Level                                         │
│  ├─ Policy: Enable VPC Flow Logs                      │
│  └─ Applies to: All resources in project              │
│                                                         │
│  Result: Cumulative (all policies apply)              │
│  • MFA required (from org)                            │
│  • Only n1-standard VMs (from folder)                 │
│  • VPC Flow Logs enabled (from project)               │
└────────────────────────────────────────────────────────┘
```

### 3. IAM Inheritance

```
┌────────────────────────────────────────────────────────┐
│  How IAM Permissions Flow                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Organization: alice@company.com → Viewer              │
│  └─→ Alice can VIEW all resources                     │
│                                                         │
│  Folder (Prod): bob@company.com → Editor               │
│  └─→ Bob can EDIT all projects in Prod folder         │
│                                                         │
│  Project: charlie@company.com → Owner                  │
│  └─→ Charlie has FULL control of this project         │
│                                                         │
│  Inheritance Rules:                                    │
│  • Permissions are ADDITIVE (union)                   │
│  • Child cannot REMOVE parent permissions             │
│  • More permissive wins                               │
└────────────────────────────────────────────────────────┘
```

---

## 🏢 Common Hierarchy Patterns

### Pattern 1: Environment-Based

```
Organization: acme-corp.com
│
├── Production Folder
│   ├── Web App Project
│   ├── API Project
│   └── Database Project
│
├── Staging Folder
│   ├── Web App Project
│   └── API Project
│
├── Development Folder
│   ├── Dev Project 1
│   └── Dev Project 2
│
└── Sandbox Folder
    └── Experimental Projects

Use Case: Clear environment separation
Benefits: Easy policy enforcement per environment
```

### Pattern 2: Business Unit-Based

```
Organization: acme-corp.com
│
├── E-commerce BU
│   ├── Production
│   │   ├── Frontend
│   │   ├── Backend
│   │   └── Data
│   └── Non-Production
│       └── Dev/Test
│
├── Analytics BU
│   ├── Data Warehouse
│   └── ML Platform
│
└── Infrastructure BU
    ├── Networking
    ├── Security
    └── Monitoring

Use Case: Large organizations with multiple business units
Benefits: Cost tracking and access control by BU
```

### Pattern 3: Team-Based

```
Organization: startup-inc.com
│
├── Engineering
│   ├── Backend Team
│   │   ├── Prod
│   │   └── Dev
│   └── Frontend Team
│       ├── Prod
│       └── Dev
│
├── Data Science
│   ├── ML Models
│   └── Data Pipelines
│
└── Shared Services
    ├── Networking
    └── Monitoring

Use Case: Small to medium organizations
Benefits: Team autonomy with centralized governance
```

---

## 🔐 Governance Framework

### 1. Security Governance

```
┌────────────────────────────────────────────────────────┐
│  Security Controls by Level                            │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Organization Level:                                   │
│  ✓ Require MFA for all users                           │
│  ✓ Enforce domain restriction                          │
│  ✓ Disable service account key creation                │
│  ✓ Require OS Login                                    │
│                                                        │
│  Folder Level (Production):                            │
│  ✓ Restrict public IP addresses                       │
│  ✓ Require VPC Service Controls                       │
│  ✓ Enable audit logging                               │
│  ✓ Restrict VM serial port access                     │
│                                                        │
│  Project Level:                                        │
│  ✓ Enable VPC Flow Logs                               │
│  ✓ Configure firewall rules                           │
│  ✓ Set up monitoring alerts                           │
└────────────────────────────────────────────────────────┘
```

### 2. Cost Governance

```
┌────────────────────────────────────────────────────────┐
│  Cost Control Strategies                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Organization Level:                                   │
│  • Consolidated billing                                │
│  • Organization-wide budgets                           │
│  • Cost allocation by folder/project                   │
│                                                         │
│  Folder Level:                                         │
│  • Department budgets                                  │
│  • Resource quotas                                     │
│  • Committed use discounts                             │
│                                                         │
│  Project Level:                                        │
│  • Project budgets and alerts                          │
│  • Resource labels for tracking                        │
│  • Automatic resource cleanup                          │
└────────────────────────────────────────────────────────┘
```

### 3. Compliance Governance

```
┌────────────────────────────────────────────────────────┐
│  Compliance Controls                                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Data Residency:                                       │
│  • Restrict resource locations (org policy)            │
│  • Enforce regional constraints                        │
│                                                         │
│  Audit & Logging:                                      │
│  • Enable Cloud Audit Logs (org-wide)                 │
│  • Log retention policies                              │
│  • SIEM integration                                    │
│                                                         │
│  Access Control:                                       │
│  • Least privilege IAM                                 │
│  • Regular access reviews                              │
│  • Service account management                          │
└────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start Guide

### Step 1: Set Up Organization

```bash
# Check if organization exists
gcloud organizations list

# If no organization, set up Cloud Identity or Google Workspace
# Visit: https://cloud.google.com/resource-manager/docs/creating-managing-organization

# Grant yourself Organization Admin role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='user:admin@company.com' \
  --role='roles/resourcemanager.organizationAdmin'
```

### Step 2: Create Folder Structure

```bash
# Create top-level folders
gcloud resource-manager folders create \
  --display-name="Production" \
  --organization=ORGANIZATION_ID

gcloud resource-manager folders create \
  --display-name="Development" \
  --organization=ORGANIZATION_ID

# Create nested folders
gcloud resource-manager folders create \
  --display-name="Web-Apps" \
  --folder=PRODUCTION_FOLDER_ID
```

### Step 3: Create Projects

```bash
# Create project in folder
gcloud projects create web-prod-2026 \
  --name="Web Production" \
  --folder=WEB_APPS_FOLDER_ID

# Link billing account
gcloud billing projects link web-prod-2026 \
  --billing-account=BILLING_ACCOUNT_ID
```

### Step 4: Apply Organization Policies

```bash
# Restrict VM external IPs
gcloud resource-manager org-policies set-policy \
  --organization=ORGANIZATION_ID \
  policy.yaml

# policy.yaml content:
# constraint: compute.vmExternalIpAccess
# listPolicy:
#   deniedValues:
#   - "*"
```

---

## 📊 Monitoring & Reporting

### 1. Resource Hierarchy Visualization

```bash
# List organization hierarchy
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --asset-types=cloudresourcemanager.googleapis.com/Organization,cloudresourcemanager.googleapis.com/Folder,cloudresourcemanager.googleapis.com/Project

# Export to JSON for visualization
gcloud asset export \
  --output-path=gs://my-bucket/asset-inventory.json \
  --content-type=resource \
  --organization=ORGANIZATION_ID
```

### 2. Policy Compliance Reports

```bash
# Check policy compliance
gcloud asset analyze-org-policies \
  --organization=ORGANIZATION_ID \
  --constraint=constraints/compute.vmExternalIpAccess

# Generate compliance report
gcloud asset analyze-org-policy-governed-assets \
  --organization=ORGANIZATION_ID \
  --constraint=constraints/compute.vmExternalIpAccess \
  --format=json
```

### 3. Cost Reports by Hierarchy

```bash
# Export billing data to BigQuery
# Then query by project/folder

SELECT
  project.name,
  SUM(cost) as total_cost
FROM `project.dataset.gcp_billing_export`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY project.name
ORDER BY total_cost DESC
```

---

## 🛠️ Tools & Automation

### 1. Terraform for Hierarchy Management

```hcl
# Organization
data "google_organization" "org" {
  domain = "company.com"
}

# Folders
resource "google_folder" "production" {
  display_name = "Production"
  parent       = data.google_organization.org.name
}

resource "google_folder" "web_apps" {
  display_name = "Web-Apps"
  parent       = google_folder.production.name
}

# Projects
resource "google_project" "web_prod" {
  name            = "Web Production"
  project_id      = "web-prod-2026"
  folder_id       = google_folder.web_apps.name
  billing_account = var.billing_account_id
}

# Organization Policy
resource "google_organization_policy" "restrict_external_ips" {
  org_id     = data.google_organization.org.org_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}
```

### 2. Python SDK

```python
from google.cloud import resourcemanager_v3

# Initialize client
client = resourcemanager_v3.FoldersClient()

# Create folder
folder = resourcemanager_v3.Folder(
    display_name="Production",
    parent="organizations/123456789"
)

operation = client.create_folder(folder=folder)
result = operation.result()
print(f"Created folder: {result.name}")
```

---

## ✅ Governance Checklist

### Organization Setup
- [ ] Organization node created
- [ ] Super Admin designated
- [ ] Organization Admins assigned
- [ ] Cloud Identity / Workspace configured
- [ ] Billing accounts linked

### Hierarchy Design
- [ ] Folder structure planned
- [ ] Naming conventions defined
- [ ] Environment separation implemented
- [ ] Projects organized logically
- [ ] Resource labels strategy defined

### Security & Compliance
- [ ] Organization policies applied
- [ ] IAM roles assigned (least privilege)
- [ ] MFA enforced
- [ ] Audit logging enabled
- [ ] VPC Service Controls configured

### Cost Management
- [ ] Budgets and alerts configured
- [ ] Cost allocation labels applied
- [ ] Committed use discounts evaluated
- [ ] Resource quotas set
- [ ] Billing exports to BigQuery

### Operations
- [ ] Monitoring and alerting configured
- [ ] Incident response procedures documented
- [ ] Backup and DR strategy implemented
- [ ] Change management process defined
- [ ] Regular access reviews scheduled

---

## 🎓 Next Steps

After mastering Resource Hierarchy & Governance:

1. **IAM & Security** - Deep dive into access control
2. **Networking** - VPC design and connectivity
3. **Compute Services** - Deploy workloads
4. **Storage & Databases** - Data management
5. **DevOps & Automation** - CI/CD pipelines

---

**Last Updated:** March 2026
**Version:** 2.0
