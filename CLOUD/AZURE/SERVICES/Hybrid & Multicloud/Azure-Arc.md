# 🌐 **Azure Arc**

## 🔹 What is Azure Arc?

**Azure Arc** is a bridge that extends Azure management and services to **on-premises**, **multi-cloud**, and **edge** environments.

### Key Benefits:

- Centralized governance and compliance
    
- Azure services (like Azure Monitor, Policy, Defender) on non-Azure resources
    
- Kubernetes and server management outside Azure
    
- Enables GitOps with Azure Kubernetes Service (AKS)
    

---

## 🧩 Components of Azure Arc

|Component|Description|
|---|---|
|**Arc-enabled Servers**|Manage Windows/Linux machines outside Azure|
|**Arc-enabled Kubernetes**|Manage k8s clusters on-premises or other clouds|
|**Arc-enabled SQL Server**|Run Azure data services on-prem or multi-cloud|
|**Azure Arc Data Services**|Deploy Azure SQL MI and PostgreSQL Hyperscale anywhere|

---

## 🧰 Prerequisites

- Azure subscription
    
- Azure CLI installed
    
- Azure Arc extension:
    
    ```bash
    az extension add --name connectedmachine
    ```
    
- For Kubernetes:
    
    ```bash
    az extension add --name k8s-extension
    az extension add --name k8s-configuration
    ```
    

---

## 🖥️ Arc-enabled Servers Setup (Linux Example)

### 1. **Register resource provider**

```bash
az provider register --namespace 'Microsoft.HybridCompute'
az provider register --namespace 'Microsoft.GuestConfiguration'
```

### 2. **Create a Resource Group**

```bash
az group create --name Arc-Infra --location eastus
```

### 3. **Download and install the agent**

```bash
wget https://aka.ms/azcmagent
chmod +x azcmagent
sudo ./azcmagent connect \
  --resource-group Arc-Infra \
  --tenant-id <your-tenant-id> \
  --location eastus \
  --subscription-id <your-subscription-id> \
  --resource-name my-linux \
  --tags "env=dev" "os=linux"
```

To check:

```bash
azcmagent show
```

---

## ☸️ Arc-enabled Kubernetes Cluster

### 1. Connect a Kubernetes cluster to Azure Arc

Install `kubectl`, `helm`, and ensure kubeconfig is set.

```bash
az connectedk8s connect \
  --name arc-k8s-cluster \
  --resource-group Arc-Infra
```

Verify connection:

```bash
az connectedk8s list -g Arc-Infra
```

### 2. Enable GitOps (optional)

```bash
az k8s-configuration flux create \
  --cluster-name arc-k8s-cluster \
  --resource-group Arc-Infra \
  --cluster-type connectedClusters \
  --name arc-gitops-config \
  --scope cluster \
  --namespace default \
  --url https://github.com/<your-repo> \
  --branch main \
  --sync-interval 60s \
  --kustomization name=infra path=./manifests prune=true
```

---

## 📦 Arc with Terraform

### Example: Register an Arc-enabled server (requires agent pre-installed)

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "arc" {
  name     = "Arc-Infra"
  location = "East US"
}
```

For Kubernetes, use the [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) with extensions (still better for AKS).

---

## 🔐 Azure Policy with Arc

You can apply policies to non-Azure resources:

```bash
az policy assignment create \
  --name "audit-linux-password" \
  --policy "EnableLinuxPasswordAudit" \
  --scope "/subscriptions/<sub-id>/resourceGroups/Arc-Infra"
```

View compliance in Azure Policy dashboard.

---

## 🔎 Monitoring Arc-enabled Resources

1. **Azure Monitor Agent**
    
    - Install on Arc server to collect metrics/logs.
        
    - Use `Log Analytics` workspace.
        
2. **Azure Defender for Servers**
    
    - Works on Arc machines with agent.
        
3. **Kubernetes Monitoring**
    
    - Enable Insights:
        
        ```bash
        az k8s-extension create \
          --name azuremonitor-containers \
          --cluster-name arc-k8s-cluster \
          --resource-group Arc-Infra \
          --cluster-type connectedClusters \
          --extension-type Microsoft.AzureMonitor.Containers
        ```
        

---

## ⚙️ YAML Example for GitOps via Flux v2

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: infra-repo
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/your-org/infra
  branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: infra-kustomize
  namespace: flux-system
spec:
  interval: 5m
  path: "./"
  prune: true
  sourceRef:
    kind: GitRepository
    name: infra-repo
```

