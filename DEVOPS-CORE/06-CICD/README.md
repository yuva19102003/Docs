# CI/CD - Continuous Integration & Continuous Deployment

## Overview
This directory contains comprehensive guides for CI/CD tools, pipelines, and best practices. Learn how to automate building, testing, and deploying applications using industry-standard tools.

---

## What is CI/CD?

### Continuous Integration (CI)
Automatically build, test, and merge code whenever developers push commits to a shared repository.

**Benefits:**
- Detect errors early
- Prevent integration issues
- Maintain a deployable build
- Improve code quality

### Continuous Deployment (CD)
Automatically deploy applications after CI is successful.

**Benefits:**
- Faster delivery
- Reduced manual errors
- Consistent deployments
- Quick rollbacks

---

## Learning Path

### Beginner Level
1. **[CI/CD Fundamentals](0-CICD-Fundamentals.md)** - Start here
   - CI/CD concepts and workflow
   - Pipeline stages
   - Best practices
   - Tools overview

2. **[GitHub Actions](GitHub-Actions/)** - Cloud-native CI/CD
   - Workflow automation
   - YAML configuration
   - Secrets management
   - Deployment examples

### Intermediate Level
3. **[Jenkins](Jenkins/)** - Traditional CI/CD server
   - Installation and setup
   - Pipeline configuration
   - Docker integration
   - Real-world projects

4. **[GitLab CI](GitLab-CI/)** - Integrated CI/CD
   - .gitlab-ci.yml configuration
   - Runners and executors
   - Pipeline optimization

5. **[Azure DevOps](Azure-DevOps/)** - Microsoft ecosystem
   - Azure Pipelines
   - Release management
   - Integration with Azure services

### Advanced Level
6. **[ArgoCD](ArgoCD/)** - GitOps for Kubernetes
   - Declarative deployments
   - Automated sync
   - Rollback strategies
   - Multi-cluster management

7. **[SonarQube](SonarQube/)** - Code quality & security
   - Static code analysis
   - Security scanning
   - Quality gates
   - CI/CD integration

---

## CI/CD Pipeline Stages

```
┌─────────────┐
│   Source    │  Developer pushes code
└──────┬──────┘
       │
┌──────▼──────┐
│    Build    │  Compile code, create artifacts
└──────┬──────┘
       │
┌──────▼──────┐
│    Test     │  Unit, integration, security tests
└──────┬──────┘
       │
┌──────▼──────┐
│   Deploy    │  Deploy to environment
└──────┬──────┘
       │
┌──────▼──────┐
│   Monitor   │  Track metrics and errors
└─────────────┘
```

---

## Tools Comparison

### CI/CD Platforms

| Tool | Best For | Complexity | Cost | Cloud/Self-Hosted |
|------|----------|------------|------|-------------------|
| **GitHub Actions** | GitHub repos, cloud-native | Low | Free tier | Cloud |
| **GitLab CI** | GitLab repos, integrated | Medium | Free tier | Both |
| **Jenkins** | Flexibility, plugins | High | Free | Self-hosted |
| **Azure DevOps** | Microsoft ecosystem | Medium | Free tier | Cloud |
| **CircleCI** | Fast builds, Docker | Low | Free tier | Cloud |

### Deployment Tools

| Tool | Type | Best For | Learning Curve |
|------|------|----------|----------------|
| **ArgoCD** | GitOps | Kubernetes deployments | Medium |
| **FluxCD** | GitOps | Kubernetes, Helm | Medium |
| **Spinnaker** | CD Platform | Multi-cloud deployments | High |
| **Harness** | CD Platform | Enterprise deployments | Medium |

### Code Quality Tools

| Tool | Purpose | Language Support | Integration |
|------|---------|------------------|-------------|
| **SonarQube** | Code quality, security | 25+ languages | Excellent |
| **Snyk** | Dependency scanning | Multiple | Good |
| **Trivy** | Container scanning | N/A | Good |
| **CodeClimate** | Code quality | Multiple | Good |

---

## Quick Start Examples

### GitHub Actions - Simple CI
```yaml
name: CI Pipeline
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
```

### Jenkins - Declarative Pipeline
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

### GitLab CI - Basic Pipeline
```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm install
    - npm run build

test:
  stage: test
  script:
    - npm test

deploy:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
```

---

## Common Pipeline Patterns

### 1. Build → Test → Deploy
```
Code Push → Build Artifact → Run Tests → Deploy to Staging → Deploy to Production
```

### 2. Feature Branch Workflow
```
Feature Branch → CI Tests → Code Review → Merge to Main → Deploy
```

### 3. GitOps Workflow
```
Code Change → Build Image → Update Manifest → ArgoCD Syncs → Deployed
```

### 4. Blue-Green Deployment
```
Deploy to Green → Test Green → Switch Traffic → Keep Blue as Backup
```

### 5. Canary Deployment
```
Deploy to 10% → Monitor → Deploy to 50% → Monitor → Deploy to 100%
```

---

## Best Practices

### Pipeline Design
- ✅ Keep pipelines fast (< 10 minutes)
- ✅ Fail fast - run quick tests first
- ✅ Use caching for dependencies
- ✅ Parallelize independent jobs
- ✅ Use pipeline templates for consistency

