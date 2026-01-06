AWS **EventBridge** is a **serverless event bus** service that allows you to connect applications using **events**. It's basically a highly scalable and flexible way to route events between AWS services, custom applications, and even external SaaS services.

---

### 🔧 What is EventBridge used for?

- **Decoupling services** via event-driven architecture
    
- **Automating workflows** based on events (e.g., an S3 file upload triggers a Lambda)
    
- **Integrating SaaS apps** like Zendesk, Datadog, etc., with your AWS services
    
- **Creating custom application events** and routing them based on rules
    

---

### 🧠 Core Concepts

|Component|Description|
|---|---|
|**Event Bus**|A pipeline that receives and routes events. AWS has default buses, or you can create custom ones.|
|**Event**|A JSON object representing a change or action (e.g., EC2 state change).|
|**Rule**|Determines which events trigger which targets based on pattern matching.|
|**Target**|The service to invoke (e.g., Lambda, SQS, SNS, Step Functions).|
|**Schema Registry**|Helps discover, create, and manage event schemas. Useful for codegen.|

---

### 🚀 Example Use Case

You want to trigger a **Lambda** function whenever an EC2 instance is terminated:

1. **Source**: EC2 (AWS service event)
    
2. **Event Bus**: default
    
3. **Rule**: Match event where `detail.state` is `"terminated"`
    
4. **Target**: Your Lambda function
    

---

### 🔗 Integration Targets

- AWS Lambda
    
- SNS / SQS
    
- Step Functions
    
- ECS Tasks
    
- Kinesis streams
    
- CodeBuild
    
- And more...
    

---

### ✅ Features

- Schema discovery
    
- Event replay
    
- Event archiving
    
- Cross-account event routing
    
- SaaS integrations
    
- Reliable delivery with retries and DLQ (dead-letter queue)
    

---

Perfect! Here's a **hands-on demo workflow** using **AWS EventBridge + Lambda** — super useful if you're learning event-driven architectures.

---

## 🎯 **Goal**

Trigger a **Lambda function** whenever a file is uploaded to an **S3 bucket** using **EventBridge**.

---

## 🧱 **Architecture Diagram**

```
[S3 Upload] ---> [EventBridge Rule] ---> [Lambda Function]
```

---

## ⚙️ Step-by-Step Workflow

### ✅ Step 1: Create an S3 Bucket

```bash
aws s3 mb s3://my-eventbridge-demo-bucket
```

---

### ✅ Step 2: Create a Lambda Function

Example function code (`index.js`):

```javascript
exports.handler = async (event) => {
  console.log("Event received:", JSON.stringify(event, null, 2));
  return {
    statusCode: 200,
    body: "File upload detected!",
  };
};
```

**Create the Lambda:**

```bash
zip function.zip index.js

aws lambda create-function \
  --function-name S3UploadHandler \
  --runtime nodejs18.x \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::123456789012:role/lambda-exec-role
```

> Ensure the IAM role has `AWSLambdaBasicExecutionRole` and permissions for EventBridge

---

### ✅ Step 3: Create an EventBridge Rule

This rule triggers on **S3 object upload** events:

```bash
aws events put-rule \
  --name S3UploadRule \
  --event-pattern '{
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "resources": ["arn:aws:s3:::my-eventbridge-demo-bucket"]
  }'
```

---

### ✅ Step 4: Add Lambda as a Target

```bash
aws events put-targets \
  --rule S3UploadRule \
  --targets '[
    {
      "Id": "TargetLambda",
      "Arn": "arn:aws:lambda:us-east-1:123456789012:function:S3UploadHandler"
    }
  ]'
```

---

### ✅ Step 5: Grant EventBridge permission to invoke Lambda

```bash
aws lambda add-permission \
  --function-name S3UploadHandler \
  --statement-id S3EventBridgeInvoke \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:us-east-1:123456789012:rule/S3UploadRule
```

---

### ✅ Step 6: Test It!

Upload a file to your bucket:

```bash
aws s3 cp myfile.txt s3://my-eventbridge-demo-bucket/
```

Check CloudWatch Logs for your Lambda to confirm it ran!

---

## 🧠 Extra Tips

- Use **Dead Letter Queues (DLQ)** for handling failed invocations
    
- Use **Event Replay** if needed (requires enabling event archiving)
    
- You can also use **custom events** with your own app or microservices
    

---
