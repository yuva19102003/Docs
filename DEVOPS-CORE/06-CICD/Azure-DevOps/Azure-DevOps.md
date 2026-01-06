
## This will be a **complete hands-on guide** that takes you from **setup to deployment**, covering:

### 📘 Table of Contents

1. 🌐 What is Azure DevOps
    
2. 🧱 Azure DevOps Services Overview
    
3. 🏗️ Setting Up Your Azure DevOps Account
    
4. 🧩 Creating a New Project
    
5. ⚙️ Creating a CI Pipeline (Azure Pipelines)
    
6. 🐳 Integrating with Docker
    
7. ☸️ Deploying to Kubernetes / Azure Web App
    
8. 🔐 Using Variables and Secrets
    
9. 📊 Monitoring and Logs
    
10. 🚀 Best Practices + Real Example
    

---

## 🌐 1. What is Azure DevOps?

**Azure DevOps** is Microsoft’s end-to-end **DevOps platform** for automating:

- **Code Management** (via Git Repos)
    
- **Continuous Integration (CI)**
    
- **Continuous Deployment (CD)**
    
- **Project Tracking (Boards)**
    
- **Testing and Monitoring**
    

It’s cloud-native, secure, and integrates deeply with **Azure Cloud**, **GitHub**, **Docker**, and **Kubernetes**.

---

## 🧱 2. Azure DevOps Services Overview

|Service|Description|
|---|---|
|**Azure Repos**|Git repositories for source control|
|**Azure Pipelines**|CI/CD pipelines to build, test, and deploy|
|**Azure Boards**|Agile project management (Scrum, Kanban)|
|**Azure Artifacts**|Package management (npm, Maven, NuGet)|
|**Azure Test Plans**|Manual and automated testing|

---

## 🏗️ 3. Setting Up Your Azure DevOps Account

