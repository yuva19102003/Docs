# Tags & Labels

## Overview

Tags and labels are key-value pairs that help you organize, manage, and track your GCP resources. While they serve similar purposes, they have different use cases and capabilities.

---

## Table of Contents

1. [Labels vs Tags](#labels-vs-tags)
2. [Labels](#labels)
3. [Tags](#tags)
4. [Use Cases](#use-cases)
5. [Best Practices](#best-practices)
6. [Implementation](#implementation)

---

## Labels vs Tags

### Comparison

```
┌─────────────────────────────────────────────────────────┐
│              Labels vs Tags                             │
└─────────────────────────────────────────────────────────┘

LABELS:
├─ Key-value pairs attached to resources
├─ Used for: Cost tracking, filtering, grouping
├─ Scope: Individual resources
├─ Limit: 64 labels per resource
└─ Example: environment=production, team=engineering

TAGS:
├─ Key-value pairs attached to resources
├─ Used for: IAM policies, firewall rules, routing
├─ Scope: Organization-wide
├─ Limit: 50 tags per resource
└─ Example: environment/production, team/engineering
```

### When to Use What

**Use Labels for:**
- Cost allocation and tracking
- Resource filtering and grouping
- Billing reports
- Automation scripts

**Use Tags for:**
- Conditional IAM policies
- Firewall rules
- Network routing
- Organization policies

---

## Labels

### Label Structure

```yaml
# Label format
key: value

# Rules:
# - Keys: 1-63 characters, lowercase, numbers, hyphens, underscores
# - Values: 0-63 characters, same rules as keys
# - Maximum 64 labels per resource

# Examples:
environment: production
team: engineering
cost_center: cc-1001
application: web-app
owner: alice@company.com
```

### Applying Labels

**Using gcloud:**

```bash
# Add labels to Compute Engine instance
gcloud compute instances add-labels my-instance \
    --zone=us-central1-a \
    --labels=environment=production,team=engineering,cost_center=cc-1001

# Update labels
gcloud compute instances update my-instance \
    --zone=us-central1-a \
    --update-labels=version=v2,deployed_by=alice

# Remove labels
gcloud compute instances remove-labels my-instance \
    --zone=us-central1-a \
    --labels=version,deployed_by

# List resources by label
gcloud compute instances list \
    --filter="labels.environment=production"
```

**Using Terraform:**

```hcl
# Compute Engine instance with labels
resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  labels = {
    environment   = "production"
    team          = "engineering"
    cost_center   = "cc-1001"
    application   = "web-app"
    managed_by    = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      
      labels = {
        disk_type = "boot"
        environment = "production"
      }
    }
  }

  network_interface {
    network = "default"
  }
}

# Cloud Storage bucket with labels
resource "google_storage_bucket" "data" {
  name     = "company-data-bucket"
  location = "US"

  labels = {
    environment = "production"
    team        = "data-science"
    cost_center = "cc-3003"
    data_class  = "sensitive"
  }
}

# BigQuery dataset with labels
resource "google_bigquery_dataset" "analytics" {
  dataset_id = "analytics"
  location   = "US"

  labels = {
    environment = "production"
    team        = "analytics"
    cost_center = "cc-2002"
  }
}
```

### Label Taxonomy

```yaml
# Recommended label schema
labels:
  # Business
  business_unit: "engineering" | "marketing" | "sales" | "finance"
  cost_center: "cc-XXXX"
  department: "department_name"
  
  # Technical
  environment: "production" | "staging" | "development" | "test"
  application: "app_name"
  component: "frontend" | "backend" | "database" | "cache"
  version: "v1.0.0"
  
  # Operational
  team: "team_name"
  owner: "email@company.com"
  managed_by: "terraform" | "manual" | "ansible"
  backup: "daily" | "weekly" | "none"
  
  # Compliance
  data_classification: "public" | "internal" | "confidential" | "restricted"
  compliance: "pci" | "hipaa" | "gdpr" | "sox"
  
  # Cost Management
  chargeback: "direct" | "shared" | "overhead"
  project_code: "proj-2026-001"
```

---

## Tags

### Tag Structure

```yaml
# Tag format
tagKey/tagValue

# Rules:
# - Tag keys must be created at organization level
# - Tag values defined under tag keys
# - Hierarchical structure
# - Used in IAM conditions and firewall rules

# Examples:
environment/production
environment/development
team/engineering
team/marketing
```

### Creating Tags

**Using gcloud:**

```bash
# Create tag key
gcloud resource-manager tags keys create environment \
    --parent=organizations/ORG_ID \
    --description="Environment classification"

# Create tag values
gcloud resource-manager tags values create production \
    --parent=TAG_KEY_ID \
    --description="Production environment"

gcloud resource-manager tags values create development \
    --parent=TAG_KEY_ID \
    --description="Development environment"

# Bind tag to resource
gcloud resource-manager tags bindings create \
    --tag-value=TAG_VALUE_ID \
    --parent=//compute.googleapis.com/projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME

# List tags on resource
gcloud resource-manager tags bindings list \
    --parent=//compute.googleapis.com/projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME
```

**Using Terraform:**

```hcl
# Create tag key
resource "google_tags_tag_key" "environment" {
  parent      = "organizations/${var.org_id}"
  short_name  = "environment"
  description = "Environment classification"
}

# Create tag values
resource "google_tags_tag_value" "production" {
  parent      = google_tags_tag_key.environment.id
  short_name  = "production"
  description = "Production environment"
}

resource "google_tags_tag_value" "development" {
  parent      = google_tags_tag_key.environment.id
  short_name  = "development"
  description = "Development environment"
}

# Bind tag to project
resource "google_tags_tag_binding" "project_env" {
  parent    = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
  tag_value = google_tags_tag_value.production.id
}

# Bind tag to instance
resource "google_tags_tag_binding" "instance_env" {
  parent    = "//compute.googleapis.com/projects/${var.project_id}/zones/${var.zone}/instances/${google_compute_instance.web.name}"
  tag_value = google_tags_tag_value.production.id
}
```

### Using Tags in IAM

```yaml
# IAM policy with tag-based condition
bindings:
  - role: roles/compute.instanceAdmin
    members:
      - group:prod-admins@company.com
    condition:
      title: "Production environment only"
      description: "Grant access only to production resources"
      expression: |
        resource.matchTag('123456789/environment', 'production')
```

```bash
# Grant role with tag condition
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="group:prod-admins@company.com" \
    --role="roles/compute.instanceAdmin" \
    --condition='expression=resource.matchTag("123456789/environment", "production"),title=Production Only'
```

### Using Tags in Firewall Rules

```hcl
# Firewall rule using tags
resource "google_compute_firewall" "allow_ssh_prod" {
  name    = "allow-ssh-production"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # IAP range
  
  # Apply to instances with production tag
  target_tags = ["production"]
}

# Instance with network tag
resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["production", "web-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
  }
}
```

---

## Use Cases

### 1. Cost Allocation

```sql
-- Query costs by label
SELECT
  labels.value AS team,
  service.description,
  SUM(cost) AS total_cost
FROM
  `billing_export.gcp_billing_export_v1_XXXXXX`
WHERE
  labels.key = 'team'
  AND usage_start_time >= TIMESTAMP('2026-03-01')
GROUP BY
  team, service.description
ORDER BY
  total_cost DESC;
```

### 2. Resource Management

```bash
# Stop all development instances
gcloud compute instances list \
    --filter="labels.environment=development" \
    --format="value(name,zone)" | \
while read name zone; do
    gcloud compute instances stop $name --zone=$zone
done

# Delete old test resources
gcloud compute instances list \
    --filter="labels.environment=test AND creationTimestamp<'2026-01-01'" \
    --format="value(name,zone)" | \
while read name zone; do
    gcloud compute instances delete $name --zone=$zone --quiet
done
```

### 3. Conditional Access

```python
# Grant access based on tags
from google.cloud import resourcemanager_v3

def grant_conditional_access(project_id, member, role, tag_key, tag_value):
    """
    Grant IAM role with tag-based condition
    """
    client = resourcemanager_v3.ProjectsClient()
    
    policy = client.get_iam_policy(resource=f"projects/{project_id}")
    
    binding = {
        "role": role,
        "members": [member],
        "condition": {
            "title": f"Access to {tag_value} resources",
            "expression": f'resource.matchTag("{tag_key}", "{tag_value}")'
        }
    }
    
    policy.bindings.append(binding)
    
    client.set_iam_policy(resource=f"projects/{project_id}", policy=policy)
    print(f"Granted {role} to {member} for {tag_value} resources")

# Usage
grant_conditional_access(
    "my-project",
    "group:prod-team@company.com",
    "roles/compute.instanceAdmin",
    "123456789/environment",
    "production"
)
```

### 4. Automated Tagging

```python
# Automatically tag resources
from google.cloud import asset_v1, resourcemanager_v3

def auto_tag_resources():
    """
    Automatically apply tags based on project labels
    """
    asset_client = asset_v1.AssetServiceClient()
    tags_client = resourcemanager_v3.TagBindingsClient()
    
    # Get all compute instances
    request = asset_v1.SearchAllResourcesRequest(
        scope="organizations/123456789",
        asset_types=["compute.googleapis.com/Instance"]
    )
    
    resources = asset_client.search_all_resources(request=request)
    
    for resource in resources:
        # Check resource labels
        if 'environment' in resource.labels:
            env = resource.labels['environment']
            
            # Apply corresponding tag
            tag_value_id = get_tag_value_id(env)
            
            tags_client.create_tag_binding(
                parent=resource.name,
                tag_binding={"tag_value": tag_value_id}
            )
            
            print(f"Tagged {resource.name} with environment={env}")

def get_tag_value_id(environment):
    # Map environment to tag value ID
    mapping = {
        'production': 'tagValues/123456',
        'development': 'tagValues/123457',
        'staging': 'tagValues/123458'
    }
    return mapping.get(environment)

auto_tag_resources()
```

---

## Best Practices

### 1. Consistent Naming

✓ **Use lowercase**
```bash
# Good
environment=production
team=engineering

# Bad
Environment=Production
TEAM=ENGINEERING
```

✓ **Use hyphens for multi-word keys**
```bash
# Good
cost-center=cc-1001
business-unit=engineering

# Bad
cost_center=cc-1001
businessUnit=engineering
```

### 2. Required Labels

```yaml
# Define required labels
required_labels:
  - environment
  - team
  - cost_center
  - owner

# Enforce via organization policy
constraint: compute.requireLabels
listPolicy:
  allowedValues:
    - "environment"
    - "team"
    - "cost_center"
    - "owner"
```

### 3. Label Validation

```python
# Validate labels before resource creation
def validate_labels(labels, required_labels):
    """
    Validate that all required labels are present
    """
    missing = [label for label in required_labels if label not in labels]
    
    if missing:
        raise ValueError(f"Missing required labels: {missing}")
    
    # Validate format
    for key, value in labels.items():
        if not key.islower():
            raise ValueError(f"Label key must be lowercase: {key}")
        if len(key) > 63:
            raise ValueError(f"Label key too long: {key}")
        if len(value) > 63:
            raise ValueError(f"Label value too long: {value}")
    
    return True

# Usage
labels = {
    'environment': 'production',
    'team': 'engineering',
    'cost_center': 'cc-1001',
    'owner': 'alice@company.com'
}

required = ['environment', 'team', 'cost_center', 'owner']
validate_labels(labels, required)
```

### 4. Documentation

```markdown
# Label Documentation

## Standard Labels

### environment
- **Values:** production, staging, development, test
- **Purpose:** Identify resource environment
- **Required:** Yes
- **Example:** environment=production

### team
- **Values:** engineering, marketing, sales, data-science
- **Purpose:** Identify owning team
- **Required:** Yes
- **Example:** team=engineering

### cost_center
- **Values:** cc-XXXX (4-digit code)
- **Purpose:** Cost allocation
- **Required:** Yes
- **Example:** cost_center=cc-1001

### owner
- **Values:** email address
- **Purpose:** Resource owner contact
- **Required:** Yes
- **Example:** owner=alice@company.com
```

---

## Implementation

### Terraform Module for Labeling

```hcl
# modules/labeled-instance/main.tf
variable "name" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["production", "staging", "development", "test"], var.environment)
    error_message = "Environment must be production, staging, development, or test."
  }
}

variable "team" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "owner" {
  type = string
}

variable "additional_labels" {
  type    = map(string)
  default = {}
}

locals {
  standard_labels = {
    environment  = var.environment
    team         = var.team
    cost_center  = var.cost_center
    owner        = var.owner
    managed_by   = "terraform"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
  
  all_labels = merge(local.standard_labels, var.additional_labels)
}

resource "google_compute_instance" "instance" {
  name         = var.name
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  labels = local.all_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}

# Usage
module "web_server" {
  source = "./modules/labeled-instance"

  name        = "web-server"
  environment = "production"
  team        = "engineering"
  cost_center = "cc-1001"
  owner       = "alice@company.com"

  additional_labels = {
    application = "web-app"
    version     = "v1.0.0"
  }
}
```

---

## Summary

Tags and labels provide:
- Resource organization
- Cost tracking
- Access control
- Automation capabilities

### Quick Reference

```bash
# Labels
gcloud compute instances add-labels INSTANCE \
    --labels=KEY=VALUE

gcloud compute instances list \
    --filter="labels.KEY=VALUE"

# Tags
gcloud resource-manager tags keys create KEY \
    --parent=organizations/ORG_ID

gcloud resource-manager tags bindings create \
    --tag-value=TAG_VALUE_ID \
    --parent=RESOURCE_NAME
```

---

## Next Steps

- [Best Practices](./8-Best-Practices.md) - Governance best practices
- [Cost Allocation](../3️⃣%20Billing%20&%20Cost%20Management/7-Cost-Allocation.md) - Using labels for cost tracking

---

**Last Updated:** March 2026
