# IAM Roles

Complete guide to understanding, using, and managing IAM roles in Google Cloud Platform.

---

## 📚 Overview

IAM roles are collections of permissions that determine what actions can be performed on GCP resources. Understanding roles is fundamental to implementing secure access control.

**Key Concepts:**
- **Roles**: Collections of permissions
- **Permissions**: Fine-grained access controls (e.g., `compute.instances.create`)
- **Role Types**: Basic, Predefined, Custom
- **Role Binding**: Assigning roles to members

---

## 🎯 Role Types

### 1. Basic Roles (Legacy - Not Recommended)

```
┌────────────────────────────────────────────────────────┐
│  Basic Roles (Primitive Roles)                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/viewer (Viewer)                                 │
│  • Read-only access to all resources                   │
│  • Cannot modify anything                              │
│  • Can view configurations                             │
│  • ~2,000 permissions                                  │
│                                                         │
│  Use Cases:                                            │
│  • Auditors                                            │
│  • Read-only stakeholders                              │
│  • Monitoring systems                                  │
│                                                         │
│  ─────────────────────────────────────────────────     │
│                                                         │
│  roles/editor (Editor)                                 │
│  • All Viewer permissions                              │
│  • Can create, modify, delete resources                │
│  • Cannot manage IAM or billing                        │
│  • ~3,000+ permissions                                 │
│                                                         │
│  Use Cases:                                            │
│  • Developers (not recommended)                        │
│  • Operations teams (not recommended)                  │
│  • Use predefined roles instead                        │
│                                                         │
│  ─────────────────────────────────────────────────     │
│                                                         │
│  roles/owner (Owner)                                   │
│  • All Editor permissions                              │
│  • Can manage IAM policies                             │
│  • Can manage billing                                  │
│  • Can delete projects                                 │
│  • Full control                                        │
│                                                         │
│  Use Cases:                                            │
│  • Project administrators                              │
│  • Very limited assignment                             │
│  • High-risk role                                      │
│                                                         │
│  ⚠️  WARNING: Basic roles are too permissive           │
│  ✓  Use predefined roles instead                       │
│  ✓  Follow principle of least privilege                │
└────────────────────────────────────────────────────────┘
```

### 2. Predefined Roles (Recommended)

```
┌────────────────────────────────────────────────────────┐
│  Predefined Roles Overview                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  What: Curated by Google for specific services         │
│  Count: 3,000+ roles available                         │
│  Maintenance: Updated by Google automatically          │
│  Granularity: Service-specific permissions             │
│                                                         │
│  Benefits:                                             │
│  ✓ Fine-grained access control                         │
│  ✓ Regularly updated with new features                 │
│  ✓ Follow best practices                               │
│  ✓ Reduce security risks                               │
│  ✓ Easier to audit                                     │
│                                                         │
│  Naming Convention:                                    │
│  roles/[SERVICE].[ROLE_NAME]                           │
│                                                         │
│  Examples:                                             │
│  • roles/compute.instanceAdmin.v1                      │
│  • roles/storage.objectViewer                          │
│  • roles/bigquery.dataEditor                           │
│  • roles/iam.serviceAccountUser                        │
└────────────────────────────────────────────────────────┘
```

#### Common Predefined Roles by Service

**Compute Engine:**
```
┌────────────────────────────────────────────────────────┐
│  Compute Engine Roles                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/compute.viewer                                  │
│  • View all Compute Engine resources                   │
│  • Cannot modify anything                              │
│  • Read-only access                                    │
│                                                         │
│  roles/compute.instanceAdmin.v1                        │
│  • Create, modify, delete VM instances                 │
│  • Start, stop, reset instances                        │
│  • Attach/detach disks                                 │
│  • Does NOT include network admin                      │
│                                                         │
│  roles/compute.networkAdmin                            │
│  • Manage networks, subnets, firewall rules            │
│  • Create/delete VPCs                                  │
│  • Configure load balancers                            │
│  • Does NOT include VM management                      │
│                                                         │
│  roles/compute.securityAdmin                           │
│  • Manage firewall rules                               │
│  • Manage SSL certificates                             │
│  • Security-focused permissions                        │
│                                                         │
│  roles/compute.storageAdmin                            │
│  • Manage disks, snapshots, images                     │
│  • Create/delete persistent disks                      │
│  • Manage disk snapshots                               │
└────────────────────────────────────────────────────────┘
```

