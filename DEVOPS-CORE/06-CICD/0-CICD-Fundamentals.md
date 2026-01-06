## 🧠 1. What is CI/CD?

### CI/CD Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CI/CD Pipeline Architecture                      │
└─────────────────────────────────────────────────────────────────────────┘

Developer                 CI (Continuous Integration)
   │                              │
   │ git push                     │
   ▼                              ▼
┌────────┐                 ┌──────────────┐
│ GitHub │────────────────▶│   Trigger    │
│ GitLab │                 │   Pipeline   │
└────────┘                 └──────┬───────┘
                                  │
                                  ▼
                           ┌──────────────┐
                           │  Build Code  │
                           │  • Maven     │
                           │  • npm       │
                           │  • Docker    │
                           └──────┬───────┘
                                  │
                                  ▼
                           ┌──────────────┐
                           │  Run Tests   │
                           │  • Unit      │
                           │  • Integration│
                           │  • Security  │
                           └──────┬───────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                 PASS ✓                      FAIL ✗
                    │                           │
                    ▼                           ▼
            CD (Continuous Deployment)    Notify Team
                    │                     (Email/Slack)
                    ▼
            ┌──────────────┐
            │ Build Image  │
            │ • Docker     │
            │ • Container  │
            └──────┬───────┘
                   │
                   ▼
            ┌──────────────┐
            │ Push to      │
            │ Registry     │
            │ • Docker Hub │
            │ • ECR        │
            └──────┬───────┘
                   │
                   ▼
            ┌──────────────┐
            │ Deploy to    │
            │ Environment  │
            │ • K8s        │
            │ • EC2        │
            │ • ECS        │
            └──────┬───────┘
                   │
                   ▼
            ┌──────────────┐
            │   Monitor    │
            │ • Prometheus │
            │ • Grafana    │
            │ • CloudWatch │
            └──────────────┘
```

### 💡 Continuous Integration (CI)

> The process of automatically building, testing, and merging code whenever a developer pushes new commits to a shared repository.

✅ **Purpose**:

- Detect errors early
    
- Prevent integration issues
    
- Maintain a deployable build
    

Example:  
When a developer pushes to GitHub → pipeline runs tests → if all pass → merge to `main`.

---

### ⚙️ Continuous Deployment (CD)

> Automatically deploy your application after CI is successful.

✅ **Purpose**:

- Make delivery faster and reliable
    
- Reduce manual steps in deployment
    

Example:  
After CI success → code is built → Docker image created → pushed to Docker Hub → deployed automatically to Kubernetes or AWS EC2.

---

🧩 **CI/CD Together** means:  
Every code change automatically goes through →  
**Build → Test → Deploy → Monitor**

---

## 🔧 2. CI/CD Pipeline Stages

Let’s break it into phases:

|Stage|Description|Example Tool|
|---|---|---|
|**Source**|Developer pushes code|GitHub, GitLab|
|**Build**|Code compilation / image build|Maven, npm, Docker|
|**Test**|Unit, integration, security tests|JUnit, PyTest, Snyk|
|**Deploy**|Deploy to environment|ArgoCD, Jenkins, GitHub Actions|
|**Monitor**|Track metrics, errors|Prometheus, Grafana|

---

### 🧱 Pipeline Flow Example

```
Developer → Push code → CI (build/test) → CD (deploy) → Monitor (Grafana)
```

---

## ⚙️ 3. Tools Used in CI/CD

|Category|Tools|Description|
|---|---|---|
|**Version Control**|GitHub, GitLab|Store code|
|**CI Tools**|Jenkins, GitHub Actions, GitLab CI, CircleCI|Automate testing/build|
|**CD Tools**|ArgoCD, Spinnaker, FluxCD|Automate deployment|
|**Containerization**|Docker|Package applications|
|**Orchestration**|Kubernetes|Manage container deployment|
|**Monitoring**|Prometheus, Grafana|Observe performance|
|**Security**|Snyk, Trivy|Vulnerability scanning|

---

## 🏗️ 4. Real Example: Complete CI/CD Pipeline

Let’s build a **hands-on flow** for a microservice application using:

- **GitHub Actions** for CI
    
- **Docker** for packaging
    
- **Kubernetes + ArgoCD** for CD
    
- **Prometheus + Grafana** for monitoring
    

---

### 🪜 Step 1: Folder Structure

```
my-app/
├── app/
│   ├── main.py
│   ├── requirements.txt
├── Dockerfile
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
└── .github/
    └── workflows/
        └── ci-cd.yml
```

---

### 🧩 Step 2: Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app/ /app
RUN pip install -r requirements.txt
CMD ["python", "main.py"]
```

---

### 🧩 Step 3: Kubernetes Deployment

`k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: yuvaraj/my-app:latest
        ports:
        - containerPort: 5000
```

---

### 🧩 Step 4: GitHub Actions CI/CD Workflow

`.github/workflows/ci-cd.yml`

```yaml
name: CI-CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.11

      - name: Install Dependencies
        run: |
          pip install -r app/requirements.txt

      - name: Run Tests
        run: |
          pytest

      - name: Build Docker Image
        run: |
          docker build -t yuvaraj/my-app:${{ github.sha }} .

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Push Image
        run: |
          docker push yuvaraj/my-app:${{ github.sha }}

      - name: Deploy to Kubernetes via ArgoCD
        run: |
          kubectl apply -f k8s/
```

---

### 🧩 Step 5: Continuous Deployment with ArgoCD

**ArgoCD** watches your GitHub repo → if it detects changes in `k8s/deployment.yaml`,  
it automatically syncs and deploys them to Kubernetes.

#### ArgoCD YAML (App Definition)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  project: default
  source:
    repoURL: 'https://github.com/yuvaraj/my-app'
    path: k8s
    targetRevision: main
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 📊 5. Best Practices for CI/CD

|Area|Best Practice|
|---|---|
|**Branching**|Use Git Flow (`main`, `develop`, `feature/*`)|
|**Secrets**|Use GitHub Secrets, AWS Secrets Manager|
|**Testing**|Automate unit + integration + security|
|**Monitoring**|Always include metrics and alerts|
|**Rollback**|Use ArgoCD or Helm for versioned deployments|
|**Security**|Scan Docker images with Trivy or Snyk|
|**Performance**|Cache dependencies (pip, npm, etc.)|

---

## 🚀 6. Advanced CI/CD Topics

|Feature|Description|
|---|---|
|**Blue-Green Deployment**|Run two environments (Blue = live, Green = new version). Switch after testing.|
|**Canary Deployment**|Gradually roll out new versions to small user groups.|
|**Infrastructure as Code (IaC)**|Use Terraform or Ansible to automate environment setup.|
|**GitOps**|Manage deployments declaratively via Git (ArgoCD, FluxCD).|
|**Security Integration**|Add tools like `Snyk` or `Trivy` to scan during CI.|

---

## 💥 Example Workflow Summary

```
Developer commits code →
GitHub Actions builds and tests →
Docker image pushed →
ArgoCD deploys to K8s automatically →
Prometheus + Grafana monitor health →
Alerts sent on failures.
```

---
