# 3. Projects

**Projects** are the core organizational unit in GCP where all resources are created and billed.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Project Characteristics                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Project ID:      web-prod-2026 (immutable, unique)    │
│  Project Number:  123456789012 (auto-assigned)         │
│  Project Name:    Web Production (mutable, display)    │
│                                                         │
│  Purpose:                                              │
│  • Resource container (VMs, DBs, buckets, etc.)        │
│  • Billing boundary (separate billing per project)     │
│  • API enablement (enable services per project)        │
│  • Quota management (resource limits per project)      │
│  • IAM boundary (access control isolation)             │
│  • Audit logging scope                                 │
└────────────────────────────────────────────────────────┘
```

---

## Project Identifiers

### Three Types of Identifiers

```
┌────────────────────────────────────────────────────────┐
│  Project Identifiers Comparison                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Project ID                                            │
│  • User-defined (must be globally unique)              │
│  • Immutable (cannot be changed)                       │
│  • 6-30 characters, lowercase, numbers, hyphens        │
│  • Example: web-prod-2026                              │
│  • Used in: gcloud commands, APIs, URLs                │
│                                                         │
│  Project Number                                        │
│  • Auto-assigned by Google                             │
│  • Immutable (permanent identifier)                    │
│  • Numeric only                                        │
│  • Example: 123456789012                               │
│  • Used in: Service accounts, some APIs                │
│                                                         │
│  Project Name                                          │
│  • User-defined (display name)                         │
│  • Mutable (can be changed anytime)                    │
│  • Not unique (multiple projects can have same name)   │
│  • Example: Web Production                             │
│  • Used in: Console UI, reports                        │
└────────────────────────────────────────────────────────┘
```

---

## Project Lifecycle

### Creation

```bash
# Create project (auto-assigned to user)
gcloud projects create web-prod-2026 \
  --name="Web Production"

# Create project in folder
gcloud projects create web-prod-2026 \
  --name="Web Production" \
  --folder=FOLDER_ID

# Create project in organization
gcloud projects create web-prod-2026 \
  --name="Web Production" \
  --organization=ORGANIZATION_ID

# Create with labels
gcloud projects create web-prod-2026 \
  --name="Web Production" \
  --labels=environment=production,team=web,cost-center=engineering

# Link billing account
gcloud billing projects link web-prod-2026 \
  --billing-account=BILLING_ACCOUNT_ID
```

### Management

```bash
# List projects
gcloud projects list

# List with filter
gcloud projects list --filter="projectId:web-*"

# Describe project
gcloud projects describe web-prod-2026

# Update project name
gcloud projects update web-prod-2026 \
  --name="Web Production Updated"

# Add labels
gcloud projects update web-prod-2026 \
  --update-labels=version=v2,owner=alice

# Remove labels
gcloud projects update web-prod-2026 \
  --remove-labels=version
```

### Deletion and Recovery

```bash
# Delete project (soft delete, 30-day recovery period)
gcloud projects delete web-prod-2026

# Undelete project (within 30 days)
gcloud projects undelete web-prod-2026

# Check project lifecycle state
gcloud projects describe web-prod-2026 \
  --format="value(lifecycleState)"

# States: ACTIVE, DELETE_REQUESTED, DELETE_IN_PROGRESS
```

---

## Project Structure

### Typical Project Contents

```
Project: web-prod-2026
│
├── Compute Resources
│   ├── Compute Engine VMs (10 instances)
│   ├── GKE Cluster (3-node cluster)
│   ├── Cloud Run Services (5 services)
│   └── App Engine Application
│
├── Storage
│   ├── Cloud Storage Buckets (15 buckets)
│   ├── Persistent Disks (20 disks)
│   └── Filestore Instances (2 instances)
│
├── Databases
│   ├── Cloud SQL (2 instances)
│   ├── Firestore (1 database)
│   └── Memorystore Redis (1 instance)
│
├── Networking
│   ├── VPC Networks (2 networks)
│   ├── Subnets (5 subnets)
│   ├── Firewall Rules (20 rules)
│   ├── Load Balancers (3 LBs)
│   └── Cloud NAT (1 gateway)
│
├── Security & IAM
│   ├── Service Accounts (10 accounts)
│   ├── IAM Policies
│   ├── Secrets (Secret Manager)
│   └── Encryption Keys (Cloud KMS)
│
├── APIs & Services
│   ├── Enabled APIs (50 APIs)
│   ├── API Keys
│   └── OAuth Credentials
│
└── Monitoring & Logging
    ├── Cloud Monitoring Dashboards
    ├── Alerting Policies
    ├── Log Sinks
    └── Uptime Checks
