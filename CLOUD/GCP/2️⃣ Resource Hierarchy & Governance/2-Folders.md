# 2. Folders

**Folders** provide a grouping mechanism for organizing projects and applying policies at scale within your Google Cloud organization.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Folder Characteristics                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose:                                              │
│  • Logical grouping of projects                        │
│  • Policy inheritance point                            │
│  • IAM boundary for access control                     │
│  • Cost allocation unit                                │
│                                                         │
│  Capabilities:                                         │
│  • Nest up to 10 levels deep                          │
│  • Apply folder-level policies                         │
│  • Assign folder-level IAM roles                       │
│  • Move projects between folders                       │
│                                                         │
│  Limits:                                               │
│  • Maximum nesting: 10 levels                          │
│  • No limit on number of folders                       │
│  • No limit on projects per folder                     │
└────────────────────────────────────────────────────────┘
```

---

## Folder Hierarchy

### Basic Structure

```
┌────────────────────────────────────────────────────────────┐
│  Folder Hierarchy Example                                  │
└────────────────────────────────────────────────────────────┘

Organization: company.com
│
├── Level 1: Environment Folders
│   │
│   ├── Production (Folder)
│   │   │
│   │   ├── Level 2: Application Folders
│   │   │   │
│   │   │   ├── E-commerce (Folder)
│   │   │   │   │
│   │   │   │   ├── Level 3: Component Folders
│   │   │   │   │   │
│   │   │   │   │   ├── Frontend (Folder)
│   │   │   │   │   │   └── Projects: web-prod-1, web-prod-2
│   │   │   │   │   │
│   │   │   │   │   ├── Backend (Folder)
│   │   │   │   │   │   └── Projects: api-prod-1, api-prod-2
│   │   │   │   │   │
│   │   │   │   │   └── Data (Folder)
│   │   │   │   │       └── Projects: db-prod, analytics-prod
│   │   │   │   │
│   │   │   │   └── (3 levels deep)
│   │   │   │
│   │   │   └── Analytics (Folder)
│   │   │       └── Projects: analytics-prod, ml-prod
│   │   │
│   │   └── (2 levels deep)
│   │
│   ├── Staging (Folder)
│   │   └── Projects: staging-1, staging-2
│   │
│   └── Development (Folder)
│       └── Projects: dev-1, dev-2, dev-3
│
└── (1 level deep)

Policy Inheritance Flow:
Organization → Production → E-commerce → Frontend → Projects
```

---

## Folder Design Patterns

### Pattern 1: Environment-Based (Recommended for Most)

```
Organization
│
├── Production
│   ├── Web Applications
│   ├── APIs
│   ├── Databases
│   └── Infrastructure
│
├── Staging
│   ├── Web Applications
│   └── APIs
│
├── Development
│   ├── Team A
│   ├── Team B
│   └── Sandbox
│
└── Shared Services
    ├── Networking
    ├── Monitoring
    └── Security

Benefits:
  ✓ Clear environment separation
  ✓ Easy policy enforcement per environment
  ✓ Simple cost tracking
  ✓ Intuitive for teams

Use Case: Most organizations, especially startups and mid-size companies
```

### Pattern 2: Business Unit-Based

```
Organization
│
├── E-commerce BU
│   ├── Production
│   │   ├── Frontend
│   │   ├── Backend
│   │   └── Data
│   └── Non-Production
│       ├── Staging
│       └── Development
│
├── Analytics BU
│   ├── Production
│   │   ├── Data Warehouse
│   │   └── ML Platform
│   └── Non-Production
│
├── Mobile BU
│   ├── Production
│   └── Non-Production
│
└── Infrastructure BU
    ├── Networking
    ├── Security
    └── Monitoring

Benefits:
  ✓ Business unit autonomy
  ✓ Clear cost allocation by BU
  ✓ Separate governance per BU
  ✓ Scalable for large orgs

