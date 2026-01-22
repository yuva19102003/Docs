# Jenkins Pipelines

## What is a Jenkins Pipeline?

A Jenkins Pipeline is a suite of plugins that supports implementing and integrating continuous delivery pipelines into Jenkins. A pipeline is defined in a `Jenkinsfile` using a domain-specific language (DSL) based on Groovy.

## Pipeline Types

### Declarative Pipeline (Recommended)

Simpler, more structured syntax with predefined sections:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}
```

### Scripted Pipeline

Full Groovy programming with maximum flexibility:

```groovy
node {
    stage('Build') {
        echo 'Building...'
    }
}
```

## Pipeline Structure

```
┌────────────────────────────────────────────────────────────┐
│              DECLARATIVE PIPELINE STRUCTURE                 │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  pipeline {                                                 │
│      │                                                      │
│      ├─► agent { ... }          ← Where to run             │
│      │                                                      │
│      ├─► environment { ... }    ← Variables                │
│      │                                                      │
│      ├─► options { ... }        ← Pipeline options         │
│      │                                                      │
│      ├─► parameters { ... }     ← Build parameters         │
│      │                                                      │
│      ├─► triggers { ... }       ← Automated triggers       │
│      │                                                      │
│      ├─► stages {                                          │
│      │       │                                             │
│      │       ├─► stage('Build') {                          │
│      │       │       steps { ... }                         │
│      │       │   }                                         │
│      │       │                                             │
│      │       ├─► stage('Test') {                           │
│      │       │       steps { ... }                         │
│      │       │   }                                         │
│      │       │                                             │
│      │       └─► stage('Deploy') {                         │
│      │               steps { ... }                         │
│      │           }                                         │
│      │   }                                                 │
│      │                                                     │
│      └─► post {                ← Post-build actions        │
│              always { ... }                                │
│              success { ... }                               │
│              failure { ... }                               │
│          }                                                 │
│  }                                                         │
└────────────────────────────────────────────────────────────┘
```

## Basic Declarative Pipeline

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/repo.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            steps {
                sh './deploy.sh'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finished'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

## Agent Configuration

### Run on Any Available Agent

```groovy
pipeline {
    agent any
    // ...
}
```

### Run on Specific Label

```groovy
pipeline {
    agent {
        label 'linux'
    }
    // ...
}
```

### Run in Docker Container

```groovy
pipeline {
    agent {
        docker {
            image 'node:20'
            args '-v /tmp:/tmp'
        }
    }
    // ...
}
```

### Run in Kubernetes Pod

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.8-openjdk-17
    command: ['cat']
    tty: true
'''
        }
    }
    // ...
}
```

### Different Agents per Stage

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build') {
            agent {
                docker 'maven:3.8-openjdk-17'
            }
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            agent {
                docker 'node:20'
            }
            steps {
                sh 'npm test'
            }
        }
    }
}
```

## Environment Variables

### Global Environment

```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'my-app'
        VERSION = '1.0.0'
        DOCKER_REGISTRY = 'docker.io'
    }
    
    stages {
        stage('Build') {
            steps {
                echo "Building ${APP_NAME} version ${VERSION}"
            }
        }
    }
}
```

### Stage-Specific Environment

```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy') {
            environment {
                DEPLOY_ENV = 'production'
            }
            steps {
                echo "Deploying to ${DEPLOY_ENV}"
            }
        }
    }
}
```

### Using Credentials

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_CREDS = credentials('dockerhub-credentials')
        AWS_ACCESS_KEY = credentials('aws-access-key-id')
        AWS_SECRET_KEY = credentials('aws-secret-access-key')
    }
    
    stages {
        stage('Push') {
            steps {
                sh 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin'
                sh 'docker push myimage:latest'
            }
        }
    }
}
```

## Parameters

### String Parameter

```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version number')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH}", url: 'https://github.com/user/repo.git'
                echo "Building version ${params.VERSION}"
            }
        }
    }
}
```

### Choice Parameter

```groovy
pipeline {
    agent any
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Deployment environment')
    }
    
    stages {
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT}"
            }
        }
    }
}
```

