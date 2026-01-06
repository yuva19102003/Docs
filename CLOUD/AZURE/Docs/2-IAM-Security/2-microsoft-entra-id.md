
# **Microsoft Entra ID – Complete Beginner Tutorial**

## **1. What is Microsoft Entra ID?**

Microsoft Entra ID (formerly Azure AD) is Microsoft’s **cloud identity and access management (IAM) service**.

It helps you:

* Control **who can access** your apps and resources
* Decide **what they can do** (permissions/roles)
* Keep your environment **secure** with MFA, conditional access, and monitoring

**Analogy:** It’s like a **digital gatekeeper** of your organization.

---

## **2. Key Components**

| Component        | What it does                                               |
| ---------------- | ---------------------------------------------------------- |
| **Users**        | People in your organization who need access                |
| **Groups**       | Groups of users for easy permission management             |
| **Roles**        | Define permissions to resources                            |
| **Applications** | Apps connected to Entra ID (Office 365, Teams, Salesforce) |
| **Devices**      | Laptops, phones, managed devices                           |
| **Tenant**       | Your organization’s Entra environment                      |
| **Domains**      | Your company domains managed in Entra                      |

---

## **3. Principals and Identities**

**Principals** represent an identity that can authenticate:

| Principal Type        | Description                        | Example                                |
| --------------------- | ---------------------------------- | -------------------------------------- |
| **User Principal**    | A human user                       | Employee logging in to Office 365      |
| **Service Principal** | An app or service identity         | App calling an API                     |
| **Managed Identity**  | Azure service identity (automatic) | VM accessing Storage without passwords |

**Important IDs:**

* **Object ID:** Unique identifier for any principal (user, app, group)
* **Application (Client) ID:** Unique ID for an app registration
* **Directory (Tenant) ID:** Unique ID of your Entra tenant
* **Principal ID:** Unique ID of a service principal or managed identity

---

## **4. Roles in Entra ID**

Roles determine **what a principal can do**.

| Role                          | Description                   | Example                         |
| ----------------------------- | ----------------------------- | ------------------------------- |
| **User**                      | Basic access                  | Access Office 365 apps          |
| **Global Administrator**      | Full access to tenant         | Manage users, roles, apps       |
| **Application Administrator** | Manage apps                   | Configure SSO & API permissions |
| **Security Administrator**    | Manage security policies      | Set MFA & Conditional Access    |
| **Resource-Specific Roles**   | Access only certain resources | VM Contributor, Storage Reader  |

**Tip:** Always use **least privilege** — give only the permissions needed.

---

## **5. Key Features**

* **Single Sign-On (SSO):** One login for multiple apps
* **Multi-Factor Authentication (MFA):** Extra security layer
* **Conditional Access:** Limit access by location, device, or risk
* **B2B Collaboration:** Invite external partners securely
* **Privileged Identity Management (PIM):** Monitor admin accounts
* **Hybrid Identity:** Sync on-prem Active Directory with cloud

---

## **6. Setting Up Microsoft Entra ID – Step by Step**

### **Step 1: Create a Tenant**

1. Go to [Azure Portal](https://portal.azure.com)
2. Search **Microsoft Entra ID** → Click **Create a tenant**
3. Fill **Organization Name** & **Initial Domain Name** → **Create**

### **Step 2: Add Users**

1. Navigate to **Users > New User**
2. Fill details → Assign **roles/groups** → Enable **MFA**

### **Step 3: Create Groups**

1. Go to **Groups > New Group**
2. Add users → Use groups to **assign app access**

### **Step 4: Register Applications**

1. Go to **App registrations > New Registration**
2. Fill name, supported account types, redirect URI
3. Configure **API permissions** & generate **client secret**

### **Step 5: Assign Roles**

1. Go to the resource (VM, Storage, App)
2. Assign **role to principal** (user, service principal, managed identity)

### **Step 6: Enable Security**

* MFA
* Conditional Access
* Privileged Identity Management (PIM) for admins

### **Step 7: Optional – Hybrid Identity**

1. Install **Azure AD Connect**
2. Sync on-prem AD → Enable SSO for hybrid users

---

## **7. How Principals and Roles Work Together**

1. **User logs in** → User principal is created
2. **App or script accesses resources** → Use **service principal** or **managed identity**
3. **Permissions are assigned** → Role defines access
4. **Entra enforces rules** → Access allowed or denied

**Example:**

* VM (Managed Identity) → Storage Blob Reader → Can read blobs
* App (Service Principal) → Contributor role on Resource Group → Can create VMs

---

## **8. Beginner-Friendly Diagram**

```
        ┌─────────────┐
        │    User     │
        │ (Human)     │
        └─────┬──────┘
              │
              ▼
        ┌─────────────┐
        │ User Principal│
        └─────┬──────┘
              │ Assigned Role
              ▼
        ┌─────────────┐
        │  Resource   │
        │  (VM, App)  │
        └─────────────┘

        ┌─────────────┐
        │   App /     │
        │ Service     │
        └─────┬──────┘
              │
              ▼
    ┌─────────────────────┐
    │ Service Principal / │
    │ Managed Identity    │
    └─────┬───────────────┘
          │ Assigned Role
          ▼
        ┌─────────────┐
        │  Resource   │
        │  (VM, App)  │
        └─────────────┘
```

**Explanation:**

* **User principal:** Human logging in
* **Service principal:** App identity accessing resources
* **Managed identity:** Azure service identity (VM, Function App)
* **Role:** Permission assigned to principal for a resource

---

## **9. Best Practices**

* Enable **MFA** for all users, especially admins
* Use **groups** for assigning roles instead of individual users
* Regularly review **audit logs**
* Use **least privilege** principle
* Monitor **guest and external accounts**

---

## **10. Resources for Learning**

* [Microsoft Entra Documentation](https://learn.microsoft.com/en-us/entra/)
* [Microsoft Learn – Secure Identity](https://learn.microsoft.com/en-us/training/paths/secure-identity-azure/)
* YouTube tutorials: Search for *Microsoft Entra ID beginner*

---

✅ **Summary:**
Microsoft Entra ID manages **who can access what** securely.

* **Users** = human accounts
* **Service Principals** = app identities
* **Managed Identities** = Azure service accounts
* **Roles** = permissions
* **Enforce security** with MFA, Conditional Access, and PIM

---
