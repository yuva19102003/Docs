# 5️⃣ API & Service Management

Complete guide to enabling, managing, and monitoring Google Cloud APIs and services.

---

## 📚 What You'll Learn

Master GCP API management to control service access and usage:

- **API Enablement**: Activate services for your projects
- **Service Management**: Control API access and configuration
- **Quota Management**: Monitor and adjust usage limits
- **API Gateway**: Expose and manage APIs
- **Monitoring**: Track API usage and performance

---

## 📖 Table of Contents

### [1. Service APIs](./1-Service-APIs.md)
**Understanding GCP APIs**

```
Topics Covered:
  • What are GCP APIs
  • API architecture
  • Service endpoints
  • API versioning
  • API discovery
  • Common APIs overview
  • API dependencies
```

**Key Concepts:**
- 200+ Google Cloud APIs
- RESTful and gRPC APIs
- API Library
- Service activation

---

### [2. Enabling APIs](./2-Enabling-APIs.md)
**Activating Services**

```
Topics Covered:
  • Enabling APIs via Console
  • Enabling APIs via gcloud
  • Enabling APIs via Terraform
  • Bulk API enablement
  • API dependencies
  • Disabling APIs
  • API status monitoring
```

**Key Concepts:**
- Per-project enablement
- Automatic dependency resolution
- API activation time
- Billing requirements

---

### [3. Service Quotas](./3-Service-Quotas.md)
**Managing Usage Limits**

```
Topics Covered:
  • Understanding quotas
  • Rate limits vs allocation quotas
  • Viewing quotas
  • Requesting quota increases
  • Quota monitoring
  • Quota alerts
  • Best practices
```

**Key Concepts:**
- Default quotas
- Project-level limits
- Regional quotas
- Quota management

---

### [4. API Gateway](./4-API-Gateway.md)
**Exposing and Managing APIs**

```
Topics Covered:
  • API Gateway overview
  • Creating API configs
  • Deploying APIs
  • Authentication and authorization
  • Rate limiting
  • Monitoring and logging
  • Custom domains
```

**Key Concepts:**
- API management
- OpenAPI specifications
- Backend routing
- Security policies

---

### [5. Service Usage API](./5-Service-Usage-API.md)
**Programmatic API Management**

```
Topics Covered:
  • Service Usage API overview
  • Listing enabled services
  • Enabling services programmatically
  • Disabling services
  • Batch operations
  • Automation examples
  • API usage tracking
```

**Key Concepts:**
- Programmatic control
- Automation
- CI/CD integration
- Infrastructure as Code

---

### [6. API Monitoring](./6-API-Monitoring.md)
**Tracking API Usage**

```
Topics Covered:
  • API metrics
  • Usage dashboards
  • Error tracking
  • Latency monitoring
  • Cost analysis
  • Alerting
  • Troubleshooting
```

**Key Concepts:**
- Cloud Monitoring integration
- API analytics
- Performance optimization
- Cost control

---

## 🔧 API Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP API Architecture                          │
└─────────────────────────────────────────────────────────────────┘

Client Application
      │
      ├─ Authentication (API Key, OAuth, Service Account)
      │
      ▼
┌─────────────────┐
│  API Endpoint   │  ← https://SERVICE.googleapis.com
│  (Load Balanced)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  API Gateway    │  ← Rate limiting, authentication
│  (Google Front  │     Request validation
│   End)          │     Routing
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Service API    │  ← Compute Engine API
│  (Backend)      │     Cloud Storage API
│                 │     BigQuery API, etc.
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GCP Service    │  ← Actual service implementation
│  (Resources)    │     VMs, Buckets, Datasets, etc.
└─────────────────┘

Flow:
1. Client makes API request
2. Authentication verified
3. API Gateway validates and routes
4. Service API processes request
5. Service performs action
6. Response returned to client
```

---

## 💡 Key Concepts

### 1. API Enablement Model

```
┌────────────────────────────────────────────────────────┐
│  API Enablement Hierarchy                              │
└────────────────────────────────────────────────────────┘

Organization
├─ No APIs enabled at org level
│
Folder
├─ No APIs enabled at folder level
│
Project: web-prod-2026
├─ APIs are enabled PER PROJECT
│
├─ Enabled APIs:
│  ├─ compute.googleapis.com (Compute Engine)
│  ├─ storage.googleapis.com (Cloud Storage)
│  ├─ sqladmin.googleapis.com (Cloud SQL)
│  ├─ container.googleapis.com (GKE)
│  └─ monitoring.googleapis.com (Cloud Monitoring)
│
└─ Each project has independent API configuration

