# GitHub Actions - Reusable Workflows & Composite Actions

## Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│              Reusable Workflows & Composite Actions Flow                │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Trigger Event   │
│                  │
│  • Push          │
│  • Pull Request  │
│  • Schedule      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                    Main Workflow File                         │
│                                                               │
│  name: Main CI/CD Pipeline                                   │
│  on: [push, pull_request]                                    │
│                                                               │
│  jobs:                                                        │
│    build:                                                     │
│      uses: ./.github/workflows/reusable-build.yml           │
│    test:                                                      │
│      uses: ./.github/workflows/reusable-test.yml            │
│    deploy:                                                    │
│      uses: ./.github/workflows/reusable-deploy.yml          │
└────────┬──────────────────┬──────────────────┬───────────────┘
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Build Workflow  │ │  Test Workflow  │ │ Deploy Workflow │
│                 │ │                 │ │                 │
│ • Setup Node    │ │ • Unit Tests    │ │ • K8s Deploy    │
│ • Install Deps  │ │ • Integration   │ │ • Health Check  │
│ • Build App     │ │ • E2E Tests     │ │ • Rollback      │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         ├───────────────────┴───────────────────┤
         │                                       │
         ▼                                       ▼
┌─────────────────────────────┐   ┌─────────────────────────────┐
│   Composite Actions         │   │   Composite Actions         │
│                             │   │                             │
│  ┌────────────────────┐    │   │  ┌────────────────────┐    │
│  │  Setup Action      │    │   │  │  Docker Action     │    │
│  │                    │    │   │  │                    │    │
│  │  • Install Tools   │    │   │  │  • Build Image     │    │
│  │  • Cache Deps      │    │   │  │  • Push Image      │    │
│  │  • Configure Env   │    │   │  │  • Tag Image       │    │
│  └────────────────────┘    │   │  └────────────────────┘    │
└─────────────────────────────┘   └─────────────────────────────┘
         │                                       │
         └───────────────────┬───────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Job Complete   │
                    │                 │
                    │  • Artifacts    │
                    │  • Logs         │
                    │  • Status       │
                    └─────────────────┘
```

## Workflow Module Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Modular Workflow System                          │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│ Caller Workflow  │
│                  │
│   main.yml       │
└────────┬─────────┘
         │
         ├──────────────────┬──────────────────┬──────────────────┐
         │                  │                  │                  │
         ▼                  ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   Module 1:     │ │   Module 2:     │ │   Module 3:     │ │   Module 4:     │
│     Build       │ │   Security      │ │    Deploy       │ │   Notify        │
│                 │ │                 │ │                 │ │                 │
│ docker-build    │ │ security-scan   │ │  k8s-deploy     │ │  slack-notify   │
│     .yml        │ │     .yml        │ │     .yml        │ │     .yml        │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │                   │
         ▼                   ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Build Image    │ │  SAST Scan      │ │ Update Manifest │ │ Send Message    │
│  Push to        │ │  Dependency     │ │ Apply to K8s    │ │ Post Status     │
│  Registry       │ │  Container Scan │ │ Verify Deploy   │ │ Alert Team      │
└─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘
         │                   │                   │                   │
         └───────────────────┴───────────────────┴───────────────────┘
                                     │
                                     ▼
                            ┌─────────────────┐
                            │  Pipeline       │
                            │  Complete       │
                            └─────────────────┘
```

