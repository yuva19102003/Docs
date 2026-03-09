# Messaging & Event-Driven Best Practices

Production-ready patterns for event-driven systems.

---

## Message Design

### Idempotency

**Implement idempotent message handlers:**
```python
import hashlib
from google.cloud import firestore

db = firestore.Client()

def process_message_idempotent(message):
    # Generate idempotency key
    message_id = message.message_id
    idempotency_key = hashlib.sha256(
        f"{message_id}:{message.data}".encode()
    ).hexdigest()
    
    # Check if already processed
    doc_ref = db.collection('processed_messages').document(idempotency_key)
    if doc_ref.get().exists:
        print(f"Message {message_id} already processed")
        return
    
    # Process message
    try:
        result = process_business_logic(message)
        
        # Mark as processed
        doc_ref.set({
            'message_id': message_id,
            'processed_at': firestore.SERVER_TIMESTAMP,
            'result': result
        })
    except Exception as e:
        print(f"Error processing message: {e}")
        raise
```

### Message Structure

```json
{
  "metadata": {
    "message_id": "uuid-12345",
    "correlation_id": "trace-abc",
    "timestamp": "2026-03-09T12:00:00Z",
    "version": "1.0",
    "source": "order-service"
  },
  "data": {
    "order_id": "12345",
    "customer_id": "67890",
    "amount": 100.00,
    "items": [...]
  }
}
```

---

## Pub/Sub Best Practices

### Message Attributes

```python
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('project-id', 'orders')

# Use attributes for filtering
data = json.dumps(order_data).encode('utf-8')
future = publisher.publish(
    topic_path,
    data,
    order_type='premium',
    priority='high',
    region='us-east',
    correlation_id=correlation_id
)
```

### Error Handling

```python
from google.cloud import pubsub_v1
import time

subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path('project-id', 'my-sub')

def callback(message):
    try:
        # Process message
        process_message(message.data)
        message.ack()
    except RetryableError as e:
        # Nack for retry
        print(f"Retryable error: {e}")
        message.nack()
    except FatalError as e:
        # Ack to prevent reprocessing
        print(f"Fatal error: {e}")
        log_to_dead_letter(message)
        message.ack()
```

### Monitoring

```python
# Monitor subscription backlog
from google.cloud import monitoring_v3

client = monitoring_v3.MetricServiceClient()
project_name = f"projects/{project_id}"

# Query unacked messages
query = monitoring_v3.ListTimeSeriesRequest(
    name=project_name,
    filter='metric.type="pubsub.googleapis.com/subscription/num_unacked_messages_by_region"',
    interval=monitoring_v3.TimeInterval({
        "end_time": {"seconds": int(time.time())},
        "start_time": {"seconds": int(time.time() - 3600)},
    }),
)

results = client.list_time_series(request=query)
for result in results:
    print(f"Subscription: {result.resource.labels['subscription_id']}")
    print(f"Unacked messages: {result.points[0].value.int64_value}")
```

---

## Event-Driven Patterns

### Event Sourcing

```python
from google.cloud import firestore

db = firestore.Client()

class OrderAggregate:
    def __init__(self, order_id):
        self.order_id = order_id
        self.events = []
        self.state = {}
    
    def apply_event(self, event):
        # Apply event to state
        if event['type'] == 'OrderCreated':
            self.state = {
                'order_id': event['data']['order_id'],
                'status': 'created',
                'items': event['data']['items']
            }
        elif event['type'] == 'OrderPaid':
            self.state['status'] = 'paid'
        elif event['type'] == 'OrderShipped':
            self.state['status'] = 'shipped'
    
    def load_from_events(self):
        # Load events from Firestore
        events_ref = db.collection('events').where('order_id', '==', self.order_id)
        for doc in events_ref.stream():
            event = doc.to_dict()
            self.apply_event(event)
            self.events.append(event)
    
    def save_event(self, event):
        # Save event to Firestore
        db.collection('events').add(event)
        self.apply_event(event)
        self.events.append(event)
```

### CQRS (Command Query Responsibility Segregation)

