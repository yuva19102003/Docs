
## 🧠 1. What is GitHub Actions?

GitHub Actions is a **CI/CD automation service** that lets you:

- Build, test, and deploy code **directly from your GitHub repository**
    
- Automate workflows using **YAML configuration files**
    
- Integrate with tools like **Docker, AWS, GCP, Kubernetes, Slack, etc.**
    

It’s **event-driven**, meaning it runs automatically when something happens — for example:

- Someone **pushes** code
    
- A **PR (pull request)** is opened
    
- A **schedule** runs (cron jobs)
    
- Or it’s **manually triggered**
    

---

## ⚙️ 2. Core Concepts

|Term|Meaning|
|---|---|
|**Workflow**|The entire automation process (defined in a `.yml` file)|
|**Job**|A group of steps that run on a runner|
|**Step**|A single task (e.g., build, test, deploy)|
|**Runner**|The environment where the job executes (GitHub-hosted or self-hosted)|
|**Actions**|Reusable tasks like “Checkout code”, “Login to Docker”, etc.|
|**Event Trigger**|Defines _when_ the workflow runs (push, pull_request, etc.)|

---

## 📂 3. Folder Structure

In your GitHub repository, create this folder:

```
.github/
└── workflows/
    └── ci-cd.yml
```

All GitHub Actions workflows live under `.github/workflows/`.

---

## 🏗️ 4. Example Project

We’ll build and deploy a **Python web app** using GitHub Actions + Docker + Kubernetes.

### Folder structure:

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

## 🧩 5. Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app/ /app
RUN pip install -r requirements.txt
CMD ["python", "main.py"]
```

---

## ⚙️ 6. Kubernetes Deployment File

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

## 🧱 7. The CI/CD Pipeline (`ci-cd.yml`)

Create a file: `.github/workflows/ci-cd.yml`

```yaml
name: CI-CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    env:
      IMAGE_NAME: yuvaraj/my-app

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.11

      - name: Install dependencies
        run: |
          pip install -r app/requirements.txt

      - name: Run tests
        run: |
          pytest || echo "Tests Skipped"

      - name: Build Docker image
        run: |
          docker build -t $IMAGE_NAME:${{ github.sha }} .

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Push Docker image
        run: |
          docker push $IMAGE_NAME:${{ github.sha }}

      - name: Deploy to Kubernetes (optional)
        run: |
          kubectl apply -f k8s/
```

---

## 🔐 8. Add Secrets to GitHub

Go to your repository →  
⚙️ **Settings → Secrets and variables → Actions → New repository secret**

Add:

- `DOCKER_USERNAME`
    
- `DOCKER_PASSWORD`
    
- (Optional) `KUBE_CONFIG_DATA` if deploying to Kubernetes
    

---

## 🧠 9. How It Works (Step-by-Step)

1. You push code → `main` branch
    
2. GitHub Action starts the workflow
    
3. It checks out the code
    
4. Installs dependencies & runs tests
    
5. Builds a Docker image
    
6. Pushes image to Docker Hub
    
7. Deploys automatically to Kubernetes (if configured)
    

💡 The `${{ github.sha }}` ensures a **unique image tag per commit**.

---

## 🧰 10. Example Output in GitHub

When the pipeline runs, you’ll see stages like:

```
✓ Checkout code
✓ Install dependencies
✓ Run tests
✓ Build Docker image
✓ Push Docker image
✓ Deploy to Kubernetes
```

All visible in the **Actions tab** of your GitHub repo.

---

## 🪶 11. Add Environment Conditions

You can separate **staging** and **production** deployments:

```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ dev ]

jobs:
  staging:
    if: github.ref == 'refs/heads/dev'
  production:
    if: github.ref == 'refs/heads/main'
```

---

## 🧩 12. Add Notifications (Optional)

To get Slack or Discord alerts:

```yaml
- name: Send notification to Slack
  uses: slackapi/slack-github-action@v1.23
  with:
    payload: '{"text": "🚀 Deployment successful for ${{ github.repository }}" }'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## ⚡ 13. GitHub Action Marketplace

Find reusable actions here:  
👉 [https://github.com/marketplace?type=actions](https://github.com/marketplace?type=actions)

Some popular ones:

- `actions/checkout` → Clone your repo
    
- `docker/login-action` → Login to Docker
    
- `actions/setup-node` → Setup Node.js
    
- `aws-actions/configure-aws-credentials` → Deploy to AWS
    
- `azure/login` → Deploy to Azure
    

---

## 📊 14. Monitoring and Logs

You can see:

- Live logs (build, push, deploy)
    
- Artifacts (generated files)
    
- Time taken per step
    
- Status badges (✅ failed ❌)
    

Add a status badge to your README:

```markdown
![CI/CD](https://github.com/yuvaraj/my-app/actions/workflows/ci-cd.yml/badge.svg)
```

---

## 🧠 15. Example: Deploy to AWS EC2 (Instead of Kubernetes)

```yaml
- name: SSH into EC2 and deploy
  uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ubuntu
    key: ${{ secrets.EC2_SSH_KEY }}
    script: |
      docker pull yuvaraj/my-app:${{ github.sha }}
      docker stop my-app || true
      docker rm my-app || true
      docker run -d -p 80:5000 yuvaraj/my-app:${{ github.sha }}
```

---

## 🧩 16. Schedule Pipelines (Cron Jobs)

You can run workflows periodically (like nightly builds):

```yaml
on:
  schedule:
    - cron: '0 0 * * *'   # every day at midnight
```

---

## 🧰 17. Reusable Workflows

Create a central workflow used by multiple repos:

```yaml
jobs:
  call-shared-workflow:
    uses: yuvaraj-org/.github/.github/workflows/build.yml@main
```

---

## 🧱 18. Best Practices

|Area|Recommendation|
|---|---|
|**Security**|Use GitHub Secrets for credentials|
|**Speed**|Use cache for dependencies|
|**Testing**|Run tests in parallel jobs|
|**Artifacts**|Upload logs or test reports|
|**Tagging**|Use commit hash or version for Docker tags|
|**Branch protection**|Allow Actions only on PRs and main|
|**GitOps**|Use ArgoCD or Flux to sync deployments|

---

## 💡 19. GitHub Actions vs Jenkins

|Feature|GitHub Actions|Jenkins|
|---|---|---|
|Setup|Zero setup (built into GitHub)|Manual installation|
|UI|Simple & integrated|Full dashboard|
|Cost|Free (limits apply)|Free self-hosted|
|Config|YAML-based|Groovy/DSL|
|Speed|Cloud-native runners|Self-managed agents|
|Security|GitHub Secrets|Jenkins credentials|

**In short:** GitHub Actions = _Modern CI/CD for cloud-native DevOps_ 🚀

---

## 🏁 20. Full Flow Summary

```
Developer pushes → GitHub Action triggers →
Build + Test → Docker build → Push to DockerHub →
ArgoCD/Kubernetes auto-deploys →
Prometheus/Grafana monitor → Slack alert on success/failure.
```

---
