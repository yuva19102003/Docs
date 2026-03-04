# 1. IAM Fundamentals

Understanding the core concepts of Google Cloud Identity and Access Management.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  IAM Core Model: WHO can do WHAT on WHICH resource    │
├────────────────────────────────────────────────────────┤
│                                                         │
│  WHO (Identity/Member)                                 │
│  • Google Account (user)                               │
│  • Google Group                                        │
│  • Service Account                                     │
│  • Cloud Identity domain                               │
│                                                         │
│  WHAT (Role)                                           │
│  • Collection of permissions                           │
│  • Basic, Predefined, or Custom                        │
│  • Defines allowed actions                             │
│                                                         │
│  WHICH (Resource)                                      │
│  • Organization, Folder, Project                       │
│  • Specific resources (VM, bucket, etc.)               │
│  • Hierarchy determines scope                          │
└────────────────────────────────────────────────────────┘
```

---

## IAM Components

### 1. Members (Identity)

```
┌────────────────────────────────────────────────────────┐
│  Member Types                                          │
└────────────────────────────────────────────────────────┘

Google Account (user:)
├─ Format: user:alice@company.com
├─ Individual person
├─ Gmail or Cloud Identity
└─ Human user authentication

Google Group (group:)
├─ Format: group:developers@company.com
├─ Collection of users
├─ Managed in Google Groups
└─ Recommended for team access

Service Account (serviceAccount:)
├─ Format: serviceAccount:app@project.iam.gserviceaccount.com
├─ Non-human identity
├─ For applications and workloads
└─ Programmatic access

Cloud Identity Domain (domain:)
├─ Format: domain:company.com
├─ All users in organization
├─ Requires Cloud Identity/Workspace
└─ Organization-wide grants

Special Identifiers:
├─ allUsers (anyone on internet)
├─ allAuthenticatedUsers (any Google Account)
└─ Use with extreme caution!
```

### 2. Roles (Permissions)

```
┌────────────────────────────────────────────────────────┐
│  Role Structure                                        │
└────────────────────────────────────────────────────────┘

Role: roles/compute.instanceAdmin.v1
│
├─ Title: Compute Instance Admin (v1)
│
├─ Description: Full control of Compute Engine instances
│
├─ Permissions: (100+ permissions)
│  ├─ compute.instances.create
│  ├─ compute.instances.delete
│  ├─ compute.instances.get
│  ├─ compute.instances.list
│  ├─ compute.instances.start
│  ├─ compute.instances.stop
│  └─ ... (and many more)
│
├─ Stage: GA (General Availability)
│
└─ Included In:
   ├─ roles/compute.admin
   └─ roles/editor
```

### 3. Permissions

```
┌────────────────────────────────────────────────────────┐
│  Permission Format                                     │
└────────────────────────────────────────────────────────┘

service.resource.verb

Examples:
  compute.instances.create
  │       │         │
  │       │         └─ Action (create, delete, get, list)
  │       └─ Resource type (instances, disks, networks)
  └─ Service (compute, storage, iam)

More Examples:
  storage.buckets.create
  storage.objects.get
  iam.serviceAccounts.create
  bigquery.datasets.get
  pubsub.topics.publish

Permission Characteristics:
  • Granular (specific actions)
  • Service-specific
  • Cannot be granted directly
  • Must be part of a role
  • 10,000+ permissions available
```

---

## IAM Policy

### Policy Structure

```json
{
  "version": 3,
  "etag": "BwXhFJ5H8nY=",
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "user:alice@company.com",
        "group:devops@company.com"
      ]
    },
    {
      "role": "roles/storage.objectViewer",
      "members": [
        "serviceAccount:app@project.iam.gserviceaccount.com"
      ],
      "condition": {
        "title": "Expires end of 2026",
        "description": "Temporary access for migration",
        "expression": "request.time < timestamp('2026-12-31T23:59:59Z')"
      }
    },
    {
      "role": "roles/viewer",
      "members": [
        "group:everyone@company.com"
      ]
    }
  ]
}
```

### Policy Components

```
┌────────────────────────────────────────────────────────┐
│  Policy Anatomy                                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  version: Policy schema version                        │
│  • 1: Basic policies                                   │
│  • 3: Policies with conditions (recommended)           │
│                                                         │
│  etag: Concurrency control                             │
│  • Prevents concurrent modifications                   │
│  • Must match for updates                              │
│                                                         │
│  bindings: Array of role assignments                   │
│  • role: The role being granted                        │
│  • members: Who gets the role                          │
│  • condition: Optional access constraints              │
│                                                         │
│  auditConfigs: Audit logging configuration             │
│  • Service-specific audit settings                     │
│  • Log types (ADMIN_READ, DATA_READ, DATA_WRITE)      │
└────────────────────────────────────────────────────────┘
```

---

## Policy Inheritance

### Hierarchy Example

```
┌────────────────────────────────────────────────────────────┐
│  Policy Inheritance in Action                              │
└────────────────────────────────────────────────────────────┘

