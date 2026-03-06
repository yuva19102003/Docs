# Cloud Functions - Serverless Functions

Complete guide to Cloud Functions - event-driven serverless compute.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Function Types](#function-types)
3. [Function Deployment](#function-deployment)
4. [Triggers](#triggers)
5. [Configuration](#configuration)
6. [Security](#security)
7. [Monitoring](#monitoring)
8. [Cost Optimization](#cost-optimization)
9. [Best Practices](#best-practices)

---

## Introduction

Cloud Functions is a serverless execution environment for building and connecting cloud services with code.

### Key Features

✅ Event-driven execution  
✅ Automatic scaling  
✅ Pay per invocation  
✅ No server management  
✅ Multiple triggers  
✅ Built-in security  
✅ Integrated monitoring  
✅ 1st and 2nd generation  

### Architecture

```
Event Source          Cloud Function         Action
    |                      |                    |
    v                      v                    v
┌─────────┐          ┌──────────┐        ┌──────────┐
│ Pub/Sub │─────────>│ Function │───────>│ Database │
└─────────┘          └──────────┘        └──────────┘
┌─────────┐          ┌──────────┐        ┌──────────┐
│ Storage │─────────>│ Function │───────>│ API Call │
└─────────┘          └──────────┘        └──────────┘
┌─────────┐          ┌──────────┐        ┌──────────┐
│  HTTP   │─────────>│ Function │───────>│ Response │
└─────────┘          └──────────┘        └──────────┘
```

---

## Function Types

### 1st Generation

**Legacy runtime:**
- Node.js 10, 12, 14, 16
- Python 3.7, 3.8, 3.9, 3.10
- Go 1.11, 1.13, 1.16, 1.19
- Java 11, 17
- Ruby 2.6, 2.7, 3.0
- PHP 7.4, 8.1
- .NET Core 3.1

**Limitations:**
- 540 second timeout
- 8 GB memory max
- Limited concurrency

### 2nd Generation

**Modern runtime (Cloud Run-based):**
- Node.js 16, 18, 20
- Python 3.8, 3.9, 3.10, 3.11
- Go 1.16, 1.17, 1.18, 1.19, 1.20, 1.21
- Java 11, 17

**Improvements:**
- 60 minute timeout
- 16 GB memory max
- Higher concurrency
- More CPU
- Better performance

### Comparison

| Feature | 1st Gen | 2nd Gen |
|---------|---------|---------|
| **Timeout** | 540s | 3600s |
| **Memory** | 8 GB | 16 GB |
| **CPU** | Limited | Up to 4 vCPU |
| **Concurrency** | 1 | 1000 |
| **Min Instances** | 0 | 0-1000 |
| **Networking** | Limited | VPC support |

---

## Function Deployment

### HTTP Function (2nd Gen)

**main.py:**
```python
import functions_framework

@functions_framework.http
def hello_http(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`.
    """
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
    
    return f'Hello {name}!'
```

**requirements.txt:**
```
functions-framework==3.3.0
```

```bash
# Deploy 2nd gen function
gcloud functions deploy hello-http \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=. \
  --entry-point=hello_http \
  --trigger-http \
  --allow-unauthenticated
```

### Event Function (Pub/Sub)

**main.py:**
```python
import base64
import functions_framework

@functions_framework.cloud_event
def hello_pubsub(cloud_event):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         cloud_event (CloudEvent): The CloudEvent that triggered this function.
    """
    # Decode the Pub/Sub message
    message = base64.b64decode(cloud_event.data["message"]["data"]).decode()
    
    print(f"Received message: {message}")
    
    # Process the message
    process_message(message)

def process_message(message):
    # Your processing logic here
    pass
```

```bash
# Deploy Pub/Sub function
gcloud functions deploy hello-pubsub \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=. \
  --entry-point=hello_pubsub \
  --trigger-topic=my-topic
```

### Storage Function

**main.py:**
```python
import functions_framework
from google.cloud import storage

@functions_framework.cloud_event
def hello_gcs(cloud_event):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
         cloud_event (CloudEvent): The CloudEvent that triggered this function.
    """
    data = cloud_event.data

    bucket = data["bucket"]
    name = data["name"]
    
    print(f"File: {name}")
    print(f"Bucket: {bucket}")
    
    # Process the file
    process_file(bucket, name)

def process_file(bucket_name, file_name):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    
    # Download and process
    content = blob.download_as_text()
    print(f"Content: {content}")
```

```bash
# Deploy Storage function
gcloud functions deploy hello-gcs \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=. \
  --entry-point=hello_gcs \
  --trigger-bucket=my-bucket
```

### Node.js Example

**index.js:**
```javascript
const functions = require('@google-cloud/functions-framework');

// HTTP function
functions.http('helloHttp', (req, res) => {
  const name = req.query.name || req.body.name || 'World';
  res.send(`Hello ${name}!`);
});

// CloudEvent function
functions.cloudEvent('helloPubSub', (cloudEvent) => {
  const message = Buffer.from(cloudEvent.data.message.data, 'base64').toString();
  console.log(`Received message: ${message}`);
});
```

**package.json:**
```json
{
  "name": "cloud-function",
  "version": "1.0.0",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.3.0"
  }
}
```

---

## Triggers

### HTTP Trigger

```bash
# Deploy HTTP function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-http \
  --allow-unauthenticated

# Call function
curl https://REGION-PROJECT_ID.cloudfunctions.net/my-function
```

### Pub/Sub Trigger

```bash
# Create topic
gcloud pubsub topics create my-topic

# Deploy function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-topic=my-topic

# Publish message
gcloud pubsub topics publish my-topic --message="Hello"
```

### Cloud Storage Trigger

```bash
# Deploy function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-bucket=my-bucket \
  --trigger-event-filters="type=google.cloud.storage.object.v1.finalized"
```

### Firestore Trigger

```bash
# Deploy function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-event-filters="type=google.cloud.firestore.document.v1.written" \
  --trigger-event-filters="database=(default)" \
  --trigger-event-filters-path-pattern="document=users/{userId}"
```

### Cloud Scheduler Trigger

```bash
# Create Pub/Sub topic
gcloud pubsub topics create scheduled-topic

# Deploy function
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-topic=scheduled-topic

# Create scheduler job
gcloud scheduler jobs create pubsub daily-job \
  --schedule="0 0 * * *" \
  --topic=scheduled-topic \
  --message-body="Run daily task" \
  --location=us-central1
```

---

## Configuration

### Memory and CPU

```bash
# Set memory (128MB to 16GB for 2nd gen)
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --memory=512Mi \
  --cpu=1 \
  --trigger-http
```

### Timeout

```bash
# Set timeout (up to 3600s for 2nd gen)
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --timeout=300 \
  --trigger-http
```

### Environment Variables

```bash
# Set environment variables
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --set-env-vars="ENV=production,DEBUG=false" \
  --trigger-http
```

### Secrets

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Mount secret
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --set-secrets="DB_PASSWORD=my-secret:latest" \
  --trigger-http
```

**Access in code:**
```python
import os

db_password = os.environ.get('DB_PASSWORD')
```

### Concurrency

```bash
# Set concurrency (2nd gen only)
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --concurrency=100 \
  --trigger-http
```

### Min/Max Instances

```bash
# Set instance limits
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --min-instances=1 \
  --max-instances=100 \
  --trigger-http
```

---

## Security

### Authentication

```bash
# Require authentication
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --trigger-http \
  --no-allow-unauthenticated

# Grant invoker role
gcloud functions add-iam-policy-binding my-function \
  --region=us-central1 \
  --member="user:user@example.com" \
  --role="roles/cloudfunctions.invoker"
```

### Service Account

```bash
# Create service account
gcloud iam service-accounts create function-sa

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:function-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"

# Use service account
gcloud functions deploy my-function \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --service-account=function-sa@PROJECT_ID.iam.gserviceaccount.com \
  --trigger-http
```

### Invoke with Authentication

```bash
# Get ID token
TOKEN=$(gcloud auth print-identity-token)

# Call function
curl -H "Authorization: Bearer $TOKEN" \
  https://REGION-PROJECT_ID.cloudfunctions.net/my-function
```

**Python Example:**
```python
import google.auth
from google.auth.transport.requests import AuthorizedSession

credentials, project = google.auth.default()
authed_session = AuthorizedSession(credentials)

response = authed_session.get(
    'https://REGION-PROJECT_ID.cloudfunctions.net/my-function'
)
print(response.text)
```

---

## Monitoring

### Cloud Logging

```bash
# View logs
gcloud functions logs read my-function \
  --region=us-central1 \
  --limit=50

# Stream logs
gcloud functions logs read my-function \
  --region=us-central1 \
  --follow
```

**Structured Logging:**
```python
import json

print(json.dumps({
    'severity': 'INFO',
    'message': 'Processing request',
    'user_id': user_id
}))
```

### Cloud Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="cloudfunctions.googleapis.com/function/execution_count"'
```

**Key Metrics:**
- Execution count
- Execution time
- Memory usage
- Active instances
- Error count

### Error Reporting

```python
from google.cloud import error_reporting

client = error_reporting.Client()

try:
    # Your code
    pass
except Exception as e:
    client.report_exception()
```

---

## Cost Optimization

### Pricing Model

**Charges:**
- Invocations: $0.40/million
- Compute time: $0.00001667/GB-second
- Networking: $0.12/GB egress

**Free Tier (per month):**
- 2 million invocations
- 400,000 GB-seconds
- 200,000 GHz-seconds
- 5 GB network egress

### Cost Example

**Scenario:** 1M invocations/month, 200ms avg, 256MB memory

```
Invocations: 1M × $0.40/1M = $0.40
Compute: 1M × 0.2s × 0.25GB × $0.00001667 = $0.83
Total: $1.23/month (within free tier)
```

### Optimization Strategies

✅ Right-size memory allocation  
✅ Optimize execution time  
✅ Use appropriate timeout  
✅ Minimize cold starts  
✅ Use caching  
✅ Batch operations  
✅ Use min instances sparingly  
✅ Monitor and optimize  

---

## Best Practices

### Performance

✅ Minimize cold start time  
✅ Reuse connections  
✅ Use global variables for reuse  
✅ Optimize dependencies  
✅ Use appropriate memory  
✅ Implement caching  
✅ Handle errors gracefully  

### Security

✅ Use least privilege service accounts  
✅ Store secrets in Secret Manager  
✅ Require authentication  
✅ Validate input  
✅ Implement rate limiting  
✅ Use VPC connectors  
✅ Enable audit logging  

### Reliability

✅ Implement retry logic  
✅ Handle idempotency  
✅ Set appropriate timeouts  
✅ Use dead letter queues  
✅ Monitor error rates  
✅ Implement circuit breakers  
✅ Test thoroughly  

### Operations

✅ Use infrastructure as code  
✅ Implement CI/CD  
✅ Use structured logging  
✅ Monitor key metrics  
✅ Set up alerts  
✅ Document functions  
✅ Version control  

---

## Troubleshooting

**Function fails to deploy:**
```bash
# Check logs
gcloud functions logs read my-function --region=us-central1

# Validate locally
functions-framework --target=my_function --debug
```

**Timeout errors:**
```bash
# Increase timeout
gcloud functions deploy my-function \
  --gen2 \
  --timeout=600 \
  --region=us-central1
```

**Memory errors:**
```bash
# Increase memory
gcloud functions deploy my-function \
  --gen2 \
  --memory=1Gi \
  --region=us-central1
```

**Cold start issues:**
- Minimize dependencies
- Use min instances
- Optimize initialization code
- Use lighter runtimes

---

## Next Steps

- **[Compute Comparison](6-Compute-Comparison.md)** - Detailed comparison
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
