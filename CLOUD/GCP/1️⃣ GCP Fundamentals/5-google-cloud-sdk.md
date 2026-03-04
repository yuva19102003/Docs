# ⚙️ Google Cloud SDK

The **Google Cloud SDK** is a set of command-line tools for managing GCP resources, automating tasks, and integrating with CI/CD pipelines.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Google Cloud SDK Components                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  gcloud     → Manage GCP resources (primary tool)      │
│  gsutil     → Manage Cloud Storage buckets             │
│  bq         → Interact with BigQuery                   │
│  kubectl    → Manage Kubernetes clusters (optional)    │
│  terraform  → Infrastructure as Code (optional)        │
└────────────────────────────────────────────────────────┘
```

---

## Installation

### Linux / macOS

```bash
# Download and install
curl https://sdk.cloud.google.com | bash

# Restart shell
exec -l $SHELL

# Initialize SDK
gcloud init
```

### Windows

```powershell
# Download installer from:
# https://cloud.google.com/sdk/docs/install

# Or use PowerShell:
(New-Object Net.WebClient).DownloadFile(
  "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe",
  "$env:Temp\GoogleCloudSDKInstaller.exe"
)
& $env:Temp\GoogleCloudSDKInstaller.exe
```

### Using Package Managers

```bash
# macOS (Homebrew)
brew install --cask google-cloud-sdk

# Ubuntu/Debian
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-sdk

# Red Hat/CentOS
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
sudo yum install google-cloud-sdk
```

### Docker

```bash
# Use official Google Cloud SDK Docker image
docker run -it google/cloud-sdk:latest gcloud version

# Interactive shell
docker run -it google/cloud-sdk:latest /bin/bash
```

---

## Initial Configuration

### 1. Initialize SDK

```bash
# Interactive setup
gcloud init

# Follow prompts:
# 1. Login to Google account
# 2. Select or create project
# 3. Set default region/zone
```

### 2. Authentication

```bash
# Login with user account
gcloud auth login

# Login with service account
gcloud auth activate-service-account \
  --key-file=/path/to/service-account-key.json

# List authenticated accounts
gcloud auth list

# Revoke credentials
gcloud auth revoke user@example.com
```

### 3. Set Default Configuration

```bash
# Set default project
gcloud config set project PROJECT_ID

# Set default region
gcloud config set compute/region us-central1

# Set default zone
gcloud config set compute/zone us-central1-a

# View all configurations
gcloud config list

# View specific property
gcloud config get-value project
```

---

## Configuration Profiles

Manage multiple configurations for different projects or environments.

```bash
# Create new configuration
gcloud config configurations create production
gcloud config configurations create development

# List configurations
gcloud config configurations list

# Activate configuration
gcloud config configurations activate production

# Set properties for active configuration
gcloud config set project prod-project-123
gcloud config set compute/region us-east1

# Switch to another configuration
gcloud config configurations activate development
gcloud config set project dev-project-456
```

### Configuration Example

```
┌────────────────────────────────────────────────────────┐
│  Configuration: production                             │
├────────────────────────────────────────────────────────┤
│  project: ecommerce-prod-2026                          │
│  region: us-central1                                   │
│  zone: us-central1-a                                   │
│  account: admin@company.com                            │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Configuration: development                            │
├────────────────────────────────────────────────────────┤
│  project: ecommerce-dev-2026                           │
│  region: us-west1                                      │
│  zone: us-west1-b                                      │
│  account: developer@company.com                        │
└────────────────────────────────────────────────────────┘
```

---

## gcloud Command Structure

```
┌────────────────────────────────────────────────────────┐
│  gcloud Command Syntax                                 │
└────────────────────────────────────────────────────────┘

gcloud [GROUP] [SUBGROUP] [COMMAND] [FLAGS] [ARGUMENTS]

Examples:
  gcloud compute instances create vm-1 --zone=us-central1-a
         │       │         │      │     └─ Flags
         │       │         │      └─ Arguments
         │       │         └─ Command
         │       └─ Subgroup
         └─ Group

Common Groups:
  • compute      → Compute Engine
  • container    → GKE
  • sql          → Cloud SQL
  • storage      → Cloud Storage (use gsutil instead)
  • iam          → IAM
  • projects     → Project management
  • services     → API management