Use Case: Large enterprises with multiple business units
```

### Pattern 3: Team-Based

```
Organization
│
├── Engineering
│   ├── Backend Team
│   │   ├── Production
│   │   └── Development
│   ├── Frontend Team
│   │   ├── Production
│   │   └── Development
│   └── DevOps Team
│       ├── Infrastructure
│       └── Tools
│
├── Data Science
│   ├── ML Models
│   ├── Data Pipelines
│   └── Experiments
│
├── QA
│   ├── Test Environments
│   └── Performance Testing
│
└── Shared
    ├── Networking
    └── Monitoring

Benefits:
  ✓ Team ownership and accountability
  ✓ Flexible team structure
  ✓ Easy to add/remove teams
  ✓ Clear access boundaries

Use Case: Small to medium organizations with autonomous teams
```

### Pattern 4: Hybrid (Environment + Business Unit)

```
Organization
│
├── Production
│   ├── E-commerce BU
│   │   ├── Web
│   │   ├── API
│   │   └── Data
│   ├── Analytics BU
│   │   └── Data Platform
│   └── Shared Services
│       ├── Networking
│       └── Security
│
├── Non-Production
│   ├── Staging
│   │   ├── E-commerce
│   │   └── Analytics
│   └── Development
│       ├── E-commerce
│       └── Analytics
│
└── Sandbox
    └── Experimental Projects

Benefits:
  ✓ Environment-level policies
  ✓ BU-level cost tracking
  ✓ Best of both worlds
  ✓ Flexible governance

Use Case: Large organizations needing both environment and BU separation
```

---

## Folder Management

### Creating Folders

```bash
# Create folder under organization
gcloud resource-manager folders create \
  --display-name="Production" \
  --organization=ORGANIZATION_ID

# Create nested folder
gcloud resource-manager folders create \
  --display-name="Web-Apps" \
  --folder=PARENT_FOLDER_ID

# Create multiple folders (script)
#!/bin/bash
ORG_ID="123456789012"

# Create top-level folders
PROD_ID=$(gcloud resource-manager folders create \
  --display-name="Production" \
  --organization=$ORG_ID \
  --format="value(name)")

DEV_ID=$(gcloud resource-manager folders create \
  --display-name="Development" \
  --organization=$ORG_ID \
  --format="value(name)")

# Create nested folders under Production
gcloud resource-manager folders create \
  --display-name="Web-Apps" \
  --folder=$PROD_ID

gcloud resource-manager folders create \
  --display-name="APIs" \
  --folder=$PROD_ID

gcloud resource-manager folders create \
  --display-name="Databases" \
  --folder=$PROD_ID
```

### Listing Folders

```bash
# List all folders in organization
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID

# List folders in a specific folder
gcloud resource-manager folders list \
  --folder=FOLDER_ID

# List with detailed output
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID \
  --format="table(displayName,name,lifecycleState)"

# Search for folders by name
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID \
  --filter="displayName:Production"
```

### Updating Folders

```bash
# Rename folder
gcloud resource-manager folders update FOLDER_ID \
  --display-name="New-Name"

# Move folder to different parent
gcloud resource-manager folders move FOLDER_ID \
  --folder=NEW_PARENT_FOLDER_ID

# Move folder to organization root
gcloud resource-manager folders move FOLDER_ID \
  --organization=ORGANIZATION_ID
```

### Deleting Folders

```bash
# Delete folder (must be empty)
gcloud resource-manager folders delete FOLDER_ID

# Note: Folder must have:
# - No projects
# - No sub-folders
# - No active policies (optional)

# Force delete (moves to trash, 30-day recovery)
gcloud resource-manager folders delete FOLDER_ID \
  --quiet
