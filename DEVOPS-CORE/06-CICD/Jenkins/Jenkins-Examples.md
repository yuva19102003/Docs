# Jenkins Pipeline Examples

## Example 1: Node.js Application CI/CD

```groovy
pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        DOCKER_CREDS = credentials('dockerhub-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/nodejs-app.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Lint') {
            steps {
                sh 'npm run lint'
            }
        }
        
        stage('Test') {
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
        
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                script {
                    def imageTag = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                    sh "docker tag ${imageTag} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    sh 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin'
                    sh "docker push ${imageTag}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl set image deployment/myapp \
                    myapp=${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER} \
                    --record
                """
            }
        }
    }
    
    post {
        always {
            junit '**/test-results/*.xml'
            publishHTML([
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
            cleanWs()
        }
        success {
            slackSend color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded!"
        }
        failure {
            slackSend color: 'danger', message: "Build ${env.BUILD_NUMBER} failed!"
        }
    }
}
```

## Example 2: Python Application with Testing

```groovy
pipeline {
    agent {
        docker {
            image 'python:3.11'
            args '-v /tmp:/tmp'
        }
    }
    
    environment {
        VIRTUAL_ENV = "${WORKSPACE}/venv"
    }
    
    stages {
        stage('Setup') {
            steps {
                sh '''
                    python -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install -r requirements-dev.txt
                '''
            }
        }
        
        stage('Lint & Format Check') {
            parallel {
                stage('Flake8') {
                    steps {
                        sh '''
                            . venv/bin/activate
                            flake8 src/ tests/
                        '''
                    }
                }
                stage('Black') {
                    steps {
                        sh '''
                            . venv/bin/activate
                            black --check src/ tests/
                        '''
                    }
                }
                stage('MyPy') {
                    steps {
                        sh '''
                            . venv/bin/activate
                            mypy src/
                        '''
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest --cov=src --cov-report=xml --cov-report=html --junitxml=test-results.xml
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                sh '''
                    . venv/bin/activate
                    bandit -r src/ -f json -o bandit-report.json
                    safety check --json > safety-report.json
                '''
            }
        }
        
        stage('Build Package') {
            steps {
                sh '''
                    . venv/bin/activate
                    python setup.py sdist bdist_wheel
                '''
            }
        }
        
        stage('Publish to PyPI') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'pypi-creds', usernameVariable: 'TWINE_USERNAME', passwordVariable: 'TWINE_PASSWORD')]) {
                    sh '''
                        . venv/bin/activate
                        twine upload dist/*
                    '''
                }
            }
        }
    }
    
    post {
        always {
            junit 'test-results.xml'
            cobertura coberturaReportFile: 'coverage.xml'
            archiveArtifacts artifacts: 'dist/*', fingerprint: true
        }
    }
}
```

