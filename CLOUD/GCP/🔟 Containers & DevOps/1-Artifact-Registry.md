# Artifact Registry - Modern Artifact Management

Complete guide to Google Cloud Artifact Registry - unified artifact management for containers and packages.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Repository Types](#repository-types)
3. [Setup and Configuration](#setup-and-configuration)
4. [Docker Images](#docker-images)
5. [Language Packages](#language-packages)
6. [Security](#security)
7. [Vulnerability Scanning](#vulnerability-scanning)
8. [Cost Optimization](#cost-optimization)
9. [Best Practices](#best-practices)

---

## Introduction

Artifact Registry is the next generation of Container Registry, providing a single place for managing containers and language packages.

### Key Features

✅ Unified artifact management  
✅ Docker, Maven, npm, Python, Go support  
✅ Regional and multi-region repositories  
✅ Vulnerability scanning  
✅ IAM-based access control  
✅ Encryption at rest and in transit  
✅ Integration with Cloud Build  
✅ Artifact analysis  
✅ Retention policies  
✅ Remote repositories  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Artifact Registry                          │
├─────────────────────────────────────────────────────┤
│  Repository: my-repo (us-central1)                  │
│  ┌──────────────────────────────────────────────┐   │
│  │  Docker Images                               │   │
│  │  ├─ myapp:v1.0.0                             │   │
│  │  ├─ myapp:v1.0.1                             │   │
│  │  └─ myapp:latest                             │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Maven Packages                              │   │
│  │  ├─ com.example:mylib:1.0.0                  │   │
│  │  └─ com.example:mylib:1.0.1                  │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Features:                                          │
│  - Vulnerability scanning                           │
│  - Access control (IAM)                             │
│  - Encryption at rest                               │
│  - Audit logging                                    │
└─────────────────────────────────────────────────────┘
```

---

## Repository Types

### Supported Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| **Docker** | Container images | Application containers |
| **Maven** | Java packages | Java libraries |
| **npm** | Node.js packages | JavaScript libraries |
| **Python** | Python packages | Python libraries |
| **Apt** | Debian packages | OS packages |
| **Yum** | RPM packages | OS packages |
| **Go** | Go modules | Go libraries |
| **KFP** | Kubeflow Pipelines | ML pipelines |

### Repository Modes

**Standard Repository:**
- Store your own artifacts
- Full read/write access
- Vulnerability scanning

**Remote Repository:**
- Proxy to external registries
- Cache artifacts locally
- Reduce external bandwidth

**Virtual Repository:**
- Aggregate multiple repositories
- Single endpoint
- Priority-based resolution

---

## Setup and Configuration

### Create Repository

```bash
# Create Docker repository
gcloud artifacts repositories create my-docker-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker images"

# Create Maven repository
gcloud artifacts repositories create my-maven-repo \
  --repository-format=maven \
  --location=us-central1 \
  --description="Maven packages"

# Create npm repository
gcloud artifacts repositories create my-npm-repo \
  --repository-format=npm \
  --location=us-central1 \
  --description="npm packages"

# Create Python repository
gcloud artifacts repositories create my-python-repo \
  --repository-format=python \
  --location=us-central1 \
  --description="Python packages"

# Create multi-region repository
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us \
  --description="Multi-region Docker repository"
```

### List Repositories

```bash
# List all repositories
gcloud artifacts repositories list

# List repositories in specific location
gcloud artifacts repositories list --location=us-central1

# Describe repository
gcloud artifacts repositories describe my-docker-repo \
  --location=us-central1
```

### Terraform Configuration

```hcl
resource "google_artifact_registry_repository" "docker_repo" {
  location      = "us-central1"
  repository_id = "my-docker-repo"
  description   = "Docker images"
  format        = "DOCKER"
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}

resource "google_artifact_registry_repository" "maven_repo" {
  location      = "us-central1"
  repository_id = "my-maven-repo"
  description   = "Maven packages"
  format        = "MAVEN"
  
  maven_config {
    allow_snapshot_overwrites = false
    version_policy            = "RELEASE"
  }
}

resource "google_artifact_registry_repository" "npm_repo" {
  location      = "us-central1"
  repository_id = "my-npm-repo"
  description   = "npm packages"
  format        = "NPM"
}

# IAM binding
resource "google_artifact_registry_repository_iam_member" "reader" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:my-sa@project.iam.gserviceaccount.com"
}
```

---

## Docker Images

### Configure Docker

```bash
# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# For multiple regions
gcloud auth configure-docker \
  us-central1-docker.pkg.dev,\
  europe-west1-docker.pkg.dev,\
  asia-east1-docker.pkg.dev
```

### Push Images

```bash
# Build image
docker build -t myapp:v1.0.0 .

# Tag image
docker tag myapp:v1.0.0 \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0

# Push image
docker push \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0

# Tag as latest
docker tag myapp:v1.0.0 \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:latest

docker push \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:latest
```

### Pull Images

```bash
# Pull image
docker pull \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0

# Pull latest
docker pull \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:latest
```

### List Images

```bash
# List images in repository
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo

# List tags for specific image
gcloud artifacts docker tags list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp

# Describe image
gcloud artifacts docker images describe \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0
```

### Delete Images

```bash
# Delete specific tag
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0

# Delete all tags for image
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp \
  --delete-tags
```

---

## Language Packages

### Maven (Java)

**Configure Maven:**

```xml
<!-- settings.xml -->
<settings>
  <servers>
    <server>
      <id>artifact-registry</id>
      <configuration>
        <httpConfiguration>
          <get>
            <usePreemptive>true</usePreemptive>
          </get>
          <head>
            <usePreemptive>true</usePreemptive>
          </head>
        </httpConfiguration>
      </configuration>
    </server>
  </servers>
</settings>

<!-- pom.xml -->
<project>
  <distributionManagement>
    <repository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/PROJECT_ID/my-maven-repo</url>
    </repository>
  </distributionManagement>
  
  <repositories>
    <repository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/PROJECT_ID/my-maven-repo</url>
    </repository>
  </repositories>
</project>
```

**Publish Package:**

```bash
# Authenticate
gcloud auth application-default login

# Deploy
mvn deploy
```

### npm (Node.js)

**Configure npm:**

```bash
# Set registry
npm config set registry https://us-central1-npm.pkg.dev/PROJECT_ID/my-npm-repo/

# Authenticate
npx google-artifactregistry-auth
```

**.npmrc:**

```
@myorg:registry=https://us-central1-npm.pkg.dev/PROJECT_ID/my-npm-repo/
//us-central1-npm.pkg.dev/PROJECT_ID/my-npm-repo/:always-auth=true
```

**Publish Package:**

```bash
# Publish
npm publish
```

### Python

**Configure pip:**

```bash
# Install keyring
pip install keyring
pip install keyrings.google-artifactregistry-auth

# Configure pip
pip config set global.index-url https://us-central1-python.pkg.dev/PROJECT_ID/my-python-repo/simple/
```

**Publish Package:**

```bash
# Install twine
pip install twine

# Build package
python setup.py sdist bdist_wheel

# Upload
twine upload --repository-url \
  https://us-central1-python.pkg.dev/PROJECT_ID/my-python-repo/ \
  dist/*
```

---

## Security

### IAM Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Artifact Registry Reader** | Read artifacts | Pull images/packages |
| **Artifact Registry Writer** | Read + Write | Push images/packages |
| **Artifact Registry Repository Administrator** | Full control | Manage repository |
| **Artifact Registry Administrator** | All repositories | Admin access |

### Grant Access

```bash
# Grant reader access
gcloud artifacts repositories add-iam-policy-binding my-docker-repo \
  --location=us-central1 \
  --member=serviceAccount:my-sa@project.iam.gserviceaccount.com \
  --role=roles/artifactregistry.reader

# Grant writer access
gcloud artifacts repositories add-iam-policy-binding my-docker-repo \
  --location=us-central1 \
  --member=user:developer@example.com \
  --role=roles/artifactregistry.writer

# Grant admin access
gcloud artifacts repositories add-iam-policy-binding my-docker-repo \
  --location=us-central1 \
  --member=group:admins@example.com \
  --role=roles/artifactregistry.repoAdmin
```

### Service Account Authentication

```bash
# Create service account
gcloud iam service-accounts create artifact-registry-sa \
  --display-name="Artifact Registry Service Account"

# Grant permissions
gcloud artifacts repositories add-iam-policy-binding my-docker-repo \
  --location=us-central1 \
  --member=serviceAccount:artifact-registry-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.writer

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=artifact-registry-sa@PROJECT_ID.iam.gserviceaccount.com

# Authenticate Docker
cat key.json | docker login -u _json_key --password-stdin \
  https://us-central1-docker.pkg.dev
```

---

## Vulnerability Scanning

### Enable Scanning

```bash
# Enable Container Analysis API
gcloud services enable containeranalysis.googleapis.com

# Scanning is automatic for new images
```

### View Vulnerabilities

```bash
# List vulnerabilities
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo \
  --show-occurrences

# Get vulnerability details
gcloud artifacts docker images describe \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:v1.0.0 \
  --show-all-metadata
```

### Vulnerability Severity

| Severity | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | Immediate threat | Block deployment |
| **HIGH** | Serious vulnerability | Review required |
| **MEDIUM** | Moderate risk | Monitor |
| **LOW** | Minor issue | Informational |
| **MINIMAL** | Negligible | Informational |

### Binary Authorization

```bash
# Create policy
cat > policy.yaml <<EOF
admissionWhitelistPatterns:
- namePattern: us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/*
defaultAdmissionRule:
  requireAttestationsBy:
  - projects/PROJECT_ID/attestors/my-attestor
  evaluationMode: REQUIRE_ATTESTATION
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
EOF

# Apply policy
gcloud container binauthz policy import policy.yaml
```

---

## Cost Optimization

### Pricing Components

**Storage:**
- $0.10/GB/month (standard)
- $0.05/GB/month (multi-region)

**Network Egress:**
- Same region: Free
- Cross-region: $0.01/GB
- Internet: $0.12/GB

**Operations:**
- Free

### Optimization Strategies

**1. Use retention policies:**

```bash
# Create cleanup policy
gcloud artifacts repositories set-cleanup-policies my-docker-repo \
  --location=us-central1 \
  --policy=policy.json
```

**policy.json:**
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

**2. Use regional repositories:**

```bash
# Use regional instead of multi-region
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us-central1  # Regional
```

**3. Optimize image sizes:**

```dockerfile
# Multi-stage build
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
CMD ["node", "dist/index.js"]
```

**4. Delete unused images:**

```bash
# List old images
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo \
  --filter="createTime<2025-01-01"

# Delete old images
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo/myapp:old-tag
```

### Cost Example

**Scenario:** 100 GB storage, 500 GB egress/month

```
Storage:
- 100 GB × $0.10 = $10.00/month

Network Egress:
- Same region: 200 GB × $0 = $0
- Cross-region: 200 GB × $0.01 = $2.00
- Internet: 100 GB × $0.12 = $12.00

Total: $24.00/month
```

---

## Best Practices

### Repository Management

✅ Use separate repositories per environment  
✅ Implement retention policies  
✅ Use regional repositories for better performance  
✅ Enable vulnerability scanning  
✅ Use multi-region for critical images  
✅ Implement naming conventions  
✅ Document repository purposes  
✅ Regular cleanup of unused images  

### Image Management

✅ Tag images with version and commit SHA  
✅ Use semantic versioning  
✅ Avoid using `latest` in production  
✅ Use multi-stage builds  
✅ Optimize image layers  
✅ Scan images for vulnerabilities  
✅ Sign images for verification  
✅ Document image contents  

### Security

✅ Use IAM for access control  
✅ Enable audit logging  
✅ Implement least privilege  
✅ Use service accounts  
✅ Enable vulnerability scanning  
✅ Use Binary Authorization  
✅ Encrypt sensitive data  
✅ Regular security audits  

### Performance

✅ Use regional repositories  
✅ Implement caching strategies  
✅ Optimize image sizes  
✅ Use compression  
✅ Minimize layers  
✅ Use build cache  
✅ Parallel builds  
✅ Monitor performance  

---

## Troubleshooting

### Authentication Issues

```bash
# Re-authenticate
gcloud auth login
gcloud auth configure-docker us-central1-docker.pkg.dev

# Check credentials
gcloud auth list

# Use service account
gcloud auth activate-service-account --key-file=key.json
```

### Permission Denied

```bash
# Check IAM permissions
gcloud artifacts repositories get-iam-policy my-docker-repo \
  --location=us-central1

# Grant required permissions
gcloud artifacts repositories add-iam-policy-binding my-docker-repo \
  --location=us-central1 \
  --member=user:user@example.com \
  --role=roles/artifactregistry.writer
```

### Image Not Found

```bash
# Verify repository exists
gcloud artifacts repositories describe my-docker-repo \
  --location=us-central1

# List images
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/PROJECT_ID/my-docker-repo

# Check image name and tag
docker images | grep myapp
```

---

## Next Steps

- **[Cloud Build](2-Cloud-Build.md)** - CI/CD build service
- **[Cloud Deploy](3-Cloud-Deploy.md)** - Continuous delivery
- **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
