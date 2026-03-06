# Cloud Run - Serverless Containers

Complete guide to Cloud Run - fully managed serverless platform for containers.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Service Deployment](#service-deployment)
3. [Container Requirements](#container-requirements)
4. [Configuration](#configuration)
5. [Traffic Management](#traffic-management)
6. [Networking](#networking)
7. [Security](#security)
8. [Scaling](#scaling)
9. [Monitoring](#monitoring)
10. [Cost Optimization](#cost-optimization)
11. [Best Practices](#best-practices)

---

## Introduction

Cloud Run is a fully managed platform that runs stateless containers via HTTP requests or Pub/Sub events.

### Key Features

✅ Fully managed serverless  
✅ Scale to zero  
✅ Pay per use (100ms billing)  
✅ Any language, any library  
✅ Built on Knative  
✅ Automatic HTTPS  
✅ Custom domains  
✅ Traffic splitting  
✅ WebSockets support  
✅ gRPC support  

### Architecture

```
Internet/Pub/Sub
       |
       v
┌─────────────────────────────────────┐
│    Cloud Run Service                │
├─────────────────────────────────────┤
│  Load Balancer (Managed)            │
│         |                           │
│    ┌────┴────┐                      │
│    v         v                      │
│  ┌────┐   ┌────┐   ┌────┐          │
│  │ C1 │   │ C2 │...│ Cn │          │
│  └────┘   └────┘   └────┘          │
│  (Auto-scaled 0-1000)               │
└─────────────────────────────────────┘
```

---

## Service Deployment

### Deploy from Source

```bash
# Deploy from source code
gcloud run deploy my-service \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated
```

### Deploy from Container Image

```bash
# Build and push image
docker build -t gcr.io/my-project/my-app:v1 .
docker push gcr.io/my-project/my-app:v1

# Deploy
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v1 \
  --region=us-central1 \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --memory=512Mi \
  --cpu=1 \
  --timeout=300 \
  --max-instances=100 \
  --min-instances=0 \
  --concurrency=80 \
  --set-env-vars="ENV=production,DEBUG=false"
```

### Deploy with YAML

**service.yaml:**
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-service
  annotations:
    run.googleapis.com/ingress: all
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "0"
        autoscaling.knative.dev/maxScale: "100"
        run.googleapis.com/cpu-throttling: "true"
    spec:
      containerConcurrency: 80
      timeoutSeconds: 300
      serviceAccountName: my-sa@my-project.iam.gserviceaccount.com
      containers:
      - image: gcr.io/my-project/my-app:v1
        ports:
        - name: http1
          containerPort: 8080
        env:
        - name: ENV
          value: "production"
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
        startupProbe:
          httpGet:
            path: /health
          initialDelaySeconds: 0
          periodSeconds: 1
          failureThreshold: 3
```

```bash
# Deploy from YAML
gcloud run services replace service.yaml --region=us-central1
```

### Terraform Example

```hcl
resource "google_cloud_run_service" "default" {
  name     = "my-service"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/my-project/my-app:v1"
        
        ports {
          container_port = 8080
        }

        env {
          name  = "ENV"
          value = "production"
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }

      container_concurrency = 80
      timeout_seconds       = 300
      service_account_name  = google_service_account.cloudrun.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "100"
        "run.googleapis.com/cpu-throttling" = "true"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```

---

## Container Requirements

### Dockerfile Example

```dockerfile
# Use official Node.js runtime
FROM node:18-slim

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose port (Cloud Run uses PORT env var)
EXPOSE 8080

# Start app
CMD [ "node", "server.js" ]
```

### Application Code

**server.js:**
```javascript
const express = require('express');
const app = express();

// Cloud Run sets PORT env variable
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Cloud Run!' });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
```

### Container Requirements

✅ Listen on `0.0.0.0` on port defined by `PORT` env var  
✅ Stateless (no local disk persistence)  
✅ Respond to requests within timeout (default 300s)  
✅ Handle graceful shutdown (SIGTERM)  
✅ Container size < 10 GB  
✅ Start within 4 minutes  

---

## Configuration

### Resource Limits

```bash
# Set CPU and memory
gcloud run services update my-service \
  --region=us-central1 \
  --cpu=2 \
  --memory=1Gi
```

**Available CPU:**
- 0.08 (80 millicpu)
- 1, 2, 4, 6, 8 vCPUs

**Available Memory:**
- 128Mi to 32Gi

### Environment Variables

```bash
# Set environment variables
gcloud run services update my-service \
  --region=us-central1 \
  --set-env-vars="KEY1=value1,KEY2=value2"

# Update from file
gcloud run services update my-service \
  --region=us-central1 \
  --env-vars-file=env.yaml
```

**env.yaml:**
```yaml
KEY1: value1
KEY2: value2
DATABASE_URL: postgresql://...
```

### Secrets

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Mount secret as environment variable
gcloud run services update my-service \
  --region=us-central1 \
  --set-secrets="DB_PASSWORD=my-secret:latest"

# Mount secret as volume
gcloud run services update my-service \
  --region=us-central1 \
  --set-secrets="/secrets/db-password=my-secret:latest"
```

### Concurrency

```bash
# Set concurrent requests per container
gcloud run services update my-service \
  --region=us-central1 \
  --concurrency=80
```

**Concurrency Guidelines:**
- Default: 80
- Max: 1000
- CPU-bound: 1-10
- I/O-bound: 80-1000

### Timeout

```bash
# Set request timeout
gcloud run services update my-service \
  --region=us-central1 \
  --timeout=300
```

**Timeout Limits:**
- Default: 300 seconds (5 minutes)
- Max: 3600 seconds (60 minutes)

---

## Traffic Management

### Revisions

```bash
# List revisions
gcloud run revisions list --service=my-service --region=us-central1

# Deploy new revision
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v2 \
  --region=us-central1 \
  --no-traffic

# Split traffic
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-revisions=my-service-v2=50,my-service-v1=50

# Rollback
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-revisions=my-service-v1=100
```

### Blue/Green Deployment

```bash
# Deploy new version without traffic
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v2 \
  --region=us-central1 \
  --no-traffic \
  --tag=blue

# Test blue version
curl https://blue---my-service-xxx.run.app

# Switch traffic
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-tags=blue=100
```

### Canary Deployment

```bash
# Deploy canary
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:v2 \
  --region=us-central1 \
  --no-traffic \
  --tag=canary

# Route 10% to canary
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-tags=canary=10 \
  --to-revisions=LATEST=90

# Gradually increase
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-tags=canary=50 \
  --to-revisions=LATEST=50

# Full rollout
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-latest
```

---

## Networking

### Custom Domains

```bash
# Map custom domain
gcloud run domain-mappings create \
  --service=my-service \
  --domain=api.example.com \
  --region=us-central1

# List domain mappings
gcloud run domain-mappings list --region=us-central1
```

### VPC Connector

```bash
# Create VPC connector
gcloud compute networks vpc-access connectors create my-connector \
  --region=us-central1 \
  --network=my-vpc \
  --range=10.8.0.0/28

# Use connector
gcloud run services update my-service \
  --region=us-central1 \
  --vpc-connector=my-connector \
  --vpc-egress=private-ranges-only
```

### Ingress Control

```bash
# Allow all traffic
gcloud run services update my-service \
  --region=us-central1 \
  --ingress=all

# Internal only
gcloud run services update my-service \
  --region=us-central1 \
  --ingress=internal

# Internal and Cloud Load Balancing
gcloud run services update my-service \
  --region=us-central1 \
  --ingress=internal-and-cloud-load-balancing
```

---

## Security

### Authentication

```bash
# Require authentication
gcloud run services update my-service \
  --region=us-central1 \
  --no-allow-unauthenticated

# Grant invoker role
gcloud run services add-iam-policy-binding my-service \
  --region=us-central1 \
  --member="user:user@example.com" \
  --role="roles/run.invoker"
```

### Service Account

```bash
# Create service account
gcloud iam service-accounts create cloudrun-sa

# Grant permissions
gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:cloudrun-sa@my-project.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"

# Use service account
gcloud run services update my-service \
  --region=us-central1 \
  --service-account=cloudrun-sa@my-project.iam.gserviceaccount.com
```

### Invoke with Authentication

```bash
# Get ID token
TOKEN=$(gcloud auth print-identity-token)

# Call service
curl -H "Authorization: Bearer $TOKEN" \
  https://my-service-xxx.run.app
```

**Python Example:**
```python
import google.auth
from google.auth.transport.requests import AuthorizedSession

# Get credentials
credentials, project = google.auth.default()

# Create authorized session
authed_session = AuthorizedSession(credentials)

# Make request
response = authed_session.get('https://my-service-xxx.run.app')
print(response.text)
```

---

## Scaling

### Auto-scaling Configuration

```bash
# Set min and max instances
gcloud run services update my-service \
  --region=us-central1 \
  --min-instances=1 \
  --max-instances=100
```

### Scaling Behavior

**Scale to Zero:**
- Default behavior
- No cost when idle
- Cold start on first request

**Minimum Instances:**
- Keep instances warm
- Reduce cold starts
- Incur cost even when idle

**Maximum Instances:**
- Control costs
- Prevent runaway scaling
- Protect downstream services

### Cold Start Optimization

```bash
# Use CPU always allocated
gcloud run services update my-service \
  --region=us-central1 \
  --cpu-throttling \
  --no-cpu-throttling  # Keep CPU allocated
```

**Optimization Strategies:**
- Minimize container size
- Use lighter base images
- Lazy load dependencies
- Use minimum instances for critical services
- Optimize startup code

---

## Monitoring

### Cloud Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_count"'
```

**Key Metrics:**
- Request count
- Request latency
- Container instance count
- CPU utilization
- Memory utilization
- Billable time

### Logging

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# Stream logs
gcloud logging tail "resource.type=cloud_run_revision"
```

**Application Logging:**
```javascript
// Structured logging
console.log(JSON.stringify({
  severity: 'INFO',
  message: 'Request processed',
  requestId: req.id,
  duration: duration
}));
```

### Alerting

```bash
# Create alert (via console or API)
```

**Common Alerts:**
- High error rate (> 5%)
- High latency (p95 > 1s)
- Container startup failures
- Memory limit exceeded

---

## Cost Optimization

### Pricing Model

**Charges:**
- CPU: $0.00002400/vCPU-second
- Memory: $0.00000250/GiB-second
- Requests: $0.40/million requests

**Free Tier (per month):**
- 2 million requests
- 360,000 vCPU-seconds
- 180,000 GiB-seconds

### Cost Example

**Scenario:** 1M requests/month, 500ms avg, 512Mi memory, 1 vCPU

```
CPU cost: 1M × 0.5s × 1 vCPU × $0.000024 = $12.00
Memory cost: 1M × 0.5s × 0.5 GiB × $0.0000025 = $0.63
Request cost: 1M × $0.40/1M = $0.40
Total: $13.03/month
```

### Optimization Strategies

✅ Right-size CPU and memory  
✅ Optimize container startup time  
✅ Use appropriate concurrency  
✅ Enable CPU throttling when idle  
✅ Optimize request handling time  
✅ Use caching  
✅ Batch operations  
✅ Use minimum instances sparingly  
✅ Monitor and optimize cold starts  
✅ Use Cloud CDN for static content  

---

## Best Practices

### Performance

✅ Optimize container image size  
✅ Use multi-stage Docker builds  
✅ Implement health checks  
✅ Handle graceful shutdown  
✅ Use connection pooling  
✅ Implement caching  
✅ Optimize cold start time  
✅ Use appropriate concurrency  

### Security

✅ Use least privilege service accounts  
✅ Store secrets in Secret Manager  
✅ Require authentication  
✅ Use VPC connectors for private resources  
✅ Implement rate limiting  
✅ Validate input  
✅ Use HTTPS only  
✅ Enable Binary Authorization  

### Reliability

✅ Implement retry logic  
✅ Use circuit breakers  
✅ Set appropriate timeouts  
✅ Handle errors gracefully  
✅ Implement health checks  
✅ Use structured logging  
✅ Monitor key metrics  
✅ Set up alerts  

### Operations

✅ Use infrastructure as code  
✅ Implement CI/CD  
✅ Use traffic splitting for deployments  
✅ Tag revisions  
✅ Document service dependencies  
✅ Use labels for organization  
✅ Implement observability  
✅ Regular security updates  

---

## Troubleshooting

### Common Issues

**Container fails to start:**
```bash
# Check logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit=50 \
  --format=json

# Check revision status
gcloud run revisions describe REVISION_NAME \
  --region=us-central1
```

**High latency:**
- Check cold start metrics
- Optimize container startup
- Increase minimum instances
- Check downstream dependencies

**Memory errors:**
```bash
# Increase memory
gcloud run services update my-service \
  --region=us-central1 \
  --memory=1Gi
```

**Timeout errors:**
```bash
# Increase timeout
gcloud run services update my-service \
  --region=us-central1 \
  --timeout=600
```

---

## Next Steps

- **[App Engine](4-App-Engine.md)** - Platform as a Service
- **[Cloud Functions](5-Cloud-Functions.md)** - Serverless functions
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
