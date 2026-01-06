
## 🌐 What is Amazon API Gateway?

**AWS API Gateway** is a fully managed service that helps you **create, publish, manage, monitor, and secure REST, HTTP, and WebSocket APIs** at any scale.

> It acts as a **front door** to your applications running on **Lambda, EC2, ECS, or any HTTP backend**.

---

## 🔧 API Types

|Type|Description|Use Case Example|
|---|---|---|
|REST API|Full-featured API with stages, caching, etc.|Serverless apps, legacy systems|
|HTTP API|Lightweight, cheaper, faster|Simple proxy to Lambda or ALB|
|WebSocket API|Bi-directional communication|Real-time chat, IoT messaging|

---

## ✅ Use Cases

|Scenario|Why Use API Gateway|
|---|---|
|🚀 Lambda function as backend|Serverless HTTP interface|
|🌐 Frontend + Backend separation|Decoupled SPA/backend|
|🔐 Secure internal APIs|IAM, JWT auth, WAF, throttling|
|📊 API metering or rate-limiting|Protect downstream services|
|🔁 Transform requests/responses|Mapping templates or Lambda integration|
|🔔 Event-driven apps|Webhooks from clients to Lambda|

---

## 🧱 API Gateway + Lambda Architecture

```
User ➝ API Gateway ➝ Lambda ➝ DynamoDB / S3 / RDS
```

---

## 🔗 Integration Options

|Backend Type|Integration Type|Description|
|---|---|---|
|Lambda|Lambda integration|Run code on demand|
|HTTP endpoint|HTTP proxy|Forward request to an HTTP server|
|AWS service|AWS integration|Call DynamoDB, SQS, etc., directly|
|VPC service|Private integration|Use via VPC Link|

---

## 🛠️ Terraform – HTTP API + Lambda Example

### 1. Lambda Function

```hcl
resource "aws_lambda_function" "api_fn" {
  function_name = "hello-api"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda.zip"
}
```

### 2. Create HTTP API Gateway

```hcl
resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api-demo"
  protocol_type = "HTTP"
}
```

### 3. Lambda Integration

```hcl
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_fn.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}
```

### 4. Route and Stage

```hcl
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
```

---

## 🔐 Security Options

|Option|REST API|HTTP API|Description|
|---|---|---|---|
|IAM auth|✅|✅|Use IAM roles to access endpoints|
|Lambda authorizer|✅|✅|Custom logic to allow/deny access|
|Cognito user pools|✅|✅|Use Cognito JWT for auth|
|API key + usage plan|✅|❌|Track and throttle API calls|

---

## 📊 Monitoring & Logging

- Integrated with **CloudWatch Logs** and **Metrics**
    
- Can enable **access logging**
    
- Supports **X-Ray tracing** (for REST and HTTP APIs)
    

---

## 📈 Pricing (HTTP API)

|Metric|Cost Estimate|
|---|---|
|Requests (first 300M/mo)|$1.00 per million|
|Data transfer|Same as usual AWS data transfer costs|

> REST APIs are ~3x more expensive than HTTP APIs. Choose HTTP APIs for simple Lambda proxy setups.

---

## 🔧 Advanced Features

|Feature|Description|
|---|---|
|CORS|Cross-origin support|
|Throttling & quotas|Protect backend from abuse|
|Stage variables|Use config per environment (e.g., dev/prod)|
|Custom domain names|Route your APIs under your domain|
|JWT Validation|Native OIDC support (Cognito, Auth0, etc.)|

---

## 🌍 API Gateway + Custom Domain + SSL (Optional)

```hcl
resource "aws_apigatewayv2_domain_name" "custom" {
  domain_name = "api.yuva.dev"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_map" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.custom.id
  stage       = aws_apigatewayv2_stage.default.name
}
```

---

## ✅ TL;DR Summary

|Feature|API Gateway|
|---|---|
|Supports|REST, HTTP, WebSocket|
|Best for|Serverless APIs, event-based triggers|
|Backend Integration|Lambda, HTTP, AWS services|
|Auth Options|IAM, Cognito, JWT, Lambda authorizer|
|Rate limiting|✅ REST APIs only|
|Logging|✅ CloudWatch + X-Ray|
|Terraform Support|✅ (`aws_apigatewayv2_*` for HTTP APIs)|

---