## Example 3: Java Maven Multi-Module Project

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }
    
    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/java-app.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("myapp:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Deploy to Dev') {
            steps {
                sh '''
                    kubectl config use-context dev-cluster
                    kubectl set image deployment/myapp myapp=myapp:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Smoke Tests') {
            steps {
                sh 'mvn test -Dtest=SmokeTest'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    kubectl config use-context prod-cluster
                    kubectl set image deployment/myapp myapp=myapp:${BUILD_NUMBER}
                '''
            }
        }
    }
    
    post {
        always {
            junit '**/target/surefire-reports/*.xml'
            jacoco()
            archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
    }
}
```

## Example 4: Go Application

```groovy
pipeline {
    agent {
        docker {
            image 'golang:1.22'
            args '-v $HOME/go:/go'
        }
    }
    
    environment {
        CGO_ENABLED = '0'
        GOOS = 'linux'
        GOARCH = 'amd64'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/go-app.git'
            }
        }
        
        stage('Dependencies') {
            steps {
                sh 'go mod download'
                sh 'go mod verify'
            }
        }
        
        stage('Lint') {
            steps {
                sh 'go install golang.org/x/lint/golint@latest'
                sh 'golint ./...'
                sh 'go vet ./...'
            }
        }
        
        stage('Test') {
            steps {
                sh 'go test -v -race -coverprofile=coverage.out ./...'
                sh 'go tool cover -html=coverage.out -o coverage.html'
            }
        }
        
        stage('Build') {
            steps {
                sh 'go build -o bin/app -ldflags="-s -w" ./cmd/app'
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.build("goapp:${env.BUILD_NUMBER}", "--build-arg VERSION=${env.BUILD_NUMBER} .")
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'go install github.com/securego/gosec/v2/cmd/gosec@latest'
                sh 'gosec -fmt json -out gosec-report.json ./...'
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        docker.image("goapp:${env.BUILD_NUMBER}").push()
                        docker.image("goapp:${env.BUILD_NUMBER}").push('latest')
                    }
                }
            }
        }
    }
    
    post {
        always {
            publishHTML([
                reportDir: '.',
                reportFiles: 'coverage.html',
                reportName: 'Coverage Report'
            ])
        }
    }
}
```

## Example 5: Multi-Branch Pipeline

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
        
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                sh './deploy.sh dev'
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                sh './deploy.sh staging'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?'
                sh './deploy.sh production'
            }
        }
    }
}
```

## Example 6: Terraform Infrastructure Pipeline

```groovy
pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        TF_VAR_environment = "${params.ENVIRONMENT}"
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Environment')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/terraform-infra.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                sh '''
                    cd terraform/${ENVIRONMENT}
                    terraform init -backend-config="bucket=tfstate-${ENVIRONMENT}"
                '''
            }
        }
        
        stage('Terraform Validate') {
            steps {
                sh '''
                    cd terraform/${ENVIRONMENT}
                    terraform validate
                '''
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh '''
                    cd terraform/${ENVIRONMENT}
                    terraform plan -out=tfplan
                '''
            }
        }
        
        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                input message: "Proceed with terraform ${params.ACTION}?", ok: 'Proceed'
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                    cd terraform/${ENVIRONMENT}
                    terraform apply -auto-approve tfplan
                '''
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh '''
                    cd terraform/${ENVIRONMENT}
                    terraform destroy -auto-approve
                '''
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'terraform/**/*.tfplan', allowEmptyArchive: true
        }
    }
}
```

