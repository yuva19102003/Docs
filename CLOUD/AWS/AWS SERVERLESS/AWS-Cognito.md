
## 🔐 What is Amazon Cognito?

**Amazon Cognito** is a **serverless user authentication and access control service** that lets you easily add **sign-up, sign-in, and access control to your applications**.

> ✅ Use it to authenticate users (email/password, social, SSO) and authorize them to access AWS resources securely.

---

## 🔧 Key Components

|Component|Description|
|---|---|
|**User Pools**|Manage **user identities**: sign-up, sign-in, tokens (JWT)|
|**Identity Pools**|Manage **temporary AWS credentials** to access services like S3, DynamoDB|
|**Cognito Hosted UI**|Pre-built, customizable sign-in UI with OAuth2 support|
|**Federation**|Sign-in via Google, Facebook, SAML, Apple, or corporate IdP|

---

## 🧠 Cognito User Pool vs Identity Pool

|Feature|**User Pool**|**Identity Pool**|
|---|---|---|
|Purpose|Authenticate users|Authorize access to AWS resources|
|Token type|JWT (ID, Access, Refresh)|AWS temporary credentials (via STS)|
|Supports social login|✅|✅ (via user pool federation)|
|Can access AWS API|❌ (requires identity pool)|✅|

---

## 📘 Cognito Authentication Flow

1. **User logs in** (via Hosted UI or SDK)
    
2. **User Pool** validates credentials and returns **ID and Access Tokens (JWT)**
    
3. **Identity Pool** exchanges ID token for **temporary AWS credentials** via STS
    
4. App uses those credentials to call AWS services (like S3, DynamoDB)
    

---

## 🛠️ Terraform Example – User Pool + Identity Pool

### 1. Create User Pool

```hcl
resource "aws_cognito_user_pool" "main" {
  name = "demo-user-pool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}
```

---

### 2. Create User Pool Client (for app to connect)

```hcl
resource "aws_cognito_user_pool_client" "client" {
  name         = "demo-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  supported_identity_providers = ["COGNITO"]

  callback_urls = ["https://yourapp.com/callback"]
}
```

---

### 3. Create Identity Pool

```hcl
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "demo-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = true
  }
}
```

---

### 4. IAM Roles for Authenticated Users

```hcl
resource "aws_iam_role" "authenticated" {
  name = "CognitoAuthenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
        },
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "auth_attach" {
  role       = aws_iam_role.authenticated.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

---

## 🧪 Supported Identity Providers

|Provider Type|Example|
|---|---|
|Email/Password|Built-in Cognito user pool|
|Social Login|Google, Facebook, Apple|
|SAML Federation|ADFS, Okta, Ping, etc.|
|OpenID Connect|Auth0, GitHub, Google, etc.|

---

## 🌐 Hosted UI

Cognito provides a **pre-built login UI** with:

- Sign-up, Sign-in
    
- Forgot password
    
- OAuth2 flows
    

> You can customize logo, color, and callback URLs.

---

## 📊 Token Types from User Pool

|Token|Purpose|TTL (default)|
|---|---|---|
|ID Token|User attributes (sub, email)|1 hour|
|Access Token|Used to authorize API requests|1 hour|
|Refresh Token|Used to get new ID/Access|30 days|

---

## 📈 Monitoring

- **CloudWatch Logs**: Auth events, failed logins
    
- **CloudTrail**: Management API activity
    
- **CloudWatch Metrics**: Sign-in attempts, success, failures
    

---

## 💸 Pricing (as of 2024)

|Service|Price|
|---|---|
|Monthly active users|Free for 50,000 MAUs, then ~$0.0055/user|
|Identity pool STS calls|Priced per STS usage|

---

## ✅ Real-World Scenarios

|Scenario|Cognito Fit?|
|---|---|
|Web app sign-in with JWT|✅ Use user pool + client|
|AWS service access per user|✅ Use identity pool + IAM|
|MFA/OTP|✅ Built-in support|
|Social login|✅ Google, Facebook, Apple, etc.|
|Custom auth backend|✅ Use Lambda triggers (PreSignUp, PostAuth)|

---

## 🔐 Advanced Features

|Feature|Description|
|---|---|
|🔒 MFA|SMS or TOTP-based multi-factor auth|
|🔁 Triggers|Use Lambda for custom auth flows or verification|
|📦 User attributes|Custom attributes supported|
|⏳ Token expiration|Customizable for access/refresh tokens|
|🚀 Federated Auth|Link third-party IdPs (Google, SAML, OIDC)|
|🌐 Custom Domains|Use your own domain for the Hosted UI login page|

---

## ✅ TL;DR Summary

|Feature|Amazon Cognito|
|---|---|
|Authentication|✅ Built-in + social login|
|Authorization|✅ AWS credentials via identity pool|
|Protocols|OAuth2, SAML, OpenID Connect|
|SDK Support|✅ Web, Android, iOS, Amplify, Boto3|
|Terraform Support|✅ (`aws_cognito_*`)|

---
