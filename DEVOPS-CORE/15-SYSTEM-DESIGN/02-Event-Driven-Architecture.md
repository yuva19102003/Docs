# Event-Driven Architecture Pattern

## Overview
Event-Driven Architecture (EDA) is a design pattern where services communicate by producing and consuming events. An event represents a significant change in state, and services react to these events asynchronously, enabling loose coupling and high scalability.

---

## Problem Statement

### Traditional Request-Response Challenges
- **Tight Coupling** - Services directly depend on each other
- **Synchronous Blocking** - Caller waits for response
- **Cascading Failures** - One service failure affects all
- **Scalability Limits** - Hard to scale individual components
- **Complex Orchestration** - Difficult to coordinate multiple services

### When to Use Event-Driven Architecture
✅ Asynchronous processing needed  
✅ Multiple services need same data  
✅ Real-time data streaming  
✅ Audit trail requirements  
✅ Complex business workflows  
✅ Microservices architecture  
✅ High scalability requirements  

### When NOT to Use
❌ Simple CRUD applications  
❌ Strong consistency required  
❌ Low latency critical (< 10ms)  
❌ Small team with limited expertise  
❌ Debugging complexity unacceptable  

---

## Architecture Diagram

### Complete Event-Driven System
```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              Event Producers                                      │
└────────┬─────────────┬─────────────┬─────────────┬─────────────┬────────────────┘
         │             │             │             │             │
    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐
    │  User  │    │ Order  │    │Payment │    │Inventory│   │Shipping│
    │Service │    │Service │    │Service │    │ Service │   │Service │
    └────┬───┘    └────┬───┘    └────┬───┘    └────┬───┘    └────┬───┘
         │             │             │             │             │
         │ Publish     │ Publish     │ Publish     │ Publish     │ Publish
         │ Events      │ Events      │ Events      │ Events      │ Events
         │             │             │             │             │
         └─────────────┴─────────────┴─────────────┴─────────────┘
                                     │
                          ┌──────────▼──────────┐
                          │   Event Broker      │
                          │   (Apache Kafka)    │
                          │                     │
                          │  Topics:            │
                          │  - user-events      │
                          │  - order-events     │
                          │  - payment-events   │
                          │  - inventory-events │
                          │  - shipping-events  │
                          └──────────┬──────────┘
                                     │
         ┌─────────────┬─────────────┼─────────────┬─────────────┐
         │             │             │             │             │
    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐    ┌────▼───┐
    │Analytics│   │ Email  │    │ SMS    │    │Audit   │    │ Data   │
    │Service │    │Service │    │Service │    │Service │    │Warehouse│
    └────────┘    └────────┘    └────────┘    └────────┘    └────────┘
         │             │             │             │             │
┌────────▼─────────────▼─────────────▼─────────────▼─────────────▼────────┐
│                        Event Consumers                                    │
└───────────────────────────────────────────────────────────────────────────┘
```

### Event Flow Example: Order Processing
```
┌──────────┐
│  Client  │
└────┬─────┘
     │ 1. POST /orders
     │
     ▼
┌────────────┐         ┌─────────────────┐
│   Order    │────────►│  Kafka Topic    │
│  Service   │ Publish │ "order-events"  │
└────────────┘ Event   └────────┬────────┘
                                │
                    ┌───────────┼───────────┬───────────┐
                    │           │           │           │
                    ▼           ▼           ▼           ▼
            ┌───────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
            │  Payment  │ │Inventory│ │  Email  │ │Analytics│
            │  Service  │ │ Service │ │ Service │ │ Service │
            └─────┬─────┘ └────┬────┘ └─────────┘ └─────────┘
                  │            │
                  │ Publish    │ Publish
                  │ Event      │ Event
                  │            │
                  ▼            ▼
            ┌─────────────────────┐
            │    Kafka Topics     │
            │ - payment-events    │
            │ - inventory-events  │
            └──────────┬──────────┘
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
      ┌──────────┐          ┌──────────┐
      │Shipping  │          │  Audit   │
      │ Service  │          │ Service  │
      └──────────┘          └──────────┘
```