```

---

## Essential gcloud Commands

### Project Management

```bash
# List projects
gcloud projects list

# Create project
gcloud projects create my-project-123 \
  --name="My Project" \
  --folder=FOLDER_ID

# Describe project
gcloud projects describe my-project-123

# Delete project
gcloud projects delete my-project-123

# Set active project
gcloud config set project my-project-123
```

### Compute Engine

```bash
# Create VM instance
gcloud compute instances create web-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --tags=http-server,https-server

# List instances
gcloud compute instances list

# Start instance
gcloud compute instances start web-vm --zone=us-central1-a

# Stop instance
gcloud compute instances stop web-vm --zone=us-central1-a

# SSH into instance
gcloud compute ssh web-vm --zone=us-central1-a

# Delete instance
gcloud compute instances delete web-vm --zone=us-central1-a

# Describe instance
gcloud compute instances describe web-vm --zone=us-central1-a
```

### GKE (Kubernetes)

```bash
# Create GKE cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-medium

# List clusters
gcloud container clusters list

# Get cluster credentials (configure kubectl)
gcloud container clusters get-credentials my-cluster \
  --zone=us-central1-a

# Resize cluster
gcloud container clusters resize my-cluster \
  --num-nodes=5 \
  --zone=us-central1-a

# Delete cluster
gcloud container clusters delete my-cluster --zone=us-central1-a
```

### Cloud SQL

```bash
# Create Cloud SQL instance
gcloud sql instances create my-db \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1

# List instances
gcloud sql instances list

# Connect to instance
gcloud sql connect my-db --user=postgres

# Create database
gcloud sql databases create myapp --instance=my-db

# Create user
gcloud sql users create myuser \
  --instance=my-db \
  --password=mypassword

# Delete instance
gcloud sql instances delete my-db
```

### IAM

```bash
# List IAM policy for project
gcloud projects get-iam-policy PROJECT_ID

# Add IAM policy binding
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/editor'

# Remove IAM policy binding
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/editor'

# List service accounts
gcloud iam service-accounts list

# Create service account
gcloud iam service-accounts create my-sa \
  --display-name="My Service Account"

# Create service account key
gcloud iam service-accounts keys create key.json \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com
```

### APIs & Services

```bash
# List enabled APIs
gcloud services list --enabled

# List available APIs
gcloud services list --available

# Enable API
gcloud services enable compute.googleapis.com

# Disable API
gcloud services disable compute.googleapis.com
```

### Networking

```bash
# Create VPC network
gcloud compute networks create my-vpc \
  --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create my-subnet \
  --network=my-vpc \
  --region=us-central1 \
  --range=10.0.1.0/24

# Create firewall rule
gcloud compute firewall-rules create allow-http \
  --network=my-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0

# List firewall rules
gcloud compute firewall-rules list

# Delete firewall rule
gcloud compute firewall-rules delete allow-http
```

---

## gsutil (Cloud Storage)

```bash
# Create bucket
gsutil mb gs://my-unique-bucket-name

# List buckets
gsutil ls

# Upload file
gsutil cp local-file.txt gs://my-bucket/

# Upload directory
gsutil cp -r local-directory gs://my-bucket/

# Download file
gsutil cp gs://my-bucket/file.txt ./

# List bucket contents
gsutil ls gs://my-bucket/

# Delete file
gsutil rm gs://my-bucket/file.txt

# Delete bucket
gsutil rb gs://my-bucket/

# Sync directory (like rsync)
gsutil rsync -r local-directory gs://my-bucket/directory

# Set bucket permissions
gsutil iam ch user:alice@company.com:objectViewer gs://my-bucket

# Make file public
gsutil acl ch -u AllUsers:R gs://my-bucket/public-file.txt

# Copy between buckets
gsutil cp gs://source-bucket/* gs://dest-bucket/
```

---

## bq (BigQuery)

```bash
# List datasets
bq ls

# Create dataset
bq mk my_dataset

# List tables in dataset
bq ls my_dataset

# Create table
bq mk --table my_dataset.my_table schema.json

# Query data
bq query --use_legacy_sql=false \
  'SELECT * FROM `my_dataset.my_table` LIMIT 10'