Key Points:
  • APIs enabled per project
  • No inheritance from parent
  • Each project pays for its API usage
  • Can enable same API in multiple projects
```

### 2. Common GCP APIs

```
┌────────────────────────────────────────────────────────┐
│  Most Used GCP APIs                                    │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute & Containers:                                 │
│  • compute.googleapis.com (Compute Engine)             │
│  • container.googleapis.com (GKE)                      │
│  • run.googleapis.com (Cloud Run)                      │
│  • appengine.googleapis.com (App Engine)               │
│                                                         │
│  Storage:                                              │
│  • storage.googleapis.com (Cloud Storage)              │
│  • file.googleapis.com (Filestore)                     │
│                                                         │
│  Databases:                                            │
│  • sqladmin.googleapis.com (Cloud SQL)                 │
│  • spanner.googleapis.com (Cloud Spanner)              │
│  • firestore.googleapis.com (Firestore)                │
│  • bigtable.googleapis.com (Bigtable)                  │
│                                                         │
│  Networking:                                           │
│  • servicenetworking.googleapis.com                    │
│  • dns.googleapis.com (Cloud DNS)                      │
│  • networkservices.googleapis.com                      │
│                                                         │
│  Data & Analytics:                                     │
│  • bigquery.googleapis.com (BigQuery)                  │
│  • dataflow.googleapis.com (Dataflow)                  │
│  • pubsub.googleapis.com (Pub/Sub)                     │
│                                                         │
│  Management:                                           │
│  • cloudresourcemanager.googleapis.com                 │
│  • iam.googleapis.com (IAM)                            │
│  • monitoring.googleapis.com (Monitoring)              │
│  • logging.googleapis.com (Logging)                    │
└────────────────────────────────────────────────────────┘
```

### 3. API Dependencies

```
┌────────────────────────────────────────────────────────┐
│  API Dependency Example: GKE                           │
└────────────────────────────────────────────────────────┘

Enable: container.googleapis.com (GKE)
      │
      ├─ Automatically enables:
      │
      ├─→ compute.googleapis.com (Compute Engine)
      │   └─ Required for VM nodes
      │
      ├─→ storage.googleapis.com (Cloud Storage)
      │   └─ Required for container images
      │
      ├─→ logging.googleapis.com (Cloud Logging)
      │   └─ Required for cluster logs
      │
      └─→ monitoring.googleapis.com (Cloud Monitoring)
          └─ Required for cluster metrics

When you enable GKE API:
  ✓ All dependencies enabled automatically
  ✓ No manual intervention needed
  ✓ Ensures service works correctly
```

---

## 🚀 Quick Start Guide

### Step 1: List Available APIs

```bash
# List all available APIs
gcloud services list --available

# Search for specific API
gcloud services list --available --filter="name:compute"

# List with details
gcloud services list --available \
  --format="table(name,title)"
```

### Step 2: Enable APIs

```bash
# Enable single API
gcloud services enable compute.googleapis.com

# Enable multiple APIs
gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com \
  sqladmin.googleapis.com

# Enable with project specification
gcloud services enable compute.googleapis.com \
  --project=web-prod-2026
```

### Step 3: List Enabled APIs

```bash
# List enabled APIs in current project
gcloud services list --enabled

# List with filter
gcloud services list --enabled \
  --filter="name:compute"

# Count enabled APIs
gcloud services list --enabled --format="value(name)" | wc -l
```

### Step 4: Check API Status

```bash
# Check if specific API is enabled
gcloud services list --enabled \
  --filter="name:compute.googleapis.com"

# Get API details
gcloud services describe compute.googleapis.com
```

### Step 5: View Quotas

```bash
# View quotas (via Console)
# Navigation: IAM & Admin → Quotas

# List quotas for service
gcloud compute project-info describe \
  --project=PROJECT_ID