---

## Workflow Explanation

### Order Creation Flow

#### Step 1: Order Placement
```
Client → Order Service
POST /api/orders
{
  "userId": "USR-123",
  "items": [{"productId": "PROD-456", "quantity": 2}],
  "totalAmount": 99.99
}
```

#### Step 2: Event Publishing
```javascript
// Order Service publishes event
const event = {
  eventId: "EVT-789",
  eventType: "OrderCreated",
  timestamp: "2026-01-05T10:30:00Z",
  aggregateId: "ORD-12345",
  version: 1,
  data: {
    orderId: "ORD-12345",
    userId: "USR-123",
    items: [
      {productId: "PROD-456", quantity: 2, price: 49.99}
    ],
    totalAmount: 99.99,
    status: "PENDING"
  }
};

await kafka.publish('order-events', event);
```

#### Step 3: Event Consumption (Multiple Services)

**Payment Service:**
```javascript
// Subscribe to order-events
consumer.on('OrderCreated', async (event) => {
  const payment = await processPayment(event.data);
  
  await kafka.publish('payment-events', {
    eventType: 'PaymentProcessed',
    orderId: event.data.orderId,
    paymentId: payment.id,
    status: payment.status
  });
});
```

**Inventory Service:**
```javascript
consumer.on('OrderCreated', async (event) => {
  const reserved = await reserveInventory(event.data.items);
  
  await kafka.publish('inventory-events', {
    eventType: 'InventoryReserved',
    orderId: event.data.orderId,
    items: reserved
  });
});
```

**Email Service:**
```javascript
consumer.on('OrderCreated', async (event) => {
  await sendEmail({
    to: event.data.userId,
    subject: 'Order Confirmation',
    body: `Your order ${event.data.orderId} has been received`
  });
});
```

#### Step 4: Saga Orchestration
```
OrderCreated → PaymentProcessed → InventoryReserved → ShippingScheduled → OrderCompleted
     │              │                   │                    │                 │
     ▼              ▼                   ▼                    ▼                 ▼
  PENDING      PAYMENT_OK          RESERVED            SCHEDULED          COMPLETED
```

---

## Key Components

### 1. Event Broker (Apache Kafka)

**Purpose:** Central hub for event distribution

**Responsibilities:**
- Event persistence
- Message ordering
- Scalable event streaming
- Fault tolerance
- Event replay capability

**Kafka Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│                    Kafka Cluster                        │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Broker 1 │  │ Broker 2 │  │ Broker 3 │            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
│       │             │             │                    │
│  ┌────▼─────────────▼─────────────▼─────┐            │
│  │         Topic: order-events           │            │
│  │  Partition 0 │ Partition 1 │ Part 2  │            │
│  │  Replica: 3  │ Replica: 3  │ Repl: 3 │            │
│  └───────────────────────────────────────┘            │
│                                                         │
│  ┌─────────────────────────────────────┐              │
│  │    ZooKeeper (Coordination)         │              │
│  └─────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

**Kafka Configuration:**
```yaml
# docker-compose.yml
version: '3.8'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: true
```

### 2. Event Store

**Purpose:** Persist all events for audit and replay

**Event Sourcing Pattern:**
```
Traditional State Storage:
┌──────────────┐
│   Database   │
│              │
│ Current State│
│ Only         │
└──────────────┘

Event Sourcing:
┌──────────────┐
│  Event Store │
│              │
│ Event 1      │
│ Event 2      │
│ Event 3      │
│ ...          │
│ Event N      │
└──────────────┘
      │
      │ Replay Events
      ▼
┌──────────────┐
│Current State │
└──────────────┘
```

**Event Store Schema:**
```sql
CREATE TABLE events (
  event_id UUID PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  aggregate_id VARCHAR(100) NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  version INTEGER NOT NULL,
  data JSONB NOT NULL,
  metadata JSONB,
  timestamp TIMESTAMP NOT NULL,
  INDEX idx_aggregate (aggregate_id, version)
);
```

