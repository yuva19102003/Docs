# Service Accounts

Complete guide to service accounts - the identity system for applications and workloads in Google Cloud Platform.

---

## 📚 Overview

Service accounts are special Google accounts that represent applications and services rather than human users. They enable secure, automated access to GCP resources.

**Key Concepts:**
- **Application Identity**: Non-human accounts for workloads
- **Authentication**: How applications prove their identity
- **Authorization**: What service accounts can access
- **Key Management**: Securing service account credentials

---

## 🤖 What is a Service Account?

```
┌────────────────────────────────────────────────────────┐
│  Service Account vs User Account                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  User Account:                                         │
│  • alice@company.com                                   │
│  • Represents a human                                  │
│  • Interactive login                                   │
│  • MFA, password                                       │
│  • Used by people                                      │
│                                                         │
│  Service Account:                                      │
│  • my-app@project-id.iam.gserviceaccount.com          │
│  • Represents an application                           │
│  • Non-interactive                                     │
│  • Key-based or token-based auth                       │
│  • Used by code/workloads                              │
│                                                         │
│  Common Use Cases:                                     │
│  ✓ Application running on Compute Engine               │
│  ✓ Cloud Function accessing Cloud Storage              │
│  ✓ GKE pod connecting to Cloud SQL                     │
│  ✓ CI/CD pipeline deploying resources                  │
│  ✓ Scheduled jobs accessing BigQuery                   │
└────────────────────────────────────────────────────────┘
```

---

## 🎯 Service Account Types

### 1. User-Managed Service Accounts

```
┌────────────────────────────────────────────────────────┐
│  User-Managed Service Accounts                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Created by: You (the user)                            │
│  Format: NAME@PROJECT_ID.iam.gserviceaccount.com       │
│  Limit: 100 per project                                │
│                                                         │
│  Characteristics:                                      │
│  • You control lifecycle                               │
│  • You manage permissions                              │
│  • You handle keys (if needed)                         │
│  • Can be used across projects                         │
│                                                         │
│  Example:                                              │
│  backend-api@web-prod-2026.iam.gserviceaccount.com     │
│                                                         │
│  Best For:                                             │
│  • Application-specific identity                       │
│  • Fine-grained access control                         │
│  • Cross-project access                                │
└────────────────────────────────────────────────────────┘
```

### 2. Default Service Accounts

```
┌────────────────────────────────────────────────────────┐
│  Default Service Accounts                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine Default:                               │
│  PROJECT_NUMBER-compute@developer.gserviceaccount.com  │
│  • Auto-created with project                           │
│  • Has Editor role by default (⚠️  too permissive)     │
│  • Used by VMs if no SA specified                      │
│                                                         │
│  App Engine Default:                                   │
│  PROJECT_ID@appspot.gserviceaccount.com                │
│  • Auto-created with App Engine                        │
│  • Has Editor role by default                          │
│                                                         │
│  ⚠️  WARNING: Default SAs are over-privileged          │
│  ✓  Create custom SAs with minimal permissions         │
│  ✓  Never use default SAs in production                │
│  ✓  Disable if not needed                              │
└────────────────────────────────────────────────────────┘
```

### 3. Google-Managed Service Accounts

```
┌────────────────────────────────────────────────────────┐
│  Google-Managed Service Accounts                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Created by: Google services automatically             │
│  Format: service-PROJECT_NUMBER@*.iam.gserviceaccount.com │
│  Visibility: Hidden by default                         │
│                                                         │
│  Examples:                                             │
│  • service-123@compute-system.iam.gserviceaccount.com  │
│  • service-123@container-engine-robot.iam.gserviceaccount.com │
│                                                         │
│  Purpose:                                              │
│  • Internal Google service operations                  │
│  • You don't manage these                              │
│  • Automatically configured                            │
│                                                         │
│  Note: Usually don't need to interact with these       │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Creating Service Accounts

### 1. Via gcloud CLI

```bash
# Create service account
gcloud iam service-accounts create backend-api \
  --display-name="Backend API Service Account" \
  --description="Service account for backend API application"

