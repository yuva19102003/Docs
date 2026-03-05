# IAM in Resource Hierarchy

## Overview

IAM (Identity and Access Management) integrates deeply with GCP's resource hierarchy, allowing you to grant permissions at different levels that automatically inherit down the tree. Understanding IAM hierarchy is crucial for implementing least privilege and efficient access control.

---

## Table of Contents

1. [IAM Hierarchy Fundamentals](#iam-hierarchy-fundamentals)
2. [Permission Inheritance](#permission-inheritance)
3. [IAM at Each Level](#iam-at-each-level)
4. [Best Practices](#best-practices)
5. [Common Patterns](#common-patterns)
6. [Troubleshooting](#troubleshooting)

---

## IAM Hierarchy Fundamentals

### How IAM Works in Hierarchy

```
Organization
├─ IAM Policy: viewer@company.com = roles/viewer
│  └─ Grants view access to EVERYTHING below
│
├─ Folder: Production
│  ├─ IAM Policy: prod-team@company.com = roles/editor
│  │  └─ Grants edit access to all production projects
│  │
│  └─ Project: prod-web
│     ├─ Inherits: viewer@company.com (viewer)
│     ├─ Inherits: prod-team@company.com (editor)
│     └─ IAM Policy: web-admin@company.com = roles/compute.admin
│        └─ Grants compute admin only for this project
│
└─ Folder: Development
   └─ Project: dev-sandbox
      ├─ Inherits: viewer@company.com (viewer)
      └─ IAM Policy: dev-team@company.com = roles/owner
         └─ Full control of dev project
```

### Key Concepts

**Policy Inheritance**
- Permissions granted at higher levels flow down
- Cannot be revoked at lower levels
- Additive only (more permissive wins)

**Effective Permissions**
- Union of all inherited and direct permissions
- Most permissive permission applies

---

## Permission Inheritance

### Inheritance Flow

```bash
# Check effective IAM policy
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --format="table(bindings.role, bindings.members)"

# Check inherited permissions
gcloud projects get-ancestors-iam-policy PROJECT_ID
```

### Example Scenario

```
Organization: company.com
├─ alice@company.com = roles/viewer (Org level)
│
├─ Folder: Engineering
│  ├─ bob@company.com = roles/editor (Folder level)
│  │
│  └─ Project: eng-prod
│     └─ charlie@company.com = roles/compute.admin (Project level)

Effective Permissions:
- alice: Can view all resources in organization
- bob: Can edit all resources in Engineering folder
- charlie: Can manage Compute Engine in eng-prod project
- alice in eng-prod: viewer (inherited from org)
- bob in eng-prod: editor (inherited from folder)
```

---

## IAM at Each Level

### Organization Level

```bash
# Grant organization-level role
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="user:admin@company.com" \
    --role="roles/resourcemanager.organizationAdmin"

# Common organization roles
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="group:security-team@company.com" \
    --role="roles/securitycenter.admin"

gcloud organizations add-iam-policy-binding ORG_ID \
    --member="group:billing-team@company.com" \
    --role="roles/billing.admin"
```

### Folder Level

```bash
# Grant folder-level role
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
    --member="group:prod-team@company.com" \
    --role="roles/editor"

# Grant to all projects in folder
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
    --member="group:sre-team@company.com" \
    --role="roles/monitoring.viewer"
```

### Project Level

```bash
# Grant project-level role
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:developer@company.com" \
    --role="roles/editor"

# Grant specific service role
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"
```

### Resource Level

```bash
# Grant access to specific resource (Cloud Storage bucket)
gsutil iam ch user:user@company.com:objectViewer gs://my-bucket

# Grant access to Compute Engine instance
gcloud compute instances add-iam-policy-binding INSTANCE_NAME \
    --zone=ZONE \
    --member="user:admin@company.com" \
    --role="roles/compute.instanceAdmin"
```

---

## Best Practices

### 1. Grant at Appropriate Level

✓ **Organization Level**
- Security team (Security Admin)
- Billing team (Billing Admin)
- Auditors (Viewer)

✓ **Folder Level**
- Department teams (Editor for their folder)
- Environment-specific roles (Prod vs Dev)

✓ **Project Level**
- Application-specific access
- Service accounts
- Individual developers

✓ **Resource Level**
- Fine-grained access
- Temporary access
- External users

### 2. Use Groups

```bash
# Create groups for teams
# In Google Workspace Admin Console:
# - engineering@company.com
# - marketing@company.com
# - sre@company.com

# Grant to groups instead of individuals
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="group:engineering@company.com" \
    --role="roles/editor"
```

### 3. Principle of Least Privilege

```bash
# ❌ Bad: Granting owner at organization level
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="user:developer@company.com" \
    --role="roles/owner"

# ✓ Good: Grant specific role at project level
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:developer@company.com" \
    --role="roles/compute.instanceAdmin"
```

### 4. Regular Audits

```python
# Audit IAM permissions
from google.cloud import asset_v1

def audit_iam_permissions(organization_id):
    """
    Audit all IAM permissions in organization
    """
    client = asset_v1.AssetServiceClient()
    
    # Search for all IAM policies
    request = asset_v1.SearchAllIamPoliciesRequest(
        scope=f"organizations/{organization_id}"
    )
    
    policies = client.search_all_iam_policies(request=request)
    
    print("IAM Audit Report")
    print("=" * 80)
    
    for policy in policies:
        print(f"\nResource: {policy.resource}")
        print(f"Policy:")
        for binding in policy.policy.bindings:
            print(f"  Role: {binding.role}")
            for member in binding.members:
                print(f"    Member: {member}")

audit_iam_permissions("123456789")
```

---

## Common Patterns

### Pattern 1: Environment Separation

```
Organization
│
├─ Folder: Production
│  ├─ IAM: prod-team@company.com = roles/viewer
│  ├─ IAM: prod-sre@company.com = roles/editor
│  └─ Projects: prod-*
│
├─ Folder: Staging
│  ├─ IAM: engineering@company.com = roles/editor
│  └─ Projects: staging-*
│
└─ Folder: Development
   ├─ IAM: engineering@company.com = roles/owner
   └─ Projects: dev-*
```

### Pattern 2: Team-Based Access

```
Organization
│
├─ Folder: Engineering
│  ├─ IAM: engineering@company.com = roles/editor
│  └─ Projects: eng-*
│
├─ Folder: Marketing
│  ├─ IAM: marketing@company.com = roles/editor
│  └─ Projects: mkt-*
│
└─ Folder: Data Science
   ├─ IAM: data-science@company.com = roles/editor
   └─ Projects: ds-*
```

### Pattern 3: Shared Services

```
Organization
│
├─ Folder: Shared Services
│  ├─ Project: shared-monitoring
│  │  └─ IAM: all-engineers@company.com = roles/monitoring.viewer
│  │
│  ├─ Project: shared-networking
│  │  └─ IAM: network-team@company.com = roles/compute.networkAdmin
│  │
│  └─ Project: shared-security
│     └─ IAM: security-team@company.com = roles/securitycenter.admin
│
└─ Other folders/projects inherit access to shared services
```

---

## Troubleshooting

### Check Effective Permissions

```bash
# Check what permissions a user has
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:alice@company.com" \
    --format="table(bindings.role)"

# Check all members with a specific role
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.role:roles/editor" \
    --format="table(bindings.members)"
```

### Test Permissions

```bash
# Test if user has permission
gcloud projects test-iam-permissions PROJECT_ID \
    --permissions=compute.instances.create,compute.instances.delete

# Check service account permissions
gcloud projects test-iam-permissions PROJECT_ID \
    --permissions=storage.buckets.get \
    --impersonate-service-account=SA_EMAIL
```

---

## Summary

IAM in resource hierarchy provides:
- Centralized access management
- Automatic permission inheritance
- Flexible access control
- Scalable security model

### Quick Reference

```bash
# Organization level
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="user:USER" --role="ROLE"

# Folder level
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
    --member="group:GROUP" --role="ROLE"

# Project level
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:SA" --role="ROLE"

# Check effective policy
gcloud projects get-iam-policy PROJECT_ID
```

---

## Next Steps

- [Tags & Labels](./7-Tags-Labels.md) - Resource organization
- [Best Practices](./8-Best-Practices.md) - Governance best practices
- [IAM Fundamentals](../4️⃣%20Identity%20&%20Access%20Management/1-IAM-Fundamentals.md) - Deep dive into IAM

---

**Last Updated:** March 2026
