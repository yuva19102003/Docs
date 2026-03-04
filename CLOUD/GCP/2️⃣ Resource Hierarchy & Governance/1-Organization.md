# 1. Organization Node

The **Organization** is the root node of the Google Cloud resource hierarchy, representing your company or domain.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Organization Node                                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Domain: company.com                                   │
│  Organization ID: 123456789012                         │
│  Display Name: Acme Corporation                        │
│                                                         │
│  Purpose:                                              │
│  • Root container for all GCP resources                │
│  • Centralized policy management                       │
│  • Organization-wide IAM control                       │
│  • Consolidated billing                                │
│  • Audit logging aggregation                           │
└────────────────────────────────────────────────────────┘
```

---

## What is an Organization?

An **Organization resource** represents your company in Google Cloud and serves as the top-level container for all your cloud resources.

### Key Characteristics

```
┌────────────────────────────────────────────────────────┐
│  Organization Properties                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Uniqueness:                                           │
│  • One organization per Google Workspace/Cloud Identity│
│  • Tied to a specific domain (e.g., company.com)      │
│                                                         │
│  Scope:                                                │
│  • Contains all folders and projects                   │
│  • Policies apply to entire organization               │
│  • IAM roles cascade down hierarchy                    │
│                                                         │
│  Lifecycle:                                            │
│  • Created automatically with Workspace/Identity       │
│  • Cannot be deleted (only deactivated)                │
│  • Permanent organization ID                           │
└────────────────────────────────────────────────────────┘
```

---

## Organization Setup

### Prerequisites

To create an organization, you need either:

1. **Google Workspace Account** (recommended for businesses)
2. **Cloud Identity Free** (for GCP-only usage)

### Setup Process

```
┌────────────────────────────────────────────────────────┐
│  Organization Creation Workflow                        │
└────────────────────────────────────────────────────────┘

Step 1: Set Up Identity Provider
┌─────────────────────────────────┐
│  Option A: Google Workspace     │
│  • Full productivity suite      │
│  • Gmail, Drive, Docs, etc.     │
│  • Cost: $6-18/user/month       │
└─────────────────────────────────┘
         OR
┌─────────────────────────────────┐
│  Option B: Cloud Identity Free  │
│  • Identity management only     │
│  • No productivity apps         │
│  • Cost: Free                   │
└─────────────────────────────────┘
                │
                ▼
Step 2: Verify Domain Ownership
┌─────────────────────────────────┐
│  • Add TXT record to DNS        │
│  • Verify domain in console     │
│  • Wait for propagation         │
└─────────────────────────────────┘
                │
                ▼
Step 3: Organization Auto-Created
┌─────────────────────────────────┐
│  • Organization node created    │
│  • Organization ID assigned     │
│  • Super Admin designated       │
└─────────────────────────────────┘
                │
                ▼
Step 4: Configure Organization
┌─────────────────────────────────┐
│  • Assign Organization Admins   │
│  • Set up billing accounts      │
│  • Apply organization policies  │
│  • Create folder structure      │
└─────────────────────────────────┘
```

### Detailed Setup Steps

#### 1. Sign Up for Cloud Identity

```bash
# Visit Cloud Identity signup
https://workspace.google.com/signup/gcpidentity/welcome

# Or Google Workspace
https://workspace.google.com/
```

#### 2. Verify Domain

```
Add TXT record to your domain's DNS:

Name: @
Type: TXT
Value: google-site-verification=XXXXXXXXXXXXXXXXX

Wait 24-48 hours for DNS propagation
```

#### 3. Check Organization Creation

```bash
# List organizations
gcloud organizations list

# Output:
# DISPLAY_NAME          ID            DIRECTORY_CUSTOMER_ID
# Acme Corporation      123456789012  C01234567

# Get organization details
gcloud organizations describe 123456789012
```

---

## Organization Roles

### Core Roles

```
┌────────────────────────────────────────────────────────┐
│  Organization-Level Roles                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Super Admin (Google Workspace/Cloud Identity)         │
│  ├─ Full control over domain and organization         │
│  ├─ Can assign Organization Admin role                │
│  ├─ Manages user accounts and groups                  │
│  └─ Should be limited to 2-3 people                   │
│                                                         │
│  Organization Admin (roles/resourcemanager.organizationAdmin)
│  ├─ Full control over organization resources          │
│  ├─ Can create folders and projects                   │
│  ├─ Can set organization policies                     │
│  └─ Cannot manage user accounts                       │
│                                                         │
│  Organization Viewer (roles/resourcemanager.organizationViewer)
│  ├─ Read-only access to organization                  │
│  ├─ View folders and projects                         │
│  ├─ View organization policies                        │
│  └─ Cannot make changes                               │
│                                                         │
│  Folder Admin (roles/resourcemanager.folderAdmin)      │
│  ├─ Manage specific folders                           │
│  ├─ Create projects in folders                        │
│  ├─ Set folder-level policies                         │
│  └─ Scoped to specific folders                        │
│                                                         │
│  Project Creator (roles/resourcemanager.projectCreator)│
│  ├─ Create new projects                               │
│  ├─ Automatically becomes project owner               │
│  └─ Cannot delete projects                            │
└────────────────────────────────────────────────────────┘
```

### Role Assignment

```bash
# Grant Organization Admin role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='user:admin@company.com' \
  --role='roles/resourcemanager.organizationAdmin'

