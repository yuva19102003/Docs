# GitHub Actions - Workflow Examples

Complete collection of production-ready GitHub Actions workflows for various use cases.

## CI/CD Pipeline Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Complete CI/CD Pipeline Stages                       │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│ Git Push/PR  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│                        CI Stage                               │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Lint & Format│─>│  Unit Tests  │─>│ Integration  │      │
│  │              │  │              │  │    Tests     │      │
│  └──────────────┘  └──────────────┘  └──────┬───────┘      │
│                                              │               │
│  ┌──────────────┐  ┌──────────────┐        │               │
│  │Security Scan │<─│Build Artifacts│<───────┘               │
│  │              │  │              │                         │
│  │ • SAST       │  │ • Compile    │                         │
│  │ • Dependency │  │ • Package    │                         │
│  │ • Container  │  │              │                         │
│  └──────┬───────┘  └──────┬───────┘                         │
└─────────┼──────────────────┼─────────────────────────────────┘
          │                  │
          └──────────┬───────┘
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                      Build Stage                              │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Docker Build  │─>│Multi-Platform│─>│Push to       │      │
│  │              │  │    Build     │  │  Registry    │      │
│  │ • Dockerfile │  │              │  │              │      │
│  │ • Context    │  │ • amd64      │  │ • Docker Hub │      │
│  │ • Args       │  │ • arm64      │  │ • ECR/GCR    │      │
│  └──────────────┘  └──────────────┘  └──────┬───────┘      │
└─────────────────────────────────────────────┼───────────────┘
                                              │
                     ┌────────────────────────┼────────────────────────┐
                     ▼                        ▼                        ▼
┌──────────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│    Deploy to Dev         │  │  Deploy to Staging   │  │ Deploy to Production │
│                          │  │                      │  │                      │
│  • Auto Deploy           │  │  • Manual Approval   │  │  • Manual Approval   │
│  • Smoke Tests           │  │  • Integration Tests │  │  • Blue-Green        │
│  • Quick Feedback        │  │  • Load Tests        │  │  • Canary Release    │
└────────┬─────────────────┘  └────────┬─────────────┘  └────────┬─────────────┘
         │                             │                         │
         └─────────────────────────────┴─────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────┐
│                      Post-Deploy                              │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Health Checks │─>│ Smoke Tests  │─>│  Monitoring  │      │
│  │              │  │              │  │              │      │
│  │ • Endpoints  │  │ • Critical   │  │ • Metrics    │      │
│  │ • Services   │  │   Paths      │  │ • Logs       │      │
│  │ • Database   │  │ • API Tests  │  │ • Alerts     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Deployment Strategies

```
┌────────────────────────────────────────────────────────────────┐
│                    Deployment Strategies                        │
└────────────────────────────────────────────────────────────────┘

1. Blue-Green Deployment
   ═══════════════════════

   ┌─────────────┐              ┌─────────────┐
   │    Blue     │              │    Green    │
   │ Environment │              │ Environment │
   │             │              │             │
   │ (Current)   │              │   (New)     │
   └──────┬──────┘              └──────┬──────┘
          │                            │
          │      Switch Traffic        │
          └────────────┬───────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  Load Balancer │
              │                │
              │  100% → Green  │
              └────────────────┘


2. Canary Deployment
   ══════════════════

   ┌─────────────┐              ┌─────────────┐
   │   Stable    │              │   Canary    │
   │  Version    │              │   Version   │
   │             │              │             │
   │   (90%)     │              │    (10%)    │
   └──────┬──────┘              └──────┬──────┘
          │                            │
          │      Monitor Metrics       │
          └────────────┬───────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  If Successful │
              │                │
              │  50% → 100%    │
              └────────────────┘


3. Rolling Deployment
   ═══════════════════

   Step 1:  [Old] [Old] [Old] [Old]
            
   Step 2:  [New] [Old] [Old] [Old]
            
   Step 3:  [New] [New] [Old] [Old]
            
   Step 4:  [New] [New] [New] [Old]
            
   Step 5:  [New] [New] [New] [New]
```

