
## 1. ✅ What is AWS App Runner?

**AWS App Runner** is a fully managed service that makes it easy to:

- **Deploy** containerized applications and web APIs
    
- **Scale** automatically with incoming traffic
    
- **Avoid managing infrastructure** like EC2, ECS, or EKS
    

You provide source code or a container image, and App Runner handles the build, deployment, and scaling.

---

## 2. 🔧 Core Concepts

|Component|Description|
|---|---|
|**Service**|The running application instance|
|**Source**|GitHub repository or container image (ECR Public/Private)|
|**Auto Scaling**|Automatically adjusts instances (0–n) based on traffic|
|**Instance Configuration**|CPU (vCPU), Memory, Environment Variables, Port|
|**Custom Domain**|Map a custom DNS domain to your service|

---

## 3. 📊 Architecture

```plaintext
GitHub / ECR Image → App Runner Build Service → Managed Container → Internet Access / VPC
```

- HTTPS automatically provisioned
    
- Load balancing and deployment are managed
    
- Can integrate with RDS, DynamoDB, or internal services
    

---

## 4. 💡 Use Cases

- Deploying REST APIs or Web apps quickly
    
- Internal microservices with low ops overhead
    
- Prototypes and MVPs without full infra setup
    
- GitHub-to-Prod pipelines for containerized apps
    

---

## 5. 🛠️ Hands-on: Deploying an App

### 📌 Prerequisites

- GitHub or ECR repository
    
- Dockerfile in root (if using source code)
    

---

### 🚀 Option 1: Deploy from GitHub

1. Go to **AWS Console > App Runner > Create Service**
    
2. Select:
    
    - Source: GitHub
        
    - Repository & branch
        
    - Runtime: Auto or Dockerfile
        
3. Configure:
    
    - Port (default: 8080)
        
    - CPU/Memory
        
    - Env variables
        
4. Click **Next → Deploy**
    

✅ Done! You’ll get a secure HTTPS endpoint.

---

### 🚀 Option 2: Deploy from Container Image (ECR)

```bash
# Build and push Docker image
aws ecr create-repository --repository-name my-app

# Tag and push to ECR
docker tag my-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app
```

1. Go to App Runner → Create Service
    
2. Choose container registry (ECR private or public)
    
3. Provide service settings (port, memory, etc.)
    
4. Deploy!
    

---

## 6. 🔁 CI/CD with App Runner

- **GitHub**: Automatic deployments on push
    
- **Amazon ECR**: Can trigger deployments when a new image is pushed
    
- Can integrate with **CodePipeline** or **GitHub Actions** for more control
    

### 🧪 GitHub Actions Example:

```yaml
name: Deploy to App Runner
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: |
          aws apprunner start-deployment \
            --service-arn arn:aws:apprunner:us-east-1:123456789012:service/my-app/abcdef
```

---

## 7. ⚙️ Service Settings

|Setting|Options / Example|
|---|---|
|CPU & Memory|1 vCPU / 2 GB default|
|Env Variables|`DATABASE_URL`, `NODE_ENV=production`|
|Auto Scaling|Min: 0 or 1, Max: 25 instances|
|Health Check Path|`/health`|
|IAM Role|For accessing secrets or other AWS APIs|

---

## 8. 🌐 Networking Options

|Mode|Description|
|---|---|
|**Public**|Exposed to internet (default)|
|**Private VPC**|Connects to private AWS resources (RDS, ElastiCache, etc.)|
|**VPC Connector**|Set up access to VPC + Subnet|

> 🔐 Use **VPC connectors** to securely reach RDS without exposing your DB to the internet.

---

## 9. 📈 Observability & Logging

- **CloudWatch Logs** (for stdout/stderr)
    
- **X-Ray** integration for tracing
    
- Metrics:
    
    - Request count
        
    - Instance concurrency
        
    - Latency
        

```bash
aws logs tail /aws/apprunner/my-app --follow
```

---

## 10. 🔐 Security Best Practices

- Use **IAM roles** to restrict App Runner access
    
- Use **Secrets Manager** for credentials
    
- Enable **HTTPS-only traffic**
    
- Use **VPC connectors** for secure internal DB access
    
- Limit auto-deploy triggers on public branches (e.g., don’t auto-deploy on every `main` commit in public GitHub repos)
    

---

## 11. ⚠️ Limitations

- No persistent storage (ephemeral)
    
- No GPU support (yet)
    
- Limited regions
    
- Can’t SSH into container
    
- Pricing per instance-minute + request count
    

---

## 🧠 Section 12: Interview Questions **(with Answers)**

---

### ✅ **Beginner Level**

---

**1. What is AWS App Runner?**

