# App Engine - Platform as a Service

Complete guide to Google App Engine - fully managed application platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Environments](#environments)
3. [Application Deployment](#application-deployment)
4. [Configuration](#configuration)
5. [Services](#services)
6. [Traffic Management](#traffic-management)
7. [Scaling](#scaling)
8. [Security](#security)
9. [Monitoring](#monitoring)
10. [Best Practices](#best-practices)

---

## Introduction

App Engine is a fully managed platform for building and deploying applications without managing infrastructure.

### Key Features

✅ Fully managed platform  
✅ Auto-scaling  
✅ Built-in services (Memcache, Task Queue)  
✅ Traffic splitting  
✅ Version management  
✅ Integrated monitoring  
✅ Custom domains  
✅ SSL certificates  
✅ Cron jobs  
✅ Task queues  

### Architecture

```
┌─────────────────────────────────────────┐
│        App Engine Application           │
├─────────────────────────────────────────┤
│  Service 1    Service 2    Service 3    │
│  ┌────────┐  ┌────────┐  ┌────────┐    │
│  │ v1 v2  │  │ v1     │  │ v1     │    │
│  └────────┘  └────────┘  └────────┘    │
├─────────────────────────────────────────┤
│  Built-in Services                      │
│  - Memcache                             │
│  - Task Queue                           │
│  - Cron                                 │
│  - Search                               │
└─────────────────────────────────────────┘
```

---

## Environments

### Standard Environment

**Fully managed, fast scaling:**
- Preconfigured runtimes
- Fast startup (seconds)
- Free tier available
- Automatic scaling
- Limited customization

**Supported Runtimes:**
- Python 3.7, 3.8, 3.9, 3.10, 3.11
- Java 11, 17
- Node.js 12, 14, 16, 18, 20
- PHP 7.4, 8.1, 8.2
- Ruby 2.7, 3.0, 3.1, 3.2
- Go 1.16, 1.17, 1.18, 1.19, 1.20, 1.21

### Flexible Environment

**Customizable, container-based:**
- Custom runtimes (Docker)
- Slower startup (minutes)
- More control
- SSH access
- Background processes

### Comparison

| Feature | Standard | Flexible |
|---------|----------|----------|
| **Startup** | Seconds | Minutes |
| **Scaling** | Instant | Gradual |
| **SSH** | No | Yes |
| **Custom Runtime** | No | Yes |
| **Background** | No | Yes |
| **Free Tier** | Yes | No |
| **Cost** | Lower | Higher |

---

## Application Deployment

### Standard Environment

**app.yaml:**
```yaml
runtime: python311
instance_class: F2

automatic_scaling:
  target_cpu_utilization: 0.65
  min_instances: 1
  max_instances: 10
  min_pending_latency: 30ms
  max_pending_latency: automatic
  max_concurrent_requests: 80

env_variables:
  ENV: 'production'
  DEBUG: 'false'

handlers:
- url: /static
  static_dir: static
  secure: always

- url: /.*
  script: auto
  secure: always
```

**main.py:**
```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from App Engine!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

**requirements.txt:**
```
Flask==2.3.0
gunicorn==20.1.0
```

```bash
# Deploy
gcloud app deploy

# View application
gcloud app browse
```

### Flexible Environment

**app.yaml:**
```yaml
runtime: custom
env: flex

automatic_scaling:
  min_num_instances: 1
  max_num_instances: 10
  cool_down_period_sec: 120
  cpu_utilization:
    target_utilization: 0.65

resources:
  cpu: 1
  memory_gb: 0.5
  disk_size_gb: 10

network:
  forwarded_ports:
    - 8080

env_variables:
  ENV: 'production'
```

**Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
```

---

## Configuration

### Instance Classes (Standard)

| Class | Memory | CPU | Cost/Hour |
|-------|--------|-----|-----------|
| **F1** | 256 MB | 600 MHz | $0.05 |
| **F2** | 512 MB | 1.2 GHz | $0.10 |
| **F4** | 1024 MB | 2.4 GHz | $0.20 |
| **F4_1G** | 2048 MB | 2.4 GHz | $0.30 |

### Resources (Flexible)

```yaml
resources:
  cpu: 2
  memory_gb: 4
  disk_size_gb: 20
  volumes:
  - name: ramdisk1
    volume_type: tmpfs
    size_gb: 0.5
```

### Environment Variables

```yaml
env_variables:
  DATABASE_URL: 'postgresql://...'
  API_KEY: 'your-api-key'
  REDIS_HOST: '10.0.0.3'
```

### Secrets

```bash
# Create secret
echo -n "my-secret" | gcloud secrets create app-secret --data-file=-

# Grant access
gcloud secrets add-iam-policy-binding app-secret \
  --member="serviceAccount:PROJECT_ID@appspot.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

**Access in code:**
```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
name = f"projects/PROJECT_ID/secrets/app-secret/versions/latest"
response = client.access_secret_version(request={"name": name})
secret_value = response.payload.data.decode('UTF-8')
```

---

## Services

### Multiple Services

**default/app.yaml:**
```yaml
runtime: python311
service: default

handlers:
- url: /.*
  script: auto
```

**api/app.yaml:**
```yaml
runtime: python311
service: api

handlers:
- url: /.*
  script: auto
```

**admin/app.yaml:**
```yaml
runtime: python311
service: admin

handlers:
- url: /.*
  script: auto
  login: admin
```

```bash
# Deploy services
gcloud app deploy default/app.yaml
gcloud app deploy api/app.yaml
gcloud app deploy admin/app.yaml

# List services
gcloud app services list

# Access services
# https://PROJECT_ID.appspot.com (default)
# https://api-dot-PROJECT_ID.appspot.com (api)
# https://admin-dot-PROJECT_ID.appspot.com (admin)
```

---

## Traffic Management

### Versions

```bash
# Deploy new version without traffic
gcloud app deploy --no-promote

# List versions
gcloud app versions list

# Split traffic
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5

# Migrate traffic
gcloud app services set-traffic default \
  --splits=v2=1.0 \
  --migrate

# Delete old version
gcloud app versions delete v1 --service=default
```

### Traffic Splitting Methods

**IP Splitting:**
```bash
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5 \
  --split-by=ip
```

**Cookie Splitting:**
```bash
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5 \
  --split-by=cookie
```

**Random Splitting:**
```bash
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5 \
  --split-by=random
```

---

## Scaling

### Automatic Scaling (Standard)

```yaml
automatic_scaling:
  target_cpu_utilization: 0.65
  target_throughput_utilization: 0.6
  min_instances: 2
  max_instances: 20
  min_pending_latency: 30ms
  max_pending_latency: automatic
  max_concurrent_requests: 80
```

### Basic Scaling

```yaml
basic_scaling:
  max_instances: 5
  idle_timeout: 10m
```

### Manual Scaling

```yaml
manual_scaling:
  instances: 5
```

### Scaling Comparison

| Type | Use Case | Cost | Startup |
|------|----------|------|---------|
| **Automatic** | Variable traffic | Pay per use | Fast |
| **Basic** | Predictable traffic | Pay per hour | Fast |
| **Manual** | Constant load | Pay per hour | Fast |

---

## Security

### Service Account

```bash
# Create service account
gcloud iam service-accounts create appengine-sa

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:appengine-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

**app.yaml:**
```yaml
service_account: appengine-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Authentication

**Require login:**
```yaml
handlers:
- url: /admin/.*
  script: auto
  login: required

- url: /internal/.*
  script: auto
  login: admin
```

### Firewall Rules

```bash
# Block all traffic except from specific IPs
gcloud app firewall-rules create 100 \
  --action=ALLOW \
  --source-range=203.0.113.0/24

gcloud app firewall-rules create 200 \
  --action=DENY \
  --source-range=*
```

---

## Monitoring

### Cloud Logging

```bash
# View logs
gcloud app logs tail

# Read logs
gcloud logging read "resource.type=gae_app" --limit=50
```

**Structured Logging:**
```python
import logging
import json

logging.info(json.dumps({
    'message': 'Request processed',
    'user_id': user_id,
    'duration': duration
}))
```

### Cloud Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="appengine.googleapis.com/http/server/response_count"'
```

**Key Metrics:**
- Request count
- Response latency
- Instance count
- Memory usage
- CPU usage
- Error rate

---

## Built-in Services

### Cron Jobs

**cron.yaml:**
```yaml
cron:
- description: "Daily cleanup"
  url: /tasks/cleanup
  schedule: every day 00:00
  timezone: America/New_York

- description: "Hourly sync"
  url: /tasks/sync
  schedule: every 1 hours
  target: api

- description: "Weekly report"
  url: /tasks/report
  schedule: every monday 09:00
```

```bash
# Deploy cron jobs
gcloud app deploy cron.yaml
```

### Task Queues

**queue.yaml:**
```yaml
queue:
- name: default
  rate: 5/s
  bucket_size: 10
  max_concurrent_requests: 10

- name: email-queue
  rate: 10/s
  retry_parameters:
    task_retry_limit: 7
    task_age_limit: 2d
```

```bash
# Deploy queues
gcloud app deploy queue.yaml
```

**Enqueue task:**
```python
from google.cloud import tasks_v2

client = tasks_v2.CloudTasksClient()
parent = client.queue_path('PROJECT_ID', 'LOCATION', 'email-queue')

task = {
    'app_engine_http_request': {
        'http_method': tasks_v2.HttpMethod.POST,
        'relative_uri': '/tasks/send-email',
        'body': json.dumps({'email': 'user@example.com'}).encode()
    }
}

response = client.create_task(request={'parent': parent, 'task': task})
```

### Memcache

```python
from google.appengine.api import memcache

# Set value
memcache.set('key', 'value', time=3600)

# Get value
value = memcache.get('key')

# Delete value
memcache.delete('key')
```

---

## Best Practices

### Performance

✅ Use memcache for frequently accessed data  
✅ Optimize cold start time  
✅ Use appropriate instance class  
✅ Implement caching strategies  
✅ Minimize dependencies  
✅ Use CDN for static content  
✅ Optimize database queries  
✅ Use task queues for async work  

### Cost Optimization

✅ Use automatic scaling  
✅ Set appropriate min/max instances  
✅ Use Standard environment when possible  
✅ Delete unused versions  
✅ Optimize instance class  
✅ Use caching to reduce compute  
✅ Monitor and optimize costs  

### Security

✅ Use service accounts with least privilege  
✅ Store secrets in Secret Manager  
✅ Implement authentication  
✅ Use firewall rules  
✅ Enable HTTPS only  
✅ Validate input  
✅ Implement rate limiting  
✅ Regular security updates  

---

## Troubleshooting

**Deployment fails:**
```bash
# Check logs
gcloud app logs tail

# Validate app.yaml
gcloud app deploy --validate-only
```

**High latency:**
- Check instance class
- Optimize cold start
- Increase min instances
- Check database performance

**Out of memory:**
- Increase instance class
- Optimize memory usage
- Check for memory leaks

---

## Next Steps

- **[Cloud Functions](5-Cloud-Functions.md)** - Serverless functions
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