## Table of Contents
- [Node.js Applications](#nodejs-applications)
- [Python Applications](#python-applications)
- [Go Applications](#go-applications)
- [Docker Workflows](#docker-workflows)
- [Cloud Deployments](#cloud-deployments)
- [Database Workflows](#database-workflows)
- [Monitoring & Notifications](#monitoring--notifications)

## Node.js Applications

### Basic Node.js CI/CD

```yaml
name: Node.js CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test
      
      - name: Generate coverage
        run: npm run coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          name: codecov-umbrella
  
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/
```

### Next.js Deployment to Vercel

```yaml
name: Deploy Next.js to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Vercel CLI
        run: npm install --global vercel@latest
      
      - name: Pull Vercel Environment
        run: vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Build Project
        run: vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Deploy to Vercel
        run: vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
```

### React App with S3 Deployment

```yaml
name: React App to S3

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
        env:
          REACT_APP_API_URL: ${{ secrets.API_URL }}
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to S3
        run: |
          aws s3 sync build/ s3://${{ secrets.S3_BUCKET }} --delete
      
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

## Python Applications

### Python Django CI/CD

```yaml
name: Django CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run migrations
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379/0
        run: |
          python manage.py migrate
      
      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379/0
        run: |
          pytest --cov=. --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
  
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.14
        with:
          heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: ${{ secrets.HEROKU_APP_NAME }}
          heroku_email: ${{ secrets.HEROKU_EMAIL }}
```

### FastAPI with Docker

```yaml
name: FastAPI Docker Build

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: pytest
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/fastapi-app:latest
            ${{ secrets.DOCKER_USERNAME }}/fastapi-app:${{ github.sha }}
```

## Go Applications

### Go Build and Test

```yaml
name: Go CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        go-version: ['1.20', '1.21', '1.22']
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
          cache: true
      
      - name: Install dependencies
        run: go mod download
      
      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
      
      - name: Run tests
        run: go test -v -race -coverprofile=coverage.out ./...
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.out
  
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      
      - name: Build for multiple platforms
        run: |
          GOOS=linux GOARCH=amd64 go build -o bin/app-linux-amd64
          GOOS=darwin GOARCH=amd64 go build -o bin/app-darwin-amd64
          GOOS=windows GOARCH=amd64 go build -o bin/app-windows-amd64.exe
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: binaries
          path: bin/
```

### Go with Docker Multi-Stage Build

```yaml
name: Go Docker Multi-Stage

on:
  push:
    branches: [main]
    tags:
      - 'v*'

jobs:
  docker:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/go-app
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Docker Workflows

### Multi-Platform Docker Build

```yaml
name: Multi-Platform Docker

on:
  push:
    branches: [main]
    tags:
      - 'v*'

jobs:
  docker:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: |
            ${{ secrets.DOCKER_USERNAME }}/myapp
            ghcr.io/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64,linux/arm/v7
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Docker Compose Testing

```yaml
name: Docker Compose Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build services
        run: docker-compose build
      
      - name: Start services
        run: docker-compose up -d
      
      - name: Wait for services
        run: |
          timeout 60 bash -c 'until docker-compose ps | grep healthy; do sleep 2; done'
      
      - name: Run tests
        run: docker-compose exec -T app npm test
      
      - name: Show logs
        if: failure()
        run: docker-compose logs
      
      - name: Stop services
        if: always()
        run: docker-compose down -v
```

## Cloud Deployments

### Cloud Deployment Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Multi-Cloud Deployment Architecture                  │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│ GitHub Actions   │
│                  │
│ • Workflow       │
│ • Build & Test   │
│ • Build Container│
└────────┬─────────┘
         │
         ├──────────────────┬──────────────────┬──────────────────┐
         ▼                  ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│      AWS        │ │      GCP        │ │     Azure       │ │   On-Premises   │
│                 │ │                 │ │                 │ │                 │
│  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │
│  │    ECR    │  │ │  │    GCR    │  │ │  │    ACR    │  │ │  │Docker Hub │  │
│  └─────┬─────┘  │ │  └─────┬─────┘  │ │  └─────┬─────┘  │ │  └─────┬─────┘  │
│        │        │ │        │        │ │        │        │ │        │        │
│        ▼        │ │        ▼        │ │        ▼        │ │        ▼        │
│  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │
│  │ECS/Fargate│  │ │  │Cloud Run  │  │ │  │Container  │  │ │  │Kubernetes │  │
│  │           │  │ │  │           │  │ │  │   Apps    │  │ │  │           │  │
│  └─────┬─────┘  │ │  └─────┬─────┘  │ │  └─────┬─────┘  │ │  └─────┬─────┘  │
│        │        │ │        │        │ │        │        │ │        │        │
│        ▼        │ │        ▼        │ │        ▼        │ │        ▼        │
│  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │
│  │    ALB    │  │ │  │Cloud Load │  │ │  │   App     │  │ │  │  Ingress  │  │
│  │           │  │ │  │ Balancing │  │ │  │  Gateway  │  │ │  │           │  │
│  └───────────┘  │ │  └───────────┘  │ │  └───────────┘  │ │  └───────────┘  │
└─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘
         │                  │                  │                  │
         └──────────────────┴──────────────────┴──────────────────┘
                                    │
                                    ▼
                          ┌──────────────────┐
                          │   Monitoring     │
                          │                  │
                          │  • CloudWatch    │
                          │  • Cloud Monitor │
                          │  • App Insights  │
                          │  • Prometheus    │
                          └──────────────────┘
```

### AWS ECS Deployment

```yaml
name: Deploy to AWS ECS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
      
      - name: Build and push image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: myapp
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      
      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: myapp
          image: ${{ steps.login-ecr.outputs.registry }}/myapp:${{ github.sha }}
      
      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: myapp-service
          cluster: myapp-cluster
          wait-for-service-stability: true
```

### Google Cloud Run Deployment

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
      
      - name: Configure Docker
        run: gcloud auth configure-docker
      
      - name: Build and push
        env:
          PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
        run: |
          docker build -t gcr.io/$PROJECT_ID/myapp:${{ github.sha }} .
          docker push gcr.io/$PROJECT_ID/myapp:${{ github.sha }}
      
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy myapp \
            --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/myapp:${{ github.sha }} \
            --platform managed \
            --region us-central1 \
            --allow-unauthenticated
```

### Azure Container Apps

```yaml
name: Deploy to Azure Container Apps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and push image
        uses: azure/docker-login@v1
        with:
          login-server: ${{ secrets.REGISTRY_LOGIN_SERVER }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
      
      - run: |
          docker build -t ${{ secrets.REGISTRY_LOGIN_SERVER }}/myapp:${{ github.sha }} .
          docker push ${{ secrets.REGISTRY_LOGIN_SERVER }}/myapp:${{ github.sha }}
      
      - name: Deploy to Container Apps
        uses: azure/container-apps-deploy-action@v1
        with:
          containerAppName: myapp
          resourceGroup: myResourceGroup
          imageToDeploy: ${{ secrets.REGISTRY_LOGIN_SERVER }}/myapp:${{ github.sha }}
```

### Kubernetes Deployment

```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'
      
      - name: Configure kubectl
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > $HOME/.kube/config
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }} .
          docker push ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
      
      - name: Update deployment
        run: |
          kubectl set image deployment/myapp \
            myapp=${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }} \
            -n production
      
      - name: Verify deployment
        run: |
          kubectl rollout status deployment/myapp -n production
          kubectl get pods -n production
```

## Database Workflows

### Database Migration

```yaml
name: Database Migration

on:
  push:
    branches: [main]
    paths:
      - 'migrations/**'

jobs:
  migrate:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run migrations
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          npm install -g db-migrate
          db-migrate up
```

### Backup Database

```yaml
name: Database Backup

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    
    steps:
      - name: Backup PostgreSQL
        run: |
          pg_dump ${{ secrets.DATABASE_URL }} > backup-$(date +%Y%m%d).sql
      
      - name: Upload to S3
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - run: |
          aws s3 cp backup-$(date +%Y%m%d).sql s3://${{ secrets.BACKUP_BUCKET }}/
```

## Monitoring & Notifications

### Slack Notifications

```yaml
name: Slack Notifications

on:
  push:
    branches: [main]
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types:
      - completed

jobs:
  notify:
    runs-on: ubuntu-latest
    
    steps:
      - name: Notify on success
        if: ${{ github.event.workflow_run.conclusion == 'success' }}
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "✅ Deployment successful for ${{ github.repository }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment Status:* Success ✅\n*Repository:* ${{ github.repository }}\n*Branch:* ${{ github.ref_name }}\n*Commit:* ${{ github.sha }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
      
      - name: Notify on failure
        if: ${{ github.event.workflow_run.conclusion == 'failure' }}
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "❌ Deployment failed for ${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Discord Notifications

```yaml
name: Discord Notification

on: [push, pull_request]

jobs:
  notify:
    runs-on: ubuntu-latest
    
    steps:
      - name: Send Discord notification
        uses: sarisia/actions-status-discord@v1
        if: always()
        with:
          webhook: ${{ secrets.DISCORD_WEBHOOK }}
          status: ${{ job.status }}
          title: "Deployment Status"
          description: "Build and deployment completed"
          color: 0x0000ff
          username: GitHub Actions
```

### Performance Monitoring

```yaml
name: Performance Monitoring

on:
  schedule:
    - cron: '*/30 * * * *'  # Every 30 minutes

jobs:
  monitor:
    runs-on: ubuntu-latest
    
    steps:
      - name: Check website performance
        run: |
          response_time=$(curl -o /dev/null -s -w '%{time_total}' https://myapp.com)
          echo "Response time: $response_time seconds"
          
          if (( $(echo "$response_time > 2.0" | bc -l) )); then
            echo "::error::Website is slow! Response time: $response_time"
            exit 1
          fi
      
      - name: Alert on failure
        if: failure()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: '{"text": "⚠️ Website performance degraded!"}'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```
