# 7️⃣ Compute Services - Overview

Learn where to run your applications on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Compute Options Comparison](#compute-options-comparison)
3. [Decision Tree](#decision-tree)
4. [Service Categories](#service-categories)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Comparison](#cost-comparison)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP offers multiple compute options to run your applications, from traditional VMs to serverless containers. Choose based on your requirements for control, scalability, and management overhead.

### Compute Spectrum

```
More Control                                    Less Management
    |                                                  |
    v                                                  v
┌─────────────┬──────────────┬──────────────┬─────────────┬──────────────┐
│  Compute    │     GKE      │   Cloud Run  │ App Engine  │   Cloud      │
│   Engine    │ (Kubernetes) │ (Containers) │   (PaaS)    │  Functions   │
│   (IaaS)    │   (CaaS)     │              │             │ (Serverless) │
└─────────────┴──────────────┴──────────────┴─────────────┴──────────────┘
```

---

## Compute Options Comparison

### Feature Matrix

| Feature | Compute Engine | GKE | Cloud Run | App Engine | Cloud Functions |
|---------|---------------|-----|-----------|------------|-----------------|
| **Type** | IaaS | CaaS | Serverless Containers | PaaS | FaaS |
| **Control** | Full | High | Medium | Low | Minimal |
| **Scaling** | Manual/Auto | Auto | Auto | Auto | Auto |
| **Cold Start** | None | None | ~1s | ~5s | ~1s |
| **Min Instances** | 1 | 1 | 0 | 1 | 0 |
| **Max Instances** | Unlimited | Unlimited | 1000 | Unlimited | 1000 |
| **Pricing** | Per second | Per second | Per 100ms | Per hour | Per 100ms |
| **Free Tier** | Yes | No | Yes | Yes | Yes |
| **Custom Runtime** | Yes | Yes | Yes | Limited | No |
| **Stateful** | Yes | Yes | Limited | Limited | No |
| **GPU Support** | Yes | Yes | No | No | No |
| **SSH Access** | Yes | Yes | No | No | No |

---

## Decision Tree

```
Start: What do you need to run?
    |
    ├─> Need full OS control? ──> Compute Engine
    |
    ├─> Running containers?
    |   ├─> Need orchestration? ──> GKE
    |   └─> Simple container? ──> Cloud Run
    |
    ├─> Web application?
    |   ├─> Need custom runtime? ──> Compute Engine / Cloud Run
    |   └─> Standard runtime? ──> App Engine
    |
    └─> Event-driven function? ──> Cloud Functions
```

### Detailed Decision Criteria

**Choose Compute Engine when:**
- Need full control over OS and infrastructure
- Running legacy applications
- Require specific hardware (GPUs, custom CPUs)
- Need persistent local storage
- Running Windows workloads

**Choose GKE when:**
- Running microservices architecture
- Need container orchestration
- Multi-cloud portability required
- Complex deployment patterns
- Need service mesh (Istio)

**Choose Cloud Run when:**
- Running stateless containers
- Need automatic scaling to zero
- Pay-per-use pricing preferred
- Simple deployment required
- HTTP-based workloads

**Choose App Engine when:**
- Building web applications
- Need managed platform
- Standard runtimes sufficient
- Integrated services needed
- Quick deployment required

**Choose Cloud Functions when:**
- Event-driven workloads
- Lightweight processing
- Serverless preferred
- Short-lived executions
- Simple single-purpose functions

---

## Service Categories

### 1. Infrastructure as a Service (IaaS)

**Compute Engine**
- Virtual machines in the cloud
- Full control over OS and configuration
- Persistent disks and local SSDs
- Custom machine types
- Preemptible and Spot VMs

```
┌─────────────────────────────────────┐
│      Compute Engine Instance        │
├─────────────────────────────────────┤
│  Your Application                   │
│  Your Runtime                       │
│  Your OS (Linux/Windows)            │
├─────────────────────────────────────┤
│  Google Manages:                    │
│  - Physical hardware                │
│  - Network infrastructure           │
│  - Security patches (optional)      │
└─────────────────────────────────────┘
```

### 2. Container as a Service (CaaS)

**Google Kubernetes Engine (GKE)**
- Managed Kubernetes clusters
- Container orchestration
- Auto-scaling and auto-repair
- Multi-zone and regional clusters
- Workload identity and security

```
┌─────────────────────────────────────┐
│         GKE Cluster                 │
├─────────────────────────────────────┤
│  Your Containers                    │
│  Your Configuration                 │
├─────────────────────────────────────┤
│  Google Manages:                    │
│  - Kubernetes control plane         │
│  - Node pools                       │
│  - Networking                       │
│  - Upgrades                         │
└─────────────────────────────────────┘
```

### 3. Platform as a Service (PaaS)

**App Engine**
- Fully managed application platform
- Standard and Flexible environments
- Built-in services (Memcache, Task Queue)
- Traffic splitting and versioning
- Automatic scaling

```
┌─────────────────────────────────────┐
│         App Engine                  │
├─────────────────────────────────────┤
│  Your Application Code              │
├─────────────────────────────────────┤
│  Google Manages:                    │
│  - Runtime environment              │
│  - Scaling                          │
│  - Load balancing                   │
│  - Monitoring                       │
│  - Infrastructure                   │
└─────────────────────────────────────┘
```

### 4. Serverless Containers

**Cloud Run**
- Fully managed serverless containers
- Scale to zero
- Pay per use
- Any language, any library
- Built on Knative

```
┌─────────────────────────────────────┐
│          Cloud Run                  │
├─────────────────────────────────────┤
│  Your Container                     │
├─────────────────────────────────────┤
│  Google Manages:                    │
│  - Container runtime                │
│  - Auto-scaling (0-1000)            │
│  - Load balancing                   │
│  - HTTPS endpoints                  │
│  - Infrastructure                   │
└─────────────────────────────────────┘
```

### 5. Function as a Service (FaaS)

**Cloud Functions**
- Event-driven serverless functions
- Automatic scaling
- Pay per invocation
- Integrated with GCP services
- 1st and 2nd gen runtimes

```
┌─────────────────────────────────────┐
│       Cloud Functions               │
├─────────────────────────────────────┤
│  Your Function Code                 │
├─────────────────────────────────────┤
│  Google Manages:                    │
│  - Runtime environment              │
│  - Scaling                          │
│  - Event triggers                   │
│  - Infrastructure                   │
│  - Everything else                  │
└─────────────────────────────────────┘
```

---

## Architecture Patterns

### Pattern 1: Traditional Web Application

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer           │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌────────┐   ┌────────┐
│ VM 1   │   │ VM 2   │  <-- Compute Engine
│ Web    │   │ Web    │
│ Server │   │ Server │
└────┬───┘   └───┬────┘
     |           |
     └─────┬─────┘
           v
    ┌──────────────┐
    │  Cloud SQL   │
    └──────────────┘
```

**Use Case:** Traditional monolithic applications, legacy systems

### Pattern 2: Microservices on Kubernetes

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer           │
└──────────┬──────────┘
           |
    ┌──────┴──────────────────┐
    │   GKE Cluster           │
    │  ┌──────────────────┐   │
    │  │  Ingress         │   │
    │  └────────┬─────────┘   │
    │           |              │
    │  ┌────────┴─────────┐   │
    │  │  Service Mesh    │   │
    │  │  (Istio)         │   │
    │  └────────┬─────────┘   │
    │           |              │
    │  ┌────┬───┴───┬────┐    │
    │  │Svc1│ Svc2  │Svc3│    │
    │  └────┴───────┴────┘    │
    └─────────────────────────┘
```

**Use Case:** Microservices, complex applications, multi-team development

### Pattern 3: Serverless Architecture

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer           │
└──────────┬──────────┘
           |
    ┌──────┴──────┐
    v             v
┌──────────┐  ┌──────────┐
│ Cloud    │  │ Cloud    │
│ Run      │  │ Run      │
│ Service1 │  │ Service2 │
└────┬─────┘  └─────┬────┘
     |              |
     └──────┬───────┘
            v
    ┌───────────────┐
    │  Firestore    │
    └───────────────┘
```

**Use Case:** Modern applications, variable traffic, cost optimization

### Pattern 4: Event-Driven Processing

```
┌──────────────┐
│  Cloud       │
│  Storage     │
└──────┬───────┘
       |
       | (Event)
       v
┌──────────────┐      ┌──────────────┐
│  Cloud       │─────>│  Cloud       │
│  Functions   │      │  Pub/Sub     │
└──────────────┘      └──────┬───────┘
                             |
                             v
                      ┌──────────────┐
                      │  BigQuery    │
                      └──────────────┘
```

**Use Case:** Data processing, ETL, event handling

### Pattern 5: Hybrid Architecture

```
┌─────────────────────────────────────┐
│  Frontend (App Engine)              │
└──────────────┬──────────────────────┘
               |
    ┌──────────┴──────────┐
    v                     v
┌──────────┐      ┌──────────────┐
│ Cloud    │      │  Compute     │
│ Run      │      │  Engine      │
│ (API)    │      │  (Legacy)    │
└────┬─────┘      └──────┬───────┘
     |                   |
     └─────────┬─────────┘
               v
        ┌──────────────┐
        │  Cloud SQL   │
        └──────────────┘
```

**Use Case:** Gradual migration, mixed workloads

---

## Cost Comparison

### Monthly Cost Example (us-central1)

**Scenario:** Web application with 2 vCPUs, 8GB RAM, running 24/7

| Service | Configuration | Monthly Cost | Notes |
|---------|--------------|--------------|-------|
| **Compute Engine** | n1-standard-2 | ~$49 | Sustained use discount |
| **Compute Engine** | e2-standard-2 | ~$33 | Cheaper machine type |
| **Compute Engine** | Spot VM | ~$10 | Can be preempted |
| **GKE** | 1 node (e2-standard-2) | ~$73 | Includes cluster fee |
| **Cloud Run** | 2 vCPU, 8GB, 1M requests | ~$50 | Pay per use |
| **App Engine** | F2 instance, 24/7 | ~$120 | Flexible environment |
| **Cloud Functions** | 1M invocations, 512MB | ~$5 | Event-driven only |

### Cost Optimization Strategies

**Compute Engine:**
- Use committed use discounts (up to 57% off)
- Use sustained use discounts (automatic)
- Use Spot VMs for fault-tolerant workloads (up to 91% off)
- Right-size instances
- Use preemptible VMs for batch processing

**GKE:**
- Use Autopilot mode (pay only for pods)
- Enable cluster autoscaling
- Use Spot VMs for node pools
- Right-size pod requests
- Use node auto-provisioning

**Cloud Run:**
- Set minimum instances to 0
- Optimize container startup time
- Use concurrency settings
- Set appropriate CPU allocation
- Use request timeout limits

**App Engine:**
- Use automatic scaling
- Set max instances limit
- Use Standard environment when possible
- Optimize instance class
- Use traffic splitting for gradual rollouts

**Cloud Functions:**
- Optimize memory allocation
- Reduce cold starts
- Use appropriate timeout
- Batch operations when possible
- Use Pub/Sub for async processing

---

## Quick Reference

### Compute Engine

```bash
# Create VM instance
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud

# SSH into instance
gcloud compute ssh my-vm --zone=us-central1-a

# Stop instance
gcloud compute instances stop my-vm --zone=us-central1-a

# Delete instance
gcloud compute instances delete my-vm --zone=us-central1-a
```

### GKE

```bash
# Create cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3

# Get credentials
gcloud container clusters get-credentials my-cluster \
  --zone=us-central1-a

# Deploy application
kubectl apply -f deployment.yaml

# Delete cluster
gcloud container clusters delete my-cluster --zone=us-central1-a
```

### Cloud Run

```bash
# Deploy container
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-image \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated

# Update service
gcloud run services update my-service \
  --region=us-central1 \
  --memory=512Mi

# Delete service
gcloud run services delete my-service --region=us-central1
```

### App Engine

```bash
# Deploy application
gcloud app deploy app.yaml

# View application
gcloud app browse

# View logs
gcloud app logs tail

# Set traffic split
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5
```

### Cloud Functions

```bash
# Deploy function
gcloud functions deploy my-function \
  --runtime=python39 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=main

# Call function
gcloud functions call my-function

# View logs
gcloud functions logs read my-function

# Delete function
gcloud functions delete my-function
```

---

## Service Limits

### Compute Engine

| Resource | Default Limit | Notes |
|----------|--------------|-------|
| CPUs per region | 24 | Can request increase |
| Instances per region | 24 | Can request increase |
| Persistent disk size | 64 TB | Per disk |
| Local SSD | 9 TB | Per instance |
| Network egress | 7 Gbps | Per vCPU |

### GKE

| Resource | Default Limit | Notes |
|----------|--------------|-------|
| Clusters per project | 50 | Soft limit |
| Nodes per cluster | 15,000 | Standard mode |
| Pods per node | 110 | Default |
| Services per cluster | 10,000 | Recommended |
| Namespaces per cluster | 10,000 | Recommended |

### Cloud Run

| Resource | Default Limit | Notes |
|----------|--------------|-------|
| Services per region | 1,000 | Soft limit |
| Concurrent requests | 1,000 | Per container |
| Memory | 32 GB | Maximum |
| CPUs | 8 | Maximum |
| Request timeout | 60 minutes | Maximum |

### App Engine

| Resource | Default Limit | Notes |
|----------|--------------|-------|
| Applications per project | 1 | Hard limit |
| Services per application | 105 | Soft limit |
| Versions per service | 210 | Soft limit |
| Instances per version | 200 | Automatic scaling |
| Request size | 32 MB | Maximum |

### Cloud Functions

| Resource | Default Limit | Notes |
|----------|--------------|-------|
| Functions per project | 1,000 | Per region |
| Concurrent executions | 1,000 | Per function |
| Memory | 8 GB | Maximum |
| Timeout | 60 minutes | 2nd gen |
| Deployment size | 100 MB | Compressed |

---

## Best Practices

### General

✅ Choose the right compute option for your workload  
✅ Use managed services when possible  
✅ Implement auto-scaling  
✅ Use health checks  
✅ Enable logging and monitoring  
✅ Implement proper security (IAM, VPC)  
✅ Use infrastructure as code (Terraform)  
✅ Tag resources for cost tracking  
✅ Implement disaster recovery  
✅ Regular security updates  

### Performance

✅ Choose appropriate machine types  
✅ Use regional resources for HA  
✅ Implement caching strategies  
✅ Optimize container images  
✅ Use CDN for static content  
✅ Implement connection pooling  
✅ Monitor and optimize costs  
✅ Use appropriate storage types  
✅ Implement rate limiting  
✅ Load test before production  

### Security

✅ Use service accounts with least privilege  
✅ Enable VPC Service Controls  
✅ Use private Google access  
✅ Implement network policies  
✅ Enable audit logging  
✅ Use Secret Manager for credentials  
✅ Implement DDoS protection  
✅ Regular security scanning  
✅ Use HTTPS/TLS everywhere  
✅ Implement authentication and authorization  

---

## Next Steps

1. **[Compute Engine](1-Compute-Engine.md)** - Virtual machines and infrastructure
2. **[Google Kubernetes Engine](2-GKE.md)** - Container orchestration
3. **[Cloud Run](3-Cloud-Run.md)** - Serverless containers
4. **[App Engine](4-App-Engine.md)** - Platform as a Service
5. **[Cloud Functions](5-Cloud-Functions.md)** - Serverless functions
6. **[Compute Comparison](6-Compute-Comparison.md)** - Detailed comparison
7. **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [App Engine Documentation](https://cloud.google.com/appengine/docs)
- [Cloud Functions Documentation](https://cloud.google.com/functions/docs)
- [Pricing Calculator](https://cloud.google.com/products/calculator)
- [Architecture Center](https://cloud.google.com/architecture)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
