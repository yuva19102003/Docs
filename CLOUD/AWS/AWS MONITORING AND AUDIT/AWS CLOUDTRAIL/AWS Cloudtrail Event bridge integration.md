Integrating **AWS CloudTrail** with **Amazon EventBridge** allows you to respond automatically to specific events that occur in your AWS account. This is useful for auditing, automation, security, or operational monitoring.

---

### ✅ Use Case Example

**Automatically respond to IAM user creation** — When a new IAM user is created, send a notification (e.g., via SNS or Lambda).

---

## 🛠️ Step-by-Step: CloudTrail + EventBridge Integration

---

### 1. **Enable CloudTrail (if not already)**

CloudTrail logs all API calls made in your account.

- Go to **CloudTrail > Trails**
    
- Create a new trail or use the default one.
    
- Enable logging to an S3 bucket.
    

---

### 2. **Go to EventBridge > Create Rule**

---

### 3. **Configure the Rule**

- **Name**: `iam-user-create-event`
    
- **Event Source**: `AWS services`
    
- **AWS Service**: `CloudTrail`
    
- **Event Type**: `AWS API Call via CloudTrail`
    

---

### 4. **Define Event Pattern**

Use this pattern to capture IAM user creation:

```json
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": ["CreateUser"]
  }
}
```

---

### 5. **Set Target**

Choose what should happen when the event is matched.

#### Example 1: **SNS Topic**

- Send a notification when a new user is created.
    

#### Example 2: **Lambda Function**

- Run automation (e.g., attach policies, tag users).
    

---

### 6. **IAM Permissions**

Make sure the **EventBridge rule** has permission to invoke the target service (SNS, Lambda, etc.)

For Lambda, the trust policy must allow EventBridge:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "events.amazonaws.com"
  },
  "Action": "lambda:InvokeFunction"
}
```

---

### 🧪 Example: Lambda Function Code (Python)

```python
def lambda_handler(event, context):
    username = event['detail']['requestParameters']['userName']
    print(f"New IAM user created: {username}")
```

---

### 🔍 Test It

1. Manually create a new IAM user.
    
2. CloudTrail will log it.
    
3. EventBridge matches the pattern.
    
4. Your target (SNS/Lambda/etc.) is triggered.
    

---
