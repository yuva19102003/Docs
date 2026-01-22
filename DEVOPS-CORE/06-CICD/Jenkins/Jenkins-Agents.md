# Jenkins Agents (Distributed Builds)

## What are Jenkins Agents?

Jenkins Agents (formerly called slaves or nodes) are worker machines that execute build jobs dispatched by the Jenkins Master (Controller). This distributed architecture allows:

- **Scalability**: Run multiple builds simultaneously
- **Platform Diversity**: Build on different OS (Linux, Windows, macOS)
- **Resource Isolation**: Separate build environments
- **Load Distribution**: Distribute workload across multiple machines

## Master-Agent Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                  JENKINS MASTER-AGENT ARCHITECTURE                │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│                    ┌──────────────────────┐                      │
│                    │   JENKINS MASTER     │                      │
│                    │    (Controller)      │                      │
│                    ├──────────────────────┤                      │
│                    │ • Job Scheduling     │                      │
│                    │ • Plugin Management  │                      │
│                    │ • UI & API           │                      │
│                    │ • Build History      │                      │
│                    └──────────┬───────────┘                      │
│                               │                                   │
│              ┌────────────────┼────────────────┐                 │
│              │                │                │                 │
│              ▼                ▼                ▼                 │
│     ┌────────────────┐ ┌────────────────┐ ┌────────────────┐   │
│     │   AGENT 1      │ │   AGENT 2      │ │   AGENT 3      │   │
│     │   (Linux)      │ │   (Docker)     │ │   (Windows)    │   │
│     ├────────────────┤ ├────────────────┤ ├────────────────┤   │
│     │ Label: linux   │ │ Label: docker  │ │ Label: windows │   │
│     │ Executors: 2   │ │ Executors: 4   │ │ Executors: 2   │   │
│     ├────────────────┤ ├────────────────┤ ├────────────────┤   │
│     │ Workspace 1    │ │ Container 1    │ │ Workspace 1    │   │
│     │ Workspace 2    │ │ Container 2    │ │ Workspace 2    │   │
│     │                │ │ Container 3    │ │                │   │
│     │                │ │ Container 4    │ │                │   │
│     └────────────────┘ └────────────────┘ └────────────────┘   │
│              │                │                │                 │
│              └────────────────┴────────────────┘                 │
│                               │                                   │
│                               ▼                                   │
│                    ┌──────────────────────┐                      │
│                    │  BUILD ARTIFACTS     │                      │
│                    │  • Docker Images     │                      │
│                    │  • Binaries          │                      │
│                    │  • Test Reports      │                      │
│                    └──────────────────────┘                      │
└──────────────────────────────────────────────────────────────────┘
```

## Agent Connection Methods

### 1. SSH (Recommended for Linux/macOS)

**Pros**: Secure, standard protocol, easy setup
**Cons**: Requires SSH server on agent

### 2. JNLP (Java Web Start)

**Pros**: Works through firewalls, no inbound connections needed
**Cons**: Requires Java on agent

### 3. Windows Service

**Pros**: Native Windows integration, runs as service
**Cons**: Windows only

### 4. Docker

**Pros**: Ephemeral, isolated, scalable
**Cons**: Requires Docker infrastructure

### 5. Kubernetes

**Pros**: Dynamic provisioning, auto-scaling, cloud-native
**Cons**: Requires Kubernetes cluster

## Setting Up SSH Agent (Linux)

### On Agent Machine

```bash
# Install Java
sudo apt update
sudo apt install openjdk-17-jdk -y

# Create Jenkins user
sudo useradd -m -s /bin/bash jenkins

# Create SSH directory
sudo mkdir -p /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh

# Generate SSH key on Master and copy public key to agent
# On Master:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_agent_key

# Copy public key to agent
ssh-copy-id -i ~/.ssh/jenkins_agent_key.pub jenkins@agent-ip

# Or manually add to authorized_keys
sudo nano /home/jenkins/.ssh/authorized_keys
# Paste public key
sudo chmod 600 /home/jenkins/.ssh/authorized_keys
sudo chown -R jenkins:jenkins /home/jenkins/.ssh

