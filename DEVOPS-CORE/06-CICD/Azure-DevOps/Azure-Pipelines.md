# Azure Pipelines

## Basic Pipeline Structure

```yaml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - task: DotNetCoreCLI@2
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

- stage: Test
  jobs:
  - job: TestJob
    steps:
    - task: DotNetCoreCLI@2
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'

- stage: Deploy
  jobs:
  - deployment: DeployJob
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo Deploying...
```

## Multi-Stage Pipeline

```yaml
stages:
- stage: Build
  displayName: 'Build Stage'
  jobs:
  - job: Build
    steps:
    - script: npm install
    - script: npm run build
    - publish: $(System.DefaultWorkingDirectory)/dist
      artifact: WebApp

- stage: DeployDev
  displayName: 'Deploy to Dev'
  dependsOn: Build
  jobs:
  - deployment: DeployDev
    environment: dev
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: WebApp
          - script: ./deploy.sh dev

- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: DeployDev
  jobs:
  - deployment: DeployProd
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: WebApp
          - script: ./deploy.sh production
```

## Tasks

### Node.js

```yaml
- task: NodeTool@0
  inputs:
    versionSpec: '20.x'

- script: |
    npm install
    npm run build
    npm test
```

### Docker

```yaml
- task: Docker@2
  inputs:
    command: 'buildAndPush'
    repository: 'myapp'
    dockerfile: '**/Dockerfile'
    containerRegistry: 'DockerHub'
    tags: |
      $(Build.BuildId)
      latest
```

### Kubernetes

```yaml
- task: Kubernetes@1
  inputs:
    connectionType: 'Kubernetes Service Connection'
    kubernetesServiceEndpoint: 'MyK8sCluster'
    command: 'apply'
    useConfigurationFile: true
    configuration: 'k8s/deployment.yaml'
```

## Variables

```yaml
variables:
  - name: buildConfiguration
    value: 'Release'
  - group: 'production-vars'
  - name: imageTag
    value: '$(Build.BuildId)'
```

## Conditions

```yaml
- script: echo Deploy to production
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

## Templates

### Template File (`build-template.yml`)

```yaml
parameters:
  - name: buildConfiguration
    type: string
    default: 'Release'

steps:
- script: npm install
- script: npm run build -- --configuration ${{ parameters.buildConfiguration }}
```

### Use Template

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - template: build-template.yml
      parameters:
        buildConfiguration: 'Release'
```

## Complete Example

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: production-secrets
  - name: dockerRegistry
    value: 'myregistry.azurecr.io'
  - name: imageName
    value: 'myapp'

stages:
- stage: Build
  jobs:
  - job: BuildAndTest
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '20.x'
    
    - script: |
        npm ci
        npm run build
      displayName: 'Build'
    
    - script: |
        npm test
      displayName: 'Test'
    
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results.xml'
    
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage/cobertura-coverage.xml'
    
    - task: Docker@2
      inputs:
        command: 'buildAndPush'
        repository: '$(dockerRegistry)/$(imageName)'
        dockerfile: '**/Dockerfile'
        containerRegistry: 'AzureContainerRegistry'
        tags: |
          $(Build.BuildId)
          latest

- stage: DeployStaging
  dependsOn: Build
  jobs:
  - deployment: DeployToStaging
    environment: 'staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: Kubernetes@1
            inputs:
              connectionType: 'Kubernetes Service Connection'
              kubernetesServiceEndpoint: 'StagingCluster'
              command: 'set'
              arguments: 'image deployment/myapp myapp=$(dockerRegistry)/$(imageName):$(Build.BuildId)'

- stage: DeployProduction
  dependsOn: DeployStaging
  jobs:
  - deployment: DeployToProduction
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: Kubernetes@1
            inputs:
              connectionType: 'Kubernetes Service Connection'
              kubernetesServiceEndpoint: 'ProductionCluster'
              command: 'set'
              arguments: 'image deployment/myapp myapp=$(dockerRegistry)/$(imageName):$(Build.BuildId)'
```

## Best Practices

✅ **Use Stages**: Organize pipeline logically
✅ **Use Templates**: Reuse configurations
✅ **Implement Approvals**: Manual gates for production
✅ **Use Variable Groups**: Centralize secrets
✅ **Publish Artifacts**: Share between stages
✅ **Use Service Connections**: Secure credentials
✅ **Monitor Pipelines**: Set up alerts
✅ **Use Conditions**: Control execution flow

## Next Steps

Continue to:
- **Azure-Agents.md** - Setting up self-hosted agents
- **Azure-DevOps-Examples.md** - Real-world examples
