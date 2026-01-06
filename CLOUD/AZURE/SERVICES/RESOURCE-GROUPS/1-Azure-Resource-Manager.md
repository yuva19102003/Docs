
### Azure resource manager [ARM]
![Azure Resource Manager Diagram](Pasted%20image%2020250205192000.png)

Azure Resource Manager (ARM) is the service that manages Azure resources.

### Features of ARM:
- **Infrastructure as Code (IaC)**: Deploy resources using JSON or Bicep templates.
- **Grouping**: Manage resources together.
- **Security**: Control access with role-based permissions.
- **Tagging**: Organize resources with labels.
- **Automation**: Deploy resources in the correct order.

### Example ARM Template:

```
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2021-04-01",
      "location": "eastus",
      "name": "MyResourceGroup"
    }
  ]
}
```

- Centralized management of resources.
- Infrastructure as Code (IaC) for automation.
- Secure and efficient resource handling.

---

## 🛠️ Terraform for Azure Resource Group

**Terraform** is an open-source Infrastructure as Code (IaC) tool by HashiCorp. It allows you to provision and manage Azure resources using declarative configuration.

---

### 🔹 Terraform Configuration Example

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "MyResourceGroup"
  location = "East US"
}

output "resource_group_name" {
  value = azurerm_resource_group.example.name
}
```

---

### ✅ Output

After applying, Terraform will display the resource group name:

```
Outputs:

resource_group_name = "MyResourceGroup"
```

---
