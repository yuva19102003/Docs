# Service Usage API

Programmatic management of Google Cloud APIs and services using the Service Usage API.

---

## 📚 Overview

The Service Usage API enables you to list, enable, disable, and get information about Google Cloud services programmatically. Essential for automation, infrastructure as code, and dynamic service management.

**Use Cases:**
- Automate API enablement in CI/CD pipelines
- Bulk enable APIs across multiple projects
- Monitor API usage and status
- Implement custom API management workflows
- Infrastructure as Code (Terraform, Pulumi)

---

## 🚀 Getting Started

### 1. Enable Service Usage API

```bash
# Enable the Service Usage API itself
gcloud services enable serviceusage.googleapis.com

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:admin@company.com' \
  --role='roles/serviceusage.serviceUsageAdmin'
```

### 2. Authentication

```python
from google.cloud import serviceusage_v1
from google.oauth2 import service_account

# Option 1: Application Default Credentials
client = serviceusage_v1.ServiceUsageClient()

# Option 2: Service Account Key
credentials = service_account.Credentials.from_service_account_file(
    'path/to/key.json'
)
client = serviceusage_v1.ServiceUsageClient(credentials=credentials)

# Option 3: Impersonation
from google.auth import impersonated_credentials
target_credentials = impersonated_credentials.Credentials(
    source_credentials=source_creds,
    target_principal='sa@project.iam.gserviceaccount.com',
    target_scopes=['https://www.googleapis.com/auth/cloud-platform']
)
client = serviceusage_v1.ServiceUsageClient(credentials=target_credentials)
```

---

## 📋 Common Operations

### 1. List Services

```python
from google.cloud import serviceusage_v1

def list_enabled_services(project_id):
    """List all enabled services"""
    client = serviceusage_v1.ServiceUsageClient()
    
    parent = f"projects/{project_id}"
    request = serviceusage_v1.ListServicesRequest(
        parent=parent,
        filter="state:ENABLED"
    )
    
    services = client.list_services(request=request)
    
    print(f"Enabled services in {project_id}:")
    for service in services:
        print(f"  - {service.config.name}: {service.config.title}")
    
    return list(services)

# List available services
def list_available_services(project_id):
    """List all available services"""
    client = serviceusage_v1.ServiceUsageClient()
    
    parent = f"projects/{project_id}"
    request = serviceusage_v1.ListServicesRequest(
        parent=parent,
        filter="state:ENABLED OR state:DISABLED"
    )
    
    services = client.list_services(request=request)
    return list(services)

# Usage
list_enabled_services("my-project-123")
```

### 2. Enable Services

```python
def enable_service(project_id, service_name):
    """Enable a GCP service"""
    client = serviceusage_v1.ServiceUsageClient()
    
    name = f"projects/{project_id}/services/{service_name}"
    request = serviceusage_v1.EnableServiceRequest(name=name)
    
    operation = client.enable_service(request=request)
    
    print(f"Enabling {service_name}...")
    response = operation.result()  # Wait for completion
    
    print(f"✓ {service_name} enabled")
    return response

# Enable multiple services
def enable_multiple_services(project_id, service_names):
    """Enable multiple services"""
    for service_name in service_names:
        try:
            enable_service(project_id, service_name)
        except Exception as e:
            print(f"✗ Failed to enable {service_name}: {e}")

# Usage
services_to_enable = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com"
]
enable_multiple_services("my-project-123", services_to_enable)
```

### 3. Disable Services

```python
def disable_service(project_id, service_name):
    """Disable a GCP service"""
    client = serviceusage_v1.ServiceUsageClient()
    
    name = f"projects/{project_id}/services/{service_name}"
    request = serviceusage_v1.DisableServiceRequest(name=name)
    
    operation = client.disable_service(request=request)
    
    print(f"Disabling {service_name}...")
    response = operation.result()
    
    print(f"✓ {service_name} disabled")
    return response

# ⚠️  Use with caution!
# disable_service("my-project-123", "compute.googleapis.com")
```

### 4. Get Service Details

