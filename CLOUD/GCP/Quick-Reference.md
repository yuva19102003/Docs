# GCP Quick Reference Guide

Essential commands and configurations for daily GCP operations.

---

## Table of Contents

1. [gcloud CLI Essentials](#gcloud-cli-essentials)
2. [Compute](#compute)
3. [Networking](#networking)
4. [Storage & Databases](#storage--databases)
5. [Security](#security)
6. [Monitoring](#monitoring)
7. [Common Patterns](#common-patterns)

---

## gcloud CLI Essentials

### Configuration

```bash
# Initialize gcloud
gcloud init

# Set project
gcloud config set project PROJECT_ID

# Set region/zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# List configurations
gcloud config list

# Create new configuration
gcloud config configurations create dev
gcloud config configurations activate dev

# Switch between accounts
gcloud config set account user@example.com
gcloud auth login
```

### Common Commands

```bash
# List resources
gcloud compute instances list
gcloud container clusters list
gcloud sql instances list
gcloud run services list

# Describe resource
gcloud compute instances describe INSTANCE_NAME

# SSH into VM
gcloud compute ssh INSTANCE_NAME

# Copy files
gcloud compute scp local-file.txt INSTANCE_NAME:~/

# View logs
gcloud logging read "resource.type=gce_instance" --limit=10

# Enable API
gcloud services enable compute.googleapis.com
```

---

## Compute

### Compute Engine

```bash
# Create VM
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --tags=http-server

# Create from snapshot
gcloud compute instances create my-vm \
  --source-snapshot=my-snapshot

# Start/Stop/Delete
gcloud compute instances start my-vm
gcloud compute instances stop my-vm
gcloud compute instances delete my-vm

# Resize VM
gcloud compute instances set-machine-type my-vm \
  --machine-type=e2-standard-4 \
  --zone=us-central1-a
```

### GKE

```bash
# Create cluster
gcloud container clusters create my-cluster \
  --region=us-central1 \
  --num-nodes=3 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10

# Get credentials
gcloud container clusters get-credentials my-cluster \
  --region=us-central1

# Resize cluster
gcloud container clusters resize my-cluster \
  --num-nodes=5 \
  --region=us-central1

# Upgrade cluster
gcloud container clusters upgrade my-cluster \
  --region=us-central1
```

### Cloud Run

```bash
# Deploy service
gcloud run deploy my-service \
  --image=gcr.io/PROJECT/image:tag \
  --region=us-central1 \
  --platform=managed \
  --allow-unauthenticated \
  --memory=512Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=100

# Update service
gcloud run services update my-service \
  --region=us-central1 \
  --memory=1Gi

# Set environment variables
gcloud run services update my-service \
  --region=us-central1 \
  --set-env-vars="KEY1=value1,KEY2=value2"

# View logs
gcloud run services logs read my-service \
  --region=us-central1
```

---

## Networking

### VPC

```bash
# Create VPC
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
  --allow=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server
```

### Load Balancing

```bash
# Create health check
gcloud compute health-checks create http my-health-check \
  --port=80 \
  --request-path=/health

# Create backend service
gcloud compute backend-services create my-backend \
  --protocol=HTTP \
  --health-checks=my-health-check \
  --global

# Create URL map
gcloud compute url-maps create my-url-map \
  --default-service=my-backend

# Create target proxy
gcloud compute target-http-proxies create my-proxy \
  --url-map=my-url-map

# Create forwarding rule
gcloud compute forwarding-rules create my-lb \
  --global \
  --target-http-proxy=my-proxy \
  --ports=80
```

---

## Storage & Databases

### Cloud Storage

```bash
# Create bucket
gsutil mb -l us-central1 gs://my-bucket

# Upload file
gsutil cp local-file.txt gs://my-bucket/

# Download file
gsutil cp gs://my-bucket/file.txt ./

# Sync directory
gsutil rsync -r local-dir gs://my-bucket/dir

# Set lifecycle
gsutil lifecycle set lifecycle.json gs://my-bucket

# Make public
gsutil iam ch allUsers:objectViewer gs://my-bucket

# Delete bucket
gsutil rm -r gs://my-bucket
```

### Cloud SQL

```bash
# Create instance
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-n1-standard-1 \
  --region=us-central1

# Create database
gcloud sql databases create my-db \
  --instance=my-instance

# Create user
gcloud sql users create myuser \
  --instance=my-instance \
  --password=mypassword

# Connect
gcloud sql connect my-instance --user=myuser

# Export
gcloud sql export sql my-instance \
  gs://my-bucket/backup.sql \
  --database=my-db

# Import
gcloud sql import sql my-instance \
  gs://my-bucket/backup.sql \
  --database=my-db
```

### BigQuery

```bash
# Create dataset
bq mk --dataset PROJECT:my_dataset

# Create table
bq mk --table PROJECT:my_dataset.my_table schema.json

# Load data
bq load --source_format=CSV \
  PROJECT:my_dataset.my_table \
  gs://my-bucket/data.csv

# Query
bq query --use_legacy_sql=false \
  'SELECT * FROM `PROJECT.my_dataset.my_table` LIMIT 10'

# Export
bq extract \
  PROJECT:my_dataset.my_table \
  gs://my-bucket/export.csv
```

---

## Security

### IAM

```bash
# Grant role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:user@example.com \
  --role=roles/viewer

# Remove role
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member=user:user@example.com \
  --role=roles/viewer

# List IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Service account
gcloud iam service-accounts create my-sa \
  --display-name="My Service Account"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=my-sa@PROJECT.iam.gserviceaccount.com
```

### Secret Manager

```bash
# Create secret
echo -n "my-secret-value" | \
  gcloud secrets create my-secret --data-file=-

# Access secret
gcloud secrets versions access latest --secret=my-secret

# Update secret
echo -n "new-value" | \
  gcloud secrets versions add my-secret --data-file=-

# Grant access
gcloud secrets add-iam-policy-binding my-secret \
  --member=serviceAccount:SA@PROJECT.iam.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor
```

---

## Monitoring

### Cloud Monitoring

```bash
# List metrics
gcloud monitoring metrics-descriptors list

# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU" \
  --condition-threshold-value=0.8

# Create dashboard
gcloud monitoring dashboards create \
  --config-from-file=dashboard.json
```

### Cloud Logging

```bash
# Read logs
gcloud logging read "resource.type=gce_instance" \
  --limit=10 \
  --format=json

# Create sink
gcloud logging sinks create my-sink \
  bigquery.googleapis.com/projects/PROJECT/datasets/logs \
  --log-filter='severity>=ERROR'

# Create metric
gcloud logging metrics create error_count \
  --description="Count of errors" \
  --log-filter='severity>=ERROR'
```

---

## Common Patterns

### Deploy Web App

```bash
# 1. Build container
docker build -t gcr.io/PROJECT/app:v1 .
docker push gcr.io/PROJECT/app:v1

# 2. Deploy to Cloud Run
gcloud run deploy app \
  --image=gcr.io/PROJECT/app:v1 \
  --region=us-central1 \
  --allow-unauthenticated

# 3. Map custom domain
gcloud run domain-mappings create \
  --service=app \
  --domain=app.example.com \
  --region=us-central1
```

### Set Up CI/CD

```bash
# 1. Create Cloud Build trigger
gcloud builds triggers create github \
  --repo-name=my-repo \
  --repo-owner=my-org \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml

# 2. Grant permissions
gcloud projects add-iam-policy-binding PROJECT \
  --member=serviceAccount:PROJECT@cloudbuild.gserviceaccount.com \
  --role=roles/run.admin
```

### Backup Strategy

```bash
# 1. Cloud SQL backup
gcloud sql instances patch my-instance \
  --backup-start-time=03:00 \
  --enable-bin-log

# 2. GCS lifecycle
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [{
      "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
      "condition": {"age": 30}
    }]
  }
}
EOF
gsutil lifecycle set lifecycle.json gs://backup-bucket

# 3. Snapshot schedule
gcloud compute resource-policies create snapshot-schedule daily-backup \
  --region=us-central1 \
  --start-time=03:00 \
  --daily-schedule
```

---

## Keyboard Shortcuts (Console)

```
/ or Ctrl+/     - Search
g then h        - Go to Home
g then c        - Go to Compute Engine
g then k        - Go to GKE
g then s        - Go to Cloud Storage
g then q        - Go to BigQuery
?               - Show shortcuts
```

---

## Useful Environment Variables

```bash
# Set project
export GOOGLE_CLOUD_PROJECT=my-project

# Set region
export CLOUDSDK_COMPUTE_REGION=us-central1

# Set zone
export CLOUDSDK_COMPUTE_ZONE=us-central1-a

# Disable prompts
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# Set output format
export CLOUDSDK_CORE_FORMAT=json
```

---

## Troubleshooting

```bash
# Check quota
gcloud compute project-info describe --project=PROJECT

# View operations
gcloud compute operations list

# Debug SSH
gcloud compute ssh INSTANCE --troubleshoot

# Check service status
gcloud services list --enabled

# View audit logs
gcloud logging read \
  'protoPayload.serviceName="compute.googleapis.com"' \
  --limit=10
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
