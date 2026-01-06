## 🌩️ AWS CloudWatch Logs — Overview with Examples

CloudWatch Logs helps you **collect, monitor, search, and analyze logs** from AWS services and custom sources. Below are the core components explained with examples:

---
### ✅ 1. **Log Groups**
- **Definition:** A container for multiple **log streams** from similar components or services.
- **Example:**
    ```bash
    Log Group: /ecs/payment-service
    ```
    Used to group all logs from ECS containers running the payment service.
---
### ✅ 2. **Log Streams**
- **Definition:** A sequence of **log events** from a single source (e.g., Lambda function invocation, EC2 instance).
- **Example:**
    ```bash
    Log Stream: ecs/payment-service/f1a23bc4a5674b8c9d
    ```
    Logs from a single ECS task or EC2 instance.
---
### ✅ 3. **Log Events**
- **Definition:** Individual log entries with a timestamp and message.
- **Example:**
    ```json
    {
      "timestamp": 1712840835000,
      "message": "2025-04-11 10:27:15 [ERROR] Payment failed: Card declined"
    }
    ```
---
### ✅ 4. **Source**
- **Definition:** The origin of the logs.
- **Examples of sources:**
    - AWS Lambda
    - EC2 with CloudWatch Agent
    - ECS/Containers
    - API Gateway
- **Example:**
    ```bash
    Source: Lambda function "process-order"
    ```
    Generates logs per invocation.
---
### ✅ 5. **Log Insights**
- **Definition:** A powerful query engine to analyze logs using SQL-like syntax.
- **Example Query:**
    ```sql
    fields @timestamp, @message
    | filter @message like /ERROR/
    | sort @timestamp desc
    | limit 5
    ```
    Filters and displays the last 5 error logs for faster debugging
---
### ✅ 6. **S3 Export**
- **Definition:** Export logs from CloudWatch to S3 for long-term storage or analysis.
- **Example:** Export logs from `/ecs/payment-service` to:
    ```bash
    s3://centralized-logs-bucket/ecs/payment-service/
    ```
    Can later be analyzed using **Athena** or **Glue**
---
### ✅ 7. **Log Subscriptions**
- **Definition:** Real-time forwarding of logs to other AWS services.
- **Targets:**
    - Lambda
    - Kinesis Data Stream
    - Kinesis Firehose
- **Example:** Set up a **subscription filter** to forward logs to a Lambda function:
    ```bash
    Filter Pattern: ?ERROR
    Target: Lambda "notifySlackOnError"
    ```
    Sends error logs as Slack alerts.
---
### ✅ 8. **Live Tail**
- **Definition:** View logs in real time, similar to `tail -f`.
- **Example:** During deployment of `user-service`, use **Live Tail** in the console to monitor:
    ```
    2025-04-11T10:35:14Z: [INFO] Deployment started
    2025-04-11T10:35:20Z: [INFO] Health check passed
    ```
---
### ✅ 9. **Log Aggregation (Multi-Account & Multi-Region)**
- **Definition:** Centralize logs from multiple AWS accounts and regions.
- **Use Case Setup:**
    - You have **dev**, **staging**, and **prod** accounts in `us-east-1` and `us-west-2`.
    - Logs are sent via **subscription filters** to a central **Kinesis Firehose** in a **logging account**.
    - Firehose delivers to:
        ```bash
        s3://central-log-archive/company-logs/
        ```
    - Use **Athena** or **OpenSearch** to analyze logs from all sources.
---

## 🔁 Full CloudWatch Logs Workflow with Console + CLI

---

### 1️⃣ Create a **Log Group**

🖥️ **Console**:

- Go to **CloudWatch > Logs > Log groups**
    
- Click **"Create log group"**
    
- Name it: `/custom-service-logs`
    

💻 **CLI**:

```bash
aws logs create-log-group --log-group-name /custom-service-logs
```

---

### 2️⃣ Create a **Log Stream**

🖥️ **Console**:

- Click your log group `/custom-service-logs`
    
- Click **"Create log stream"** → Name it `stream-01`
    

💻 **CLI**:

