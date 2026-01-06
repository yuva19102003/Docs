
## 📣 What is Amazon SNS?

**Amazon SNS** is a **fully managed pub/sub (publish-subscribe) messaging service** that lets you **send messages to multiple subscribers** like Lambda, SQS, email, SMS, HTTP, and mobile push endpoints.

> ✅ It’s designed for **fan-out architecture**, **notifications**, and **decoupling event producers from consumers**.

---

## 🧠 Core Concepts

|Concept|Description|
|---|---|
|**Topic**|A named communication channel for publishers and subscribers|
|**Publisher**|Any component that sends messages to a topic|
|**Subscriber**|Endpoints that receive messages from the topic|
|**Message**|Content that’s sent to all subscribers (JSON, plaintext, etc.)|

---

## 🔗 Supported Protocols (Subscribers)

|Protocol Type|Example Targets|
|---|---|
|**Lambda**|Trigger serverless functions|
|**SQS**|Fan-out messages to multiple queues|
|**HTTP/S**|POST messages to webhook endpoints|
|**Email/Email-JSON**|Send email notifications|
|**SMS**|Text messages to mobile numbers|
|**Application (Mobile push)**|Apple, GCM, etc.|

---

## 🎯 Common Use Cases

|Scenario|Description|
|---|---|
|❗ System alerts|Send error messages to email/SMS/Lambda|
|🔁 Fan-out to multiple systems|Publish once, process in Lambda + SQS|
|🛒 Order confirmation|Notify user + payment gateway simultaneously|
|📦 Decouple microservices|Allow async communication between services|
|📱 Push notifications|Send app alerts to mobile devices|

---

## 🧱 SNS Architecture

```
Publisher
    |
    v
  [ SNS Topic ]
   /   |   \
 SQS Lambda Email (Fan-out)
```

---

## 🛠️ Terraform Example – SNS with Lambda & SQS

### 1. Create SNS Topic

```hcl
resource "aws_sns_topic" "orders" {
  name = "order-events"
}
```

### 2. Subscribe SQS to Topic

```hcl
resource "aws_sqs_queue" "queue" {
  name = "order-processing-queue"
}

resource "aws_sns_topic_subscription" "sqs_sub" {
  topic_arn = aws_sns_topic.orders.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue.arn

  raw_message_delivery = true
}
```

> Note: Add proper permissions on SQS queue to allow SNS to send messages.

```hcl
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "sqs:SendMessage",
      Resource = aws_sqs_queue.queue.arn,
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.orders.arn
        }
      }
    }]
  })
}
```

### 3. Subscribe Lambda to Topic

```hcl
resource "aws_lambda_permission" "sns_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.orders.arn
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.orders.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.handler.arn
}
```

---

## 🧪 Message Filtering

You can use **message filtering** to deliver messages only to specific subscribers based on message attributes.

### Example:

**Message Attributes**

```json
{
  "type": "order",
  "status": "shipped"
}
```

**Subscription Filter Policy**

```json
{
  "status": ["shipped"]
}
```

Only messages with `status: shipped` will be delivered.

---

## 🔐 Security

|Security Layer|Description|
|---|---|
|IAM Policies|Control publish/subscribe access|
|Topic Policies|Allow specific principals or services|
|Encryption at Rest|KMS support (SSE-SNS)|
|VPC Endpoint|Use PrivateLink for private access|

---

## 📊 Monitoring

|Tool|Metric/Log|
|---|---|
|CloudWatch|NumberOfMessagesPublished, Delivered, Failed|
|CloudTrail|Logs topic-level API activity|
|Dead Letter Queue (DLQ)|Capture undeliverable Lambda events|

---

## 💰 Pricing (as of 2024)

|Component|Free Tier|Paid|
|---|---|---|
|SNS API calls|1M requests/month free|$0.50/million after that|
|Email|1,000 emails/month free|$0.10 per 1,000 after|
|SMS|$0.0075+ per message (region)|Pay per send|
|Mobile Push|Free||

---

## ✅ TL;DR Summary

|Feature|Amazon SNS|
|---|---|
|Type|Managed pub/sub messaging|
|Queue Types|Push-based (fan-out)|
|Integrates with|Lambda, SQS, HTTP, SMS, Email, Mobile|
|Message Filtering|✅ Yes|
|Encryption|✅ KMS (SSE-SNS)|
|Monitoring|✅ CloudWatch, DLQ|
|Terraform Support|✅ (`aws_sns_topic`, `aws_sns_topic_subscription`)|

---
