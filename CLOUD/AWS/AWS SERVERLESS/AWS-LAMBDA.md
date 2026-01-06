
## ⚙️ What is AWS Lambda?

**AWS Lambda** is a **serverless compute service** that lets you run code **without provisioning or managing servers**. You only pay when your code runs.

> Lambda scales automatically and runs your function **in response to events** like API calls, file uploads, or database changes.

---

## 🔧 Key Concepts

|Concept|Description|
|---|---|
|**Function**|Your code + configuration (runtime, memory, timeout, etc.)|
|**Trigger**|Event source that invokes the function (e.g., S3, API Gateway, DynamoDB)|
|**Runtime**|Programming language supported (Node.js, Python, Go, Java, .NET, etc.)|
|**Execution Role**|IAM role that grants your function permission to use other AWS services|
|**Handler**|Entry point of your function (e.g., `index.handler`)|

---

## 🚀 Common Use Cases

|Category|Example|
|---|---|
|🧩 Microservices|Run REST API endpoints via API Gateway|
|📁 File Processing|Process S3 uploads (e.g., resize images, extract metadata)|
|🔄 Automation|Periodic tasks via EventBridge (e.g., clean up, reports)|
|🔗 Event-driven apps|React to DynamoDB, Kinesis, SNS, or SQS changes|
|🔒 Security|Real-time security checks, IAM automation|

---

## 🛠️ Supported Runtimes

- Python (`python3.11`, `3.9`, `3.8`)
    
- Node.js (`nodejs20.x`, `18.x`, `16.x`)
    
- Go (`provided.al2023`)
    
- Java, .NET, Ruby, and custom runtimes via container images
    

---

## 🧪 Event Sources (Triggers)

|Source|Event|
|---|---|
|S3|`PUT`, `POST`, `DELETE` objects|
|API Gateway|HTTP/REST requests|
|DynamoDB|Insert/modify/delete items|
|EventBridge|Scheduled (cron) or event bus|
|SQS|Messages in queue|
|CloudWatch|Logs, metrics, alarms|
|Cognito|User pool auth triggers|

---

## 🧱 Lambda Function Structure (Python)

```python
# index.py
def handler(event, context):
    print("Received event:", event)
    return {
        "statusCode": 200,
        "body": "Hello from Lambda!"
    }
```

> Handler format: `file_name.function_name` (e.g., `index.handler`)

---

## 📦 Terraform Example – Deploy Basic Lambda Function

```hcl
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "yuva-lambda-demo"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"  # Zip file containing index.py

  source_code_hash = filebase64sha256("lambda.zip")
}
```

> 📁 Create `lambda.zip`:

```bash
zip lambda.zip index.py
```

---
![Lambda Diagram](Screenshot%202025-07-03%20200310.png)

---
## 🧑‍💼 Lambda IAM Permissions

Attach policies to allow Lambda to access:

|AWS Service|Required IAM Actions|
|---|---|
|S3|`s3:GetObject`, `s3:PutObject`|
|DynamoDB|`dynamodb:GetItem`, `dynamodb:PutItem`|
|SNS/SQS|`sns:Publish`, `sqs:SendMessage`|
|CloudWatch|`logs:*`|

---

## 📊 Monitoring & Logs

- **Amazon CloudWatch** is used to:
    
    - View Lambda **logs**
        
    - Set **alarms** based on errors, duration, invocations
        
- Use **AWS X-Ray** for tracing
    

---

## 📈 Pricing

|Metric|Value|
|---|---|
|Free Tier|1 million requests/month, 400,000 GB-seconds|
|Invocations|$0.20 per 1 million requests|
|Duration (GB-sec)|$0.00001667 per GB-second|

> Example: 128 MB Lambda running for 1 sec = **0.0000021 USD**

---

## 🔐 Security Tips

- ✅ Use **least privilege** IAM role
    
- ✅ Enable **VPC** if accessing RDS or private resources
    
- ✅ Set a **timeout** (default: 3s, max: 15 min)
    
- ✅ Use **environment variable encryption** (KMS)
    
- ✅ Use **layers** to share code (e.g., boto3, numpy)
    

---

## 🧰 Advanced Features

|Feature|Description|
|---|---|
|**Lambda Layers**|Share libraries (e.g., `requests`, `pandas`) across functions|
|**Concurrency**|Set max parallel executions (throttle)|
|**Versions/Aliases**|Use for deployments, staging, traffic shifting|
|**Function URLs**|Built-in HTTPS endpoint (no API Gateway)|
|**Container Image**|Package large apps as Docker images (max 10 GB)|

---

## ✅ TL;DR Summary

|Feature|AWS Lambda|
|---|---|
|What is it?|Serverless compute for event-driven workloads|
|Languages|Python, Node.js, Go, Java, etc.|
|Trigger Sources|S3, API Gateway, EventBridge, DynamoDB, etc.|
|Max Timeout|15 minutes|
|Max Memory|10 GB|
|Package Types|ZIP (50MB) or Docker (10 GB)|
|Terraform Support|✅ Yes (`aws_lambda_function`)|

---
