# 4. Resource Manager

The **Resource Manager API** provides programmatic access to manage your GCP resource hierarchy.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Resource Manager Capabilities                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  • Create, read, update, delete resources              │
│  • Manage resource hierarchy                           │
│  • Search and filter resources                         │
│  • Apply labels and metadata                           │
│  • Bulk operations                                     │
│  • IAM policy management                               │
│  • Organization policy management                      │
│  • Resource inventory and discovery                    │
└────────────────────────────────────────────────────────┘
```

---

## Resource Manager Components

```
┌────────────────────────────────────────────────────────────┐
│  Resource Manager Services                                 │
└────────────────────────────────────────────────────────────┘

1. Cloud Resource Manager API
   ├─ Organizations
   ├─ Folders
   └─ Projects

2. Cloud Asset Inventory
   ├─ Asset discovery
   ├─ Asset search
   └─ Asset export

3. Resource Search
   ├─ Cross-project search
   ├─ Advanced filtering
   └─ Resource metadata

4. Organization Policy Service
   ├─ Policy management
   ├─ Constraint enforcement
   └─ Policy analysis
```

---

## Resource Manager API

### Enable API

```bash
# Enable Resource Manager API
gcloud services enable cloudresourcemanager.googleapis.com

# Enable Cloud Asset API
gcloud services enable cloudasset.googleapis.com
```

### Basic Operations

```bash
# List organizations
gcloud organizations list

# Get organization details
gcloud organizations describe ORGANIZATION_ID

# List folders
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID

# List projects
gcloud projects list

# Search all resources
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="*"
```

---

## Cloud Asset Inventory

### Asset Discovery

```bash
# Search all resources in organization
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --asset-types=compute.googleapis.com/Instance

# Search with filter
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="name:web-*"

# Search by labels
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="labels.environment=production"

# Search specific resource types
gcloud asset search-all-resources \
  --scope=projects/PROJECT_ID \
  --asset-types=storage.googleapis.com/Bucket,compute.googleapis.com/Instance
```

### Asset Export

```bash
# Export all assets to Cloud Storage
gcloud asset export \
  --output-path=gs://my-bucket/assets.json \
  --content-type=resource \
  --organization=ORGANIZATION_ID

# Export specific asset types
gcloud asset export \
  --output-path=gs://my-bucket/compute-assets.json \
  --content-type=resource \
  --asset-types=compute.googleapis.com/Instance \
  --project=PROJECT_ID

# Export with IAM policies
gcloud asset export \
  --output-path=gs://my-bucket/assets-with-iam.json \
  --content-type=iam-policy \
  --organization=ORGANIZATION_ID

# Export to BigQuery
gcloud asset export \
  --output-bigquery-table=projects/PROJECT_ID/datasets/assets/tables/inventory \
  --content-type=resource \
  --organization=ORGANIZATION_ID
```

---

## Resource Search

### Advanced Search Queries

```bash
# Search by resource type
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --asset-types=compute.googleapis.com/Instance \
  --format="table(name,location,assetType)"

# Search by location
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="location:us-central1"

# Search by state
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="state:ACTIVE"

# Complex query
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="labels.environment=production AND location:us-*"

# Search IAM policies
gcloud asset search-all-iam-policies \
  --scope=organizations/ORGANIZATION_ID \
  --query="policy:roles/owner"
```

### Search Examples

```bash
# Find all VMs in production
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --asset-types=compute.googleapis.com/Instance \
  --query="labels.environment=production"

# Find all public buckets
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --asset-types=storage.googleapis.com/Bucket \
  --query="iamPolicy.bindings.members:allUsers"

# Find resources without labels
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="NOT labels:*"

# Find expensive resources (requires custom metadata)
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="labels.cost-tier=high"
```

---

## Resource Metadata and Labels

### Applying Labels

```bash
# Label project
gcloud projects update PROJECT_ID \
  --update-labels=environment=production,team=web

# Label compute instance
gcloud compute instances update INSTANCE_NAME \
  --zone=ZONE \
  --update-labels=app=frontend,version=v2

# Label storage bucket
gsutil label ch -l environment:production gs://BUCKET_NAME

# Label Cloud SQL instance
gcloud sql instances patch INSTANCE_NAME \
  --labels=environment=production,tier=premium
```

### Bulk Labeling

```bash
#!/bin/bash
# Bulk label all VMs in a project

PROJECT_ID="web-prod-2026"
LABELS="environment=production,managed-by=terraform"

# Get all instances
INSTANCES=$(gcloud compute instances list \
  --project=$PROJECT_ID \
  --format="value(name,zone)")

# Apply labels to each instance
while IFS=$'\t' read -r name zone; do
  echo "Labeling $name in $zone"
  gcloud compute instances update $name \
    --zone=$zone \
    --update-labels=$LABELS \
    --project=$PROJECT_ID
done <<< "$INSTANCES"
```

---

## Automation with Python SDK

### Setup

```python
from google.cloud import resourcemanager_v3
from google.cloud import asset_v1

# Initialize clients
project_client = resourcemanager_v3.ProjectsClient()
folder_client = resourcemanager_v3.FoldersClient()
org_client = resourcemanager_v3.OrganizationsClient()
asset_client = asset_v1.AssetServiceClient()
```

### List Resources

```python
# List all projects
def list_projects(parent):
    """List all projects under a parent (org or folder)."""
    request = resourcemanager_v3.ListProjectsRequest(parent=parent)
    projects = project_client.list_projects(request=request)
    
    for project in projects:
        print(f"Project: {project.project_id}")
        print(f"  Name: {project.display_name}")
        print(f"  State: {project.state}")
        print(f"  Labels: {project.labels}")
        print()