# Grant Organization Viewer role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='group:auditors@company.com' \
  --role='roles/resourcemanager.organizationViewer'

# Grant Folder Admin role (scoped to specific folder)
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='user:manager@company.com' \
  --role='roles/resourcemanager.folderAdmin'

# Grant Project Creator role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='group:developers@company.com' \
  --role='roles/resourcemanager.projectCreator'

# List IAM policy for organization
gcloud organizations get-iam-policy ORGANIZATION_ID
```

---

## Organization Policies

Organization policies allow you to enforce governance rules across your entire organization.

### Policy Types

```
┌────────────────────────────────────────────────────────┐
│  Organization Policy Types                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. List Constraints                                   │
│     • Allow or deny specific values                    │
│     • Example: Allowed VM machine types                │
│     • Example: Allowed resource locations              │
│                                                         │
│  2. Boolean Constraints                                │
│     • Enforce or disable a feature                     │
│     • Example: Require OS Login                        │
│     • Example: Disable service account key creation    │
│                                                         │
│  3. Custom Constraints                                 │
│     • Define your own rules using CEL                  │
│     • Example: Require specific labels                 │
│     • Example: Enforce naming conventions              │
└────────────────────────────────────────────────────────┘
```

### Common Organization Policies

#### 1. Restrict Resource Locations

```yaml
# policy-restrict-locations.yaml
constraint: constraints/gcp.resourceLocations
listPolicy:
  allowedValues:
    - in:us-locations
    - in:eu-locations
```

```bash
# Apply policy
gcloud resource-manager org-policies set-policy \
  policy-restrict-locations.yaml \
  --organization=ORGANIZATION_ID
```

#### 2. Require OS Login

```yaml
# policy-require-os-login.yaml
constraint: constraints/compute.requireOsLogin
booleanPolicy:
  enforced: true
```

```bash
# Apply policy
gcloud resource-manager org-policies set-policy \
  policy-require-os-login.yaml \
  --organization=ORGANIZATION_ID
```

#### 3. Disable Service Account Key Creation

```yaml
# policy-disable-sa-keys.yaml
constraint: constraints/iam.disableServiceAccountKeyCreation
booleanPolicy:
  enforced: true
```

#### 4. Restrict VM External IPs

```yaml
# policy-restrict-external-ips.yaml
constraint: constraints/compute.vmExternalIpAccess
listPolicy:
  deniedValues:
    - "*"
```

#### 5. Enforce Domain Restriction

```yaml
# policy-domain-restriction.yaml
constraint: constraints/iam.allowedPolicyMemberDomains
listPolicy:
  allowedValues:
    - company.com
    - partner-company.com
```

### Policy Management Commands

```bash
# List all organization policies
gcloud resource-manager org-policies list \
  --organization=ORGANIZATION_ID

# Describe specific policy
gcloud resource-manager org-policies describe \
  constraints/compute.vmExternalIpAccess \
  --organization=ORGANIZATION_ID

# Delete policy (revert to default)
gcloud resource-manager org-policies delete \
  constraints/compute.vmExternalIpAccess \
  --organization=ORGANIZATION_ID

# Test policy before applying
gcloud resource-manager org-policies set-policy \
  policy.yaml \
  --organization=ORGANIZATION_ID \
  --dry-run
```

---

## Organization Structure

### Typical Organization Layout

```
┌────────────────────────────────────────────────────────────┐
│  Organization: company.com (ID: 123456789012)              │
└────────────────────────────────────────────────────────────┘
                            │
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼─────┐       ┌────▼─────┐       ┌────▼─────┐
   │Production│       │ Staging  │       │   Dev    │
   │  Folder  │       │  Folder  │       │  Folder  │
   └────┬─────┘       └────┬─────┘       └────┬─────┘
        │                  │                   │
   ┌────▼──────────┐  ┌───▼────────┐    ┌────▼─────────┐
   │ 50 Projects   │  │ 20 Projects│    │ 100 Projects │
   │               │  │            │    │              │
   │ Policies:     │  │ Policies:  │    │ Policies:    │
   │ • Strict      │  │ • Moderate │    │ • Relaxed    │
   │ • Audit logs  │  │ • Audit    │    │ • Minimal    │
   │ • No external │  │   logs     │    │   audit      │
   │   IPs         │  │ • Limited  │    │ • External   │
   │ • MFA req.    │  │   external │    │   IPs OK     │
   │               │  │   IPs      │    │              │
   └───────────────┘  └────────────┘    └──────────────┘