Organization: company.com
Policy:
  - alice@company.com → roles/viewer
  - security@company.com → roles/securityReviewer
│
├─ Folder: Production
│  Policy:
│    - devops@company.com → roles/editor
│    - bob@company.com → roles/compute.admin
│  │
│  ├─ Project: web-prod
│  │  Policy:
│  │    - charlie@company.com → roles/owner
│  │    - app@web-prod.iam.gserviceaccount.com → roles/storage.objectViewer
│  │  │
│  │  └─ Resource: VM Instance (web-server-1)
│  │     Policy:
│  │       - dave@company.com → roles/compute.instanceAdmin.v1

Effective Permissions on web-server-1:
┌──────────────────────────────────────────────────────┐
│ User                  │ Effective Role              │
├──────────────────────────────────────────────────────┤
│ alice@company.com     │ Viewer (from org)           │
│ security@company.com  │ Security Reviewer (from org)│
│ devops@company.com    │ Editor (from folder)        │
│ bob@company.com       │ Compute Admin (from folder) │
│ charlie@company.com   │ Owner (from project)        │
│ dave@company.com      │ Instance Admin (from VM)    │
└──────────────────────────────────────────────────────┘

Key Points:
  ✓ All parent permissions inherited
  ✓ Permissions are cumulative (union)
  ✓ More permissive wins
  ✓ Cannot remove inherited permissions
  ✗ Child cannot override parent (use Deny policies)
```

---

## Permission Evaluation

### Allow Policy Evaluation

```
┌────────────────────────────────────────────────────────┐
│  Permission Check Flow                                 │
└────────────────────────────────────────────────────────┘

Request: alice@company.com wants to compute.instances.start
Resource: projects/web-prod/zones/us-central1-a/instances/web-1

Step 1: Collect all policies
├─ Organization policy
├─ Folder policy
├─ Project policy
└─ Resource policy

Step 2: Merge all bindings
├─ Combine all role assignments
└─ Create union of permissions

Step 3: Check conditions (if any)
├─ Evaluate IAM conditions
├─ Check time constraints
├─ Check resource attributes
└─ Check request context

Step 4: Evaluate deny policies (if any)
├─ Check organization deny policies
├─ Deny takes precedence over allow
└─ If denied, request is rejected

Step 5: Check if permission exists
├─ Does any role include compute.instances.start?
├─ Are all conditions met?
└─ Is it not explicitly denied?

Result:
  ✓ ALLOW: Permission found and conditions met
  ✗ DENY: Permission not found or denied
```

---

## IAM Best Practices

### 1. Use Groups

```
┌────────────────────────────────────────────────────────┐
│  Group-Based Access Management                         │
└────────────────────────────────────────────────────────┘

❌ Bad Practice:
gcloud projects add-iam-policy-binding web-prod \
  --member='user:alice@company.com' \
  --role='roles/editor'

gcloud projects add-iam-policy-binding web-prod \
  --member='user:bob@company.com' \
  --role='roles/editor'

gcloud projects add-iam-policy-binding web-prod \
  --member='user:charlie@company.com' \
  --role='roles/editor'

Problems:
  • Hard to manage individual users
  • Difficult to audit
  • Error-prone
  • Doesn't scale

✅ Good Practice:
# Create group: developers@company.com
# Add alice, bob, charlie to group

gcloud projects add-iam-policy-binding web-prod \
  --member='group:developers@company.com' \
  --role='roles/editor'

Benefits:
  ✓ Single policy binding
  ✓ Easy to add/remove users
  ✓ Clear team structure
  ✓ Scales well
  ✓ Easier auditing
```

### 2. Least Privilege

```
┌────────────────────────────────────────────────────────┐
│  Principle of Least Privilege                          │
└────────────────────────────────────────────────────────┘

❌ Bad: Overly Permissive
gcloud projects add-iam-policy-binding web-prod \
  --member='serviceAccount:app@web-prod.iam.gserviceaccount.com' \
  --role='roles/editor'

Problems:
  • Can modify ANY resource
  • Can create/delete VMs, databases, etc.
  • Security risk
  • Compliance issues

✅ Good: Minimal Permissions
gcloud projects add-iam-policy-binding web-prod \
  --member='serviceAccount:app@web-prod.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

gcloud projects add-iam-policy-binding web-prod \
  --member='serviceAccount:app@web-prod.iam.gserviceaccount.com' \
  --role='roles/cloudsql.client'

Benefits:
  ✓ Only necessary permissions
  ✓ Reduced security risk
  ✓ Easier to audit
  ✓ Compliance friendly
