# OpenShift CI/CD

## Overview

OpenShift provides native CI/CD capabilities through BuildConfigs, Pipelines (Tekton), and integration with external CI/CD tools.

## Build Strategies

### Source-to-Image (S2I)
Builds container images from source code without Dockerfile.

```bash
# Create S2I build
oc new-app python:3.9~https://github.com/user/myapp.git

# Trigger build
oc start-build myapp
```

### Docker Build
Uses Dockerfile in repository.

```bash
# Create Docker build
oc new-build https://github.com/user/myapp.git --strategy=docker

# With specific Dockerfile
oc new-build https://github.com/user/myapp.git \
  --strategy=docker \
  --dockerfile=Dockerfile.prod
```

### Pipeline Build
Uses Jenkins or Tekton pipelines.

## BuildConfig

### S2I BuildConfig
```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: myapp
  namespace: myproject
spec:
  source:
    type: Git
    git:
      uri: https://github.com/user/myapp.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python:3.9
  output:
    to:
      kind: ImageStreamTag
      name: myapp:latest
  triggers:
  - type: ConfigChange
  - type: ImageChange
  - type: GitHub
    github:
      secret: webhook-secret
```

### Docker BuildConfig
```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: myapp-docker
spec:
  source:
    type: Git
    git:
      uri: https://github.com/user/myapp.git
    contextDir: /
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
  output:
    to:
      kind: ImageStreamTag
      name: myapp:latest
```

## Webhooks

### GitHub Webhook
```bash
# Get webhook URL
oc describe bc myapp | grep -A 1 "Webhook GitHub"

# Configure in GitHub:
# Settings > Webhooks > Add webhook
# Payload URL: <webhook-url>
# Content type: application/json
```

### Generic Webhook
```bash
# Trigger build via webhook
curl -X POST -k \
  https://api.cluster.example.com:6443/apis/build.openshift.io/v1/namespaces/myproject/buildconfigs/myapp/webhooks/secret/generic
```

## OpenShift Pipelines (Tekton)

### Install Pipelines Operator
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

### Task Definition
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-image
spec:
  params:
  - name: IMAGE
    type: string
  - name: CONTEXT
    type: string
    default: .
  workspaces:
  - name: source
  steps:
  - name: build
    image: quay.io/buildah/stable
    script: |
      buildah bud -t $(params.IMAGE) $(params.CONTEXT)
      buildah push $(params.IMAGE)
    securityContext:
      privileged: true
```

### Pipeline Definition
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-deploy-pipeline
spec:
  params:
  - name: GIT_REPO
    type: string
  - name: IMAGE_NAME
    type: string
  workspaces:
  - name: shared-workspace
  tasks:
  - name: fetch-repository
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: url
      value: $(params.GIT_REPO)
  
  - name: build-image
    taskRef:
      name: build-image
    runAfter:
    - fetch-repository
    workspaces:
    - name: source
      workspace: shared-workspace
    params:
    - name: IMAGE
      value: $(params.IMAGE_NAME)
  
  - name: deploy
    taskRef:
      name: openshift-client
    runAfter:
    - build-image
    params:
    - name: SCRIPT
      value: |
        oc rollout latest dc/myapp
        oc rollout status dc/myapp
```

### PipelineRun
```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-deploy-run
spec:
  pipelineRef:
    name: build-deploy-pipeline
  params:
  - name: GIT_REPO
    value: https://github.com/user/myapp.git
  - name: IMAGE_NAME
    value: image-registry.openshift-image-registry.svc:5000/myproject/myapp:latest
  workspaces:
  - name: shared-workspace
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

## Deployment Strategies

### Rolling Deployment
```yaml
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: myapp
spec:
  replicas: 3
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 25%
      maxSurge: 25%
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
```

### Blue-Green Deployment
```bash
# Deploy blue version
oc new-app --name=blue myapp:v1
oc expose svc/blue

# Deploy green version
oc new-app --name=green myapp:v2

# Create route to blue
oc create route edge myapp --service=blue

# Switch to green
oc patch route myapp -p '{"spec":{"to":{"name":"green"}}}'
```

### Canary Deployment
```bash
# Deploy stable version
oc new-app --name=stable myapp:v1
oc scale dc/stable --replicas=9

# Deploy canary version
oc new-app --name=canary myapp:v2
oc scale dc/canary --replicas=1

# Create route with both backends
oc create route edge myapp --service=stable
oc set route-backends myapp stable=90 canary=10
```

## GitOps with ArgoCD

### Install ArgoCD
```bash
# Create namespace
oc new-project argocd

# Install ArgoCD
oc apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD server
oc create route edge argocd-server \
  --service=argocd-server \
  --port=https \
  --insecure-policy=Redirect \
  -n argocd
```

### ArgoCD Application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/myapp-config.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: myproject
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Jenkins Integration

### Deploy Jenkins
```bash
# Create Jenkins
oc new-app jenkins-persistent

# Get Jenkins URL
oc get route jenkins
```

### Jenkinsfile
```groovy
pipeline {
  agent {
    label 'maven'
  }
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
    stage('Build Image') {
      steps {
        script {
          openshift.withCluster() {
            openshift.withProject('myproject') {
              openshift.startBuild('myapp', '--from-dir=.')
            }
          }
        }
      }
    }
    stage('Deploy') {
      steps {
        script {
          openshift.withCluster() {
            openshift.withProject('myproject') {
              openshift.selector('dc', 'myapp').rollout().latest()
            }
          }
        }
      }
    }
  }
}
```

## Image Promotion

### Tag Images Across Environments
```bash
# Tag for dev
oc tag myapp:latest myapp:dev

# Promote to test
oc tag myapp:dev myapp:test -n test-project

# Promote to prod
oc tag myapp:test myapp:prod -n prod-project
```

## Automated Rollbacks

### Deployment Hooks
```yaml
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: myapp
spec:
  strategy:
    type: Rolling
    rollingParams:
      pre:
        failurePolicy: Abort
        execNewPod:
          command:
          - /bin/sh
          - -c
          - echo "Pre-deployment check"
          containerName: myapp
      post:
        failurePolicy: Ignore
        execNewPod:
          command:
          - /bin/sh
          - -c
          - echo "Post-deployment notification"
          containerName: myapp
```

### Rollback
```bash
# Rollback to previous version
oc rollback myapp

# Rollback to specific version
oc rollback myapp --to-version=2

# Cancel ongoing deployment
oc rollout cancel dc/myapp
```

## Best Practices

1. **Immutable Images**: Tag images with version/commit hash
2. **Separate Environments**: Use different projects for dev/test/prod
3. **Automated Testing**: Include tests in pipeline
4. **Security Scanning**: Scan images for vulnerabilities
5. **GitOps**: Store configurations in Git
6. **Rollback Strategy**: Have automated rollback procedures
7. **Monitoring**: Monitor deployments and builds
8. **Secrets Management**: Use secrets for sensitive data
9. **Resource Limits**: Set appropriate resource limits
10. **Documentation**: Document pipeline and deployment processes