---

## 🚀 Use Cases of Azure Arc

|Use Case|Description|
|---|---|
|**Hybrid cloud management**|Manage on-prem, AWS, GCP resources in Azure|
|**Policy enforcement**|Apply Azure policies to any infrastructure|
|**DevOps with GitOps**|Git-based deployments for any K8s clusters|
|**Run Azure SQL Anywhere**|Azure SQL MI in disconnected or edge environments|
|**Monitoring and Security**|Use Defender and Monitor on Arc-connected systems|

---

## 🆚 Azure Arc vs AWS Control Tower

|Feature / Area|**Azure Arc**|**AWS Control Tower**|
|---|---|---|
|**Primary Focus**|Manage and govern **non-Azure resources** (on-prem, multi-cloud)|Govern **multi-account AWS environments**|
|**Scope**|Hybrid & multi-cloud (Linux/Windows servers, K8s clusters, SQL DBs)|AWS-only (multi-account landing zones, guardrails, governance)|
|**Cross-cloud/On-prem support**|✅ Yes – for VMs, K8s, SQL in AWS, GCP, on-prem, edge|❌ No – only AWS accounts and regions|
|**Multi-account setup**|❌ Not designed for managing Azure subscriptions/accounts|✅ Yes – automates account setup, SCPs, org units|
|**Governance & Policy**|✅ Azure Policy across hybrid and multi-cloud resources|✅ Service Control Policies (SCPs), AWS Config, AWS Organizations|
|**Monitoring**|✅ Azure Monitor, Defender for Cloud on Arc-connected systems|✅ CloudWatch + AWS Config (only for AWS resources)|
|**Security & Compliance**|✅ Defender for Cloud (hybrid)|✅ Preconfigured Guardrails (via SCPs, AWS Config rules)|
|**GitOps & K8s Integration**|✅ FluxCD GitOps + K8s management (Arc-enabled K8s)|❌ No GitOps; only works with AWS-native services|
|**Custom Locations / vCenter**|✅ Supports vCenter, Azure Stack, bare-metal servers|❌ Not supported|
|**Agent-based Resource Management**|✅ Agent installs on VMs to onboard them to Azure|❌ N/A – AWS-native accounts only|

---

## 🔄 Summary Table

|Category|**Azure Arc**|**AWS Control Tower**|Winner|
|---|---|---|---|
|Hybrid/multi-cloud|✅ Yes|❌ No|🏆 Azure Arc|
|Multi-account AWS Mgmt|❌ No|✅ Yes|🏆 AWS Control Tower|
|GitOps/K8s Integration|✅ Full support|❌ None|🏆 Azure Arc|
|Policy Compliance|✅ Azure Policy on all environments|✅ AWS Config & SCPs|🎯 Tie|
|Monitoring/Security|✅ Defender for Cloud + Log Analytics|✅ CloudWatch + GuardDuty|🎯 Tie|

---

## 🔧 Real-World Use Case Comparison

|Scenario|Use Azure Arc?|Use AWS Control Tower?|
|---|---|---|
|Manage Linux VMs on-prem and in GCP|✅ Yes|❌ No|
|Manage all AWS accounts under one policy/compliance model|❌ No|✅ Yes|
|Connect EKS cluster to Azure Monitor and GitOps pipeline|✅ Yes|❌ No|
|Enforce governance on Azure, AWS, and edge Kubernetes clusters|✅ Yes|❌ No|
|Provision new AWS accounts with baseline guardrails|❌ No|✅ Yes|

---

## 🔁 TL;DR

|Service|What it Does Best|
|---|---|
|**Azure Arc**|Manages **non-Azure** servers, Kubernetes, SQL, hybrid infra|
|**AWS Control Tower**|Manages **multiple AWS accounts** with governance, SCPs, guardrails|

🧠 Think of it this way:

- **Azure Arc** = "Manage _any infrastructure_ from Azure"
    
- **AWS Control Tower** = "Govern _many AWS accounts_ with best practices"
    

---