### 3. Event Schema Registry

**Purpose:** Manage event schema versions

**Tools:**
- **Confluent Schema Registry** - Kafka schema management
- **Apache Avro** - Binary serialization format
- **Protocol Buffers** - Google's serialization

**Example Schema (Avro):**
```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.example.events",
  "fields": [
    {"name": "eventId", "type": "string"},
    {"name": "eventType", "type": "string"},
    {"name": "timestamp", "type": "long"},
    {"name": "orderId", "type": "string"},
    {"name": "userId", "type": "string"},
    {"name": "totalAmount", "type": "double"},
    {"name": "items", "type": {
      "type": "array",
      "items": {
        "type": "record",
        "name": "OrderItem",
        "fields": [
          {"name": "productId", "type": "string"},
          {"name": "quantity", "type": "int"},
          {"name": "price", "type": "double"}
        ]
      }
    }}
  ]
}
```

### 4. Consumer Groups

**Purpose:** Parallel event processing with load balancing

**Consumer Group Pattern:**
```
┌─────────────────────────────────────┐
│      Kafka Topic (3 Partitions)    │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │ P0   │  │ P1   │  │ P2   │     │
│  └───┬──┘  └───┬──┘  └───┬──┘     │
└──────┼─────────┼─────────┼─────────┘
       │         │         │
       │         │         │
┌──────▼─────────▼─────────▼─────────┐
│    Consumer Group: email-service   │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │ C1   │  │ C2   │  │ C3   │     │
│  │ P0   │  │ P1   │  │ P2   │     │
│  └──────┘  └──────┘  └──────┘     │
└────────────────────────────────────┘
```

**Consumer Configuration:**
```javascript
const consumer = kafka.consumer({
  groupId: 'email-service-group',
  sessionTimeout: 30000,
  heartbeatInterval: 3000
});

await consumer.connect();
await consumer.subscribe({
  topics: ['order-events', 'payment-events'],
  fromBeginning: false
});

await consumer.run({
  eachMessage: async ({ topic, partition, message }) => {
    const event = JSON.parse(message.value.toString());
    await handleEvent(event);
  }
});
```

---

## Event Patterns

### 1. Event Notification
**Simple notification that something happened**

```javascript
{
  "eventType": "UserRegistered",
  "userId": "USR-123",
  "timestamp": "2026-01-05T10:30:00Z"
}
```

### 2. Event-Carried State Transfer
**Event contains all necessary data**

```javascript
{
  "eventType": "UserRegistered",
  "userId": "USR-123",
  "email": "user@example.com",
  "name": "John Doe",
  "registrationDate": "2026-01-05T10:30:00Z",
  "accountType": "PREMIUM"
}
```

### 3. Event Sourcing
**All state changes stored as events**

```javascript
// Event Stream for Order ORD-123
[
  {
    "eventType": "OrderCreated",
    "orderId": "ORD-123",
    "version": 1,
    "data": {...}
  },
  {
    "eventType": "PaymentReceived",
    "orderId": "ORD-123",
    "version": 2,
    "data": {...}
  },
  {
    "eventType": "OrderShipped",
    "orderId": "ORD-123",
    "version": 3,
    "data": {...}
  }
]
```

### 4. CQRS (Command Query Responsibility Segregation)
```
┌──────────┐         ┌──────────┐         ┌──────────┐
│ Command  │────────►│  Event   │────────►│  Query   │
│  Model   │ Publish │  Store   │ Project │  Model   │
│ (Write)  │         │          │         │  (Read)  │
└──────────┘         └──────────┘         └──────────┘
```

---

## Implementation Examples