## Table of Contents
- [Reusable Workflows](#reusable-workflows)
- [Composite Actions](#composite-actions)
- [Calling Workflows](#calling-workflows)
- [Workflow Modules](#workflow-modules)
- [Best Practices](#best-practices)

## Reusable Workflows

Reusable workflows allow you to define a workflow once and call it from other workflows.

### Creating a Reusable Workflow

Create `.github/workflows/reusable-build.yml`:

```yaml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      node-version:
        description: 'Node.js version to use'
        required: false
        type: string
        default: '18'
      environment:
        description: 'Deployment environment'
        required: true
        type: string
    secrets:
      docker-username:
        required: true
      docker-password:
        required: true
    outputs:
      image-tag:
        description: 'Docker image tag'
        value: ${{ jobs.build.outputs.tag }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      tag: ${{ steps.meta.outputs.tags }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: myapp
          tags: |
            type=sha
            type=ref,event=branch
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.docker-username }}
          password: ${{ secrets.docker-password }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

### Calling a Reusable Workflow

Create `.github/workflows/main.yml`:

```yaml
name: Main CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    uses: ./.github/workflows/reusable-build.yml
    with:
      node-version: '20'
      environment: 'production'
    secrets:
      docker-username: ${{ secrets.DOCKER_USERNAME }}
      docker-password: ${{ secrets.DOCKER_PASSWORD }}
  
  deploy:
    needs: build-and-test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying image: ${{ needs.build-and-test.outputs.image-tag }}"
```

## Composite Actions

Composite actions allow you to combine multiple steps into a single reusable action.

### Creating a Composite Action

Create `.github/actions/setup-app/action.yml`:

```yaml
name: 'Setup Application'
description: 'Setup Node.js, install dependencies, and cache'

inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '18'
  cache-dependency-path:
    description: 'Path to package-lock.json'
    required: false
    default: 'package-lock.json'

outputs:
  cache-hit:
    description: 'Whether cache was hit'
    value: ${{ steps.cache.outputs.cache-hit }}

runs:
  using: 'composite'
  steps:
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'
        cache-dependency-path: ${{ inputs.cache-dependency-path }}
    
    - name: Cache node modules
      id: cache
      uses: actions/cache@v3
      with:
        path: node_modules
        key: ${{ runner.os }}-node-${{ hashFiles(inputs.cache-dependency-path) }}
        restore-keys: |
          ${{ runner.os }}-node-
    
    - name: Install dependencies
      if: steps.cache.outputs.cache-hit != 'true'
      shell: bash
      run: npm ci
    
    - name: Display versions
      shell: bash
      run: |
        echo "Node version: $(node --version)"
        echo "NPM version: $(npm --version)"
```

### Using a Composite Action

```yaml
name: Use Composite Action

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup application
        uses: ./.github/actions/setup-app
        with:
          node-version: '20'
      
      - name: Build
        run: npm run build
      
      - name: Test
        run: npm test
```

## Workflow Modules

### Module 1: Docker Build & Push

Create `.github/workflows/modules/docker-build.yml`:

```yaml
name: Docker Build Module

on:
  workflow_call:
    inputs:
      dockerfile:
        type: string
        default: 'Dockerfile'
      context:
        type: string
        default: '.'
      image-name:
        type: string
        required: true
      platforms:
        type: string
        default: 'linux/amd64'
    secrets:
      registry-username:
        required: true
      registry-password:
        required: true
    outputs:
      image-digest:
        value: ${{ jobs.build.outputs.digest }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      digest: ${{ steps.build.outputs.digest }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Registry
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.registry-username }}
          password: ${{ secrets.registry-password }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ inputs.image-name }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          context: ${{ inputs.context }}
          file: ${{ inputs.dockerfile }}
          platforms: ${{ inputs.platforms }}
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Module 2: Security Scanning

Create `.github/workflows/modules/security-scan.yml`:

```yaml
name: Security Scan Module

on:
  workflow_call:
    inputs:
      scan-type:
        type: string
        default: 'all'  # all, sast, dependency, container
      severity:
        type: string
        default: 'HIGH,CRITICAL'

jobs:
  dependency-scan:
    if: inputs.scan-type == 'all' || inputs.scan-type == 'dependency'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
  
  sast-scan:
    if: inputs.scan-type == 'all' || inputs.scan-type == 'sast'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: javascript
      
      - name: Autobuild
        uses: github/codeql-action/autobuild@v3
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
  
  container-scan:
    if: inputs.scan-type == 'all' || inputs.scan-type == 'container'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: ${{ inputs.severity }}
      
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

### Module 3: Kubernetes Deployment

Create `.github/workflows/modules/k8s-deploy.yml`:

```yaml
name: Kubernetes Deploy Module

on:
  workflow_call:
    inputs:
      environment:
        type: string
        required: true
      namespace:
        type: string
        required: true
      image-tag:
        type: string
        required: true
      manifests-path:
        type: string
        default: 'k8s'
    secrets:
      kubeconfig:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'
      
      - name: Configure kubeconfig
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.kubeconfig }}" | base64 -d > $HOME/.kube/config
      
      - name: Update image tag
        run: |
          sed -i "s|IMAGE_TAG|${{ inputs.image-tag }}|g" ${{ inputs.manifests-path }}/*.yaml
      
      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f ${{ inputs.manifests-path }}/ -n ${{ inputs.namespace }}
      
      - name: Verify deployment
        run: |
          kubectl rollout status deployment/myapp -n ${{ inputs.namespace }}
      
      - name: Get deployment info
        run: |
          kubectl get pods -n ${{ inputs.namespace }}
          kubectl get svc -n ${{ inputs.namespace }}
```

## Calling Multiple Modules

### Pipeline Flow Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Complete Pipeline with Modules                       │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Push to Main    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Security Scan    │
│                  │
│ • SAST           │
│ • Dependencies   │
│ • Container      │
└────────┬─────────┘
         │
         ▼
    ┌────────┐
    │ Pass?  │
    └───┬────┘
        │
    ┌───┴───┐
    │       │
   Yes     No
    │       │
    │       ▼
    │  ┌──────────────┐
    │  │ Fail Pipeline│
    │  │              │
    │  │ • Report     │
    │  │ • Notify     │
    │  └──────────────┘
    │
    ▼
┌──────────────────┐
│ Build Docker     │
│     Image        │
│                  │
│ • Multi-stage    │
│ • Optimize       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Push to Registry │
│                  │
│ • Tag: latest    │
│ • Tag: sha       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Deploy to        │
│    Staging       │
│                  │
│ • Update K8s     │
│ • Health Check   │
└────────┬─────────┘
         │
         ▼
    ┌────────┐
    │  OK?   │
    └───┬────┘
        │
    ┌───┴───┐
    │       │
   Yes     No
    │       │
    │       ▼
    │  ┌──────────────┐
    │  │   Rollback   │
    │  │              │
    │  │ • Revert     │
    │  │ • Alert      │
    │  └──────────────┘
    │
    ▼
┌──────────────────┐
│ Deploy to        │
│   Production     │
│                  │
│ • Blue-Green     │
│ • Canary         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│    Complete      │
│                  │
│ • Notify Team    │
│ • Update Docs    │
└──────────────────┘
```

Create `.github/workflows/complete-pipeline.yml`:

```yaml
name: Complete CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security-scan:
    uses: ./.github/workflows/modules/security-scan.yml
    with:
      scan-type: 'all'
      severity: 'HIGH,CRITICAL'
    secrets: inherit
  
  build:
    needs: security-scan
    uses: ./.github/workflows/modules/docker-build.yml
    with:
      image-name: 'myorg/myapp'
      platforms: 'linux/amd64,linux/arm64'
    secrets:
      registry-username: ${{ secrets.DOCKER_USERNAME }}
      registry-password: ${{ secrets.DOCKER_PASSWORD }}
  
  deploy-staging:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: build
    uses: ./.github/workflows/modules/k8s-deploy.yml
    with:
      environment: 'staging'
      namespace: 'staging'
      image-tag: ${{ needs.build.outputs.image-digest }}
    secrets:
      kubeconfig: ${{ secrets.KUBECONFIG_STAGING }}
  
  deploy-production:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: [build, deploy-staging]
    uses: ./.github/workflows/modules/k8s-deploy.yml
    with:
      environment: 'production'
      namespace: 'production'
      image-tag: ${{ needs.build.outputs.image-digest }}
    secrets:
      kubeconfig: ${{ secrets.KUBECONFIG_PRODUCTION }}
```

## Best Practices

### 1. Matrix Strategy for Multiple Versions

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

### 2. Conditional Execution

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - name: Deploy only on main
        run: echo "Deploying..."
```

### 3. Caching Dependencies

```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### 4. Artifacts Upload/Download

```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: build-output
          path: dist/
  
  deploy:
    needs: build
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: build-output
          path: dist/
```

### 5. Environment Protection Rules

```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://myapp.com
    steps:
      - run: echo "Deploying to production"
```

## Advanced Patterns

### Dynamic Matrix from JSON

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - id: set-matrix
        run: echo "matrix={\"include\":[{\"env\":\"dev\"},{\"env\":\"prod\"}]}" >> $GITHUB_OUTPUT
  
  deploy:
    needs: setup
    strategy:
      matrix: ${{ fromJson(needs.setup.outputs.matrix) }}
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying to ${{ matrix.env }}"
```

### Workflow Dispatch with Inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
      version:
        description: 'Version to deploy'
        required: true
        type: string

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "Deploying version ${{ inputs.version }} to ${{ inputs.environment }}"
```
