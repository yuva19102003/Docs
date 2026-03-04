# Enabling APIs

Complete guide to enabling, managing, and configuring Google Cloud APIs for your projects.

---

## 📚 Overview

Before using any GCP service, you must enable its API. This guide covers all methods of enabling APIs, managing dependencies, and troubleshooting common issues.

**Key Concepts:**
- **API Enablement**: Per-project activation of services
- **Dependencies**: Automatic enabling of required APIs
- **Billing**: Some APIs require billing to be enabled
- **Quotas**: Default limits applied when APIs are enabled

---

## 🎯 Understanding API Enablement

### 1. Why Enable APIs?

```
┌────────────────────────────────────────────────────────┐
│  API Enablement Model                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose:                                              │
│  • Security: Explicit opt-in for services              │
│  • Cost Control: Only pay for what you use            │
│  • Compliance: Track which services are used           │
│  • Quotas: Apply appropriate limits                    │
│                                                         │
│  Scope:                                                │
│  • APIs are enabled PER PROJECT                        │
│  • No inheritance from organization/folder             │
│  • Each project has independent API configuration      │
│                                                         │
│  Billing Requirement:                                  │
│  • Some APIs require billing account                   │
│  • Free tier available for many services               │
│  • Billing must be linked before enabling              │
└────────────────────────────────────────────────────────┘
```

### 2. API Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│  API Lifecycle States                                            │
└─────────────────────────────────────────────────────────────────┘

State 1: Not Enabled (Default)
┌─────────────────────────────────┐
│ • API not available             │
│ • No quota allocated            │
│ • No charges                    │
│ • Cannot use service            │
└────────────┬────────────────────┘
             │ Enable API
             ▼
State 2: Enabled
┌─────────────────────────────────┐
│ • API available for use         │
│ • Quotas allocated              │
│ • Usage tracked                 │
│ • Charges may apply             │
└────────────┬────────────────────┘
             │ Disable API
             ▼
State 3: Disabled
┌─────────────────────────────────┐
│ • API no longer available       │
│ • Existing resources remain     │
│ • No new resources can be made  │
│ • Can re-enable anytime         │
└─────────────────────────────────┘

Note: Disabling an API doesn't delete existing resources
```

---

## 🚀 Enabling APIs

### 1. Via Console (UI)

```
Method 1: API Library
─────────────────────
Navigation: APIs & Services → Library

Steps:
1. Search for API (e.g., "Compute Engine")
2. Click on API card
3. Click "Enable" button
4. Wait for enablement (usually instant)
5. API is now available

Method 2: From Service Page
────────────────────────────
Navigation: Specific service (e.g., Compute Engine)

Steps:
1. Navigate to service
2. If API not enabled, see prompt
3. Click "Enable API" button
4. API enables automatically

Method 3: Quick Enable
──────────────────────
Navigation: APIs & Services → Dashboard

Steps:
1. Click "+ Enable APIs and Services"
2. Search and select API
3. Click "Enable"
```

### 2. Via gcloud CLI

```bash
# Enable single API
gcloud services enable compute.googleapis.com

# Enable multiple APIs at once
gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com \
  sqladmin.googleapis.com \
  container.googleapis.com

# Enable API for specific project
gcloud services enable compute.googleapis.com \
  --project=my-project-123

# Enable with async (don't wait for completion)
gcloud services enable compute.googleapis.com --async

# Check if API is enabled
gcloud services list --enabled \
  --filter="name:compute.googleapis.com"
```

### 3. Via Terraform

```hcl
# Enable single API
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  # Don't disable on destroy (recommended)
  disable_on_destroy = false
  
  # Disable dependent services on destroy
  disable_dependent_services = false
}

# Enable multiple APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
  ])
  
  project = var.project_id
  service = each.key
  
  disable_on_destroy = false
}

# Enable with dependencies
resource "google_project_service" "gke" {
  project = var.project_id
  service = "container.googleapis.com"
  
  disable_on_destroy         = false
  disable_dependent_services = false
}

# GKE automatically enables:
# - compute.googleapis.com
# - storage.googleapis.com
# - logging.googleapis.com
# - monitoring.googleapis.com
```

### 4. Via REST API

```bash
# Enable API using REST API
curl -X POST \
  "https://serviceusage.googleapis.com/v1/projects/PROJECT_ID/services/compute.googleapis.com:enable" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json"

# Check operation status
curl -X GET \
  "https://serviceusage.googleapis.com/v1/operations/OPERATION_NAME" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)"
```

### 5. Via Python SDK

```python
from google.cloud import serviceusage_v1

def enable_api(project_id, service_name):
    """Enable a GCP API"""
    client = serviceusage_v1.ServiceUsageClient()
    
    # Format: projects/PROJECT_ID/services/SERVICE_NAME
    name = f"projects/{project_id}/services/{service_name}"
    
    # Enable the service
    operation = client.enable_service(name=name)
    
    # Wait for operation to complete
    response = operation.result()
    
    print(f"Enabled {service_name}")
    return response

