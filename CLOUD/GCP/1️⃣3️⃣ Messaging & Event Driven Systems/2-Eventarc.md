# Eventarc

Event routing and delivery for cloud services.

---

## Overview

Eventarc provides a standardized way to route events from Google Cloud services to Cloud Run, Cloud Functions, and GKE.

---

## Key Features

- CloudEvents standard
- Multiple event sources
- Event filtering
- Declarative routing
- Serverless integration
- Audit log events

---

## Event Sources

**Direct Sources:**
- Cloud Storage
- Pub/Sub
- Cloud Audit Logs
- Workflows
- Custom events

**Audit Log Sources:**
- Any GCP service with audit logs
- API calls
- Resource changes
- Admin activities

---

## Creating Triggers

**Cloud Storage Trigger:**
```bash
# Trigger on file upload
gcloud eventarc triggers create storage-trigger \
  --location=us-central1 \
  --destination-run-service=my-service \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=my-bucket"
```

**Pub/Sub Trigger:**
```bash
gcloud eventarc triggers create pubsub-trigger \
  --location=us-central1 \
  --destination-run-service=my-service \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --transport-topic=projects/PROJECT_ID/topics/my-topic
```

**Audit Log Trigger:**
```bash
# Trigger on VM creation
gcloud eventarc triggers create vm-created-trigger \
  --location=us-central1 \
  --destination-run-service=my-service \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.audit.log.v1.written" \
  --event-filters="serviceName=compute.googleapis.com" \
  --event-filters="methodName=v1.compute.instances.insert" \
  --service-account=SA_EMAIL
```

---

## Receiving Events

**Cloud Run Handler (Python):**
```python
from flask import Flask, request
import json

app = Flask(__name__)

@app.route('/', methods=['POST'])
def handle_event():
    envelope = request.get_json()
    
    # CloudEvents format
    event_type = request.headers.get('ce-type')
    event_source = request.headers.get('ce-source')
    event_id = request.headers.get('ce-id')
    
    print(f"Event Type: {event_type}")
    print(f"Event Source: {event_source}")
    print(f"Event ID: {event_id}")
    print(f"Data: {json.dumps(envelope)}")
    
    return ('', 204)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

**Node.js Handler:**
```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.post('/', (req, res) => {
  const eventType = req.headers['ce-type'];
  const eventSource = req.headers['ce-source'];
  const eventId = req.headers['ce-id'];
  
  console.log(`Event Type: ${eventType}`);
  console.log(`Event Source: ${eventSource}`);
  console.log(`Event ID: ${eventId}`);
  console.log(`Data: ${JSON.stringify(req.body)}`);
  
  res.status(204).send();
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
```

---

## Event Filtering

```bash
# Filter by multiple attributes
gcloud eventarc triggers create filtered-trigger \
  --location=us-central1 \
  --destination-run-service=my-service \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=my-bucket" \
  --event-filters-path-pattern="name=/images/*"
```

---

## Custom Events

```bash
# Create custom event channel
gcloud eventarc channels create my-channel \
  --location=us-central1

# Publish custom event
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/cloudevents+json" \
  -d '{
    "specversion": "1.0",
    "type": "com.example.order.created",
    "source": "//myapp/orders",
    "id": "12345",
    "data": {
      "orderId": "12345",
      "amount": 100.00
    }
  }' \
  https://eventarcpublishing.googleapis.com/v1/projects/PROJECT_ID/locations/us-central1/channels/my-channel:publishEvents
```

---

## Best Practices

✓ Use CloudEvents format  
✓ Implement event filtering  
✓ Handle duplicate events (idempotency)  
✓ Monitor event delivery  
✓ Use appropriate event sources  
✓ Implement error handling  
✓ Test event handlers  

---

**Last Updated:** March 2026