```

---

## 📊 API Enablement Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  API Enablement Process                                          │
└─────────────────────────────────────────────────────────────────┘

Step 1: Identify Required APIs
┌─────────────────────────────────┐
│ • What services do you need?    │
│ • Check documentation           │
│ • Review dependencies           │
└────────────┬────────────────────┘
             │
             ▼
Step 2: Check Billing
┌─────────────────────────────────┐
│ • Billing account linked?       │
│ • Some APIs require billing     │
│ • Free tier available           │
└────────────┬────────────────────┘
             │
             ▼
Step 3: Enable APIs
┌─────────────────────────────────┐
│ • Via Console (UI)              │
│ • Via gcloud (CLI)              │
│ • Via Terraform (IaC)           │
│ • Dependencies auto-enabled     │
└────────────┬────────────────────┘
             │
             ▼
Step 4: Configure Credentials
┌─────────────────────────────────┐
│ • API keys (simple)             │
│ • OAuth 2.0 (user auth)         │
│ • Service accounts (apps)       │
│ • Application Default Creds     │
└────────────┬────────────────────┘
             │
             ▼
Step 5: Test API Access
┌─────────────────────────────────┐
│ • Make test API call            │
│ • Verify permissions            │
│ • Check quotas                  │
│ • Monitor usage                 │
└─────────────────────────────────┘
```

---

## 💰 API Costs

### Pricing Model

```
┌────────────────────────────────────────────────────────┐
│  API Pricing Structure                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Free APIs (No charge):                                │
│  • Cloud Resource Manager API                          │
│  • IAM API                                             │
│  • Service Usage API                                   │
│  • Cloud Billing API                                   │
│                                                         │
│  Usage-Based Pricing:                                  │
│  • Compute Engine API (charged for VMs created)        │
│  • Cloud Storage API (charged for storage used)        │
│  • BigQuery API (charged for queries)                  │
│                                                         │
│  API Call Pricing:                                     │
│  • Some APIs charge per API call                       │
│  • Usually very low cost                               │
│  • Free tier often available                           │
│                                                         │
│  Example: Maps API                                     │
│  • $5 per 1,000 requests                               │
│  • $200 free credit monthly                            │
└────────────────────────────────────────────────────────┘
```

---

## 🔒 API Security

### Authentication Methods

```
┌────────────────────────────────────────────────────────┐
│  API Authentication Options                            │
└────────────────────────────────────────────────────────┘

1. API Keys
├─ Simple authentication
├─ Public APIs only
├─ No user context
└─ Example: Maps API, Translation API

2. OAuth 2.0
├─ User authentication
├─ Delegated access
├─ Scoped permissions
└─ Example: Gmail API, Drive API

3. Service Accounts
├─ Application authentication
├─ Server-to-server
├─ No user interaction
└─ Example: Compute Engine, Cloud Storage

4. Application Default Credentials (ADC)
├─ Automatic credential discovery
├─ Works in multiple environments
├─ Recommended for applications
└─ Fallback chain: env var → metadata → gcloud

Best Practices:
  ✓ Use service accounts for applications
  ✓ Use OAuth for user-facing apps
  ✓ Avoid API keys when possible
  ✓ Rotate credentials regularly
  ✓ Use least privilege permissions
```

---

## 📈 Quota Management

### Quota Types

```
┌────────────────────────────────────────────────────────┐
│  Quota Categories                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Rate Quotas (per minute/day):                        │
│  • API requests per minute                             │
│  • Queries per day                                     │
│  • Writes per second                                   │
│  • Resets automatically                                │
│                                                         │
│  Allocation Quotas (total resources):                  │
│  • Number of VMs                                       │
│  • Total CPUs                                          │
│  • Persistent disk size                                │
│  • Requires quota increase request                     │
│                                                         │
│  Regional Quotas:                                      │
│  • Per-region limits                                   │
│  • Independent across regions                          │
│  • Example: 24 CPUs per region                        │
│                                                         │
│  Global Quotas:                                        │
│  • Project-wide limits                                 │
│  • Across all regions                                  │
│  • Example: 100 Cloud SQL instances                    │
└────────────────────────────────────────────────────────┘
```

### Common Quotas

```
┌────────────────────────────────────────────────────────┐
│  Default Quotas (Examples)                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine:                                       │
│  • CPUs: 24 per region                                 │
│  • Persistent Disk: 10 TB per region                   │
│  • In-use IP addresses: 8 per region                   │
│  • VM instances: Varies by type                        │
│                                                         │
│  Cloud Storage:                                        │
│  • Buckets: 10,000 per project                         │
│  • Objects: Unlimited                                  │
│  • Bandwidth: 200 Gbps egress                          │
│                                                         │
│  BigQuery:                                             │
│  • Queries per day: Unlimited                          │
│  • Concurrent queries: 100                             │
│  • Slots: 2,000 (on-demand)                            │
│                                                         │
│  Cloud SQL:                                            │
│  • Instances: 100 per project                          │
│  • Storage: 30 TB per instance                         │
│  • Connections: Varies by tier                         │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Automation Examples

### Terraform

```hcl
# Enable APIs with Terraform
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"
  
  disable_on_destroy = false
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
```

### Python

```python
from googleapiclient import discovery
from google.oauth2 import service_account