### Node.js Producer
```javascript
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'order-service',
  brokers: ['kafka:9092']
});

const producer = kafka.producer();

async function publishOrderCreated(order) {
  await producer.connect();
  
  const event = {
    eventId: generateUUID(),
    eventType: 'OrderCreated',
    timestamp: new Date().toISOString(),
    aggregateId: order.id,
    version: 1,
    data: order
  };
  
  await producer.send({
    topic: 'order-events',
    messages: [{
      key: order.id,
      value: JSON.stringify(event),
      headers: {
        'event-type': 'OrderCreated',
        'correlation-id': order.correlationId
      }
    }]
  });
  
  console.log(`Published event: ${event.eventId}`);
}
```

### Node.js Consumer
```javascript
const consumer = kafka.consumer({
  groupId: 'payment-service-group'
});

async function startConsumer() {
  await consumer.connect();
  await consumer.subscribe({
    topics: ['order-events'],
    fromBeginning: false
  });
  
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const event = JSON.parse(message.value.toString());
      
      console.log(`Received event: ${event.eventType}`);
      
      switch(event.eventType) {
        case 'OrderCreated':
          await handleOrderCreated(event);
          break;
        case 'OrderCancelled':
          await handleOrderCancelled(event);
          break;
        default:
          console.log(`Unknown event type: ${event.eventType}`);
      }
    }
  });
}

async function handleOrderCreated(event) {
  try {
    // Process payment
    const payment = await processPayment(event.data);
    
    // Publish payment event
    await publishPaymentProcessed(payment);
  } catch (error) {
    console.error('Payment processing failed:', error);
    await publishPaymentFailed(event.data.orderId, error);
  }
}
```

### Go Producer
```go
package main

import (
    "context"
    "encoding/json"
    "github.com/segmentio/kafka-go"
    "time"
)

type OrderCreatedEvent struct {
    EventID     string    `json:"eventId"`
    EventType   string    `json:"eventType"`
    Timestamp   time.Time `json:"timestamp"`
    AggregateID string    `json:"aggregateId"`
    Version     int       `json:"version"`
    Data        Order     `json:"data"`
}

func publishOrderCreated(order Order) error {
    writer := kafka.NewWriter(kafka.WriterConfig{
        Brokers: []string{"kafka:9092"},
        Topic:   "order-events",
    })
    defer writer.Close()
    
    event := OrderCreatedEvent{
        EventID:     generateUUID(),
        EventType:   "OrderCreated",
        Timestamp:   time.Now(),
        AggregateID: order.ID,
        Version:     1,
        Data:        order,
    }
    
    eventJSON, _ := json.Marshal(event)
    
    err := writer.WriteMessages(context.Background(),
        kafka.Message{
            Key:   []byte(order.ID),
            Value: eventJSON,
        },
    )
    
    return err
}
```

---

## Error Handling & Resilience

### Dead Letter Queue Pattern
```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Event   │────────►│Consumer  │ Failed  │   DLQ    │
│  Topic   │         │          │────────►│  Topic   │
└──────────┘         └──────────┘         └──────────┘
                           │
                           │ Retry 3x
                           │
                           ▼
                     ┌──────────┐
                     │ Success  │
                     └──────────┘
```

**Implementation:**
```javascript
async function processWithRetry(event, maxRetries = 3) {
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      await processEvent(event);
      return; // Success
    } catch (error) {
      attempt++;
      console.error(`Attempt ${attempt} failed:`, error);
      
      if (attempt >= maxRetries) {
        // Send to DLQ
        await sendToDeadLetterQueue(event, error);
        throw error;
      }
      
      // Exponential backoff
      await sleep(Math.pow(2, attempt) * 1000);
    }
  }
}
```

### Idempotency
```javascript
// Ensure events are processed only once
const processedEvents = new Set();

async function handleEvent(event) {
  // Check if already processed
  if (processedEvents.has(event.eventId)) {
    console.log(`Event ${event.eventId} already processed`);
    return;
  }
  
  // Process event
  await processEvent(event);
  
  // Mark as processed
  processedEvents.add(event.eventId);
  await saveProcessedEvent(event.eventId);
}
```

---

## Monitoring & Observability