```

---

## Project Naming Conventions

### Recommended Patterns

```
Pattern: <service>-<environment>-<region>-<purpose>

Examples:
  ✓ web-prod-us-frontend
  ✓ api-prod-eu-backend
  ✓ data-prod-global-warehouse
  ✓ ml-dev-us-training
  ✓ network-shared-global-hub
  ✓ monitoring-shared-global-central

Pattern: <team>-<app>-<environment>

Examples:
  ✓ backend-ecommerce-prod
  ✓ frontend-mobile-staging
  ✓ data-analytics-dev
  ✓ devops-cicd-prod

Pattern: <company>-<bu>-<env>-<app>

Examples:
  ✓ acme-retail-prod-web
  ✓ acme-analytics-prod-dwh
  ✓ acme-mobile-dev-ios
```

### Naming Rules

```
✓ Use lowercase letters
✓ Use hyphens for separation
✓ Include environment (prod/staging/dev)
✓ Be descriptive but concise
✓ 6-30 characters
✓ Start with letter
✓ End with letter or number
✓ Globally unique

✗ Avoid underscores
✗ Avoid special characters
✗ Avoid generic names (project1, test)
✗ Avoid PII or sensitive info
```

---

## Project Quotas and Limits

### Common Quotas

```
┌────────────────────────────────────────────────────────┐
│  Default Project Quotas                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine:                                       │
│  • CPUs: 24 per region                                 │
│  • Persistent Disk: 10 TB per region                   │
│  • In-use IP addresses: 8 per region                   │
│  • VMs: Varies by machine type                         │
│                                                         │
│  Cloud Storage:                                        │
│  • Buckets: 10,000 per project                         │
│  • Objects: Unlimited                                  │
│  • Bandwidth: 200 Gbps egress                          │
│                                                         │
│  Cloud SQL:                                            │
│  • Instances: 100 per project                          │
│  • Storage: 30 TB per instance                         │
│  • Connections: Varies by tier                         │
│                                                         │
│  GKE:                                                  │
│  • Clusters: 50 per project per region                 │
│  • Nodes: 5,000 per cluster                            │
│  • Pods: 110 per node (default)                        │
└────────────────────────────────────────────────────────┘
```

### Managing Quotas

```bash
# View quotas
gcloud compute project-info describe \
  --project=web-prod-2026

# Request quota increase
# (Must be done through Console: IAM & Admin → Quotas)

# Check specific quota
gcloud compute regions describe us-central1 \
  --project=web-prod-2026 \
  --format="table(quotas.metric,quotas.limit,quotas.usage)"
```

---

## Project IAM

### Project-Level Roles

```
┌────────────────────────────────────────────────────────┐
│  Common Project Roles                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Owner (roles/owner)                                   │
│  • Full control over project                           │
│  • Manage IAM policies                                 │
│  • Delete project                                      │
│  • Manage billing                                      │
│                                                         │
│  Editor (roles/editor)                                 │
│  • Create/modify/delete resources                      │
│  • Cannot manage IAM                                   │
│  • Cannot delete project                               │
│                                                         │
│  Viewer (roles/viewer)                                 │
│  • Read-only access                                    │
│  • View resources and configurations                   │
│  • Cannot make changes                                 │
│                                                         │
│  Browser (roles/browser)                               │
│  • Browse project hierarchy                            │
│  • View project in console                             │
│  • Minimal permissions                                 │
└────────────────────────────────────────────────────────┘
```

### IAM Management

```bash
# Grant project role
gcloud projects add-iam-policy-binding web-prod-2026 \
  --member='user:alice@company.com' \
  --role='roles/editor'

