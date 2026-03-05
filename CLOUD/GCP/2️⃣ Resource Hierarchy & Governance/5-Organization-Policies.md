# Organization Policies

## Overview

Organization policies provide centralized control over your organization's cloud resources. They allow you to configure restrictions on how resources can be created and configured across your entire GCP organization, folders, and projects.

---

## Table of Contents

1. [Policy Fundamentals](#policy-fundamentals)
2. [Policy Types](#policy-types)
3. [Policy Constraints](#policy-constraints)
4. [Policy Inheritance](#policy-inheritance)
5. [Common Policies](#common-policies)
6. [Implementation](#implementation)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Policy Fundamentals

### What are Organization Policies?

Organization policies are rules that apply constraints to resources in your organization hierarchy.

```
┌──────────────────────────────────────────────────┐
│         Organization Policy Architecture         │
└──────────────────────────────────────────────────┘

Organization (Root)
├─ Policy: Restrict VM External IPs
│  └─ Applies to all resources below
│
├─ Folder: Production
│  ├─ Policy: Require Shielded VMs
│  │  └─ Overrides/inherits from parent
│  │
│  └─ Project: prod-web
│     ├─ Inherits: Restrict External IPs
│     ├─ Inherits: Require Shielded VMs
│     └─ Resources must comply
│
└─ Folder: Development
   ├─ Policy: Allow External IPs (Exception)
   └─ Project: dev-sandbox
      └─ Can use external IPs
```

### Key Concepts

**Constraint**
- A rule that restricts resource configuration
- Example: `compute.vmExternalIpAccess`

**Policy**
- Application of a constraint to a resource
- Can be enforced or not enforced

**Inheritance**
- Policies flow down the hierarchy
- Child resources inherit parent policies

---

## Policy Types

### 1. List Constraints

Allow or deny specific values:

```yaml
# Allow only specific machine types
constraint: compute.vmExternalIpAccess
listPolicy:
  allowedValues:
    - "projects/PROJECT_ID/zones/us-central1-a/machineTypes/e2-medium"
    - "projects/PROJECT_ID/zones/us-central1-a/machineTypes/e2-standard-2"
```

### 2. Boolean Constraints

Simple on/off policies:

```yaml
# Require OS Login
constraint: compute.requireOsLogin
booleanPolicy:
  enforced: true
```

### 3. Custom Constraints

Define your own rules:

```yaml
# Custom constraint for resource naming
name: organizations/123456789/customConstraints/custom.resourceNaming
resourceTypes:
  - compute.googleapis.com/Instance
condition: "resource.name.startsWith('prod-')"
actionType: ALLOW
displayName: "Require prod- prefix"
description: "All production resources must start with prod-"
```

---

## Policy Constraints

### Compute Engine Constraints

```bash
# Restrict VM external IP access
gcloud resource-manager org-policies set-policy \
    --organization=ORG_ID \
    compute-external-ip-policy.yaml

# compute-external-ip-policy.yaml
constraint: compute.vmExternalIpAccess
listPolicy:
  deniedValues:
    - "*"
```

```bash
# Require Shielded VMs
gcloud resource-manager org-policies set-policy \
    --organization=ORG_ID \
    shielded-vm-policy.yaml

# shielded-vm-policy.yaml
constraint: compute.requireShieldedVm
booleanPolicy:
  enforced: true
```

```bash
# Restrict machine types
gcloud resource-manager org-policies set-policy \
    --organization=ORG_ID \
    machine-type-policy.yaml

# machine-type-policy.yaml
constraint: compute.vmExternalIpAccess
listPolicy:
  allowedValues:
    - "e2-*"
    - "n2-*"
```

### Storage Constraints

```yaml
# Enforce uniform bucket-level access
constraint: storage.uniformBucketLevelAccess
booleanPolicy:
  enforced: true
```

```yaml
# Restrict public access
constraint: storage.publicAccessPrevention
booleanPolicy:
  enforced: true
```

### IAM Constraints

```yaml
# Restrict service account key creation
constraint: iam.disableServiceAccountKeyCreation
booleanPolicy:
  enforced: true
```

```yaml
# Restrict service account key upload
constraint: iam.disableServiceAccountKeyUpload
booleanPolicy:
  enforced: true
```

### Network Constraints

```yaml
# Restrict VPC peering
constraint: compute.restrictVpcPeering
listPolicy:
  allowedValues:
    - "under:organizations/ORG_ID"
```

```yaml
# Restrict shared VPC host projects
constraint: compute.restrictSharedVpcHostProjects
listPolicy:
  allowedValues:
    - "projects/shared-vpc-host"
```

---

## Policy Inheritance

### Inheritance Rules

```
Organization: company.com
├─ Policy A: Deny External IPs (Enforced)
│
├─ Folder: Production
│  ├─ Policy B: Require Shielded VMs (Enforced)
│  │  └─ Inherits Policy A
│  │
│  └─ Project: prod-web
│     ├─ Inherits Policy A (External IPs)
│     ├─ Inherits Policy B (Shielded VMs)
│     └─ Cannot override parent policies
│
└─ Folder: Development
   ├─ Policy C: Allow External IPs (Exception)
   │  └─ Overrides Policy A for this branch
   │
   └─ Project: dev-sandbox
      ├─ Inherits Policy C (Can use External IPs)
      └─ Still inherits other org policies
```

### Policy Evaluation

```python
# Python script to check effective policy
from google.cloud import orgpolicy_v2

def get_effective_policy(resource, constraint):
    """
    Get the effective policy for a resource
    """
    client = orgpolicy_v2.OrgPolicyClient()
    
    request = orgpolicy_v2.GetEffectivePolicyRequest(
        name=f"{resource}/policies/{constraint}"
    )
    
    try:
        policy = client.get_effective_policy(request=request)
        print(f"Effective Policy for {resource}:")
        print(f"Constraint: {constraint}")
        print(f"Policy: {policy}")
        return policy
    except Exception as e:
        print(f"Error: {e}")
        return None

# Check effective policy
get_effective_policy(
    "projects/my-project",
    "compute.vmExternalIpAccess"
)
```

---

## Common Policies

### Security Policies

```yaml
# 1. Require OS Login
constraint: compute.requireOsLogin
booleanPolicy:
  enforced: true

# 2. Disable service account key creation
constraint: iam.disableServiceAccountKeyCreation
booleanPolicy:
  enforced: true

# 3. Require Shielded VMs
constraint: compute.requireShieldedVm
booleanPolicy:
  enforced: true

# 4. Enforce uniform bucket access
constraint: storage.uniformBucketLevelAccess
booleanPolicy:
  enforced: true

# 5. Prevent public storage access
constraint: storage.publicAccessPrevention
booleanPolicy:
  enforced: true
```

### Cost Control Policies

```yaml
# 1. Restrict expensive machine types
constraint: compute.restrictMachineTypes
listPolicy:
  allowedValues:
    - "e2-*"
    - "n2-standard-*"
  deniedValues:
    - "n2-highmem-*"
    - "n2-highcpu-*"

# 2. Restrict regions (reduce data transfer costs)
constraint: compute.restrictRegions
listPolicy:
  allowedValues:
    - "in:us-locations"
    - "in:eu-locations"

# 3. Disable serial port access (security + cost)
constraint: compute.disableSerialPortAccess
booleanPolicy:
  enforced: true
```

### Compliance Policies

```yaml
# 1. Restrict resource locations (data residency)
constraint: gcp.resourceLocations
listPolicy:
  allowedValues:
    - "in:us-locations"

# 2. Require labels
constraint: compute.requireLabels
listPolicy:
  allowedValues:
    - "cost_center"
    - "environment"
    - "owner"

# 3. Restrict service account impersonation
constraint: iam.allowedPolicyMemberDomains
listPolicy:
  allowedValues:
    - "company.com"
```

---

## Implementation

### Using gcloud CLI

```bash
# List all constraints
gcloud resource-manager org-policies list \
    --organization=ORG_ID

# Get a specific policy
gcloud resource-manager org-policies describe \
    compute.vmExternalIpAccess \
    --organization=ORG_ID

# Set a policy
gcloud resource-manager org-policies set-policy \
    policy.yaml \
    --organization=ORG_ID

# Delete a policy
gcloud resource-manager org-policies delete \
    compute.vmExternalIpAccess \
    --organization=ORG_ID
```

### Using Terraform

```hcl
# Organization policy with Terraform
resource "google_organization_policy" "external_ip_policy" {
  org_id     = var.org_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}

resource "google_organization_policy" "shielded_vm_policy" {
  org_id     = var.org_id
  constraint = "compute.requireShieldedVm"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "machine_type_policy" {
  org_id     = var.org_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    allow {
      values = [
        "e2-medium",
        "e2-standard-2",
        "e2-standard-4"
      ]
    }
  }
}

# Folder-level policy
resource "google_folder_organization_policy" "dev_external_ip" {
  folder     = google_folder.development.name
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    allow {
      all = true
    }
  }
}

# Project-level policy
resource "google_project_organization_policy" "project_policy" {
  project    = google_project.my_project.project_id
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}
```

### Using Python

```python
# Manage organization policies with Python
from google.cloud import orgpolicy_v2
from google.cloud.orgpolicy_v2 import Policy

def create_policy(parent, constraint, deny_all=True):
    """
    Create an organization policy
    """
    client = orgpolicy_v2.OrgPolicyClient()
    
    policy = Policy()
    policy.name = f"{parent}/policies/{constraint}"
    
    if deny_all:
        policy.spec.rules = [
            {
                "deny_all": True
            }
        ]
    
    request = orgpolicy_v2.CreatePolicyRequest(
        parent=parent,
        policy=policy
    )
    
    response = client.create_policy(request=request)
    print(f"Created policy: {response.name}")
    return response

def update_policy(policy_name, allowed_values):
    """
    Update an existing policy
    """
    client = orgpolicy_v2.OrgPolicyClient()
    
    policy = client.get_policy(name=policy_name)
    
    policy.spec.rules = [
        {
            "values": {
                "allowed_values": allowed_values
            }
        }
    ]
    
    response = client.update_policy(policy=policy)
    print(f"Updated policy: {response.name}")
    return response

def delete_policy(policy_name):
    """
    Delete a policy
    """
    client = orgpolicy_v2.OrgPolicyClient()
    
    client.delete_policy(name=policy_name)
    print(f"Deleted policy: {policy_name}")

# Usage
create_policy(
    "organizations/123456789",
    "compute.vmExternalIpAccess",
    deny_all=True
)

update_policy(
    "organizations/123456789/policies/compute.vmExternalIpAccess",
    ["e2-medium", "e2-standard-2"]
)
```

---

## Best Practices

### 1. Start at Organization Level

✓ **Apply broad policies at the top**
- Security policies
- Compliance requirements
- Cost controls

✓ **Use exceptions sparingly**
- Document why exceptions are needed
- Review exceptions regularly

### 2. Test Before Enforcing

```bash
# Test policy in dry-run mode
gcloud resource-manager org-policies set-policy \
    policy.yaml \
    --organization=ORG_ID \
    --dry-run

# Check what would be affected
gcloud resource-manager org-policies describe \
    compute.vmExternalIpAccess \
    --organization=ORG_ID \
    --effective
```

### 3. Document Policies

```markdown
# Organization Policy Documentation

## Policy: Restrict VM External IPs
- **Constraint:** compute.vmExternalIpAccess
- **Level:** Organization
- **Rationale:** Reduce attack surface and data egress costs
- **Exceptions:** Production web frontends (folder: prod-web)
- **Owner:** Security Team
- **Review Date:** Quarterly

## Policy: Require Shielded VMs
- **Constraint:** compute.requireShieldedVm
- **Level:** Organization
- **Rationale:** Security and compliance requirement
- **Exceptions:** None
- **Owner:** Security Team
- **Review Date:** Annually
```

### 4. Monitor Policy Violations

```python
# Monitor policy violations
from google.cloud import logging_v2

def monitor_policy_violations():
    """
    Query logs for policy violations
    """
    client = logging_v2.Client()
    
    filter_str = '''
    protoPayload.methodName="SetIamPolicy"
    AND protoPayload.status.code!=0
    AND protoPayload.status.message=~".*organization policy.*"
    '''
    
    for entry in client.list_entries(filter_=filter_str):
        print(f"Violation detected:")
        print(f"  Resource: {entry.resource}")
        print(f"  User: {entry.proto_payload.authentication_info.principal_email}")
        print(f"  Error: {entry.proto_payload.status.message}")

monitor_policy_violations()
```

### 5. Regular Reviews

```yaml
# Policy review schedule
quarterly_review:
  - Review all organization policies
  - Check for new constraints
  - Validate exceptions
  - Update documentation

annual_review:
  - Comprehensive policy audit
  - Align with compliance requirements
  - Update based on new services
  - Train teams on changes
```

---

## Troubleshooting

### Common Issues

**Issue 1: Policy Not Taking Effect**

```bash
# Check effective policy
gcloud resource-manager org-policies describe \
    compute.vmExternalIpAccess \
    --project=PROJECT_ID \
    --effective

# Check inheritance
gcloud resource-manager org-policies list \
    --project=PROJECT_ID \
    --show-unset
```

**Issue 2: Cannot Create Resource**

```bash
# Check which policy is blocking
gcloud compute instances create test-vm \
    --zone=us-central1-a \
    --dry-run

# Review policy constraints
gcloud resource-manager org-policies describe \
    compute.vmExternalIpAccess \
    --project=PROJECT_ID
```

**Issue 3: Policy Conflicts**

```python
# Check for conflicting policies
def check_policy_conflicts(resource):
    """
    Check for conflicting policies in hierarchy
    """
    client = orgpolicy_v2.OrgPolicyClient()
    
    # Get all policies for resource
    policies = client.list_policies(parent=resource)
    
    for policy in policies:
        print(f"Policy: {policy.name}")
        print(f"Spec: {policy.spec}")
        print("---")

check_policy_conflicts("projects/my-project")
```

---

## Summary

Organization policies provide:
- Centralized control over resources
- Automated compliance enforcement
- Cost and security guardrails
- Inheritance through hierarchy

### Quick Reference

```bash
# List constraints
gcloud resource-manager org-policies list-constraints \
    --organization=ORG_ID

# Set policy
gcloud resource-manager org-policies set-policy policy.yaml \
    --organization=ORG_ID

# Check effective policy
gcloud resource-manager org-policies describe CONSTRAINT \
    --project=PROJECT_ID \
    --effective

# Delete policy
gcloud resource-manager org-policies delete CONSTRAINT \
    --organization=ORG_ID
```

---

## Next Steps

- [IAM Hierarchy](./6-IAM-Hierarchy.md) - Access control in hierarchy
- [Tags & Labels](./7-Tags-Labels.md) - Resource organization
- [Best Practices](./8-Best-Practices.md) - Governance best practices

---

**Last Updated:** March 2026