### Key Metrics
```
┌─────────────────────────────────────────┐
│         Kafka Metrics                   │
├─────────────────────────────────────────┤
│ • Messages per second                   │
│ • Consumer lag                          │
│ • Partition distribution                │
│ • Broker health                         │
│ • Replication status                    │
│ • Disk usage                            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│      Application Metrics                │
├─────────────────────────────────────────┤
│ • Event processing time                 │
│ • Error rate                            │
│ • DLQ message count                     │
│ • Event throughput                      │
│ • Consumer group lag                    │
└─────────────────────────────────────────┘
```

### Prometheus Metrics
```javascript
const { Counter, Histogram } = require('prom-client');

const eventsProcessed = new Counter({
  name: 'events_processed_total',
  help: 'Total number of events processed',
  labelNames: ['event_type', 'status']
});

const eventProcessingDuration = new Histogram({
  name: 'event_processing_duration_seconds',
  help: 'Event processing duration',
  labelNames: ['event_type']
});

async function handleEvent(event) {
  const timer = eventProcessingDuration.startTimer({
    event_type: event.eventType
  });
  
  try {
    await processEvent(event);
    eventsProcessed.inc({
      event_type: event.eventType,
      status: 'success'
    });
  } catch (error) {
    eventsProcessed.inc({
      event_type: event.eventType,
      status: 'error'
    });
    throw error;
  } finally {
    timer();
  }
}
```

---

## Best Practices

### Event Design
✅ **Immutable Events** - Never modify published events  
✅ **Self-Contained** - Include all necessary data  
✅ **Versioned** - Support schema evolution  
✅ **Timestamped** - Include event timestamp  
✅ **Identifiable** - Unique event ID  
✅ **Traceable** - Include correlation ID  

### Consumer Design
✅ **Idempotent** - Handle duplicate events  
✅ **Resilient** - Implement retry logic  
✅ **Fast** - Process events quickly  
✅ **Stateless** - Don't rely on local state  
✅ **Observable** - Log and monitor  

### Operational
✅ **Monitor Lag** - Track consumer lag  
✅ **Set Retention** - Configure topic retention  
✅ **Partition Strategy** - Choose partition key wisely  
✅ **Backup Events** - Archive to S3/blob storage  
✅ **Test Replay** - Verify event replay capability  

---

## Pros & Cons

### Advantages
✅ **Loose Coupling** - Services don't know about each other  
✅ **Scalability** - Easy to add consumers  
✅ **Resilience** - Services can fail independently  
✅ **Audit Trail** - Complete event history  
✅ **Flexibility** - Easy to add new features  
✅ **Real-time** - Immediate event propagation  

### Disadvantages
❌ **Complexity** - More moving parts  
❌ **Eventual Consistency** - Not immediately consistent  
❌ **Debugging** - Harder to trace issues  
❌ **Ordering** - Complex to maintain order  
❌ **Duplicate Events** - Must handle idempotency  
❌ **Learning Curve** - Requires expertise  

---

## Related Patterns
- [Microservices Architecture](01-Microservices-Architecture.md)
- [CQRS Pattern](06-CQRS-Pattern.md)
- [Message Queue Patterns](12-Message-Queue-Patterns.md)
- [Circuit Breaker Pattern](08-Circuit-Breaker.md)

---

## Tools & Resources

### Event Brokers
- **Apache Kafka** - Distributed streaming platform
- **RabbitMQ** - Message broker with routing
- **AWS EventBridge** - Managed event bus
- **Google Pub/Sub** - Managed messaging

### Event Stores
- **EventStoreDB** - Purpose-built event store
- **PostgreSQL** - With JSONB for events
- **MongoDB** - Document-based storage

### Monitoring
- **Kafka Manager** - Kafka cluster management
- **Confluent Control Center** - Enterprise monitoring
- **Prometheus + Grafana** - Metrics and visualization

---

**Last Updated:** January 5, 2026  
**Pattern Complexity:** High  
**Recommended For:** Microservices, real-time systems, audit requirements
