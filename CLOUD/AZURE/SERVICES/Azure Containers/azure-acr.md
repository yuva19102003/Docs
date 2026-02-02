# 🐳 Azure Container Registry (ACR) – Complete End-to-End Tutorial

## 📋 Table of Contents
1. [Overview](#overview)
2. [ACR Architecture](#acr-architecture)
3. [Service Tiers](#service-tiers)
4. [Prerequisites](#prerequisites)
5. [Creating ACR via Azure Portal](#creating-acr-via-azure-portal)
6. [Creating ACR via Azure CLI](#creating-acr-via-azure-cli)
7. [Creating ACR via Terraform](#creating-acr-via-terraform)
8. [Authentication Methods](#authentication-methods)
9. [Push & Pull Images](#push--pull-images)
10. [ACR Tasks](#acr-tasks)
11. [Geo-Replication](#geo-replication)
12. [Security & Access Control](#security--access-control)
13. [Integration with AKS](#integration-with-aks)
14. [Best Practices](#best-practices)

---

## 📖 Overview

**Azure Container Registry (ACR)** is a managed Docker registry service based on the open-source Docker Registry 2.0. It allows you to store and manage container images and artifacts in a private registry for all types of container deployments.

### Key Features
- **Private Docker Registry**: Store container images securely
- **Geo-Replication**: Replicate images across multiple Azure regions
- **ACR Tasks**: Build, test, and patch container images in Azure
- **Security**: Integration with Azure AD, RBAC, and private endpoints
- **Webhook Support**: Trigger events on image push/delete
- **Content Trust**: Sign and verify images
- **Vulnerability Scanning**: Integrated security scanning

### Use Cases
- Store images for Azure Kubernetes Service (AKS)
- CI/CD pipelines with Azure DevOps, GitHub Actions
- Multi-region deployments with geo-replication
- Artifact storage for Helm charts, OCI artifacts

---

## 🏗️ ACR Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Container Registry                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Repository  │  │  Repository  │  │  Repository  │      │
│  │   app-web    │  │   app-api    │  │   app-db     │      │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤      │
│  │ v1.0.0       │  │ v2.1.0       │  │ latest       │      │
│  │ v1.0.1       │  │ v2.1.1       │  │ v5.7         │      │
│  │ latest       │  │ latest       │  └──────────────┘      │
│  └──────────────┘  └──────────────┘                         │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│                    Security & Access                         │
│  • Azure AD Authentication                                   │
│  • Service Principal / Managed Identity                      │
│  • RBAC (Role-Based Access Control)                         │
│  • Private Endpoints / Firewall Rules                        │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────┐         ┌─────────┐         ┌─────────┐
    │   AKS   │         │  Docker │         │ CI/CD   │
    │ Cluster │         │  Client │         │Pipeline │
    └─────────┘         └─────────┘         └─────────┘
```

---

## 💰 Service Tiers

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| **Storage** | 10 GB | 100 GB | 500 GB |
| **Throughput** | Low | Medium | High |
| **Geo-Replication** | ❌ | ❌ | ✅ |
| **Content Trust** | ❌ | ❌ | ✅ |
| **Private Link** | ❌ | ❌ | ✅ |
| **Webhooks** | 2 | 10 | 500 |
| **Use Case** | Dev/Test | Production | Enterprise |

---

## ✅ Prerequisites

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Install Docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 🌐 Creating ACR via Azure Portal

### Step 1: Navigate to Container Registries
1. Go to Azure Portal → Search "Container Registries"
2. Click **+ Create**

### Step 2: Configure Basic Settings
- **Subscription**: Select your subscription
- **Resource Group**: Create new or select existing
- **Registry Name**: `myacrregistry` (must be globally unique)
- **Location**: `East US`
- **SKU**: `Standard` or `Premium`

### Step 3: Networking (Optional)
- **Public Access**: Enable/Disable
- **Private Endpoint**: Configure if needed

### Step 4: Review + Create
- Click **Create** and wait for deployment

---

## 💻 Creating ACR via Azure CLI

### Basic ACR Creation
```bash
# Variables
RESOURCE_GROUP="rg-acr-demo"
LOCATION="eastus"
ACR_NAME="myacrregistry2024"  # Must be globally unique
SKU="Standard"  # Basic, Standard, or Premium

# Create Resource Group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku $SKU \
  --location $LOCATION

# Enable Admin User (for testing only)
az acr update \
  --name $ACR_NAME \
  --admin-enabled true

# Get ACR Login Server
az acr show \
  --name $ACR_NAME \
  --query loginServer \
  --output tsv
```

### Premium ACR with Geo-Replication
```bash
# Create Premium ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Premium \
  --location eastus

# Add Geo-Replication
az acr replication create \
  --registry $ACR_NAME \
  --location westus

az acr replication create \
  --registry $ACR_NAME \
  --location westeurope
```

---

## 🔧 Creating ACR via Terraform

### Complete Terraform Configuration

#### 1. Provider Configuration (`provider.tf`)
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

#### 2. Variables (`variables.tf`)
```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-acr-terraform"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "myacrtf2024"
}

variable "acr_sku" {
  description = "SKU for ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "geo_replication_locations" {
  description = "List of locations for geo-replication"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

#### 3. Main Configuration (`main.tf`)
```hcl
# Resource Group
resource "azurerm_resource_group" "acr_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled

  # Public network access
  public_network_access_enabled = true

  # Network rule set (Premium only)
  dynamic "network_rule_set" {
    for_each = var.acr_sku == "Premium" ? [1] : []
    content {
      default_action = "Allow"
    }
  }

  # Geo-replication (Premium only)
  dynamic "georeplications" {
    for_each = var.acr_sku == "Premium" ? var.geo_replication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }

  tags = var.tags
}

# Diagnostic Settings (Optional)
resource "azurerm_monitor_diagnostic_setting" "acr_diagnostics" {
  name                       = "acr-diagnostics"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.acr_logs.id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "acr_logs" {
  name                = "${var.acr_name}-logs"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
```

#### 4. Advanced Configuration with RBAC (`acr-advanced.tf`)
```hcl
# Service Principal for ACR
data "azurerm_client_config" "current" {}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "acr_identity" {
  name                = "${var.acr_name}-identity"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  tags                = var.tags
}

# Role Assignment - AcrPull
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_identity.principal_id
}

# Role Assignment - AcrPush
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.acr_identity.principal_id
}

# Private Endpoint (Premium only)
resource "azurerm_private_endpoint" "acr_pe" {
  count               = var.acr_sku == "Premium" ? 1 : 0
  name                = "${var.acr_name}-pe"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  subnet_id           = azurerm_subnet.acr_subnet[0].id

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Virtual Network for Private Endpoint
resource "azurerm_virtual_network" "acr_vnet" {
  count               = var.acr_sku == "Premium" ? 1 : 0
  name                = "${var.acr_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "acr_subnet" {
  count                = var.acr_sku == "Premium" ? 1 : 0
  name                 = "acr-subnet"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.acr_vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Webhook for CI/CD
resource "azurerm_container_registry_webhook" "acr_webhook" {
  name                = "acrwebhook"
  resource_group_name = azurerm_resource_group.acr_rg.name
  registry_name       = azurerm_container_registry.acr.name
  location            = azurerm_resource_group.acr_rg.location

  service_uri = "https://myapp.example.com/webhook"
  status      = "enabled"
  scope       = "myapp:*"
  actions     = ["push", "delete"]

  custom_headers = {
    "Content-Type" = "application/json"
  }
}
```

#### 5. Outputs (`outputs.tf`)
```hcl
output "acr_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "acr_admin_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}

output "managed_identity_id" {
  description = "The ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.acr_identity.id
}

output "managed_identity_client_id" {
  description = "The Client ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.acr_identity.client_id
}
```

#### 6. Terraform Variables File (`terraform.tfvars`)
```hcl
# Basic Configuration
resource_group_name = "rg-acr-production"
location            = "eastus"
acr_name            = "mycompanyacr2024"
acr_sku             = "Premium"
admin_enabled       = false

# Geo-Replication (Premium only)
geo_replication_locations = [
  "westus",
  "westeurope"
]

# Tags
tags = {
  Environment = "Production"
  Project     = "ContainerRegistry"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
```

#### 7. Deploy with Terraform
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan

# Get outputs
terraform output acr_login_server
terraform output -json
```

---

## 🔐 Authentication Methods

### 1. Azure CLI Authentication
```bash
# Login to ACR
az acr login --name $ACR_NAME

# Alternative: Get access token
TOKEN=$(az acr login --name $ACR_NAME --expose-token --output tsv --query accessToken)
echo $TOKEN | docker login $ACR_NAME.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin
```

### 2. Service Principal Authentication
```bash
# Create Service Principal
SP_NAME="acr-service-principal"
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

SP_PASSWD=$(az ad sp create-for-rbac \
  --name $SP_NAME \
  --scopes $ACR_REGISTRY_ID \
  --role acrpull \
  --query password \
  --output tsv)

SP_APP_ID=$(az ad sp list \
  --display-name $SP_NAME \
  --query [].appId \
  --output tsv)

# Docker login with Service Principal
docker login $ACR_NAME.azurecr.io \
  --username $SP_APP_ID \
  --password $SP_PASSWD
```

### 3. Managed Identity Authentication
```bash
# Assign AcrPull role to Managed Identity
IDENTITY_ID="/subscriptions/xxx/resourcegroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"

az role assignment create \
  --assignee $IDENTITY_ID \
  --scope $ACR_REGISTRY_ID \
  --role acrpull
```

### 4. Admin User Authentication (Not Recommended for Production)
```bash
# Get admin credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# Docker login
docker login $ACR_NAME.azurecr.io \
  --username $ACR_USERNAME \
  --password $ACR_PASSWORD
```

---

## 📦 Push & Pull Images

### Build and Push Image
```bash
# Set variables
ACR_NAME="myacrregistry2024"
IMAGE_NAME="myapp"
IMAGE_TAG="v1.0.0"

# Build Docker image
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Tag image for ACR
docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# Push to ACR
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# List images in ACR
az acr repository list --name $ACR_NAME --output table

# Show tags for a repository
az acr repository show-tags --name $ACR_NAME --repository $IMAGE_NAME --output table
```

### Pull Image from ACR
```bash
# Pull image
docker pull $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# Run container
docker run -d -p 8080:80 $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG
```

### ACR Build (Build in Cloud)
```bash
# Build image in ACR without local Docker
az acr build \
  --registry $ACR_NAME \
  --image myapp:v1.0.0 \
  --file Dockerfile \
  .

# Build with build arguments
az acr build \
  --registry $ACR_NAME \
  --image myapp:v1.0.0 \
  --build-arg NODE_VERSION=18 \
  --file Dockerfile \
  .
```

---

## ⚙️ ACR Tasks

### Quick Task (One-time build)
```bash
# Build and push in one command
az acr build \
  --registry $ACR_NAME \
  --image myapp:{{.Run.ID}} \
  --file Dockerfile \
  https://github.com/username/repo.git
```

### Automated Task (Triggered builds)
```bash
# Create task triggered by Git commit
az acr task create \
  --registry $ACR_NAME \
  --name buildtask \
  --image myapp:{{.Run.ID}} \
  --context https://github.com/username/repo.git \
  --file Dockerfile \
  --git-access-token $GITHUB_TOKEN

# Create task triggered by base image update
az acr task create \
  --registry $ACR_NAME \
  --name basetask \
  --image myapp:{{.Run.ID}} \
  --context https://github.com/username/repo.git \
  --file Dockerfile \
  --base-image-trigger-enabled true

# Run task manually
az acr task run --registry $ACR_NAME --name buildtask

# List tasks
az acr task list --registry $ACR_NAME --output table

# Show task runs
az acr task list-runs --registry $ACR_NAME --output table
```

### Multi-Step Task
```yaml
# acr-task.yaml
version: v1.1.0
steps:
  # Build image
  - build: -t {{.Run.Registry}}/myapp:{{.Run.ID}} .
  
  # Run tests
  - cmd: {{.Run.Registry}}/myapp:{{.Run.ID}}
    env:
      - TEST_MODE=true
  
  # Push if tests pass
  - push: 
    - {{.Run.Registry}}/myapp:{{.Run.ID}}
    - {{.Run.Registry}}/myapp:latest
```

```bash
# Create multi-step task
az acr task create \
  --registry $ACR_NAME \
  --name multisteptask \
  --context https://github.com/username/repo.git \
  --file acr-task.yaml \
  --git-access-token $GITHUB_TOKEN
```

---

## 🌍 Geo-Replication

### Enable Geo-Replication (Premium SKU Required)
```bash
# Add replication to West US
az acr replication create \
  --registry $ACR_NAME \
  --location westus

# Add replication to West Europe
az acr replication create \
  --registry $ACR_NAME \
  --location westeurope

# List replications
az acr replication list \
  --registry $ACR_NAME \
  --output table

# Delete replication
az acr replication delete \
  --registry $ACR_NAME \
  --location westus
```

### Terraform Geo-Replication
```hcl
resource "azurerm_container_registry" "acr" {
  name                = "myacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"
  sku                 = "Premium"

  georeplications {
    location                = "westus"
    zone_redundancy_enabled = true
    tags                    = var.tags
  }

  georeplications {
    location                = "westeurope"
    zone_redundancy_enabled = true
    tags                    = var.tags
  }
}
```

---

## 🔒 Security & Access Control

### Network Security
```bash
# Disable public access (Premium only)
az acr update \
  --name $ACR_NAME \
  --public-network-enabled false

# Add firewall rule
az acr network-rule add \
  --name $ACR_NAME \
  --ip-address 203.0.113.0/24

# List network rules
az acr network-rule list --name $ACR_NAME
```

### RBAC Roles
```bash
# Assign AcrPull role (read-only)
az role assignment create \
  --assignee user@example.com \
  --role AcrPull \
  --scope $ACR_REGISTRY_ID

# Assign AcrPush role (read-write)
az role assignment create \
  --assignee user@example.com \
  --role AcrPush \
  --scope $ACR_REGISTRY_ID

# Assign AcrDelete role
az role assignment create \
  --assignee user@example.com \
  --role AcrDelete \
  --scope $ACR_REGISTRY_ID
```

### Content Trust (Image Signing)
```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://$ACR_NAME.azurecr.io

# Push signed image
docker push $ACR_NAME.azurecr.io/myapp:v1.0.0
```

---

## ☸️ Integration with AKS

### Attach ACR to AKS
```bash
AKS_NAME="myakscluster"
AKS_RG="rg-aks"

# Attach ACR to AKS
az aks update \
  --name $AKS_NAME \
  --resource-group $AKS_RG \
  --attach-acr $ACR_NAME

# Verify integration
az aks check-acr \
  --name $AKS_NAME \
  --resource-group $AKS_RG \
  --acr $ACR_NAME.azurecr.io
```

### Terraform AKS + ACR Integration
```hcl
# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myakscluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
```

### Deploy to AKS from ACR
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myacrregistry2024.azurecr.io/myapp:v1.0.0
        ports:
        - containerPort: 80
```

```bash
# Apply deployment
kubectl apply -f deployment.yaml

# Verify pods
kubectl get pods
```

---

## 🎯 Best Practices

### 1. Security
- ✅ Use Managed Identities instead of admin credentials
- ✅ Enable Azure AD authentication
- ✅ Use Private Endpoints for production
- ✅ Enable Content Trust for image signing
- ✅ Implement RBAC with least privilege
- ✅ Enable vulnerability scanning
- ✅ Use firewall rules to restrict access

### 2. Image Management
- ✅ Use semantic versioning for tags
- ✅ Implement image retention policies
- ✅ Use multi-stage builds to reduce image size
- ✅ Scan images for vulnerabilities
- ✅ Tag images with commit SHA for traceability

### 3. Performance
- ✅ Use Premium SKU for production workloads
- ✅ Enable geo-replication for global deployments
- ✅ Use ACR Tasks for automated builds
- ✅ Implement caching strategies

### 4. Cost Optimization
- ✅ Use appropriate SKU for your needs
- ✅ Implement image cleanup policies
- ✅ Monitor storage usage
- ✅ Delete unused images and tags

### 5. Monitoring
- ✅ Enable diagnostic logs
- ✅ Set up alerts for failed pushes/pulls
- ✅ Monitor storage metrics
- ✅ Track authentication failures

---

## 📊 Monitoring & Diagnostics

### Enable Diagnostics
```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name acr-logs

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name acr-logs \
  --query id \
  --output tsv)

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name acr-diagnostics \
  --resource $ACR_REGISTRY_ID \
  --workspace $WORKSPACE_ID \
  --logs '[{"category": "ContainerRegistryRepositoryEvents", "enabled": true}, {"category": "ContainerRegistryLoginEvents", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### Query Logs
```kusto
// Failed login attempts
ContainerRegistryLoginEvents
| where ResultType == "Failed"
| project TimeGenerated, Identity, LoginServer, ResultDescription

// Image push events
ContainerRegistryRepositoryEvents
| where OperationName == "Push"
| project TimeGenerated, Repository, Tag, Identity
```

---

## 🧹 Cleanup & Maintenance

### Delete Old Images
```bash
# Delete specific tag
az acr repository delete \
  --name $ACR_NAME \
  --image myapp:v1.0.0 \
  --yes

# Delete all tags older than 30 days
az acr repository show-tags \
  --name $ACR_NAME \
  --repository myapp \
  --orderby time_asc \
  --query "[?lastUpdateTime < '$(date -d '30 days ago' -Iseconds)'].name" \
  --output tsv | xargs -I {} az acr repository delete \
  --name $ACR_NAME \
  --image myapp:{} \
  --yes
```

### Retention Policy (Premium only)
```bash
# Set retention policy
az acr config retention update \
  --registry $ACR_NAME \
  --status enabled \
  --days 30 \
  --type UntaggedManifests
```

### Terraform Cleanup
```bash
# Destroy all resources
terraform destroy -auto-approve
```

---

## 📚 Complete Example: CI/CD with GitHub Actions

### GitHub Actions Workflow
```yaml
# .github/workflows/build-push-acr.yml
name: Build and Push to ACR

on:
  push:
    branches: [ main ]

env:
  ACR_NAME: myacrregistry2024
  IMAGE_NAME: myapp

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Build and push image
      run: |
        az acr build \
          --registry ${{ env.ACR_NAME }} \
          --image ${{ env.IMAGE_NAME }}:${{ github.sha }} \
          --image ${{ env.IMAGE_NAME }}:latest \
          --file Dockerfile \
          .
    
    - name: Deploy to AKS
      uses: azure/k8s-deploy@v4
      with:
        manifests: |
          k8s/deployment.yaml
        images: |
          ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

---

## 🎓 Summary

Azure Container Registry provides a robust, secure, and scalable solution for managing container images. Key takeaways:

- **Choose the right SKU**: Basic for dev/test, Premium for production
- **Security first**: Use Managed Identities and Private Endpoints
- **Automate**: Leverage ACR Tasks for CI/CD
- **Scale globally**: Use geo-replication for multi-region deployments
- **Monitor**: Enable diagnostics and set up alerts
- **Integrate**: Seamlessly connect with AKS and other Azure services

With Terraform, you can manage ACR infrastructure as code, ensuring consistency and repeatability across environments.