Organization-Level Policies:
  • Domain restriction (company.com only)
  • Require OS Login
  • Disable service account key upload
  • Restrict resource locations (US, EU only)

Organization-Level IAM:
  • Super Admins: 2 users
  • Organization Admins: 5 users
  • Organization Viewers: 10 users (auditors, compliance)
  • Billing Admins: 3 users
```

---

## Billing Integration

### Billing Account Association

```
┌────────────────────────────────────────────────────────┐
│  Organization Billing Structure                        │
└────────────────────────────────────────────────────────┘

Organization: company.com
│
├── Billing Account 1 (Production)
│   ├── Linked to Production folder projects
│   ├── Budget: $50,000/month
│   └── Alerts at 50%, 90%, 100%
│
├── Billing Account 2 (Non-Production)
│   ├── Linked to Dev/Staging projects
│   ├── Budget: $10,000/month
│   └── Alerts at 80%, 100%
│
└── Billing Account 3 (Shared Services)
    ├── Linked to networking, monitoring projects
    ├── Budget: $5,000/month
    └── Cost allocation by labels
```

### Billing Commands

```bash
# List billing accounts
gcloud billing accounts list

# Link billing account to project
gcloud billing projects link PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID

# Set up billing budget
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Production Budget" \
  --budget-amount=50000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100

# Export billing data to BigQuery
gcloud billing accounts get-iam-policy BILLING_ACCOUNT_ID
```

---

## Organization Migration

### Migrating Projects to Organization

```
┌────────────────────────────────────────────────────────┐
│  Migration Workflow                                    │
└────────────────────────────────────────────────────────┘

Before Migration:
┌─────────────────┐
│  Standalone     │
│  Projects       │
│  • project-1    │
│  • project-2    │
│  • project-3    │
└─────────────────┘

After Migration:
┌─────────────────────────────────┐
│  Organization: company.com      │
│  ├── Folder: Migrated Projects  │
│  │   ├── project-1              │
│  │   ├── project-2              │
│  │   └── project-3              │
└─────────────────────────────────┘
```

### Migration Steps

```bash
# 1. Verify organization exists
gcloud organizations list

# 2. Get project details
gcloud projects describe PROJECT_ID

# 3. Move project to organization
gcloud projects move PROJECT_ID \
  --organization=ORGANIZATION_ID

# 4. Move project to specific folder
gcloud projects move PROJECT_ID \
  --folder=FOLDER_ID

# 5. Verify migration
gcloud projects describe PROJECT_ID
```

### Migration Considerations

```
┌────────────────────────────────────────────────────────┐
│  Pre-Migration Checklist                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Backup project IAM policies                         │
│  ✓ Document current billing setup                      │
│  ✓ Review existing organization policies               │
│  ✓ Plan folder structure                               │
│  ✓ Communicate with stakeholders                       │
│  ✓ Test with non-critical project first                │
│  ✓ Verify IAM inheritance impact                       │
│  ✓ Check for policy conflicts                          │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Post-Migration Tasks                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Verify project access still works                   │
│  ✓ Check billing account linkage                       │
│  ✓ Review inherited policies                           │
│  ✓ Update documentation                                │
│  ✓ Train team on new structure                         │
└────────────────────────────────────────────────────────┘
```

---

## Multi-Organization Strategies

### When to Use Multiple Organizations

```
┌────────────────────────────────────────────────────────┐
│  Multiple Organization Scenarios                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. Separate Legal Entities                           │
│     • Different companies in a holding structure       │
│     • Separate billing and compliance requirements     │
│                                                         │
│  2. Acquisitions                                       │
│     • Acquired company maintains separate org          │
│     • Gradual integration over time                    │
│                                                         │
│  3. Regulatory Isolation                               │
│     • Strict data residency requirements               │
│     • Different compliance frameworks                  │
│                                                         │
│  4. Partner/Customer Environments                      │
│     • Managed services provider                        │
│     • Separate org per customer                        │
└────────────────────────────────────────────────────────┘
```

### Multi-Org Architecture

```
Holding Company Structure:

