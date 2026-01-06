## 🔹 **Groups in Azure (Microsoft Entra ID)**

A **group** in Microsoft Entra ID is a collection of users, devices, or service principals used to manage **permissions**, **access control**, and **policies** more efficiently.

### ✅ **Types of Groups**

- **Security Groups**: Used for assigning access to resources like apps, VMs, and files.
    
    - _Example_: A security group **“Developers”** grants access to **Azure DevOps** and **GitHub Repos**.
        

Groups help implement **Role-Based Access Control (RBAC)** by simplifying permission assignments across multiple users. 🚀

---

![Create Groups in Entra ID](Pasted%20image%2020250205213738.png)

### 📌 **Create a Group**

1. Sign in to **Microsoft Entra ID Portal**.
    
2. Go to **“Groups”** > Click **“New Group”**.
    
3. Choose **Group Type**: `Security` or `Microsoft 365`.
    
4. Enter **Name**, **Description**.
    
5. Assign **Owners** and **Members**.
    
6. Configure **Settings & Permissions**.
    
7. Click **“Create”** – Group is created successfully.
    

---

### ➕ **Add User to a Group**

1. Go to **Groups** > Select the desired group.
    
2. Click **“Members”** > **“Add Members”**.
    
3. Search and select the user.
    
4. Click **“Add”** – User is added to the group.
    

---

### ➖ **Remove User from a Group**

1. Go to **Groups** > Select the group.
    
2. Click **“Members”** > Locate the user.
    
3. Click **“Remove”** > Confirm.
    
4. User is successfully removed.
    

---

### 🗑️ **Delete a Group**

1. Go to **Groups** > Select the group.
    
2. Click **“Delete”** > Confirm.
    
3. Group moves to **“Deleted Groups”**.
    
4. _(Optional)_ Permanently delete or restore the group.
    

---

## ⚙️ **Terraform – Managing Azure Entra ID Groups**

You can use the `azuread` provider to manage groups and group membership in Entra ID (Azure AD).

### 📦 **Provider Setup**

```hcl
provider "azuread" {
  # Make sure you're authenticated using `az login`
}
```

---

### 🏗️ **Create a Security Group**

```hcl
resource "azuread_group" "developers" {
  display_name     = "Developers"
  security_enabled = true
  mail_enabled     = false
  description      = "Security group for developer access to Azure DevOps and GitHub"
}
```

---

### ➕ **Add Users to the Group**

```hcl
resource "azuread_group_member" "add_users" {
  group_object_id  = azuread_group.developers.id
  member_object_id = "<USER_OBJECT_ID>" # Replace with actual User Object ID
}
```

> 🔍 To get the `member_object_id`, use:

 ```bash
 az ad user show --id <user_email> --query objectId --output tsv
 ```

---

### ➖ **Remove Users from the Group**

Simply remove the `azuread_group_member` resource from your code or run:

```bash
terraform state rm azuread_group_member.add_users
terraform apply
```

---

### 🗑️ **Delete a Group**

To delete the group, just remove or comment out the `azuread_group` resource from your code and re-apply:

```bash
terraform apply
```

---

### 💡 **Optional: Use Variables for Reusability**

```hcl
variable "group_name" {
  default = "Developers"
}

resource "azuread_group" "example" {
  display_name     = var.group_name
  security_enabled = true
  mail_enabled     = false
}
```

---
