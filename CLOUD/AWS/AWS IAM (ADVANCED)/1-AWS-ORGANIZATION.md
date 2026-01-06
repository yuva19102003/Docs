
## 🏢 AWS Organizations

**Goal:** Learn how to create an AWS Organization, add accounts, apply Service Control Policies (SCPs), and centralize billing.
### 🧠 What is AWS Organizations?

AWS Organizations lets you **centrally manage** and **govern multiple AWS accounts** under one umbrella. You can:

- Consolidate billing
    
- Group accounts into Organizational Units (OUs)
    
- Apply policies like Service Control Policies (SCPs)
    
- Delegate permissions and guardrails
    

---

### 🛠️ Prerequisites

- One AWS root account (will become the **management account**)
    
- IAM permissions to create an organization
    
- Optional: Additional email addresses (one per new account)
    

---

### ✅ Step 1: Create an Organization

1. **Log in** to the AWS Console as the root user or IAM user with permission.
    
2. Go to **AWS Organizations** service.
    
3. Click **"Create Organization"**.
    
    - Choose **Enable All Features** (Recommended).
        
4. You are now the **management account** of your organization.
    

---

### ✅ Step 2: Add AWS Accounts

You can add accounts in two ways:

#### Option 1: Invite an Existing AWS Account

1. Go to **"Accounts" > "Add account" > "Invite account"**.
    
2. Enter the email or account ID of the existing AWS account.
    
3. The invited account owner must **accept** the invitation.
    

#### Option 2: Create a New AWS Account

1. Go to **"Accounts" > "Add account" > "Create account"**.
    
2. Enter:
    
    - Account name
        
    - Email (must be unique)
        
    - IAM role name (used to manage it from the management account)
        
3. AWS will create and link the new account.
    

---

### ✅ Step 3: Create Organizational Units (OUs)

1. Go to **"Organize accounts"**.
    
2. Click **"Add OU"** (e.g., `Dev`, `Prod`, `Test`).
    
3. Drag and drop accounts into the relevant OUs.
    

---

### ✅ Step 4: Apply Service Control Policies (SCPs)

1. Go to **"Policies" > "Service Control Policies"**.
    
2. Click **"Create policy"** and define a JSON policy. Example:
    

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyEC2",
      "Effect": "Deny",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
```

3. Attach the SCP to an OU or account.
    
    - SCPs apply restrictions **on top of IAM policies**.
        

---

### ✅ Step 5: Enable Consolidated Billing

- By default, **Consolidated Billing** is enabled.
    
- You can view all account charges under **Billing > Bills** in the management account.
    
- Optionally, use **AWS Cost Explorer** and **Budgets** for tracking.
    

---

### ✅ Step 6: Use Delegated Administration (Optional)

You can delegate other accounts to manage specific services like AWS Config, CloudFormation StackSets, etc.

1. Go to **AWS Organizations > Delegated Administrator**.
    
2. Choose the service and assign a member account.
    

---

### 🛡️ Best Practices

- Don’t use the root account for daily tasks.
    
- Use SCPs to enforce compliance.
    
- Isolate workloads using separate accounts (e.g., `Dev`, `Prod`, `Security`).
    
- Enable AWS CloudTrail and Config in all accounts.
    
- Consider AWS Control Tower for easier multi-account setup.
    

---

### 📘 Useful CLI Commands

```bash
# List organization accounts
aws organizations list-accounts

# Create an OU
aws organizations create-organizational-unit \
  --parent-id <root or OU ID> \
  --name "Dev"

# Apply SCP
aws organizations attach-policy \
  --policy-id <policy-id> \
  --target-id <ou-id or account-id>
```

---
