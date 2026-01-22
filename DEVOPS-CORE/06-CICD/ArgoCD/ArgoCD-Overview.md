# ArgoCD Overview

## What is ArgoCD?

ArgoCD is a **declarative, GitOps continuous delivery tool** for Kubernetes. It automates the deployment of applications to Kubernetes clusters by continuously monitoring Git repositories and synchronizing the desired state with the actual cluster state.

### Key Features

- **GitOps Methodology**: Git as the single source of truth
- **Declarative Setup**: Define desired state in Git
- **Automated Sync**: Continuous monitoring and synchronization
- **Multi-Cluster Support**: Manage multiple Kubernetes clusters
- **Rollback Capabilities**: Easy rollback to previous versions
- **Health Assessment**: Application health monitoring
- **Web UI & CLI**: Multiple interfaces for management
- **SSO Integration**: LDAP, OIDC, SAML support
- **RBAC**: Fine-grained access control
- **Webhook Support**: GitHub, GitLab, Bitbucket integration

## GitOps Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                      GITOPS WITH ARGOCD                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────┐                                                  │
│  │ Developer  │                                                  │
│  └──────┬─────┘                                                  │
│         │                                                         │
│         │ 1. Push Code                                           │
│         ▼                                                         │
│  ┌─────────────────┐                                            │
│  │  Git Repository │                                            │
│  │  (Application)  │                                            │
│  └────────┬────────┘                                            │
│           │                                                       │
│           │ 2. CI Pipeline                                       │
│           ▼                                                       │
│  ┌─────────────────┐         ┌──────────────────┐              │
│  │   CI System     │────────►│ Container        │              │
│  │ (Jenkins/GHA)   │ Build   │ Registry         │              │
│  └────────┬────────┘         └──────────────────┘              │
│           │                                                       │
│           │ 3. Update Manifests                                  │
│           ▼                                                       │
│  ┌─────────────────┐                                            │
│  │  Git Repository │                                            │
│  │  (Manifests)    │                                            │
│  │  • Helm Charts  │                                            │
│  │  • Kustomize    │                                            │
│  │  • YAML         │                                            │
│  └────────┬────────┘                                            │
│           │                                                       │
│           │ 4. Monitor & Detect Changes                          │
│           ▼                                                       │
│  ┌─────────────────────────────────────┐                        │
│  │           ARGOCD                     │                        │
│  ├─────────────────────────────────────┤                        │
│  │  • Compare Desired vs Actual State  │                        │
│  │  • Detect Drift                     │                        │
│  │  • Sync Applications                │                        │
│  │  • Health Monitoring                │                        │
│  └────────┬────────────────────────────┘                        │
│           │                                                       │
│           │ 5. Deploy/Sync                                       │
│           ▼                                                       │
│  ┌─────────────────────────────────────┐                        │
│  │      KUBERNETES CLUSTER              │                        │
│  ├─────────────────────────────────────┤                        │
│  │  ┌──────────┐  ┌──────────┐        │                        │
│  │  │   Pod    │  │   Pod    │        │                        │
│  │  └──────────┘  └──────────┘        │                        │
│  │  ┌──────────┐  ┌──────────┐        │                        │
│  │  │ Service  │  │ Ingress  │        │                        │
│  │  └──────────┘  └──────────┘        │                        │
│  └─────────────────────────────────────┘                        │
│           │                                                       │
│           │ 6. Report Status                                     │
│           ▼                                                       │
│  ┌─────────────────┐                                            │
│  │  ArgoCD UI      │                                            │
│  │  • Sync Status  │                                            │
│  │  • Health       │                                            │
│  │  • History      │                                            │
│  └─────────────────┘                                            │
└──────────────────────────────────────────────────────────────────┘
```

## ArgoCD Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    ARGOCD ARCHITECTURE                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  ARGOCD COMPONENTS                          │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  ┌──────────────────┐         ┌──────────────────┐        │ │
│  │  │   API Server     │◄────────┤   Web UI         │        │ │
│  │  ├──────────────────┤         └──────────────────┘        │ │
│  │  │ • REST API       │                                      │ │
│  │  │ • gRPC API       │         ┌──────────────────┐        │ │
│  │  │ • Authentication │◄────────┤   CLI            │        │ │
│  │  │ • Authorization  │         └──────────────────┘        │ │
│  │  └────────┬─────────┘                                      │ │
│  │           │                                                 │ │
│  │           ▼                                                 │ │
│  │  ┌──────────────────┐                                      │ │
│  │  │  Repository      │                                      │ │
│  │  │  Server          │                                      │ │
│  │  ├──────────────────┤                                      │ │
│  │  │ • Git Ops        │                                      │
│  │  │ • Helm Charts    │                                      │ │
│  │  │ • Kustomize      │                                      │ │
│  │  │ • Manifest Gen   │                                      │ │
│  │  └────────┬─────────┘                                      │ │
│  │           │                                                 │ │
│  │           ▼                                                 │ │
│  │  ┌──────────────────┐                                      │ │
│  │  │  Application     │                                      │ │
│  │  │  Controller      │                                      │ │
│  │  ├──────────────────┤                                      │ │
│  │  │ • Sync Loop      │                                      │ │
│  │  │ • Health Check   │                                      │ │
│  │  │ • Diff Detection │                                      │ │
│  │  │ • Auto-Sync      │                                      │ │
│  │  └────────┬─────────┘                                      │ │
│  │           │                                                 │ │
│  │           ▼                                                 │ │
│  │  ┌──────────────────┐                                      │ │
│  │  │  Redis           │                                      │ │
│  │  │  (Cache)         │                                      │ │
│  │  └──────────────────┘                                      │ │
│  │                                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                          │                                        │
│                          │ Manages                                │
│                          ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              KUBERNETES CLUSTERS                             │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │                                                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │   Cluster 1  │  │   Cluster 2  │  │   Cluster N  │     │ │
│  │  │   (Dev)      │  │   (Staging)  │  │   (Prod)     │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  │                                                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                          ▲                                        │
│                          │ Pulls from                             │
│                          │                                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              GIT REPOSITORIES                                │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │                                                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │   GitHub     │  │   GitLab     │  │  Bitbucket   │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  │                                                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

## Core Concepts

### 1. Application

An ArgoCD Application is a Kubernetes resource that represents a deployed application instance. It defines:
- Source repository (Git URL, path, branch/tag)
- Destination cluster and namespace
- Sync policy (manual or automatic)
- Health status

### 2. Project

Projects provide logical grouping of applications with:
- Source repository restrictions
- Destination cluster/namespace restrictions
- Allowed/denied resource types
- RBAC policies

### 3. Sync Status

- **Synced**: Git state matches cluster state
- **OutOfSync**: Git state differs from cluster state
- **Unknown**: Unable to determine sync status

### 4. Health Status

- **Healthy**: Resource is functioning correctly
- **Progressing**: Resource is being deployed
- **Degraded**: Resource has issues
- **Suspended**: Resource is suspended
- **Missing**: Resource is missing from cluster
- **Unknown**: Health cannot be determined

### 5. Sync Strategies

**Manual Sync**
- User-initiated synchronization
- Full control over deployments
- Suitable for production environments

**Automatic Sync**
- ArgoCD automatically syncs on Git changes
- Optional self-healing
- Optional pruning of resources

### 6. Sync Phases

**Pre-Sync**: Run before sync (e.g., database migrations)
**Sync**: Deploy resources
**Post-Sync**: Run after sync (e.g., notifications, tests)
**Sync-Fail**: Run if sync fails

## Supported Manifest Formats

### 1. Plain Kubernetes YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0.0
```

