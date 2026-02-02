# Azure Kubernetes Service (AKS)

## Overview

Azure Kubernetes Service (AKS) is a managed Kubernetes service that simplifies deploying, managing, and scaling containerized applications using Kubernetes on Azure.

## Key Features

- **Managed Control Plane:** Azure manages the Kubernetes control plane (API server, etcd, scheduler)
- **Automatic Updates:** Automated Kubernetes version upgrades
- **Scaling:** Horizontal pod autoscaling and cluster autoscaling
- **Integrated Monitoring:** Azure Monitor Container Insights
- **Security:** Azure AD integration, RBAC, network policies
- **Developer Tools:** Integration with Azure DevOps, GitHub Actions, VS Code

## Create AKS Cluster

### Basic Cluster

```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --enable-managed-identity \
  --generate-ssh-keys
```

### Production Cluster

```bash
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --node-vm-size Standard_DS3_v2 \
  --enable-managed-identity \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10 \
  --network-plugin azure \
  --network-policy azure \
  --enable-addons monitoring \
  --workspace-resource-id /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace} \
  --enable-aad \
  --enable-azure-rbac \
  --attach-acr /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name} \
  --zones 1 2 3 \
  --generate-ssh-keys
```

### ARM Template

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-07-01",
  "name": "myAKSCluster",
  "location": "eastus",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "kubernetesVersion": "1.28.3",
    "dnsPrefix": "myakscluster",
    "agentPoolProfiles": [
      {
        "name": "nodepool1",
        "count": 3,
        "vmSize": "Standard_DS2_v2",
        "mode": "System",
        "enableAutoScaling": true,
        "minCount": 3,
        "maxCount": 10,
        "availabilityZones": ["1", "2", "3"]
      }
    ],
    "networkProfile": {
      "networkPlugin": "azure",
      "networkPolicy": "azure",
      "serviceCidr": "10.0.0.0/16",
      "dnsServiceIP": "10.0.0.10"
    },
    "aadProfile": {
      "managed": true,
      "enableAzureRBAC": true
    },
    "addonProfiles": {
      "omsagent": {
        "enabled": true,
        "config": {
          "logAnalyticsWorkspaceResourceID": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
        }
      }
    }
  }
}
```

## Connect to Cluster

### Get Credentials

```bash
# Get cluster credentials
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster

# Get admin credentials (bypass Azure AD)
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --admin

# Verify connection
kubectl get nodes
```

### Azure AD Authentication

```bash
# Login with Azure AD
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster

# Get access token
kubectl get nodes
# This will prompt for Azure AD authentication
```

## Node Pools

### Add Node Pool

```bash
# Add user node pool
az aks nodepool add \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name userpool \
  --node-count 3 \
  --node-vm-size Standard_DS3_v2 \
  --mode User \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10 \
  --zones 1 2 3

# Add spot instance node pool
az aks nodepool add \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name spotpool \
  --priority Spot \
  --eviction-policy Delete \
  --spot-max-price -1 \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --mode User
```

### Manage Node Pools

```bash
# List node pools
az aks nodepool list \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster -o table

# Scale node pool
az aks nodepool scale \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name userpool \
  --node-count 5

# Update node pool
az aks nodepool update \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name userpool \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10

# Delete node pool
az aks nodepool delete \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name userpool
```

### Node Pool with Taints

```bash
az aks nodepool add \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name gpupool \
  --node-count 2 \
  --node-vm-size Standard_NC6 \
  --node-taints sku=gpu:NoSchedule \
  --labels workload=gpu
```

## Networking

### Network Plugins

**Kubenet (Basic):**
- Default networking
- Nodes get IP from Azure VNet
- Pods get IP from separate address space
- NAT for pod traffic

**Azure CNI (Advanced):**
- Pods get IP from Azure VNet
- Direct connectivity to pods
- Better integration with Azure services
- Requires more IP addresses

### Create with Azure CNI

```bash
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --network-plugin azure \
  --vnet-subnet-id /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet} \
  --service-cidr 10.0.0.0/16 \
  --dns-service-ip 10.0.0.10 \
  --docker-bridge-address 172.17.0.1/16
```

### Network Policies

```bash
# Enable Azure Network Policy
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --network-plugin azure \
  --network-policy azure

# Enable Calico Network Policy
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --network-plugin azure \
  --network-policy calico
```

### Ingress Controller

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Or using Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

## Storage

### Storage Classes

```yaml
# Azure Disk Storage Class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-premium
provisioner: disk.csi.azure.com
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

```yaml
# Azure Files Storage Class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile
provisioner: file.csi.azure.com
parameters:
  skuName: Standard_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```

### Persistent Volume Claim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-disk-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-premium
  resources:
    requests:
      storage: 10Gi
```

## Security

### Azure AD Integration

```bash
# Enable Azure AD integration
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --enable-aad \
  --enable-azure-rbac
```

### RBAC Configuration

```bash
# Grant cluster admin role
az role assignment create \
  --assignee user@example.com \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerService/managedClusters/{cluster}

# Grant cluster user role
az role assignment create \
  --assignee user@example.com \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerService/managedClusters/{cluster}
```

### Pod Security

```yaml
# Pod Security Policy (deprecated, use Pod Security Standards)
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

### Secrets Management

```bash
# Enable Azure Key Vault Provider for Secrets Store CSI Driver
az aks enable-addons \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --addons azure-keyvault-secrets-provider
```

