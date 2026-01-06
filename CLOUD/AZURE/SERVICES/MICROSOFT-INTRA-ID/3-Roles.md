
## 🔐 Azure Roles and Role-Based Access Control (RBAC)

In **Azure**, roles are used to manage **access control** by defining what actions users, groups, or applications can perform on specific resources. Azure implements **Role-Based Access Control (RBAC)** to achieve this.

---

### 🧠 Key Concepts

- **Role Definition** :  
    A set of permissions that determine what actions can be performed.  
    Examples:
    
    - `Owner`: Full access, including access management
        
    - `Contributor`: Create/manage resources, but cannot grant access
        
    - `Reader`: View-only access 
    
![Reader Role](Pasted%20image%2020250205214634.png)

- **Role Assignment**  
    A binding between a **role definition**, a **security principal** (user, group, service principal), and a **scope**.
    
- **Scope**  
    Defines where access applies:
    
    - Management Group
        
    - Subscription
        
    - Resource Group
        
    - Individual Resource
        

---

### 🧾 Types of Azure Roles

1. **Built-in Roles** (Predefined by Microsoft)
    
    - `Owner`: Full control, including permissions assignment
        
    - `Contributor`: Manage resources, no permission management
        
    - `Reader`: Read-only access
        
2. **Custom Roles**
    
    - Created by users to meet specific access needs
        
    - Defined using JSON templates with granular permissions
        
3. **User-Defined Roles**
    
    - Another term often used for custom roles created by users to match organizational needs
        

---

### ⚙️ Role Management Actions in Entra ID (Azure AD)

#### ✅ Create Role

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Roles** section
    
3. Clicks **New Role**
    
4. Enters **Role Name** & **Description**
    
5. Assigns **Permissions & Settings**
    
6. Assigns role to **Users or Groups**
    
7. Clicks **Create**  
    🔹 _Role is successfully created_
    

---

#### 🔁 Overwrite Role

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Roles** section
    
3. Selects the **Role**
    
4. Clicks **Edit**
    
5. Updates **Role Name, Permissions, or Settings**
    
6. Clicks **Save**  
    🔹 _Role is successfully overwritten_
    

---

#### ❌ Delete Role

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Roles** section
    
3. Selects the **Role**
    
4. Clicks **Delete**
    
5. Confirms deletion  
    🔹 _Role is successfully deleted_
    

---

### 👤 User Role Assignments

#### ➕ Add Role to User

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Users** section
    
3. Selects the **User**
    
4. Clicks **Assigned Roles**
    
5. Clicks **Add Assignment**
    
6. Selects **Role**
    
7. Clicks **Assign**  
    🔹 _Role is successfully assigned to user_
    

#### ➖ Remove Role from User

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Users** section
    
3. Selects the **User**
    
4. Clicks **Assigned Roles**
    
5. Selects the **Role**
    
6. Clicks **Remove Assignment**  
    🔹 _Role is successfully removed from user_
    

---

### 👥 Group Role Assignments

#### ➕ Add Role to Group

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Groups** section
    
3. Selects the **Group**
    
4. Clicks **Assigned Roles**
    
5. Clicks **Add Assignment**
    
6. Selects **Role**
    
7. Clicks **Assign**  
    🔹 _Role is successfully assigned to group_
    

#### ➖ Remove Role from Group

1. Admin logs into **Entra ID Portal**
    
2. Navigates to **Groups** section
    
3. Selects the **Group**
    
4. Clicks **Assigned Roles**
    
5. Selects the **Role**
    
6. Clicks **Remove Assignment**  
    🔹 _Role is successfully removed from group_
    

---

## ☁️ Azure RBAC via Terraform

### ✅ Prerequisites

Make sure the following Terraform provider is defined:

```hcl
provider "azurerm" {
  features {}
}
```

---

### 1️⃣ Create a Custom Role

```hcl
resource "azurerm_role_definition" "custom_reader" {
  name        = "CustomReader"
  scope       = data.azurerm_subscription.primary.id
  description = "Custom Reader with limited actions"

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Compute/virtualMachines/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

data "azurerm_subscription" "primary" {}
```

---

### 2️⃣ Assign Built-in Role to a User

```hcl
resource "azurerm_role_assignment" "user_contributor" {
  principal_id   = azurerm_user_assigned_identity.example.principal_id
  role_definition_name = "Contributor" # or use role_definition_id for custom roles
  scope          = azurerm_resource_group.example.id
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "my-identity"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}
```

---

### 3️⃣ Assign Custom Role to Azure AD Group

```hcl
resource "azurerm_role_assignment" "group_custom_role" {
  principal_id         = data.azuread_group.devops_team.id
  role_definition_id   = azurerm_role_definition.custom_reader.role_definition_resource_id
  scope                = azurerm_resource_group.example.id
}

data "azuread_group" "devops_team" {
  display_name = "DevOpsTeam"
}
```

---

### 4️⃣ Remove Role Assignment (by deleting the resource)

To remove a role assignment, simply delete the corresponding `azurerm_role_assignment` resource from your Terraform code and apply the change.

---

### ℹ️ Notes

- **principal_id**: The Object ID of the user, group, or service principal
    
- **scope**: Can be a subscription, resource group, or individual resource
    
- **role_definition_name**: For built-in roles (e.g., `Reader`, `Contributor`)
    
- **role_definition_id**: For custom roles created via `azurerm_role_definition`
    

---



### ROLES FOR IDENTITY

Giving or assigning roles and permission for identities (users or resources) for interact with other identities..

1.  SERVICE PRINCIPALS:  assign roles to the users to interact with the resources. [3a-Service-principals.md](3a-Service-principals.md)
2. MANAGED IDENTITIES:  assign roles to resources to interact with other resources. [3b-managed-identities.md](3b-managed-identities.md)
3. difference between service principals and managed identities. [3c-service-principals-vs-managed-identities.md](3c-service-principals-vs-managed-identities.md)

---


