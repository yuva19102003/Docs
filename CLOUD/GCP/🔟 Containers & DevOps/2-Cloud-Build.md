# Cloud Build - Serverless CI/CD Platform

Complete guide to Google Cloud Build - serverless continuous integration and deployment platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Build Configuration](#build-configuration)
3. [Build Triggers](#build-triggers)
4. [Build Steps](#build-steps)
5. [Docker Builds](#docker-builds)
6. [Advanced Features](#advanced-features)
7. [Integration](#integration)
8. [Cost Optimization](#cost-optimization)
9. [Best Practices](#best-practices)

---

## Introduction

Cloud Build is a serverless CI/CD platform that executes builds on Google Cloud infrastructure.

### Key Features

✅ Serverless build execution  
✅ Docker-in-Docker support  
✅ Custom build steps  
✅ Parallel execution  
✅ Build triggers (GitHub, Bitbucket)  
✅ Build caching  
✅ Secrets management  
✅ Artifact integration  
✅ Vulnerability scanning  
✅ Build history and logs  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Cloud Build Pipeline                       │
├─────────────────────────────────────────────────────┤
│  1. Source                                          │
│     ├─ GitHub                                       │
│     ├─ Bitbucket                                    │
│     └─ Cloud Source Repositories                    │
│           ↓                                         │
│  2. Build Steps                                     │
│     ├─ Step 1: Install dependencies                │
│     ├─ Step 2: Run tests                           │
│     ├─ Step 3: Build Docker image                  │
│     └─ Step 4: Push to Artifact Registry           │
│           ↓                                         │
│  3. Artifacts                                       │
│     ├─ Docker images                               │
│     ├─ Build logs                                  │
│     └─ Test results                                │
│           ↓                                         │
│  4. Deploy                                          │
│     ├─ Cloud Run                                   │
│     ├─ GKE                                         │
│     └─ App Engine                                  │
└─────────────────────────────────────────────────────┘
```

---

## Build Configuration

### cloudbuild.yaml

**Basic Configuration:**

```yaml
# cloudbuild.yaml
steps:
  # Step 1: Install dependencies
  - name: 'node:18'
    entrypoint: npm
    args: ['install']
  
  # Step 2: Run tests
  - name: 'node:18'
    entrypoint: npm
    args: ['test']
  
  # Step 3: Build Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
      - '.'
  
  # Step 4: Push to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - '--all-tags'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp'

# Images to be pushed
images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'

# Build options
options:
  machineType: 'N1_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
  
# Timeout
timeout: '1800s'
```

### Submit Build

```bash
# Submit build from local directory
gcloud builds submit --config=cloudbuild.yaml .

# Submit with substitutions
gcloud builds submit \
  --config=cloudbuild.yaml \
  --substitutions=_ENV=production,_VERSION=v1.0.0 \
  .

# Submit from Git repository
gcloud builds submit \
  --config=cloudbuild.yaml \
  https://github.com/user/repo.git

# Submit with specific tag
gcloud builds submit \
  --tag=us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:v1.0.0 \
  .
```

### Build Substitutions

```yaml
# cloudbuild.yaml with substitutions
substitutions:
  _ENV: 'development'
  _VERSION: 'latest'
  _REGION: 'us-central1'

steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - '${_REGION}-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:${_VERSION}'
      - '--build-arg'
      - 'ENV=${_ENV}'
      - '.'

# Override from command line
# gcloud builds submit --substitutions=_ENV=production,_VERSION=v1.0.0
```

---

## Build Triggers

### Create Trigger

```bash
# Create trigger for GitHub repository
gcloud builds triggers create github \
  --name=my-trigger \
  --repo-name=my-repo \
  --repo-owner=my-org \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml

# Create trigger for specific tags
gcloud builds triggers create github \
  --name=release-trigger \
  --repo-name=my-repo \
  --repo-owner=my-org \
  --tag-pattern="^v[0-9]+\.[0-9]+\.[0-9]+$" \
  --build-config=cloudbuild.yaml

# Create trigger for pull requests
gcloud builds triggers create github \
  --name=pr-trigger \
  --repo-name=my-repo \
  --repo-owner=my-org \
  --pull-request-pattern="^main$" \
  --build-config=cloudbuild.yaml \
  --comment-control=COMMENTS_ENABLED
```

### Trigger Configuration

```yaml
# trigger.yaml
name: my-trigger
description: Build on push to main
github:
  owner: my-org
  name: my-repo
  push:
    branch: ^main$
filename: cloudbuild.yaml
substitutions:
  _ENV: production
  _REGION: us-central1
includedFiles:
  - 'src/**'
  - 'Dockerfile'
ignoredFiles:
  - 'docs/**'
  - '**.md'
```

```bash
# Create trigger from file
gcloud builds triggers create github \
  --trigger-config=trigger.yaml
```

### Terraform Configuration

```hcl
resource "google_cloudbuild_trigger" "main_branch" {
  name        = "main-branch-trigger"
  description = "Build on push to main"
  
  github {
    owner = "my-org"
    name  = "my-repo"
    
    push {
      branch = "^main$"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  substitutions = {
    _ENV    = "production"
    _REGION = "us-central1"
  }
  
  included_files = [
    "src/**",
    "Dockerfile"
  ]
  
  ignored_files = [
    "docs/**",
    "**.md"
  ]
}

resource "google_cloudbuild_trigger" "release_tag" {
  name        = "release-tag-trigger"
  description = "Build on release tags"
  
  github {
    owner = "my-org"
    name  = "my-repo"
    
    push {
      tag = "^v[0-9]+\\.[0-9]+\\.[0-9]+$"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  substitutions = {
    _ENV = "production"
  }
}

resource "google_cloudbuild_trigger" "pull_request" {
  name        = "pull-request-trigger"
  description = "Build on pull requests"
  
  github {
    owner = "my-org"
    name  = "my-repo"
    
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED"
    }
  }
  
  filename = "cloudbuild.yaml"
}
```

---

## Build Steps

### Common Builders

**Official Builders:**

| Builder | Image | Use Case |
|---------|-------|----------|
| **docker** | gcr.io/cloud-builders/docker | Docker operations |
| **gcloud** | gcr.io/cloud-builders/gcloud | gcloud commands |
| **kubectl** | gcr.io/cloud-builders/kubectl | Kubernetes |
| **git** | gcr.io/cloud-builders/git | Git operations |
| **npm** | gcr.io/cloud-builders/npm | Node.js |
| **maven** | gcr.io/cloud-builders/mvn | Java/Maven |
| **gradle** | gcr.io/cloud-builders/gradle | Java/Gradle |
| **go** | gcr.io/cloud-builders/go | Go |

### Custom Build Steps

```yaml
steps:
  # Use official builder
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'myapp', '.']
  
  # Use Docker Hub image
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['install']
  
  # Use custom builder
  - name: 'us-central1-docker.pkg.dev/$PROJECT_ID/builders/custom-builder'
    args: ['custom', 'command']
  
  # Run shell script
  - name: 'ubuntu'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        echo "Running custom script"
        ./scripts/deploy.sh
  
  # Set environment variables
  - name: 'node:18'
    env:
      - 'NODE_ENV=production'
      - 'API_URL=https://api.example.com'
    args: ['npm', 'run', 'build']
  
  # Use secrets
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        echo "$$API_KEY" > /workspace/api-key.txt
    secretEnv: ['API_KEY']

# Define secrets
availableSecrets:
  secretManager:
    - versionName: projects/$PROJECT_ID/secrets/api-key/versions/latest
      env: 'API_KEY'
```

### Parallel Steps

```yaml
# Run steps in parallel
steps:
  # Step 1: Install dependencies (runs first)
  - name: 'node:18'
    id: 'install'
    entrypoint: 'npm'
    args: ['install']
  
  # Steps 2-4: Run in parallel (wait for step 1)
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
  
  # Step 5: Build (wait for all tests)
  - name: 'node:18'
    id: 'build'
    entrypoint: 'npm'
    args: ['run', 'build']
    waitFor: ['lint', 'test-unit', 'test-integration']
```

---

## Docker Builds

### Simple Docker Build

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

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Multi-Stage Build

```dockerfile
# Dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 8080
CMD ["node", "dist/index.js"]
```

```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--cache-from'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
      - '.'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Build with Arguments

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--build-arg'
      - 'NODE_ENV=production'
      - '--build-arg'
      - 'API_URL=https://api.example.com'
      - '--build-arg'
      - 'VERSION=$TAG_NAME'
      - '.'
```

### Kaniko Build

```yaml
# Build without Docker daemon (more secure)
steps:
  - name: 'gcr.io/kaniko-project/executor:latest'
    args:
      - '--destination=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--cache=true'
      - '--cache-ttl=24h'
```

---

## Advanced Features

### Build Caching

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
      - '.'
  
  # Push new image
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
```

### Secrets Management

```yaml
steps:
  # Use Secret Manager
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        echo "$$DATABASE_PASSWORD" > /workspace/db-password.txt
        echo "$$API_KEY" > /workspace/api-key.txt
    secretEnv: ['DATABASE_PASSWORD', 'API_KEY']

availableSecrets:
  secretManager:
    - versionName: projects/$PROJECT_ID/secrets/database-password/versions/latest
      env: 'DATABASE_PASSWORD'
    - versionName: projects/$PROJECT_ID/secrets/api-key/versions/latest
      env: 'API_KEY'
```

### Conditional Steps

```yaml
steps:
  # Always run
  - name: 'node:18'
    id: 'install'
    entrypoint: 'npm'
    args: ['install']
  
  # Run only on main branch
  - name: 'node:18'
    id: 'deploy-prod'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if [ "$BRANCH_NAME" = "main" ]; then
          npm run deploy:prod
        else
          echo "Skipping production deployment"
        fi
```

### Artifacts

```yaml
steps:
  # Build and test
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['run', 'build']
  
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['test']

# Save artifacts
artifacts:
  objects:
    location: 'gs://$PROJECT_ID-build-artifacts'
    paths:
      - 'dist/**'
      - 'coverage/**'
      - 'test-results/**'
```

---

## Integration

### Deploy to Cloud Run

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
  
  # Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'myapp'
      - '--image'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Deploy to GKE

```yaml
steps:
  # Build and push image
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
  
  # Deploy to GKE
  - name: 'gcr.io/cloud-builders/kubectl'
    args:
      - 'set'
      - 'image'
      - 'deployment/myapp'
      - 'myapp=us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
    env:
      - 'CLOUDSDK_COMPUTE_REGION=us-central1'
      - 'CLOUDSDK_CONTAINER_CLUSTER=my-cluster'

images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
```

### Deploy to App Engine

```yaml
steps:
  # Deploy to App Engine
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'app'
      - 'deploy'
      - 'app.yaml'
      - '--version'
      - '$SHORT_SHA'
      - '--no-promote'
```

---

## Cost Optimization

### Pricing

**Build Time:**
- First 120 build-minutes/day: Free
- Additional: $0.003/build-minute

**Machine Types:**

| Type | vCPUs | Memory | Price/min |
|------|-------|--------|-----------|
| **n1-standard-1** | 1 | 3.75 GB | $0.003 |
| **n1-highcpu-8** | 8 | 7.2 GB | $0.016 |
| **n1-highcpu-32** | 32 | 28.8 GB | $0.064 |
| **e2-medium** | 2 | 4 GB | $0.0025 |

### Optimization Strategies

**1. Use build caching:**

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '--cache-from'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:latest'
      - '-t'
      - 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA'
      - '.'
```

**2. Optimize Docker layers:**

```dockerfile
# Bad: Reinstalls dependencies on every code change
COPY . .
RUN npm install

# Good: Cache dependencies
COPY package*.json ./
RUN npm ci
COPY . .
```

**3. Use appropriate machine type:**

```yaml
options:
  machineType: 'E2_MEDIUM'  # Cheaper for light builds
  # machineType: 'N1_HIGHCPU_8'  # For heavy builds
```

**4. Parallel execution:**

```yaml
steps:
  - name: 'node:18'
    id: 'test-1'
    args: ['npm', 'run', 'test:unit']
    waitFor: ['-']  # Start immediately
  
  - name: 'node:18'
    id: 'test-2'
    args: ['npm', 'run', 'test:integration']
    waitFor: ['-']  # Start immediately
```

**5. Set appropriate timeout:**

```yaml
timeout: '600s'  # 10 minutes instead of default 60 minutes
```

### Cost Example

**Scenario:** 100 builds/month, 5 minutes each

```
Build time: 100 × 5 = 500 minutes
Free tier: 120 min/day × 30 = 3,600 minutes
Billable: 0 minutes
Cost: $0/month

With n1-highcpu-8:
Build time: 100 × 2 = 200 minutes (faster)
Free tier: 3,600 minutes
Billable: 0 minutes
Cost: $0/month

Large team (1,000 builds/month, 5 min each):
Build time: 1,000 × 5 = 5,000 minutes
Free tier: 3,600 minutes
Billable: 1,400 minutes
Cost: 1,400 × $0.003 = $4.20/month
```

---

## Best Practices

### Build Configuration

✅ Use cloudbuild.yaml for consistency  
✅ Implement build caching  
✅ Use multi-stage Docker builds  
✅ Optimize Docker layers  
✅ Set appropriate timeouts  
✅ Use substitutions for flexibility  
✅ Document build steps  
✅ Version control build configs  

### Security

✅ Use Secret Manager for secrets  
✅ Scan images for vulnerabilities  
✅ Use least privilege service accounts  
✅ Enable audit logging  
✅ Use private repositories  
✅ Implement binary authorization  
✅ Regular security audits  
✅ Use signed images  

### Performance

✅ Use build caching  
✅ Parallel step execution  
✅ Optimize Docker layers  
✅ Use appropriate machine types  
✅ Minimize build artifacts  
✅ Use regional resources  
✅ Monitor build times  
✅ Regular performance reviews  

### Reliability

✅ Implement retry logic  
✅ Use health checks  
✅ Monitor build success rates  
✅ Set up alerting  
✅ Test build configs  
✅ Document failure scenarios  
✅ Implement rollback procedures  
✅ Regular testing  

---

## Troubleshooting

### Build Failures

```bash
# View build logs
gcloud builds log BUILD_ID

# List recent builds
gcloud builds list --limit=10

# Describe build
gcloud builds describe BUILD_ID

# Cancel build
gcloud builds cancel BUILD_ID
```

### Permission Issues

```bash
# Check service account permissions
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:*@cloudbuild.gserviceaccount.com"

# Grant required permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/artifactregistry.writer
```

### Timeout Issues

```yaml
# Increase timeout
timeout: '3600s'  # 1 hour

# Or use default (10 minutes)
# timeout: '600s'
```

---

## Next Steps

- **[Cloud Deploy](3-Cloud-Deploy.md)** - Continuous delivery
- **[CI/CD Patterns](4-CICD-Patterns.md)** - Implementation patterns
- **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
