# IAM Policies

Complete guide to IAM policy structure, management, and troubleshooting in Google Cloud Platform.

---

## 📚 Overview

IAM policies define who (identity) has what access (role) to which resource. Understanding policy structure and evaluation is critical for secure access management.

**Key Concepts:**
- **Policy**: Collection of role bindings
- **Binding**: Associates members with a role
- **Member**: Identity (user, group, service account)
- **Role**: Set of permissions
- **Condition**: Optional constraints on access

---

## 🏗️ Policy Structure

### Basic Policy Anatomy

```json
{
  "bindings": [
    {
      "role": "roles/storage.objectViewer",
      "members": [
        "user:alice@company.com",
        "group:developers@company.com",
        "serviceAccount:app@project.iam.gserviceaccount.com"
      ]
    },
    {
      "role": "roles/storage.admin",
      "members": [
        "user:admin@company.com"
      ],
      "condition": {
        "title": "Expires_2026",
        "description": "Temporary admin access",
        "expression": "request.time < timestamp('2026-12-31T23:59:59Z')"
      }
    }
  ],
  "etag": "BwXhFJ5H8nY=",
  "version": 3
}
```

### Policy Components

```
┌────────────────────────────────────────────────────────┐
│  IAM Policy Components                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  bindings (array):                                     │
│  • List of role assignments                            │
│  • Each binding = role + members + optional condition  │
│                                                         │
│  role (string):                                        │
│  • The role being granted                              │
│  • Format: roles/SERVICE.ROLE                          │
│  • Example: roles/compute.instanceAdmin.v1             │
│                                                         │
│  members (array):                                      │
│  • Who gets the role                                   │
│  • Format: TYPE:EMAIL                                  │
│  • Types: user, group, serviceAccount, domain          │
│                                                         │
│  condition (object, optional):                         │
│  • When the binding applies                            │
│  • CEL (Common Expression Language)                    │
│  • Time-based, attribute-based, etc.                   │
│                                                         │
│  etag (string):                                        │
│  • Concurrency control                                 │
│  • Prevents conflicting updates                        │
│  • Changes with each policy modification               │
│                                                         │
│  version (integer):                                    │
│  • Policy schema version                               │
│  • Version 3: Supports conditions                      │
│  • Version 1: No conditions (legacy)                   │
└────────────────────────────────────────────────────────┘
```

---

## 🔧 Managing Policies

### 1. Get IAM Policy

```bash
# Get project policy
gcloud projects get-iam-policy PROJECT_ID

# Get policy in JSON format
gcloud projects get-iam-policy PROJECT_ID --format=json > policy.json

# Get policy for specific resource
gcloud storage buckets get-iam-policy gs://my-bucket
gcloud compute instances get-iam-policy my-vm --zone=us-central1-a
gcloud sql instances get-iam-policy my-db-instance

# Get policy with readable format
gcloud projects get-iam-policy PROJECT_ID \
  --format='table(bindings.role,bindings.members.flatten())'
```

### 2. Add IAM Policy Binding

```bash
# Add single binding
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/viewer'

# Add with condition
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Temporary Access,description=Expires end of 2026'

# Add to specific resource
gcloud storage buckets add-iam-policy-binding gs://my-bucket \
  --member='serviceAccount:app@project.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'
```

### 3. Remove IAM Policy Binding

```bash
# Remove binding
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/viewer'

# Remove conditional binding (must match condition exactly)
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Temporary Access'
```

### 4. Set IAM Policy (Replace Entire Policy)

```bash
# Get current policy
gcloud projects get-iam-policy PROJECT_ID --format=json > policy.json

# Edit policy.json file
# Add/remove bindings as needed

# Set the modified policy
gcloud projects set-iam-policy PROJECT_ID policy.json

# ⚠️  WARNING: This replaces the entire policy
# • Use add/remove-iam-policy-binding for single changes
# • Always backup current policy first
# • Check etag to prevent conflicts
```

---

## 🎯 IAM Conditions

### 1. Condition Syntax

```
┌────────────────────────────────────────────────────────┐
│  IAM Condition Structure                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  {                                                     │
│    "title": "Short descriptive title",                │
│    "description": "Longer explanation (optional)",    │
│    "expression": "CEL expression"                     │
│  }                                                     │
│                                                         │
│  CEL (Common Expression Language):                    │
│  • Boolean expressions                                 │
│  • Attribute-based access control                      │
│  • Time-based access                                   │
│  • Resource-based conditions                           │
└────────────────────────────────────────────────────────┘
```

### 2. Common Condition Examples

