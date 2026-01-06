
## 📣 What are S3 Event Notifications?

**S3 Event Notifications** allow you to **trigger AWS services** (like Lambda, SNS, or SQS) when specific events occur in your S3 bucket — for example:

|Example|Trigger|
|---|---|
|Image uploaded|Trigger a Lambda to resize|
|Object deleted|Log to SQS for audit|
|File created in a prefix|Notify a pipeline via SNS|

---

## 🔔 Supported Events

|Event Name|Triggered When…|
|---|---|
|`s3:ObjectCreated:*`|Any object creation (PUT, POST, COPY, etc.)|
|`s3:ObjectCreated:Put`|Object uploaded via PUT|
|`s3:ObjectCreated:Post`|Uploaded via HTML form|
|`s3:ObjectCreated:CompleteMultipartUpload`|Multipart upload completed|
|`s3:ObjectRemoved:*`|Object deleted (DELETE or version marker)|
|`s3:ObjectRestore:Completed`|Object restore from Glacier completed|
|`s3:Replication:OperationCompletedReplication`|Replication success|
|`s3:LifecycleExpiration:*`|Object expired due to lifecycle policy|

---

## 🎯 Use Cases

|Use Case|Triggered Action|
|---|---|
|Image processing|Trigger Lambda to resize|
|Document ingestion|Push event to SQS → EC2 batch process|
|Real-time data pipeline|Notify SNS → Kinesis / analytics service|
|Logging deletions|Send deleted object info to audit queue|
|Webhooks / notification bridge|Notify external systems via Lambda|

---

## 📦 Destinations You Can Use

|Destination|Description|
|---|---|
|**Lambda**|Run code in response to event|
|**SQS**|Store event in queue|
|**SNS**|Publish event to subscribers|

---

## 🔧 How to Set Up (Console)

1. Go to your bucket → **Properties** tab
    
2. Scroll to **Event notifications**
    
3. Click **Create event notification**
    
4. Select:
    
    - **Event types** (PUT, DELETE, etc.)
        
    - **Prefix/suffix filters** (optional)
        
    - **Destination** (Lambda, SNS, SQS)
        

---

## 🧠 Key Points to Remember

|Feature|Details|
|---|---|
|Region-specific|Destination must be in the **same region**|
|One destination per rule|You can have multiple rules, each with one destination|
|Permissions required|Bucket must allow S3 to invoke destination|
|Filtering supported|By object **prefix** and/or **suffix**|

---

## 🛠️ Terraform Example: S3 → Lambda

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = "yuva-event-demo"
}

resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda.zip"
  function_name    = "s3_event_handler"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
```

---

## 🛠️ Terraform Example: S3 → SQS

```hcl
resource "aws_sqs_queue" "event_queue" {
  name = "s3-events-queue"
}

resource "aws_s3_bucket_notification" "sqs_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.event_queue.arn
    events        = ["s3:ObjectRemoved:*"]
    filter_prefix = "logs/"
  }
}
```

> Make sure SQS policy allows S3 to send messages.

---

## 📋 Limitations

|Limitation|Details|
|---|---|
|Only one configuration block|Use multiple destinations inside it|
|Event delivery is **best effort**|Not guaranteed — use retries or DLQs|
|Destination must be same region|No cross-region triggers|
|No multiple destinations per rule|One Lambda/SNS/SQS per rule|

---

## 🔎 Testing

Use `aws s3 cp` to upload a test file and confirm:

```bash
aws s3 cp image.jpg s3://yuva-event-demo/uploads/
```

Check your **Lambda logs (CloudWatch)** or **SQS queue** for received event.

---

## ✅ TL;DR Summary

|Feature|Value|
|---|---|
|Event Types|PUT, DELETE, RESTORE, etc.|
|Destinations|Lambda, SQS, SNS|
|Filtering|By prefix/suffix|
|Invocation Region|Destination must be in the same region|
|Use Cases|Processing, audit, notifications|
|Retry mechanism|Built-in for Lambda; SQS handles retries|

---
