
## Table of Contents

1. Overview
    
2. Key Features
    
3. Prerequisites
    
4. Creating and Storing Secrets
    
5. Retrieving Secrets
    
6. Automatic Rotation of Secrets
    
7. Managing Access with IAM
    
8. Using Secrets Manager in Applications
    
9. Auditing and Monitoring
    
10. Best Practices
    
11. Summary
    

---

## 1. Overview

**AWS Secrets Manager** helps you **securely store, manage, and retrieve sensitive information** such as database passwords, API keys, and tokens. It enables **automatic rotation** of credentials without requiring manual intervention or downtime, integrated with many AWS services like RDS, Redshift, and more.

---

## 2. Key Features

- Secure, encrypted storage of secrets
    
- Automatic rotation with built-in or custom Lambda functions
    
- Fine-grained access control with AWS IAM
    
- Seamless integration with AWS SDKs and services
    
- Audit logging via AWS CloudTrail
    
- Cross-account secret sharing
    

---

## 3. Prerequisites

- AWS Account
    
- IAM permissions for Secrets Manager (`secretsmanager:*`)
    
- AWS CLI or AWS Console access
    
- AWS SDK installed for your application language (optional)
    

---

## 4. Creating and Storing Secrets

### Using AWS Console

1. Go to AWS Secrets Manager Console.
    
2. Click **Store a new secret**.
    
3. Select secret type:
    
    - Credentials for RDS database
        
    - Other type of secrets (key/value pairs, plaintext)
        
4. Enter secret key-value pairs (e.g., username/password).
    
5. Name the secret (e.g., `MyApp/DBCredentials`).
    
6. Optionally configure automatic rotation (covered later).
    
7. Review and store.
    

### Using AWS CLI

```bash
aws secretsmanager create-secret --name MyApp/DBCredentials \
--secret-string '{"username":"admin","password":"P@ssw0rd123"}'
```

---

## 5. Retrieving Secrets

### Using AWS Console

- Open your secret → Click **Retrieve secret value**.
    

### Using AWS CLI

```bash
aws secretsmanager get-secret-value --secret-id MyApp/DBCredentials
```

### Using AWS SDK (Python Example)

```python
import boto3
import json

client = boto3.client('secretsmanager')

response = client.get_secret_value(SecretId='MyApp/DBCredentials')
secret = json.loads(response['SecretString'])

print(f"Username: {secret['username']}")
print(f"Password: {secret['password']}")
```

---

## 6. Automatic Rotation of Secrets

Secrets Manager supports automatic rotation to update secrets periodically without downtime.

### Step 1: Create a Lambda rotation function

- AWS provides templates for rotation functions (e.g., RDS credentials).
    
- Customize as needed.
    

### Step 2: Enable rotation on secret

- Go to your secret → Enable rotation.
    
- Select the Lambda function and rotation interval (e.g., every 30 days).
    

---

## 7. Managing Access with IAM

- Use IAM policies to control who/what can create, retrieve, or rotate secrets.
    
- Example policy to allow reading a specific secret:
    

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["secretsmanager:GetSecretValue"],
    "Resource": "arn:aws:secretsmanager:region:account-id:secret:MyApp/DBCredentials-*"
  }]
}
```

---

## 8. Using Secrets Manager in Applications

- Integrate Secrets Manager SDK calls to retrieve secrets at runtime.
    
- Cache secrets securely in memory to avoid repeated API calls.
    
- Use environment variables or configuration management to inject secret IDs.
    

---

## 9. Auditing and Monitoring

- Use **AWS CloudTrail** to log API calls made to Secrets Manager.
    
- Set up **CloudWatch alarms** for suspicious activity or access.
    
- Enable AWS Config rules for compliance checks.
    

---

## 10. Best Practices

- Enable **automatic rotation** to reduce risks from leaked credentials.
    
- Restrict IAM permissions using the **principle of least privilege**.
    
- Monitor secret usage and access patterns regularly.
    
- Use **encryption keys** managed by AWS KMS.
    
- Avoid hardcoding secrets; always fetch at runtime.
    

---

## 11. Summary Table

|Feature|Description|Use Case|
|---|---|---|
|Secret Storage|Secure encrypted storage|Store DB credentials, API keys|
|Automatic Rotation|Rotate credentials automatically|Reduce manual overhead and risk|
|Fine-grained IAM|Control access via IAM policies|Secure secrets from unauthorized access|
|SDK & CLI Access|Retrieve secrets programmatically|Dynamic secret retrieval in apps|
|Audit & Monitoring|Track and alert on secret access|Compliance and security auditing|

---