**Time-Based Access:**
```bash
# Access expires at specific date
expression='request.time < timestamp("2026-12-31T23:59:59Z")'

# Access only during business hours (9 AM - 5 PM UTC)
expression='request.time.getHours("UTC") >= 9 && request.time.getHours("UTC") < 17'

# Access only on weekdays
expression='request.time.getDayOfWeek("UTC") >= 1 && request.time.getDayOfWeek("UTC") <= 5'

# Combine date and time
expression='request.time < timestamp("2026-12-31T23:59:59Z") && request.time.getHours("UTC") >= 9'
```

**Resource-Based Access:**
```bash
# Access only to specific resource
expression='resource.name == "projects/my-project/zones/us-central1-a/instances/my-vm"'

# Access to resources with specific label
expression='resource.labels.environment == "production"'

# Access to resources in specific region
expression='resource.name.startsWith("projects/my-project/regions/us-central1/")'
```

**Attribute-Based Access:**
```bash
# Access based on user domain
expression='request.auth.claims.email.endsWith("@company.com")'

# Access based on IP address
expression='origin.ip in ["203.0.113.0/24", "198.51.100.0/24"]'

# Complex condition
expression='request.time < timestamp("2026-12-31T23:59:59Z") && resource.labels.environment == "dev"'
```

### 3. Applying Conditions

```bash
# Time-bound access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-06-30T23:59:59Z"),title=Q2 2026 Access,description=Access expires end of Q2'

# Resource-specific access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:developer@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=resource.labels.environment == "dev",title=Dev Only,description=Can only manage dev VMs'

# Business hours access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:support@company.com' \
  --role='roles/compute.viewer' \
  --condition='expression=request.time.getHours("UTC") >= 9 && request.time.getHours("UTC") < 17,title=Business Hours,description=Access during 9-5 UTC'
```

---

## 📊 Policy Inheritance

### Hierarchy and Inheritance

```
┌────────────────────────────────────────────────────────┐
│  Policy Inheritance Flow                               │
└────────────────────────────────────────────────────────┘

Organization
├─ Policy: alice@company.com → Viewer
│  Effect: Alice can view ALL resources
│
Folder: Production
├─ Policy: bob@company.com → Editor  
│  Effect: Bob can edit all Production resources
│  Inherits: Alice's Viewer (cumulative)
│
Project: web-prod
├─ Policy: charlie@company.com → Owner
│  Effect: Charlie owns web-prod
│  Inherits: Alice's Viewer + Bob's Editor
│
Resource: VM Instance
├─ Policy: dave@company.com → Instance Admin
│  Effect: Dave manages this VM
│  Inherits: All above permissions

Key Rules:
✓ Permissions are ADDITIVE (union of all levels)
✓ Child inherits parent permissions
✓ Cannot remove inherited permissions at child level
✓ More permissive wins
✓ Use Deny policies to block inherited permissions
```

### Effective Permissions

```bash
# Check effective permissions for a member
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:alice@company.com"

# Test if you have specific permissions
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.create,compute.instances.delete

# Use Policy Analyzer to see full inheritance
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --identity="user:alice@company.com"
```

---

## 🔍 Policy Troubleshooting

### 1. Policy Troubleshooter

```
Navigation: IAM & Admin → Policy Troubleshooter

Use Cases:
• Why does user have/not have access?
• Which policy grants permission?
• Where is permission inherited from?
• Why is condition not working?

Steps:
1. Select principal (user/SA)
2. Select resource
3. Select permission
4. View detailed analysis
```

### 2. Common Issues

**Issue: Permission Denied**
```bash
# Check if API is enabled
gcloud services list --enabled | grep compute

# Check if user has required role
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:alice@company.com"

# Test specific permissions
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.create

# Check organization policies
gcloud resource-manager org-policies list --project=PROJECT_ID
```

**Issue: Condition Not Working**
```bash
# Verify condition syntax
# Use Policy Troubleshooter in Console

# Common mistakes:
# ✗ Wrong timestamp format
# ✗ Incorrect attribute names
# ✗ Missing quotes
# ✗ Wrong comparison operators

# Test condition
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:test@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Test' \
  --dry-run
```

**Issue: Policy Update Conflicts**
```bash
# Error: etag mismatch
# Solution: Get fresh policy and retry

# Get current policy with etag
gcloud projects get-iam-policy PROJECT_ID --format=json > policy.json

# Modify policy.json

# Set policy (etag prevents conflicts)
gcloud projects set-iam-policy PROJECT_ID policy.json

# If conflict occurs, repeat process
```

---

## 🛡️ Deny Policies (New Feature)

### 1. Deny Policy Overview