**Answer**:  
AWS App Runner is a fully managed service that allows developers to **quickly deploy containerized web applications and APIs** without managing servers or infrastructure. You can deploy directly from a GitHub repository or a container image in Amazon ECR, and App Runner takes care of **build, deployment, scaling, and HTTPS setup** automatically.

---

**2. What sources can App Runner use to deploy apps?**

**Answer**:  
AWS App Runner supports two main source types:

- **Source code repository**: e.g., GitHub (App Runner can build using the `Dockerfile` or a predefined runtime)
    
- **Container registry**: Amazon ECR (both private and public repositories)
    

---

**3. How does App Runner handle scaling?**

**Answer**:  
App Runner automatically scales the number of running instances based on incoming HTTP requests. It supports:

- **Auto-scaling**: Scales up when traffic increases and scales down when idle.
    
- **Min/Max instance settings**: You can set the minimum and maximum number of instances (e.g., min=1, max=25).
    
- Supports **concurrent requests per instance** for better performance.
    

---

### ✅ **Intermediate Level**

---

**4. How do you secure access to an internal RDS from App Runner?**

**Answer**:  
To securely connect App Runner to a private RDS database:

1. **Create a VPC Connector** in App Runner that connects to the same VPC/subnet as the RDS instance.
    
2. Configure security groups to allow App Runner traffic to the RDS port (typically 3306 for MySQL).
    
3. Use **IAM roles** and **Secrets Manager** to securely fetch DB credentials.
    
4. Set environment variables in App Runner to store connection strings (e.g., `DB_HOST`, `DB_USER`).
    

---

**5. What’s the difference between AWS App Runner and ECS Fargate?**

**Answer**:

|Feature|AWS App Runner|AWS Fargate (with ECS/EKS)|
|---|---|---|
|**Abstraction**|Fully managed PaaS|Container orchestration (IaaS-like)|
|**Setup Complexity**|Very low – no cluster setup|Requires task definition, VPC, roles|
|**Use Case**|Web apps & APIs|Complex microservices, batch jobs|
|**Networking**|Simple (public or VPC connector)|Full VPC control|
|**Customizability**|Limited|Highly configurable|

---

**6. Can App Runner use a Dockerfile?**

**Answer**:  
Yes. If you're using **source code (like from GitHub)**, App Runner can detect and use a **`Dockerfile`** in your repository root.  
If you're using a **container image** from ECR, the Dockerfile is not needed since the image is already built.

---

### ✅ **Advanced Level**

---

**7. How does VPC Connector work with App Runner?**

**Answer**:  
The **VPC Connector** allows App Runner services to access resources **inside a private VPC** (e.g., RDS, Redis, private APIs).

- You configure subnets and security groups during VPC Connector creation.
    
- The connector enables **private egress** from App Runner to internal AWS resources.
    
- It **does not allow inbound connections** from VPC to App Runner; App Runner remains public or uses private endpoints for internal access.
    

---

**8. How would you set up CI/CD with GitHub and App Runner?**

**Answer**:  
There are two common ways:

**Option A: App Runner GitHub Integration**

- Connect your GitHub repository in App Runner
    
- Enable "automatic deployments"
    
- App Runner watches the repo for new commits and triggers deployments
    

**Option B: GitHub Actions**

- Use GitHub Actions to build the image, push it to ECR, and trigger a manual deployment using AWS CLI:
    

```yaml
- name: Trigger App Runner deployment
  run: |
    aws apprunner start-deployment \
      --service-arn arn:aws:apprunner:us-east-1:123456789012:service/my-app/abcdef
```

---

**9. What logging and monitoring tools are available?**

**Answer**:

- **CloudWatch Logs**: App Runner logs application output (`stdout`/`stderr`) here.
    
- **X-Ray Integration**: For distributed tracing (needs enabling).
    
- **CloudWatch Metrics**: Metrics like:
    
    - Request count
        
    - Active instances
        
    - Response latency
        
    - Concurrency
        

You can view these in **CloudWatch Dashboards** or set **alarms** for anomalies.

---

**10. What are the pricing factors in App Runner?**

**Answer**:  
App Runner pricing depends on:

|Component|Cost Factor|
|---|---|
|**Instance time**|Billed per vCPU/hour and memory GB/hour|
|**Requests**|Billed per number of HTTP requests|
|**Data transfer**|Outbound data transfer is billed separately|
|**Builds**|For source-based deployments, App Runner charges for build time (if auto-build is enabled)|

Sample pricing (as of 2024):

- vCPU: $0.064/hour
    
- Memory: $0.007/hour
    
- Request: $1.00 per 1 million requests
    

---
