# Containers & DevOps Best Practices

Production guidelines for containers and CI/CD on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Container Best Practices](#container-best-practices)
2. [CI/CD Best Practices](#cicd-best-practices)
3. [Security Best Practices](#security-best-practices)
4. [Performance Best Practices](#performance-best-practices)
5. [Monitoring Best Practices](#monitoring-best-practices)
6. [Cost Optimization](#cost-optimization)
7. [Disaster Recovery](#disaster-recovery)
8. [Team Practices](#team-practices)

---

## Container Best Practices

### Docker Image Optimization

✅ **Use multi-stage builds:**

```dockerfile
# Bad: Large image with build tools
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["node", "dist/index.js"]

# Good: Multi-stage build
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
USER node
CMD ["node", "dist/index.js"]
```

✅ **Optimize layer caching:**

```dockerfile
# Bad: Invalidates cache on any file change
COPY . .
RUN npm install

# Good: Cache dependencies separately
COPY package*.json ./
RUN npm ci
COPY . .
```

✅ **Use specific base image tags:**

```dockerfile
# Bad: Unpredictable updates
FROM node:latest

# Good: Specific version
FROM node:18.19.0-alpine3.19
```

✅ **Minimize image size:**

```dockerfile
# Use alpine variants
FROM node:18-alpine

# Remove unnecessary files
RUN npm ci --only=production && \
    npm cache clean --force

# Use .dockerignore
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.DS_Store
```

✅ **Run as non-root user:**

```dockerfile
FROM node:18-alpine

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app
COPY --chown=nodejs:nodejs . .

USER nodejs
CMD ["node", "index.js"]
```

### Container Security

✅ **Scan for vulnerabilities:**

```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'myapp:$COMMIT_SHA', '.']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA']
  
  # Wait for scan
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        sleep 30
        CRITICAL=$(gcloud artifacts docker images describe \
          us-central1-docker.pkg.dev/$PROJECT_ID/my-repo/myapp:$COMMIT_SHA \
          --show-all-metadata \
          --format='value(image_summary.vulnerability_counts.CRITICAL)')
        
        if [ "$CRITICAL" -gt 0 ]; then
          echo "Critical vulnerabilities found"
          exit 1
        fi
```

✅ **Use distroless images:**

```dockerfile
# Minimal attack surface
FROM gcr.io/distroless/nodejs18-debian11
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
CMD ["/app/dist/index.js"]
```

✅ **Sign images:**

```bash
# Sign with Binary Authorization
gcloud beta container binauthz attestations sign-and-create \
  --artifact-url=us-central1-docker.pkg.dev/PROJECT/repo/image:tag \
  --attestor=my-attestor \
  --attestor-project=PROJECT_ID
```

---

## CI/CD Best Practices

### Build Configuration

✅ **Use declarative configuration:**

```yaml
# cloudbuild.yaml - version controlled
steps:
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['ci']
  
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['test']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', '$_IMAGE_NAME:$COMMIT_SHA', '.']

substitutions:
  _IMAGE_NAME: 'us-central1-docker.pkg.dev/${PROJECT_ID}/my-repo/myapp'

options:
  machineType: 'E2_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
  
timeout: '1800s'
```

✅ **Implement build caching:**

```yaml
steps:
  # Pull previous image
  - name: 'gcr.io/cloud-builders/docker'
    entrypoint: 'bash'
    args:
      - '-c'
      - 'docker pull $_IMAGE_NAME:latest || exit 0'
  
  # Build with cache
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '--cache-from'
      - '$_IMAGE_NAME:latest'
      - '-t'
      - '$_IMAGE_NAME:$COMMIT_SHA'
      - '.'
```

✅ **Use substitutions for flexibility:**

```yaml
substitutions:
  _ENV: 'production'
  _REGION: 'us-central1'
  _SERVICE_NAME: 'myapp'
  _IMAGE_NAME: 'us-central1-docker.pkg.dev/${PROJECT_ID}/my-repo/${_SERVICE_NAME}'

steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - '${_SERVICE_NAME}-${_ENV}'
      - '--image'
      - '${_IMAGE_NAME}:$COMMIT_SHA'
      - '--region'
      - '${_REGION}'
```

### Testing Strategy

✅ **Implement comprehensive testing:**

```yaml
steps:
  # Unit tests
  - name: 'node:18'
    id: 'test-unit'
    entrypoint: 'npm'
    args: ['run', 'test:unit']
  
  # Integration tests
  - name: 'node:18'
    id: 'test-integration'
    entrypoint: 'npm'
    args: ['run', 'test:integration']
  
  # E2E tests
  - name: 'node:18'
    id: 'test-e2e'
    entrypoint: 'npm'
    args: ['run', 'test:e2e']
  
  # Security scan
  - name: 'aquasec/trivy'
    args: ['image', '--severity', 'HIGH,CRITICAL', '$_IMAGE_NAME:$COMMIT_SHA']
  
  # Performance test
  - name: 'grafana/k6'
    args: ['run', 'loadtest.js']
```

✅ **Fail fast:**

```yaml
steps:
  # Lint first (fast)
  - name: 'node:18'
    id: 'lint'
    entrypoint: 'npm'
    args: ['run', 'lint']
  
  # Then run tests
  - name: 'node:18'
    id: 'test'
    entrypoint: 'npm'
    args: ['test']
    waitFor: ['lint']
  
  # Build only if tests pass
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', '$_IMAGE_NAME:$COMMIT_SHA', '.']
    waitFor: ['test']
```

### Deployment Strategy

✅ **Use progressive delivery:**

```yaml
# clouddeploy.yaml
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
  name: my-pipeline
serialPipeline:
  stages:
    # Auto-deploy to dev
    - targetId: dev
      profiles: [dev]
    
    # Auto-deploy to test
    - targetId: test
      profiles: [test]
    
    # Manual approval for staging
    - targetId: staging
      profiles: [staging]
      strategy:
        standard:
          verify: true
    
    # Manual approval + canary for prod
    - targetId: prod
      profiles: [prod]
      strategy:
        canary:
          canaryDeployment:
            percentages: [10, 25, 50, 75]
            verify: true
```

✅ **Implement approval gates:**

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

✅ **Enable rollback:**

```bash
# Automatic rollback on failure
gcloud deploy rollouts rollback ROLLOUT_ID \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1
```

---

## Security Best Practices

### Secret Management

✅ **Use Secret Manager:**

```yaml
steps:
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

✅ **Never commit secrets:**

```bash
# .gitignore
.env
.env.local
*.key
*.pem
secrets/
credentials.json
```

✅ **Use service accounts:**

```yaml
# cloudbuild.yaml
serviceAccount: 'projects/PROJECT_ID/serviceAccounts/build-sa@PROJECT_ID.iam.gserviceaccount.com'

options:
  logging: CLOUD_LOGGING_ONLY
```

### Access Control

✅ **Implement least privilege:**

```bash
# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:build-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.writer

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:deploy-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.developer
```

✅ **Enable audit logging:**

```bash
# Enable Cloud Build audit logs
gcloud logging sinks create build-audit-sink \
  storage.googleapis.com/audit-logs-bucket \
  --log-filter='resource.type="cloud_build"'
```

✅ **Use Binary Authorization:**

```yaml
# policy.yaml
admissionWhitelistPatterns:
  - namePattern: us-central1-docker.pkg.dev/PROJECT_ID/my-repo/*
defaultAdmissionRule:
  requireAttestationsBy:
    - projects/PROJECT_ID/attestors/my-attestor
  evaluationMode: REQUIRE_ATTESTATION
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
```

---

## Performance Best Practices

### Build Performance

✅ **Use parallel execution:**

```yaml
steps:
  - name: 'node:18'
    id: 'install'
    args: ['npm', 'ci']
  
  # Run in parallel
  - name: 'node:18'
    id: 'lint'
    args: ['npm', 'run', 'lint']
    waitFor: ['install']
  
  - name: 'node:18'
    id: 'test'
    args: ['npm', 'test']
    waitFor: ['install']
  
  - name: 'node:18'
    id: 'build'
    args: ['npm', 'run', 'build']
    waitFor: ['lint', 'test']
```

✅ **Optimize machine types:**

```yaml
options:
  # For light builds
  machineType: 'E2_MEDIUM'
  
  # For heavy builds
  # machineType: 'N1_HIGHCPU_32'
```

✅ **Use build caching:**

```dockerfile
# Enable BuildKit cache
# syntax=docker/dockerfile:1
FROM node:18 AS builder
WORKDIR /app

# Cache dependencies
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

COPY . .
RUN npm run build
```

### Deployment Performance

✅ **Use regional resources:**

```yaml
# Use same region for all resources
substitutions:
  _REGION: 'us-central1'
  _ARTIFACT_REGISTRY: 'us-central1-docker.pkg.dev'
  _CLUSTER_LOCATION: 'us-central1'
```

✅ **Implement health checks:**

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
        - name: myapp
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
```

---

## Monitoring Best Practices

### Build Monitoring

✅ **Track build metrics:**

```bash
# Create dashboard for build metrics
gcloud monitoring dashboards create --config-from-file=dashboard.json
```

**dashboard.json:**
```json
{
  "displayName": "Cloud Build Dashboard",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Build Success Rate",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_build\" metric.type=\"cloudbuild.googleapis.com/build/count\"",
                  "aggregation": {
                    "alignmentPeriod": "3600s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        }
      }
    ]
  }
}
```

✅ **Set up alerts:**

```bash
# Alert on build failures
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Build Failure Alert" \
  --condition-display-name="Build Failed" \
  --condition-threshold-value=1 \
  --condition-threshold-duration=60s \
  --condition-filter='resource.type="cloud_build" AND metric.type="cloudbuild.googleapis.com/build/count" AND metric.label.status="FAILURE"'
```

### Deployment Monitoring

✅ **Monitor deployment health:**

```yaml
# Cloud Deploy with verification
strategy:
  canary:
    canaryDeployment:
      percentages: [10, 50]
      verify: true
    
    runtimeConfig:
      kubernetes:
        serviceNetworking:
          service: myapp-service
          deployment: myapp
```

✅ **Track deployment metrics:**

```bash
# View deployment history
gcloud deploy releases list \
  --delivery-pipeline=my-pipeline \
  --region=us-central1

# Monitor rollout status
gcloud deploy rollouts list \
  --delivery-pipeline=my-pipeline \
  --release=release-001 \
  --region=us-central1
```

---

## Cost Optimization

### Build Cost Optimization

✅ **Use free tier:**

```
Free tier: 120 build-minutes/day
- Small team: Usually sufficient
- Large team: Optimize build times
```

✅ **Optimize build times:**

```yaml
# Use caching
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '--cache-from'
      - '$_IMAGE_NAME:latest'
      - '-t'
      - '$_IMAGE_NAME:$COMMIT_SHA'
      - '.'

# Use appropriate machine type
options:
  machineType: 'E2_MEDIUM'  # Cheaper for light builds
```

✅ **Reduce build frequency:**

```yaml
# Only build on specific branches
includedFiles:
  - 'src/**'
  - 'Dockerfile'
ignoredFiles:
  - 'docs/**'
  - '**.md'
```

### Storage Cost Optimization

✅ **Implement retention policies:**

```json
{
  "rules": [
    {
      "id": "delete-old-images",
      "action": "DELETE",
      "condition": {
        "olderThan": "30d",
        "tagState": "UNTAGGED"
      }
    },
    {
      "id": "keep-recent-versions",
      "action": "KEEP",
      "mostRecentVersions": {
        "keepCount": 10
      }
    }
  ]
}
```

✅ **Delete unused images:**

```bash
# List old images
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-repo \
  --filter="createTime<2025-01-01"

# Delete old images
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:old-tag
```

---

## Disaster Recovery

### Backup Strategy

✅ **Version control everything:**

```bash
# Store in Git
- cloudbuild.yaml
- clouddeploy.yaml
- Dockerfile
- k8s manifests
- Terraform configs
```

✅ **Multi-region artifacts:**

```bash
# Create multi-region repository
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us \
  --description="Multi-region repository"
```

✅ **Document recovery procedures:**

```markdown
# Disaster Recovery Runbook

## Scenario 1: Build System Failure
1. Check Cloud Build status
2. Verify service account permissions
3. Check Artifact Registry availability
4. Fallback: Manual build and deploy

## Scenario 2: Deployment Failure
1. Check Cloud Deploy status
2. Verify target cluster health
3. Review rollout logs
4. Rollback to previous version

## Scenario 3: Complete Outage
1. Switch to backup region
2. Deploy from multi-region artifacts
3. Update DNS/load balancer
4. Verify application health
```

---

## Team Practices

### Code Review

✅ **Review build configurations:**

```yaml
# Require approval for cloudbuild.yaml changes
# .github/CODEOWNERS
cloudbuild.yaml @platform-team
clouddeploy.yaml @platform-team
Dockerfile @platform-team
```

✅ **Automated checks:**

```yaml
# Run checks on PR
steps:
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['run', 'lint']
  
  - name: 'node:18'
    entrypoint: 'npm'
    args: ['test']
  
  - name: 'hadolint/hadolint'
    args: ['hadolint', 'Dockerfile']
```

### Documentation

✅ **Document pipelines:**

```markdown
# CI/CD Pipeline Documentation

## Build Process
1. Lint code
2. Run tests
3. Build Docker image
4. Push to Artifact Registry
5. Create Cloud Deploy release

## Deployment Process
1. Deploy to dev (automatic)
2. Deploy to test (automatic)
3. Deploy to staging (manual approval)
4. Deploy to prod (manual approval + canary)

## Rollback Process
1. Identify failed deployment
2. Run rollback command
3. Verify application health
4. Investigate root cause
```

✅ **Maintain runbooks:**

```markdown
# Runbook: Failed Deployment

## Symptoms
- Deployment stuck in pending
- Health checks failing
- Error in logs

## Investigation
1. Check Cloud Deploy status
2. Review rollout logs
3. Check target cluster
4. Verify image availability

## Resolution
1. Rollback deployment
2. Fix issue
3. Create new release
4. Monitor deployment
```

---

## Production Checklist

### Before Going Live

- [ ] Multi-stage Docker builds implemented
- [ ] Vulnerability scanning enabled
- [ ] Binary Authorization configured
- [ ] Secrets in Secret Manager
- [ ] Service accounts with least privilege
- [ ] Build caching enabled
- [ ] Progressive delivery configured
- [ ] Approval gates for production
- [ ] Monitoring and alerting set up
- [ ] Rollback procedures tested
- [ ] Documentation complete
- [ ] Team trained on procedures
- [ ] Disaster recovery plan documented
- [ ] Cost optimization implemented
- [ ] Security audit completed

### After Going Live

- [ ] Monitor build success rates
- [ ] Track deployment frequency
- [ ] Review security scans
- [ ] Optimize build times
- [ ] Review costs monthly
- [ ] Update documentation
- [ ] Conduct post-mortems
- [ ] Regular security audits
- [ ] Performance reviews
- [ ] Team retrospectives

---

## Next Steps

- **[Overview](0-Overview.md)** - Containers & DevOps overview
- **[Artifact Registry](1-Artifact-Registry.md)** - Container storage
- **[Cloud Build](2-Cloud-Build.md)** - CI/CD builds
- **[Cloud Deploy](3-Cloud-Deploy.md)** - Continuous delivery
- **[CI/CD Patterns](4-CICD-Patterns.md)** - Implementation patterns

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
