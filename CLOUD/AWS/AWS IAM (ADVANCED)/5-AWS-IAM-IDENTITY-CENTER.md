**AWS Identity Center (formerly AWS SSO)** — your centralized hub for managing access **across multiple AWS accounts and applications**.

---

## 🧑‍💼 What is **AWS Identity Center**?

AWS Identity Center is a **centralized user identity and access management** service that lets you:

- ✅ Manage access to **multiple AWS accounts** from one place
    
- ✅ Integrate with **external identity providers** (like Microsoft Entra ID, Okta, Google Workspace, etc.)
    
- ✅ Use **built-in user directory** or **connect external IdPs**
    
- ✅ Enable **SSO (Single Sign-On)** for AWS Management Console, CLI, SDKs
    

---

## 🔑 Identity Center Core Components

|Component|Purpose|
|---|---|
|**Users/Groups**|Central directory (or synced from external IdP)|
|**Permission Sets**|Predefined sets of IAM roles + policies|
|**Account Assignments**|Who (user/group) gets what permission set on which account|
|**Applications**|Assign access to cloud or SaaS apps (SAML 2.0)|

---

## 🛠️ How Identity Center Works

1. **Enable Identity Center** in the management account.
    
2. Create or sync **users and groups**.
    
3. Define **permission sets** (think of them as IAM roles + policy templates).
    
4. Assign users/groups to **AWS accounts** using permission sets.
    
5. Users log in to [AWS access portal](https://my-sso-portal.awsapps.com/start) for **SSO access** to:
    
    - AWS accounts
        
    - Cloud/SaaS apps
        
    - CLI / SDK access
        

---

## 🚀 Use Case Example

### Scenario:

You’re managing 3 AWS accounts: `dev`, `test`, `prod`

### Goal:

- Devs get full access in `dev`
    
- Read-only access in `test` and `prod`
    

---

### 🧩 Steps:

1. **Create users** in Identity Center (or sync via Entra ID).
    
2. Create **permission sets**:
    
    - `DeveloperAccess` → AdministratorAccess
        
    - `ReadOnlyAccess` → ReadOnlyPolicy
        
3. Assign:
    
    - Dev group → `DeveloperAccess` on `dev`
        
    - Dev group → `ReadOnlyAccess` on `test` and `prod`
        

---

## 🔐 Identity Center + CLI Access

Users can log in via the **SSO browser** or AWS CLI:

```bash
aws configure sso
```

Then choose:

- SSO start URL
    
- Region
    
- Account & role
    

This gives **temporary credentials**, like `aws sts assume-role`.

---

## ☁️ Bonus: Identity Center vs IAM

|Feature|AWS IAM|AWS Identity Center|
|---|---|---|
|For individuals|✅ Yes|❌ Not ideal|
|For org-wide access|❌ Manual & complex|✅ Simplified|
|Central management|❌ No|✅ Yes|
|SSO access|❌ No native SSO|✅ Built-in|
|Directory integration|Limited (AD only)|✅ AD, Entra, Okta, etc.|

---

## 🧠 Common Integrations

- ✅ Microsoft Entra ID (Azure AD) – SAML / SCIM
    
- ✅ Okta, OneLogin – SAML 2.0
    
- ✅ AWS Organizations – Account-wide assignments
    

---
