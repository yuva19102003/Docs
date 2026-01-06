## 🔐 Security Principal in Azure

A **security principal** is an identity representing a user, group, service, or application that requests access to Azure resources. When a **role** is assigned to a security principal, it defines **what actions** the principal can perform on a given resource.

![Security Principal Diagram](Pasted%20image%2020250205220511.png)

---

## 📌 App Registration in Microsoft Entra ID (Azure AD)

**App Registration** is the process of creating an identity for an application in Azure Active Directory (Entra ID). This identity allows the app to authenticate and securely access Azure services and APIs.

![App Registration Diagram](Pasted%20image%2020250205224308.png)

### 🔧 Key Concepts

- **Service Principal**: Created automatically during app registration. It represents the application identity in a tenant, enabling access to Azure resources.
    
- **Authentication**: Supports **OAuth 2.0**, **OpenID Connect**, and **Client Credentials Flow**.
    
- **Permissions**: Roles and permissions can be assigned to the service principal for secure access control.
    
- **Secrets/Certificates**: Used to authenticate the app securely via client secrets or certificates.
    

> ✅ App registration creates a **service principal**, enabling the application to authenticate and operate autonomously in Azure.

---

## 🔨 Lifecycle of a Service Principal

### 1️⃣ Create a Service Principal

**Steps:**

1. Admin logs in to [Microsoft Entra ID Portal](https://entra.microsoft.com/).
    
2. Go to **Azure Active Directory** → **App registrations**.
    
3. Click **+ New registration**.
    
4. Enter application details → Click **Register**.
    
5. ✅ Service principal is created.
    

---

### 2️⃣ Assign Role to Service Principal

**Steps:**

1. Navigate to **Azure Active Directory** → **Roles and administrators**.
    
2. Select the desired role.
    
3. Click **Add assignment**.
    
4. Search and select the **Service Principal**.
    
5. Click **Assign**.
    
6. ✅ Role is assigned to the service principal.
    

---

### 3️⃣ Modify Role for Service Principal

**Steps:**

1. Go to **Azure Active Directory** → **Roles and administrators**.
    
2. Select the role assigned to the service principal.
    
3. Click **Remove assignment**.
    
4. (Optional) Reassign a different role.
    
5. Click **Assign**.
    
6. ✅ Role assignment is updated.
    

---

### 4️⃣ Remove Role from Service Principal

**Steps:**

1. Go to **Azure Active Directory** → **Roles and administrators**.
    
2. Select the role currently assigned to the service principal.
    
3. Click **Remove assignment**.
    
4. ✅ Role is removed.
    

---

### 5️⃣ Delete Service Principal

**Steps:**

1. Navigate to **Azure Active Directory** → **App registrations**.
    
2. Select the desired service principal.
    
3. Click **Delete** and confirm.
    
4. ✅ Service principal is deleted from the directory.
    

---
Here's a **text-based arrow diagram** to visually represent the flow of the **App Registration → Service Principal → Role Assignment** process in Terraform:

```
+----------------------+
|  azuread_application |
|      (App Reg)       |
+----------+-----------+
           |
           | creates
           v
+---------------------------+
| azuread_service_principal |
|     (App Identity)        |
+-----------+---------------+
            |
            | assigned to
            v
+----------------------------+
|   azurerm_role_assignment |
| (Grants Role to SPN)      |
+----------------------------+
            ^
            |
            | uses
            |
+----------------------------+
| azurerm_role_definition   |
| (e.g., Contributor Role)  |
+----------------------------+
            ^
            |
            | on
            |
+-------------------------+
| azurerm_subscription    |
| (or Resource Group, etc)|
+-------------------------+
```

Optional (if using secrets):

```
+-----------------------------+
| azuread_application_password|
|   (Client Secret)           |
+-----------------------------+
```

---

This diagram aligns with the Terraform resources:

- `azuread_application` → Defines the app
    
- `azuread_service_principal` → Identity for the app
    
- `azurerm_role_definition` + `azurerm_role_assignment` → Assigns role to SPN
    
- `azuread_application_password` → Adds client secret for auth (optional)
    
---

## ✅ 1. App Registration (Azure AD Application)

```hcl
resource "azuread_application" "example" {
  display_name = "my-app"
}
```

---

## ✅ 2. Create a Service Principal

```hcl
resource "azuread_service_principal" "example" {
  application_id = azuread_application.example.application_id
}
```

---

## ✅ 3. Assign a Role to the Service Principal

To assign a **built-in role** like `Contributor` or `Reader`, you’ll need the **Azure Resource ID** and **Role Definition ID**.

```hcl
data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_id   = data.azurerm_role_definition.contributor.id
  principal_id         = azuread_service_principal.example.id
}
```

---

## ✅ 4. Assign App Secret (Client Credentials)

```hcl
resource "azuread_application_password" "example" {
  application_object_id = azuread_application.example.id
  display_name          = "my-secret"
}
```

---

## 🧹 5. Delete Service Principal (Handled via `terraform destroy`)

When you run:

```bash
terraform destroy
```

It will remove the app registration and service principal automatically if they are part of your Terraform state.

---

## 📦 Full Working Example

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = "<your-tenant-id>"  # optional if already configured
}

data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azuread_application" "example" {
  display_name = "terraform-sp-demo"
}

resource "azuread_service_principal" "example" {
  application_id = azuread_application.example.application_id
}

resource "azuread_application_password" "example" {
  application_object_id = azuread_application.example.id
  display_name          = "my-app-secret"
}

resource "azurerm_role_assignment" "example" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = azuread_service_principal.example.id
}
```

---
