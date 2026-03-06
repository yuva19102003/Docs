# 🔟 Containers & DevOps - Overview

Learn container management and deployment automation on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Container Services](#container-services)
3. [CI/CD Services](#cicd-services)
4. [Service Comparison](#service-comparison)
5. [DevOps Workflow](#devops-workflow)
6. [Architecture Patterns](#architecture-patterns)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP provides comprehensive services for containerization, continuous integration, and continuous deployment.

### Container & DevOps Spectrum

```
Container Registry → Build → Deploy → Monitor
       |              |        |         |
       v              v        v         v
┌──────────┐   ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Artifact │   │  Cloud   │ │  Cloud   │ │  Cloud   │
│ Registry │   │  Build   │ │  Deploy  │ │Monitoring│
└──────────┘   └──────────┘ └──────────┘ └──────────┘
```

---

## Container Services

### 1. Artifact Registry

**Modern artifact management**

```
┌─────────────────────────────────────────┐
│        Artifact Registry                │
├─────────────────────────────────────────┤
│  Repositories:                          │
│  ┌──────────────────────────────────┐   │
│  │  Docker Images                   │   │
│  │  - Multi-arch support            │   │
│  │  - Vulnerability scanning        │   │
│  │  - Access control                │   │
│  └──────────────────────────────────┘   │
│  ┌──────────────────────────────────┐   │
│  │  Language Packages               │   │
│  │  - Maven (Java)                  │   │
│  │  - npm (Node.js)                 │   │
│  │  - Python packages               │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Features:                              │
│  - Regional/multi-region                │
│  - IAM integration                      │
│  - Encryption at rest                   │
│  - Vulnerability scanning               │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Unified artifact management
- Docker, Maven, npm, Python support
- Regional and multi-region repositories
- Vulnerability scanning
- IAM-based access control
- Encryption at rest and in transit

**Use Cases:**
- Container image storage
- Package management
- Multi-region distribution
- Secure artifact storage

### 2. Container Registry (Legacy)

**Docker image storage (being replaced by Artifact Registry)**

```
┌─────────────────────────────────────────┐
│        Container Registry               │
├─────────────────────────────────────────┤
│  gcr.io/PROJECT_ID/IMAGE:TAG            │
│                                         │
│  Features:                              │
│  - Docker image storage                 │
│  - Vulnerability scanning               │
│  - IAM integration                      │
│  - Cloud Storage backend                │
│                                         │
│  Status: Legacy (use Artifact Registry) │
└─────────────────────────────────────────┘
```

**Note:** Google recommends migrating to Artifact Registry.

---

## CI/CD Services

### 1. Cloud Build

**Serverless CI/CD platform**

```
┌─────────────────────────────────────────┐
│          Cloud Build                    │
├─────────────────────────────────────────┤
│  Build Pipeline:                        │
│  ┌──────────────────────────────────┐   │
│  │  1. Source (Git)                 │   │
│  │     ↓                            │   │
│  │  2. Build (Docker/Maven/npm)     │   │
│  │     ↓                            │   │
│  │  3. Test (Unit/Integration)      │   │
│  │     ↓                            │   │
│  │  4. Push (Artifact Registry)     │   │
│  │     ↓                            │   │
│  │  5. Deploy (GKE/Cloud Run)       │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Features:                              │
│  - Serverless builds                    │
│  - Docker support                       │
│  - Custom build steps                   │
│  - Parallel execution                   │
│  - Build triggers                       │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Serverless build execution
- Docker-in-Docker support
- Custom build steps
- Parallel builds
- GitHub/Bitbucket integration
- Build triggers (push, PR, tag)
- Build caching

**Use Cases:**
- Container image builds
- Application builds
- Automated testing
- Multi-stage builds

### 2. Cloud Deploy

**Managed continuous delivery**

```
┌─────────────────────────────────────────┐
│          Cloud Deploy                   │
├─────────────────────────────────────────┤
│  Delivery Pipeline:                     │
│  ┌──────────────────────────────────┐   │
│  │  Dev → Test → Staging → Prod    │   │
│  │   ↓      ↓       ↓        ↓     │   │
│  │  Auto   Auto   Manual   Manual  │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Features:                              │
│  - Progressive delivery                 │
│  - Canary deployments                   │
│  - Blue-green deployments               │
│  - Rollback support                     │
│  - Approval gates                       │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Managed CD service
- GKE and Cloud Run support
- Progressive delivery
- Canary and blue-green deployments
- Approval workflows
- Rollback capabilities
- Deployment verification

**Use Cases:**
- Multi-environment deployments
- Progressive rollouts
- Canary releases
- Production deployments

---

## Service Comparison

### Feature Matrix

| Feature | Artifact Registry | Cloud Build | Cloud Deploy |
|---------|------------------|-------------|--------------|
| **Purpose** | Artifact storage | CI/CD builds | Continuous delivery |
| **Pricing** | Storage + egress | Build minutes | Deployments |
| **Integration** | All GCP services | Git, Docker | GKE, Cloud Run |
| **Automation** | N/A | Triggers | Pipelines |
| **Deployment** | N/A | Manual/Auto | Progressive |

### Use Case Matrix

| Requirement | Recommended | Alternative | Reason |
|-------------|-------------|-------------|--------|
| **Store images** | Artifact Registry | Container Registry | Modern, unified |
| **Build containers** | Cloud Build | Jenkins | Serverless, native |
| **Deploy to GKE** | Cloud Deploy | kubectl | Managed, progressive |
| **CI/CD pipeline** | Cloud Build | GitHub Actions | Native integration |
| **Multi-region** | Artifact Registry | Cloud Storage | Purpose-built |

---

## DevOps Workflow

### Complete CI/CD Pipeline

```
┌─────────────────────────────────────────────────────┐
│              Complete DevOps Workflow               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Developer pushes code                           │
│     ↓                                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Source Repository (GitHub/Cloud Source)     │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │ Trigger                       │
│                     ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Cloud Build                                 │   │
│  │  - Checkout code                             │   │
│  │  - Run tests                                 │   │
│  │  - Build Docker image                        │   │
│  │  - Scan for vulnerabilities                  │   │
│  │  - Push to Artifact Registry                 │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │                               │
│                     ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Artifact Registry                           │   │
│  │  - Store image                               │   │
│  │  - Vulnerability scan                        │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │                               │
│                     ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Cloud Deploy                                │   │
│  │  - Deploy to Dev (auto)                      │   │
│  │  - Deploy to Test (auto)                     │   │
│  │  - Deploy to Staging (approval)              │   │
│  │  - Deploy to Prod (approval + canary)        │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │                               │
│                     ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Target Environment                          │   │
│  │  - GKE Cluster                               │   │
│  │  - Cloud Run Service                         │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │                               │
│                     ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  Monitoring                                  │   │
│  │  - Cloud Monitoring                          │   │
│  │  - Cloud Logging                             │   │
│  │  - Error Reporting                           │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Architecture Patterns

### Pattern 1: Simple CI/CD

```
GitHub
   ↓
Cloud Build
   ↓
Artifact Registry
   ↓
Cloud Run
```

**Use Case:** Simple web applications

### Pattern 2: Multi-Environment Pipeline

```
GitHub
   ↓
Cloud Build
   ↓
Artifact Registry
   ↓
Cloud Deploy
   ├─→ Dev (GKE)
   ├─→ Test (GKE)
   ├─→ Staging (GKE)
   └─→ Production (GKE)
```

**Use Case:** Enterprise applications

### Pattern 3: Microservices

```
GitHub (Multiple repos)
   ↓
Cloud Build (Per service)
   ↓
Artifact Registry
   ↓
Cloud Deploy
   └─→ GKE (Multiple services)
```

**Use Case:** Microservices architecture

### Pattern 4: Multi-Region

```
Cloud Build
   ↓
Artifact Registry (Multi-region)
   ├─→ us-central1
   ├─→ europe-west1
   └─→ asia-east1
        ↓
   Cloud Deploy
   └─→ Regional GKE clusters
```

**Use Case:** Global applications

---

## Quick Reference

### Artifact Registry

```bash
# Create repository
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us-central1

# Configure Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Push image
docker tag myapp us-central1-docker.pkg.dev/PROJECT/my-repo/myapp:v1
docker push us-central1-docker.pkg.dev/PROJECT/my-repo/myapp:v1
```

### Cloud Build

```bash
# Submit build
gcloud builds submit --tag gcr.io/PROJECT/myapp

# Create trigger
gcloud builds triggers create github \
  --repo-name=my-repo \
  --repo-owner=my-org \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml
```

### Cloud Deploy

```bash
# Create delivery pipeline
gcloud deploy apply --file=clouddeploy.yaml

# Create release
gcloud deploy releases create release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --images=myapp=us-central1-docker.pkg.dev/PROJECT/my-repo/myapp:v1
```

---

## Cost Comparison

### Pricing Overview

| Service | Pricing Model | Free Tier | Typical Cost |
|---------|--------------|-----------|--------------|
| **Artifact Registry** | Storage + egress | 0.5 GB | $0.10/GB/month |
| **Cloud Build** | Build minutes | 120 min/day | $0.003/min |
| **Cloud Deploy** | Per deployment | 5 deployments/month | $0.02/deployment |

### Cost Example

**Scenario:** Small team, 100 builds/month

```
Artifact Registry:
- Storage: 10 GB × $0.10 = $1.00
- Egress: 50 GB × $0.12 = $6.00
- Total: $7.00/month

Cloud Build:
- Build time: 100 builds × 5 min = 500 min
- Free tier: 120 min/day × 30 = 3,600 min
- Billable: 0 min
- Total: $0/month

Cloud Deploy:
- Deployments: 50/month
- Free tier: 5/month
- Billable: 45 × $0.02 = $0.90
- Total: $0.90/month

Total: $7.90/month
```

---

## Best Practices

### Container Management

✅ Use Artifact Registry over Container Registry  
✅ Enable vulnerability scanning  
✅ Use multi-stage Docker builds  
✅ Tag images with version and commit SHA  
✅ Implement image retention policies  
✅ Use regional repositories for better performance  
✅ Enable encryption at rest  
✅ Use IAM for access control  

### CI/CD Pipeline

✅ Automate testing in build pipeline  
✅ Use build triggers for automation  
✅ Implement approval gates for production  
✅ Use canary deployments  
✅ Enable rollback capabilities  
✅ Monitor deployment metrics  
✅ Use secrets management  
✅ Implement security scanning  

### Security

✅ Scan images for vulnerabilities  
✅ Use least privilege IAM  
✅ Enable binary authorization  
✅ Use private repositories  
✅ Implement secret management  
✅ Enable audit logging  
✅ Use VPC Service Controls  
✅ Regular security audits  

### Performance

✅ Use build caching  
✅ Optimize Docker layers  
✅ Use parallel builds  
✅ Implement progressive delivery  
✅ Monitor build times  
✅ Use regional resources  
✅ Optimize image sizes  
✅ Use multi-stage builds  

---

## Next Steps

1. **[Artifact Registry](1-Artifact-Registry.md)** - Container and artifact storage
2. **[Cloud Build](2-Cloud-Build.md)** - CI/CD build service
3. **[Cloud Deploy](3-Cloud-Deploy.md)** - Continuous delivery
4. **[CI/CD Patterns](4-CICD-Patterns.md)** - Implementation patterns
5. **[Best Practices](5-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- [DevOps Best Practices](https://cloud.google.com/architecture/devops)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
