
## What is AWS ECR?

> **AWS Elastic Container Registry (ECR)** is a fully-managed Docker container registry that allows you to store, manage, and deploy container images.

Key Benefits:

- Private/Public repositories
    
- Native Docker CLI and SDK support
    
- Integrated with IAM for security
    
- Image vulnerability scanning
    

---

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
    
- Docker installed
    
- IAM user with permissions:
    
    - `AmazonEC2ContainerRegistryFullAccess`
        
- AWS Account with ECR access
    

---

## ECR Concepts

|Concept|Description|
|---|---|
|**Repository**|Place to store container images|
|**Image Tag**|Labels used to version images (e.g., `v1.0`)|
|**URI**|Unique ECR URL for your image|
|**Authentication**|Token-based auth via AWS CLI|

---

## ECR CLI Commands Summary

|Task|Command|
|---|---|
|Create Repository|`aws ecr create-repository --repository-name NAME`|
|Authenticate Docker|`aws ecr get-login-password`|
|Tag Docker Image|`docker tag IMAGE ECR_URI`|
|Push Docker Image|`docker push ECR_URI`|
|Pull Docker Image|`docker pull ECR_URI`|
|Delete Image|`aws ecr batch-delete-image`|
|Delete Repository|`aws ecr delete-repository --force`|

---

## Step-by-Step Tutorials

### 1. Create an ECR Repository

```bash
aws ecr create-repository \
  --repository-name my-app \
  --image-scanning-configuration scanOnPush=true \
  --region us-east-1
```

### 2. Authenticate Docker with ECR

```bash
aws ecr get-login-password \
  --region us-east-1 \
  | docker login \
    --username AWS \
    --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

> Replace `<aws_account_id>` with your 12-digit AWS account ID.

### 3. Build and Tag Docker Image

```bash
# Build Docker Image
docker build -t my-app .

# Tag the image
docker tag my-app:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

### 4. Push Docker Image to ECR

```bash
docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

### 5. Pull Docker Image from ECR

```bash
docker pull <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

---

## Advanced Practicals

### 1. Automate Push using GitHub Actions

**`.github/workflows/docker-push.yml`**

```yaml
name: Build & Push to ECR

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Login to AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to Amazon ECR
        run: |
          aws ecr get-login-password --region us-east-1 | \
          docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com

      - name: Build, Tag, Push Docker Image
        run: |
          docker build -t my-app .
          docker tag my-app:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
          docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

### 2. Lifecycle Policies (Auto-delete Old Images)

```json
[
  {
    "rulePriority": 1,
    "description": "Expire images older than 30 days",
    "selection": {
      "tagStatus": "any",
      "countType": "sinceImagePushed",
      "countUnit": "days",
      "countNumber": 30
    },
    "action": {
      "type": "expire"
    }
  }
]
```

**Command:**

```bash
aws ecr put-lifecycle-policy \
  --repository-name my-app \
  --lifecycle-policy-text file://lifecycle.json
```

### 3. ECR Image Scanning

```bash
aws ecr describe-image-scan-findings \
  --repository-name my-app \
  --image-id imageTag=latest
```

### 4. Cross-Account ECR Access

1. Create IAM role in the other account.
    
2. Add permissions in ECR policy of source account:
    

```json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowCrossAccountPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<target_account_id>:root"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
```

### 5. ECR with Kubernetes (EKS)

In your `deployment.yaml`:

```yaml
image: <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

Add IAM role to node group that allows access to ECR.

Or use `imagePullSecrets` with `kubectl create secret docker-registry`.

---

## Best Practices

- Use tags like `prod`, `dev`, `latest`, `v1.0` for versioning.
    
- Enable image scanning (`scanOnPush=true`).
    
- Use lifecycle policies to clean old images.
    
- Use GitHub Actions or CI/CD pipelines.
    
- Set up cross-account access securely using roles.
    
- Integrate with EKS, ECS, or Lambda.
    

---

## Cleanup

```bash
# Delete image
aws ecr batch-delete-image \
  --repository-name my-app \
  --image-ids imageTag=latest

# Delete repository
aws ecr delete-repository \
  --repository-name my-app \
  --force
```

---

## References

- [ECR Official Docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
    
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
    
- [GitHub Action for ECR](https://github.com/aws-actions/amazon-ecr-login)
    

---