┌──────────────────────────────────────────────────────┐
│  Parent Company (Acme Holdings)                      │
└──────────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
   ┌────▼────┐   ┌───▼────┐   ┌───▼────┐
   │ Org 1   │   │ Org 2  │   │ Org 3  │
   │ Acme    │   │ Beta   │   │ Gamma  │
   │ Corp    │   │ Inc    │   │ LLC    │
   └─────────┘   └────────┘   └────────┘

Shared Services:
  • Separate organization for shared infrastructure
  • VPC peering or VPN between organizations
  • Centralized monitoring and logging
```

---

## Organization Monitoring

### Audit Logging

```bash
# Enable organization-level audit logs
gcloud logging sinks create org-audit-sink \
  storage.googleapis.com/org-audit-logs-bucket \
  --organization=ORGANIZATION_ID \
  --log-filter='logName:"cloudaudit.googleapis.com"'

# Query organization activity
gcloud logging read \
  'resource.type="organization" AND logName:"cloudaudit.googleapis.com/activity"' \
  --organization=ORGANIZATION_ID \
  --limit=50 \
  --format=json
```

### Activity Monitoring

```
┌────────────────────────────────────────────────────────┐
│  Organization Activity Dashboard                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Recent Changes:                                       │
│  • 10:15 AM - New folder created (Production)          │
│  • 10:12 AM - Organization policy updated              │
│  • 10:05 AM - IAM role granted to user                │
│  • 09:45 AM - Project moved to folder                  │
│                                                         │
│  Policy Violations:                                    │
│  • 2 projects with external IPs (policy violation)     │
│  • 1 service account key created (policy violation)    │
│                                                         │
│  Cost Alerts:                                          │
│  • Production folder: 85% of budget used               │
│  • Project xyz: Unusual spending spike detected        │
└────────────────────────────────────────────────────────┘
```

---

## Best Practices

### 1. Organization Setup

```
✓ Use Cloud Identity or Google Workspace
✓ Limit Super Admins to 2-3 trusted individuals
✓ Assign Organization Admins to IT team
✓ Enable 2FA/MFA for all admin accounts
✓ Use groups for role assignments
✓ Document organization structure
```

### 2. Policy Management

```
✓ Start with restrictive policies, relax as needed
✓ Test policies in dev environment first
✓ Document policy rationale
✓ Review policies quarterly
✓ Use policy inheritance effectively
✓ Monitor policy violations
```

### 3. Access Control

```
✓ Implement least privilege principle
✓ Use service accounts for automation
✓ Regular access reviews (quarterly)
✓ Audit organization-level permissions
✓ Use groups instead of individual users
✓ Enable audit logging
```

### 4. Billing Management

```
✓ Separate billing accounts by environment
✓ Set up budgets and alerts
✓ Export billing data to BigQuery
✓ Use labels for cost allocation
✓ Review spending monthly
✓ Implement cost optimization policies
```

---

## Troubleshooting

### Common Issues

```
Issue: Organization not visible
Solution:
  • Verify Cloud Identity/Workspace setup
  • Check domain verification status
  • Ensure you have Organization Viewer role
  • Wait 24-48 hours after domain verification

Issue: Cannot create organization
Solution:
  • Must have Cloud Identity or Google Workspace
  • Domain must be verified
  • Only one organization per domain
  • Contact Google Cloud support if needed

Issue: Policy not applying
Solution:
  • Check policy syntax
  • Verify policy inheritance
  • Check for conflicting policies at lower levels
  • Use policy analyzer tool
  • Wait for policy propagation (up to 15 minutes)

Issue: Cannot move project to organization
Solution:
  • Must have Organization Admin role
  • Project must not be in another organization
  • Check for billing account conflicts
  • Verify no policy violations
```

---

## Security Considerations

```
┌────────────────────────────────────────────────────────┐
│  Organization Security Checklist                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Enable MFA for all admin accounts                   │
│  ✓ Limit Super Admin access                            │
│  ✓ Use groups for role assignments                     │
│  ✓ Enable Cloud Audit Logs                             │
│  ✓ Set up Security Command Center                      │
│  ✓ Implement organization policies                     │
│  ✓ Regular access reviews                              │
│  ✓ Monitor for policy violations                       │
│  ✓ Incident response plan documented                   │
│  ✓ Backup critical configurations                      │
└────────────────────────────────────────────────────────┘
```

---

## Next Steps

After setting up your organization:

1. **Create Folder Structure** → [2-Folders.md](./2-Folders.md)
2. **Organize Projects** → [3-Projects.md](./3-Projects.md)
3. **Apply Policies** → [5-Organization-Policies.md](./5-Organization-Policies.md)
4. **Configure IAM** → [6-IAM-Hierarchy.md](./6-IAM-Hierarchy.md)

---