# Create workspace directory
sudo mkdir -p /home/jenkins/workspace
sudo chown jenkins:jenkins /home/jenkins/workspace
```

### On Jenkins Master

1. Go to **Manage Jenkins → Manage Nodes and Clouds → New Node**
2. Enter node name: `linux-agent-1`
3. Select **Permanent Agent**
4. Configure:
   - **Name**: `linux-agent-1`
   - **Description**: Linux build agent
   - **Number of executors**: `2`
   - **Remote root directory**: `/home/jenkins`
   - **Labels**: `linux ubuntu`
   - **Usage**: Use this node as much as possible
   - **Launch method**: Launch agents via SSH
   - **Host**: `agent-ip-address`
   - **Credentials**: Add SSH credentials (username: jenkins, private key)
   - **Host Key Verification Strategy**: Manually trusted key verification
5. Click **Save**

## Setting Up JNLP Agent

### On Agent Machine

```bash
# Install Java
sudo apt update
sudo apt install openjdk-17-jdk -y

# Create Jenkins directory
sudo mkdir -p /opt/jenkins
cd /opt/jenkins

# Download agent.jar from Jenkins Master
wget http://jenkins-master:8080/jnlpJars/agent.jar

# Get secret from Jenkins UI (Manage Jenkins → Manage Nodes → Agent → Secret)
# Run agent
java -jar agent.jar -jnlpUrl http://jenkins-master:8080/computer/agent-name/jenkins-agent.jnlp -secret <secret> -workDir "/opt/jenkins"
```

### Create Systemd Service

Create `/etc/systemd/system/jenkins-agent.service`:

```ini
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
Type=simple
User=jenkins
WorkingDirectory=/opt/jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/agent.jar -jnlpUrl http://jenkins-master:8080/computer/agent-name/jenkins-agent.jnlp -secret <secret> -workDir "/opt/jenkins"
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable jenkins-agent
sudo systemctl start jenkins-agent
sudo systemctl status jenkins-agent
```

## Docker Agent

### Static Docker Agent

```bash
# Run Jenkins agent in Docker
docker run -d \
  --name jenkins-agent \
  --init \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins-agent-workspace:/home/jenkins \
  jenkins/inbound-agent:latest \
  -url http://jenkins-master:8080 \
  -secret <secret> \
  -name docker-agent-1 \
  -workDir /home/jenkins
```

### Dynamic Docker Agents (Docker Plugin)

Install **Docker Plugin** in Jenkins.

Configure Docker Cloud:
1. Go to **Manage Jenkins → Manage Nodes and Clouds → Configure Clouds**
2. Add **Docker**
3. Configure:
   - **Docker Host URI**: `unix:///var/run/docker.sock` or `tcp://docker-host:2376`
   - **Docker Agent templates**:
     - **Labels**: `docker`
     - **Docker Image**: `jenkins/agent:latest`
     - **Instance Capacity**: `10`
     - **Remote File System Root**: `/home/jenkins`

### Pipeline with Docker Agent

```groovy
pipeline {
    agent {
        docker {
            image 'node:20'
            args '-v /tmp:/tmp'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'node --version'
                sh 'npm install'
            }
        }
    }
}
```

## Kubernetes Agent

### Install Kubernetes Plugin

Install **Kubernetes Plugin** from Jenkins Plugin Manager.

### Configure Kubernetes Cloud

1. Go to **Manage Jenkins → Manage Nodes and Clouds → Configure Clouds**
2. Add **Kubernetes**
3. Configure:
   - **Name**: `kubernetes`
   - **Kubernetes URL**: `https://kubernetes.default.svc.cluster.local`
   - **Kubernetes Namespace**: `jenkins`
   - **Jenkins URL**: `http://jenkins.jenkins.svc.cluster.local:8080`
   - **Jenkins tunnel**: `jenkins-agent.jenkins.svc.cluster.local:50000`

### Pod Template

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: maven
    image: maven:3.8-openjdk-17
    command:
    - cat
    tty: true
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }
    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
        stage('Docker Build') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp:latest .'
                }
            }
        }
    }
}
```

### Multi-Container Pod

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: node:20
    command: ['cat']
    tty: true
  - name: python
    image: python:3.11
    command: ['cat']
    tty: true
  - name: golang
    image: golang:1.22
    command: ['cat']
    tty: true
'''
        }
    }
    stages {
        stage('Node Build') {
            steps {
                container('node') {
                    sh 'npm install'
                }
            }
        }
        stage('Python Tests') {
            steps {
                container('python') {
                    sh 'pytest'
                }
            }
        }
        stage('Go Build') {
            steps {
                container('golang') {
                    sh 'go build ./...'
                }
            }
        }
    }
}
```