# Usage
list_projects("organizations/123456789012")
```

### Search Assets

```python
# Search for resources
def search_assets(scope, query):
    """Search for assets matching query."""
    request = asset_v1.SearchAllResourcesRequest(
        scope=scope,
        query=query,
    )
    
    results = asset_client.search_all_resources(request=request)
    
    for resource in results:
        print(f"Resource: {resource.name}")
        print(f"  Type: {resource.asset_type}")
        print(f"  Location: {resource.location}")
        print(f"  Labels: {dict(resource.labels)}")
        print()

# Usage
search_assets(
    "organizations/123456789012",
    "labels.environment=production"
)
```

### Create Project

```python
# Create a new project
def create_project(project_id, display_name, parent):
    """Create a new project."""
    project = resourcemanager_v3.Project(
        project_id=project_id,
        display_name=display_name,
        parent=parent,
        labels={
            "environment": "production",
            "team": "web"
        }
    )
    
    request = resourcemanager_v3.CreateProjectRequest(project=project)
    operation = project_client.create_project(request=request)
    
    # Wait for operation to complete
    result = operation.result()
    print(f"Created project: {result.project_id}")
    return result

# Usage
create_project(
    "web-prod-2026",
    "Web Production",
    "folders/123456789"
)
```

---

## Resource Inventory Dashboard

### BigQuery Analysis

```sql
-- Create asset inventory table (from export)
-- Then analyze with SQL

-- Count resources by type
SELECT
  asset_type,
  COUNT(*) as count
FROM `project.dataset.asset_inventory`
GROUP BY asset_type
ORDER BY count DESC;

-- Resources by project
SELECT
  project,
  asset_type,
  COUNT(*) as count
FROM `project.dataset.asset_inventory`
GROUP BY project, asset_type
ORDER BY project, count DESC;

-- Resources by location
SELECT
  location,
  asset_type,
  COUNT(*) as count
FROM `project.dataset.asset_inventory`
WHERE location IS NOT NULL
GROUP BY location, asset_type
ORDER BY location, count DESC;

-- Resources without labels
SELECT
  name,
  asset_type,
  project
FROM `project.dataset.asset_inventory`
WHERE ARRAY_LENGTH(labels) = 0;

-- Resources by label
SELECT
  label.key,
  label.value,
  COUNT(*) as count
FROM `project.dataset.asset_inventory`,
UNNEST(labels) as label
GROUP BY label.key, label.value
ORDER BY count DESC;
```

---

## Terraform Integration

```hcl
# Data source: List projects
data "google_projects" "my_projects" {
  filter = "parent.id:${var.folder_id}"
}

# Output project IDs
output "project_ids" {
  value = [for p in data.google_projects.my_projects.projects : p.project_id]
}

# Data source: Organization
data "google_organization" "org" {
  domain = "company.com"
}

# Data source: Folder
data "google_folder" "production" {
  folder = "folders/123456789"
}

# Create multiple projects dynamically
resource "google_project" "apps" {
  for_each = toset(["web", "api", "data"])

  name            = "${each.key}-prod"
  project_id      = "${each.key}-prod-2026"
  folder_id       = data.google_folder.production.name
  billing_account = var.billing_account_id

  labels = {
    environment = "production"
    app         = each.key
  }
}
```

---

## Monitoring and Alerts

### Resource Change Notifications

```bash
# Create Pub/Sub topic for notifications
gcloud pubsub topics create resource-changes

# Create asset feed
gcloud asset feeds create resource-feed \
  --organization=ORGANIZATION_ID \
  --asset-types=compute.googleapis.com/Instance \
  --content-type=resource \
  --pubsub-topic=projects/PROJECT_ID/topics/resource-changes

# Subscribe to changes
gcloud pubsub subscriptions create resource-changes-sub \
  --topic=resource-changes
```

### Audit Logging

```bash
# Query resource changes
gcloud logging read \
  'protoPayload.methodName="google.cloud.resourcemanager.v3.Projects.CreateProject"' \
  --limit=50 \
  --format=json

# Monitor folder changes
gcloud logging read \
  'resource.type="folder" AND protoPayload.methodName=~"Folder"' \
  --limit=50

# Track IAM changes
gcloud logging read \
  'protoPayload.methodName=~"SetIamPolicy"' \
  --limit=50
```

---

## Best Practices

```
✓ Use Cloud Asset Inventory for discovery
✓ Export assets to BigQuery for analysis
✓ Apply consistent labeling strategy
✓ Automate resource management with APIs
✓ Monitor resource changes with feeds
✓ Regular inventory audits
✓ Use service accounts for automation
✓ Implement resource naming conventions
✓ Track resource lifecycle
✓ Document resource ownership
```

---

## Common Use Cases

### 1. Resource Discovery

```bash
# Find all resources in organization
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --format="table(name,assetType,project,location)"
```

### 2. Compliance Auditing

```bash
# Find resources without required labels
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="NOT labels.cost-center:*"
```

### 3. Cost Optimization

```bash
# Find idle resources
gcloud asset search-all-resources \
  --scope=organizations/ORGANIZATION_ID \
  --query="labels.status=idle"
```

### 4. Security Review

```bash
# Find public resources
gcloud asset search-all-iam-policies \
  --scope=organizations/ORGANIZATION_ID \
  --query="policy.bindings.members:allUsers"
```

---

## Next Steps

- **Organization Policies** → [5-Organization-Policies.md](./5-Organization-Policies.md)
- **IAM Hierarchy** → [6-IAM-Hierarchy.md](./6-IAM-Hierarchy.md)
- **Tags & Labels** → [7-Tags-Labels.md](./7-Tags-Labels.md)

---
