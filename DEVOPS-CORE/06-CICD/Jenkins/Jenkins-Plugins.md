# Jenkins Essential Plugins

## Plugin Categories

```
┌────────────────────────────────────────────────────────────┐
│              JENKINS PLUGIN ECOSYSTEM                       │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Source     │  │    Build     │  │    Test      │    │
│  │   Control    │  │    Tools     │  │   & Quality  │    │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤    │
│  │ • Git        │  │ • Maven      │  │ • JUnit      │    │
│  │ • GitHub     │  │ • Gradle     │  │ • SonarQube  │    │
│  │ • Bitbucket  │  │ • NodeJS     │  │ • Checkstyle │    │
│  │ • GitLab     │  │ • Docker     │  │ • Coverage   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Deploy     │  │  Notification│  │   Security   │    │
│  │   & Cloud    │  │  & Reporting │  │              │    │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤    │
│  │ • Kubernetes │  │ • Slack      │  │ • Credentials│    │
│  │ • AWS        │  │ • Email      │  │ • OWASP      │    │
│  │ • Azure      │  │ • Teams      │  │ • Role-Based │    │
│  │ • Ansible    │  │ • Jira       │  │ • Audit Log  │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└────────────────────────────────────────────────────────────┘
```

## Essential Plugins (Must-Have)

### 1. Pipeline Plugins

**Pipeline**
- Core pipeline functionality
- Declarative and scripted pipelines
- Pre-installed with Jenkins

**Pipeline: Stage View**
- Visual representation of pipeline stages
- Shows stage duration and status

**Blue Ocean**
- Modern, visual pipeline editor
- Better UI for pipeline visualization
- Real-time pipeline execution view

```bash
# Install via CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin blueocean
```

### 2. Source Control Management

**Git Plugin**
- Git repository integration
- Branch and tag support
- Pre-installed with Jenkins

**GitHub Plugin**
- GitHub-specific features
- Webhook support
- Pull request builder

**GitLab Plugin**
- GitLab integration
- Merge request triggers
- GitLab CI/CD integration

**Bitbucket Plugin**
- Bitbucket Cloud/Server integration
- Pull request triggers

### 3. Build Tools

**Maven Integration Plugin**
- Maven project support
- Automatic POM parsing
- Dependency management

**Gradle Plugin**
- Gradle build support
- Build scan integration

**NodeJS Plugin**
- Node.js and npm support
- Multiple Node versions
- Global npm packages

```groovy
// Using NodeJS plugin in pipeline
pipeline {
    agent any
    tools {
        nodejs 'NodeJS-20'
    }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
    }
}
```

### 4. Docker Integration

**Docker Plugin**
- Docker build and push
- Docker agent provisioning
- Docker registry integration

**Docker Pipeline Plugin**
- Docker commands in pipeline
- Build and run containers

```groovy
pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    docker.build('myapp:latest')
                }
            }
        }
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        docker.image('myapp:latest').push()
                    }
                }
            }
        }
    }
}
```

### 5. Kubernetes Integration

**Kubernetes Plugin**
- Dynamic Kubernetes agents
- Pod template support
- Auto-scaling