### 2. Helm Charts

```yaml
# values.yaml
replicaCount: 3
image:
  repository: myapp
  tag: v1.0.0
```

### 3. Kustomize

```yaml
# kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml
images:
  - name: myapp
    newTag: v1.0.0
```

### 4. Jsonnet

```jsonnet
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'myapp',
  },
}
```

## ArgoCD vs Traditional CI/CD

| Aspect | Traditional CI/CD | ArgoCD (GitOps) |
|--------|-------------------|-----------------|
| **Deployment Trigger** | Push-based (CI pushes to cluster) | Pull-based (ArgoCD pulls from Git) |
| **Source of Truth** | CI/CD pipeline state | Git repository |
| **Cluster Access** | CI needs cluster credentials | Only ArgoCD needs access |
| **Drift Detection** | Manual | Automatic |
| **Rollback** | Re-run pipeline | Git revert |
| **Audit Trail** | CI logs | Git history |
| **Security** | Credentials in CI | Credentials in cluster |
| **Multi-Cluster** | Complex | Native support |

## Benefits of ArgoCD

### For Developers

✅ **Git as Single Source of Truth**: All changes tracked in Git
✅ **Easy Rollbacks**: Git revert to previous state
✅ **Visual Feedback**: See deployment status in UI
✅ **Self-Service**: Deploy without cluster access
✅ **Audit Trail**: Git history shows who changed what

