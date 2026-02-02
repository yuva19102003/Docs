# Kubernetes Cluster Setup

Guide to setting up Kubernetes clusters for different environments.

## Cluster Setup Options

```
┌────────────────────────────────────────────────┐
│         Cluster Setup Methods                  │
├────────────────────────────────────────────────┤
│  Local Development:                            │
│    - Minikube                                  │
│    - Kind (Kubernetes in Docker)               │
│    - Docker Desktop                            │
│    - MicroK8s                                  │
│                                                │
│  Production:                                   │
│    - kubeadm                                   │
│    - kops                                      │
│    - Kubespray                                 │
│                                                │
│  Managed Services:                             │
│    - EKS (AWS)                                 │
│    - GKE (Google Cloud)                        │
│    - AKS (Azure)                               │
│    - DigitalOcean Kubernetes                   │
└────────────────────────────────────────────────┘
```

## Minikube

### Install Minikube

```bash
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Start Cluster

```bash
# Start with default settings
minikube start

# Start with specific resources
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.28.0

# Start with specific driver
minikube start --driver=docker
```

### Minikube Commands

```bash
# Stop cluster
minikube stop

# Delete cluster
minikube delete

# SSH into node
minikube ssh

# Get cluster IP
minikube ip

# Open dashboard
minikube dashboard

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
```

## Kind (Kubernetes in Docker)

### Install Kind

```bash
# macOS/Linux
brew install kind

# Or download binary
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Create Cluster

```bash
# Simple cluster
kind create cluster

# Named cluster
kind create cluster --name dev-cluster

# With config file
kind create cluster --config kind-config.yaml
```

### Kind Configuration

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
```

## kubeadm

### Prerequisites

```bash
# Disable swap
sudo swapoff -a

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### Install Container Runtime

```bash
# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```

### Install kubeadm, kubelet, kubectl

```bash
# Add Kubernetes repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install packages
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Initialize Control Plane

```bash
# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install CNI Plugin

```bash
# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Or Flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Join Worker Nodes

```bash
# On worker nodes
sudo kubeadm join <control-plane-ip>:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

## AWS EKS

### Using eksctl

```bash
# Install eksctl
brew install eksctl

# Create cluster
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-cluster
```

### EKS Configuration File

```yaml
# eks-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: my-cluster
  region: us-east-1
  version: "1.28"

managedNodeGroups:
  - name: ng-1
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 1
    maxSize: 5
    volumeSize: 50
    ssh:
      allow: true
      publicKeyName: my-key
    labels:
      role: worker
    tags:
      environment: production
```

## GKE

```bash
# Create cluster
gcloud container clusters create my-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n1-standard-2 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Get credentials
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

## AKS

```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

## Cluster Verification

```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info

# Check component status
kubectl get componentstatuses
```

## References

- [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Minikube](https://minikube.sigs.k8s.io/)
- [Kind](https://kind.sigs.k8s.io/)