# Usage
enable_api("my-project-123", "compute.googleapis.com")
```

---

## 🔗 API Dependencies

### 1. Understanding Dependencies

```
┌────────────────────────────────────────────────────────┐
│  API Dependency Example: GKE                           │
└────────────────────────────────────────────────────────┘

Enable: container.googleapis.com (GKE)
      │
      ├─ Automatically enables:
      │
      ├─→ compute.googleapis.com
      │   └─ Required for VM nodes
      │
      ├─→ storage.googleapis.com
      │   └─ Required for container images
      │
      ├─→ logging.googleapis.com
      │   └─ Required for cluster logs
      │
      └─→ monitoring.googleapis.com
          └─ Required for cluster metrics

Result: 5 APIs enabled with one command
```

### 2. Common API Dependencies

```
Cloud Run:
  container.googleapis.com
  ├─→ compute.googleapis.com
  ├─→ storage.googleapis.com
  └─→ artifactregistry.googleapis.com

Cloud Functions:
  cloudfunctions.googleapis.com
  ├─→ cloudbuild.googleapis.com
  ├─→ storage.googleapis.com
  └─→ logging.googleapis.com

Cloud SQL:
  sqladmin.googleapis.com
  ├─→ compute.googleapis.com
  └─→ servicenetworking.googleapis.com

App Engine:
  appengine.googleapis.com
  ├─→ storage.googleapis.com
  ├─→ compute.googleapis.com
  └─→ cloudresourcemanager.googleapis.com
```

### 3. Checking Dependencies

```bash
# List all enabled APIs (including dependencies)
gcloud services list --enabled

# Check specific API dependencies
gcloud services describe compute.googleapis.com

# List APIs that depend on a service
gcloud services list --enabled \
  --filter="config.name:compute"
```

---

## 📋 Managing APIs

### 1. Listing APIs

```bash
# List all available APIs
gcloud services list --available

# List enabled APIs
gcloud services list --enabled

# List with specific format
gcloud services list --enabled \
  --format="table(config.name,config.title)"

# Count enabled APIs
gcloud services list --enabled --format="value(config.name)" | wc -l

# Search for specific API
gcloud services list --available \
  --filter="config.name:compute"

# List APIs with details
gcloud services list --enabled \
  --format="table(config.name,config.title,state)"
```

### 2. Disabling APIs

```bash
# Disable API (use with caution!)
gcloud services disable compute.googleapis.com

# Disable with force (skip dependency check)
gcloud services disable compute.googleapis.com --force

# Disable multiple APIs
gcloud services disable \
  compute.googleapis.com \
  storage.googleapis.com

# ⚠️  WARNING: Disabling APIs can break applications
# • Existing resources remain but can't be managed
# • New resources can't be created
# • Applications may fail
# • Consider carefully before disabling
```

### 3. API Status

```bash
# Check if specific API is enabled
gcloud services list --enabled \
  --filter="config.name=compute.googleapis.com"

# Get API details
gcloud services describe compute.googleapis.com

# Check API state
gcloud services describe compute.googleapis.com \
  --format="value(state)"
```

---

## 🎯 Common API Patterns

### Pattern 1: New Project Setup

```bash
#!/bin/bash
# Enable essential APIs for new project

PROJECT_ID="my-new-project"

echo "Enabling essential APIs for $PROJECT_ID..."

# Core infrastructure APIs
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  serviceusage.googleapis.com \
  --project=$PROJECT_ID

# Compute and networking
gcloud services enable \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  dns.googleapis.com \
  --project=$PROJECT_ID

# Storage
gcloud services enable \
  storage.googleapis.com \
  --project=$PROJECT_ID

# Monitoring and logging
gcloud services enable \
  monitoring.googleapis.com \
  logging.googleapis.com \
  cloudtrace.googleapis.com \
  --project=$PROJECT_ID

# Container services
gcloud services enable \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  --project=$PROJECT_ID

echo "✓ Essential APIs enabled"
```

### Pattern 2: Web Application Stack

```bash
#!/bin/bash
# Enable APIs for web application

PROJECT_ID="web-app-prod"

# Frontend hosting
gcloud services enable \
  storage.googleapis.com \
  cdn.googleapis.com \
  --project=$PROJECT_ID

# Backend compute
gcloud services enable \
  compute.googleapis.com \
  run.googleapis.com \
  --project=$PROJECT_ID

# Database
gcloud services enable \
  sqladmin.googleapis.com \
  redis.googleapis.com \
  --project=$PROJECT_ID

# Secrets and configuration
gcloud services enable \
  secretmanager.googleapis.com \
  --project=$PROJECT_ID

# Monitoring
gcloud services enable \
  monitoring.googleapis.com \
  logging.googleapis.com \
  cloudprofiler.googleapis.com \
  --project=$PROJECT_ID

echo "✓ Web application APIs enabled"
```

### Pattern 3: Data Analytics Platform

```bash
#!/bin/bash
# Enable APIs for data analytics

PROJECT_ID="data-analytics"

# Data warehouse
gcloud services enable \
  bigquery.googleapis.com \
  bigquerystorage.googleapis.com \
  bigquerydatatransfer.googleapis.com \
  --project=$PROJECT_ID

# Data processing
gcloud services enable \
  dataflow.googleapis.com \
  dataproc.googleapis.com \
  --project=$PROJECT_ID