### Boolean Parameter

```groovy
pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy after build?')
    }
    
    stages {
        stage('Test') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

## Conditional Execution (when)

### Branch Condition

```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        sh './deploy-prod.sh'
    }
}
```

### Environment Condition

```groovy
stage('Deploy') {
    when {
        environment name: 'DEPLOY_ENV', value: 'production'
    }
    steps {
        sh './deploy.sh'
    }
}
```

### Expression Condition

```groovy
stage('Deploy') {
    when {
        expression { env.BRANCH_NAME == 'main' && params.DEPLOY == true }
    }
    steps {
        sh './deploy.sh'
    }
}
```

### Multiple Conditions

```groovy
stage('Deploy to Production') {
    when {
        allOf {
            branch 'main'
            environment name: 'BUILD_TYPE', value: 'release'
        }
    }
    steps {
        sh './deploy-prod.sh'
    }
}
```

## Parallel Execution

### Parallel Stages

```groovy
pipeline {
    agent any
    
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
                
                stage('E2E Tests') {
                    steps {
                        sh 'npm run test:e2e'
                    }
                }
            }
        }
    }
}
```

### Parallel with Different Agents

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build on Multiple Platforms') {
            parallel {
                stage('Linux Build') {
                    agent { label 'linux' }
                    steps {
                        sh './build.sh'
                    }
                }
                
                stage('Windows Build') {
                    agent { label 'windows' }
                    steps {
                        bat 'build.bat'
                    }
                }
                
                stage('macOS Build') {
                    agent { label 'macos' }
                    steps {
                        sh './build.sh'
                    }
                }
            }
        }
    }
}
```

## Post Actions

### Always Execute

```groovy
post {
    always {
        echo 'This runs regardless of pipeline result'
        cleanWs()  // Clean workspace
    }
}
```

### Success Only

```groovy
post {
    success {
        echo 'Pipeline succeeded!'
        slackSend color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded"
    }
}
```

### Failure Only

```groovy
post {
    failure {
        echo 'Pipeline failed!'
        emailext (
            subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "Check console output at ${env.BUILD_URL}",
            to: 'team@example.com'
        )
    }
}
```

### Changed Status

```groovy
post {
    changed {
        echo 'Pipeline status changed from previous build'
    }
}
```

### Unstable Build

```groovy
post {
    unstable {
        echo 'Build is unstable (tests failed but build succeeded)'
    }
}
```

## Input Steps (Manual Approval)

### Simple Approval

```groovy
stage('Deploy to Production') {
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
        sh './deploy-prod.sh'
    }
}
```

### Approval with Parameters

```groovy
stage('Deploy') {
    steps {
        script {
            def userInput = input(
                message: 'Deploy to which environment?',
                parameters: [
                    choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Target environment')
                ]
            )
            echo "Deploying to ${userInput}"
            sh "./deploy.sh ${userInput}"
        }
    }
}
```

### Timeout for Approval

```groovy
stage('Deploy to Production') {
    steps {
        timeout(time: 1, unit: 'HOURS') {
            input message: 'Deploy to production?', ok: 'Deploy'
        }
        sh './deploy-prod.sh'
    }
}
```

## Error Handling

### Try-Catch

```groovy
stage('Build') {
    steps {
        script {
            try {
                sh 'npm run build'
            } catch (Exception e) {
                echo "Build failed: ${e.message}"
                currentBuild.result = 'FAILURE'
            }
        }
    }
}
```

### Retry on Failure

```groovy
stage('Deploy') {
    steps {
        retry(3) {
            sh './deploy.sh'
        }
    }
}
```

### Timeout

```groovy
stage('Long Running Task') {
    steps {
        timeout(time: 30, unit: 'MINUTES') {
            sh './long-task.sh'
        }
    }
}
```

## Working with Files

### Archive Artifacts

```groovy
post {
    success {
        archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
    }
}
```