**Cloud Storage:**
```
┌────────────────────────────────────────────────────────┐
│  Cloud Storage Roles                                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/storage.objectViewer                            │
│  • Read objects and metadata                           │
│  • List objects in buckets                             │
│  • Download files                                      │
│                                                         │
│  roles/storage.objectCreator                           │
│  • Upload objects                                      │
│  • Cannot read or delete                               │
│  • Write-only access                                   │
│                                                         │
│  roles/storage.objectAdmin                             │
│  • Full control over objects                           │
│  • Create, read, update, delete                        │
│  • Manage object metadata                              │
│                                                         │
│  roles/storage.admin                                   │
│  • Full control over buckets and objects               │
│  • Create/delete buckets                               │
│  • Manage bucket IAM                                   │
│  • Configure bucket settings                           │
└────────────────────────────────────────────────────────┘
```

**BigQuery:**
```
┌────────────────────────────────────────────────────────┐
│  BigQuery Roles                                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/bigquery.dataViewer                             │
│  • Read dataset metadata and table data                │
│  • Run queries (if have job permissions)               │
│  • Cannot modify data                                  │
│                                                         │
│  roles/bigquery.dataEditor                             │
│  • Read and modify data                                │
│  • Create, update, delete tables                       │
│  • Insert, update, delete rows                         │
│                                                         │
│  roles/bigquery.user                                   │
│  • Run queries                                         │
│  • Create datasets in own project                      │
│  • List all datasets                                   │
│                                                         │
│  roles/bigquery.admin                                  │
│  • Full control over BigQuery resources                │
│  • Manage datasets, tables, jobs                       │
│  • Configure billing                                   │
└────────────────────────────────────────────────────────┘
```

**Kubernetes Engine (GKE):**
```
┌────────────────────────────────────────────────────────┐
│  GKE Roles                                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/container.viewer                                │
│  • View clusters and Kubernetes resources              │
│  • Read-only access                                    │
│                                                         │
│  roles/container.developer                             │
│  • View clusters                                       │
│  • Deploy applications                                 │
│  • View logs                                           │
│  • Cannot modify cluster configuration                 │
│                                                         │
│  roles/container.clusterAdmin                          │
│  • Full control over clusters                          │
│  • Create, modify, delete clusters                     │
│  • Manage node pools                                   │
│  • Configure cluster settings                          │
│                                                         │
│  roles/container.admin                                 │
│  • Full control over GKE and Kubernetes resources      │
│  • Manage clusters and workloads                       │
│  • Highest level of access                             │
└────────────────────────────────────────────────────────┘
```

**Cloud SQL:**
```
┌────────────────────────────────────────────────────────┐
│  Cloud SQL Roles                                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/cloudsql.viewer                                 │
│  • View instances and configurations                   │
│  • Cannot connect or modify                            │
│                                                         │
│  roles/cloudsql.client                                 │
│  • Connect to instances                                │
│  • Use Cloud SQL Proxy                                 │
│  • Cannot modify instances                             │
│                                                         │
│  roles/cloudsql.editor                                 │
│  • Modify instances                                    │
│  • Create databases and users                          │
│  • Cannot delete instances                             │
│                                                         │
│  roles/cloudsql.admin                                  │
│  • Full control over Cloud SQL                         │
│  • Create, modify, delete instances                    │
│  • Manage backups and replicas                         │
└────────────────────────────────────────────────────────┘
```

### 3. Custom Roles

```
┌────────────────────────────────────────────────────────┐
│  Custom Roles                                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  What: User-defined roles with specific permissions    │
│  Scope: Organization or Project level                  │
│  Use Case: When predefined roles don't fit needs       │
│                                                         │
│  Benefits:                                             │
│  ✓ Tailored to exact requirements                      │
│  ✓ Implement least privilege precisely                 │
│  ✓ Combine permissions from multiple services          │
│                                                         │
│  Limitations:                                          │
│  ✗ You must maintain and update                        │
│  ✗ Not automatically updated by Google                 │
│  ✗ More complex to manage                              │
│  ✗ Cannot use in some scenarios                        │
│                                                         │
│  Best Practices:                                       │
│  ✓ Use predefined roles when possible                  │
│  ✓ Document custom role purpose                        │
│  ✓ Regular review and updates                          │
│  ✓ Test thoroughly before deployment                   │
│  ✓ Version control role definitions                    │
└────────────────────────────────────────────────────────┘
```

---

## 🔍 Understanding Permissions

### Permission Structure

```
┌────────────────────────────────────────────────────────┐
│  Permission Naming Convention                          │
└────────────────────────────────────────────────────────┘

Format: [SERVICE].[RESOURCE].[VERB]

Examples:
  compute.instances.create
  ├─ compute: Service (Compute Engine)
  ├─ instances: Resource type
  └─ create: Action/verb

  storage.buckets.delete
  ├─ storage: Service (Cloud Storage)
  ├─ buckets: Resource type
  └─ delete: Action/verb

  bigquery.datasets.get
  ├─ bigquery: Service
  ├─ datasets: Resource type
  └─ get: Action/verb

Common Verbs:
  • get: Read single resource
  • list: List resources
  • create: Create new resource
  • update: Modify existing resource
  • delete: Remove resource
  • use: Use resource
  • setIamPolicy: Modify IAM policy
```