### Security
- ✅ Store secrets in secure vaults
- ✅ Scan dependencies for vulnerabilities
- ✅ Scan Docker images before deployment
- ✅ Use least privilege for service accounts
- ✅ Audit pipeline access and changes

### Testing
- ✅ Unit tests in every pipeline
- ✅ Integration tests before deployment
- ✅ Security scans (SAST/DAST)
- ✅ Performance tests for critical paths
- ✅ Smoke tests after deployment

### Deployment
- ✅ Use infrastructure as code
- ✅ Implement rollback strategies
- ✅ Deploy to staging first
- ✅ Use feature flags for gradual rollout
- ✅ Monitor deployments actively

### Monitoring
- ✅ Track pipeline success rates
- ✅ Monitor deployment frequency
- ✅ Measure lead time for changes
- ✅ Track mean time to recovery (MTTR)
- ✅ Set up alerts for failures

---

## Real-World Pipeline Example

### Complete DevOps Flow
```
Developer commits code
    ↓
GitHub Actions triggers
    ↓
Build Docker image
    ↓
Run unit tests
    ↓
SonarQube code analysis
    ↓
Security scan (Trivy)
    ↓
Push image to registry
    ↓
Update Kubernetes manifest
    ↓
ArgoCD auto-syncs
    ↓
Deploy to cluster
    ↓
Prometheus monitors
    ↓
Grafana dashboards
    ↓
Slack notification
```

---

## Troubleshooting Guide

### Pipeline Fails at Build
1. Check build logs for errors
2. Verify dependencies are available
3. Check for syntax errors
4. Ensure correct build tool version
5. Verify environment variables

### Tests Failing
1. Run tests locally first
2. Check test environment setup
3. Verify test data availability
4. Check for flaky tests
5. Review recent code changes

### Deployment Fails
1. Check deployment logs
2. Verify credentials and permissions
3. Check target environment health
4. Verify image/artifact availability
5. Check network connectivity

### Slow Pipelines
1. Identify bottleneck stages
2. Implement caching
3. Parallelize independent jobs
4. Optimize test execution
5. Use faster runners/agents

---

## Integration Examples

### Jenkins + Docker + Kubernetes
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }
        stage('Push') {
            steps {
                sh 'docker push myapp:${BUILD_NUMBER}'
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl set image deployment/myapp myapp=myapp:${BUILD_NUMBER}'
            }
        }
    }
}
```

### GitHub Actions + ArgoCD
```yaml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and Push
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker push myapp:${{ github.sha }}
      - name: Update Manifest
        run: |
          sed -i 's|image:.*|image: myapp:${{ github.sha }}|' k8s/deployment.yaml
          git commit -am "Update image"
          git push
```

---

## Metrics to Track

### DORA Metrics (DevOps Research and Assessment)

1. **Deployment Frequency**
   - How often you deploy to production
   - Elite: Multiple times per day

2. **Lead Time for Changes**
   - Time from commit to production
   - Elite: Less than one hour

3. **Mean Time to Recovery (MTTR)**
   - Time to recover from failure
   - Elite: Less than one hour

4. **Change Failure Rate**
   - Percentage of deployments causing failure
   - Elite: 0-15%

---

## Additional Resources

### Official Documentation
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [SonarQube Docs](https://docs.sonarqube.org/)

### Learning Resources
- [CI/CD Best Practices](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)
- [GitOps Principles](https://www.gitops.tech/)
- [DORA Metrics](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance)

---

## Directory Structure

```
CICD/
├── README.md                    # This file
├── 0-CICD-Fundamentals.md       # CI/CD fundamentals
├── GitHub-Actions/              # GitHub Actions guides
│   └── GitHub-Actions.md
├── Jenkins/                     # Jenkins setup and pipelines
│   ├── README.md
│   ├── Jenkins.md
│   └── java-maven-sonar-argocd-helm-k8s/
├── GitLab-CI/                   # GitLab CI configuration
│   ├── GitLab-CI.md
│   └── .gitlab-ci.yml
├── Azure-DevOps/                # Azure DevOps pipelines
│   └── Azure-DevOps.md
├── ArgoCD/                      # GitOps with ArgoCD
│   ├── README.md
│   └── [images]
└── SonarQube/                   # Code quality and security
    ├── README.md
    ├── 1-Server-Setup.md
    ├── 2-Project-Local-Scan.md
    └── 3-Docker-Local-Scan.md
```

---

## Quick Links

### Tools
- [GitHub Actions](GitHub-Actions/GitHub-Actions.md)
- [Jenkins](Jenkins/README.md)
- [GitLab CI](GitLab-CI/GitLab-CI.md)
- [Azure DevOps](Azure-DevOps/Azure-DevOps.md)
- [ArgoCD](ArgoCD/README.md)
- [SonarQube](SonarQube/README.md)

### Concepts
- [CI/CD Fundamentals](0-CICD-Fundamentals.md)
- [Pipeline Stages](#cicd-pipeline-stages)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting-guide)

### Related Topics
- [DevOps Core](../README.md)
- [Containerization](../CONTAINERIZATION/)
- [Orchestration](../CONTAINERIZATION/Kubernetes/)
- [Monitoring](../OBSERVABILITY/)

---

**Last Updated:** January 2026
**Maintained by:** DevOps Documentation Team
