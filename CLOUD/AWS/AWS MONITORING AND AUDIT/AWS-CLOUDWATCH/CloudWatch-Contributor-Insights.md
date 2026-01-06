 **CloudWatch Contributor Insights** — one of the lesser-known but **super powerful** features for analyzing **high-cardinality log data** like:

- Most active users
    
- Most error-generating IPs
    
- Most requested APIs
    
- Most frequent Lambda or ECS services
    

---

## 🔍 What is CloudWatch Contributor Insights?

**Contributor Insights** analyzes structured log fields to show **top-N contributors** (e.g., top users, IPs, endpoints) for events like errors, throttles, or usage spikes.

It’s like **"GROUP BY + COUNT + TOP N"** for your log data—visualized!

---

## 📘 Example Use Case

### 🎯 Goal:

Find **top 5 IP addresses** hitting your API Gateway and causing `5xx` errors.

---

## 🧰 Step-by-Step Example

### ✅ Step 1: Log Group Setup

Make sure your API Gateway or Lambda is logging to CloudWatch Logs, e.g.:

```bash
/aws/apigateway/my-api-access-logs
```

> Sample log event (JSON):

```json
{
  "requestId": "xyz",
  "ip": "203.0.113.1",
  "status": "500",
  "path": "/api/orders"
}
```

---

### ✅ Step 2: Create Contributor Insights Rule (Console or CLI)

You can define a rule to analyze those logs.

#### 📋 Sample Rule: Show Top IPs Causing 5xx Errors

```json
{
  "Schema": {
    "Name": "CloudWatchLogRule",
    "Version": 1
  },
  "LogGroupNames": ["/aws/apigateway/my-api-access-logs"],
  "Filter": "status >= 500",
  "Contribution": {
    "Keys": ["ip"],
    "ValueOf": "1",
    "Filters": []
  },
  "AggregateOn": "Sum"
}
```

---

### ✅ Step 3: Create Rule via AWS CLI

Save the rule as `top-error-ips.json` and run:

```bash
aws cloudwatch put-insight-rule \
  --rule-name "TopErrorIPs" \
  --rule-definition file://top-error-ips.json \
  --log-group-names "/aws/apigateway/my-api-access-logs"
```

Then enable it:

```bash
aws cloudwatch enable-insight-rules --rule-names "TopErrorIPs"
```

---

### ✅ Step 4: View Results in Console

Go to:

**CloudWatch → Contributor Insights → "TopErrorIPs"**

You’ll see:

|IP Address|Count|
|---|---|
|203.0.113.1|57|
|198.51.100.99|41|
|192.0.2.10|36|

This tells you **which clients** are generating the most 5xx errors.

---

## 🧠 Other Use Cases

|Use Case|Key(s) to Group By|
|---|---|
|Top throttled Lambda functions|`function_name`|
|Top ECS tasks with CPU spikes|`task_id`|
|Top API Gateway users|`user_agent`, `path`|
|Top DynamoDB partitions|`partition_key`|

---

## 📍 Summary

|Feature|Description|
|---|---|
|Real-time analysis|Yes|
|Top-N contributors|Yes (IPs, users, endpoints, etc.)|
|Visualization|Yes (charts in CloudWatch UI)|
|Works on structured logs|Yes (JSON or pattern-matched)|
|Export to dashboards|Yes|

---
