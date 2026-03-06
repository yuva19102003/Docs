# Compute Services - Best Practices

Production-ready guidelines for all GCP compute services.

---

## 📋 Table of Contents

1. [General Best Practices](#general-best-practices)
2. [Compute Engine](#compute-engine)
3. [GKE](#gke)
4. [Cloud Run](#cloud-run)
5. [App Engine](#app-engine)
6. [Cloud Functions](#cloud-functions)
7. [Security](#security)
8. [Cost Optimization](#cost-optimization)
9. [Monitoring & Operations](#monitoring--operations)

---

## General Best Practices

### Architecture

✅ Design for failure  
✅ Use managed services when possible  
✅ Implement auto-scaling  
✅ Use multiple zones/regions for HA  
✅ Separate environments (dev, staging, prod)  
✅ Use infrastructure as code  
✅ Implement proper networking  
✅ Use service accounts with least privilege  
✅ Enable logging and monitoring  
✅ Document architecture and runbooks  

### Development

✅ Use version control  
✅ Implement CI/CD pipelines  
✅ Use container images  
✅ Tag resources properly  
✅ Use environment variables for config  
✅ Store secrets securely  
✅ Implement health checks  
✅ Handle graceful shutdown  
✅ Write comprehensive tests  
✅ Document APIs and services  

### Operations

✅ Automate deployments  
✅ Implement blue/green or canary deployments  
✅ Use traffic splitting for rollouts  
✅ Monitor key metrics  
✅ Set up alerts  
✅ Implement log aggregation  
✅ Regular backups  
✅ Disaster recovery plan  
✅ Security scanning  
✅ Regular updates and patches  

---

## Compute Engine

### High Availability

```bash
# Use regional managed instance groups
gcloud compute instance-groups managed create web-group \
  --base-instance-name=web \
  --template=web-template \
  --size=6 \
  --region=us-central1 \
  --distribution-policy-zones=us-central1-a,us-central1-b,us-central1-c
```

✅ Use regional MIGs  
✅ Distribute across multiple zones  
✅ Implement health checks  
✅ Use load balancing  
✅ Enable auto-healing  
✅ Use persistent disks for data  
✅ Regular snapshots  
✅ Test failover procedures  

### Performance

✅ Choose appropriate machine types  
✅ Use SSD persistent disks for databases  
✅ Use local SSDs for temporary data  
✅ Optimize network throughput  
✅ Use placement policies for low latency  
✅ Enable CPU overcommit for burstable workloads  
✅ Use committed use discounts  
✅ Monitor and right-size instances  

### Security

```bash
# Use Shielded VMs
gcloud compute instances create secure-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring

# Enable OS Login
gcloud compute project-info add-metadata \
  --metadata enable-oslogin=TRUE
```

✅ Use Shielded VMs  
✅ Enable OS Login  
✅ Use service accounts with least privilege  
✅ Implement network segmentation  
✅ Use private Google access  
✅ Enable VPC Flow Logs  
✅ Regular security updates  
✅ Use Secret Manager for credentials  

### Cost Optimization

✅ Use Spot VMs for fault-tolerant workloads  
✅ Use committed use discounts  
✅ Right-size instances  
✅ Stop instances when not needed  
✅ Use appropriate disk types  
✅ Delete unused persistent disks  
✅ Use snapshots for backups  
✅ Monitor and optimize costs  

---

## GKE

### Cluster Configuration

```bash
# Production cluster
gcloud container clusters create prod-cluster \
  --region=us-central1 \
  --num-nodes=1 \
  --machine-type=n2-standard-4 \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=30 \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-ip-alias \
  --network=my-vpc \
  --subnetwork=my-subnet \
  --workload-pool=my-project.svc.id.goog \
  --enable-shielded-nodes \
  --enable-network-policy
```

✅ Use regional clusters  
✅ Enable auto-repair and auto-upgrade  
✅ Use VPC-native clusters  
✅ Enable Workload Identity  
✅ Implement network policies  
✅ Use private clusters  
✅ Enable Binary Authorization  
✅ Use node auto-provisioning  

### Workload Management

```yaml
# Resource requests and limits
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

# Liveness and readiness probes
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

✅ Set resource requests and limits  
✅ Implement health checks  
✅ Use horizontal pod autoscaling  
✅ Use pod disruption budgets  
✅ Implement proper logging  
✅ Use namespaces for isolation  
✅ Use resource quotas  
✅ Implement pod security policies  

### Security

✅ Use Workload Identity  
✅ Implement RBAC  
✅ Enable Binary Authorization  
✅ Use network policies  
✅ Enable audit logging  
✅ Use private clusters  
✅ Scan container images  
✅ Use admission controllers  

### Cost Optimization

✅ Use Autopilot mode for variable workloads  
✅ Use Spot VMs for fault-tolerant workloads  
✅ Right-size pod resource requests  
✅ Use cluster autoscaler  
✅ Use node auto-provisioning  
✅ Delete unused clusters  
✅ Monitor and optimize resource usage  

---

## Cloud Run

### Service Configuration

```bash
# Production service
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v1 \
  --region=us-central1 \
  --platform=managed \
  --memory=512Mi \
  --cpu=1 \
  --timeout=300 \
  --max-instances=100 \
  --min-instances=1 \
  --concurrency=80 \
  --service-account=my-sa@my-project.iam.gserviceaccount.com \
  --vpc-connector=my-connector \
  --vpc-egress=private-ranges-only \
  --no-allow-unauthenticated
```

✅ Set appropriate resource limits  
✅ Use minimum instances for critical services  
✅ Set appropriate concurrency  
✅ Use VPC connectors for private resources  
✅ Require authentication  
✅ Use service accounts with least privilege  
✅ Implement health checks  
✅ Handle graceful shutdown  

### Container Optimization

```dockerfile
# Multi-stage build
FROM node:18-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:18-slim
WORKDIR /app
COPY --from=builder /app .
EXPOSE 8080
CMD ["node", "server.js"]
```

✅ Use multi-stage Docker builds  
✅ Minimize container image size  
✅ Use lighter base images  
✅ Optimize startup time  
✅ Implement proper logging  
✅ Handle SIGTERM gracefully  
✅ Use connection pooling  

### Traffic Management

```bash
# Canary deployment
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v2 \
  --region=us-central1 \
  --no-traffic \
  --tag=canary

gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-tags=canary=10 \
  --to-revisions=LATEST=90
```

✅ Use traffic splitting for deployments  
✅ Tag revisions  
✅ Test before full rollout  
✅ Implement rollback procedures  
✅ Monitor error rates during rollouts  

### Cost Optimization

✅ Scale to zero when possible  
✅ Optimize container startup time  
✅ Right-size resources  
✅ Use appropriate concurrency  
✅ Enable CPU throttling  
✅ Optimize request handling time  
✅ Use caching  
✅ Monitor and optimize costs  

---

## App Engine

### Application Configuration

```yaml
# app.yaml
runtime: python311
instance_class: F2

automatic_scaling:
  target_cpu_utilization: 0.65
  min_instances: 2
  max_instances: 20
  min_pending_latency: 30ms
  max_pending_latency: automatic
  max_concurrent_requests: 80

handlers:
- url: /static
  static_dir: static
  secure: always
  expiration: "1d"

- url: /.*
  script: auto
  secure: always
```

✅ Use appropriate instance class  
✅ Set min/max instances  
✅ Use automatic scaling  
✅ Serve static content efficiently  
✅ Enable HTTPS only  
✅ Use appropriate runtime  
✅ Implement caching  

### Service Management

✅ Use multiple services for separation  
✅ Implement traffic splitting  
✅ Use versions for rollback  
✅ Delete old versions  
✅ Use cron jobs for scheduled tasks  
✅ Use task queues for async work  
✅ Implement proper logging  

### Security

✅ Use service accounts with least privilege  
✅ Store secrets in Secret Manager  
✅ Implement authentication  
✅ Use firewall rules  
✅ Enable audit logging  
✅ Regular security updates  

### Cost Optimization

✅ Use Standard environment when possible  
✅ Set appropriate max instances  
✅ Optimize instance class  
✅ Delete unused versions  
✅ Use caching to reduce compute  
✅ Monitor and optimize costs  

---

## Cloud Functions

### Function Configuration

```bash
# Production function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --memory=512Mi \
  --cpu=1 \
  --timeout=300 \
  --max-instances=100 \
  --min-instances=1 \
  --concurrency=100 \
  --service-account=my-sa@my-project.iam.gserviceaccount.com \
  --vpc-connector=my-connector \
  --trigger-http \
  --no-allow-unauthenticated
```

✅ Use 2nd generation when possible  
✅ Right-size memory allocation  
✅ Set appropriate timeout  
✅ Use minimum instances for critical functions  
✅ Set appropriate concurrency  
✅ Use service accounts with least privilege  
✅ Require authentication  

### Code Optimization

```python
# Reuse connections
import google.auth
from google.cloud import storage

# Initialize outside handler
credentials, project = google.auth.default()
storage_client = storage.Client(credentials=credentials)

def my_function(request):
    # Reuse storage_client
    bucket = storage_client.bucket('my-bucket')
    # Process request
    return 'OK'
```

✅ Minimize cold start time  
✅ Reuse connections  
✅ Use global variables for reuse  
✅ Optimize dependencies  
✅ Implement caching  
✅ Handle errors gracefully  
✅ Implement idempotency  

### Event Handling

✅ Use appropriate trigger type  
✅ Implement retry logic  
✅ Use dead letter queues  
✅ Handle duplicate events  
✅ Validate input  
✅ Implement proper logging  
✅ Monitor error rates  

### Cost Optimization

✅ Right-size memory allocation  
✅ Optimize execution time  
✅ Use appropriate timeout  
✅ Minimize cold starts  
✅ Use caching  
✅ Batch operations  
✅ Monitor and optimize costs  

---

## Security

### Identity & Access Management

```bash
# Create service account
gcloud iam service-accounts create app-sa \
  --display-name="Application Service Account"

# Grant minimal permissions
gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:app-sa@my-project.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

✅ Use service accounts with least privilege  
✅ Implement Workload Identity (GKE)  
✅ Use IAM conditions  
✅ Regular access reviews  
✅ Enable audit logging  
✅ Use organization policies  

### Secrets Management

```bash
# Store secrets
echo -n "my-secret" | gcloud secrets create app-secret --data-file=-

# Grant access
gcloud secrets add-iam-policy-binding app-secret \
  --member="serviceAccount:app-sa@my-project.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

✅ Use Secret Manager  
✅ Never commit secrets to code  
✅ Rotate secrets regularly  
✅ Use different secrets per environment  
✅ Audit secret access  

### Network Security

✅ Use VPC networks  
✅ Implement firewall rules  
✅ Use private Google access  
✅ Enable VPC Flow Logs  
✅ Use Cloud Armor for DDoS protection  
✅ Implement network policies (GKE)  
✅ Use private clusters  
✅ Enable Binary Authorization  

### Application Security

✅ Validate all input  
✅ Implement rate limiting  
✅ Use HTTPS only  
✅ Implement authentication  
✅ Use CORS properly  
✅ Scan container images  
✅ Regular security updates  
✅ Implement security headers  

---

## Cost Optimization

### General Strategies

✅ Right-size resources  
✅ Use auto-scaling  
✅ Delete unused resources  
✅ Use appropriate pricing models  
✅ Monitor and optimize costs  
✅ Use labels for cost tracking  
✅ Set budget alerts  
✅ Regular cost reviews  

### Compute Engine

✅ Use Spot VMs (up to 91% off)  
✅ Use committed use discounts (up to 57% off)  
✅ Use sustained use discounts (automatic)  
✅ Right-size instances  
✅ Stop instances when not needed  
✅ Use appropriate disk types  
✅ Delete unused disks  

### GKE

✅ Use Autopilot mode  
✅ Use Spot node pools  
✅ Enable cluster autoscaling  
✅ Right-size pod requests  
✅ Use node auto-provisioning  
✅ Delete unused clusters  
✅ Monitor resource usage  

### Serverless (Cloud Run, App Engine, Cloud Functions)

✅ Scale to zero  
✅ Optimize execution time  
✅ Right-size resources  
✅ Use appropriate concurrency  
✅ Implement caching  
✅ Batch operations  
✅ Use minimum instances sparingly  

---

## Monitoring & Operations

### Logging

```python
# Structured logging
import json
import logging

logging.info(json.dumps({
    'severity': 'INFO',
    'message': 'Request processed',
    'user_id': user_id,
    'duration': duration,
    'status': 200
}))
```

✅ Use structured logging  
✅ Include correlation IDs  
✅ Log at appropriate levels  
✅ Don't log sensitive data  
✅ Use log-based metrics  
✅ Implement log retention policies  

### Monitoring

```bash
# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Error Rate" \
  --condition-display-name="Error rate > 5%" \
  --condition-threshold-value=0.05 \
  --condition-threshold-duration=300s
```

✅ Monitor key metrics  
✅ Set up alerts  
✅ Use dashboards  
✅ Implement SLOs  
✅ Monitor error rates  
✅ Track latency  
✅ Monitor resource usage  
✅ Regular reviews  

### Incident Response

✅ Document runbooks  
✅ Implement on-call rotation  
✅ Use incident management tools  
✅ Conduct post-mortems  
✅ Implement rollback procedures  
✅ Test disaster recovery  
✅ Regular drills  

### CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build
        run: docker build -t gcr.io/$PROJECT/app:$SHA .
      
      - name: Push
        run: docker push gcr.io/$PROJECT/app:$SHA
      
      - name: Deploy
        run: |
          gcloud run deploy app \
            --image=gcr.io/$PROJECT/app:$SHA \
            --region=us-central1
```

✅ Automate deployments  
✅ Use infrastructure as code  
✅ Implement testing  
✅ Use blue/green or canary deployments  
✅ Implement rollback procedures  
✅ Use version control  
✅ Document processes  

---

## Summary

### Key Takeaways

✅ Choose the right compute service for your workload  
✅ Design for failure and high availability  
✅ Implement security best practices  
✅ Optimize costs continuously  
✅ Monitor and alert on key metrics  
✅ Automate operations  
✅ Document everything  
✅ Regular reviews and improvements  

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
