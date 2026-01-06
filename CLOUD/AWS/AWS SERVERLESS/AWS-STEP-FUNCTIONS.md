
## 🔄 What is AWS Step Functions?

**AWS Step Functions** is a **serverless orchestration service** that lets you **coordinate multiple AWS services** (like Lambda, ECS, SQS, Glue) into **stateful workflows** using a **JSON-based state machine**.

> ✅ It visually represents each step, manages retries, catches failures, and maintains flow state.

---

## 🎯 Why Use Step Functions?

|Benefit|Description|
|---|---|
|✅ Visual workflows|Easy to understand and debug with the visual editor|
|🔁 Retry logic|Built-in error handling and retry strategies|
|🔄 State management|Maintains task output and passes it between steps|
|👷 Serverless orchestration|No need to write glue logic in code|
|🔐 IAM-secured|Permissions scoped per task (Lambda, SQS, ECS, etc.)|

---

## 🧠 Common Use Cases

|Use Case|Description|
|---|---|
|🧾 Order Processing|Validate, charge, notify in sequence|
|🔄 ETL pipelines|Step-by-step data transformation (Glue, Lambda, Athena)|
|📦 Batch job control|Trigger and monitor ECS jobs or Batch tasks|
|✅ Approval workflows (manual + auto)|Wait for user input, branch based on approval|
|🔗 Chained Lambda execution|With branching, conditionals, error handling|

---

## 🔧 Types of Workflows

|Type|Description|Use Case|
|---|---|---|
|**Standard**|Durable, long-running (up to 1 year)|ETL, approval flows|
|**Express**|High-speed, short-lived (up to 5 minutes)|Real-time event processing|

---

## 🧱 Basic Architecture

```
Start → Lambda → Choice → Parallel → Wait → Succeed/Fail
```

---

## 📝 Sample State Machine (JSON)

```json
{
  "Comment": "Sample Order Workflow",
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:validateOrder",
      "Next": "ChargeCard"
    },
    "ChargeCard": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:chargeCard",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "NotifyFailure"
      }],
      "Next": "ShipOrder"
    },
    "ShipOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:shipOrder",
      "End": true
    },
    "NotifyFailure": {
      "Type": "Fail",
      "Cause": "Charge failed"
    }
  }
}
```

---

## 📦 Terraform Example (Standard Workflow + Lambda)

### 1. IAM Role for Step Function

```hcl
resource "aws_iam_role" "step_fn_role" {
  name = "step_fn_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.step_fn_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaRole"
}
```

### 2. State Machine Definition

```hcl
data "aws_lambda_function" "validate_order" {
  function_name = "validateOrder"
}

data "aws_lambda_function" "charge_card" {
  function_name = "chargeCard"
}

data "aws_lambda_function" "ship_order" {
  function_name = "shipOrder"
}

resource "aws_sfn_state_machine" "order_workflow" {
  name     = "order-processing"
  role_arn = aws_iam_role.step_fn_role.arn

  definition = jsonencode({
    StartAt = "ValidateOrder",
    States = {
      ValidateOrder = {
        Type     = "Task",
        Resource = data.aws_lambda_function.validate_order.arn,
        Next     = "ChargeCard"
      },
      ChargeCard = {
        Type     = "Task",
        Resource = data.aws_lambda_function.charge_card.arn,
        Next     = "ShipOrder"
      },
      ShipOrder = {
        Type     = "Task",
        Resource = data.aws_lambda_function.ship_order.arn,
        End      = true
      }
    }
  })
}
```

---

## 🔐 Security & Permissions

|Component|Required IAM Permissions|
|---|---|
|Step Function|`states:StartExecution`, `states:Describe*`|
|Lambda tasks|`lambda:InvokeFunction`|
|Other services|`dynamodb:*`, `sqs:*`, `ecs:*`, as needed|

---

## 📊 Monitoring

- **CloudWatch Logs**: Enable via workflow settings
    
- **CloudWatch Metrics**: Success, fail, duration, throttle, etc.
    
- **X-Ray Tracing**: Supported
    

---

## ⚙️ Advanced Features

|Feature|Description|
|---|---|
|🔄 Retry/Catch|Built-in error handling per state|
|⏱️ Wait|Add delays (seconds, timestamp, dynamic)|
|🧠 Choice|Conditional branching (like `if/else`)|
|⬛ Parallel|Run steps concurrently|
|📩 Map (for-each)|Loop over list of items|
|👤 Callback pattern|Wait for external system to send token (sync flow)|
|📥 Input/Output Path|Filter or transform data between steps|

---

## 💰 Pricing

|Workflow Type|Pricing Detail|
|---|---|
|**Standard**|$0.025 per 1,000 state transitions|
|**Express**|$1.00 per million executions + duration-based compute fees|

---

## ✅ TL;DR Summary

|Feature|AWS Step Functions|
|---|---|
|What is it?|Serverless workflow orchestrator|
|Types|Standard (durable) / Express (fast, high-volume)|
|Integrates with|Lambda, ECS, DynamoDB, Glue, SQS, SNS, etc.|
|Error handling|✅ Retry, Catch built-in|
|Visual flow editor|✅ Yes|
|Monitoring|CloudWatch, Logs, X-Ray|
|Terraform support|✅ Yes (`aws_sfn_state_machine`)|

---
