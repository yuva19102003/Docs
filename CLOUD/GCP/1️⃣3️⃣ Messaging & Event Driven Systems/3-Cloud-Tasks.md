# Cloud Tasks

Asynchronous task execution with guaranteed delivery.

---

## Overview

Cloud Tasks lets you separate out pieces of work that can be performed independently, outside of your main application flow, and send them off to be processed asynchronously.

---

## Key Features

- Guaranteed task execution
- Rate limiting
- Task scheduling
- Retry configuration
- HTTP/App Engine targets
- Task deduplication

---

## Creating Queues

```bash
# Create queue
gcloud tasks queues create my-queue \
  --location=us-central1

# Create queue with rate limits
gcloud tasks queues create rate-limited-queue \
  --location=us-central1 \
  --max-dispatches-per-second=10 \
  --max-concurrent-dispatches=5

# Update queue
gcloud tasks queues update my-queue \
  --location=us-central1 \
  --max-attempts=5 \
  --max-retry-duration=3600s
```

---

## Creating Tasks

**HTTP Task:**
```bash
# Create HTTP task
gcloud tasks create-http-task \
  --queue=my-queue \
  --location=us-central1 \
  --url=https://example.com/process \
  --method=POST \
  --header=Content-Type:application/json \
  --body-content='{"order_id":"12345"}' \
  --schedule-time=2026-03-09T15:00:00Z
```

**Python:**
```python
from google.cloud import tasks_v2
import json
from datetime import datetime, timedelta

client = tasks_v2.CloudTasksClient()
project = 'my-project'
queue = 'my-queue'
location = 'us-central1'

parent = client.queue_path(project, location, queue)

# Create task
task = {
    'http_request': {
        'http_method': tasks_v2.HttpMethod.POST,
        'url': 'https://example.com/process',
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'order_id': '12345',
            'customer_id': '67890'
        }).encode()
    }
}

# Schedule task for later
schedule_time = datetime.utcnow() + timedelta(minutes=30)
task['schedule_time'] = schedule_time

# Create task with retry config
response = client.create_task(request={'parent': parent, 'task': task})
print(f'Created task: {response.name}')
```

**Node.js:**
```javascript
const {CloudTasksClient} = require('@google-cloud/tasks');
const client = new CloudTasksClient();

async function createTask() {
  const project = 'my-project';
  const queue = 'my-queue';
  const location = 'us-central1';
  const url = 'https://example.com/process';
  
  const parent = client.queuePath(project, location, queue);
  
  const task = {
    httpRequest: {
      httpMethod: 'POST',
      url: url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: Buffer.from(JSON.stringify({
        order_id: '12345'
      })).toString('base64'),
    },
  };
  
  // Schedule task
  const scheduleTime = new Date();
  scheduleTime.setMinutes(scheduleTime.getMinutes() + 30);
  task.scheduleTime = {
    seconds: scheduleTime.getTime() / 1000,
  };
  
  const [response] = await client.createTask({parent, task});
  console.log(`Created task: ${response.name}`);
}
```

---

## Task Handler

**Cloud Run Handler:**
```python
from flask import Flask, request
import logging

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process_task():
    # Verify task header
    task_name = request.headers.get('X-CloudTasks-TaskName')
    if not task_name:
        return 'Invalid request', 400
    
    # Get task data
    data = request.get_json()
    order_id = data.get('order_id')
    
    try:
        # Process task
        result = process_order(order_id)
        logging.info(f'Processed order {order_id}: {result}')
        return 'Success', 200
    except Exception as e:
        logging.error(f'Error processing order {order_id}: {e}')
        # Return 5xx to trigger retry
        return 'Error', 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

---

## Authentication

**OIDC Token:**
```python
# Create task with OIDC token
task = {
    'http_request': {
        'http_method': tasks_v2.HttpMethod.POST,
        'url': 'https://example.com/process',
        'oidc_token': {
            'service_account_email': 'task-runner@project.iam.gserviceaccount.com',
            'audience': 'https://example.com'
        },
        'body': json.dumps(data).encode()
    }
}
```

---

## Rate Limiting

```bash
# Configure queue rate limits
gcloud tasks queues update my-queue \
  --location=us-central1 \
  --max-dispatches-per-second=100 \
  --max-concurrent-dispatches=10 \
  --max-burst-size=100
```

**Use Cases:**
- Prevent overwhelming downstream services
- Control API rate limits
- Manage resource consumption
- Smooth traffic spikes

---

## Retry Configuration

```bash
# Configure retry policy
gcloud tasks queues update my-queue \
  --location=us-central1 \
  --max-attempts=10 \
  --min-backoff=1s \
  --max-backoff=3600s \
  --max-doublings=5 \
  --max-retry-duration=86400s
```

**Retry Logic:**
```
Attempt 1: Immediate
Attempt 2: 1s delay
Attempt 3: 2s delay
Attempt 4: 4s delay
Attempt 5: 8s delay
Attempt 6: 16s delay (max doublings reached)
Attempt 7+: 3600s delay (max backoff)
```

---

## Task Deduplication

```python
# Create task with deduplication
task = {
    'http_request': {
        'http_method': tasks_v2.HttpMethod.POST,
        'url': 'https://example.com/process',
        'body': json.dumps(data).encode()
    },
    'name': client.task_path(
        project, location, queue, 
        f'order-{order_id}'  # Unique task name
    )
}

try:
    response = client.create_task(request={'parent': parent, 'task': task})
except Exception as e:
    if 'ALREADY_EXISTS' in str(e):
        print('Task already exists')
    else:
        raise
```

---

## Monitoring

```bash
# View queue stats
gcloud tasks queues describe my-queue \
  --location=us-central1

# List tasks
gcloud tasks list \
  --queue=my-queue \
  --location=us-central1

# Delete task
gcloud tasks delete TASK_ID \
  --queue=my-queue \
  --location=us-central1
```

**Metrics:**
```python
from google.cloud import monitoring_v3

client = monitoring_v3.MetricServiceClient()
project_name = f"projects/{project_id}"

# Query queue depth
query = monitoring_v3.ListTimeSeriesRequest(
    name=project_name,
    filter='metric.type="cloudtasks.googleapis.com/queue/depth"',
    interval=monitoring_v3.TimeInterval({
        "end_time": {"seconds": int(time.time())},
        "start_time": {"seconds": int(time.time() - 3600)},
    }),
)
```

---

## Best Practices

✓ Set appropriate task deadlines  
✓ Implement idempotent handlers  
✓ Use rate limiting  
✓ Monitor queue depth  
✓ Configure retry policies  
✓ Use task deduplication  
✓ Implement proper error handling  
✓ Use OIDC tokens for authentication  

---

## Pricing

```
Task operations: $0.40 per million operations
First 1 million operations/month: Free
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
