# Jenkins Installation Guide

## Installation Methods Overview

```
┌──────────────────────────────────────────────────────────────┐
│              JENKINS INSTALLATION OPTIONS                     │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Native    │  │   Docker    │  │ Kubernetes  │         │
│  │   Package   │  │  Container  │  │    Helm     │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                  │
│         ▼                ▼                ▼                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ • Ubuntu    │  │ • Quick     │  │ • Scalable  │         │
│  │ • RHEL      │  │ • Portable  │  │ • HA Setup  │         │
│  │ • Windows   │  │ • Isolated  │  │ • Cloud     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

## Prerequisites

### System Requirements

- **Java**: JDK 11 or JDK 17 (LTS versions)
- **RAM**: Minimum 4 GB, Recommended 8 GB+
- **Disk**: Minimum 50 GB, Recommended 100 GB+
- **CPU**: Minimum 2 cores, Recommended 4+ cores

### Network Requirements

- Port 8080 (default web UI)
- Port 50000 (default agent communication)
- Outbound internet access for plugins

## Installation on Ubuntu/Debian

### Method 1: Official Package Repository (Recommended)

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Java (JDK 17)
sudo apt install openjdk-17-jdk -y

# Verify Java installation
java -version

# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index
sudo apt update

# Install Jenkins
sudo apt install jenkins -y

# Start Jenkins service
sudo systemctl start jenkins

# Enable Jenkins to start on boot
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins
```

### Method 2: WAR File

```bash
# Download Jenkins WAR file
wget https://get.jenkins.io/war-stable/latest/jenkins.war

# Run Jenkins
java -jar jenkins.war --httpPort=8080
```

## Installation on RHEL/CentOS/Fedora

```bash
# Install Java
sudo dnf install java-17-openjdk-devel -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo dnf install jenkins -y

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Configure firewall
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

## Installation on Windows

### Using MSI Installer

1. Download Java JDK 17 from Oracle or Adoptium
2. Install Java and set JAVA_HOME environment variable
3. Download Jenkins MSI installer from jenkins.io
4. Run the installer and follow the wizard
5. Jenkins will be installed as a Windows service
6. Access Jenkins at http://localhost:8080

### Using Chocolatey

```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Jenkins
choco install jenkins -y

# Start Jenkins service
Start-Service jenkins
```

## Installation on macOS

### Using Homebrew

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Java
brew install openjdk@17

# Add Java to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Jenkins LTS
brew install jenkins-lts

# Start Jenkins service
brew services start jenkins-lts

# Access Jenkins
open http://localhost:8080
```

## Docker Installation

### Quick Start (Single Container)

```bash
# Pull Jenkins image
docker pull jenkins/jenkins:lts

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Production Setup with Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - JAVA_OPTS=-Xmx2048m -Xms1024m
    restart: unless-stopped

volumes:
  jenkins_home:
    driver: local
```

Start Jenkins:

```bash
docker-compose up -d
```

### Custom Dockerfile with Pre-installed Plugins

Create `Dockerfile`:

```dockerfile
FROM jenkins/jenkins:lts

# Switch to root to install packages
USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Switch back to jenkins user
USER jenkins

# Install plugins
RUN jenkins-plugin-cli --plugins \
    git \
    docker-workflow \
    kubernetes \
    pipeline-stage-view \
    blueocean \
    credentials-binding \
    workflow-aggregator
```

Build and run:

```bash
docker build -t jenkins-custom .
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins-custom
```

## Kubernetes Installation

### Using Helm Chart

```bash
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Create namespace
kubectl create namespace jenkins

# Install Jenkins
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer \
  --set controller.resources.requests.cpu=2 \
  --set controller.resources.requests.memory=4Gi \
  --set controller.resources.limits.cpu=4 \
  --set controller.resources.limits.memory=8Gi \
  --set persistence.size=50Gi

# Get admin password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password

# Get Jenkins URL
kubectl get svc --namespace jenkins jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}"
```

### Custom Kubernetes Manifests

Create `jenkins-deployment.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccountName: jenkins
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        - containerPort: 50000
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        resources:
          requests:
            memory: "4Gi"
            cpu: "2"
          limits:
            memory: "8Gi"
            cpu: "4"
        env:
        - name: JAVA_OPTS
          value: "-Xmx4096m -Xms2048m"
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: agent
    port: 50000
    targetPort: 50000
  selector:
    app: jenkins
```