### Viewing Role Permissions

```bash
# List all roles
gcloud iam roles list

# Describe specific role
gcloud iam roles describe roles/compute.instanceAdmin.v1

# Output shows:
# - Role name and title
# - Description
# - All included permissions
# - Stage (GA, BETA, ALPHA)

# Example output:
description: Full control of Compute Engine instances
includedPermissions:
- compute.instances.create
- compute.instances.delete
- compute.instances.get
- compute.instances.list
- compute.instances.start
- compute.instances.stop
- compute.instances.update
# ... (100+ permissions)

# Search for specific permission
gcloud iam roles list --filter="includedPermissions:compute.instances.create"

# List permissions for a service
gcloud iam list-testable-permissions //cloudresourcemanager.googleapis.com/projects/PROJECT_ID
```

---

## 🛠️ Working with Roles

### 1. Granting Roles

```bash
# Grant role to user at project level
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Grant role to group
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:my-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Grant role at organization level
gcloud organizations add-iam-policy-binding ORG_ID \
  --member='user:admin@company.com' \
  --role='roles/resourcemanager.organizationAdmin'

# Grant role at folder level
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member='user:manager@company.com' \
  --role='roles/resourcemanager.folderEditor'

# Grant role with condition (time-bound)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Temporary Access,description=Expires end of 2026'
```

### 2. Removing Roles

```bash
# Remove role from user
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Remove all roles from a member
# First, get current policy
gcloud projects get-iam-policy PROJECT_ID --format=json > policy.json

# Edit policy.json to remove member
# Then set the policy
gcloud projects set-iam-policy PROJECT_ID policy.json
```

### 3. Viewing Role Assignments

```bash
# Get IAM policy for project
gcloud projects get-iam-policy PROJECT_ID

# Get policy in readable format
gcloud projects get-iam-policy PROJECT_ID \
  --format='table(bindings.role,bindings.members.flatten())'

# Filter by specific member
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:alice@company.com" \
  --format="table(bindings.role)"

# Check what roles a service account has
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:my-sa@PROJECT_ID.iam.gserviceaccount.com"
```

---

## 🎨 Creating Custom Roles

### 1. Define Custom Role

```yaml
# custom-role.yaml
title: "Custom VM Operator"
description: "Can start, stop, and view VMs but not create or delete"
stage: "GA"
includedPermissions:
- compute.instances.get
- compute.instances.list
- compute.instances.start
- compute.instances.stop
- compute.instances.reset
- compute.zones.list
- compute.zones.get
```

### 2. Create Custom Role

```bash
# Create at project level
gcloud iam roles create customVmOperator \
  --project=PROJECT_ID \
  --file=custom-role.yaml

# Create at organization level
gcloud iam roles create customVmOperator \
  --organization=ORG_ID \
  --file=custom-role.yaml

# Create with gcloud flags (without YAML)
gcloud iam roles create customVmOperator \
  --project=PROJECT_ID \
  --title="Custom VM Operator" \
  --description="Can start, stop, and view VMs" \
  --permissions=compute.instances.get,compute.instances.list,compute.instances.start,compute.instances.stop \
  --stage=GA
```

### 3. Update Custom Role

```bash
# Update role from file
gcloud iam roles update customVmOperator \
  --project=PROJECT_ID \
  --file=custom-role-updated.yaml

# Add permissions
gcloud iam roles update customVmOperator \
  --project=PROJECT_ID \
  --add-permissions=compute.instances.suspend,compute.instances.resume

# Remove permissions
gcloud iam roles update customVmOperator \
  --project=PROJECT_ID \
  --remove-permissions=compute.instances.reset
```

### 4. Delete Custom Role

```bash
# Soft delete (can be undeleted within 7 days)
gcloud iam roles delete customVmOperator \
  --project=PROJECT_ID

# Undelete within 7 days
gcloud iam roles undelete customVmOperator \
  --project=PROJECT_ID

# Permanent delete (after 37 days of soft delete)
# Happens automatically
```

---

## 📊 Role Comparison Examples

### Example 1: Developer Access Patterns

