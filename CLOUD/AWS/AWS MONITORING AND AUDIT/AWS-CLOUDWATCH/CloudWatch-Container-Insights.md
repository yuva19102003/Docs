
## 🔍 What is CloudWatch Container Insights?

**CloudWatch Container Insights** helps you monitor, troubleshoot, and optimize containerized applications. It automatically collects metrics like:

- **CPU, memory, network, and disk I/O usage**
    
- **Container-level logs**
    
- **Performance at task/pod, service, and cluster level**
    
- **ECS/EKS infrastructure and app telemetry**
    

---

## ✅ What It Works With:

- Amazon **ECS** (Fargate or EC2)
    
- Amazon **EKS**
    
- **Kubernetes** clusters on EC2
    
- **Docker** running on EC2 (with agent)
    

---

## 🧱 Example: Enable Container Insights on ECS (Fargate or EC2)

### 🎯 Goal

Set up **CloudWatch Container Insights** on ECS and view metrics and logs.

---

### 🚀 Step 1: Enable Insights via AWS CLI

Enable for a specific region:

```bash
aws ecs update-cluster-settings \
  --cluster your-cluster-name \
  --settings name=containerInsights,value=enabled
```

---

### 📦 Step 2: Create a Task Definition with CloudWatch Logs

```json
{
  "containerDefinitions": [
    {
      "name": "my-app",
      "image": "nginx",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "family": "my-app-task"
}
```

---

### 🛠 Step 3: IAM Role Permissions for CloudWatch

Make sure the ECS task execution role has these permissions:

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:CreateLogGroup"
  ],
  "Resource": "*"
}
```

---

### 📊 Step 4: View Insights in Console

Navigate to:

```
CloudWatch Console → Container Insights → Performance Monitoring
```

You’ll see:

- CPU & memory usage
    
- Network I/O per container
    
- Task/Pod performance
    
- ECS Service/Task/Cluster overview
    

---

## 🧠 Bonus: Enable on EKS with `cloudwatch-agent` DaemonSet

### Helm install (for EKS)

```bash
helm repo add aws-cloudwatch https://aws.github.io/eks-charts
helm install cloudwatch-agent aws-cloudwatch/cloudwatch-agent \
  --set cloudwatch.region=us-east-1 \
  --set clusterName=your-cluster-name \
  --set serviceAccount.create=true \
  --set serviceAccount.name=cloudwatch-agent \
  --namespace amazon-cloudwatch \
  --create-namespace
```

You’ll start seeing metrics like:

- Node-level CPU/mem
    
- Pod-level performance
    
- Cluster-wide aggregates
    

---

## 📍 Summary

|Feature|ECS|EKS|
|---|---|---|
|CPU/memory metrics|✅|✅|
|Auto log collection|✅|✅|
|DaemonSet required|❌|✅|
|Console UI (Insights)|✅|✅|
|Alerts (via Alarms)|✅|✅|

---