```bash
aws logs create-log-stream \
  --log-group-name /custom-service-logs \
  --log-stream-name stream-01
```

---

### 3️⃣ Put **Custom Log Events**

🖥️ **Console**:  
You can't directly push logs from the console; use SDKs/CLI or from an app.

💻 **CLI**:

```bash
aws logs put-log-events \
  --log-group-name /custom-service-logs \
  --log-stream-name stream-01 \
  --log-events timestamp=$(date +%s%3N),message="Service started successfully" \
  --sequence-token <nextSequenceToken>
```

👉 You need a `--sequence-token` from the previous response or:

```bash
aws logs describe-log-streams \
  --log-group-name /custom-service-logs \
  --log-stream-name-prefix stream-01 \
  --query 'logStreams[0].uploadSequenceToken'
```

---

### 4️⃣ View in **Logs Insights**

🖥️ **Console**:

- Go to **CloudWatch > Logs Insights**
    
- Choose `/custom-service-logs`
    
- Run this query:
    

```sql
fields @timestamp, @message
| sort @timestamp desc
| limit 10
```

💻 **CLI**:

```bash
aws logs start-query \
  --log-group-name /custom-service-logs \
  --start-time $(date -d '5 minutes ago' +%s) \
  --end-time $(date +%s) \
  --query-string "fields @timestamp, @message | sort @timestamp desc | limit 10"
```

---

### 5️⃣ View in **Live Tail**

🖥️ **Console**:

- Go to **CloudWatch > Log groups**
    
- Click `/custom-service-logs` → **Live Tail**
    

💻 **CLI**: Not supported. Use `tail` via SDKs or tools like `cw tail`.

---

## 🔁 Log Subscriptions

Used to **stream logs to Lambda, Kinesis, or Firehose (S3)**

---

### 6️⃣ Integration: **CloudWatch Logs → Lambda**

🖥️ **Console**:

- Go to `/custom-service-logs`
    
- Click **"Subscription filters" > "Create"**
    
- Choose destination: **Lambda function**
    
- Filter: `?ERROR` or `""` for all logs
    

💻 **CLI**:

```bash
aws logs put-subscription-filter \
  --log-group-name "/custom-service-logs" \
  --filter-name "LambdaSub" \
  --filter-pattern "?ERROR" \
  --destination-arn "arn:aws:lambda:us-east-1:123456789012:function:logErrorNotifier"
```

---

### 7️⃣ Integration: **CloudWatch Logs → Kinesis Stream**

🖥️ **Console**:

- Go to your log group → "Subscription filters" → Create
    
- Choose **Kinesis stream**
    
- Provide ARN and IAM role
    

💻 **CLI**:

```bash
aws logs put-subscription-filter \
  --log-group-name "/custom-service-logs" \
  --filter-name "KinesisSub" \
  --filter-pattern "" \
  --destination-arn "arn:aws:kinesis:us-east-1:123456789012:stream/LogStream" \
  --role-arn "arn:aws:iam::123456789012:role/CloudWatchToKinesisRole"
```

---

### 8️⃣ Integration: **CloudWatch Logs → S3 via Firehose**

🖥️ **Console**:

- Go to Firehose → Create delivery stream
    
- Destination: **S3**
    
- Go to log group `/custom-service-logs`
    
- Create Subscription Filter → Destination: Firehose
    

💻 **CLI**:

```bash
aws logs put-subscription-filter \
  --log-group-name "/custom-service-logs" \
  --filter-name "S3Sub" \
  --filter-pattern "" \
  --destination-arn "arn:aws:firehose:us-east-1:123456789012:deliverystream/LogToS3" \
  --role-arn "arn:aws:iam::123456789012:role/CloudWatchToFirehoseRole"
```

---

## 📦 Architecture Summary

```
  App or CLI → Log Group → Log Stream
                        ↓
               +--------+--------+
               |  Logs Insights |
               |   + Live Tail  |
               +--------+--------+
                        ↓
      +----------+----------+-----------+
      |          |          |           |
    Lambda     Kinesis   Firehose     (future)
   (AlertFn)   (Analytics)   → S3     (Athena/Glue)
```

---

