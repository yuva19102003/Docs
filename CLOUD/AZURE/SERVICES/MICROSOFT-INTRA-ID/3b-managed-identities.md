# **Managed Identity in Azure**

**Managed Identity** provides an automatically managed identity in Azure Active Directory (Entra ID) for applications to securely access Azure resources—**without needing credentials in code**.

![Managed Identity Diagram](Pasted%20image%2020250205220851.png)

---
## 🧩 Types of Managed Identities

### 1. **System-assigned**

- Automatically created and tied to an Azure resource (e.g., VM, Web App).
    
- Lifecycle is **bound to the resource**—deleted when the resource is deleted.
    
- **One identity per resource**.
    
### 2. **User-assigned**

- Created as a standalone **Azure resource**.
    
- Can be **shared** across multiple Azure resources.
    
- **Lifecycle is independent** of any specific resource.
    
---

## 🔐 Key Features

- **Automatic Authentication**: No need to store or rotate credentials—Azure manages it.
    
- **RBAC Integration**: Permissions are granted using **Azure Role-Based Access Control**.
    
- **Improved Security**: Eliminates hardcoding secrets or connection strings.
    
- **Scalable**: Easily assign user-assigned identities across resources.
    

---

## ✅ Benefits

- **Improved Security**: Credentials aren’t exposed in code.
    
- **Simplified Management**: Azure handles the identity lifecycle.
    
- **Audit Friendly**: Uses Azure AD and RBAC for centralized visibility and control.
    

---

## 💡 Example Use Case

An **Azure Virtual Machine (VM)** accesses **Azure Blob Storage** securely:

- VM uses its **system-assigned managed identity**.
    
- Identity authenticates via Azure Instance Metadata Service (IMDS).
    
- VM retrieves a **token from Azure AD**, which it uses to access blob data.
    

---

## 🛠️ How to Use Managed Identity

### 🔷 Create Managed Identity (via Entra ID Portal)

1. Admin logs into the **Entra ID Portal**.
    
2. Navigate to **Azure Active Directory** → **Managed Identities**.
    
3. Click **Create** → Select the Azure resource (e.g., VM, App Service).
    
4. Enable **System-assigned** or **User-assigned** Managed Identity.
    
5. Click **Create**.
    
6. ✅ Managed Identity is successfully created.
    

---

### 🔷 Assign Role to Managed Identity (RBAC)

1. Go to **Azure Active Directory** → **Roles and Administrators**.
    
2. Select the desired **Azure role** (e.g., `Reader`, `Key Vault Secrets User`).
    
3. Click **Add Assignment**.
    
4. Search for the **Managed Identity** by name.
    
5. Click **Assign**.
    
6. ✅ Role is successfully assigned.
    

---

### 🔷 Modify Role Assignment

1. Go to **Roles and Administrators** → Select the assigned role.
    
2. Click **Remove Assignment** for the Managed Identity.
    
3. (Optional) Reassign a new role.
    
4. Click **Assign**.
    
5. ✅ Role is successfully modified.
    

---

### 🔷 Remove Role from Managed Identity

1. Navigate to **Azure Active Directory** → **Roles and Administrators**.
    
2. Choose the role assigned to the identity.
    
3. Click **Remove Assignment**.
    
4. ✅ Role is removed from the identity.
    

---

### 🔷 Delete Managed Identity

1. Go to **Azure Active Directory** → **Managed Identities**.
    
2. Select the identity you want to delete.
    
3. Click **Delete** → Confirm deletion.
    
4. ✅ Managed Identity is successfully deleted.
    

---

## 💻 CLI Example (Azure CLI)

### Enable Managed Identity on a VM:

```bash
az vm identity assign \
  --resource-group MyResourceGroup \
  --name MyVM
```

### Assign Role to Managed Identity:

```bash
az role assignment create \
  --assignee <clientId or objectId> \
  --role "Storage Blob Data Reader" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage-name>
```

---

## 🔄 Token Authentication Flow

1. Application or VM uses **IMDS endpoint** (`http://169.254.169.254`) to request a token.
    
2. Azure returns a **JSON Web Token (JWT)** for the target Azure service.
    
3. App includes the token in its request headers to **authenticate securely**.
    

---

## 📌 Best Practices

- Prefer **system-assigned** identity for simple one-resource use cases.
    
- Use **user-assigned** identity when multiple resources share the same identity.
    
- Regularly **audit RBAC assignments**.
    
- Always **use Managed Identity over hardcoded credentials** when possible.
    

---

## ✅ 1. **System-assigned Managed Identity (on a VM)**

```hcl
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "myvm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
```

---

## ✅ 2. **User-assigned Managed Identity**

### a. Create the Identity

```hcl
resource "azurerm_user_assigned_identity" "uai" {
  name                = "my-uai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

### b. Attach to a VM

```hcl
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-with-uai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
```

---

## ✅ 3. **Assign RBAC Role to Managed Identity**

```hcl
resource "azurerm_role_assignment" "blob_access" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}
```

> 🔹 Use `role_definition_name` or `role_definition_id`.

---

## ✅ 4. **Full Resource Group and Storage Sample (Optional)**

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageacct123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---
Here’s the **Terraform workflow diagram for Managed Identity (Left to Right)** using **text-based boxes and arrows**:

```
Start 
  → Define Resource Group 
  → Create Target Resource (e.g., Storage Account) 
  → Create Managed Identity (System-assigned or User-assigned) 
  → Attach Identity to Resource (e.g., VM, App Service) 
  → Get principal_id from Identity 
  → Assign Role using azurerm_role_assignment 
  → terraform apply 
  → Azure deploys resources and permissions 
  → Resource accesses target securely via Managed Identity 
  → End
```
## 📌 Notes

- For **system-assigned** identities, use `azurerm_windows_virtual_machine.identity.principal_id`.
    
- For **user-assigned**, use `azurerm_user_assigned_identity.uai.principal_id`.
    
- Roles are defined by name (`Storage Blob Data Reader`, `Contributor`, etc.) or custom role ID.
    

---