### Stash and Unstash

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build') {
            agent { label 'linux' }
            steps {
                sh 'npm run build'
                stash name: 'build-artifacts', includes: 'dist/**/*'
            }
        }
        
        stage('Deploy') {
            agent { label 'deploy-server' }
            steps {
                unstash 'build-artifacts'
                sh './deploy.sh'
            }
        }
    }
}
```

### Read/Write Files

```groovy
stage('Process') {
    steps {
        script {
            def content = readFile('config.json')
            echo "Config: ${content}"
            
            writeFile file: 'output.txt', text: 'Build completed'
        }
    }
}
```

## Triggers

### Poll SCM

```groovy
pipeline {
    agent any
    
    triggers {
        pollSCM('H/5 * * * *')  // Poll every 5 minutes
    }
    
    stages {
        // ...
    }
}
```

### Cron Schedule

```groovy
pipeline {
    agent any
    
    triggers {
        cron('H 2 * * *')  // Run daily at 2 AM
    }
    
    stages {
        // ...
    }
}
```

### Upstream Projects

```groovy
pipeline {
    agent any
    
    triggers {
        upstream(upstreamProjects: 'project1,project2', threshold: hudson.model.Result.SUCCESS)
    }
    
    stages {
        // ...
    }
}
```

## Options

### Common Options

```groovy
pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))  // Keep last 10 builds
        disableConcurrentBuilds()  // Don't run multiple builds simultaneously
        timeout(time: 1, unit: 'HOURS')  // Timeout after 1 hour
        timestamps()  // Add timestamps to console output
        skipDefaultCheckout()  // Don't automatically checkout SCM
    }
    
    stages {
        // ...
    }
}
```

## Tools

### Auto-install Tools

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
        nodejs 'NodeJS-20'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
                sh 'node --version'
            }
        }
    }
}
```

## Shared Libraries

### Using Shared Library

```groovy
@Library('my-shared-library') _

pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                buildApp()  // Function from shared library
            }
        }
    }
}
```

### Shared Library Structure

```
(root)
├── vars/
│   ├── buildApp.groovy
│   └── deployApp.groovy
├── src/
│   └── org/
│       └── company/
│           └── Utils.groovy
└── resources/
    └── scripts/
        └── deploy.sh
```

Example `vars/buildApp.groovy`:

```groovy
def call(String buildTool = 'maven') {
    if (buildTool == 'maven') {
        sh 'mvn clean package'
    } else if (buildTool == 'gradle') {
        sh './gradlew build'
    }
}
```

## Complete Example: Full CI/CD Pipeline

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        DOCKER_CREDS = credentials('dockerhub-credentials')
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Deployment environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/repo.git'
            }
        }
        
        stage('Build') {
            agent {
                docker {
                    image 'node:20'
                    reuseNode true
                }
            }
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            when {
                expression { params.RUN_TESTS }
            }
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
            }
        }
        
        stage('Code Quality') {
            steps {
                sh 'npm run lint'
                sh 'npm run sonar'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                    sh "docker tag ${imageTag} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    sh 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin'
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.ENVIRONMENT == 'production' }
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh "./deploy.sh ${params.ENVIRONMENT}"
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            slackSend color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded"
        }
        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Check console output at ${env.BUILD_URL}",
                to: 'team@example.com'
            )
        }
    }
}
```

## Best Practices

✅ **Use Declarative Pipelines**: Easier to read and maintain
✅ **Store Jenkinsfile in SCM**: Version control your pipeline
✅ **Use Shared Libraries**: Reuse common pipeline code
✅ **Implement Proper Error Handling**: Use try-catch and post blocks
✅ **Use Credentials Binding**: Never hardcode secrets
✅ **Keep Stages Focused**: One responsibility per stage
✅ **Use Parallel Execution**: Speed up builds
✅ **Add Manual Approvals**: For production deployments
✅ **Clean Workspaces**: Prevent disk space issues
✅ **Use Descriptive Stage Names**: Make pipeline readable

## Next Steps

Continue to:
- **Jenkins-Plugins.md** - Essential plugins and integrations
- **Jenkins-Agents.md** - Set up distributed builds
- **Jenkins-Examples.md** - More real-world examples