### For Operations

✅ **Drift Detection**: Automatically detect manual changes
✅ **Multi-Cluster Management**: Manage multiple clusters from one place
✅ **Disaster Recovery**: Recreate cluster from Git
✅ **Security**: No cluster credentials in CI/CD
✅ **Compliance**: Enforce policies and approvals via Git

### For Organizations

✅ **Standardization**: Consistent deployment process
✅ **Scalability**: Manage hundreds of applications
✅ **Collaboration**: Git-based workflow familiar to developers
✅ **Observability**: Centralized view of all deployments
✅ **Cost Efficiency**: Reduce manual operations

## Use Cases

### 1. Continuous Deployment

Automatically deploy applications when manifests change in Git.

### 2. Multi-Environment Management

Manage dev, staging, and production environments from separate Git branches or repositories.

### 3. Multi-Cluster Deployments

Deploy the same application to multiple Kubernetes clusters.

### 4. Progressive Delivery

Implement canary deployments, blue-green deployments with ArgoCD Rollouts.

### 5. Disaster Recovery

Quickly restore cluster state from Git repository.

### 6. Configuration Management

Manage Kubernetes configurations across multiple clusters.

## ArgoCD Ecosystem

### ArgoCD Rollouts

Advanced deployment strategies:
- Canary deployments
- Blue-green deployments
- Analysis and progressive delivery
- Traffic management integration (Istio, Nginx, etc.)

### ArgoCD Image Updater

Automatically update container image versions in Git:
- Monitor container registries
- Update manifests with new image tags
- Create pull requests for review

### ArgoCD Notifications

Send notifications on application events:
- Slack, Microsoft Teams
- Email, Webhook
- Custom triggers and templates

### ArgoCD Autopilot

Bootstrap ArgoCD and applications:
- Opinionated GitOps structure
- Application scaffolding
- Quick start for new projects

## Best Practices

✅ **Separate App and Config Repos**: Keep application code and Kubernetes manifests in separate repositories
✅ **Use Projects**: Organize applications into projects for better RBAC
✅ **Enable Auto-Sync Carefully**: Use manual sync for production, auto-sync for dev/staging
✅ **Implement RBAC**: Restrict access based on teams and environments
✅ **Use App of Apps Pattern**: Manage multiple applications with a parent application
✅ **Monitor Sync Status**: Set up alerts for OutOfSync applications
✅ **Version Control Everything**: All Kubernetes resources in Git
✅ **Use Helm/Kustomize**: Parameterize manifests for different environments
✅ **Implement Pre/Post Sync Hooks**: Run migrations, tests, notifications
✅ **Regular Backups**: Backup ArgoCD configuration and application definitions

## Getting Started

Ready to install and use ArgoCD? Continue to:
- **ArgoCD-Installation.md** - Installation methods and setup
- **ArgoCD-Applications.md** - Creating and managing applications
- **ArgoCD-Advanced.md** - Multi-cluster, RBAC, SSO, and advanced features
- **ArgoCD-Examples.md** - Real-world examples and patterns
