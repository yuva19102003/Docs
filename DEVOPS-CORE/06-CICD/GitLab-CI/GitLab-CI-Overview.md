# GitLab CI/CD Overview

## What is GitLab CI/CD?

GitLab CI/CD is a built-in continuous integration and deployment tool integrated directly into GitLab. It provides a complete DevOps platform with source control, CI/CD, security scanning, and monitoring all in one place.

### Key Features

- **Built-in CI/CD**: No external tools needed
- **Pipeline as Code**: `.gitlab-ci.yml` in repository
- **Auto DevOps**: Automatic CI/CD configuration
- **Container Registry**: Built-in Docker registry
- **Security Scanning**: SAST, DAST, dependency scanning
- **Review Apps**: Temporary environments for merge requests
- **GitLab Runners**: Self-hosted or shared runners
- **Kubernetes Integration**: Native K8s deployment
- **Multi-Project Pipelines**: Trigger pipelines across projects

## GitLab CI/CD Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                  GITLAB CI/CD ARCHITECTURE                    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────┐                                              │
│  │ Developer  │                                              │
│  └──────┬─────┘                                              │
│         │                                                     │
│         │ 1. Push Code                                       │
│         ▼                                                     │
│  ┌─────────────────────────────────────┐                    │
│  │        GITLAB SERVER                 │                    │
│  ├─────────────────────────────────────┤                    │
│  │  • Git Repository                   │                    │
│  │  • .gitlab-ci.yml Parser            │                    │
│  │  • Pipeline Scheduler               │                    │
│  │  • Job Queue                        │                    │
│  │  • Container Registry               │                    │
│  │  • Artifact Storage                 │                    │
│  └────────┬────────────────────────────┘                    │
│           │                                                   │
│           │ 2. Dispatch Jobs                                 │
│           ▼                                                   │
│  ┌─────────────────────────────────────┐                    │
│  │       GITLAB RUNNERS                 │                    │
│  ├─────────────────────────────────────┤                    │
│  │                                      │                    │
│  │  ┌──────────┐  ┌──────────┐        │                    │
│  │  │ Runner 1 │  │ Runner 2 │        │                    │
│  │  │ (Docker) │  │ (Shell)  │        │                    │
│  │  └────┬─────┘  └────┬─────┘        │                    │
│  │       │             │               │                    │
│  │       │ 3. Execute  │               │                    │
│  │       ▼             ▼               │                    │
│  │  ┌──────────┐  ┌──────────┐        │                    │
│  │  │   Job    │  │   Job    │        │                    │
│  │  │  Build   │  │   Test   │        │                    │
│  │  └──────────┘  └──────────┘        │                    │
│  └─────────────────────────────────────┘                    │
│           │                                                   │
│           │ 4. Report Results                                │
│           ▼                                                   │
│  ┌─────────────────────────────────────┐                    │
│  │      DEPLOYMENT TARGETS              │                    │
│  ├─────────────────────────────────────┤                    │
│  │  • Kubernetes                       │                    │
│  │  • Cloud Platforms                  │                    │
│  │  • Servers                          │                    │
│  │  • Container Registry               │                    │
│  └─────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────┘
```

## Pipeline Execution Flow

```
┌──────────────────────────────────────────────────────────────┐
│                  PIPELINE EXECUTION FLOW                      │
└──────────────────────────────────────────────────────────────┘

    Git Push
       │
       ▼
  ┌─────────────────┐
  │ Parse           │
  │ .gitlab-ci.yml  │
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ Create Pipeline │
  └────────┬────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────┐
  │              STAGES (Sequential)                     │
  ├─────────────────────────────────────────────────────┤
  │                                                      │
  │  STAGE 1: build                                     │
  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
  │  │  Job 1   │  │  Job 2   │  │  Job 3   │         │
  │  │ (Parallel)  │ (Parallel)  │ (Parallel)         │
  │  └──────────┘  └──────────┘  └──────────┘         │
  │       │             │             │                 │
  │       └─────────────┴─────────────┘                 │
  │                     │                               │
  │                     ▼                               │
  │  STAGE 2: test                                      │
  │  ┌──────────┐  ┌──────────┐                        │
  │  │Unit Test │  │Integration│                        │
  │  └──────────┘  └──────────┘                        │
  │       │             │                               │
  │       └─────────────┘                               │
  │             │                                       │
  │             ▼                                       │
  │  STAGE 3: deploy                                    │
  │  ┌──────────┐                                       │
  │  │  Deploy  │                                       │
  │  └──────────┘                                       │
  │                                                      │
  └─────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────┐
  │ Pipeline        │
  │ Complete        │
  └─────────────────┘
