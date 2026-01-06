
## 📦 What is AWS SQS?

**Amazon Simple Queue Service (SQS)** is a **fully managed message queuing service** that enables **decoupled communication** between distributed systems.

> ✅ Use it to **buffer, store, and process** messages between microservices, workers, or serverless functions — **without message loss** or the need to manage brokers.

---

## 🧠 Key Concepts

|Concept|Description|
|---|---|
|**Queue**|A buffer that stores messages until they are processed|
|**Message**|Up to 256 KB of data (text or binary)|
|**Producer**|Component that sends messages to the queue|
|**Consumer**|Component that receives and processes messages|
|**Visibility Timeout**|Hides a message from other consumers while being processed|
|**Dead Letter Queue (DLQ)**|Stores messages that couldn't be processed after multiple tries|

---

## 🧾 Queue Types

|Queue Type|Description|
|---|---|
|**Standard Queue**|High throughput, **at-least-once** delivery, possible out-of-order|
|**FIFO Queue**|**Exactly-once processing**, maintains message order, lower throughput|

---

## 🎯 Use Cases

|Use Case|Why Use SQS?|
|---|---|
|Async task queue for microservices|Decouples producers and consumers|
|Order processing systems|Buffer transactions and maintain order|
|Email/SMS job processing|Offload bursty workloads to background workers|
|Serverless event pipelines|Lambda + SQS for async logic|

---

## 🔗 SQS Integration Options

|Source / Target|Integration Method|
|---|---|
|AWS Lambda|SQS event source mapping|
|EC2 worker app|Long polling with SDK|
|API Gateway|Direct integration with SQS (via VTL)|
|SNS|SNS ➡️ SQS fan-out|

---

## 🛠️ Terraform Example — Standard Queue + Lambda

### 1. Create SQS Queue

```hcl
resource "aws_sqs_queue" "my_queue" {
  name                      = "my-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600  # 4 days
}
```

### 2. Lambda Permission + Trigger

```hcl
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.my_queue.arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 5
  enabled          = true
}
```

---

## ⚙️ Advanced Features

|Feature|Description|
|---|---|
|**DLQ (Dead Letter Queue)**|Captures failed messages after N receive attempts|
|**Long Polling**|Wait up to 20 seconds for messages (cost efficient)|
|**Message Attributes**|Metadata for routing/filtering|
|**Delay Queues**|Delay delivery of new messages for up to 15 mins|
|**FIFO Groups**|Maintain order within message group IDs|
|**Server-side Encryption**|Encrypt messages using SSE-SQS or SSE-KMS|

---

## 🧪 Example: DLQ Configuration

```hcl
resource "aws_sqs_queue" "dlq" {
  name = "my-dlq"
}

resource "aws_sqs_queue" "main" {
  name = "my-main-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn,
    maxReceiveCount     = 3
  })
}
```

---

## 🔐 Security

|Security Layer|Description|
|---|---|
|IAM Policies|Control send/receive/delete access|
|Queue Policies|Allow cross-account or service access|
|SSE Encryption|Managed (SSE-SQS) or Customer-managed (SSE-KMS)|
|VPC Endpoint (PrivateLink)|Send/receive within private subnets|

---

## 📊 Monitoring

|Tool|Metrics|
|---|---|
|CloudWatch|NumberOfMessagesSent, Received, Deleted|
|DLQ monitoring|ApproximateNumberOfMessagesVisible (DLQ)|
|CloudTrail|SQS API activity (create/delete/receive)|
|X-Ray|Traces if used with Lambda|

---

## 💰 Pricing (as of 2024)

|Queue Type|Cost per million requests|Notes|
|---|---|---|
|Standard|~$0.40|First 1M/month free|
|FIFO|~$0.50|Includes sequencing cost|
|Data Transfer|$0 within same region|Standard AWS outbound fees|

---

## ⚖️ Standard vs FIFO Comparison

|Feature|Standard Queue|FIFO Queue|
|---|---|---|
|Order guarantee|❌ No|✅ Yes|
|Duplicate messages|✅ Possible|❌ Not allowed|
|Max throughput|Very high|Lower (300 msg/sec default)|
|Use case|Logs, telemetry, jobs|Orders, payments, workflows|

---

## 📦 Message Structure

```json
{
  "MessageBody": "Hello, World!",
  "MessageAttributes": {
    "UserType": {
      "DataType": "String",
      "StringValue": "admin"
    }
  },
  "DelaySeconds": 10
}
```

---

## ✅ TL;DR Summary

|Feature|AWS SQS|
|---|---|
|Type|Managed message queue|
|Queue types|Standard (default), FIFO|
|Use case|Async processing, decoupling, retries|
|Max message size|256 KB (use S3 + pointer for large payload)|
|Retry/DLQ|✅ Built-in|
|Integration|Lambda, EC2, ECS, API Gateway, SNS|
|Terraform Support|✅ `aws_sqs_queue`|

---