```
┌────────────────────────────────────────────────────────┐
│  Deny Policies vs Allow Policies                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Allow Policies (Traditional):                         │
│  • Grant permissions                                   │
│  • Additive (union of all allows)                      │
│  • Cannot override inherited allows                    │
│                                                         │
│  Deny Policies (New):                                  │
│  • Explicitly deny permissions                         │
│  • Override allow policies                             │
│  • Can block inherited permissions                     │
│  • Deny always wins over allow                         │
│                                                         │
│  Evaluation Order:                                     │
│  1. Check deny policies (if denied, stop)             │
│  2. Check allow policies (if allowed, grant)          │
│  3. Default deny (if no allow, deny)                  │
│                                                         │
│  Use Cases:                                            │
│  • Block specific actions organization-wide            │
│  • Prevent privilege escalation                        │
│  • Enforce security boundaries                         │
│  • Override inherited permissions                      │
└────────────────────────────────────────────────────────┘
```

### 2. Creating Deny Policies

```bash
# Deny policy example (YAML)
cat > deny-policy.yaml << EOF
displayName: "Deny VM Deletion in Production"
rules:
- denyRule:
    deniedPrincipals:
    - principalSet: //goog/public:all
    deniedPermissions:
    - compute.googleapis.com/instances.delete
    denialCondition:
      expression: 'resource.matchTag("12345/environment", "production")'
      title: "Deny deletion of production VMs"
EOF

# Create deny policy
gcloud iam deny-policies create deny-vm-delete \
  --attachment-point=projects/PROJECT_ID \
  --kind=denypolicies \
  --policy-file=deny-policy.yaml

# List deny policies
gcloud iam deny-policies list \
  --attachment-point=projects/PROJECT_ID

# Delete deny policy
gcloud iam deny-policies delete deny-vm-delete \
  --attachment-point=projects/PROJECT_ID
```

---

## 📋 Policy Best Practices

### 1. Policy Management

```
✓ Use add/remove-iam-policy-binding for single changes
✓ Use set-iam-policy only for bulk changes
✓ Always backup policies before modifications
✓ Use version control for policy files
✓ Document why permissions are granted
✓ Regular policy audits
✓ Use IAM Recommender for optimization
✓ Implement least privilege
✓ Use groups instead of individual users
✓ Use conditions for temporary access
```

### 2. Condition Best Practices

```
✓ Use descriptive titles
✓ Add detailed descriptions
✓ Test conditions before production
✓ Use time-based conditions for temporary access
✓ Combine conditions for fine-grained control
✓ Document condition logic
✓ Monitor condition effectiveness
✓ Review and update regularly
```

### 3. Security Best Practices

```
✓ Principle of least privilege
✓ Use predefined roles when possible
✓ Avoid basic roles (Owner, Editor, Viewer)
✓ Regular access reviews
✓ Enable audit logging
✓ Monitor policy changes
✓ Use deny policies for critical restrictions
✓ Implement separation of duties
✓ Use service accounts for applications
✓ Rotate credentials regularly
```

---

## 🔄 Policy Automation

### Terraform Example

```hcl
# Grant role to user
resource "google_project_iam_member" "alice_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:alice@company.com"
}

# Grant role with condition
resource "google_project_iam_member" "contractor_temp" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "user:contractor@company.com"
  
  condition {
    title       = "Temporary Access"
    description = "Access expires end of 2026"
    expression  = "request.time < timestamp('2026-12-31T23:59:59Z')"
  }
}

# Grant role to service account
resource "google_project_iam_member" "app_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app.email}"
}

# Bind multiple roles to group
resource "google_project_iam_binding" "developers" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  
  members = [
    "group:developers@company.com",
  ]
}
```

### Python Script for Bulk Updates

```python
from google.cloud import resourcemanager_v3
from google.iam.v1 import iam_policy_pb2, policy_pb2

def add_member_to_role(project_id, member, role):
    """Add member to role in project"""
    client = resourcemanager_v3.ProjectsClient()
    
    # Get current policy
    policy = client.get_iam_policy(
        request={"resource": f"projects/{project_id}"}
    )
    
    # Find or create binding
    binding = None
    for b in policy.bindings:
        if b.role == role:
            binding = b
            break
    
    if not binding:
        binding = policy_pb2.Binding(role=role)
        policy.bindings.append(binding)
    
    # Add member if not already present
    if member not in binding.members:
        binding.members.append(member)
    
    # Set updated policy
    client.set_iam_policy(
        request={
            "resource": f"projects/{project_id}",
            "policy": policy
        }
    )
    
    print(f"Added {member} to {role}")

# Usage
add_member_to_role(
    "my-project-123",
    "user:alice@company.com",
    "roles/viewer"
)
```

---

## 🎓 Next Steps

1. Implement [Least Privilege](./5-Least-Privilege.md) principles
2. Learn about [Identity-Aware Proxy](./6-Identity-Aware-Proxy.md)
3. Explore [Advanced IAM](./7-Advanced-IAM.md) features
4. Review [Best Practices](./8-Best-Practices.md) for enterprise IAM

---

**Last Updated:** March 2026
**Version:** 2.0