```python
def get_service_details(project_id, service_name):
    """Get detailed information about a service"""
    client = serviceusage_v1.ServiceUsageClient()
    
    name = f"projects/{project_id}/services/{service_name}"
    request = serviceusage_v1.GetServiceRequest(name=name)
    
    service = client.get_service(request=request)
    
    print(f"Service: {service.config.name}")
    print(f"Title: {service.config.title}")
    print(f"State: {service.state.name}")
    print(f"Documentation: {service.config.documentation.summary}")
    
    return service

# Usage
get_service_details("my-project-123", "compute.googleapis.com")
```

---

## 🔧 Advanced Use Cases

### 1. Bulk Project Setup

```python
#!/usr/bin/env python3
"""
Bulk enable APIs across multiple projects
"""

from google.cloud import serviceusage_v1
from google.cloud import resourcemanager_v3
import concurrent.futures

def setup_project_apis(project_id, required_apis):
    """Enable required APIs for a project"""
    client = serviceusage_v1.ServiceUsageClient()
    
    results = []
    for api in required_apis:
        try:
            name = f"projects/{project_id}/services/{api}"
            request = serviceusage_v1.EnableServiceRequest(name=name)
            operation = client.enable_service(request=request)
            operation.result()  # Wait for completion
            results.append((api, "SUCCESS"))
            print(f"✓ {project_id}: {api} enabled")
        except Exception as e:
            results.append((api, f"FAILED: {e}"))
            print(f"✗ {project_id}: {api} failed - {e}")
    
    return results

def bulk_setup_projects(project_ids, required_apis):
    """Setup APIs for multiple projects in parallel"""
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        futures = {
            executor.submit(setup_project_apis, pid, required_apis): pid
            for pid in project_ids
        }
        
        for future in concurrent.futures.as_completed(futures):
            project_id = futures[future]
            try:
                results = future.result()
                print(f"\nCompleted: {project_id}")
            except Exception as e:
                print(f"\nFailed: {project_id} - {e}")

# Usage
projects = ["project-1", "project-2", "project-3"]
apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
]

bulk_setup_projects(projects, apis)
```

### 2. API Dependency Checker

```python
def check_api_dependencies(project_id, service_name):
    """Check if service dependencies are enabled"""
    client = serviceusage_v1.ServiceUsageClient()
    
    # Get service details
    name = f"projects/{project_id}/services/{service_name}"
    service = client.get_service(name=name)
    
    # Check dependencies (simplified - actual implementation would parse service config)
    dependencies = {
        "container.googleapis.com": [
            "compute.googleapis.com",
            "storage.googleapis.com",
            "logging.googleapis.com"
        ],
        "run.googleapis.com": [
            "compute.googleapis.com",
            "artifactregistry.googleapis.com"
        ]
    }
    
    if service_name in dependencies:
        print(f"Dependencies for {service_name}:")
        for dep in dependencies[service_name]:
            dep_name = f"projects/{project_id}/services/{dep}"
            try:
                dep_service = client.get_service(name=dep_name)
                status = "✓ ENABLED" if dep_service.state.name == "ENABLED" else "✗ DISABLED"
                print(f"  {dep}: {status}")
            except Exception as e:
                print(f"  {dep}: ✗ ERROR - {e}")
```

### 3. API Usage Monitor

```python
#!/usr/bin/env python3
"""
Monitor API enablement changes
"""

from google.cloud import serviceusage_v1
from google.cloud import logging_v2
from datetime import datetime, timedelta

def monitor_api_changes(project_id, hours=24):
    """Monitor API enablement/disablement in last N hours"""
    logging_client = logging_v2.Client(project=project_id)
    
    # Query logs for API changes
    filter_str = f'''
    protoPayload.methodName=~"ServiceUsage.(Enable|Disable)Service"
    AND timestamp >= "{(datetime.utcnow() - timedelta(hours=hours)).isoformat()}Z"
    '''
    
    entries = logging_client.list_entries(filter_=filter_str)
    
    changes = []
    for entry in entries:
        changes.append({
            'timestamp': entry.timestamp,
            'user': entry.payload.get('authenticationInfo', {}).get('principalEmail'),
            'action': entry.payload.get('methodName'),
            'service': entry.payload.get('request', {}).get('name')
        })
    
    print(f"API changes in last {hours} hours:")
    for change in changes:
        print(f"  {change['timestamp']}: {change['action']} by {change['user']}")
        print(f"    Service: {change['service']}")
    
    return changes

# Usage
monitor_api_changes("my-project-123", hours=24)
```