```

---

## Folder-Level IAM

### Common Folder Roles

```
┌────────────────────────────────────────────────────────┐
│  Folder IAM Roles                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Folder Admin (roles/resourcemanager.folderAdmin)      │
│  ├─ Full control over folder and contents             │
│  ├─ Create/delete sub-folders                         │
│  ├─ Create projects in folder                         │
│  └─ Set folder-level policies                         │
│                                                         │
│  Folder Editor (roles/resourcemanager.folderEditor)    │
│  ├─ Modify folder properties                          │
│  ├─ Cannot create/delete folders                      │
│  └─ Cannot set policies                               │
│                                                         │
│  Folder Viewer (roles/resourcemanager.folderViewer)    │
│  ├─ Read-only access to folder                        │
│  ├─ View folder structure                             │
│  └─ View folder policies                              │
│                                                         │
│  Folder IAM Admin (roles/resourcemanager.folderIamAdmin)
│  ├─ Manage IAM policies for folder                    │
│  ├─ Grant/revoke roles                                │
│  └─ Cannot modify folder itself                       │
└────────────────────────────────────────────────────────┘
```

### IAM Management

```bash
# Grant Folder Admin role
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='user:manager@company.com' \
  --role='roles/resourcemanager.folderAdmin'

# Grant role to group
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='group:prod-team@company.com' \
  --role='roles/editor'

# Grant role with condition (time-based)
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='user:contractor@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Temporary Access'

# Remove role
gcloud resource-manager folders remove-iam-policy-binding FOLDER_ID \
  --member='user:oldemployee@company.com' \
  --role='roles/editor'

# Get IAM policy
gcloud resource-manager folders get-iam-policy FOLDER_ID

# Set IAM policy from file
gcloud resource-manager folders set-iam-policy FOLDER_ID policy.yaml
```

### IAM Inheritance Example

```
┌────────────────────────────────────────────────────────┐
│  IAM Inheritance Through Folders                       │
└────────────────────────────────────────────────────────┘

Organization
├─ IAM: alice@company.com → Organization Viewer
│  └─→ Alice can view ALL resources
│
Folder: Production
├─ IAM: bob@company.com → Folder Editor
│  └─→ Bob can edit ALL projects in Production
│
Folder: Web-Apps (nested under Production)
├─ IAM: charlie@company.com → Folder Admin
│  └─→ Charlie has full control of Web-Apps folder
│
Project: web-prod-1 (in Web-Apps folder)
├─ IAM: dave@company.com → Project Owner
│  └─→ Dave has full control of web-prod-1
│
Effective Permissions on web-prod-1:
  • alice: Viewer (from org)
  • bob: Editor (from Production folder)
  • charlie: Admin (from Web-Apps folder)
  • dave: Owner (from project)

Note: Permissions are cumulative (union of all levels)
```

---

## Folder-Level Policies

### Applying Organization Policies

```bash
# Set policy on folder
gcloud resource-manager org-policies set-policy \
  policy.yaml \
  --folder=FOLDER_ID

# Example: Restrict VM external IPs for Production folder
cat > restrict-external-ips.yaml <<EOF
constraint: constraints/compute.vmExternalIpAccess
listPolicy:
  deniedValues:
    - "*"
EOF

gcloud resource-manager org-policies set-policy \
  restrict-external-ips.yaml \
  --folder=PRODUCTION_FOLDER_ID

# Example: Allow only specific machine types
cat > allowed-machine-types.yaml <<EOF
constraint: constraints/compute.allowedMachineTypes
listPolicy:
  allowedValues:
    - "n1-standard-1"
    - "n1-standard-2"
    - "n1-standard-4"
EOF

gcloud resource-manager org-policies set-policy \
  allowed-machine-types.yaml \
  --folder=PRODUCTION_FOLDER_ID
```

### Policy Inheritance

```
┌────────────────────────────────────────────────────────┐
│  Policy Inheritance Example                            │
└────────────────────────────────────────────────────────┘

Organization
├─ Policy: Restrict locations to US and EU
│  └─→ Applies to ALL folders and projects
│
Folder: Production
├─ Policy: Disable external IPs
│  └─→ Applies to ALL projects in Production
│
Folder: Web-Apps (nested)
├─ Policy: Require specific labels
│  └─→ Applies to ALL projects in Web-Apps
│
Project: web-prod-1
├─ Inherits ALL parent policies:
│  • Locations: US and EU only (from org)
│  • External IPs: Disabled (from Production)
│  • Labels: Required (from Web-Apps)
│
└─ Cannot override parent policies
   (can only add more restrictive policies)
```

---

## Moving Projects Between Folders

### Move Operations

```bash
# Move project to folder
gcloud projects move PROJECT_ID \
  --folder=DESTINATION_FOLDER_ID