# Full email will be:
# backend-api@PROJECT_ID.iam.gserviceaccount.com

# Create with specific project
gcloud iam service-accounts create data-processor \
  --display-name="Data Processor" \
  --project=my-project-123

# List service accounts
gcloud iam service-accounts list

# Get service account details
gcloud iam service-accounts describe \
  backend-api@PROJECT_ID.iam.gserviceaccount.com
```

### 2. Via Console

```
Navigation: IAM & Admin → Service Accounts → Create Service Account

Steps:
1. Enter service account name (e.g., "backend-api")
2. Add description
3. Click "Create and Continue"
4. Grant roles (optional)
5. Grant users access to this SA (optional)
6. Click "Done"
```

### 3. Via Terraform

```hcl
# Create service account
resource "google_service_account" "backend_api" {
  account_id   = "backend-api"
  display_name = "Backend API Service Account"
  description  = "Service account for backend API application"
  project      = var.project_id
}

# Grant roles to service account
resource "google_project_iam_member" "backend_api_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.backend_api.email}"
}

resource "google_project_iam_member" "backend_api_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_api.email}"
}
```

---

## 🔑 Service Account Keys

### 1. Key Types

```
┌────────────────────────────────────────────────────────┐
│  Service Account Key Types                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Google-Managed Keys:                                  │
│  • Managed by Google automatically                     │
│  • Rotated automatically                               │
│  • Cannot be downloaded                                │
│  • Used with Workload Identity, metadata server        │
│  • ✓ RECOMMENDED                                       │
│                                                         │
│  User-Managed Keys:                                    │
│  • Created and managed by you                          │
│  • Downloaded as JSON file                             │
│  • You must rotate manually                            │
│  • Can be compromised if leaked                        │
│  • ⚠️  USE ONLY WHEN NECESSARY                         │
│                                                         │
│  Key Formats:                                          │
│  • JSON (default, recommended)                         │
│  • P12 (legacy, not recommended)                       │
└────────────────────────────────────────────────────────┘
```

### 2. Creating Keys (When Necessary)

```bash
# Create JSON key
gcloud iam service-accounts keys create key.json \
  --iam-account=backend-api@PROJECT_ID.iam.gserviceaccount.com

# ⚠️  WARNING: This downloads a credential file
# • Store securely (never commit to git!)
# • Rotate regularly (every 90 days)
# • Delete when no longer needed
# • Use Workload Identity instead when possible

# List keys for service account
gcloud iam service-accounts keys list \
  --iam-account=backend-api@PROJECT_ID.iam.gserviceaccount.com

# Delete key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=backend-api@PROJECT_ID.iam.gserviceaccount.com
```

### 3. Key Security Best Practices

```
✓ Avoid creating keys when possible
✓ Use Workload Identity (GKE)
✓ Use metadata server (Compute Engine)
✓ Use Application Default Credentials
✓ Rotate keys every 90 days
✓ Store keys in Secret Manager
✓ Never commit keys to source control
✓ Use short-lived tokens when possible
✓ Monitor key usage
✓ Delete unused keys immediately
```

---

## 🔐 Authentication Methods

### 1. Workload Identity (GKE) - RECOMMENDED

```yaml
# Kubernetes deployment using Workload Identity
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-api-ksa
  namespace: default
  annotations:
    iam.gke.io/gcp-service-account: backend-api@PROJECT_ID.iam.gserviceaccount.com

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  template:
    spec:
      serviceAccountName: backend-api-ksa
      containers:
      - name: api
        image: gcr.io/PROJECT_ID/backend-api:latest
        # No keys needed! Workload Identity handles auth
```

```bash
# Set up Workload Identity binding
gcloud iam service-accounts add-iam-policy-binding \
  backend-api@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="serviceAccount:PROJECT_ID.svc.id.goog[default/backend-api-ksa]"

# Benefits:
# ✓ No keys to manage
# ✓ Automatic credential rotation
# ✓ Pod-level identity
# ✓ Secure by default
```

### 2. Metadata Server (Compute Engine)

```python
# Python code running on Compute Engine VM
from google.auth import compute_engine
from google.cloud import storage