# Load data from CSV
bq load --source_format=CSV \
  my_dataset.my_table \
  gs://my-bucket/data.csv \
  schema.json

# Export data
bq extract my_dataset.my_table gs://my-bucket/export.csv

# Delete table
bq rm -t my_dataset.my_table

# Delete dataset
bq rm -r -f my_dataset
```

---

## Advanced Features

### 1. Output Formatting

```bash
# JSON output
gcloud compute instances list --format=json

# YAML output
gcloud compute instances list --format=yaml

# Table output (default)
gcloud compute instances list --format=table

# Custom table format
gcloud compute instances list \
  --format="table(name,zone,machineType,status)"

# CSV output
gcloud compute instances list --format=csv

# Value output (single column)
gcloud compute instances list --format="value(name)"

# Filter and format
gcloud compute instances list \
  --filter="zone:us-central1-a" \
  --format="table(name,status)"
```

### 2. Filtering

```bash
# Filter by zone
gcloud compute instances list --filter="zone:us-central1-a"

# Filter by status
gcloud compute instances list --filter="status=RUNNING"

# Multiple filters (AND)
gcloud compute instances list \
  --filter="zone:us-central1-a AND status=RUNNING"

# Multiple filters (OR)
gcloud compute instances list \
  --filter="zone:us-central1-a OR zone:us-east1-b"

# Negation
gcloud compute instances list --filter="NOT status=RUNNING"

# Pattern matching
gcloud compute instances list --filter="name:web-*"
```

### 3. Scripting & Automation

```bash
#!/bin/bash
# Example: Create multiple VMs

PROJECT_ID="my-project-123"
ZONE="us-central1-a"
MACHINE_TYPE="e2-micro"

for i in {1..5}; do
  gcloud compute instances create "web-vm-$i" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --quiet  # No prompts
done

echo "Created 5 VMs successfully"
```

### 4. Dry Run & Validation

```bash
# Validate command without executing (not all commands support this)
gcloud compute instances create test-vm \
  --zone=us-central1-a \
  --dry-run

# Use --quiet to skip prompts (useful for scripts)
gcloud compute instances delete test-vm \
  --zone=us-central1-a \
  --quiet
```

### 5. Parallel Execution

```bash
# Run commands in parallel using xargs
gcloud compute instances list --format="value(name,zone)" | \
  xargs -P 5 -n 2 sh -c 'gcloud compute instances stop $0 --zone=$1'

# Explanation:
# -P 5: Run 5 parallel processes
# -n 2: Pass 2 arguments (name and zone) to each process
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy to GCP

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Cloud SDK
        uses: google-github-actions/setup-gcloud@v0
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy my-service \
            --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/my-app:latest \
            --region us-central1 \
            --platform managed
```

### GitLab CI

```yaml
deploy:
  image: google/cloud-sdk:latest
  script:
    - echo $GCP_SA_KEY | base64 -d > key.json
    - gcloud auth activate-service-account --key-file=key.json
    - gcloud config set project $GCP_PROJECT_ID
    - gcloud run deploy my-service \
        --image gcr.io/$GCP_PROJECT_ID/my-app:latest \
        --region us-central1
  only:
    - main
```

---

## Troubleshooting

### Common Issues

```bash
# Issue: Authentication error
# Solution: Re-authenticate
gcloud auth login
gcloud auth application-default login

# Issue: Permission denied
# Solution: Check IAM roles
gcloud projects get-iam-policy PROJECT_ID

# Issue: API not enabled
# Solution: Enable required API
gcloud services enable compute.googleapis.com

# Issue: Quota exceeded
# Solution: Check quotas
gcloud compute project-info describe --project=PROJECT_ID

# Issue: Wrong project
# Solution: Set correct project
gcloud config set project CORRECT_PROJECT_ID
```

### Debug Mode

```bash
# Enable verbose logging
gcloud compute instances list --verbosity=debug

# Log to file
gcloud compute instances list --log-http > debug.log 2>&1
```

---

## Best Practices

### 1. Use Configuration Profiles

```bash
# Separate configs for different environments
gcloud config configurations create prod
gcloud config configurations create dev
gcloud config configurations create staging
```

### 2. Use Service Accounts for Automation

```bash
# Create service account
gcloud iam service-accounts create ci-cd-sa