# Move project to organization root
gcloud projects move PROJECT_ID \
  --organization=ORGANIZATION_ID

# Move project from one folder to another
# (automatically removes from current folder)
gcloud projects move web-prod-1 \
  --folder=NEW_FOLDER_ID

# Verify move
gcloud projects describe PROJECT_ID \
  --format="value(parent)"
```

### Move Considerations

```
┌────────────────────────────────────────────────────────┐
│  Before Moving Projects                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Check destination folder policies                   │
│  ✓ Verify IAM inheritance impact                       │
│  ✓ Review billing account association                  │
│  ✓ Test in non-production first                        │
│  ✓ Communicate with stakeholders                       │
│  ✓ Document the change                                 │
│  ✓ Plan rollback if needed                             │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  After Moving Projects                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Verify project access still works                   │
│  ✓ Check inherited policies are correct                │
│  ✓ Confirm IAM permissions                             │
│  ✓ Test application functionality                      │
│  ✓ Update documentation                                │
│  ✓ Notify team members                                 │
└────────────────────────────────────────────────────────┘
```

---

## Folder Naming Conventions

### Best Practices

```
┌────────────────────────────────────────────────────────┐
│  Folder Naming Guidelines                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Format: [Environment]-[Purpose]-[Region]              │
│                                                         │
│  Examples:                                             │
│  ✓ Production                                          │
│  ✓ Production-Web-Apps                                 │
│  ✓ Production-US                                       │
│  ✓ Development-Team-A                                  │
│  ✓ Shared-Services-Networking                          │
│                                                         │
│  Rules:                                                │
│  • Use PascalCase or kebab-case                        │
│  • Be descriptive but concise                          │
│  • Avoid special characters                            │
│  • Use consistent naming across org                    │
│  • Include environment when relevant                   │
│  • Document naming convention                          │
└────────────────────────────────────────────────────────┘
```

### Naming Examples

```
Good Folder Names:
  ✓ Production
  ✓ Production-E-commerce
  ✓ Development-Backend-Team
  ✓ Staging-US-East
  ✓ Shared-Networking
  ✓ Sandbox-Experiments

Bad Folder Names:
  ✗ prod (too short, unclear)
  ✗ folder1 (not descriptive)
  ✗ test_env (inconsistent format)
  ✗ PRODUCTION!!! (special characters)
  ✗ my-folder (too generic)
```

---

## Cost Tracking with Folders

### Folder-Based Cost Allocation

```
┌────────────────────────────────────────────────────────┐
│  Cost Tracking Strategy                                │
└────────────────────────────────────────────────────────┘

Organization: company.com
│
├── Production Folder
│   ├── Monthly Cost: $50,000
│   ├── Projects: 50
│   └── Cost Breakdown:
│       ├── Web-Apps: $20,000 (40%)
│       ├── APIs: $15,000 (30%)
│       └── Databases: $15,000 (30%)
│
├── Staging Folder
│   ├── Monthly Cost: $10,000
│   └── Projects: 20
│
└── Development Folder
    ├── Monthly Cost: $5,000
    └── Projects: 100

Total Organization Cost: $65,000/month
```

### BigQuery Cost Analysis

```sql
-- Cost by folder (requires billing export to BigQuery)
SELECT
  project.ancestry_numbers AS folder_id,
  SUM(cost) AS total_cost,
  SUM(usage.amount) AS total_usage
FROM `project.dataset.gcp_billing_export`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY folder_id
ORDER BY total_cost DESC;

-- Cost trend by folder over time
SELECT
  DATE_TRUNC(usage_start_time, MONTH) AS month,
  project.ancestry_numbers AS folder_id,
  SUM(cost) AS monthly_cost
FROM `project.dataset.gcp_billing_export`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY month, folder_id
ORDER BY month DESC, monthly_cost DESC;
```

---

## Automation with Terraform

### Terraform Configuration

```hcl
# Define organization
data "google_organization" "org" {
  domain = "company.com"
}