# Automatically uses VM's service account
# No keys needed!
credentials = compute_engine.Credentials()

# Use credentials
client = storage.Client(credentials=credentials)
buckets = client.list_buckets()

for bucket in buckets:
    print(bucket.name)
```

```bash
# Attach service account to VM
gcloud compute instances create my-vm \
  --service-account=backend-api@PROJECT_ID.iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --zone=us-central1-a

# Benefits:
# ✓ No keys to manage
# ✓ Credentials from metadata server
# ✓ Automatic rotation
# ✓ Secure
```

### 3. Application Default Credentials (ADC)

```python
# Python application using ADC
from google.cloud import storage

# ADC automatically finds credentials in this order:
# 1. GOOGLE_APPLICATION_CREDENTIALS env var
# 2. gcloud auth application-default login
# 3. Compute Engine metadata server
# 4. App Engine/Cloud Functions default SA

client = storage.Client()  # Automatically authenticated
buckets = client.list_buckets()
```

```bash
# Set up ADC for local development
gcloud auth application-default login

# Or use service account key (not recommended for production)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"

# Check current ADC
gcloud auth application-default print-access-token
```

### 4. Service Account Keys (Last Resort)

```python
# Using service account key file
from google.oauth2 import service_account
from google.cloud import storage

# Load credentials from key file
credentials = service_account.Credentials.from_service_account_file(
    '/path/to/key.json'
)

# Use credentials
client = storage.Client(credentials=credentials)

# ⚠️  Only use when:
# • Running outside GCP
# • Workload Identity not available
# • No other option exists
```

---

## 👥 Service Account Impersonation

### 1. What is Impersonation?

```
┌────────────────────────────────────────────────────────┐
│  Service Account Impersonation                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Concept: Act as another service account temporarily   │
│                                                         │
│  Flow:                                                 │
│  User/SA A → Impersonates → SA B → Accesses Resource  │
│                                                         │
│  Benefits:                                             │
│  ✓ No key distribution needed                          │
│  ✓ Centralized access control                          │
│  ✓ Audit trail (who impersonated whom)                 │
│  ✓ Temporary elevated privileges                       │
│  ✓ Easier key rotation                                 │
│                                                         │
│  Use Cases:                                            │
│  • CI/CD pipelines                                     │
│  • Admin tasks                                         │
│  • Cross-project access                                │
│  • Temporary privilege escalation                      │
└────────────────────────────────────────────────────────┘
```

### 2. Setting Up Impersonation

```bash
# Grant impersonation permission
gcloud iam service-accounts add-iam-policy-binding \
  target-sa@PROJECT_ID.iam.gserviceaccount.com \
  --member='user:admin@company.com' \
  --role='roles/iam.serviceAccountTokenCreator'

# Or use serviceAccountUser role (broader permissions)
gcloud iam service-accounts add-iam-policy-binding \
  target-sa@PROJECT_ID.iam.gserviceaccount.com \
  --member='user:admin@company.com' \
  --role='roles/iam.serviceAccountUser'

# Impersonate service account
gcloud compute instances list \
  --impersonate-service-account=target-sa@PROJECT_ID.iam.gserviceaccount.com

# All commands run as target-sa
```

### 3. Impersonation in Code

```python
from google.auth import impersonated_credentials
from google.auth import default
from google.cloud import storage

# Get source credentials (your credentials)
source_credentials, project = default()

# Create impersonated credentials
target_scopes = ['https://www.googleapis.com/auth/cloud-platform']
target_credentials = impersonated_credentials.Credentials(
    source_credentials=source_credentials,
    target_principal='target-sa@PROJECT_ID.iam.gserviceaccount.com',
    target_scopes=target_scopes,
    lifetime=3600  # 1 hour
)

# Use impersonated credentials
client = storage.Client(credentials=target_credentials)
buckets = client.list_buckets()
```

---

## 🔒 Service Account Security

### 1. Least Privilege

```bash
# ❌ BAD: Grant Editor role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/editor'

# ✓ GOOD: Grant specific roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.client'