# Grant to group
gcloud projects add-iam-policy-binding web-prod-2026 \
  --member='group:developers@company.com' \
  --role='roles/viewer'

# Grant to service account
gcloud projects add-iam-policy-binding web-prod-2026 \
  --member='serviceAccount:app@web-prod-2026.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Remove role
gcloud projects remove-iam-policy-binding web-prod-2026 \
  --member='user:bob@company.com' \
  --role='roles/editor'

# Get IAM policy
gcloud projects get-iam-policy web-prod-2026

# Set IAM policy from file
gcloud projects set-iam-policy web-prod-2026 policy.yaml
```

---

## API Management

### Enabling APIs

```bash
# List enabled APIs
gcloud services list --enabled \
  --project=web-prod-2026

# List available APIs
gcloud services list --available \
  --project=web-prod-2026

# Enable API
gcloud services enable compute.googleapis.com \
  --project=web-prod-2026

# Enable multiple APIs
gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com \
  sqladmin.googleapis.com \
  container.googleapis.com \
  --project=web-prod-2026

# Disable API
gcloud services disable compute.googleapis.com \
  --project=web-prod-2026

# Check if API is enabled
gcloud services list --enabled \
  --filter="name:compute.googleapis.com" \
  --project=web-prod-2026
```

---

## Project Migration

### Moving Projects

```bash
# Move project to folder
gcloud projects move web-prod-2026 \
  --folder=FOLDER_ID

# Move project to organization root
gcloud projects move web-prod-2026 \
  --organization=ORGANIZATION_ID

# Verify move
gcloud projects describe web-prod-2026 \
  --format="value(parent)"
```

### Migration Checklist

```
Before Migration:
  ✓ Backup IAM policies
  ✓ Document current structure
  ✓ Review destination policies
  ✓ Check billing account
  ✓ Test with non-critical project
  ✓ Communicate with team

After Migration:
  ✓ Verify access works
  ✓ Check inherited policies
  ✓ Test applications
  ✓ Update documentation
  ✓ Monitor for issues
```

---

## Billing

### Billing Account Linkage

```bash
# List billing accounts
gcloud billing accounts list

# Link billing account to project
gcloud billing projects link web-prod-2026 \
  --billing-account=BILLING_ACCOUNT_ID

# Check billing status
gcloud billing projects describe web-prod-2026

# Unlink billing (disables billable resources)
gcloud billing projects unlink web-prod-2026
```

### Cost Management

```bash
# Set budget
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Web Prod Budget" \
  --budget-amount=5000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100 \
  --filter-projects=projects/web-prod-2026

# Export billing to BigQuery
# (Configure in Console: Billing → Billing export)
```

---

## Terraform Example

```hcl
# Create project
resource "google_project" "web_prod" {
  name            = "Web Production"
  project_id      = "web-prod-2026"
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  labels = {
    environment = "production"
    team        = "web"
    cost_center = "engineering"
  }
}

# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "container.googleapis.com",
  ])

  project = google_project.web_prod.project_id
  service = each.key

  disable_on_destroy = false
}

# Grant IAM roles
resource "google_project_iam_member" "editors" {
  project = google_project.web_prod.project_id
  role    = "roles/editor"
  member  = "group:web-team@company.com"
}

# Create service account
resource "google_service_account" "app" {
  project      = google_project.web_prod.project_id
  account_id   = "web-app"
  display_name = "Web Application Service Account"
}
```

---

## Best Practices

```
✓ Use descriptive, consistent naming
✓ Link billing account immediately
✓ Enable required APIs upfront
✓ Apply labels for cost tracking
✓ Implement least privilege IAM
✓ Enable audit logging
✓ Set up budgets and alerts
✓ Document project purpose
✓ Regular access reviews
✓ Use service accounts for apps
```

---

## Next Steps

- **Resource Manager** → [4-Resource-Manager.md](./4-Resource-Manager.md)
- **Organization Policies** → [5-Organization-Policies.md](./5-Organization-Policies.md)
- **Tags & Labels** → [7-Tags-Labels.md](./7-Tags-Labels.md)

---