# Initialize Service Usage API client
credentials = service_account.Credentials.from_service_account_file(
    'service-account-key.json'
)

service = discovery.build(
    'serviceusage', 'v1',
    credentials=credentials
)

# Enable API
project = 'projects/my-project-123'
api = 'compute.googleapis.com'

request = service.services().enable(
    name=f'{project}/services/{api}'
)
response = request.execute()
print(f'Enabled {api}')

# List enabled services
request = service.services().list(
    parent=project,
    filter='state:ENABLED'
)
response = request.execute()

for service_item in response.get('services', []):
    print(service_item['config']['name'])
```

### Bash Script

```bash
#!/bin/bash
# Bulk enable APIs for new project

PROJECT_ID="web-prod-2026"
APIS=(
  "compute.googleapis.com"
  "storage.googleapis.com"
  "sqladmin.googleapis.com"
  "container.googleapis.com"
  "monitoring.googleapis.com"
  "logging.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "iam.googleapis.com"
)

echo "Enabling APIs for project: $PROJECT_ID"

for api in "${APIS[@]}"; do
  echo "Enabling $api..."
  gcloud services enable $api --project=$PROJECT_ID
  
  if [ $? -eq 0 ]; then
    echo "✓ $api enabled successfully"
  else
    echo "✗ Failed to enable $api"
  fi
done

echo "API enablement complete!"

# List enabled APIs
echo -e "\nEnabled APIs:"
gcloud services list --enabled --project=$PROJECT_ID
```

---

## 📋 Best Practices

### 1. API Management

```
✓ Enable only required APIs
✓ Document why each API is needed
✓ Use Infrastructure as Code (Terraform)
✓ Disable unused APIs
✓ Monitor API usage
✓ Set up quota alerts
✓ Review API costs regularly
✓ Use API versioning appropriately
```

### 2. Security

```
✓ Use service accounts for applications
✓ Implement least privilege
✓ Rotate credentials regularly
✓ Use VPC Service Controls
✓ Enable audit logging
✓ Monitor for unusual API activity
✓ Restrict API access by IP (when possible)
✓ Use API keys only for public APIs
```

### 3. Cost Optimization

```
✓ Understand API pricing
✓ Use caching to reduce API calls
✓ Implement retry logic with backoff
✓ Monitor API usage and costs
✓ Set budget alerts
✓ Use batch operations when available
✓ Optimize query patterns
✓ Review and remove unused APIs
```

### 4. Performance

```
✓ Use regional endpoints when possible
✓ Implement connection pooling
✓ Use gRPC for better performance
✓ Enable compression
✓ Implement proper error handling
✓ Use exponential backoff for retries
✓ Monitor API latency
✓ Optimize payload sizes
```

---

## 🔍 Troubleshooting

### Common Issues

```
Issue: API not enabled error
Solution:
  • Enable the API: gcloud services enable API_NAME
  • Check billing account is linked
  • Verify you have permission to enable APIs
  • Wait a few minutes for propagation

Issue: Quota exceeded
Solution:
  • Check current quota usage
  • Request quota increase
  • Optimize API usage
  • Implement rate limiting
  • Use multiple projects if needed

Issue: Permission denied
Solution:
  • Verify API is enabled
  • Check IAM permissions
  • Verify service account has correct roles
  • Check organization policies
  • Review VPC Service Controls

Issue: API calls failing
Solution:
  • Check API status (status.cloud.google.com)
  • Verify credentials are valid
  • Check network connectivity
  • Review error messages
  • Enable audit logging for debugging
```

---

## 📚 Additional Resources

### Documentation
- [GCP API Library](https://console.cloud.google.com/apis/library)
- [API Reference](https://cloud.google.com/apis/docs/overview)
- [Service Usage API](https://cloud.google.com/service-usage/docs)
- [Quotas](https://cloud.google.com/docs/quota)

### Tools
- [API Explorer](https://developers.google.com/apis-explorer)
- [gcloud CLI](https://cloud.google.com/sdk/gcloud)
- [Client Libraries](https://cloud.google.com/apis/docs/cloud-client-libraries)

---

## 🎓 Next Steps

After mastering API & Service Management:

1. **Compute Services** - Deploy workloads
2. **Networking** - Connect services
3. **Storage & Databases** - Store data
4. **Monitoring** - Track performance
5. **Security** - Secure APIs

---

**Last Updated:** March 2026
**Version:** 2.0