**Kubernetes CLI Plugin**
- kubectl commands in pipeline
- Kubeconfig management

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
'''
        }
    }
    stages {
        stage('Deploy') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }
}
```

### 6. Cloud Providers

**AWS Steps Plugin**
- AWS CLI commands
- S3, EC2, ECS integration
- CloudFormation support

**Azure CLI Plugin**
- Azure resource management
- Azure DevOps integration

**Google Cloud SDK Plugin**
- GCP integration
- GKE deployment

```groovy
// AWS example
pipeline {
    agent any
    stages {
        stage('Deploy to S3') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    s3Upload(bucket: 'my-bucket', path: 'app/', includePathPattern: '**/*')
                }
            }
        }
    }
}
```

### 7. Code Quality & Security

**SonarQube Scanner**
- Code quality analysis
- Technical debt tracking
- Security vulnerabilities

```groovy
pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

**OWASP Dependency-Check Plugin**
- Dependency vulnerability scanning
- CVE detection

**Checkstyle Plugin**
- Java code style checking
- Coding standards enforcement

**JaCoCo Plugin**
- Code coverage reporting
- Coverage trends

### 8. Testing

**JUnit Plugin**
- Test result publishing
- Test trend graphs
- Pre-installed

**Test Results Analyzer Plugin**
- Detailed test analysis
- Failure trends

**Performance Plugin**
- Performance test results
- JMeter integration

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
    }
    post {
        always {
            junit '**/target/surefire-reports/*.xml'
            jacoco()
        }
    }
}
```

### 9. Notifications

**Email Extension Plugin**
- Advanced email notifications
- HTML templates
- Conditional sending

```groovy
post {
    failure {
        emailext (
            subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: """
                <p>Build failed!</p>
                <p>Job: ${env.JOB_NAME}</p>
                <p>Build Number: ${env.BUILD_NUMBER}</p>
                <p>Check console output: ${env.BUILD_URL}</p>
            """,
            to: 'team@example.com',
            mimeType: 'text/html'
        )
    }
}
```

**Slack Notification Plugin**
- Slack integration
- Channel notifications
- Custom messages

```groovy
post {
    success {
        slackSend (
            color: 'good',
            message: "Build Succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
    failure {
        slackSend (
            color: 'danger',
            message: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

**Microsoft Teams Plugin**
- Teams notifications
- Webhook integration

### 10. Credentials & Security

**Credentials Plugin**
- Secure credential storage
- Multiple credential types
- Pre-installed

**Credentials Binding Plugin**
- Bind credentials to variables
- Secure credential usage

```groovy
pipeline {
    agent any
    environment {
        DB_CREDS = credentials('database-credentials')
        API_KEY = credentials('api-key')
    }
    stages {
        stage('Deploy') {
            steps {
                sh 'echo $DB_CREDS_USR'  // Username
                sh 'echo $DB_CREDS_PSW'  // Password (masked in logs)
            }
        }
    }
}
```

**Role-based Authorization Strategy**
- Fine-grained permissions
- Project-based access control

**Audit Trail Plugin**
- Track configuration changes
- User activity logging

### 11. Deployment

**Deploy to Container Plugin**
- Deploy to Tomcat, JBoss, etc.
- WAR/EAR deployment

**Ansible Plugin**
- Ansible playbook execution
- Inventory management

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy with Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'deploy.yml',
                    inventory: 'hosts',
                    credentialsId: 'ssh-key'
                )
            }
        }
    }
}
```

**SSH Plugin**
- Remote command execution
- File transfer

### 12. Monitoring & Reporting

**Prometheus Metrics Plugin**
- Expose Jenkins metrics
- Prometheus integration

**Build Monitor Plugin**
- Dashboard view
- Build status visualization

**Dashboard View Plugin**
- Custom dashboards
- Multiple views

### 13. Configuration Management

**Configuration as Code (JCasC)**
- YAML-based configuration
- Reproducible setup
- Version control friendly

Example `jenkins.yaml`:

```yaml
jenkins:
  systemMessage: "Jenkins configured automatically by JCasC"
  numExecutors: 2
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "${ADMIN_PASSWORD}"
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"

credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "dockerhub-creds"
              username: "${DOCKER_USERNAME}"
              password: "${DOCKER_PASSWORD}"

tool:
  git:
    installations:
      - name: "Default"
        home: "git"
  maven:
    installations:
      - name: "Maven-3.9"
        properties:
          - installSource:
              installers:
                - maven:
                    id: "3.9.0"
```

**Job DSL Plugin**
- Programmatic job creation
- Job templates
- Bulk job management

```groovy
// Job DSL example
pipelineJob('my-app-pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/user/repo.git')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}
```

## Plugin Management

### Install Plugins via UI

1. Go to **Manage Jenkins → Manage Plugins**
2. Click **Available** tab
3. Search for plugin
4. Check the box
5. Click **Install without restart** or **Download now and install after restart**

### Install Plugins via CLI

```bash
# Download jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Install plugin
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:password install-plugin <plugin-name>

# Restart Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:password safe-restart
```

### Install Plugins via Dockerfile

```dockerfile
FROM jenkins/jenkins:lts

# Install plugins
RUN jenkins-plugin-cli --plugins \
    git \
    docker-workflow \
    kubernetes \
    pipeline-stage-view \
    blueocean \
    credentials-binding \
    workflow-aggregator \
    sonar \
    slack \
    email-ext
```

### Update Plugins

1. Go to **Manage Jenkins → Manage Plugins**
2. Click **Updates** tab
3. Select plugins to update
4. Click **Download now and install after restart**

### Backup Plugins

```bash
# List installed plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:password list-plugins

# Backup plugins directory
tar -czf jenkins-plugins-backup.tar.gz /var/lib/jenkins/plugins/
```

## Recommended Plugin Sets

### Minimal Setup

- Pipeline
- Git
- Credentials Binding
- Email Extension

### Standard Setup

- All Minimal plugins
- Docker Pipeline
- Kubernetes
- Blue Ocean
- Slack Notification
- SonarQube Scanner

### Enterprise Setup

- All Standard plugins
- Role-based Authorization Strategy
- Audit Trail
- Configuration as Code
- Job DSL
- Prometheus Metrics
- OWASP Dependency-Check

## Plugin Best Practices

✅ **Keep Plugins Updated**: Regular updates for security and features
✅ **Minimize Plugin Count**: Only install what you need
✅ **Test Before Production**: Test plugin updates in staging
✅ **Use Plugin Manager**: Manage dependencies automatically
✅ **Backup Before Updates**: Backup Jenkins before major updates
✅ **Monitor Plugin Health**: Check for deprecated plugins
✅ **Use JCasC**: Configure plugins via code
✅ **Review Security Advisories**: Stay informed about vulnerabilities

## Troubleshooting Plugins

### Plugin Won't Install

- Check Jenkins version compatibility
- Verify internet connectivity
- Check disk space
- Review Jenkins logs

### Plugin Conflicts

- Check plugin dependencies
- Update conflicting plugins
- Disable one of the conflicting plugins

### Plugin Causing Issues

- Disable plugin temporarily
- Check plugin logs
- Rollback to previous version
- Report issue to plugin maintainers

## Next Steps

Continue to:
- **Jenkins-Examples.md** - Real-world pipeline examples