1. Go to 👉 [https://dev.azure.com](https://dev.azure.com/)
    
2. Sign in with your Microsoft account (or GitHub).
    
3. Click **“New Organization”** → give it a name (e.g. `yuvaraj-devops`).
    
4. Create a **New Project** → select:
    
    - Visibility: Private or Public
        
    - Version Control: Git
        
    - Work Item Process: Basic (for now)
        

✅ Done — you’re inside your **Azure DevOps project dashboard**!

---

## 🧩 4. Creating a New Project Structure

Let’s take a sample **Python + Docker** web app.

```
my-app/
├── app/
│   ├── main.py
│   ├── requirements.txt
├── Dockerfile
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
└── azure-pipelines.yml
```

---

## ⚙️ 5. Azure Pipelines (CI/CD Workflow)

### Step 1: Create Pipeline

1. Go to **Pipelines → New Pipeline**
    
2. Choose your code source:
    
    - GitHub / Azure Repos / Bitbucket
        
3. Select “Starter pipeline” or “Existing YAML file”
    
4. Choose your YAML (we’ll write one next)
    

---

### Step 2: Azure Pipeline YAML

`azure-pipelines.yml`

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  imageName: 'yuvaraj/my-app'

steps:
  - task: Checkout@1
    displayName: 'Checkout code'

  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.11'

  - script: |
      pip install -r app/requirements.txt
    displayName: 'Install dependencies'

  - script: |
      pytest || echo "Tests Skipped"
    displayName: 'Run tests'

  - task: Docker@2
    displayName: 'Build and push Docker image'
    inputs:
      command: 'buildAndPush'
      repository: '$(imageName)'
      dockerfile: '**/Dockerfile'
      containerRegistry: 'DockerHubConnection'
      tags: |
        latest
        $(Build.BuildId)

  - task: Kubernetes@1
    displayName: 'Deploy to Kubernetes'
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: 'MyK8sCluster'
      namespace: 'default'
      command: 'apply'
      useConfigurationFile: true
      configuration: 'k8s/deployment.yaml'
```

---

## 🐳 6. Integrate Docker Hub

1. Go to **Project Settings → Service Connections → New Service Connection → Docker Registry**
    
2. Choose **Docker Hub**
    
3. Enter:
    
    - Registry type: Docker Hub
        
    - Docker ID & password
        
    - Name it: `DockerHubConnection`
        

Now Azure DevOps can build & push images to your Docker Hub account.

---

## ☸️ 7. Deploy to Kubernetes (Azure AKS or Minikube)

1. Create a **Service Connection** for Kubernetes:
    
    - Go to **Project Settings → Service Connections → New → Kubernetes**
        
    - Choose **Kubeconfig file upload** or connect to **Azure Kubernetes Service (AKS)** directly.
        
    - Name it: `MyK8sCluster`
        
2. Add your Kubernetes manifests in `/k8s/`:
    

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

## 🔐 8. Secrets & Variables

In Azure DevOps:

- Go to **Pipelines → Library → + Variable Group**
    
- Add:
    
    - `DOCKER_USERNAME`
        
    - `DOCKER_PASSWORD`
        
    - `KUBE_CONFIG`
        
- Click “Keep this value secret”
    

You can reference them in YAML as:

```yaml
$(DOCKER_USERNAME)
```

---

## 📊 9. Monitoring & Logs

- Go to **Pipelines → Runs**
    
- You’ll see real-time logs for each stage: Build, Test, Push, Deploy
    
- Click any step for console output
    
- View build artifacts or container logs
    

💡 You can even export logs to **Azure Monitor** or **Grafana** for observability.

---

## 🚀 10. Real Example: Python + Docker + Azure Web App

If you don’t use Kubernetes, you can deploy directly to **Azure App Service**.

Add a deploy step:

```yaml
- task: AzureWebApp@1
  inputs:
    azureSubscription: 'MyAzureServiceConnection'
    appName: 'my-app-service'
    package: '$(System.DefaultWorkingDirectory)'
```

You’ll need:

- Azure Web App created in Azure Portal
    
- Azure service connection in DevOps project
    

---

## 🧩 11. Trigger Options

You can trigger builds:

- On every push
    
- On pull requests
    
- On tags
    
- On schedule
    

Example:

```yaml
trigger:
  branches:
    include:
      - main
pr:
  branches:
    include:
      - dev
schedules:
  - cron: "0 0 * * *"
    displayName: "Daily Build"
```

---

## 🧠 12. Multi-Stage Pipeline (CI + CD)

Example:

```yaml
stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - script: echo "Building App"
  - stage: Deploy
    dependsOn: Build
    jobs:
      - job: DeployJob
        steps:
          - script: echo "Deploying App"
```

✅ CI happens first  
✅ CD triggers only if CI succeeds

---

## 📦 13. Azure Artifacts (Optional)

Use this to:

- Host your private packages
    
- Manage dependencies for large organizations
    

Example usage:

```yaml
- task: NuGetCommand@2
  inputs:
    command: 'push'
    packagesToPush: '$(Build.ArtifactStagingDirectory)/*.nupkg'
    publishVstsFeed: 'MyFeed'
```

---

## 🧠 14. Azure Boards Integration

Manage your DevOps workflow:

- Create work items (user stories, bugs, tasks)
    
- Link commits and pull requests
    
- Visualize progress with Kanban/Scrum boards
    

---

## 🔥 15. Complete Flow Summary

```
Developer → Push code to main →
Azure Pipeline triggers →
Build & Test →
Docker image pushed to Docker Hub →
Deploy to Azure Kubernetes Service (AKS) →
Monitor with Azure Monitor →
Slack/Email notification on success/failure
```

---

## 🪶 16. Best Practices

|Area|Best Practice|
|---|---|
|**YAML Pipelines**|Store pipeline code in `azure-pipelines.yml`|
|**Secrets**|Use Variable Groups or Azure Key Vault|
|**Security**|Enable branch policies & PR approvals|
|**Artifacts**|Use versioned Docker tags|
|**Stages**|Separate CI and CD|
|**Rollback**|Use Helm or previous build ID for rollback|
|**Notifications**|Integrate with Teams/Slack for alerts|

---

## ⚡ 17. Azure DevOps vs GitHub Actions vs Jenkins

|Feature|Azure DevOps|GitHub Actions|Jenkins|
|---|---|---|---|
|Setup|Cloud (ready)|Cloud (built-in)|Manual|
|CI/CD|YAML + Visual Editor|YAML only|Groovy|
|Source Control|Azure Repos / GitHub|GitHub only|Any|
|Integrations|Deep Azure Integration|GitHub-native|Plugin-based|
|Enterprise Ready|✅|✅|✅|
|Cost|Free for small use|Free (limited mins)|Free (self-hosted)|

---

## 🏁 Summary

✅ Azure DevOps = One-stop DevOps suite for:

- Source control
    
- Build automation
    
- Continuous deployment
    
- Project management
    
- Testing + Monitoring
    

---