# Only grant what's needed!
```

### 2. Service Account Permissions

```bash
# View what roles a service account has
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com"

# View who can use/impersonate a service account
gcloud iam service-accounts get-iam-policy \
  app@PROJECT_ID.iam.gserviceaccount.com
```

### 3. Monitoring Service Accounts

```bash
# List all service accounts
gcloud iam service-accounts list

# Find unused service accounts
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.serviceAccount.Recommender \
  --location=global

# Check service account activity in logs
gcloud logging read \
  'protoPayload.authenticationInfo.principalEmail="app@PROJECT_ID.iam.gserviceaccount.com"' \
  --limit=50 \
  --format=json
```

---

## 📋 Common Patterns

### Pattern 1: Application on Compute Engine

```bash
# Create service account
gcloud iam service-accounts create web-app-sa \
  --display-name="Web Application"

# Grant necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.client'

# Create VM with service account
gcloud compute instances create web-vm \
  --service-account=web-app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --scopes=cloud-platform \
  --zone=us-central1-a

# Application code automatically uses this SA
# No keys needed!
```

### Pattern 2: GKE with Workload Identity

```bash
# 1. Create GCP service account
gcloud iam service-accounts create gke-app-sa

# 2. Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:gke-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# 3. Create Kubernetes service account
kubectl create serviceaccount gke-app-ksa

# 4. Bind them together
gcloud iam service-accounts add-iam-policy-binding \
  gke-app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="serviceAccount:PROJECT_ID.svc.id.goog[default/gke-app-ksa]"

# 5. Annotate K8s SA
kubectl annotate serviceaccount gke-app-ksa \
  iam.gke.io/gcp-service-account=gke-app-sa@PROJECT_ID.iam.gserviceaccount.com

# 6. Use in pod
# spec:
#   serviceAccountName: gke-app-ksa
```

### Pattern 3: CI/CD Pipeline

```bash
# Create service account for CI/CD
gcloud iam service-accounts create cicd-deployer \
  --display-name="CI/CD Deployer"

# Grant deployment permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:cicd-deployer@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/run.admin'

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:cicd-deployer@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/iam.serviceAccountUser'

# Create key for CI/CD system (store in CI/CD secrets)
gcloud iam service-accounts keys create cicd-key.json \
  --iam-account=cicd-deployer@PROJECT_ID.iam.gserviceaccount.com

# In CI/CD pipeline:
# export GOOGLE_APPLICATION_CREDENTIALS=cicd-key.json
# gcloud auth activate-service-account --key-file=cicd-key.json
```

---

## ✅ Best Practices Checklist

### Service Account Creation
- [ ] Use descriptive names (e.g., backend-api, data-processor)
- [ ] Add clear descriptions
- [ ] Document purpose and usage
- [ ] One SA per application/service
- [ ] Don't reuse SAs across applications

### Authentication
- [ ] Use Workload Identity for GKE
- [ ] Use metadata server for Compute Engine
- [ ] Avoid creating keys when possible
- [ ] Use ADC for local development
- [ ] Never commit keys to source control

### Permissions
- [ ] Grant least privilege
- [ ] Use predefined roles when possible
- [ ] Regular permission audits
- [ ] Remove unused permissions
- [ ] Document why permissions are granted

### Key Management (if keys are necessary)
- [ ] Store keys in Secret Manager
- [ ] Rotate keys every 90 days
- [ ] Delete old keys immediately
- [ ] Monitor key usage
- [ ] Have key rotation process

### Monitoring
- [ ] Enable audit logging
- [ ] Monitor SA activity
- [ ] Set up alerts for unusual activity
- [ ] Regular access reviews
- [ ] Use IAM Recommender

---

## 🎓 Next Steps

1. Understand [IAM Policies](./4-IAM-Policies.md) for managing access
2. Implement [Least Privilege](./5-Least-Privilege.md) principles
3. Learn [Advanced IAM](./7-Advanced-IAM.md) features like Workload Identity Federation
4. Review [Best Practices](./8-Best-Practices.md) for enterprise IAM

---

**Last Updated:** March 2026
**Version:** 2.0
