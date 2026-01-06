
## 🔐 IAM Conditions Explained

### 1. `aws:SourceIp`

Restricts access based on the **IP address** of the request.

🔹 **Use case**: Allow access **only from specific IPs** (e.g., your corporate network).

✅ **Example**:

```json
"Condition": {
  "IpAddress": {
    "aws:SourceIp": "203.0.113.0/24"
  }
}
```

---

### 2. `aws:RequestedRegion`

Restricts actions based on the **AWS region** in which the request is made.

🔹 **Use case**: Prevent launching resources **outside approved regions**.

✅ **Example**:

```json
"Condition": {
  "StringEquals": {
    "aws:RequestedRegion": "us-east-1"
  }
}
```

---

### 3. `ec2:ResourceTag/<TagKey>`

Controls access based on **tags attached to the EC2 resource**.

🔹 **Use case**: Allow actions only on instances tagged a certain way.

✅ **Example**: Allow stopping only EC2s tagged with `Environment=Dev`:

```json
"Condition": {
  "StringEquals": {
    "ec2:ResourceTag/Environment": "Dev"
  }
}
```

---

### 4. `aws:MultiFactorAuthPresent`

Checks if the user **used MFA** during authentication.

🔹 **Use case**: Enforce MFA for sensitive actions (like deleting resources).

✅ **Example**:

```json
"Condition": {
  "Bool": {
    "aws:MultiFactorAuthPresent": "true"
  }
}
```

---

### BONUS: Combine Multiple Conditions

You can use multiple in a single policy:

```json
"Condition": {
  "StringEquals": {
    "aws:RequestedRegion": "us-east-1",
    "ec2:ResourceTag/Environment": "Dev"
  },
  "Bool": {
    "aws:MultiFactorAuthPresent": "true"
  },
  "IpAddress": {
    "aws:SourceIp": "203.0.113.0/24"
  }
}
```

---

##  **IAM policies for S3** 

- 🔹 **Bucket-level permissions** (like listing or deleting buckets)
    
- 🔸 **Object-level permissions** (like uploading or reading specific objects)
    

---

## 🔐 Full IAM Policy: S3 (Bucket + Object Level)

### 🎯 **Scenario:**

Allow a user to:

- **List the contents** of a specific bucket
    
- **Upload** and **download** objects within a specific folder (prefix) in that bucket
    
- **Deny deletion** of any object in the bucket
    

---

### ✅ Full Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-bucket-name"
    },
    {
      "Sid": "AllowPutGetInFolder",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket-name/folder1/*"
    },
    {
      "Sid": "DenyDeleteObject",
      "Effect": "Deny",
      "Action": "s3:DeleteObject",
      "Resource": "arn:aws:s3:::my-bucket-name/*"
    }
  ]
}
```

---

### 📘 Explanation

|Statement|Description|
|---|---|
|`s3:ListBucket`|Allows listing objects in the bucket (but not the contents of folders unless explicitly allowed).|
|`s3:GetObject`, `s3:PutObject`|Allows read and write within `folder1/` only.|
|`s3:DeleteObject`|Explicitly denies deletion of any object (bucket-wide).|

---

### 🧠 Object vs Bucket-Level in S3

|Level|Action Example|Resource Format|
|---|---|---|
|Bucket-level|`s3:ListBucket`, `s3:GetBucketLocation`|`arn:aws:s3:::bucket-name`|
|Object-level|`s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`|`arn:aws:s3:::bucket-name/key-name`|

---
## 🔐 What is `aws:PrincipalOrgID`?

- `aws:PrincipalOrgID` is a **global condition key**.
    
- It allows access **only to identities from a specific AWS Organization**.
    
- This is especially useful when you're sharing resources across accounts **within your org** but want to block **external accounts**.
    

---

## 📁 Use Case Example

🔸 You want to **allow only users or roles from your organization** to access an S3 bucket.

---

## ✅ Resource-Based Policy Example (S3 Bucket)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowOrgOnlyAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-secure-org-bucket",
        "arn:aws:s3:::my-secure-org-bucket/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:PrincipalOrgID": "o-xxxxxxxxxx"
        }
      }
    }
  ]
}
```

---

### 🧠 Key Points:

- `Principal: "*"` + condition = allows access **only if condition matches**.
    
- Replace `o-xxxxxxxxxx` with your actual **Organization ID**.
    
    > You can find it in the AWS Console → **Organizations → Settings**.
    
- This policy is applied **on the S3 bucket itself** (i.e., a resource policy, not an IAM user policy).
    

---

## 🚫 What It Blocks

- **Any IAM user/role from outside your AWS Organization**.
    
- Even if they have IAM permissions, they'll be denied at the **resource level**.
    

---

### 🔒 Bonus Tip: Secure Cross-Account Access with OrgID

You can also combine this with **`aws:PrincipalAccount`** or **specific IAM roles** if you want **finer control**.

---