# Create top-level folders
resource "google_folder" "production" {
  display_name = "Production"
  parent       = data.google_organization.org.name
}

resource "google_folder" "development" {
  display_name = "Development"
  parent       = data.google_organization.org.name
}

resource "google_folder" "shared_services" {
  display_name = "Shared-Services"
  parent       = data.google_organization.org.name
}

# Create nested folders
resource "google_folder" "prod_web_apps" {
  display_name = "Web-Apps"
  parent       = google_folder.production.name
}

resource "google_folder" "prod_apis" {
  display_name = "APIs"
  parent       = google_folder.production.name
}

# Apply folder-level IAM
resource "google_folder_iam_member" "prod_editors" {
  folder = google_folder.production.name
  role   = "roles/editor"
  member = "group:prod-team@company.com"
}

# Apply folder-level organization policy
resource "google_folder_organization_policy" "restrict_external_ips" {
  folder     = google_folder.production.name
  constraint = "constraints/compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}

# Create projects in folders
resource "google_project" "web_prod" {
  name            = "Web Production"
  project_id      = "web-prod-2026"
  folder_id       = google_folder.prod_web_apps.name
  billing_account = var.billing_account_id
}
```

---

## Best Practices

### 1. Folder Structure Design

```
✓ Plan folder structure before implementation
✓ Keep hierarchy shallow (3-4 levels max)
✓ Use consistent naming conventions
✓ Align with organizational structure
✓ Consider future growth
✓ Document folder purpose and ownership
```

### 2. Policy Management

```
✓ Apply policies at highest appropriate level
✓ Test policies in dev before production
✓ Document policy rationale
✓ Review policies quarterly
✓ Use inheritance effectively
✓ Monitor policy violations
```

### 3. Access Control

```
✓ Use groups for folder-level access
✓ Implement least privilege
✓ Regular access reviews
✓ Document folder ownership
✓ Use IAM conditions when appropriate
✓ Audit folder-level permissions
```

### 4. Cost Management

```
✓ Align folders with cost centers
✓ Set budgets at folder level
✓ Use labels for detailed tracking
✓ Regular cost reviews
✓ Implement cost optimization policies
✓ Export billing data for analysis
```

---

## Common Patterns

### Pattern: Environment Isolation

```
Organization
│
├── Production (Strict policies)
│   ├── Policy: No external IPs
│   ├── Policy: Require MFA
│   ├── Policy: Enable audit logs
│   └── IAM: Limited access
│
├── Staging (Moderate policies)
│   ├── Policy: Limited external IPs
│   ├── Policy: Audit logs
│   └── IAM: Broader access
│
└── Development (Relaxed policies)
    ├── Policy: Allow external IPs
    ├── Policy: Minimal audit
    └── IAM: Developer access
```

### Pattern: Multi-Region

```
Organization
│
├── US-Region
│   ├── Production-US
│   ├── Staging-US
│   └── Development-US
│
├── EU-Region
│   ├── Production-EU
│   ├── Staging-EU
│   └── Development-EU
│
└── APAC-Region
    ├── Production-APAC
    └── Development-APAC
```

---

## Troubleshooting

```
Issue: Cannot create folder
Solution:
  • Verify Organization Admin role
  • Check parent folder exists
  • Verify not at 10-level depth limit
  • Check organization policies

Issue: Cannot move project to folder
Solution:
  • Verify Folder Admin role
  • Check destination folder policies
  • Verify billing account compatibility
  • Check for policy conflicts

Issue: Policy not applying to projects
Solution:
  • Wait for policy propagation (15 min)
  • Check policy inheritance
  • Verify no overrides at project level
  • Use policy analyzer tool

Issue: IAM permissions not working
Solution:
  • Check IAM inheritance
  • Verify role at correct level
  • Check for deny policies
  • Review IAM conditions
```

---

## Next Steps

- **Projects** → [3-Projects.md](./3-Projects.md)
- **Organization Policies** → [5-Organization-Policies.md](./5-Organization-Policies.md)
- **IAM Hierarchy** → [6-IAM-Hierarchy.md](./6-IAM-Hierarchy.md)

---
