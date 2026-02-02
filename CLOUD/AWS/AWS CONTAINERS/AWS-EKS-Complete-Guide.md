# AWS EKS - Complete Guide (Beginner to Expert)

Comprehensive guide to Amazon Elastic Kubernetes Service covering everything from basics to advanced IAM, service accounts, and AWS service integrations.

## Table of Contents

1. [EKS Fundamentals](#eks-fundamentals)
2. [Architecture Deep Dive](#architecture-deep-dive)
3. [Cluster Setup & Configuration](#cluster-setup--configuration)
4. [IAM & Authentication](#iam--authentication)
5. [Service Accounts & IRSA](#service-accounts--irsa)
6. [AWS Service Integrations](#aws-service-integrations)
7. [Networking](#networking)
8. [Storage](#storage)
9. [Security](#security)
10. [Monitoring & Logging](#monitoring--logging)
11. [Autoscaling](#autoscaling)
12. [CI/CD](#cicd)
13. [Advanced Topics](#advanced-topics)
14. [Troubleshooting](#troubleshooting)
15. [Best Practices](#best-practices)

---

## EKS Fundamentals

### What is AWS EKS?

Amazon Elastic Kubernetes Service (EKS) is a managed Kubernetes service that:
- Runs Kubernetes control plane across multiple AZs
- Automatically manages control plane availability and scalability
- Integrates with AWS services (IAM, VPC, CloudWatch, etc.)
- Provides certified Kubernetes conformance
- Supports both EC2 and Fargate compute options

### EKS vs Self-Managed Kubernetes

```
┌─────────────────────────────────────────────────────┐
│              EKS vs Self-Managed                    │
├─────────────────────────────────────────────────────┤
│  EKS:                                               │
│    ✓ Managed control plane                         │
│    ✓ Automatic updates                             │
│    ✓ Multi-AZ HA by default                        │
│    ✓ AWS service integration                       │
│    ✗ Higher cost                                   │
│                                                     │
│  Self-Managed:                                      │
│    ✓ Full control                                  │
│    ✓ Lower cost                                    │
│    ✗ Manual maintenance                            │
│    ✗ Complex HA setup                              │
└─────────────────────────────────────────────────────┘
```

### Prerequisites

**AWS Account Requirements:**
- AWS Account with appropriate permissions
- IAM user or role with EKS permissions
- VPC with public and private subnets
- AWS CLI configured

**Local Tools:**
```bash
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# AWS IAM Authenticator
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.14/aws-iam-authenticator_0.6.14_linux_amd64
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/
```

**Configure AWS CLI:**
```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

---

## Architecture Deep Dive

### EKS Control Plane Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    AWS MANAGED                           │
│              EKS CONTROL PLANE                           │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   AZ-1      │  │   AZ-2      │  │   AZ-3      │    │
│  │             │  │             │  │             │    │
│  │ API Server  │  │ API Server  │  │ API Server  │    │
│  │ etcd        │  │ etcd        │  │ etcd        │    │
│  │ Scheduler   │  │ Scheduler   │  │ Scheduler   │    │
│  │ Controller  │  │ Controller  │  │ Controller  │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │            │
└─────────┼────────────────┼────────────────┼────────────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
┌──────────────────────────┼────────────────────────────┐
│                    YOUR VPC                           │
│                   DATA PLANE                          │
│                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Private    │  │  Private    │  │  Private    │ │
│  │  Subnet     │  │  Subnet     │  │  Subnet     │ │
│  │   AZ-1      │  │   AZ-2      │  │   AZ-3      │ │
│  │             │  │             │  │             │ │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │
│  │ │ Worker  │ │  │ │ Worker  │ │  │ │ Worker  │ │ │
│  │ │ Node    │ │  │ │ Node    │ │  │ │ Node    │ │ │
│  │ │ (EC2)   │ │  │ │ (EC2)   │ │  │ │ (EC2)   │ │ │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
│                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Public     │  │  Public     │  │  Public     │ │
│  │  Subnet     │  │  Subnet     │  │  Subnet     │ │
│  │   AZ-1      │  │   AZ-2      │  │   AZ-3      │ │
│  │             │  │             │  │             │ │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │
│  │ │   NAT   │ │  │ │   NAT   │ │  │ │   NAT   │ │ │
│  │ │ Gateway │ │  │ │ Gateway │ │  │ │ Gateway │ │ │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │
│  │ │   ALB   │ │  │ │   ALB   │ │  │ │   ALB   │ │ │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└───────────────────────────────────────────────────────┘
```

### Components Breakdown

**Control Plane (AWS Managed):**
- **API Server**: Entry point for all REST commands
- **etcd**: Distributed key-value store for cluster state
- **Scheduler**: Assigns pods to nodes
- **Controller Manager**: Runs controller processes
- **Cloud Controller Manager**: AWS-specific controllers

**Data Plane (Customer Managed):**
- **Worker Nodes**: EC2 instances or Fargate
- **kubelet**: Node agent
- **kube-proxy**: Network proxy
- **Container Runtime**: containerd

---

## Cluster Setup & Configuration

### Method 1: Using eksctl (Recommended)

**Basic Cluster:**
```bash
eksctl create cluster \
  --name my-eks-cluster \
  --version 1.29 \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

**Advanced Cluster with Configuration File:**
```yaml
# cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: production-cluster
  region: us-east-1
  version: "1.29"
  tags:
    environment: production
    team: platform

# IAM OIDC Provider (required for IRSA)
iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
      name: aws-load-balancer-controller
      namespace: kube-system
    wellKnownPolicies:
      awsLoadBalancerController: true
  - metadata:
      name: ebs-csi-controller-sa
      namespace: kube-system
    wellKnownPolicies:
      ebsCSIController: true
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
    wellKnownPolicies:
      autoScaler: true

# VPC Configuration
vpc:
  cidr: 10.0.0.0/16
  nat:
    gateway: HighlyAvailable
  clusterEndpoints:
    publicAccess: true
    privateAccess: true

# Managed Node Groups
managedNodeGroups:
  - name: general-purpose
    instanceType: t3.medium
    minSize: 2
    maxSize: 10
    desiredCapacity: 3
    volumeSize: 50
    volumeType: gp3
    privateNetworking: true
    ssh:
      allow: true
      publicKeyName: my-key-pair
    labels:
      role: general
      environment: production
    tags:
      nodegroup-role: general
    iam:
      withAddonPolicies:
        imageBuilder: true
        autoScaler: true
        externalDNS: true
        certManager: true
        appMesh: true
        ebs: true
        fsx: true
        efs: true
        albIngress: true
        xRay: true
        cloudWatch: true

  - name: spot-instances
    instanceTypes: ["t3.medium", "t3a.medium"]
    spot: true
    minSize: 0
    maxSize: 10
    desiredCapacity: 2
    privateNetworking: true
    labels:
      role: spot
      lifecycle: spot
    taints:
    - key: spot
      value: "true"
      effect: NoSchedule

# Fargate Profiles
fargateProfiles:
  - name: fp-default
    selectors:
    - namespace: default
      labels:
        fargate: enabled
  - name: fp-kube-system
    selectors:
    - namespace: kube-system

# CloudWatch Logging
cloudWatch:
  clusterLogging:
    enableTypes: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    logRetentionInDays: 30

# Add-ons
addons:
- name: vpc-cni
  version: latest
  attachPolicyARNs:
  - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
- name: coredns
  version: latest
- name: kube-proxy
  version: latest
- name: aws-ebs-csi-driver
  version: latest
  attachPolicyARNs:
  - arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

**Create Cluster:**
```bash
eksctl create cluster -f cluster-config.yaml
```

### Method 2: Using AWS CLI

**Create Cluster:**
```bash
# Create IAM role for cluster
aws iam create-role \
  --role-name EKSClusterRole \
  --assume-role-policy-document file://cluster-trust-policy.json

# Attach required policies
aws iam attach-role-policy \
  --role-name EKSClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create cluster
aws eks create-cluster \
  --name my-cluster \
  --role-arn arn:aws:iam::ACCOUNT_ID:role/EKSClusterRole \
  --resources-vpc-config subnetIds=subnet-xxx,subnet-yyy,securityGroupIds=sg-xxx \
  --kubernetes-version 1.29

# Wait for cluster to be active
aws eks wait cluster-active --name my-cluster
```

### Method 3: Using Terraform

```hcl
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 2
      max_size     = 10
      desired_size = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Enable IRSA
  enable_irsa = true

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### Connect to Cluster

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify connection
kubectl get svc
kubectl get nodes
kubectl cluster-info

# View current context
kubectl config current-context

# View all contexts
kubectl config get-contexts
```

---

## IAM & Authentication

### EKS Authentication Flow

```
┌──────────────────────────────────────────────────────┐
│         EKS Authentication Flow                      │
├──────────────────────────────────────────────────────┤
│                                                      │
│  1. User runs kubectl command                       │
│         ↓                                            │
│  2. kubectl calls aws-iam-authenticator             │
│         ↓                                            │
│  3. Authenticator calls AWS STS GetCallerIdentity   │
│         ↓                                            │
│  4. Returns pre-signed URL token                    │
│         ↓                                            │
│  5. kubectl sends token to EKS API Server           │
│         ↓                                            │
│  6. API Server validates token with AWS STS         │
│         ↓                                            │
│  7. Maps IAM identity to Kubernetes RBAC            │
│         ↓                                            │
│  8. Authorizes request based on RBAC                │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### IAM Roles for EKS

**1. Cluster IAM Role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Required Policies:**
- `AmazonEKSClusterPolicy`
- `AmazonEKSVPCResourceController`

**2. Node IAM Role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Required Policies:**
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`

### AWS Auth ConfigMap

The `aws-auth` ConfigMap maps IAM entities to Kubernetes RBAC:

```bash
# View current aws-auth
kubectl get configmap aws-auth -n kube-system -o yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::ACCOUNT_ID:role/EKSNodeRole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::ACCOUNT_ID:role/DevTeamRole
      username: dev-user
      groups:
        - developers
  mapUsers: |
    - userarn: arn:aws:iam::ACCOUNT_ID:user/admin
      username: admin
      groups:
        - system:masters
    - userarn: arn:aws:iam::ACCOUNT_ID:user/developer
      username: developer
      groups:
        - developers
  mapAccounts: |
    - "123456789012"
```

**Add IAM User:**
```bash
eksctl create iamidentitymapping \
  --cluster my-eks-cluster \
  --region us-east-1 \
  --arn arn:aws:iam::ACCOUNT_ID:user/developer \
  --group developers \
  --username developer
```

**Add IAM Role:**
```bash
eksctl create iamidentitymapping \
  --cluster my-eks-cluster \
  --region us-east-1 \
  --arn arn:aws:iam::ACCOUNT_ID:role/DevTeamRole \
  --group developers \
  --username dev-team
```

### Kubernetes RBAC for IAM Users

```yaml
# Create namespace
apiVersion: v1
kind: Namespace
metadata:
  name: development
---
# Create Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
  namespace: development
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "services", "jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
---
# Create RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

---

## Service Accounts & IRSA

### Understanding IRSA (IAM Roles for Service Accounts)

IRSA allows Kubernetes service accounts to assume IAM roles, providing fine-grained permissions to pods without using AWS credentials.

**Architecture:**
```
┌──────────────────────────────────────────────────────┐
│              IRSA Architecture                       │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Pod with Service Account                           │
│         ↓                                            │
│  Service Account Token (JWT)                        │
│         ↓                                            │
│  AWS STS AssumeRoleWithWebIdentity                  │
│         ↓                                            │
│  Temporary AWS Credentials                          │
│         ↓                                            │
│  Access AWS Services                                │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Enable OIDC Provider

```bash
# Check if OIDC provider exists
aws eks describe-cluster --name my-eks-cluster --query "cluster.identity.oidc.issuer" --output text

# Create OIDC provider
eksctl utils associate-iam-oidc-provider \
  --cluster my-eks-cluster \
  --region us-east-1 \
  --approve

# Verify
aws iam list-open-id-connect-providers
```

### Create IAM Role for Service Account

**Method 1: Using eksctl (Recommended):**
```bash
# Create service account with S3 read access
eksctl create iamserviceaccount \
  --name s3-reader \
  --namespace default \
  --cluster my-eks-cluster \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve \
  --override-existing-serviceaccounts
```

**Method 2: Manual Creation:**

**Step 1: Create IAM Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

```bash
aws iam create-policy \
  --policy-name S3ReadPolicy \
  --policy-document file://s3-policy.json
```

**Step 2: Create IAM Role with Trust Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-1.amazonaws.com/id/OIDC_ID:sub": "system:serviceaccount:default:s3-reader",
          "oidc.eks.us-east-1.amazonaws.com/id/OIDC_ID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

```bash
aws iam create-role \
  --role-name S3ReaderRole \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name S3ReaderRole \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/S3ReadPolicy
```

**Step 3: Create Kubernetes Service Account**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-reader
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/S3ReaderRole
```

```bash
kubectl apply -f service-account.yaml
```

### Using Service Account in Pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: s3-app
  namespace: default
spec:
  serviceAccountName: s3-reader
  containers:
  - name: app
    image: amazon/aws-cli
    command: ['sh', '-c', 'aws s3 ls && sleep 3600']
```

**Verify:**
```bash
kubectl apply -f pod.yaml
kubectl logs s3-app

# Check mounted credentials
kubectl exec -it s3-app -- env | grep AWS
kubectl exec -it s3-app -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

### Advanced IRSA Examples

**DynamoDB Access:**
```bash
eksctl create iamserviceaccount \
  --name dynamodb-app \
  --namespace production \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
  --approve
```

**Secrets Manager Access:**
```bash
# Create custom policy
cat > secrets-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:ACCOUNT_ID:secret:prod/*"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name SecretsManagerReadPolicy \
  --policy-document file://secrets-policy.json

eksctl create iamserviceaccount \
  --name secrets-reader \
  --namespace production \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/SecretsManagerReadPolicy \
  --approve
```

**SQS Access:**
```bash
eksctl create iamserviceaccount \
  --name sqs-processor \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess \
  --approve
```

### External Secrets Operator with IRSA

```bash
# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace

# Create service account with Secrets Manager access
eksctl create iamserviceaccount \
  --name external-secrets \
  --namespace external-secrets-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite \
  --approve

# Create SecretStore
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
  namespace: default
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
EOF

# Create ExternalSecret
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: prod/database
      property: password
EOF
```

---

*This is Part 1 of the comprehensive guide. The file is getting large, so I'll continue with the remaining sections in the next part.*

## AWS Service Integrations

### Amazon S3 Integration

**Use Case: Application accessing S3 buckets**

**1. Create Service Account with S3 Access:**
```bash
eksctl create iamserviceaccount \
  --name s3-full-access \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --approve
```

**2. Deploy Application:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s3-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: s3-app
  template:
    metadata:
      labels:
        app: s3-app
    spec:
      serviceAccountName: s3-full-access
      containers:
      - name: app
        image: amazon/aws-cli
        command:
        - /bin/bash
        - -c
        - |
          while true; do
            echo "Listing S3 buckets:"
            aws s3 ls
            echo "Uploading file to S3:"
            echo "Hello from EKS" > /tmp/test.txt
            aws s3 cp /tmp/test.txt s3://my-bucket/test.txt
            sleep 60
          done
```

### Amazon RDS Integration

**1. Create RDS Instance in Same VPC:**
```bash
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password MyPassword123 \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxx \
  --db-subnet-group-name my-db-subnet-group
```

**2. Create Secret for Database Credentials:**
```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=MyPassword123 \
  --from-literal=host=mydb.xxxxx.us-east-1.rds.amazonaws.com \
  --from-literal=database=mydb
```

**3. Deploy Application:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
      - name: app
        image: postgres:14
        env:
        - name: PGHOST
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: host
        - name: PGUSER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: PGDATABASE
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: database
```

### Amazon DynamoDB Integration

**1. Create DynamoDB Table:**
```bash
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions \
    AttributeName=UserId,AttributeType=S \
  --key-schema \
    AttributeName=UserId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**2. Create Service Account:**
```bash
eksctl create iamserviceaccount \
  --name dynamodb-app \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
  --approve
```

**3. Deploy Application:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dynamodb-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dynamodb-app
  template:
    metadata:
      labels:
        app: dynamodb-app
    spec:
      serviceAccountName: dynamodb-app
      containers:
      - name: app
        image: amazon/aws-cli
        command:
        - /bin/bash
        - -c
        - |
          while true; do
            aws dynamodb put-item \
              --table-name Users \
              --item '{"UserId": {"S": "user123"}, "Name": {"S": "John Doe"}}'
            aws dynamodb scan --table-name Users
            sleep 60
          done
```

### Amazon SQS Integration

**1. Create SQS Queue:**
```bash
aws sqs create-queue --queue-name my-queue
```

**2. Create Service Account:**
```bash
eksctl create iamserviceaccount \
  --name sqs-processor \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess \
  --approve
```

**3. Deploy Consumer:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sqs-consumer
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sqs-consumer
  template:
    metadata:
      labels:
        app: sqs-consumer
    spec:
      serviceAccountName: sqs-processor
      containers:
      - name: consumer
        image: amazon/aws-cli
        env:
        - name: QUEUE_URL
          value: "https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/my-queue"
        command:
        - /bin/bash
        - -c
        - |
          while true; do
            aws sqs receive-message \
              --queue-url $QUEUE_URL \
              --max-number-of-messages 10 \
              --wait-time-seconds 20
            sleep 5
          done
```

### AWS Secrets Manager Integration

**1. Create Secret:**
```bash
aws secretsmanager create-secret \
  --name prod/database \
  --secret-string '{"username":"admin","password":"MySecretPassword123"}'
```

**2. Install AWS Secrets CSI Driver:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name secrets-csi-driver \
  --namespace kube-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite \
  --approve

# Install CSI driver
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system

# Install AWS provider
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

**3. Create SecretProviderClass:**
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "prod/database"
        objectType: "secretsmanager"
        jmesPath:
          - path: username
            objectAlias: dbusername
          - path: password
            objectAlias: dbpassword
```

**4. Use in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-secrets
spec:
  serviceAccountName: secrets-csi-driver
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: secrets-store
      mountPath: "/mnt/secrets"
      readOnly: true
  volumes:
  - name: secrets-store
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "aws-secrets"
```

### Amazon ECR Integration

**1. Create ECR Repository:**
```bash
aws ecr create-repository --repository-name my-app
```

**2. Build and Push Image:**
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t my-app .

# Tag image
docker tag my-app:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Push image
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

**3. Deploy from ECR:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
        ports:
        - containerPort: 8080
```

### Amazon CloudWatch Integration

**1. Install CloudWatch Container Insights:**
```bash
# Create namespace
kubectl create namespace amazon-cloudwatch

# Create service account
eksctl create iamserviceaccount \
  --name cloudwatch-agent \
  --namespace amazon-cloudwatch \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --approve

# Deploy CloudWatch agent
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml
```

**2. View Metrics in CloudWatch:**
```bash
# Container Insights provides:
# - Pod metrics
# - Node metrics
# - Namespace metrics
# - Service metrics
# - Cluster metrics
```

### AWS Load Balancer Controller

**1. Install AWS Load Balancer Controller:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

# Install controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

**2. Create Application Load Balancer:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

**3. Create Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/xxxxx
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  ingressClassName: alb
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

---

## Networking

### VPC and Subnet Configuration

**Best Practice VPC Setup:**
```
VPC: 10.0.0.0/16

Public Subnets (for Load Balancers):
- 10.0.1.0/24 (us-east-1a)
- 10.0.2.0/24 (us-east-1b)
- 10.0.3.0/24 (us-east-1c)

Private Subnets (for Worker Nodes):
- 10.0.11.0/24 (us-east-1a)
- 10.0.12.0/24 (us-east-1b)
- 10.0.13.0/24 (us-east-1c)

Database Subnets:
- 10.0.21.0/24 (us-east-1a)
- 10.0.22.0/24 (us-east-1b)
- 10.0.23.0/24 (us-east-1c)
```

### Security Groups

**Cluster Security Group:**
```bash
# Allow all traffic within cluster
aws ec2 authorize-security-group-ingress \
  --group-id sg-cluster \
  --protocol all \
  --source-group sg-cluster

# Allow HTTPS from anywhere (for API server)
aws ec2 authorize-security-group-ingress \
  --group-id sg-cluster \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

**Node Security Group:**
```bash
# Allow all traffic from cluster security group
aws ec2 authorize-security-group-ingress \
  --group-id sg-nodes \
  --protocol all \
  --source-group sg-cluster

# Allow SSH from bastion
aws ec2 authorize-security-group-ingress \
  --group-id sg-nodes \
  --protocol tcp \
  --port 22 \
  --source-group sg-bastion
```

### VPC CNI Configuration

**Enable prefix delegation for more IPs:**
```bash
kubectl set env daemonset aws-node \
  -n kube-system \
  ENABLE_PREFIX_DELEGATION=true
```

**Configure custom networking:**
```bash
kubectl set env daemonset aws-node \
  -n kube-system \
  AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

---

## Storage

### EBS CSI Driver

**1. Install EBS CSI Driver:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

# Install driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.25"
```

**2. Create StorageClass:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

**3. Create PVC:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 10Gi
```

**4. Use in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-ebs
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: ebs-claim
```

### EFS CSI Driver

**1. Create EFS File System:**
```bash
aws efs create-file-system \
  --performance-mode generalPurpose \
  --throughput-mode bursting \
  --encrypted \
  --tags Key=Name,Value=eks-efs
```

**2. Create Mount Targets:**
```bash
aws efs create-mount-target \
  --file-system-id fs-xxxxx \
  --subnet-id subnet-xxxxx \
  --security-groups sg-xxxxx
```

**3. Install EFS CSI Driver:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name efs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
  --approve

# Install driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.7"
```

**4. Create StorageClass:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-xxxxx
  directoryPerms: "700"
```

**5. Create PVC:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
```

### FSx for Lustre

**1. Create FSx File System:**
```bash
aws fsx create-file-system \
  --file-system-type LUSTRE \
  --storage-capacity 1200 \
  --subnet-ids subnet-xxxxx \
  --security-group-ids sg-xxxxx
```

**2. Install FSx CSI Driver:**
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.1"
```

**3. Create PV and PVC:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fsx-pv
spec:
  capacity:
    storage: 1200Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: fsx.csi.aws.com
    volumeHandle: fs-xxxxx
    volumeAttributes:
      dnsname: fs-xxxxx.fsx.us-east-1.amazonaws.com
      mountname: fsx
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fsx-claim
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 1200Gi
  volumeName: fsx-pv
```

---

## Security

### Pod Security Standards

**1. Enable Pod Security Admission:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**2. Secure Pod Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

### Secrets Encryption

**Enable Secrets Encryption:**
```bash
# Create KMS key
aws kms create-key --description "EKS secrets encryption key"

# Create alias
aws kms create-alias \
  --alias-name alias/eks-secrets \
  --target-key-id <key-id>

# Enable encryption on cluster
aws eks associate-encryption-config \
  --cluster-name my-eks-cluster \
  --encryption-config '[{"resources":["secrets"],"provider":{"keyArn":"arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"}}]'
```

### Network Security

**1. Private Cluster Endpoint:**
```bash
aws eks update-cluster-config \
  --name my-eks-cluster \
  --resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true
```

**2. Restrict API Access:**
```bash
aws eks update-cluster-config \
  --name my-eks-cluster \
  --resources-vpc-config endpointPublicAccess=true,publicAccessCidrs="203.0.113.0/24"
```

### GuardDuty for EKS

**Enable GuardDuty:**
```bash
aws guardduty create-detector --enable

# Enable EKS protection
aws guardduty update-detector \
  --detector-id <detector-id> \
  --features '[{"Name":"EKS_AUDIT_LOGS","Status":"ENABLED"}]'
```

---

*Continuing with remaining sections...*

## Monitoring & Logging

### CloudWatch Container Insights

**1. Install Container Insights:**
```bash
# Create namespace
kubectl create namespace amazon-cloudwatch

# Create service account
eksctl create iamserviceaccount \
  --name cloudwatch-agent \
  --namespace amazon-cloudwatch \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --approve

# Deploy agent
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml
```

**2. View Metrics:**
- Navigate to CloudWatch Console
- Select "Container Insights"
- View cluster, node, pod, and service metrics

### Prometheus and Grafana

**1. Install Prometheus:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

**2. Access Grafana:**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Get admin password
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

### AWS X-Ray

**1. Install X-Ray Daemon:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name xray-daemon \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess \
  --approve

# Deploy daemon
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: xray-daemon
spec:
  selector:
    matchLabels:
      app: xray-daemon
  template:
    metadata:
      labels:
        app: xray-daemon
    spec:
      serviceAccountName: xray-daemon
      containers:
      - name: xray-daemon
        image: amazon/aws-xray-daemon
        ports:
        - containerPort: 2000
          protocol: UDP
EOF
```

### Logging with Fluent Bit

**1. Install Fluent Bit:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name fluent-bit \
  --namespace logging \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --approve

# Install Fluent Bit
helm repo add fluent https://fluent.github.io/helm-charts
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=fluent-bit
```

---

## Autoscaling

### Horizontal Pod Autoscaler (HPA)

**1. Install Metrics Server:**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**2. Create HPA:**
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
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Cluster Autoscaler

**1. Create IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    }
  ]
}
```

**2. Install Cluster Autoscaler:**
```bash
# Create service account
eksctl create iamserviceaccount \
  --name cluster-autoscaler \
  --namespace kube-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/ClusterAutoscalerPolicy \
  --approve

# Install autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Patch deployment
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl set image deployment cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.29.0
```

### Karpenter (Advanced Autoscaling)

**1. Install Karpenter:**
```bash
export CLUSTER_NAME=my-eks-cluster
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create IAM resources
eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" \
  --name karpenter \
  --namespace karpenter \
  --role-name "${CLUSTER_NAME}-karpenter" \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy" \
  --role-only \
  --approve

# Install Karpenter
helm repo add karpenter https://charts.karpenter.sh
helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER_NAME}-karpenter" \
  --set settings.aws.clusterName=${CLUSTER_NAME} \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile \
  --set settings.aws.interruptionQueueName=${CLUSTER_NAME}
```

**2. Create Provisioner:**
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["t3.medium", "t3.large", "t3.xlarge"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeInstanceProfile
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
```

---

## CI/CD

### GitHub Actions with EKS

```yaml
name: Deploy to EKS

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER: my-eks-cluster
  ECR_REPOSITORY: my-app

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
    
    - name: Update kube config
      run: aws eks update-kubeconfig --name $EKS_CLUSTER --region $AWS_REGION
    
    - name: Deploy to EKS
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        kubectl set image deployment/myapp myapp=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        kubectl rollout status deployment/myapp
```

### GitLab CI with EKS

```yaml
stages:
  - build
  - deploy

variables:
  AWS_REGION: us-east-1
  EKS_CLUSTER: my-eks-cluster
  ECR_REPOSITORY: my-app

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - apk add --no-cache python3 py3-pip
    - pip3 install awscli
    - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY/$ECR_REPOSITORY:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY/$ECR_REPOSITORY:$CI_COMMIT_SHA

deploy:
  stage: deploy
  image: alpine/k8s:latest
  before_script:
    - aws eks update-kubeconfig --name $EKS_CLUSTER --region $AWS_REGION
  script:
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY/$ECR_REPOSITORY:$CI_COMMIT_SHA
    - kubectl rollout status deployment/myapp
  only:
    - main
```

### ArgoCD with EKS

**1. Install ArgoCD:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**2. Create Application:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myapp
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

---

## Advanced Topics

### Fargate Profiles

**1. Create Fargate Profile:**
```bash
eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name fp-default \
  --namespace default \
  --labels fargate=enabled
```

**2. Deploy to Fargate:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fargate-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fargate-app
      fargate: enabled
  template:
    metadata:
      labels:
        app: fargate-app
        fargate: enabled
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
```

### Spot Instances

**1. Create Spot Node Group:**
```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: my-eks-cluster
  region: us-east-1

managedNodeGroups:
  - name: spot-nodes
    instanceTypes:
      - t3.medium
      - t3a.medium
      - t3.large
    spot: true
    minSize: 0
    maxSize: 10
    desiredCapacity: 2
    labels:
      lifecycle: spot
    taints:
      - key: spot
        value: "true"
        effect: NoSchedule
```

**2. Deploy with Spot Toleration:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spot-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spot-app
  template:
    metadata:
      labels:
        app: spot-app
    spec:
      tolerations:
      - key: spot
        operator: Equal
        value: "true"
        effect: NoSchedule
      nodeSelector:
        lifecycle: spot
      containers:
      - name: app
        image: nginx
```

### Multi-Cluster Management

**1. Install eksctl Anywhere:**
```bash
curl "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml" | yq e ".spec.releases[] | select(.version==\"v0.18.0\").eksABinary.$(uname -s | tr A-Z a-z).uri" - | xargs curl -o eksctl-anywhere
chmod +x eksctl-anywhere
sudo mv eksctl-anywhere /usr/local/bin/
```

**2. Create Cluster Config:**
```yaml
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: Cluster
metadata:
  name: my-cluster
spec:
  clusterNetwork:
    cniConfig:
      cilium: {}
    pods:
      cidrBlocks:
      - 192.168.0.0/16
    services:
      cidrBlocks:
      - 10.96.0.0/12
  controlPlaneConfiguration:
    count: 3
    endpoint:
      host: "198.18.99.49"
    machineGroupRef:
      kind: VSphereMachineConfig
      name: my-cluster-cp
  datacenterRef:
    kind: VSphereDatacenterConfig
    name: my-cluster-datacenter
  kubernetesVersion: "1.29"
  managementCluster:
    name: my-cluster
  workerNodeGroupConfigurations:
  - count: 3
    machineGroupRef:
      kind: VSphereMachineConfig
      name: my-cluster
    name: md-0
```

---

## Troubleshooting

### Common Issues and Solutions

**1. Nodes Not Joining Cluster:**
```bash
# Check node IAM role
aws iam get-role --role-name EKSNodeRole

# Verify aws-auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml

# Check node logs
ssh ec2-user@<node-ip>
sudo journalctl -u kubelet -f
```

**2. Pods Stuck in Pending:**
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes

# Check PVC status
kubectl get pvc
```

**3. Service Not Accessible:**
```bash
# Check service
kubectl get svc
kubectl describe svc <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

**4. IRSA Not Working:**
```bash
# Verify OIDC provider
aws eks describe-cluster --name my-eks-cluster --query "cluster.identity.oidc.issuer"

# Check service account annotation
kubectl get sa <sa-name> -o yaml

# Verify IAM role trust policy
aws iam get-role --role-name <role-name>

# Check pod environment
kubectl exec <pod-name> -- env | grep AWS
```

**5. Load Balancer Not Provisioning:**
```bash
# Check AWS Load Balancer Controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify service annotations
kubectl get svc <service-name> -o yaml
```

### Debugging Commands

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

# Pod debugging
kubectl get pods --all-namespaces
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl exec -it <pod-name> -- /bin/bash

# Network debugging
kubectl run netshoot --rm -it --image=nicolaka/netshoot -- bash
kubectl exec -it netshoot -- ping <service-name>
kubectl exec -it netshoot -- nslookup <service-name>

# Resource usage
kubectl top nodes
kubectl top pods

# Events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=<pod-name>

# API server logs (CloudWatch)
aws logs tail /aws/eks/my-eks-cluster/cluster --follow
```

---

## Best Practices

### Security Best Practices

1. **Enable Private Endpoint Access**
2. **Use IRSA Instead of Instance Profiles**
3. **Enable Secrets Encryption with KMS**
4. **Implement Network Policies**
5. **Use Pod Security Standards**
6. **Enable Audit Logging**
7. **Regularly Update EKS Version**
8. **Use Private Subnets for Nodes**
9. **Implement Least Privilege IAM Policies**
10. **Enable GuardDuty for EKS**

### Cost Optimization

1. **Use Spot Instances for Non-Critical Workloads**
2. **Implement Cluster Autoscaler or Karpenter**
3. **Right-Size Node Instance Types**
4. **Use Fargate for Serverless Workloads**
5. **Enable Container Insights Selectively**
6. **Use Reserved Instances for Stable Workloads**
7. **Implement Resource Quotas**
8. **Monitor and Optimize Storage Usage**
9. **Use Savings Plans**
10. **Clean Up Unused Resources**

### Performance Best Practices

1. **Use Latest Kubernetes Version**
2. **Enable Prefix Delegation for VPC CNI**
3. **Use gp3 EBS Volumes**
4. **Implement HPA and VPA**
5. **Use Node Affinity for Workload Placement**
6. **Enable Topology Aware Routing**
7. **Use Local NVMe for Temporary Storage**
8. **Optimize Container Images**
9. **Implement Proper Resource Requests/Limits**
10. **Use CDN for Static Content**

### Operational Best Practices

1. **Use Infrastructure as Code (Terraform/eksctl)**
2. **Implement GitOps with ArgoCD/Flux**
3. **Enable Comprehensive Monitoring**
4. **Implement Centralized Logging**
5. **Use Namespaces for Multi-Tenancy**
6. **Implement Backup Strategy**
7. **Document Runbooks**
8. **Implement Disaster Recovery Plan**
9. **Regular Security Audits**
10. **Automate Cluster Updates**

---

## Conclusion

This comprehensive guide covers AWS EKS from beginner to expert level, with special focus on:

- **IAM Integration**: Deep dive into IAM roles, policies, and authentication
- **Service Accounts & IRSA**: Complete coverage of pod-level AWS permissions
- **AWS Service Integrations**: Detailed examples for S3, RDS, DynamoDB, SQS, Secrets Manager, and more
- **Security**: Best practices for cluster and workload security
- **Networking**: VPC configuration, security groups, and network policies
- **Storage**: EBS, EFS, and FSx integration
- **Monitoring & Logging**: CloudWatch, Prometheus, and Fluent Bit
- **Autoscaling**: HPA, Cluster Autoscaler, and Karpenter
- **CI/CD**: GitHub Actions, GitLab CI, and ArgoCD
- **Advanced Topics**: Fargate, Spot instances, and multi-cluster management

For the latest updates and detailed AWS documentation, visit:
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [eksctl Documentation](https://eksctl.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Document Version**: 2.0  
**Last Updated**: 2024  
**Maintained By**: DevOps Team
