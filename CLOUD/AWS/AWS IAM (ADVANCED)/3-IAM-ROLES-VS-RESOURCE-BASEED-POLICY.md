
## 🆚 IAM Roles vs Resource-Based Policies

|Feature|**IAM Role**|**Resource-Based Policy**|
|---|---|---|
|🔐 **Who defines it**|Defined on the **principal** (user/service/role)|Defined on the **resource**|
|📦 **Attached to**|An IAM **role** or **user**|A resource (like S3 bucket, Lambda, SNS, etc.)|
|🧭 **Direction of trust**|The **role trusts the principal** (via assume role)|The **resource trusts the principal**|
|🌍 **Cross-account access**|Requires explicit trust policy + permissions|Directly supports cross-account access|
|✅ **Used when**|A principal needs to temporarily assume a role to get permissions|You want to allow specific accounts/users to access a resource|
|🔁 **Example usage**|EC2 assuming a role to access DynamoDB|Allow an S3 bucket to be read by another AWS account|
|🔄 **Principal**|Principal **assumes** the role|Principal is specified in the `Principal` field|

---

### 🛠️ Example: IAM Role (Assume Role)

```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::123456789012:role/MyCrossAccountRole"
}
```

🔹 Use case: EC2 or Lambda assumes this role to get temporary credentials.

---

### 📁 Example: Resource-Based Policy (S3)

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::123456789012:root"
  },
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```

🔹 Use case: Allow a specific AWS account to read from your bucket directly.

---

## 🎯 When to Use What?

|Need|Use|
|---|---|
|Cross-account access to S3, Lambda, etc.|✅ Resource-based policy|
|AWS service like EC2/Lambda to access other services|✅ IAM Role|
|Fine-grained control with temporary credentials|✅ IAM Role|
|Granting access **to** your resource (e.g. S3)|✅ Resource-based policy|
|Delegating access **from** a trusted user or service|✅ IAM Role|

---
