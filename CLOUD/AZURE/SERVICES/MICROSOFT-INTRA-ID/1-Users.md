
## 🔐 Azure (Microsoft Entra ID) – User Management

In **Azure (Microsoft Entra ID)**, a **user** is an identity representing an individual or application that can authenticate and access resources within an organization.

---

### 🧑‍🤝‍🧑 **Types of Users in Azure Entra ID**

- **Member Users**  
    Internal users in the organization (e.g., employees).
    
- **Guest Users**  
    External users (e.g., partners, vendors) invited for collaboration.
    
- **Service Principals**  
    Identities for applications or services to authenticate and access resources.
    
- **Managed Identities**  
    System-assigned identities used by Azure services to securely access resources **without storing credentials**.
    
Users can be assigned roles, permissions, and access to applications, resources, and services based on organizational policies. 🚀

---


![Create Users in Entra ID](Pasted%20image%2020250205212026.png)

### 👤 **Create Users in Entra ID**

1. Admin logs into the **Entra ID Portal**
    
2. Navigates to **"Users"** section
    
3. Clicks **"New User"**
    
4. Enters user details (Name, Username, etc.)
    
5. Assigns roles and permissions
    
6. Saves the new user
    
7. User receives a welcome email
    
8. User logs in and completes setup ✅
    

---

### ❌ **Delete Users in Entra ID**

1. Admin logs into the **Entra ID Portal**
    
2. Navigates to **"Users"** section
    
3. Selects the user to remove
    
4. Clicks **"Delete"**
    
5. Confirms the deletion
    
6. User is moved to **"Deleted Users"**
    
7. (Optional) Admin can **permanently delete** or **restore** the user
    
---
## ⚙️ Terraform: Manage Users in Azure Entra ID

### 🔧 Prerequisites

```hcl
provider "azuread" {
  tenant_id = "your-tenant-id"
}
```

---

### 👤 Create a Member User

```hcl
resource "azuread_user" "example_user" {
  user_principal_name = "john.doe@yourdomain.com"
  display_name        = "John Doe"
  password            = "P@ssw0rd1234!"
  force_password_change = true
  mail_nickname       = "johndoe"
  account_enabled     = true
}
```

---

### 🛡️ Assign a Role to the User (e.g., Global Reader)

```hcl
data "azuread_directory_role" "global_reader" {
  display_name = "Global Reader"
}

resource "azuread_directory_role_member" "assign_role" {
  role_object_id   = data.azuread_directory_role.global_reader.object_id
  member_object_id = azuread_user.example_user.object_id
}
```

---

### ❌ Delete a User

To delete a user, simply remove the `azuread_user` resource from your Terraform code and run:

```bash
terraform apply
```

Terraform will then remove the user from Entra ID.

---

### 📝 Notes

- Ensure the password complies with your **tenant’s complexity requirements**.
    
- The user receives an email only if **email is routable and configured**.
    
- Roles must be enabled in the tenant using Azure Portal or CLI if not already available.
    

---
