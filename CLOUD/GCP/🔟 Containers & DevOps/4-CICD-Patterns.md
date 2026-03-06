# CI/CD Patterns - Implementation Patterns

Complete guide to CI/CD implementation patterns on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Basic Patterns](#basic-patterns)
3. [Advanced Patterns](#advanced-patterns)
4. [Multi-Environment Patterns](#multi-environment-patterns)
5. [Microservices Patterns](#microservices-patterns)
6. [Security Patterns](#security-patterns)
7. [Testing Patterns](#testing-patterns)
8. [Deployment Patterns](#deployment-patterns)

---

## Introduction

This guide covers proven CI/CD patterns for different scenarios and requirements.

### Pattern Categories

```
┌─────────────────────────────────────────┐
│        CI/CD Pattern Types              │
├─────────────────────────────────────────┤
│  Basic Patterns                         │
│  - Simple pipeline                      │
│  - Branch-based deployment              │
│  - Tag-based releases                   │
│                                         │
│  Advanced Patterns                      │
│  - Multi-stage builds                   │
│  - Parallel testing                     │
│  - Progressive delivery                 │
│                                         │
│  Microservices Patterns                 │
│  - Mono-repo                            │
│  - Multi-repo                           │
│  - Service mesh integration             │
│                                         │
│  Security Patterns                      │
│  - Vulnerability scanning               │
│  - Binary authorization                 │
│  - Secret management                    │
└─────────────────────────────────────────┘
```

---

## Basic Patterns

### Pattern 1: Simple CI/CD Pipeline

**Use Case:** Small applications, single environment

```
GitHub → Cloud Build → Artifact Registry → Cloud Run
```

**cloudbuild.yaml:**

```yaml
steps:
  # Test
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['ci']
  
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['test']
  
  # Build
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Deploy
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'myapp'
      - '--image'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--region'
      - 'us-central1'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Pattern 2: Branch-Based Deployment

**Use Case:** Different environments per branch

```
main branch    → Production
develop branch → Staging
feature/*      → Development
```

**cloudbuild.yaml:**

```yaml
steps:
  # Build
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Deploy based on branch
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if [ "$BRANCH_NAME" = "main" ]; then
          ENV="prod"
        elif [ "$BRANCH_NAME" = "develop" ]; then
          ENV="staging"
        else
          ENV="dev"
        fi
        
        gcloud run deploy myapp-$ENV \
          --image us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA \
          --region us-central1

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Pattern 3: Tag-Based Releases

**Use Case:** Production releases on version tags

```
v1.0.0 tag → Production deployment
v1.0.0-rc1 → Staging deployment
```

**cloudbuild.yaml:**

```yaml
steps:
  # Build
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$TAG_NAME'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
      - '.'
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - '--all-tags'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp'
  
  # Deploy to production (only for release tags)
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if [[ "$TAG_NAME" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          gcloud run deploy myapp-prod \
            --image us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$TAG_NAME \
            --region us-central1
        fi

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$TAG_NAME'
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
```

---

## Advanced Patterns

### Pattern 4: Multi-Stage Build with Caching

**Use Case:** Optimize build times with layer caching

```yaml
steps:
  # Pull previous image for caching
  - name: 'gcr.io/cloud-builders/docker'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        docker pull us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest || exit 0
  
  # Build with cache
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--cache-from'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
      - '--build-arg'
      - 'BUILDKIT_INLINE_CACHE=1'
      - '.'
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Tag as latest
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'tag'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
```

### Pattern 5: Parallel Testing

**Use Case:** Run multiple test suites in parallel

```yaml
steps:
  # Install dependencies
  - name: 'node:18'
    id: 'install'
    entrypoint: 'npm'
    args: ['ci']
  
  # Run tests in parallel
  - name: 'node:18'
    id: 'lint'
    entrypoint: 'npm'
    args: ['run', 'lint']
    waitFor: ['install']
  
  - name: 'node:18'
    id: 'test-unit'
    entrypoint: 'npm'
    args: ['run', 'test:unit']
    waitFor: ['install']
  
  - name: 'node:18'
    id: 'test-integration'
    entrypoint: 'npm'
    args: ['run', 'test:integration']
    waitFor: ['install']
  
  - name: 'node:18'
    id: 'test-e2e'
    entrypoint: 'npm'
    args: ['run', 'test:e2e']
    waitFor: ['install']
  
  # Build (wait for all tests)
  - name: 'node:18'
    id: 'build'
    entrypoint: 'npm'
    args: ['run', 'build']
    waitFor: ['lint', 'test-unit', 'test-integration', 'test-e2e']
  
  # Docker build
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
    waitFor: ['build']
```

### Pattern 6: Progressive Delivery with Cloud Deploy

**Use Case:** Gradual rollout to production

```yaml
# cloudbuild.yaml
steps:
  # Build and push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
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

```yaml
# clouddeploy.yaml
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
  name: my-pipeline
serialPipeline:
  stages:
    - targetId: dev
    - targetId: staging
    - targetId: prod
      strategy:
        canary:
          canaryDeployment:
            percentages: [10, 25, 50, 75]
            verify: true
```

---

## Multi-Environment Patterns

### Pattern 7: Environment-Specific Configuration

**Use Case:** Different configs per environment

```
project/
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       │   ├── kustomization.yaml
│       │   └── config.yaml
│       ├── staging/
│       │   ├── kustomization.yaml
│       │   └── config.yaml
│       └── prod/
│           ├── kustomization.yaml
│           └── config.yaml
```

**k8s/base/kustomization.yaml:**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

**k8s/overlays/prod/kustomization.yaml:**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
  - ../../base
replicas:
  - name: myapp
    count: 5
images:
  - name: myapp
    newName: us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp
    newTag: v1.0.0
configMapGenerator:
  - name: app-config
    literals:
      - ENV=production
      - LOG_LEVEL=info
```

### Pattern 8: Multi-Region Deployment

**Use Case:** Deploy to multiple regions

```yaml
steps:
  # Build and push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Deploy to multiple regions
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        for region in us-central1 us-east1 us-west1; do
          gcloud run deploy myapp \
            --image us-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA \
            --region $region \
            --platform managed &
        done
        wait

images:
  - 'us-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

---

## Microservices Patterns

### Pattern 9: Mono-Repo with Selective Builds

**Use Case:** Multiple services in one repository

```
project/
├── services/
│   ├── api/
│   │   ├── Dockerfile
│   │   └── cloudbuild.yaml
│   ├── web/
│   │   ├── Dockerfile
│   │   └── cloudbuild.yaml
│   └── worker/
│       ├── Dockerfile
│       └── cloudbuild.yaml
└── cloudbuild.yaml
```

**cloudbuild.yaml:**

```yaml
steps:
  # Detect changed services
  - name: 'gcr.io/cloud-builders/git'
    id: 'detect-changes'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        git diff --name-only HEAD~1 HEAD > /workspace/changed_files.txt
        
        if grep -q "services/api/" /workspace/changed_files.txt; then
          echo "api" >> /workspace/services_to_build.txt
        fi
        
        if grep -q "services/web/" /workspace/changed_files.txt; then
          echo "web" >> /workspace/services_to_build.txt
        fi
        
        if grep -q "services/worker/" /workspace/changed_files.txt; then
          echo "worker" >> /workspace/services_to_build.txt
        fi
  
  # Build API service
  - name: 'gcr.io/cloud-builders/docker'
    id: 'build-api'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if grep -q "api" /workspace/services_to_build.txt; then
          docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/api:$COMMIT_SHA services/api/
          docker push us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/api:$COMMIT_SHA
        fi
    waitFor: ['detect-changes']
  
  # Build Web service
  - name: 'gcr.io/cloud-builders/docker'
    id: 'build-web'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if grep -q "web" /workspace/services_to_build.txt; then
          docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/web:$COMMIT_SHA services/web/
          docker push us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/web:$COMMIT_SHA
        fi
    waitFor: ['detect-changes']
  
  # Build Worker service
  - name: 'gcr.io/cloud-builders/docker'
    id: 'build-worker'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if grep -q "worker" /workspace/services_to_build.txt; then
          docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/worker:$COMMIT_SHA services/worker/
          docker push us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/worker:$COMMIT_SHA
        fi
    waitFor: ['detect-changes']
```

### Pattern 10: Multi-Repo Microservices

**Use Case:** Separate repository per service

```
Each service has its own:
- Repository
- Cloud Build trigger
- Deployment pipeline
```

**Service A - cloudbuild.yaml:**

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/service-a:$COMMIT_SHA'
      - '.'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/service-a:$COMMIT_SHA'
  
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    args:
      - 'deploy'
      - 'releases'
      - 'create'
      - 'service-a-$SHORT_SHA'
      - '--delivery-pipeline=service-a-pipeline'
      - '--region=us-central1'
      - '--images=service-a=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/service-a:$COMMIT_SHA'
```

---

## Security Patterns

### Pattern 11: Vulnerability Scanning

**Use Case:** Scan images for vulnerabilities

```yaml
steps:
  # Build
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Wait for vulnerability scan
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        # Wait for scan to complete
        sleep 30
        
        # Get vulnerability count
        VULNS=$(gcloud artifacts docker images describe \
          us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA \
          --show-all-metadata \
          --format='value(image_summary.vulnerability_counts.CRITICAL)')
        
        if [ "$VULNS" -gt 0 ]; then
          echo "Critical vulnerabilities found: $VULNS"
          exit 1
        fi

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Pattern 12: Binary Authorization

**Use Case:** Only deploy signed and verified images

```yaml
steps:
  # Build and push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  
  # Create attestation
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'beta'
      - 'container'
      - 'binauthz'
      - 'attestations'
      - 'sign-and-create'
      - '--artifact-url=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--attestor=my-attestor'
      - '--attestor-project=$PROJECT_ID'
      - '--keyversion-project=$PROJECT_ID'
      - '--keyversion-location=us-central1'
      - '--keyversion-keyring=my-keyring'
      - '--keyversion-key=my-key'
      - '--keyversion=1'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Pattern 13: Secret Management

**Use Case:** Secure handling of secrets

```yaml
steps:
  # Build with secrets
  - name: 'gcr.io/cloud-builders/docker'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        echo "$$DATABASE_PASSWORD" > /workspace/db-password.txt
        docker build \
          --secret id=db-password,src=/workspace/db-password.txt \
          -t us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA \
          .
        rm /workspace/db-password.txt
    secretEnv: ['DATABASE_PASSWORD']
  
  # Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'

availableSecrets:
  secretManager:
    - versionName: projects/$PROJECT_ID/secrets/database-password/versions/latest
      env: 'DATABASE_PASSWORD'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

---

## Testing Patterns

### Pattern 14: Integration Testing

**Use Case:** Test with real dependencies

```yaml
steps:
  # Start test database
  - name: 'docker/compose:latest'
    args:
      - '-f'
      - 'docker-compose.test.yaml'
      - 'up'
      - '-d'
  
  # Wait for services
  - name: 'ubuntu'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        sleep 10
  
  # Run integration tests
  - name: 'node:18'
    env:
      - 'DATABASE_URL=postgresql://test:test@postgres:5432/testdb'
    args: ['npm', 'run', 'test:integration']
  
  # Cleanup
  - name: 'docker/compose:latest'
    args:
      - '-f'
      - 'docker-compose.test.yaml'
      - 'down'
```

### Pattern 15: Performance Testing

**Use Case:** Load testing before deployment

```yaml
steps:
  # Deploy to test environment
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'myapp-test'
      - '--image'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--region'
      - 'us-central1'
  
  # Run load test
  - name: 'grafana/k6'
    args:
      - 'run'
      - '--vus'
      - '100'
      - '--duration'
      - '5m'
      - 'loadtest.js'
  
  # Check results
  - name: 'ubuntu'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        # Parse k6 results and fail if thresholds not met
        if [ $? -ne 0 ]; then
          echo "Load test failed"
          exit 1
        fi
```

---

## Deployment Patterns

### Pattern 16: Blue-Green Deployment

**Use Case:** Zero-downtime deployments

```yaml
steps:
  # Deploy to green environment
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'myapp-green'
      - '--image'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--region'
      - 'us-central1'
      - '--no-traffic'
  
  # Run smoke tests
  - name: 'ubuntu'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        # Test green environment
        curl -f https://myapp-green-xxx.run.app/health || exit 1
  
  # Switch traffic
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'services'
      - 'update-traffic'
      - 'myapp'
      - '--to-revisions=myapp-green=100'
      - '--region=us-central1'
```

### Pattern 17: Canary Deployment

**Use Case:** Gradual traffic shift

```yaml
# Use Cloud Deploy for canary
steps:
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    args:
      - 'deploy'
      - 'releases'
      - 'create'
      - 'release-$SHORT_SHA'
      - '--delivery-pipeline=my-pipeline'
      - '--region=us-central1'
      - '--images=myapp=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

```yaml
# clouddeploy.yaml
strategy:
  canary:
    canaryDeployment:
      percentages: [10, 25, 50, 75]
      verify: true
```

---

## Summary

### Pattern Selection Guide

| Scenario | Recommended Pattern |
|----------|-------------------|
| **Simple app** | Pattern 1: Simple CI/CD |
| **Multiple environments** | Pattern 2: Branch-based |
| **Production releases** | Pattern 3: Tag-based |
| **Fast builds** | Pattern 4: Multi-stage caching |
| **Large test suite** | Pattern 5: Parallel testing |
| **Gradual rollout** | Pattern 6: Progressive delivery |
| **Multi-environment** | Pattern 7: Environment configs |
| **Global app** | Pattern 8: Multi-region |
| **Mono-repo** | Pattern 9: Selective builds |
| **Microservices** | Pattern 10: Multi-repo |
| **Security focus** | Patterns 11-13: Security |
| **Testing focus** | Patterns 14-15: Testing |
| **Zero downtime** | Patterns 16-17: Deployment |

---

## Next Steps

- **[Best Practices](5-Best-Practices.md)** - Production guidelines
- **[Cloud Build](2-Cloud-Build.md)** - CI/CD build service
- **[Cloud Deploy](3-Cloud-Deploy.md)** - Continuous delivery

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