### 4. API Compliance Checker

```python
def check_api_compliance(project_id, required_apis, forbidden_apis):
    """Check if project complies with API policies"""
    client = serviceusage_v1.ServiceUsageClient()
    
    parent = f"projects/{project_id}"
    request = serviceusage_v1.ListServicesRequest(
        parent=parent,
        filter="state:ENABLED"
    )
    
    enabled_services = {s.config.name for s in client.list_services(request=request)}
    
    # Check required APIs
    missing_required = set(required_apis) - enabled_services
    if missing_required:
        print(f"❌ Missing required APIs:")
        for api in missing_required:
            print(f"  - {api}")
    
    # Check forbidden APIs
    forbidden_enabled = set(forbidden_apis) & enabled_services
    if forbidden_enabled:
        print(f"❌ Forbidden APIs enabled:")
        for api in forbidden_enabled:
            print(f"  - {api}")
    
    # Compliance status
    is_compliant = not missing_required and not forbidden_enabled
    print(f"\nCompliance: {'✓ PASS' if is_compliant else '✗ FAIL'}")
    
    return is_compliant

# Usage
required = [
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
]

forbidden = [
    "bigquery.googleapis.com",  # Example: Not allowed in this project
]

check_api_compliance("my-project-123", required, forbidden)
```

---

## 🔄 Integration Examples

### 1. Terraform Integration

```hcl
# Use Service Usage API via Terraform

# Enable services
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  
  project = var.project_id
  service = each.key
  
  disable_on_destroy = false
}

# Data source to check if service is enabled
data "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Conditional resource based on API status
resource "google_compute_instance" "vm" {
  count = data.google_project_service.compute.enabled ? 1 : 0
  # VM configuration
}
```

### 2. Cloud Build Integration

```yaml
# cloudbuild.yaml
steps:
  # Enable required APIs
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'services'
      - 'enable'
      - 'compute.googleapis.com'
      - 'storage.googleapis.com'
      - '--project=$PROJECT_ID'
  
  # Deploy application
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'my-service'
      - '--image=gcr.io/$PROJECT_ID/my-image'
```

### 3. Cloud Functions Integration

```python
# Cloud Function to auto-enable APIs
def enable_required_apis(event, context):
    """Cloud Function triggered by project creation"""
    from google.cloud import serviceusage_v1
    
    project_id = event['protoPayload']['request']['project']['projectId']
    
    required_apis = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com"
    ]
    
    client = serviceusage_v1.ServiceUsageClient()
    
    for api in required_apis:
        name = f"projects/{project_id}/services/{api}"
        request = serviceusage_v1.EnableServiceRequest(name=name)
        operation = client.enable_service(request=request)
        operation.result()
        print(f"Enabled {api} for {project_id}")
```

---

## ✅ Best Practices

### Development
- [ ] Use Service Usage API for automation
- [ ] Implement error handling and retries
- [ ] Log all API operations
- [ ] Use async operations for bulk changes
- [ ] Test in non-production first

### Security
- [ ] Use service accounts with minimal permissions
- [ ] Implement audit logging
- [ ] Monitor API enablement changes
- [ ] Restrict who can enable/disable APIs
- [ ] Use IAM conditions for temporary access

### Operations
- [ ] Document API dependencies
- [ ] Automate API enablement in CI/CD
- [ ] Monitor API usage and quotas
- [ ] Regular compliance checks
- [ ] Have rollback procedures

---

## 🎓 Next Steps

1. Set up [API Monitoring](./6-API-Monitoring.md) for observability
2. Return to [Enabling APIs](./2-Enabling-APIs.md) for manual methods
3. Review [Service Quotas](./3-Service-Quotas.md) for limits
4. Explore [API Gateway](./4-API-Gateway.md) for API management

---

**Last Updated:** March 2026
**Version:** 2.0
