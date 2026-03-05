# Resource Hierarchy & Governance Best Practices

## Overview

This guide provides comprehensive best practices for designing and managing your GCP resource hierarchy and governance strategy. Implement these practices to ensure scalability, security, and operational efficiency.

---

## Table of Contents

1. [Hierarchy Design](#hierarchy-design)
2. [Organization Setup](#organization-setup)
3. [Folder Structure](#folder-structure)
4. [Project Management](#project-management)
5. [IAM Strategy](#iam-strategy)
6. [Policy Management](#policy-management)
7. [Naming Conventions](#naming-conventions)
8. [Automation](#automation)
9. [Monitoring & Auditing](#monitoring--auditing)
10. [Common Pitfalls](#common-pitfalls)

---

## Hierarchy Design

### Design Principles

```
┌──────────────────────────────────────────────────────┐
│         Hierarchy Design Principles                  │
└──────────────────────────────────────────────────────┘

1. SIMPLICITY
   └─ Start simple, add complexity as needed

2. SCALABILITY
   └─ Design for growth

3. SECURITY
   └─ Least privilege by default

4. FLEXIBILITY
   └─ Allow for organizational changes

5. CONSISTENCY
   └─ Standardize across the organization
```

### Recommended Structure

```
Organization: company.com
│
├─── Folder: Production
│    ├─── Folder: Engineering
│    │    ├─ Project: eng-prod-web-us
│    │    ├─ Project: eng-prod-api-us
│    │    └─ Project: eng-prod-data-us
│    │
│    ├─── Folder: Marketing
│    │    └─ Project: mkt-prod-analytics-us
│    │
│    └─── Folder: Finance
│         └─ Project: fin-prod-erp-us
│
├─── Folder: Non-Production
│    ├─── Folder: Staging
│    │    └─ Projects: *-staging-*
│    │
│    └─── Folder: Development
│         └─ Projects: *-dev-*
│
├─── Folder: Shared Services
│    ├─ Project: shared-networking
│    ├─ Project: shared-monitoring
│    ├─ Project: shared-security
│    └─ Project: shared-logging
│
└─── Folder: Sandbox
     └─ Projects: sandbox-* (with spending limits)
```

### Anti-Patterns to Avoid

❌ **Too Deep Hierarchy**
```
# Bad: Too many levels
Organization
└─ Folder: Region
   └─ Folder: Department
      └─ Folder: Team
         └─ Folder: Environment
            └─ Folder: Application
               └─ Project
```

✓ **Optimal Depth**
```
# Good: 2-3 levels
Organization
└─ Folder: Environment
   └─ Folder: Department
      └─ Project
```

---

## Organization Setup

### Initial Configuration

```bash
# 1. Set up organization
gcloud organizations list

# 2. Configure organization policies
gcloud resource-manager org-policies set-policy \
    security-policies.yaml \
    --organization=ORG_ID

# 3. Set up billing
gcloud billing accounts list

# 4. Create initial folder structure
gcloud resource-manager folders create \
    --display-name="Production" \
    --organization=ORG_ID

# 5. Configure IAM at org level
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="group:org-admins@company.com" \
    --role="roles/resourcemanager.organizationAdmin"
```

### Organization-Level Policies

```yaml
# Essential organization policies
policies:
  # Security
  - constraint: compute.requireOsLogin
    enforced: true
  
  - constraint: compute.requireShieldedVm
    enforced: true
  
  - constraint: iam.disableServiceAccountKeyCreation
    enforced: true
  
  # Cost Control
  - constraint: compute.vmExternalIpAccess
    deny_all: true
  
  - constraint: compute.restrictRegions
    allowed_values:
      - "in:us-locations"
      - "in:eu-locations"
  
  # Compliance
  - constraint: gcp.resourceLocations
    allowed_values:
      - "in:us-locations"
```

---

## Folder Structure

### Environment-Based Structure

```hcl
# Terraform for folder structure
resource "google_folder" "production" {
  display_name = "Production"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "non_production" {
  display_name = "Non-Production"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "shared_services" {
  display_name = "Shared Services"
  parent       = "organizations/${var.org_id}"
}

# Department folders under Production
resource "google_folder" "prod_engineering" {
  display_name = "Engineering"
  parent       = google_folder.production.name
}

resource "google_folder" "prod_marketing" {
  display_name = "Marketing"
  parent       = google_folder.production.name
}

# IAM for production folder
resource "google_folder_iam_binding" "prod_viewers" {
  folder = google_folder.production.name
  role   = "roles/viewer"
  
  members = [
    "group:engineering@company.com",
    "group:sre@company.com"
  ]
}

resource "google_folder_iam_binding" "prod_editors" {
  folder = google_folder.production.name
  role   = "roles/editor"
  
  members = [
    "group:prod-sre@company.com"
  ]
  
  condition {
    title       = "Production access during business hours"
    description = "Allow edit access during business hours only"
    expression  = "request.time.getHours('America/New_York') >= 9 && request.time.getHours('America/New_York') <= 17"
  }
}
```

### Department-Based Structure

```
Organization
│
├─── Folder: Engineering
│    ├─── Folder: Production
│    ├─── Folder: Staging
│    └─── Folder: Development
│
├─── Folder: Marketing
│    ├─── Folder: Production
│    └─── Folder: Development
│
└─── Folder: Data Science
     ├─── Folder: Production
     └─── Folder: Experimentation
```

---

## Project Management

### Project Naming Convention

```yaml
# Format: <team>-<env>-<app>-<region>
examples:
  - eng-prod-web-us
  - eng-dev-api-us
  - mkt-prod-analytics-eu
  - ds-staging-ml-us

# Components:
team: 3-4 letter abbreviation
  - eng (engineering)
  - mkt (marketing)
  - ds (data-science)
  - fin (finance)

env: environment
  - prod (production)
  - staging
  - dev (development)
  - test

app: application name
  - web
  - api
  - mobile
  - analytics

region: primary region
  - us
  - eu
  - asia
```

### Project Creation Template

```hcl
# Terraform module for standardized projects
module "project" {
  source = "./modules/standard-project"
  
  project_id      = "eng-prod-web-us"
  project_name    = "Engineering Production Web US"
  folder_id       = google_folder.prod_engineering.name
  billing_account = var.billing_account_id
  
  # Standard labels
  labels = {
    environment  = "production"
    team         = "engineering"
    cost_center  = "cc-1001"
    application  = "web"
    managed_by   = "terraform"
  }
  
  # Enable required APIs
  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
  
  # IAM bindings
  iam_bindings = {
    "roles/viewer" = [
      "group:engineering@company.com"
    ]
    "roles/editor" = [
      "group:eng-prod-team@company.com"
    ]
  }
}
```

### Project Lifecycle

```python
# Automated project lifecycle management
from google.cloud import resourcemanager_v3
from datetime import datetime, timedelta

class ProjectLifecycleManager:
    def __init__(self, org_id):
        self.client = resourcemanager_v3.ProjectsClient()
        self.org_id = org_id
    
    def check_inactive_projects(self, days=90):
        """
        Find projects with no activity for specified days
        """
        projects = self.client.list_projects(parent=f"organizations/{self.org_id}")
        
        inactive = []
        for project in projects:
            if self.is_inactive(project, days):
                inactive.append(project)
        
        return inactive
    
    def is_inactive(self, project, days):
        """
        Check if project has been inactive
        """
        # Check last activity from logs
        # Implementation depends on your logging setup
        return False
    
    def archive_project(self, project_id):
        """
        Archive inactive project
        """
        # 1. Export data
        # 2. Document resources
        # 3. Delete resources
        # 4. Delete project
        print(f"Archiving project: {project_id}")
    
    def cleanup_test_projects(self):
        """
        Clean up old test projects
        """
        projects = self.client.list_projects(parent=f"organizations/{self.org_id}")
        
        for project in projects:
            if 'test' in project.project_id:
                age = datetime.now() - project.create_time
                if age > timedelta(days=30):
                    print(f"Deleting old test project: {project.project_id}")
                    # self.client.delete_project(name=project.name)

# Usage
manager = ProjectLifecycleManager("123456789")
inactive = manager.check_inactive_projects(90)
print(f"Found {len(inactive)} inactive projects")
```

---

## IAM Strategy

### Role Assignment Matrix

```yaml
# Organization Level
organization:
  roles/resourcemanager.organizationAdmin:
    - group:org-admins@company.com
  
  roles/billing.admin:
    - group:finance-team@company.com
  
  roles/securitycenter.admin:
    - group:security-team@company.com
  
  roles/viewer:
    - group:all-employees@company.com

# Folder Level (Production)
folder_production:
  roles/viewer:
    - group:engineering@company.com
    - group:sre@company.com
  
  roles/editor:
    - group:prod-sre@company.com
  
  roles/compute.admin:
    - group:prod-compute-admins@company.com

# Project Level
project:
  roles/editor:
    - group:project-team@company.com
  
  roles/compute.instanceAdmin:
    - serviceAccount:app@project.iam.gserviceaccount.com
  
  roles/storage.objectViewer:
    - serviceAccount:app@project.iam.gserviceaccount.com
```

### Service Account Strategy

```hcl
# Service account per application
resource "google_service_account" "app" {
  account_id   = "app-service-account"
  display_name = "Application Service Account"
  project      = var.project_id
}

# Grant minimal permissions
resource "google_project_iam_member" "app_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_project_iam_member" "app_compute" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.app.email}"
}

# Workload Identity for GKE
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
}
```

---

## Policy Management

### Policy as Code

```hcl
# Centralized policy management
locals {
  org_policies = {
    # Security policies
    "compute.requireOsLogin" = {
      enforce = true
    }
    
    "compute.requireShieldedVm" = {
      enforce = true
    }
    
    "iam.disableServiceAccountKeyCreation" = {
      enforce = true
    }
    
    # Cost control policies
    "compute.vmExternalIpAccess" = {
      deny_all = true
    }
    
    "compute.restrictMachineTypes" = {
      allowed_values = [
        "e2-medium",
        "e2-standard-2",
        "e2-standard-4",
        "n2-standard-2",
        "n2-standard-4"
      ]
    }
  }
}

# Apply policies
resource "google_organization_policy" "policies" {
  for_each = local.org_policies
  
  org_id     = var.org_id
  constraint = each.key
  
  dynamic "boolean_policy" {
    for_each = lookup(each.value, "enforce", null) != null ? [1] : []
    content {
      enforced = each.value.enforce
    }
  }
  
  dynamic "list_policy" {
    for_each = lookup(each.value, "deny_all", null) != null ? [1] : []
    content {
      deny {
        all = true
      }
    }
  }
  
  dynamic "list_policy" {
    for_each = lookup(each.value, "allowed_values", null) != null ? [1] : []
    content {
      allow {
        values = each.value.allowed_values
      }
    }
  }
}
```

### Policy Exceptions

```hcl
# Exception for production web servers
resource "google_folder_organization_policy" "prod_web_external_ip" {
  folder     = google_folder.prod_web.name
  constraint = "compute.vmExternalIpAccess"
  
  list_policy {
    allow {
      all = true
    }
  }
}

# Document exception
resource "google_folder" "prod_web" {
  display_name = "Production Web"
  parent       = google_folder.production.name
  
  # Add metadata explaining exception
  lifecycle {
    ignore_changes = []
  }
}
```

---

## Naming Conventions

### Comprehensive Naming Standards

```yaml
# Organization
organization:
  format: "company.com"
  example: "acme-corp.com"

# Folders
folders:
  format: "<purpose>"
  examples:
    - "Production"
    - "Non-Production"
    - "Shared Services"
    - "Engineering"
    - "Marketing"

# Projects
projects:
  format: "<team>-<env>-<app>-<region>"
  max_length: 30
  examples:
    - "eng-prod-web-us"
    - "mkt-dev-analytics-eu"
    - "ds-staging-ml-asia"

# Resources
compute_instances:
  format: "<app>-<env>-<purpose>-<number>"
  examples:
    - "web-prod-frontend-01"
    - "api-staging-backend-02"

storage_buckets:
  format: "<company>-<project>-<purpose>-<region>"
  examples:
    - "acme-eng-data-us"
    - "acme-mkt-assets-eu"

service_accounts:
  format: "<app>-<purpose>@<project>.iam.gserviceaccount.com"
  examples:
    - "web-app@eng-prod-web.iam.gserviceaccount.com"
    - "data-pipeline@ds-prod-ml.iam.gserviceaccount.com"

# Networks
vpcs:
  format: "<env>-<region>-vpc"
  examples:
    - "prod-us-vpc"
    - "dev-eu-vpc"

subnets:
  format: "<env>-<region>-<purpose>-subnet"
  examples:
    - "prod-us-web-subnet"
    - "prod-us-data-subnet"
```

---

## Automation

### Infrastructure as Code

```hcl
# Complete hierarchy as code
module "organization_hierarchy" {
  source = "./modules/organization"
  
  org_id          = var.org_id
  billing_account = var.billing_account_id
  
  # Folder structure
  folders = {
    production = {
      display_name = "Production"
      subfolders = {
        engineering = { display_name = "Engineering" }
        marketing   = { display_name = "Marketing" }
      }
    }
    non_production = {
      display_name = "Non-Production"
      subfolders = {
        staging     = { display_name = "Staging" }
        development = { display_name = "Development" }
      }
    }
    shared_services = {
      display_name = "Shared Services"
    }
  }
  
  # Organization policies
  org_policies = local.org_policies
  
  # IAM bindings
  org_iam_bindings = {
    "roles/resourcemanager.organizationAdmin" = [
      "group:org-admins@company.com"
    ]
    "roles/viewer" = [
      "group:all-employees@company.com"
    ]
  }
}
```

### Automated Compliance Checks

```python
# Compliance checker
from google.cloud import asset_v1, resourcemanager_v3

class ComplianceChecker:
    def __init__(self, org_id):
        self.org_id = org_id
        self.asset_client = asset_v1.AssetServiceClient()
        self.rm_client = resourcemanager_v3.ProjectsClient()
    
    def check_project_labels(self):
        """
        Ensure all projects have required labels
        """
        required_labels = ['environment', 'team', 'cost_center']
        
        projects = self.rm_client.list_projects(
            parent=f"organizations/{self.org_id}"
        )
        
        non_compliant = []
        for project in projects:
            missing = [
                label for label in required_labels 
                if label not in project.labels
            ]
            
            if missing:
                non_compliant.append({
                    'project': project.project_id,
                    'missing_labels': missing
                })
        
        return non_compliant
    
    def check_iam_compliance(self):
        """
        Check for overly permissive IAM bindings
        """
        dangerous_roles = [
            'roles/owner',
            'roles/editor'
        ]
        
        # Implementation
        pass
    
    def generate_report(self):
        """
        Generate compliance report
        """
        print("=" * 60)
        print("COMPLIANCE REPORT")
        print("=" * 60)
        
        # Check labels
        label_issues = self.check_project_labels()
        print(f"\nProjects missing labels: {len(label_issues)}")
        for issue in label_issues:
            print(f"  {issue['project']}: {issue['missing_labels']}")
        
        # Check IAM
        # Check policies
        # etc.

# Usage
checker = ComplianceChecker("123456789")
checker.generate_report()
```

---

## Monitoring & Auditing

### Audit Logging

```yaml
# Enable audit logs
audit_config:
  - service: allServices
    audit_log_configs:
      - log_type: ADMIN_READ
      - log_type: DATA_READ
      - log_type: DATA_WRITE
```

```bash
# Query audit logs
gcloud logging read \
    'protoPayload.methodName="SetIamPolicy"' \
    --limit=50 \
    --format=json

# Monitor policy changes
gcloud logging read \
    'protoPayload.serviceName="cloudresourcemanager.googleapis.com"
     AND protoPayload.methodName=~".*Policy.*"' \
    --limit=50
```

### Monitoring Dashboard

```python
# Create monitoring dashboard
from google.cloud import monitoring_v3

def create_governance_dashboard(project_id):
    """
    Create dashboard for governance metrics
    """
    client = monitoring_v3.DashboardsServiceClient()
    
    dashboard = monitoring_v3.Dashboard(
        display_name="Governance Dashboard",
        # Dashboard configuration
    )
    
    client.create_dashboard(
        parent=f"projects/{project_id}",
        dashboard=dashboard
    )

create_governance_dashboard("monitoring-project")
```

---

## Common Pitfalls

### ❌ Pitfall 1: Flat Structure

**Problem:** All projects at organization level

**Solution:**
```
# Bad
Organization
├─ project-1
├─ project-2
├─ project-3
└─ project-100

# Good
Organization
├─ Folder: Production
│  └─ Projects
└─ Folder: Development
   └─ Projects
```

### ❌ Pitfall 2: Over-Permissive IAM

**Problem:** Granting Owner role widely

**Solution:**
```bash
# Bad
gcloud organizations add-iam-policy-binding ORG_ID \
    --member="user:developer@company.com" \
    --role="roles/owner"

# Good
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:developer@company.com" \
    --role="roles/compute.instanceAdmin"
```

### ❌ Pitfall 3: No Naming Standards

**Problem:** Inconsistent project names

**Solution:** Enforce naming convention
```python
def validate_project_name(name):
    pattern = r'^[a-z]{3,4}-[a-z]+-[a-z]+-[a-z]{2,4}$'
    if not re.match(pattern, name):
        raise ValueError(f"Invalid project name: {name}")
```

### ❌ Pitfall 4: Missing Labels

**Problem:** Cannot track costs or resources

**Solution:** Enforce required labels
```yaml
constraint: compute.requireLabels
listPolicy:
  allowedValues:
    - "environment"
    - "team"
    - "cost_center"
```

---

## Summary

Key best practices:
1. Design hierarchy for scalability
2. Use folders for logical grouping
3. Implement consistent naming
4. Apply least privilege IAM
5. Enforce policies organization-wide
6. Automate with IaC
7. Monitor and audit regularly
8. Document everything

### Quick Checklist

```
□ Organization configured
□ Folder structure created
□ Naming conventions defined
□ Organization policies set
□ IAM roles assigned
□ Labels enforced
□ Audit logging enabled
□ Monitoring configured
□ Documentation updated
□ Team trained
```

---

## Next Steps

- [Organization](./1-Organization.md) - Organization setup
- [Folders](./2-Folders.md) - Folder management
- [Projects](./3-Projects.md) - Project management
- [IAM Fundamentals](../4️⃣%20Identity%20&%20Access%20Management/1-IAM-Fundamentals.md) - IAM deep dive

---

**Last Updated:** March 2026