```

### 3. Use Predefined Roles

```
┌────────────────────────────────────────────────────────┐
│  Role Selection Priority                               │
└────────────────────────────────────────────────────────┘

Priority Order:
1. Predefined Roles (Recommended)
   ├─ Curated by Google
   ├─ Regularly updated
   ├─ Well-documented
   └─ Example: roles/compute.instanceAdmin.v1

2. Custom Roles (When needed)
   ├─ Specific permission combinations
   ├─ Not available in predefined
   └─ Requires maintenance

3. Basic Roles (Avoid)
   ├─ Too permissive
   ├─ Legacy
   └─ Use only for testing

Example:
  ❌ roles/editor (basic role - too broad)
  ✅ roles/compute.instanceAdmin.v1 (predefined - specific)
  ✅ custom.myAppRole (custom - tailored)
```

---

## Managing IAM Policies

### View Policies

```bash
# Get project IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Get policy in JSON format
gcloud projects get-iam-policy PROJECT_ID \
  --format=json

# Get policy for specific member
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:alice@company.com"

# Get policy for specific role
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/editor"
```

### Add Policy Binding

```bash
# Grant role to user
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/viewer'

# Grant role to group
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Grant with condition
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@external.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Expires 2026,description=Temporary contractor access'
```

### Remove Policy Binding

```bash
# Remove role from user
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/viewer'

# Remove all bindings for a member
gcloud projects get-iam-policy PROJECT_ID \
  --format=json > policy.json

# Edit policy.json to remove member
# Then set the policy
gcloud projects set-iam-policy PROJECT_ID policy.json
```

---

## IAM Conditions

### Condition Examples

```bash
# Time-based access (expires)
--condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),
title=Expires end of 2026'

# Time-based access (valid period)
--condition='expression=request.time > timestamp("2026-01-01T00:00:00Z") && 
request.time < timestamp("2026-12-31T23:59:59Z"),
title=Valid only in 2026'

# Resource-based (specific bucket)
--condition='expression=resource.name.startsWith("projects/_/buckets/prod-"),
title=Only prod buckets'

# Attribute-based (resource type)
--condition='expression=resource.type == "storage.googleapis.com/Bucket",
title=Only storage buckets'

# IP-based access
--condition='expression=origin.ip == "203.0.113.0/24",
title=Only from office IP'

# Combined conditions
--condition='expression=request.time < timestamp("2026-12-31T23:59:59Z") && 
resource.name.startsWith("projects/_/buckets/dev-"),
title=Temporary access to dev buckets'
```

---

## Testing Permissions

### Test IAM Permissions

```bash
# Test if you have specific permissions
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.list,compute.instances.get,compute.instances.create

# Output shows which permissions you have
# permissions:
# - compute.instances.list
# - compute.instances.get

# Test for service account
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=storage.buckets.list \
  --impersonate-service-account=app@PROJECT_ID.iam.gserviceaccount.com
```

### Policy Troubleshooter

```bash
# Use Policy Troubleshooter (via Console)
# IAM & Admin → Policy Troubleshooter

# Input:
# - Member: user:alice@company.com
# - Resource: projects/web-prod/zones/us-central1-a/instances/web-1
# - Permission: compute.instances.start

# Output shows:
# - Whether access is granted
# - Which policy grants access
# - Inheritance path
# - Conditions evaluated
```

---

## Common IAM Patterns

### Pattern 1: Development Team

```bash
# Create group
# developers@company.com (via Google Groups)

# Grant editor access to dev project
gcloud projects add-iam-policy-binding dev-project \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Grant viewer access to prod project
gcloud projects add-iam-policy-binding prod-project \
  --member='group:developers@company.com' \
  --role='roles/viewer'
```

### Pattern 2: Service Account for App

```bash
# Create service account
gcloud iam service-accounts create web-app \
  --display-name="Web Application"

# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.client'
```

### Pattern 3: Temporary Contractor

```bash
# Grant time-limited access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@external.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-06-30T23:59:59Z"),
title=Contract ends June 2026'
```

---

## Troubleshooting

```
Issue: Permission denied
Solution:
  • Check IAM policy with get-iam-policy
  • Use test-iam-permissions
  • Use Policy Troubleshooter
  • Check for deny policies
  • Verify conditions are met

Issue: Cannot grant role
Solution:
  • Verify you have IAM Admin role
  • Check organization policies
  • Ensure role exists
  • Check member format

Issue: Inherited permission not working
Solution:
  • Check parent policies
  • Verify policy propagation (can take minutes)
  • Check for deny policies
  • Use Policy Troubleshooter
```

---

## Next Steps

- **IAM Roles** → [2-IAM-Roles.md](./2-IAM-Roles.md)
- **Service Accounts** → [3-Service-Accounts.md](./3-Service-Accounts.md)
- **IAM Policies** → [4-IAM-Policies.md](./4-IAM-Policies.md)

---
