
# 🚀 JENKINS FULL END-TO-END TUTORIAL

---

## 🧱 1. What is Jenkins?

**Jenkins** is an **open-source automation server** used to:

- Build and test your code continuously (CI)
    
- Deploy applications automatically (CD)
    
- Orchestrate DevOps pipelines (with Docker, Kubernetes, etc.)
    

It supports **plugins** for everything — GitHub, Docker, SonarQube, AWS, ArgoCD, etc.

---

## 🧰 2. System Requirements

|Requirement|Recommended|
|---|---|
|OS|Ubuntu 20.04 / 22.04 (or Windows)|
|RAM|4 GB minimum|
|Java|Java 11+ (JDK 17 preferred)|
|Browser|Chrome / Firefox|

---

## ⚙️ 3. Jenkins Installation (Ubuntu)

### Step 1: Update packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Java

```bash
sudo apt install openjdk-17-jdk -y
```

### Step 3: Add Jenkins repository and key

```bash
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
```

### Step 4: Install Jenkins

```bash
sudo apt update
sudo apt install jenkins -y
```

### Step 5: Start Jenkins

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### Step 6: Access Jenkins

Go to →  
👉 `http://localhost:8080`

Get the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## 🧩 4. Setup Wizard

1. Paste the admin password.
    
2. Choose **“Install suggested plugins”**.
    
3. Create your admin user.
    
4. You’ll land on the **Jenkins Dashboard**.
    

---

## 🧱 5. Jenkins Architecture Overview

```
Developer → Git Push → Jenkins Pipeline → Build → Test → Deploy
```

### Key Components:

|Component|Description|
|---|---|
|**Jenkins Master**|Orchestrates builds and manages agents|
|**Agent/Node**|Executes the actual build steps|
|**Pipeline**|Script that defines your CI/CD flow|
|**Job**|Unit of work (can be Freestyle or Pipeline)|
|**Workspace**|Directory on agent where build happens|

---

## 🧩 6. Jenkins Plugins (Essential Ones)

Go to: **Manage Jenkins → Plugins → Available**  
Search & Install:

✅ Git  
✅ Docker  
✅ Pipeline  
✅ Blue Ocean (modern UI)  
✅ Kubernetes  
✅ Snyk Security (optional)

---

## 🏗️ 7. Example Project: CI/CD Pipeline for a Python Web App

Let’s say your repo structure is:

```
my-app/
├── app.py
├── requirements.txt
├── Dockerfile
└── Jenkinsfile
```

---

### Step 1: `Dockerfile`

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

---

### Step 2: Jenkins Pipeline (Jenkinsfile)

Create a file named `Jenkinsfile` in your repo:

```groovy
pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = credentials('dockerhub-credentials')
        IMAGE_NAME = "yuvaraj/my-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/yuvaraj/my-app.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pytest || echo "Tests Skipped"'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $IMAGE_NAME:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo $DOCKER_HUB_USER_PSW | docker login -u $DOCKER_HUB_USER_USR --password-stdin"
                    sh "docker push $IMAGE_NAME:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished: ${currentBuild.currentResult}"
        }
    }
}
```

---

### Step 3: Create Jenkins Credentials

Go to:

> **Manage Jenkins → Credentials → Global → Add Credentials**

Add:

- **Docker Hub Username/Password**
    
- **Kubernetes Kubeconfig** (if you’re deploying to a cluster)
    

---

### Step 4: Create Pipeline Job

1. Go to Jenkins Dashboard
    
2. Click **“New Item” → Pipeline**
    
3. Name: `my-app-pipeline`
    
4. Under Pipeline → Choose **Pipeline script from SCM**
    
5. Select **Git**, paste repo URL, branch = `main`
    
6. Save & Run ✅
    

---

### Step 5: Watch Pipeline in Action

You’ll see stages like:

```
[1] Checkout Code
[2] Install Dependencies
[3] Run Tests
[4] Build Docker Image
[5] Push to Docker Hub
[6] Deploy to Kubernetes
```

If all succeed → Jenkins deploys automatically 🎉

---

## 🧠 8. Jenkins Pipeline Types

|Type|Description|
|---|---|
|**Declarative Pipeline**|Easier syntax (recommended for beginners)|
|**Scripted Pipeline**|Fully Groovy-based, more flexible|

Example:

```groovy
pipeline {
  agent any
  stages {
    stage('Build') { steps { echo 'Building...' } }
  }
}
```

---

## 🔐 9. Integrations

|Tool|Integration|
|---|---|
|**GitHub Webhook**|Auto-trigger Jenkins when new code is pushed|
|**Slack**|Send build notifications|
|**SonarQube**|Code quality analysis|
|**Trivy / Snyk**|Container security scanning|
|**AWS / GCP**|Deploy using Jenkins pipelines|

---

## 📊 10. Jenkins + GitHub Webhook Setup

### 1. Go to your GitHub repo → Settings → Webhooks → Add webhook

- Payload URL: `http://<your-server-ip>:8080/github-webhook/`
    
- Content type: `application/json`
    
- Trigger: “Just the push event”
    

Now every push triggers Jenkins automatically 🚀

---

## 🧩 11. Jenkins + Docker Integration

Install Docker plugin and ensure Jenkins user can run Docker:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Verify inside Jenkins:

```bash
docker ps
```

---

## 🧠 12. Jenkins + Kubernetes (Optional)

If you have Kubernetes (like Minikube or AWS EKS):

- Create `k8s/deployment.yaml`
    
- Use Jenkins `kubectl apply -f` step
    
- You can even **run Jenkins inside Kubernetes** with a Helm chart.
    

---

## 🪶 13. Monitoring Jenkins

- URL: `http://localhost:8080/monitoring`
    
- Integrate Prometheus plugin
    
- View build metrics and job status in Grafana dashboards.
    

---

## 🧩 14. Best Practices

✅ Store pipeline code in `Jenkinsfile` (GitOps-style).  
✅ Use credentials from Jenkins Secret Store.  
✅ Keep stages modular: build, test, deploy, notify.  
✅ Use Docker agents for isolated builds.  
✅ Enable security: disable anonymous access.  
✅ Use backup plugin or external volume for `/var/lib/jenkins`.

---

## ⚡ 15. Sample Real-World Flow

```
Developer → Git Push →
GitHub Webhook triggers Jenkins →
Build + Test →
Docker Image →
Push to Docker Hub →
Deploy to Kubernetes →
Prometheus + Grafana monitor app →
Slack notification sent.
```

---
