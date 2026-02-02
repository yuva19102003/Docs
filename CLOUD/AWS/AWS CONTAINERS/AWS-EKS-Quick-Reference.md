# AWS EKS Quick Reference Guide

Quick reference for common AWS EKS operations and commands.

## Quick Setup

```bash
# Create cluster
eksctl create cluster --name my-cluster --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-cluster

# Verify
kubectl get nodes
```

## IRSA Quick Setup

```bash
# Enable OIDC
eksctl utils associate-iam-oidc-provider --cluster my-cluster --approve

# Create service account with S3 access
eksctl create iamserviceaccount \
  --name s3-reader \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

## Common Service Account Patterns

### S3 Access
```bash
eksctl create iamserviceaccount \
  --name s3-app \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --approve
```

### DynamoDB Access
```bash
eksctl create iamserviceaccount \
  --name dynamodb-app \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
  --approve
```

### Secrets Manager Access
```bash
eksctl create iamserviceaccount \
  --name secrets-app \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite \
  --approve
```

### SQS Access
```bash
eksctl create iamserviceaccount \
  --name sqs-app \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess \
  --approve
```

## Pod with Service Account

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  serviceAccountName: s3-reader
  containers:
  - name: app
    image: amazon/aws-cli
    command: ['sh', '-c', 'aws s3 ls && sleep 3600']
```

## AWS Load Balancer Controller

```bash
# Install
eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

## EBS CSI Driver

```bash
# Install
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.25"
```

## Cluster Autoscaler

```bash
# Install
eksctl create iamserviceaccount \
  --name cluster-autoscaler \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/ClusterAutoscalerPolicy \
  --approve

kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

## Troubleshooting Commands

```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods --all-namespaces

# Describe pod
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Check service account
kubectl get sa <sa-name> -o yaml

# Verify IRSA
kubectl exec <pod-name> -- env | grep AWS

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

## Cleanup

```bash
# Delete cluster
eksctl delete cluster --name my-cluster --region us-east-1
```

## Useful Links

- [Complete Guide](./AWS-EKS-Complete-Guide.md)
- [AWS EKS Docs](https://docs.aws.amazon.com/eks/)
- [eksctl Docs](https://eksctl.io/)