## Windows Agent

### Setup Windows Agent

1. Install Java JDK on Windows machine
2. Create directory: `C:\Jenkins`
3. In Jenkins: **Manage Jenkins → Manage Nodes → New Node**
4. Configure:
   - **Launch method**: Launch agent by connecting it to the controller
   - Download `agent.jar` from Jenkins
   - Run command:
     ```cmd
     java -jar agent.jar -jnlpUrl http://jenkins-master:8080/computer/windows-agent/jenkins-agent.jnlp -secret <secret> -workDir "C:\Jenkins"
     ```

### Install as Windows Service

```cmd
# Download winsw.exe
# Rename to jenkins-agent.exe
# Create jenkins-agent.xml
```

`jenkins-agent.xml`:

```xml
<service>
  <id>jenkins-agent</id>
  <name>Jenkins Agent</name>
  <description>Jenkins Build Agent</description>
  <executable>java</executable>
  <arguments>-jar "%BASE%\agent.jar" -jnlpUrl http://jenkins-master:8080/computer/windows-agent/jenkins-agent.jnlp -secret <secret> -workDir "C:\Jenkins"</arguments>
  <logmode>rotate</logmode>
</service>
```

Install service:

```cmd
jenkins-agent.exe install
jenkins-agent.exe start
```

## Agent Labels and Selection

### Assign Labels

Labels help route jobs to appropriate agents:

- `linux`, `windows`, `macos`
- `docker`, `kubernetes`
- `java`, `node`, `python`
- `build`, `test`, `deploy`
- `gpu`, `high-memory`

### Use Labels in Pipeline

```groovy
pipeline {
    agent {
        label 'linux && docker'
    }
    stages {
        stage('Build') {
            steps {
                sh 'docker build .'
            }
        }
    }
}
```

### Multiple Agents

```groovy
pipeline {
    agent none
    stages {
        stage('Build on Linux') {
            agent { label 'linux' }
            steps {
                sh './build.sh'
            }
        }
        stage('Build on Windows') {
            agent { label 'windows' }
            steps {
                bat 'build.bat'
            }
        }
    }
}
```

## Agent Monitoring

### Check Agent Status

Go to **Manage Jenkins → Manage Nodes and Clouds**

View:
- Agent status (online/offline)
- Executor availability
- Disk space
- Response time
- Build queue

### Agent Logs

View logs:
- Click on agent name
- Click **Log** in left menu
- View connection and execution logs

### Monitoring Script

```groovy
// Groovy script to check agent health
import jenkins.model.Jenkins

Jenkins.instance.computers.each { computer ->
    println "Agent: ${computer.name}"
    println "  Online: ${!computer.offline}"
    println "  Executors: ${computer.numExecutors}"
    println "  Idle: ${computer.isIdle()}"
    println "  Disk Space: ${computer.diskSpaceMonitor?.size}"
    println ""
}
```

## Best Practices

✅ **Use Labels Effectively**: Tag agents with capabilities
✅ **Right-Size Executors**: 1-2 executors per CPU core
✅ **Monitor Disk Space**: Set up alerts for low disk space
✅ **Use Ephemeral Agents**: Docker/K8s for clean builds
✅ **Secure Connections**: Use SSH keys or secure tokens
✅ **Regular Maintenance**: Update agents and clean workspaces
✅ **Load Balancing**: Distribute builds across agents
✅ **Backup Agent Configs**: Document agent setup
✅ **Use Cloud Agents**: Auto-scale with cloud providers
✅ **Isolate Environments**: Separate dev/staging/prod agents

## Troubleshooting

### Agent Won't Connect

Check:
- Network connectivity
- Firewall rules (port 50000)
- SSH keys/credentials
- Java version compatibility
- Agent logs

### Agent Goes Offline

Possible causes:
- Network issues
- Disk space full
- Out of memory
- Agent process crashed
- Master-agent version mismatch

### Slow Builds

Solutions:
- Add more executors
- Use faster agents
- Implement build caching
- Optimize pipeline
- Use parallel execution

## Next Steps

Continue to:
- **Jenkins-Plugins.md** - Essential plugins
- **Jenkins-Examples.md** - Real-world examples
