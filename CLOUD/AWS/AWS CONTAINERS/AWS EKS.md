
## Table of Contents

1. Introduction to AWS EKS
    
2. Prerequisites
    
3. Tools Installation
    
4. EKS Architecture Overview
    
5. EKS Cluster Setup Methods
    
6. Step-by-Step Cluster Creation using `eksctl`
    
7. Connecting to the Cluster using `kubectl`
    
8. Deploying a Sample Application
    
9. Load Balancer Setup
    
10. Monitoring & Logging
    
11. IAM Roles for Service Accounts (IRSA)
    
12. Service Accounts in Kubernetes
    
13. Networking and Security Best Practices
    
14. Autoscaling
    
15. Storage Integration (EBS)
    
16. CI/CD with GitHub Actions
    
17. Cleanup
    
18. Best Practices
    
19. Troubleshooting Tips
    

---

## 1. Introduction to AWS EKS

**AWS EKS** is a managed Kubernetes service that allows you to run Kubernetes clusters without managing the Kubernetes control plane. It integrates with AWS services such as IAM, CloudWatch, and VPC.

Key features:

- Fully managed Kubernetes control plane
    
- Native integration with AWS services
    
- Supports both EC2 and Fargate worker nodes
    

---

## 2. Prerequisites

- AWS Account
    
- IAM user with admin privileges
    
- Basic knowledge of Kubernetes
    
- AWS CLI configured
    

---

## 3. Tools Installation

Install the following tools:

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Helm (Optional)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Configure AWS CLI:

```bash
aws configure
```

---

## 4. EKS Architecture Overview

- **Control Plane:** Managed by AWS (includes API Server, etcd)
    
- **Node Group:** EC2 instances or Fargate
    
- **Networking:** Uses VPC, subnets, security groups
    
- **IAM Integration:** Uses IAM roles for users and pods (IRSA)
    

---

## 5. EKS Cluster Setup Methods

- **eksctl (Recommended)**
    
- AWS Management Console
    
- Terraform
    
- CloudFormation
    

---

## 6. Step-by-Step Cluster Creation using `eksctl`

```bash
eksctl create cluster \
--name my-cluster \
--version 1.29 \
--region us-east-1 \
--nodegroup-name linux-nodes \
--node-type t3.medium \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3 \
--managed
```

This creates:

- VPC with subnets
    
- EKS control plane
    
- Managed EC2 worker nodes
    

---

## 7. Connecting to the Cluster using `kubectl`

```bash
aws eks update-kubeconfig --region us-east-1 --name my-cluster
kubectl get svc
```

---

## 8. Deploying a Sample Application

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get svc nginx
```

Access the app using the `EXTERNAL-IP`.

---

## 9. Load Balancer Setup

EKS uses AWS ELB (Elastic Load Balancer). You can use Ingress controllers for advanced routing.

Install AWS ALB Ingress Controller:

```bash
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
```

---

## 10. Monitoring & Logging

Enable control plane logging:

```bash
eksctl utils update-cluster-logging \
--cluster=my-cluster \
--enable-types=api,audit,authenticator,controllerManager,scheduler \
--region=us-east-1 \
--approve
```

Install Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## 11. IAM Roles for Service Accounts (IRSA)

```bash
eksctl create iamserviceaccount \
--name s3-reader \
--namespace default \
--cluster my-cluster \
--attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
--approve \
--override-existing-serviceaccounts
```

---

## 12. Service Accounts in Kubernetes

Kubernetes ServiceAccounts are used by pods to authenticate with the Kubernetes API server. EKS enhances this by letting service accounts assume IAM roles via IRSA.

### Create a Service Account

```bash
kubectl create serviceaccount demo-sa
```

### Attach to a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  serviceAccountName: demo-sa
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
```

### View Default Token Mounted

```bash
kubectl exec -it demo-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

Use with IRSA for cloud permissions by linking a Kubernetes SA to an IAM role.

---

## 13. Networking and Security Best Practices

- Place worker nodes in **private subnets**
    
- Use **security groups** for ingress/egress control
    
- Use **Network Policies** to control pod communication
    
- Use **PodSecurityPolicies** or **OPA/Gatekeeper** for runtime enforcement
    

---

## 14. Autoscaling

### Horizontal Pod Autoscaler (HPA)

```bash
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=5
```

### Cluster Autoscaler

Install using Helm:

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
--set autoDiscovery.clusterName=my-cluster \
--set awsRegion=us-east-1 \
-n kube-system
```

---

## 15. Storage Integration (EBS)

Create EBS CSI driver:

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr?ref=master"
```

Create a Persistent Volume Claim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi
  storageClassName: gp2
```

---

## 16. CI/CD with GitHub Actions

```yaml
name: Deploy to EKS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Update kubeconfig
        run: aws eks update-kubeconfig --region us-east-1 --name my-cluster

      - name: Deploy to EKS
        run: |
          kubectl apply -f k8s/deployment.yaml
```

---

## 17. Cleanup

To delete the cluster:

```bash
eksctl delete cluster --name my-cluster --region us-east-1
```

---

## 18. Best Practices

- Use IRSA instead of hardcoded AWS credentials
    
- Enable logging for auditing
    
- Monitor with Prometheus/Grafana
    
- Separate environments using namespaces
    
- Keep workloads private and secure
    

---

## 19. Troubleshooting Tips

- **Pods not starting:** Check `kubectl describe pod` for events
    
- **ALB not provisioning:** Check Ingress annotations
    
- **IAM errors:** Ensure correct role trust relationship and attached policies
    
- **No external IP:** Ensure service type is LoadBalancer and check security groups
    

---

## 20. Common Questions & Answers (Q&A)

**Q1: What is AWS EKS and why use it?**  
**A:** AWS EKS is a managed Kubernetes service that handles the control plane and lets you focus on deploying and managing containerized applications. It reduces the overhead of running your own Kubernetes master nodes.

**Q2: What is IRSA and why is it important?**  
**A:** IRSA (IAM Roles for Service Accounts) enables Kubernetes pods to assume AWS IAM roles securely, avoiding the need to embed AWS credentials inside containers.

**Q3: How do you scale pods in EKS?**  
**A:** Use Horizontal Pod Autoscaler (HPA) for pod scaling and Cluster Autoscaler for node scaling based on metrics like CPU or custom metrics.

**Q4: How do you expose an application running on EKS to the internet?**  
**A:** By creating a Kubernetes Service of type LoadBalancer or using an Ingress resource with an AWS Application Load Balancer (ALB) controller.

**Q5: What is the difference between a Service Account and an IAM Role in EKS?**  
**A:** A Service Account is a Kubernetes identity used by pods to interact with the Kubernetes API. An IAM Role defines permissions in AWS and, with IRSA, can be linked to a service account to grant AWS permissions to pods.

---