```yaml
# SecretProviderClass
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "{client-id}"
    keyvaultName: "{keyvault-name}"
    objects: |
      array:
        - |
          objectName: secret1
          objectType: secret
    tenantId: "{tenant-id}"
```

## Monitoring

### Enable Container Insights

```bash
az aks enable-addons \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --addons monitoring \
  --workspace-resource-id /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}
```

### Query Container Logs

```kql
// Container logs
ContainerLog
| where TimeGenerated > ago(1h)
| where LogEntry contains "error"
| project TimeGenerated, Computer, ContainerID, LogEntry

// Pod inventory
KubePodInventory
| where TimeGenerated > ago(5m)
| summarize count() by PodStatus, Namespace

// Node performance
Perf
| where ObjectName == "K8SNode"
| where CounterName == "cpuUsageNanoCores"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
```

## Scaling

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Cluster Autoscaler

```bash
# Enable cluster autoscaler
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10

# Update autoscaler settings
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --update-cluster-autoscaler \
  --min-count 5 \
  --max-count 15
```

### Vertical Pod Autoscaler

```bash
# Install VPA
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-0.13.0/vpa-v0.13.0.yaml
```

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
```

## Upgrades

### Check Available Versions

```bash
az aks get-upgrades \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --output table
```

### Upgrade Cluster

```bash
# Upgrade control plane and nodes
az aks upgrade \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --kubernetes-version 1.28.3

# Upgrade control plane only
az aks upgrade \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --kubernetes-version 1.28.3 \
  --control-plane-only

# Upgrade specific node pool
az aks nodepool upgrade \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name nodepool1 \
  --kubernetes-version 1.28.3
```

### Auto-Upgrade

```bash
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --auto-upgrade-channel stable
```

**Channels:**
- `none`: Disable auto-upgrade
- `patch`: Auto-upgrade to latest patch version
- `stable`: Auto-upgrade to latest stable minor version
- `rapid`: Auto-upgrade to latest version
- `node-image`: Auto-upgrade node images only

## ACR Integration

### Attach ACR

```bash
# Attach ACR to AKS
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --attach-acr /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}

# Or using ACR name
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --attach-acr myacr
```

### Pull Image from ACR

```yaml
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
        image: myacr.azurecr.io/myapp:v1
        ports:
        - containerPort: 80
```

## GitOps with Flux

### Enable GitOps

```bash
# Install Flux extension
az k8s-extension create \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --cluster-type managedClusters \
  --extension-type microsoft.flux \
  --name flux
```

### Create Flux Configuration

```bash
az k8s-configuration flux create \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --cluster-type managedClusters \
  --name myconfig \
  --namespace flux-system \
  --scope cluster \
  --url https://github.com/myorg/myrepo \
  --branch main \
  --kustomization name=apps path=./apps prune=true
```

## Backup and Disaster Recovery

### Velero Backup

```bash
# Install Velero
velero install \
  --provider azure \
  --plugins velero/velero-plugin-for-microsoft-azure:v1.8.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --backup-location-config resourceGroup=myResourceGroup,storageAccount=mystorageaccount \
  --snapshot-location-config apiTimeout=5m,resourceGroup=myResourceGroup
```

```bash
# Create backup
velero backup create mybackup --include-namespaces default

# Restore backup
velero restore create --from-backup mybackup
```

## Cost Optimization

### Use Spot Instances

```bash
az aks nodepool add \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name spotpool \
  --priority Spot \
  --eviction-policy Delete \
  --spot-max-price -1 \
  --node-count 3
```

### Right-size Node Pools

```bash
# Use appropriate VM sizes
# Development: Standard_B2s, Standard_DS2_v2
# Production: Standard_DS3_v2, Standard_D4s_v3
```

### Enable Cluster Autoscaler

```bash
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 10
```

## Troubleshooting

### Get Cluster Diagnostics

```bash
# Get cluster info
az aks show \
  --resource-group myResourceGroup \
  --name myAKSCluster

# Get node resource group
az aks show \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --query nodeResourceGroup -o tsv

# Run diagnostics
az aks kanalyze \
  --resource-group myResourceGroup \
  --name myAKSCluster
```

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by='.lastTimestamp'
```

**Node issues:**
```bash
kubectl get nodes
kubectl describe node <node-name>
kubectl top nodes
```

**Network issues:**
```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Test connectivity
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- bash
```

## Best Practices

### Cluster Configuration
- Use managed identity instead of service principal
- Enable Azure AD integration
- Use Azure RBAC for Kubernetes authorization
- Enable network policies
- Use availability zones for high availability

### Node Pools
- Separate system and user node pools
- Use appropriate VM sizes
- Enable cluster autoscaler
- Use spot instances for non-critical workloads

### Security
- Enable Azure Policy for AKS
- Use Pod Security Standards
- Integrate with Azure Key Vault
- Enable audit logging
- Regularly update cluster and node images

### Monitoring
- Enable Container Insights
- Set up alerts for critical metrics
- Monitor resource utilization
- Track application performance

### Networking
- Use Azure CNI for production
- Implement network policies
- Use private clusters for sensitive workloads
- Configure egress traffic properly

## Resources

- [AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [AKS Best Practices](https://docs.microsoft.com/azure/aks/best-practices)
- [AKS Roadmap](https://github.com/Azure/AKS/projects/1)
- [AKS Pricing](https://azure.microsoft.com/pricing/details/kubernetes-service/)