```

## Core Concepts

### 1. Pipeline

A pipeline is the top-level component of CI/CD. It consists of:
- **Jobs**: What to run
- **Stages**: When to run jobs

### 2. Stages

Stages define the order of execution:
- Jobs in the same stage run in parallel
- Stages run sequentially
- Default stages: build, test, deploy

### 3. Jobs

Jobs are the basic building blocks:
- Define what scripts to execute
- Run in isolated environments (containers)
- Can produce artifacts

### 4. Runners

Runners execute jobs:
- **Shared Runners**: Provided by GitLab
- **Specific Runners**: Self-hosted
- **Group Runners**: Shared across group projects

### 5. Executors

How runners execute jobs:
- **Docker**: Run jobs in containers (recommended)
- **Shell**: Run jobs directly on host
- **Kubernetes**: Run jobs in K8s pods
- **Docker Machine**: Auto-scale Docker runners
- **SSH**: Execute on remote servers

## Basic .gitlab-ci.yml Structure

```yaml
# Define stages
stages:
  - build
  - test
  - deploy

# Define variables
variables:
  APP_NAME: "myapp"
  VERSION: "1.0.0"

# Before script (runs before each job)
before_script:
  - echo "Starting job"

# Job definition
build-job:
  stage: build
  image: node:20
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test-job:
  stage: test
  image: node:20
  script:
    - npm test
  dependencies:
    - build-job

deploy-job:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
```

## GitLab CI/CD vs Other Tools

| Feature | GitLab CI/CD | GitHub Actions | Jenkins | Azure DevOps |
|---------|--------------|----------------|---------|--------------|
| **Integration** | Built-in | Built-in | External | Built-in |
| **Configuration** | YAML | YAML | Groovy/YAML | YAML |
| **Runners** | Self-hosted/Shared | Self-hosted/Cloud | Agents | Self-hosted/Cloud |
| **Container Registry** | Built-in | Built-in | Plugin | Built-in |
| **Security Scanning** | Built-in | Marketplace | Plugins | Built-in |
| **Auto DevOps** | Yes | No | No | Partial |
| **Review Apps** | Yes | No | No | No |
| **Learning Curve** | Moderate | Easy | Steep | Moderate |

## Key Features

### Auto DevOps

Automatic CI/CD configuration with:
- Auto Build
- Auto Test
- Auto Code Quality
- Auto SAST
- Auto Dependency Scanning
- Auto Container Scanning
- Auto Review Apps
- Auto Deploy
- Auto Monitoring

### Container Registry

Built-in Docker registry:
- Per-project registries
- Automatic cleanup policies
- Vulnerability scanning
- Access control

### Security Scanning

Built-in security features:
- **SAST**: Static Application Security Testing
- **DAST**: Dynamic Application Security Testing
- **Dependency Scanning**: Check for vulnerable dependencies
- **Container Scanning**: Scan Docker images
- **License Compliance**: Check license compatibility

### Review Apps

Temporary environments for merge requests:
- Automatic deployment on MR creation
- Unique URL for each MR
- Automatic cleanup on MR close

### Environments

Track deployments:
- Environment history
- Rollback capabilities
- Environment-specific variables
- Deployment approvals

## Use Cases

### 1. Continuous Integration

Build and test code on every commit:
```yaml
test:
  script:
    - npm test
```

### 2. Continuous Deployment

Automatically deploy to production:
```yaml
deploy:
  script:
    - kubectl apply -f k8s/
  only:
    - main
```

### 3. Multi-Environment Deployment

Deploy to different environments:
```yaml
deploy-staging:
  script:
    - deploy.sh staging
  only:
    - develop

deploy-production:
  script:
    - deploy.sh production
  only:
    - main
  when: manual
```

### 4. Docker Build and Push

Build and push Docker images:
```yaml
docker-build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t myapp:latest .
    - docker push myapp:latest
```

### 5. Kubernetes Deployment

Deploy to Kubernetes:
```yaml
deploy:
  image: bitnami/kubectl:latest
  script:
    - kubectl apply -f k8s/
```

## Best Practices

✅ **Use Docker Executor**: Isolated, reproducible builds
✅ **Cache Dependencies**: Speed up builds with caching
✅ **Use Artifacts**: Pass data between jobs
✅ **Implement Stages**: Organize pipeline logically
✅ **Use Variables**: Parameterize pipelines
✅ **Protect Secrets**: Use CI/CD variables with masking
✅ **Parallel Jobs**: Run independent jobs in parallel
✅ **Manual Deployments**: Require approval for production
✅ **Use Templates**: Reuse common configurations
✅ **Monitor Pipelines**: Set up alerts for failures

## Getting Started

Ready to use GitLab CI/CD? Continue to:
- **GitLab-CI-Pipelines.md** - Creating pipelines
- **GitLab-Runners.md** - Setting up runners
- **GitLab-CI-Examples.md** - Real-world examples