# Grant necessary roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:ci-cd-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=ci-cd-sa@PROJECT_ID.iam.gserviceaccount.com
```

### 3. Use Labels for Organization

```bash
# Add labels to resources
gcloud compute instances create web-vm \
  --labels=environment=production,team=frontend,cost-center=engineering
```

### 4. Script with Error Handling

```bash
#!/bin/bash
set -e  # Exit on error

PROJECT_ID="my-project"
ZONE="us-central1-a"

# Function to handle errors
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Create VM with error handling
gcloud compute instances create web-vm \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-micro || error_exit "Failed to create VM"

echo "VM created successfully"
```

---

## Quick Reference

```bash
# Authentication
gcloud auth login
gcloud auth list

# Configuration
gcloud config set project PROJECT_ID
gcloud config list

# Compute
gcloud compute instances list
gcloud compute instances create VM_NAME
gcloud compute ssh VM_NAME

# Storage
gsutil ls
gsutil cp FILE gs://BUCKET/
gsutil mb gs://BUCKET

# GKE
gcloud container clusters list
gcloud container clusters get-credentials CLUSTER_NAME

# IAM
gcloud projects get-iam-policy PROJECT_ID
gcloud iam service-accounts list

# APIs
gcloud services list --enabled
gcloud services enable API_NAME

# Help
gcloud help
gcloud compute instances create --help
```

---

# 🧠 Key Concepts to Master

Before moving forward, ensure you understand:

1. **Regions & Zones**
   - Geographic distribution for latency and compliance
   - Multi-zone deployment for high availability
   - Region selection criteria

2. **Resource Hierarchy**
   - Organization → Folders → Projects → Resources
   - Policy inheritance and IAM structure
   - Project isolation and billing boundaries

3. **Shared Responsibility Model**
   - Google secures infrastructure (OF the cloud)
   - You secure workloads (IN the cloud)
   - Varies by service model (IaaS/PaaS/SaaS)

4. **Management Interfaces**
   - Console for visual management and monitoring
   - gcloud CLI for automation and scripting
   - APIs for programmatic access

5. **Security Fundamentals**
   - IAM roles and least privilege
   - Network security and firewall rules
   - Encryption and data protection
   - Audit logging and monitoring

---

# 🔥 Real-World Architecture Example

```
┌────────────────────────────────────────────────────────────┐
│  Production E-commerce Platform                            │
└────────────────────────────────────────────────────────────┘

Organization: acme-corp.com
│
└── Folder: Production
    │
    └── Project: ecommerce-prod-2026
        │
        ├── Compute (Multi-Zone)
        │   ├── GKE Cluster (us-central1)
        │   │   ├── Zone A: 3 nodes
        │   │   ├── Zone B: 3 nodes
        │   │   └── Zone C: 3 nodes
        │   └── Cloud Run (Serverless APIs)
        │
        ├── Storage
        │   ├── Cloud Storage (Product images, static assets)
        │   └── Persistent Disks (Database volumes)
        │
        ├── Databases (High Availability)
        │   ├── Cloud SQL (PostgreSQL, Multi-zone)
        │   ├── Cloud Spanner (Global inventory)
        │   └── Firestore (User sessions, real-time)
        │
        ├── Networking
        │   ├── VPC (Custom network)
        │   ├── Global Load Balancer
        │   ├── Cloud CDN (Static content)
        │   └── Cloud Armor (DDoS protection)
        │
        ├── Security
        │   ├── IAM (Least privilege access)
        │   ├── Secret Manager (API keys, passwords)
        │   ├── Cloud KMS (Encryption keys)
        │   └── VPC Service Controls (Data perimeter)
        │
        └── Observability
            ├── Cloud Monitoring (Metrics, alerts)
            ├── Cloud Logging (Centralized logs)
            ├── Cloud Trace (Distributed tracing)
            └── Cloud Profiler (Performance analysis)

Deployment:
  • Infrastructure: Terraform
  • CI/CD: Cloud Build + GitHub Actions
  • Monitoring: Cloud Monitoring + Alerting
  • Backup: Automated daily snapshots
  • DR: Multi-region replication

Management:
  • Console: Visual monitoring and troubleshooting
  • gcloud: Automation and scripting
  • APIs: Custom tooling and integrations
```

---