Apply manifests:

```bash
kubectl apply -f jenkins-deployment.yaml
```

## Initial Setup Wizard

### Step 1: Access Jenkins

Navigate to `http://localhost:8080` (or your server IP)

### Step 2: Unlock Jenkins

Get the initial admin password:

**Linux/macOS:**
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Docker:**
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Kubernetes:**
```bash
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 3: Install Plugins

Choose one of:
- **Install suggested plugins** (Recommended for beginners)
- **Select plugins to install** (For advanced users)

Suggested plugins include:
- Git
- Pipeline
- Credentials Binding
- SSH Slaves
- Email Extension
- Build Timeout

### Step 4: Create Admin User

Fill in:
- Username
- Password
- Full name
- Email address

### Step 5: Configure Jenkins URL

Set the Jenkins URL (important for webhooks and notifications)

Example: `http://jenkins.example.com:8080`

### Step 6: Start Using Jenkins

Click "Start using Jenkins" to access the dashboard

## Post-Installation Configuration

### Configure Java

Go to: **Manage Jenkins → Global Tool Configuration → JDK**

Add JDK installation:
- Name: `JDK-17`
- JAVA_HOME: `/usr/lib/jvm/java-17-openjdk-amd64`

### Configure Git

Go to: **Manage Jenkins → Global Tool Configuration → Git**

Add Git installation:
- Name: `Default`
- Path to Git executable: `git` (or full path)

### Configure Maven (Optional)

Go to: **Manage Jenkins → Global Tool Configuration → Maven**

Add Maven installation:
- Name: `Maven-3.9`
- Install automatically from Apache

### Configure Docker (If using Docker builds)

Ensure Jenkins user can access Docker:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Configure Email Notifications

Go to: **Manage Jenkins → Configure System → E-mail Notification**

Configure SMTP server:
- SMTP server: `smtp.gmail.com`
- Use SMTP Authentication: Yes
- Username: your-email@gmail.com
- Password: app-specific password
- Use SSL: Yes
- SMTP Port: 465

## Security Hardening

### Enable Security Realm

Go to: **Manage Jenkins → Configure Global Security**

- Enable security: ✅
- Security Realm: Jenkins' own user database
- Authorization: Matrix-based security or Project-based Matrix Authorization

### Configure CSRF Protection

- Prevent Cross Site Request Forgery exploits: ✅
- Default Crumb Issuer: ✅

### Disable CLI over Remoting

- Enable CLI over Remoting: ❌

### Configure Agent Protocols

- Enable only JNLP4 protocol

### Set Up Backup

```bash
# Backup Jenkins home directory
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz /var/lib/jenkins/

# Backup to remote location
rsync -avz /var/lib/jenkins/ user@backup-server:/backups/jenkins/
```

## Troubleshooting

### Jenkins Won't Start

Check logs:
```bash
# Ubuntu/Debian
sudo journalctl -u jenkins -f

# Docker
docker logs jenkins

# Kubernetes
kubectl logs -n jenkins deployment/jenkins
```

### Port Already in Use

Change Jenkins port:
```bash
# Edit Jenkins config
sudo nano /etc/default/jenkins

# Change HTTP_PORT
HTTP_PORT=8081

# Restart Jenkins
sudo systemctl restart jenkins
```

### Out of Memory

Increase Java heap size:
```bash
# Edit Jenkins config
sudo nano /etc/default/jenkins

# Add/modify JAVA_ARGS
JAVA_ARGS="-Xmx4096m -Xms2048m"

# Restart Jenkins
sudo systemctl restart jenkins
```

### Permission Denied Errors

Fix Jenkins home permissions:
```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins
```

## Upgrading Jenkins

### Ubuntu/Debian

```bash
sudo apt update
sudo apt upgrade jenkins
sudo systemctl restart jenkins
```

### Docker

```bash
docker pull jenkins/jenkins:lts
docker stop jenkins
docker rm jenkins
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

### Kubernetes (Helm)

```bash
helm repo update
helm upgrade jenkins jenkins/jenkins --namespace jenkins
```

## Next Steps

Now that Jenkins is installed, continue to:
- **Jenkins-Pipelines.md** - Create your first pipeline
- **Jenkins-Plugins.md** - Essential plugins and configuration
- **Jenkins-Agents.md** - Set up distributed builds
- **Jenkins-Examples.md** - Real-world pipeline examples
