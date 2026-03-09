# Pub/Sub

Asynchronous messaging service for event-driven systems.

---

## Overview

Cloud Pub/Sub is a fully managed messaging service that enables asynchronous communication between applications.

---

## Key Concepts

**Topic:** Named resource to which messages are sent  
**Subscription:** Named resource representing message stream  
**Message:** Data and attributes sent to a topic  
**Publisher:** Application that sends messages  
**Subscriber:** Application that receives messages

---

## Creating Topics

```bash
# Create topic
gcloud pubsub topics create my-topic

# Create topic with schema
gcloud pubsub topics create my-topic \
  --message-encoding=JSON \
  --schema=my-schema

# List topics
gcloud pubsub topics list
```

---

## Creating Subscriptions

**Pull Subscription:**
```bash
gcloud pubsub subscriptions create my-pull-sub \
  --topic=my-topic \
  --ack-deadline=60
```

**Push Subscription:**
```bash
gcloud pubsub subscriptions create my-push-sub \
  --topic=my-topic \
  --push-endpoint=https://example.com/push \
  --push-auth-service-account=push-sa@project.iam.gserviceaccount.com
```

**BigQuery Subscription:**
```bash
gcloud pubsub subscriptions create my-bq-sub \
  --topic=my-topic \
  --bigquery-table=PROJECT:DATASET.TABLE
```

---

## Publishing Messages

**gcloud:**
```bash
# Publish single message
gcloud pubsub topics publish my-topic \
  --message="Hello World"

# Publish with attributes
gcloud pubsub topics publish my-topic \
  --message="Order created" \
  --attribute=order_id=12345,priority=high
```

**Python:**
```python
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('project-id', 'my-topic')

# Publish message
data = "Hello World".encode('utf-8')
future = publisher.publish(topic_path, data, order_id='12345')
message_id = future.result()

# Batch publishing
futures = []
for i in range(100):
    data = f"Message {i}".encode('utf-8')
    future = publisher.publish(topic_path, data)
    futures.append(future)

# Wait for all messages
for future in futures:
    future.result()
```

**Node.js:**
```javascript
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();

async function publishMessage() {
  const topic = pubsub.topic('my-topic');
  const data = Buffer.from('Hello World');
  
  const messageId = await topic.publish(data, {
    order_id: '12345',
    priority: 'high'
  });
  
  console.log(`Message ${messageId} published`);
}
```

---

## Receiving Messages

**Pull Subscription (Python):**
```python
from google.cloud import pubsub_v1

subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path('project-id', 'my-sub')

def callback(message):
    print(f"Received: {message.data.decode('utf-8')}")
    print(f"Attributes: {message.attributes}")
    message.ack()

streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)

try:
    streaming_pull_future.result()
except KeyboardInterrupt:
    streaming_pull_future.cancel()
```

**Synchronous Pull:**
```python
response = subscriber.pull(
    request={"subscription": subscription_path, "max_messages": 10}
)

for received_message in response.received_messages:
    print(f"Received: {received_message.message.data}")
    
    # Acknowledge
    subscriber.acknowledge(
        request={
            "subscription": subscription_path,
            "ack_ids": [received_message.ack_id]
        }
    )
```

---

## Message Ordering

```bash
# Create topic with ordering
gcloud pubsub topics create ordered-topic

# Create subscription with ordering
gcloud pubsub subscriptions create ordered-sub \
  --topic=ordered-topic \
  --enable-message-ordering
```

**Publishing ordered messages:**
```python
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('project-id', 'ordered-topic')

# Publish with ordering key
for i in range(10):
    data = f"Message {i}".encode('utf-8')
    future = publisher.publish(
        topic_path,
        data,
        ordering_key='user-123'
    )
    future.result()
```

---

## Dead Letter Topics

```bash
# Create dead letter topic
gcloud pubsub topics create dead-letter-topic

# Create subscription with dead letter
gcloud pubsub subscriptions create my-sub \
  --topic=my-topic \
  --dead-letter-topic=dead-letter-topic \
  --max-delivery-attempts=5

# Grant permissions
gcloud pubsub topics add-iam-policy-binding dead-letter-topic \
  --member=serviceAccount:service-PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/pubsub.publisher
```

---

## Message Filtering

```bash
# Create subscription with filter
gcloud pubsub subscriptions create filtered-sub \
  --topic=my-topic \
  --message-filter='attributes.priority="high"'

# Complex filter
gcloud pubsub subscriptions create complex-filter-sub \
  --topic=my-topic \
  --message-filter='attributes.region="us" AND attributes.priority="high"'
```

---

## Exactly-Once Delivery

```bash
# Create subscription with exactly-once delivery
gcloud pubsub subscriptions create exactly-once-sub \
  --topic=my-topic \
  --enable-exactly-once-delivery
```

---

## Monitoring

```bash
# View metrics
gcloud monitoring time-series list \
  --filter='metric.type="pubsub.googleapis.com/topic/send_request_count"' \
  --format=json

# Create alert for unacked messages
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Unacked Messages" \
  --condition-threshold-value=1000 \
  --condition-filter='metric.type="pubsub.googleapis.com/subscription/num_unacked_messages_by_region"'
```

---

## Best Practices

✓ Use message attributes for filtering  
✓ Implement idempotent message processing  
✓ Set appropriate acknowledgment deadlines  
✓ Use dead letter topics  
✓ Enable message ordering when needed  
✓ Monitor subscription backlog  
✓ Use push subscriptions for low latency  
✓ Implement retry logic with exponential backoff  

---

## Pricing

```
Message ingestion: $0.04 per GB
Message delivery: $0.04 per GB
Snapshot storage: $0.27 per GB/month
Seek backlog: $0.10 per GB
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