## Example 7: Microservices Deployment

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build Services') {
            parallel {
                stage('Auth Service') {
                    agent { label 'docker' }
                    steps {
                        dir('services/auth') {
                            sh 'docker build -t auth-service:${BUILD_NUMBER} .'
                            sh 'docker push registry.example.com/auth-service:${BUILD_NUMBER}'
                        }
                    }
                }
                
                stage('API Service') {
                    agent { label 'docker' }
                    steps {
                        dir('services/api') {
                            sh 'docker build -t api-service:${BUILD_NUMBER} .'
                            sh 'docker push registry.example.com/api-service:${BUILD_NUMBER}'
                        }
                    }
                }
                
                stage('Frontend') {
                    agent { label 'docker' }
                    steps {
                        dir('services/frontend') {
                            sh 'docker build -t frontend:${BUILD_NUMBER} .'
                            sh 'docker push registry.example.com/frontend:${BUILD_NUMBER}'
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            agent { label 'kubectl' }
            steps {
                sh '''
                    kubectl set image deployment/auth-service auth-service=registry.example.com/auth-service:${BUILD_NUMBER}
                    kubectl set image deployment/api-service api-service=registry.example.com/api-service:${BUILD_NUMBER}
                    kubectl set image deployment/frontend frontend=registry.example.com/frontend:${BUILD_NUMBER}
                    kubectl rollout status deployment/auth-service
                    kubectl rollout status deployment/api-service
                    kubectl rollout status deployment/frontend
                '''
            }
        }
        
        stage('Integration Tests') {
            agent { label 'test' }
            steps {
                sh 'npm run test:integration'
            }
        }
    }
}
```

## Example 8: Shared Library Usage

Create shared library in `vars/standardPipeline.groovy`:

```groovy
def call(Map config) {
    pipeline {
        agent any
        
        stages {
            stage('Checkout') {
                steps {
                    git branch: config.branch, url: config.repo
                }
            }
            
            stage('Build') {
                steps {
                    script {
                        if (config.buildTool == 'maven') {
                            sh 'mvn clean package'
                        } else if (config.buildTool == 'npm') {
                            sh 'npm install && npm run build'
                        }
                    }
                }
            }
            
            stage('Test') {
                steps {
                    script {
                        if (config.buildTool == 'maven') {
                            sh 'mvn test'
                        } else if (config.buildTool == 'npm') {
                            sh 'npm test'
                        }
                    }
                }
            }
            
            stage('Deploy') {
                when {
                    branch 'main'
                }
                steps {
                    sh "./deploy.sh ${config.environment}"
                }
            }
        }
    }
}
```

Use in Jenkinsfile:

```groovy
@Library('my-shared-library') _

standardPipeline(
    repo: 'https://github.com/user/repo.git',
    branch: 'main',
    buildTool: 'npm',
    environment: 'production'
)
```

## Example 9: Matrix Build (Multiple Platforms)

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build Matrix') {
            matrix {
                agent {
                    label "${PLATFORM}"
                }
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux', 'windows', 'macos'
                    }
                    axis {
                        name 'NODE_VERSION'
                        values '18', '20', '22'
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            script {
                                if (PLATFORM == 'windows') {
                                    bat "nvm use ${NODE_VERSION} && npm install && npm run build"
                                } else {
                                    sh "nvm use ${NODE_VERSION} && npm install && npm run build"
                                }
                            }
                        }
                    }
                    stage('Test') {
                        steps {
                            script {
                                if (PLATFORM == 'windows') {
                                    bat "npm test"
                                } else {
                                    sh "npm test"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## Example 10: Blue-Green Deployment

```groovy
pipeline {
    agent any
    
    environment {
        BLUE_DEPLOYMENT = 'myapp-blue'
        GREEN_DEPLOYMENT = 'myapp-green'
        SERVICE_NAME = 'myapp-service'
    }
    
    stages {
        stage('Determine Active Deployment') {
            steps {
                script {
                    def currentSelector = sh(
                        script: "kubectl get service ${SERVICE_NAME} -o jsonpath='{.spec.selector.version}'",
                        returnStdout: true
                    ).trim()
                    
                    if (currentSelector == 'blue') {
                        env.ACTIVE = 'blue'
                        env.INACTIVE = 'green'
                    } else {
                        env.ACTIVE = 'green'
                        env.INACTIVE = 'blue'
                    }
                    echo "Active: ${env.ACTIVE}, Deploying to: ${env.INACTIVE}"
                }
            }
        }
        
        stage('Deploy to Inactive') {
            steps {
                sh """
                    kubectl set image deployment/myapp-${INACTIVE} \
                    myapp=myapp:${BUILD_NUMBER}
                    kubectl rollout status deployment/myapp-${INACTIVE}
                """
            }
        }
        
        stage('Run Smoke Tests') {
            steps {
                sh "./smoke-tests.sh myapp-${INACTIVE}"
            }
        }
        
        stage('Switch Traffic') {
            steps {
                input message: 'Switch traffic to new deployment?', ok: 'Switch'
                sh """
                    kubectl patch service ${SERVICE_NAME} \
                    -p '{"spec":{"selector":{"version":"${INACTIVE}"}}}'
                """
            }
        }
        
        stage('Monitor') {
            steps {
                sleep time: 5, unit: 'MINUTES'
                sh "./health-check.sh"
            }
        }
    }
    
    post {
        failure {
            sh """
                kubectl patch service ${SERVICE_NAME} \
                -p '{"spec":{"selector":{"version":"${ACTIVE}"}}}'
            """
        }
    }
}
```

These examples cover common CI/CD scenarios and can be adapted to your specific needs.