```
┌────────────────────────────────────────────────────────┐
│  Developer Role Comparison                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ❌ Bad: roles/editor                                  │
│  • 3,000+ permissions                                  │
│  • Can modify almost everything                        │
│  • Can't manage IAM (good)                             │
│  • Too broad for most developers                       │
│                                                         │
│  ✓ Better: Combination of specific roles               │
│  • roles/compute.instanceAdmin.v1                      │
│  • roles/storage.objectAdmin                           │
│  • roles/cloudsql.client                               │
│  • Total: ~300 permissions                             │
│  • Covers typical developer needs                      │
│                                                         │
│  ✓✓ Best: Custom role for your workflow                │
│  • Exactly what developers need                        │
│  • Nothing more, nothing less                          │
│  • Total: ~50-100 permissions                          │
│  • Requires maintenance                                │
└────────────────────────────────────────────────────────┘
```

### Example 2: Read-Only Access

```
┌────────────────────────────────────────────────────────┐
│  Read-Only Access Comparison                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  roles/viewer (Basic Role)                             │
│  • View ALL resources in project                       │
│  • ~2,000 permissions                                  │
│  • May see sensitive data                              │
│  • Too broad for specific needs                        │
│                                                         │
│  Service-Specific Viewer Roles:                        │
│  • roles/compute.viewer (only Compute Engine)          │
│  • roles/storage.objectViewer (only Storage)           │
│  • roles/bigquery.dataViewer (only BigQuery)           │
│  • More granular control                               │
│  • Limit exposure                                      │
└────────────────────────────────────────────────────────┘
```

---

## 🔐 Role Best Practices

### 1. Principle of Least Privilege

```
✓ Start with minimal permissions
✓ Grant only what's needed for the job
✓ Use predefined roles over basic roles
✓ Create custom roles for specific needs
✓ Regular permission reviews
✓ Remove unused permissions
✓ Use groups instead of individual users
✓ Document why roles are granted
```

### 2. Role Selection Guide

```
Decision Tree:
┌─────────────────────────────────────────────────────┐
│ Need to grant access?                               │
└────────────┬────────────────────────────────────────┘
             │
             ▼
    ┌────────────────────┐
    │ Is there a         │  YES → Use predefined role
    │ predefined role?   │        (Recommended)
    └────────┬───────────┘
             │ NO
             ▼
    ┌────────────────────┐
    │ Can you combine    │  YES → Grant multiple
    │ predefined roles?  │        predefined roles
    └────────┬───────────┘
             │ NO
             ▼
    ┌────────────────────┐
    │ Create custom role │
    │ (Document well)    │
    └────────────────────┘

Never use basic roles (Owner, Editor, Viewer) in production!
```

### 3. Role Naming Conventions

```
Custom Role Naming:
  Format: [TEAM]_[FUNCTION]_[SCOPE]
  
  Examples:
  • backend_developer_compute
  • data_analyst_bigquery
  • devops_deployer_gke
  • security_auditor_org

Benefits:
  ✓ Easy to identify purpose
  ✓ Clear ownership
  ✓ Searchable and filterable
  ✓ Consistent across organization
```

### 4. Role Documentation Template

```markdown
# Custom Role: backend_developer_compute

## Purpose
Allow backend developers to manage compute instances for development

## Permissions
- compute.instances.create
- compute.instances.delete
- compute.instances.get
- compute.instances.list
- compute.instances.start
- compute.instances.stop

## Scope
Project: dev-backend-2026

## Assigned To
- Group: backend-developers@company.com

## Review Schedule
Quarterly (every 3 months)

## Last Updated
2026-03-04

## Change Log
- 2026-03-04: Initial creation
- 2026-02-15: Added instances.stop permission
```

---

## 🧪 Testing Roles

### 1. Policy Simulator

```bash
# Test if member has permission
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.create,compute.instances.delete

# Output shows which permissions you have

# Test as different user (requires Policy Troubleshooter API)
# Use Console: IAM → Policy Troubleshooter
```

### 2. Impersonation for Testing

```bash
# Impersonate service account to test permissions
gcloud compute instances list \
  --impersonate-service-account=test-sa@PROJECT_ID.iam.gserviceaccount.com

# If successful, service account has list permission
# If fails, permission is missing
```

---

## 📈 Role Analytics

### 1. IAM Recommender

```bash
# Get role recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global

# Shows:
# - Over-permissioned roles
# - Unused permissions
# - Recommended replacements
```

### 2. Policy Analyzer

```bash
# Analyze who has access to what
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --full-resource-name="//compute.googleapis.com/projects/PROJECT_ID/zones/us-central1-a/instances/my-vm"

# Shows all members with access to the VM
```

---

## 🎓 Next Steps

1. Learn about [Service Accounts](./3-Service-Accounts.md) for application identity
2. Understand [IAM Policies](./4-IAM-Policies.md) structure and management
3. Implement [Least Privilege](./5-Least-Privilege.md) principles
4. Explore [Advanced IAM](./7-Advanced-IAM.md) features

---

**Last Updated:** March 2026
**Version:** 2.0
