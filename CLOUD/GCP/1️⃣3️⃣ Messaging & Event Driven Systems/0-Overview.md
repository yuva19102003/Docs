# 1️⃣3️⃣ Messaging & Event Driven Systems - Overview

Learn event-driven architecture on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Messaging Patterns](#messaging-patterns)
3. [Services Comparison](#services-comparison)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Considerations](#cost-considerations)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP provides multiple services for building event-driven and message-based architectures.

### Messaging Stack

```
┌─────────────────────────────────────────────────────┐
│         Event-Driven Architecture                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Pub/Sub │  │ Eventarc │  │  Cloud   │        │
│  │          │  │          │  │  Tasks   │        │
│  └──────────┘  └──────────┘  └──────────┘        │
│                                                     │
│  ┌──────────┐  ┌──────────┐                       │
│  │ Cloud    │  │ Workflows│                       │
│  │ Scheduler│  │          │                       │
│  └──────────┘  └──────────┘                       │
└─────────────────────────────────────────────────────┘
```

---

## Messaging Patterns

### 1. Pub/Sub (Publish-Subscribe)

**Asynchronous messaging service**

```
┌─────────────────────────────────────┐
│          Pub/Sub                    │
├─────────────────────────────────────┤
│  Publishers                         │
│      ↓                              │
│  ┌─────────┐                        │
│  │  Topic  │                        │
│  └────┬────┘                        │
│       ↓                             │
│  ┌─────────────────────┐            │
│  │  Subscriptions      │            │
│  ├─────────────────────┤            │
│  │ • Push              │            │
│  │ • Pull              │            │
│  │ • BigQuery          │            │
│  │ • Cloud Storage     │            │
│  └─────────────────────┘            │
├─────────────────────────────────────┤
│  Features:                          │
│  • At-least-once delivery           │
│  • Message ordering                 │
│  • Dead letter topics               │
│  • Message filtering                │
│  • Exactly-once delivery            │
└─────────────────────────────────────┘
```

**Characteristics:**
- Asynchronous messaging
- Decoupled services
- Scalable (millions of messages/sec)
- Global availability
- Message retention (7 days)

**Use Cases:**
- Microservices communication
- Event streaming
- Data ingestion
- Async processing
- Fan-out patterns

### 2. Eventarc

**Event routing and delivery**

```
┌─────────────────────────────────────┐
│          Eventarc                   │
├─────────────────────────────────────┤
│  Event Sources:                     │
│  • Cloud Storage                    │
│  • Pub/Sub                          │
│  • Cloud Audit Logs                 │
│  • Custom events                    │
│      ↓                              │
│  ┌─────────┐                        │
│  │Eventarc │                        │
│  │ Routing │                        │
│  └────┬────┘                        │
│       ↓                             │
│  Event Targets:                     │
│  • Cloud Run                        │
│  • Cloud Functions                  │
│  • GKE                              │
│  • Workflows                        │
├─────────────────────────────────────┤
│  Features:                          │
│  • CloudEvents format               │
│  • Event filtering                  │
│  • Multiple sources                 │
│  • Declarative routing              │
└─────────────────────────────────────┘
```

**Characteristics:**
- Event routing
- CloudEvents standard
- Multiple sources
- Declarative configuration
- Serverless integration

**Use Cases:**
- Event-driven workflows
- Cloud event handling
- Serverless triggers
- Multi-source events
- Event orchestration

### 3. Cloud Tasks

**Asynchronous task execution**

```
┌─────────────────────────────────────┐
│         Cloud Tasks                 │
├─────────────────────────────────────┤
│  Task Queue                         │
│  ┌─────────────────────────────┐   │
│  │ Task 1 → HTTP Target        │   │
│  │ Task 2 → HTTP Target        │   │
│  │ Task 3 → HTTP Target        │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Features:                          │
│  • Scheduled execution              │
│  • Rate limiting                    │
│  • Retry logic                      │
│  • Task deduplication               │
│  • HTTP/App Engine targets          │
├─────────────────────────────────────┤
│  Queue Types:                       │
│  • Push queues                      │
│  • Pull queues (deprecated)         │
└─────────────────────────────────────┘
```

**Characteristics:**
- Task scheduling
- Guaranteed execution
- Rate control
- Retry mechanism
- HTTP-based

**Use Cases:**
- Background jobs
- Scheduled tasks
- Rate-limited operations
- Reliable task execution
- Async API calls

### 4. Cloud Scheduler

**Cron job service**

```
┌─────────────────────────────────────┐
│       Cloud Scheduler               │
├─────────────────────────────────────┤
│  Cron Jobs:                         │
│  ┌─────────────────────────────┐   │
│  │ */5 * * * * → HTTP Target   │   │
│  │ 0 9 * * 1 → Pub/Sub Topic   │   │
│  │ 0 0 * * * → App Engine      │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Features:                          │
│  • Cron syntax                      │
│  • Multiple targets                 │
│  • Retry configuration              │
│  • Time zones                       │
│  • Monitoring                       │
├─────────────────────────────────────┤
│  Targets:                           │
│  • HTTP endpoints                   │
│  • Pub/Sub topics                   │
│  • App Engine                       │
└─────────────────────────────────────┘
```

**Characteristics:**
- Scheduled jobs
- Cron syntax
- Multiple targets
- Reliable execution
- Fully managed

**Use Cases:**
- Periodic tasks
- Batch processing
- Report generation
- Data cleanup
- Health checks

### 5. Workflows

**Service orchestration**

```
┌─────────────────────────────────────┐
│         Workflows                   │
├─────────────────────────────────────┤
│  Workflow Definition (YAML):        │
│  ┌─────────────────────────────┐   │
│  │ Step 1: Call API A          │   │
│  │    ↓                        │   │
│  │ Step 2: Process data        │   │
│  │    ↓                        │   │
│  │ Step 3: Call API B          │   │
│  │    ↓                        │   │
│  │ Step 4: Store result        │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Features:                          │
│  • Service orchestration            │
│  • Error handling                   │
│  • Conditional logic                │
│  • Parallel execution               │
│  • Built-in connectors              │
└─────────────────────────────────────┘
```

**Characteristics:**
- Service orchestration
- YAML-based workflows
- Error handling
- Conditional logic
- Serverless

**Use Cases:**
- Multi-step processes
- Service orchestration
- Business workflows
- Data pipelines
- API composition

---

## Services Comparison

### Feature Matrix

| Feature | Pub/Sub | Eventarc | Cloud Tasks | Cloud Scheduler | Workflows |
|---------|---------|----------|-------------|-----------------|-----------|
| **Type** | Messaging | Event routing | Task queue | Cron jobs | Orchestration |
| **Pattern** | Pub/Sub | Event-driven | Queue | Scheduled | Sequential |
| **Delivery** | At-least-once | At-least-once | At-least-once | At-least-once | Exactly-once |
| **Ordering** | Yes (optional) | No | Yes | N/A | Yes |
| **Retry** | Yes | Yes | Yes | Yes | Yes |
| **Targets** | Multiple | Multiple | HTTP | HTTP/Pub/Sub | APIs |
| **Scheduling** | No | No | Yes | Yes | No |
| **Max Retention** | 7 days | N/A | 30 days | N/A | 1 year |

---

## Decision Framework

### Service Selection

```
What do you need?
    |
    ├─> Async messaging between services?
    |   └─> Pub/Sub
    |
    ├─> React to cloud events?
    |   └─> Eventarc
    |
    ├─> Execute tasks asynchronously?
    |   └─> Cloud Tasks
    |
    ├─> Schedule periodic jobs?
    |   └─> Cloud Scheduler
    |
    └─> Orchestrate multiple services?
        └─> Workflows
```

### Use Case Matrix

| Requirement | Recommended | Alternative |
|-------------|-------------|-------------|
| **Microservices messaging** | Pub/Sub | Eventarc |
| **Event-driven architecture** | Eventarc | Pub/Sub |
| **Background jobs** | Cloud Tasks | Pub/Sub |
| **Scheduled tasks** | Cloud Scheduler | Cloud Tasks |
| **Service orchestration** | Workflows | Cloud Tasks |
| **Data streaming** | Pub/Sub | Dataflow |
| **File upload triggers** | Eventarc | Cloud Functions |
| **Rate-limited operations** | Cloud Tasks | Pub/Sub |

---

## Architecture Patterns

### Pattern 1: Event-Driven Microservices

```
┌─────────────────────────────────────┐
│      Event-Driven Architecture      │
└─────────────────────────────────────┘

Service A                Service B
    |                        |
    v                        v
┌────────┐              ┌────────┐
│Publish │              │Publish │
└───┬────┘              └───┬────┘
    |                       |
    └───────┬───────────────┘
            v
    ┌───────────────┐
    │   Pub/Sub     │
    │    Topic      │
    └───────┬───────┘
            |
    ┌───────┼───────┐
    v       v       v
┌────────┐┌────────┐┌────────┐
│Service ││Service ││Service │
│   C    ││   D    ││   E    │
└────────┘└────────┘└────────┘
```

### Pattern 2: Event Processing Pipeline

```
Cloud Storage
    |
    | (File uploaded)
    v
┌─────────────────────┐
│     Eventarc        │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Cloud Function     │
│  (Process file)     │
└──────────┬──────────┘
           v
┌─────────────────────┐
│     Pub/Sub         │
└──────────┬──────────┘
           v
┌─────────────────────┐
│    Dataflow         │
│  (Transform data)   │
└──────────┬──────────┘
           v
┌─────────────────────┐
│    BigQuery         │
└─────────────────────┘
```

### Pattern 3: Task Queue Pattern

```
API Request
    |
    v
┌─────────────────────┐
│   Cloud Run         │
│   (API Service)     │
└──────────┬──────────┘
           |
    (Create task)
           v
┌─────────────────────┐
│   Cloud Tasks       │
│   (Task Queue)      │
└──────────┬──────────┘
           |
    (Execute task)
           v
┌─────────────────────┐
│   Cloud Run         │
│   (Worker Service)  │
└─────────────────────┘
```

### Pattern 4: Scheduled Workflow

```
┌─────────────────────┐
│  Cloud Scheduler    │
│  (Daily at 9 AM)    │
└──────────┬──────────┘
           v
┌─────────────────────┐
│     Pub/Sub         │
└──────────┬──────────┘
           v
┌─────────────────────┐
│    Workflows        │
│  ┌───────────────┐  │
│  │ 1. Fetch data │  │
│  │ 2. Process    │  │
│  │ 3. Store      │  │
│  │ 4. Notify     │  │
│  └───────────────┘  │
└─────────────────────┘
```

### Pattern 5: Fan-Out/Fan-In

```
┌─────────────────────┐
│   Single Event      │
└──────────┬──────────┘
           v
┌─────────────────────┐
│     Pub/Sub         │
│      Topic          │
└──────────┬──────────┘
           |
    ┌──────┼──────┐  (Fan-Out)
    v      v      v
┌──────┐┌──────┐┌──────┐
│Sub 1 ││Sub 2 ││Sub 3 │
└───┬──┘└───┬──┘└───┬──┘
    |      |      |
    └──────┼──────┘  (Fan-In)
           v
┌─────────────────────┐
│   Aggregator        │
└─────────────────────┘
```

---

## Cost Considerations

### Pricing Overview

**Pub/Sub:**
- First 10 GB/month: Free
- Additional data: $0.04 per GB
- Message delivery: $0.04 per GB

**Eventarc:**
- First 100,000 events/month: Free
- Additional: $0.40 per million events

**Cloud Tasks:**
- First 1 million operations/month: Free
- Additional: $0.40 per million operations

**Cloud Scheduler:**
- First 3 jobs/month: Free
- Additional: $0.10 per job/month

**Workflows:**
- First 5,000 steps/month: Free
- Additional: $0.01 per 1,000 steps

### Cost Optimization

```bash
# Use message filtering to reduce processing
gcloud pubsub subscriptions create filtered-sub \
  --topic=my-topic \
  --message-filter='attributes.priority="high"'

# Set appropriate message retention
gcloud pubsub topics update my-topic \
  --message-retention-duration=1h

# Use dead letter topics
gcloud pubsub subscriptions update my-sub \
  --dead-letter-topic=dead-letter-topic \
  --max-delivery-attempts=5
```

---

## Quick Reference

### Pub/Sub

```bash
# Create topic
gcloud pubsub topics create my-topic

# Create subscription
gcloud pubsub subscriptions create my-sub \
  --topic=my-topic

# Publish message
gcloud pubsub topics publish my-topic \
  --message="Hello World"

# Pull messages
gcloud pubsub subscriptions pull my-sub --auto-ack
```

### Eventarc

```bash
# Create trigger
gcloud eventarc triggers create my-trigger \
  --location=us-central1 \
  --destination-run-service=my-service \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=my-bucket"
```

### Cloud Tasks

```bash
# Create queue
gcloud tasks queues create my-queue

# Create task
gcloud tasks create-http-task \
  --queue=my-queue \
  --url=https://example.com/process \
  --method=POST \
  --body-content='{"data":"value"}'
```

### Cloud Scheduler

```bash
# Create job
gcloud scheduler jobs create http my-job \
  --schedule="0 9 * * *" \
  --uri="https://example.com/endpoint" \
  --http-method=POST
```

### Workflows

```yaml
# workflow.yaml
main:
  steps:
    - step1:
        call: http.get
        args:
          url: https://api.example.com/data
        result: apiResponse
    - step2:
        return: ${apiResponse.body}
```

```bash
# Deploy workflow
gcloud workflows deploy my-workflow \
  --source=workflow.yaml \
  --location=us-central1
```

---

## Best Practices

### Pub/Sub

✅ Use message attributes for filtering  
✅ Implement idempotent message processing  
✅ Set appropriate acknowledgment deadlines  
✅ Use dead letter topics  
✅ Enable message ordering when needed  
✅ Monitor subscription backlog  
✅ Use push subscriptions for low latency  
✅ Implement retry logic  

### Eventarc

✅ Use CloudEvents format  
✅ Implement event filtering  
✅ Handle duplicate events  
✅ Monitor event delivery  
✅ Use appropriate event sources  
✅ Implement error handling  

### Cloud Tasks

✅ Set appropriate task deadlines  
✅ Implement idempotent handlers  
✅ Use rate limiting  
✅ Monitor queue depth  
✅ Configure retry policies  
✅ Use task deduplication  

### Cloud Scheduler

✅ Use appropriate time zones  
✅ Implement idempotent jobs  
✅ Monitor job execution  
✅ Set retry configuration  
✅ Use Pub/Sub for fan-out  

### Workflows

✅ Implement error handling  
✅ Use retries appropriately  
✅ Keep workflows simple  
✅ Monitor execution  
✅ Use variables effectively  
✅ Implement timeouts  

---

## Next Steps

1. **[Pub/Sub](1-Pub-Sub.md)** - Messaging service
2. **[Eventarc](2-Eventarc.md)** - Event routing
3. **[Cloud Tasks](3-Cloud-Tasks.md)** - Task queue
4. **[Cloud Scheduler](4-Cloud-Scheduler.md)** - Cron jobs
5. **[Workflows](5-Workflows.md)** - Service orchestration
6. **[Best Practices](6-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Eventarc Documentation](https://cloud.google.com/eventarc/docs)
- [Cloud Tasks Documentation](https://cloud.google.com/tasks/docs)
- [Cloud Scheduler Documentation](https://cloud.google.com/scheduler/docs)
- [Workflows Documentation](https://cloud.google.com/workflows/docs)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
