# OIDC Setup for CI/CD - End-to-End Guide

Complete guide to setting up OpenID Connect (OIDC) authentication between CI/CD platforms and Azure using Microsoft Entra ID (formerly Azure AD).

## Table of Contents
- [What is OIDC?](#what-is-oidc)
- [Why Use OIDC for CI/CD?](#why-use-oidc-for-cicd)
- [Prerequisites](#prerequisites)
- [GitHub Actions OIDC Setup](#github-actions-oidc-setup)
- [Azure DevOps OIDC Setup](#azure-devops-oidc-setup)
- [Jenkins OIDC Setup](#jenkins-oidc-setup)
- [Troubleshooting](#troubleshooting)

## What is OIDC?

```
┌────────────────────────────────────────────────────────────────────────┐
│                    OIDC Authentication Flow                            │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐                    ┌──────────────────┐
│   CI/CD Platform │                    │  Microsoft       │
│                  │                    │  Entra ID        │
│  • GitHub Actions│                    │  (Azure AD)      │
│  • Azure DevOps  │                    │                  │
│  • Jenkins       │                    │                  │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         │ 1. Request OIDC Token                 │
         ├──────────────────────────────────────>│
         │                                       │
         │ 2. Return JWT Token                   │
         │<──────────────────────────────────────┤
         │                                       │
         │ 3. Exchange Token for                 │
         │    Azure Access Token                 │
         ├──────────────────────────────────────>│
         │                                       │
         │ 4. Return Azure Access Token          │
         │<──────────────────────────────────────┤
         │                                       │
         ▼                                       │
┌──────────────────┐                             │
│  Azure Resources │<────────────────────────────┘
│                  │    5. Access with Token
│  • Storage       │
│  • AKS           │
│  • Web Apps      │
└──────────────────┘
```

**OIDC (OpenID Connect)** is an authentication protocol that allows CI/CD platforms to authenticate with Azure without storing long-lived credentials.

## Why Use OIDC for CI/CD?

### Traditional Approach (Service Principal with Secret)
```
❌ Secrets stored in CI/CD platform
❌ Secrets can expire
❌ Secrets can be leaked
❌ Manual rotation required
❌ Security risk if compromised
```

### OIDC Approach (Federated Identity)
```
✅ No secrets stored
✅ Short-lived tokens
✅ Automatic token rotation
✅ Better security posture
✅ Audit trail in Azure AD
✅ Conditional access policies
```

## Prerequisites

### Azure Requirements
- Azure subscription
- Permissions to create:
  - App Registrations
  - Service Principals
  - Role Assignments
- Azure CLI or Azure Portal access

### CI/CD Platform Requirements
- GitHub repository (for GitHub Actions)
- Azure DevOps organization (for Azure DevOps)
- Jenkins server (for Jenkins)

## GitHub Actions OIDC Setup

### Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│              GitHub Actions OIDC Architecture                          │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Workflow (.github/workflows/deploy.yml)      │  │
│  │                                                        │  │
│  │  - uses: azure/login@v1                                │  │
│  │    with:                                               │  │
│  │      client-id: ${{ secrets.AZURE_CLIENT_ID }}         │  │
│  │      tenant-id: ${{ secrets.AZURE_TENANT_ID }}         │  │
│  │      subscription-id: ${{ secrets.AZURE_SUB_ID }}      │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────┘
                            │
                            │ OIDC Token Request
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                  Microsoft Entra ID                           │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           App Registration                              │  │
│  │                                                         │  │
│  │  • Application (client) ID                              │  │
│  │  • Federated Credentials                                │  │
│  │    - Issuer: https://token.actions.githubusercontent.com│  │
│  │    - Subject: repo:org/repo:ref:refs/heads/main         │  │
│  │    - Audience: api://AzureADTokenExchange               │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
                            │ Access Token
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                    Azure Resources                           │
│                                                              │
│  • Resource Groups                                           │
│  • Storage Accounts                                          │
│  • AKS Clusters                                              │
│  • Web Apps                                                  │
└──────────────────────────────────────────────────────────────┘
```

### Step 1: Create App Registration in Azure

```bash
# Login to Azure
az login

# Set variables
APP_NAME="github-actions-oidc"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# Create App Registration
az ad app create --display-name $APP_NAME

# Get Application ID
APP_ID=$(az ad app list --display-name $APP_NAME --query [0].appId -o tsv)

echo "Application (Client) ID: $APP_ID"
echo "Tenant ID: $TENANT_ID"
echo "Subscription ID: $SUBSCRIPTION_ID"
```

### Step 2: Create Service Principal

```bash
# Create Service Principal
az ad sp create --id $APP_ID

# Get Service Principal Object ID
SP_OBJECT_ID=$(az ad sp list --display-name $APP_NAME --query [0].id -o tsv)

echo "Service Principal Object ID: $SP_OBJECT_ID"
```

### Step 3: Assign Azure Roles

```bash
# Assign Contributor role at subscription level
az role assignment create \
  --role "Contributor" \
  --assignee $APP_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Or assign to specific resource group
RESOURCE_GROUP="my-resource-group"
az role assignment create \
  --role "Contributor" \
  --assignee $APP_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
```

### Step 4: Configure Federated Credentials

```bash
# Set GitHub repository details
GITHUB_ORG="your-org"
GITHUB_REPO="your-repo"
GITHUB_BRANCH="main"

# Create federated credential for main branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':ref:refs/heads/'$GITHUB_BRANCH'",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions OIDC for main branch"
  }'

# Create federated credential for pull requests
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':pull_request",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions OIDC for pull requests"
  }'

# Create federated credential for environment
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-production",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':environment:production",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions OIDC for production environment"
  }'
```

### Step 5: Add Secrets to GitHub Repository

Go to GitHub Repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:
```
AZURE_CLIENT_ID: <APP_ID>
AZURE_TENANT_ID: <TENANT_ID>
AZURE_SUBSCRIPTION_ID: <SUBSCRIPTION_ID>
```

### Step 6: Create GitHub Actions Workflow

Create `.github/workflows/azure-deploy.yml`:

```yaml
name: Deploy to Azure with OIDC

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Azure Login with OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Verify Azure Login
        run: |
          az account show
          az group list --output table
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'my-web-app'
          package: '.'
      
      - name: Deploy to AKS
        run: |
          az aks get-credentials --resource-group my-rg --name my-aks-cluster
          kubectl apply -f k8s/
      
      - name: Azure Logout
        if: always()
        run: az logout
```

### Step 7: Test the Workflow

```bash
# Push to trigger workflow
git add .
git commit -m "Test OIDC authentication"
git push origin main
```

## Azure DevOps OIDC Setup

### Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│              Azure DevOps OIDC Architecture                             │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    Azure DevOps Pipeline                          │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │           azure-pipelines.yml                              │  │
│  │                                                            │  │
│  │  - task: AzureCLI@2                                       │  │
│  │    inputs:                                                │  │
│  │      azureSubscription: 'OIDC-Connection'                │  │
│  │      scriptType: 'bash'                                   │  │
│  │      scriptLocation: 'inlineScript'                       │  │
│  └────────────────────────┬───────────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────────┘
                            │
                            │ Workload Identity Federation
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  Microsoft Entra ID                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Service Connection                            │  │
│  │                                                         │  │
│  │  • Workload Identity Federation                        │  │
│  │  • Issuer: Azure DevOps                                │  │
│  │  • Subject: sc://org/project/service-connection        │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Step 1: Create App Registration

```bash
# Create App Registration for Azure DevOps
APP_NAME="azuredevops-oidc"

az ad app create --display-name $APP_NAME

APP_ID=$(az ad app list --display-name $APP_NAME --query [0].appId -o tsv)
```

### Step 2: Create Service Principal and Assign Roles

```bash
# Create Service Principal
az ad sp create --id $APP_ID

# Assign Contributor role
az role assignment create \
  --role "Contributor" \
  --assignee $APP_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### Step 3: Configure Federated Credentials for Azure DevOps

```bash
# Set Azure DevOps details
ADO_ORG="your-org"
ADO_PROJECT="your-project"
SERVICE_CONNECTION_NAME="oidc-connection"

# Create federated credential
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "azuredevops-oidc",
    "issuer": "https://vstoken.dev.azure.com/'$ADO_ORG'",
    "subject": "sc://'$ADO_ORG'/'$ADO_PROJECT'/'$SERVICE_CONNECTION_NAME'",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "Azure DevOps OIDC"
  }'
```

### Step 4: Create Service Connection in Azure DevOps

**Via Azure DevOps Portal:**

1. Go to Azure DevOps → Project Settings → Service connections
2. Click "New service connection"
3. Select "Azure Resource Manager"
4. Choose "Workload Identity federation (automatic)"
5. Fill in:
   - Subscription: Select your subscription
   - Resource Group: (optional)
   - Service connection name: `oidc-connection`
6. Click "Save"

**Via Azure CLI (Alternative):**

```bash
# Get Service Principal details
SP_OBJECT_ID=$(az ad sp list --display-name $APP_NAME --query [0].id -o tsv)

echo "Use these values in Azure DevOps:"
echo "Application (Client) ID: $APP_ID"
echo "Tenant ID: $TENANT_ID"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Service Principal Object ID: $SP_OBJECT_ID"
```

### Step 5: Create Azure Pipeline

Create `azure-pipelines.yml`:

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  azureSubscription: 'oidc-connection'  # Service connection name
  resourceGroup: 'my-resource-group'─
  webAppName: 'my-web-app'

stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - task: AzureCLI@2
            displayName: 'Verify Azure Connection'
            inputs:
              azureSubscription: $(azureSubscription)
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "Logged in to Azure"
                az account show
                az group list --output table
          
          - task: Docker@2
            displayName: 'Build Docker Image'
            inputs:─
              command: 'build'
              Dockerfile: '**/Dockerfile'
              tags: '$(Build.BuildId)'
  
  - stage: Deploy
    dependsOn: Build
    condition: succeeded()
    jobs:
      - deployment: DeployJob
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureCLI@2
                  displayName: 'Deploy to Azure'
                  inputs:
                    azureSubscription: $(azureSubscription)
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      # Deploy to Azure Web App
                      az webapp deployment source config-zip \
                        --resource-group $(resourceGroup) \
                        --name $(webAppName) \
                        --src $(Build.ArtifactStagingDirectory)/app.zip
                
                - task: AzureCLI@2
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      # Deploy to Azure Web App
                      az webapp deployment source config-zip \
                        --resource-group $(resourceGroup) \
                        --name $(webAppName) \
                        --src $(Build.ArtifactStagingDirectory)/app.zip
                
                - task: AzureCLI@2
                  displayName: 'Deploy to AKS'
                  displayName: 'Deploy to AKS'
                  inputs:
                    azureSubscription: $(azureSubscription)
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      # Get AKS credentials
                      az aks get-credentials \
                        --resource-group $(resourceGroup) \
                        --name my-aks-cluster
                      
                      # Deploy to Kubernetes
                      kubectl apply -f k8s/
```

## Jenkins OIDC Setup

### Architecture



# Get AKS credentials
az aks get-credentials \
  --resource-group $(resourceGroup) \
  --name my-aks-cluster

# Deploy to Kubernetes
kubectl apply -f k8s/

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Jenkins OIDC Architecture                           │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    Jenkins Server                             │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Jenkinsfile                                   │  │
│  │                                                         │  │
│  │  withCredentials([azureServicePrincipal(              │  │
│  │    credentialsId: 'azure-oidc',                       │  │
│  │    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',   │  │
│  │    clientIdVariable: 'AZURE_CLIENT_ID',               │  │
│  │    tenantIdVariable: 'AZURE_TENANT_ID'                │  │
│  │  )]) {                                                 │  │
│  │    sh 'az login --service-principal ...'              │  │
│  │  }                                                     │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
                            │ OIDC Token Exchange
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  Microsoft Entra ID                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           App Registration                              │  │
│  │                                                         │  │
│  │  • Federated Credentials                               │  │
│  │  • Issuer: Jenkins Server URL                          │  │
│  │  • Subject: jenkins:job:pipeline-name                  │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Step 1: Install Required Jenkins Plugins

```bash
# Install via Jenkins CLI or UI
# Required plugins:
# - Azure Credentials
# - Azure CLI
# - Pipeline
```

**Via Jenkins UI:**
1. Manage Jenkins → Plugins → Available plugins
2. Search and install:
   - Azure Credentials Plugin
   - Azure CLI Plugin
   - Pipeline Plugin

### Step 2: Create App Registration for Jenkins

```bash
# Create App Registration
APP_NAME="jenkins-oidc"

az ad app create --display-name $APP_NAME

APP_ID=$(az ad app list --display-name $APP_NAME --query [0].appId -o tsv)

# Create Service Principal
az ad sp create --id $APP_ID

# Assign role
az role assignment create \
  --role "Contributor" \
  --assignee $APP_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### Step 3: Configure Federated Credentials for Jenkins

```bash
# Set Jenkins details
JENKINS_URL="https://jenkins.example.com"
JOB_NAME="my-pipeline"

# Create federated credential
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "jenkins-oidc",
    "issuer": "'$JENKINS_URL'",
    "subject": "jenkins:job:'$JOB_NAME'",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "Jenkins OIDC for pipeline"
  }'
```

### Step 4: Configure Jenkins Credentials

**Via Jenkins UI:**

1. Go to Jenkins → Manage Jenkins → Credentials
2. Click on "(global)" domain
3. Click "Add Credentials"
4. Select "Azure Service Principal"
5. Fill in:
   - Subscription ID: `<SUBSCRIPTION_ID>`
   - Client ID: `<APP_ID>`
   - Tenant ID: `<TENANT_ID>`
   - Authentication: "Workload Identity Federation"
   - ID: `azure-oidc`
   - Description: "Azure OIDC Connection"
6. Click "OK"

### Step 5: Create Jenkins Pipeline

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        RESOURCE_GROUP = 'my-resource-group'
        WEB_APP_NAME = 'my-web-app'
    }
    
    stages {
        stage('Azure Login with OIDC') {
            steps {
                script {
                    withCredentials([azureServicePrincipal(
                        credentialsId: 'azure-oidc',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )]) {
                        sh '''
                            # Login using OIDC
                            az login --service-principal \
                              --username $AZURE_CLIENT_ID \
                              --tenant $AZURE_TENANT_ID \
                              --federated-token $(cat $AZURE_FEDERATED_TOKEN_FILE) \
                              --allow-no-subscriptions
                            
                            # Set subscription
                            az account set --subscription $AZURE_SUBSCRIPTION_ID
                            
                            # Verify login
                            az account show
                        '''
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    echo "Building application..."
                    docker build -t myapp:${BUILD_NUMBER} .
                '''
            }
        }
        
        stage('Deploy to Azure') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure-oidc')]) {
                        sh '''
                            # Deploy to Azure Web App
                            az webapp deployment source config-zip \
                              --resource-group $RESOURCE_GROUP \
                              --name $WEB_APP_NAME \
                              --src app.zip
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure-oidc')]) {
                        sh '''
                            # Get AKS credentials
                            az aks get-credentials \
                              --resource-group $RESOURCE_GROUP \
                              --name my-aks-cluster \
                              --overwrite-existing
                            
                            # Deploy to Kubernetes
                            kubectl apply -f k8s/
                            
                            # Verify deployment
                            kubectl rollout status deployment/myapp
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'az logout || true'
        }
    }
}
```

### Alternative: Using Azure CLI Plugin

```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy with Azure CLI') {
            steps {
                azureCLI(
                    credentialsId: 'azure-oidc',
                    subscriptionId: env.AZURE_SUBSCRIPTION_ID
                ) {
                    sh '''
                        az group list --output table
                        az webapp list --output table
                    '''
                }
            }
        }
    }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "AADSTS700016: Application not found"

```
Problem: App Registration doesn't exist or wrong Client ID

Solution:
# Verify App Registration exists
az ad app list --display-name "your-app-name"

# Check Client ID
az ad app show --id <APP_ID>
```

#### 2. "AADSTS70021: No matching federated identity record found"

```
Problem: Federated credential subject doesn't match

Solution:
# List federated credentials
az ad app federated-credential list --id <APP_ID>

# Verify subject matches exactly
# GitHub: repo:org/repo:ref:refs/heads/main
# Azure DevOps: sc://org/project/connection-name
# Jenkins: jenkins:job:pipeline-name
```

#### 3. "Insufficient privileges to complete the operation"

```
Problem: Service Principal doesn't have required permissions

Solution:
# Check role assignments
az role assignment list --assignee <APP_ID> --output table

# Assign required role
az role assignment create \
  --role "Contributor" \
  --assignee <APP_ID> \
  --scope "/subscriptions/<SUBSCRIPTION_ID>"
```

#### 4. GitHub Actions: "Error: Login failed with Error: OIDC token not found"

```
Problem: Missing permissions in workflow

Solution:
# Add to workflow YAML
permissions:
  id-token: write  # Required for OIDC
  contents: read
```

#### 5. Azure DevOps: "Service connection authorization failed"

```
Problem: Service connection not properly configured

Solution:
1. Delete and recreate service connection
2. Ensure "Workload Identity federation" is selected
3. Verify App Registration has correct federated credential
4. Check issuer URL matches: https://vstoken.dev.azure.com/<ORG>
```

#### 6. Jenkins: "Failed to obtain access token"

```
Problem: Jenkins URL doesn't match issuer in federated credential

Solution:
# Update federated credential with correct Jenkins URL
az ad app federated-credential update \
  --id <APP_ID> \
  --federated-credential-id <CRED_ID> \
  --parameters '{
    "issuer": "https://your-jenkins-url.com"
  }'
```

### Debugging Commands

```bash
# Check App Registration
az ad app show --id <APP_ID>

# List federated credentials
az ad app federated-credential list --id <APP_ID> --output table

# Check Service Principal
az ad sp show --id <APP_ID>

# List role assignments
az role assignment list --assignee <APP_ID> --output table

# Test Azure CLI login (for debugging)
az login --service-principal \
  --username <APP_ID> \
  --tenant <TENANT_ID> \
  --federated-token <TOKEN> \
  --allow-no-subscriptions
```

### Verification Checklist

```
✅ App Registration created
✅ Service Principal created
✅ Federated credentials configured with correct:
   - Issuer
   - Subject
   - Audience
✅ Role assignments in place
✅ CI/CD platform configured with:
   - Client ID
   - Tenant ID
   - Subscription ID
✅ Workflow/Pipeline has correct permissions
✅ Test deployment successful
```

## Security Best Practices

1. **Principle of Least Privilege**
   - Assign only required roles
   - Use resource group scope instead of subscription
   - Create separate App Registrations for different environments

2. **Subject Claim Restrictions**
   - Use specific branches: `repo:org/repo:ref:refs/heads/main`
   - Use environments: `repo:org/repo:environment:production`
   - Avoid wildcards in subject claims

3. **Monitoring and Auditing**
   - Enable Azure AD sign-in logs
   - Monitor service principal activity
   - Set up alerts for unusual access patterns

4. **Credential Rotation**
   - OIDC tokens are short-lived (automatic rotation)
   - No manual secret rotation needed
   - Review and update federated credentials periodically

5. **Conditional Access**
   - Apply conditional access policies to service principals
   - Restrict access by IP range if possible
   - Require MFA for administrative changes

## Comparison: OIDC vs Service Principal with Secret

```
┌─────────────────────────────────────────────────────────────────┐
│                    Feature Comparison                            │
└─────────────────────────────────────────────────────────────────┘

Feature                  │ OIDC              │ Service Principal
─────────────────────────┼───────────────────┼──────────────────
Secret Storage           │ ✅ None           │ ❌ Required
Token Lifetime           │ ✅ Short (1 hour) │ ❌ Long (1-2 years)
Rotation                 │ ✅ Automatic      │ ❌ Manual
Security Risk            │ ✅ Low            │ ❌ Higher
Setup Complexity         │ ⚠️  Medium        │ ✅ Simple
Audit Trail              │ ✅ Detailed       │ ⚠️  Basic
Conditional Access       │ ✅ Supported      │ ⚠️  Limited
Cost                     │ ✅ Free           │ ✅ Free
```

## Additional Resources

- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/azure/active-directory/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure DevOps Workload Identity](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure)
- [Jenkins Azure Credentials Plugin](https://plugins.jenkins.io/azure-credentials/)