# Data ingestion
gcloud services enable \
  pubsub.googleapis.com \
  --project=$PROJECT_ID

# Storage
gcloud services enable \
  storage.googleapis.com \
  --project=$PROJECT_ID

# ML and AI
gcloud services enable \
  aiplatform.googleapis.com \
  notebooks.googleapis.com \
  --project=$PROJECT_ID

echo "✓ Data analytics APIs enabled"
```

---

## 🔧 Troubleshooting

### Common Issues

**Issue: "API not enabled" error**
```bash
# Error message:
# "API [compute.googleapis.com] not enabled on project [PROJECT_ID]"

# Solution: Enable the API
gcloud services enable compute.googleapis.com --project=PROJECT_ID

# Verify enablement
gcloud services list --enabled \
  --filter="config.name:compute" \
  --project=PROJECT_ID
```

**Issue: "Billing must be enabled"**
```bash
# Error message:
# "Billing must be enabled for activation of service"

# Solution: Link billing account
gcloud billing projects link PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID

# Verify billing
gcloud billing projects describe PROJECT_ID

# Then enable API
gcloud services enable compute.googleapis.com
```

**Issue: "Permission denied"**
```bash
# Error message:
# "Permission 'serviceusage.services.enable' denied"

# Solution: Grant required role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/serviceusage.serviceUsageAdmin'

# Or use Editor/Owner role (not recommended)
```

**Issue: API enablement takes too long**
```bash
# Some APIs take time to enable (especially first time)

# Check operation status
gcloud services operations list

# Use async flag to not wait
gcloud services enable compute.googleapis.com --async

# Check if enabled
gcloud services list --enabled --filter="config.name:compute"
```

**Issue: Dependency conflicts**
```bash
# Error when disabling API with dependencies

# List dependent services
gcloud services list --enabled \
  --filter="config.name:compute"

# Disable with force (use carefully!)
gcloud services disable compute.googleapis.com --force

# Or disable dependent services first
```

---

## 📊 Monitoring API Usage

### 1. API Dashboard

```
Navigation: APIs & Services → Dashboard

View:
• Enabled APIs count
• API requests (last 30 days)
• Errors and latency
• Top APIs by traffic
• Quota usage
```

### 2. API Metrics

```bash
# View API metrics in Cloud Monitoring
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count"' \
  --format=json

# Query specific API usage
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND resource.labels.service="compute.googleapis.com"'
```

### 3. API Logs

```bash
# View API enablement logs
gcloud logging read \
  'protoPayload.methodName="google.api.serviceusage.v1.ServiceUsage.EnableService"' \
  --limit=50

# View API usage logs
gcloud logging read \
  'protoPayload.serviceName="compute.googleapis.com"' \
  --limit=50 \
  --format=json
```

---

## 🔐 Security Best Practices

### 1. Principle of Least Privilege

```bash
# Only enable APIs you actually need
# Don't enable "just in case"

# ❌ BAD: Enable everything
gcloud services list --available | \
  grep -v "NAME" | \
  awk '{print $1}' | \
  xargs -I {} gcloud services enable {}

# ✓ GOOD: Enable only what's needed
gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com
```

### 2. API Access Control

```bash
# Restrict who can enable APIs
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:platform-team@company.com' \
  --role='roles/serviceusage.serviceUsageAdmin'

# Separate read and write permissions
# Viewer: Can list APIs
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/serviceusage.serviceUsageViewer'

# Admin: Can enable/disable APIs
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:platform-admins@company.com' \
  --role='roles/serviceusage.serviceUsageAdmin'
```

### 3. Audit API Changes

```bash
# Set up alerting for API enablement
gcloud logging sinks create api-changes \
  --log-filter='protoPayload.methodName=~"ServiceUsage.(Enable|Disable)Service"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/api-changes

# Monitor API enablement
gcloud logging read \
  'protoPayload.methodName="google.api.serviceusage.v1.ServiceUsage.EnableService"' \
  --limit=50 \
  --format='table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.request.name)'
```

---

## 📋 API Enablement Checklist

### Before Enabling
- [ ] Verify API is needed
- [ ] Check billing requirements
- [ ] Review quotas and limits
- [ ] Understand dependencies
- [ ] Check IAM permissions
- [ ] Review pricing

### During Enablement
- [ ] Enable via appropriate method
- [ ] Verify successful enablement
- [ ] Check dependent APIs enabled
- [ ] Test API access
- [ ] Configure quotas if needed
- [ ] Document enablement

### After Enabling
- [ ] Monitor API usage
- [ ] Set up alerts for errors
- [ ] Review costs regularly
- [ ] Audit access logs
- [ ] Update documentation
- [ ] Train team on usage

---

## 🎓 Next Steps

1. Learn about [Service Quotas](./3-Service-Quotas.md) and limits
2. Explore [API Gateway](./4-API-Gateway.md) for API management
3. Use [Service Usage API](./5-Service-Usage-API.md) for automation
4. Set up [API Monitoring](./6-API-Monitoring.md) for observability

---

**Last Updated:** March 2026
**Version:** 2.0
