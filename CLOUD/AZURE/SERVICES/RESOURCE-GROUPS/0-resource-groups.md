### **Resource**
![Azure Resource Diagram](Pasted%20image%2020250205192655.png)

Building Blocks of your cloud infrastructure in Azure.
Eg: VM, DB, Storage accounts, or any other services by Azure.

---

### Resource Groups
![Resource Groups Diagram](Pasted%20image%2020250205192344.png)

Logical Container for resources that share the same life cycle,permission and policies.
resources within a group can be deployed,update,deleted together ass a single management unit.

---

> [!Key Points]
> lifecycle management
> resource organistation
> role based access control [RBAC]

### Example:

```
# Create a Resource Group using Azure CLI
az group create --name MyResourceGroup --location eastus
```

this service will manage the resources in azure: [Azure Resource Manager](1-Azure-Resource-Manager.md) 