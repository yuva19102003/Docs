# Cloud Deploy - Managed Continuous Delivery

Complete guide to Google Cloud Deploy - managed continuous delivery service for GKE and Cloud Run.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Delivery Pipelines](#delivery-pipelines)
3. [Targets](#targets)
4. [Releases](#releases)
5. [Deployment Strategies](#deployment-strategies)
6. [Approval Gates](#approval-gates)
7. [Rollbacks](#rollbacks)
8. [Integration](#integration)
9. [Best Practices](#best-practices)

---

## Introduction

Cloud Deploy is a managed continuous delivery service that automates deployment to GKE and Cloud Run.

### Key Features

✅ Managed CD service  
✅ Progressive delivery  
✅ Canary deployments  
✅ Blue-green deployments  
✅ Approval workflows  
✅ Rollback support  
✅ Deployment verification  
✅ Multi-environment support  
✅ Audit logging  
✅ Integration with Cloud Build  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Cloud Deploy Pipeline                      │
├─────────────────────────────────────────────────────┤
│  Release (v1.0.0)                                   │
│     ↓                                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Dev Environment                             │   │
│  │  - Auto-deploy                               │   │
│  │  - No approval                               │   │
│  └──────────────┬───────────────────────────────┘   │
│                 ↓ (Success)                         │
│  ┌──────────────────────────────────────────────┐   │
│  │  Test Environment                            │   │
│  │  - Auto-deploy                               │   │
│  │  - Automated tests                           │   │
│  └──────────────┬───────────────────────────────┘   │
│                 ↓ (Success)                         │
│  ┌──────────────────────────────────────────────┐   │
│  │  Staging Environment                         │   │
│  │  - Manual approval required                  │   │
│  │  - Smoke tests                               │   │
│  └──────────────┬───────────────────────────────┘   │
│                 ↓ (Approved)                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  Production Environment                      │   │
│  │  - Manual approval required                  │   │
│  │  - Canary deployment (10% → 50% → 100%)     │   │
│  │  - Monitoring and verification               │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Delivery Pipelines

### Pipeline Configuration

**clouddeploy.yaml:**

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
  name: my-pipeline
description: Multi-environment deployment pipeline
serialPipeline:
  stages:
    - targetId: dev
      profiles: [dev]
    
    - targetId: test
      profiles: [test]
    
    - targetId: staging
      profiles: [staging]
      strategy:
        standard:
          verify: true
    
    - targetId: prod
      profiles: [prod]
      strategy:
        canary:
          runtimeConfig:
            kubernetes:
              serviceNetworking:
                service: myapp-service
                deployment: myapp
          canaryDeployment:
            percentages: [10, 50]
            verify: true

---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: dev
description: Development environment
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/dev-cluster

---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: test
description: Test environment
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/test-cluster

---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: staging
description: Staging environment
requireApproval: true
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/staging-cluster

---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: prod
description: Production environment
requireApproval: true
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/prod-cluster
```

### Create Pipeline

```bash
# Apply configuration
gcloud deploy apply --file=clouddeploy.yaml --region=us-central1

# List pipelines
gcloud deploy delivery-pipelines list --region=us-central1

# Describe pipeline
gcloud deploy delivery-pipelines describe my-pipeline \
  --region=us-central1

# Delete pipeline
gcloud deploy delivery-pipelines delete my-pipeline \
  --region=us-central1
```

### Terraform Configuration

```hcl
resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  name        = "my-pipeline"
  location    = "us-central1"
  description = "Multi-environment deployment pipeline"
  
  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.dev.name
      profiles  = ["dev"]
    }
    
    stages {
      target_id = google_clouddeploy_target.test.name
      profiles  = ["test"]
    }
    
    stages {
      target_id = google_clouddeploy_target.staging.name
      profiles  = ["staging"]
      
      strategy {
        standard {
          verify = true
        }
      }
    }
    
    stages {
      target_id = google_clouddeploy_target.prod.name
      profiles  = ["prod"]
      
      strategy {
        canary {
          runtime_config {
            kubernetes {
              service_networking {
                service    = "myapp-service"
                deployment = "myapp"
              }
            }
          }
          
          canary_deployment {
            percentages = [10, 50]
            verify      = true
          }
        }
      }
    }
  }
}
```

---

## Targets

### GKE Target

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: prod-gke
description: Production GKE cluster
requireApproval: true
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/prod-cluster
executionConfigs:
  - usages: [RENDER, DEPLOY]
    serviceAccount: deploy-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Cloud Run Target

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: prod-run
description: Production Cloud Run
requireApproval: true
run:
  location: projects/PROJECT_ID/locations/us-central1
```

### Multi-Target

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: prod-multi
description: Multi-target deployment
multiTarget:
  targetIds:
    - prod-gke-us
    - prod-gke-eu
    - prod-run-us
```

---

## Releases

### Create Release

```bash
# Create release
gcloud deploy releases create release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --images=myapp=us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:v1.0.0

# Create release with description
gcloud deploy releases create release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --images=myapp=us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:v1.0.0 \
  --description="Release v1.0.0 with new features"

# Create release from build
gcloud deploy releases create release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --build-artifacts=build-artifacts.json
```

### List Releases

```bash
# List releases
gcloud deploy releases list \
  --delivery-pipeline=my-pipeline \
  --region=us-central1

# Describe release
gcloud deploy releases describe release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1
```

### Kubernetes Manifests

**skaffold.yaml:**

```yaml
apiVersion: skaffold/v4beta1
kind: Config
metadata:
  name: myapp
profiles:
  - name: dev
    manifests:
      kustomize:
        paths:
          - k8s/overlays/dev
  
  - name: test
    manifests:
      kustomize:
        paths:
          - k8s/overlays/test
  
  - name: staging
    manifests:
      kustomize:
        paths:
          - k8s/overlays/staging
  
  - name: prod
    manifests:
      kustomize:
        paths:
          - k8s/overlays/prod
```

**k8s/base/deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myapp
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
```

---

## Deployment Strategies

### Standard Deployment

```yaml
strategy:
  standard:
    verify: true
    predeploy:
      actions:
        - name: pre-deployment-check
    postdeploy:
      actions:
        - name: smoke-test
```

### Canary Deployment

```yaml
strategy:
  canary:
    runtimeConfig:
      kubernetes:
        serviceNetworking:
          service: myapp-service
          deployment: myapp
    
    canaryDeployment:
      percentages: [10, 25, 50, 75]
      verify: true
    
    customCanaryDeployment:
      phaseConfigs:
        - phaseId: stable
          percentage: 10
          verify: true
          predeploy:
            actions:
              - name: load-test
        
        - phaseId: canary-50
          percentage: 50
          verify: true
        
        - phaseId: stable
          percentage: 100
```

### Blue-Green Deployment

```yaml
# Not directly supported, use canary with 100%
strategy:
  canary:
    runtimeConfig:
      kubernetes:
        serviceNetworking:
          service: myapp-service
          deployment: myapp
    
    canaryDeployment:
      percentages: [100]
      verify: true
```

---

## Approval Gates

### Require Approval

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: prod
description: Production environment
requireApproval: true
gke:
  cluster: projects/PROJECT_ID/locations/us-central1/clusters/prod-cluster
```

### Approve Rollout

```bash
# List pending approvals
gcloud deploy rollouts list \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1 \
  --filter="state=PENDING_APPROVAL"

# Approve rollout
gcloud deploy rollouts approve ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1

# Reject rollout
gcloud deploy rollouts reject ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1
```

### Approval Workflow

```
┌─────────────────────────────────────────┐
│     Approval Workflow                   │
├─────────────────────────────────────────┤
│  1. Release created                     │
│     ↓                                   │
│  2. Deploy to dev (auto)                │
│     ↓                                   │
│  3. Deploy to test (auto)               │
│     ↓                                   │
│  4. Deploy to staging                   │
│     - Requires approval                 │
│     - Notification sent                 │
│     - Approver reviews                  │
│     - Approve/Reject                    │
│     ↓ (Approved)                        │
│  5. Deploy to prod                      │
│     - Requires approval                 │
│     - Canary deployment                 │
│     - Monitoring                        │
│     - Approve each phase                │
└─────────────────────────────────────────┘
```

---

## Rollbacks

### Automatic Rollback

```yaml
strategy:
  canary:
    canaryDeployment:
      percentages: [10, 50]
      verify: true
    
    # Automatic rollback on failure
    automaticRollback:
      enabled: true
      failureConditions:
        - errorRate > 0.05
        - latencyP99 > 1000
```

### Manual Rollback

```bash
# List rollouts
gcloud deploy rollouts list \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1

# Rollback to previous release
gcloud deploy rollouts rollback ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1

# Create new release with previous version
gcloud deploy releases create release-002-rollback \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --images=myapp=us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:v0.9.0
```

---

## Integration

### Cloud Build Integration

**cloudbuild.yaml:**

```yaml
steps:
  # Build image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  # Push image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Create Cloud Deploy release
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: 'gcloud'
    args:
      - 'deploy'
      - 'releases'
      - 'create'
      - 'release-$SHORT_SHA'
      - '--delivery-pipeline=my-pipeline'
      - '--region=us-central1'
      - '--images=myapp=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Monitoring Integration

```yaml
strategy:
  canary:
    canaryDeployment:
      percentages: [10, 50]
      verify: true
    
    # Cloud Monitoring integration
    runtimeConfig:
      cloudRun:
        automaticTrafficControl: true
```

---

## Cost Optimization

### Pricing

**Deployments:**
- First 5 deployments/month: Free
- Additional: $0.02/deployment

**Rollouts:**
- Included in deployment cost

### Cost Example

**Scenario:** 100 deployments/month

```
Deployments:
- Free tier: 5 deployments
- Billable: 95 deployments
- Cost: 95 × $0.02 = $1.90/month

With 4 environments (dev, test, staging, prod):
- Deployments per release: 4
- Releases: 25/month
- Total deployments: 100
- Cost: $1.90/month
```

---

## Best Practices

### Pipeline Design

✅ Use progressive delivery  
✅ Implement approval gates  
✅ Use canary deployments for production  
✅ Automate dev/test deployments  
✅ Require approval for staging/prod  
✅ Implement verification steps  
✅ Use multiple environments  
✅ Document deployment process  

### Deployment Strategy

✅ Start with small canary percentages  
✅ Monitor metrics during rollout  
✅ Implement automated verification  
✅ Use health checks  
✅ Set appropriate timeouts  
✅ Plan rollback procedures  
✅ Test in non-production first  
✅ Regular deployment testing  

### Security

✅ Use service accounts  
✅ Implement least privilege  
✅ Enable audit logging  
✅ Require approvals  
✅ Use signed images  
✅ Implement Binary Authorization  
✅ Regular security audits  
✅ Document security procedures  

### Monitoring

✅ Monitor deployment metrics  
✅ Set up alerting  
✅ Track deployment success rates  
✅ Monitor application health  
✅ Log all deployments  
✅ Track rollback frequency  
✅ Regular performance reviews  
✅ Document incidents  

---

## Troubleshooting

### Deployment Failures

```bash
# View rollout details
gcloud deploy rollouts describe ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1

# View logs
gcloud logging read \
  "resource.type=clouddeploy.googleapis.com/DeliveryPipeline" \
  --limit=50

# Check target status
gcloud deploy targets describe prod \
  --region=us-central1
```

### Permission Issues

```bash
# Check service account permissions
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:deploy-sa@*"

# Grant required permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:deploy-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/clouddeploy.operator
```

### Rollout Stuck

```bash
# Cancel rollout
gcloud deploy rollouts cancel ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1

# Retry rollout
gcloud deploy rollouts retry ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1
```

---

## Next Steps

- **[CI/CD Patterns](4-CICD-Patterns.md)** - Implementation patterns
- **[Best Practices](5-Best-Practices.md)** - Production guidelines
- **[Cloud Build](2-Cloud-Build.md)** - CI/CD build service

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