```python
# Write side (Commands)
class OrderCommandHandler:
    def create_order(self, command):
        # Validate command
        order = Order(command['order_id'])
        
        # Save to write database (Cloud SQL)
        save_to_sql(order)
        
        # Publish event
        publish_event('OrderCreated', order.to_dict())

# Read side (Queries)
class OrderQueryHandler:
    def get_order(self, order_id):
        # Read from read database (BigQuery)
        return query_bigquery(f"SELECT * FROM orders WHERE order_id = '{order_id}'")
    
    def get_orders_by_customer(self, customer_id):
        # Optimized for queries
        return query_bigquery(f"SELECT * FROM orders WHERE customer_id = '{customer_id}'")

# Event handler to sync read model
def sync_read_model(event):
    if event['type'] == 'OrderCreated':
        # Update BigQuery
        insert_to_bigquery('orders', event['data'])
```

### Saga Pattern

```python
from google.cloud import pubsub_v1, firestore

class OrderSaga:
    def __init__(self, order_id):
        self.order_id = order_id
        self.db = firestore.Client()
        self.publisher = pubsub_v1.PublisherClient()
    
    def start(self, order_data):
        # Step 1: Reserve inventory
        self.publish_command('inventory', 'ReserveItems', order_data)
        self.update_saga_state('inventory_reserved', 'pending')
    
    def handle_inventory_reserved(self, event):
        # Step 2: Process payment
        self.publish_command('payment', 'ProcessPayment', event['data'])
        self.update_saga_state('payment_processed', 'pending')
    
    def handle_payment_processed(self, event):
        # Step 3: Ship order
        self.publish_command('shipping', 'ShipOrder', event['data'])
        self.update_saga_state('order_shipped', 'pending')
    
    def handle_failure(self, step, error):
        # Compensating transactions
        if step == 'payment_processed':
            self.publish_command('inventory', 'ReleaseItems', {'order_id': self.order_id})
        elif step == 'order_shipped':
            self.publish_command('payment', 'RefundPayment', {'order_id': self.order_id})
            self.publish_command('inventory', 'ReleaseItems', {'order_id': self.order_id})
    
    def publish_command(self, service, command, data):
        topic_path = self.publisher.topic_path('project-id', f'{service}-commands')
        message = {
            'command': command,
            'saga_id': self.order_id,
            'data': data
        }
        self.publisher.publish(topic_path, json.dumps(message).encode('utf-8'))
    
    def update_saga_state(self, step, status):
        doc_ref = self.db.collection('sagas').document(self.order_id)
        doc_ref.set({
            step: status,
            'updated_at': firestore.SERVER_TIMESTAMP
        }, merge=True)
```

---

## Performance Optimization

### Batching

```python
from google.cloud import pubsub_v1
from concurrent import futures

publisher = pubsub_v1.PublisherClient(
    batch_settings=pubsub_v1.types.BatchSettings(
        max_messages=100,
        max_bytes=1024 * 1024,  # 1 MB
        max_latency=0.1,  # 100 ms
    )
)

# Publish in batch
publish_futures = []
for message in messages:
    future = publisher.publish(topic_path, message.encode('utf-8'))
    publish_futures.append(future)

# Wait for all
futures.wait(publish_futures, return_when=futures.ALL_COMPLETED)
```

### Parallel Processing

```python
from concurrent.futures import ThreadPoolExecutor

def process_message(message):
    # Process individual message
    pass

def callback(message):
    with ThreadPoolExecutor(max_workers=10) as executor:
        executor.submit(process_message, message)
    message.ack()
```

---

## Checklist

### Design

- [ ] Messages are idempotent
- [ ] Correlation IDs included
- [ ] Message schema versioned
- [ ] Error handling implemented
- [ ] Dead letter topics configured
- [ ] Monitoring set up

### Reliability

- [ ] Retry logic with exponential backoff
- [ ] Circuit breakers implemented
- [ ] Timeouts configured
- [ ] Health checks enabled
- [ ] Graceful shutdown

### Performance

- [ ] Batching enabled
- [ ] Appropriate concurrency
- [ ] Message filtering used
- [ ] Compression enabled
- [ ] Connection pooling

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
