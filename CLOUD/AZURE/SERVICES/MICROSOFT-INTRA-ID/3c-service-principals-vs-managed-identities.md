
### 🔄 **Service Principal vs. Managed Identity — Comparison Table**

|**Feature**|**Service Principal**|**Managed Identity**|
|---|---|---|
|**Definition**|Identity used by applications or services to authenticate with Azure resources.|Identity automatically managed by Azure for authenticating Azure resources to other services.|
|**Creation**|Manually created via Azure CLI, PowerShell, or Portal.|System-assigned: auto-created. User-assigned: manually created, reusable across resources.|
|**Lifecycle**|Exists independently and must be manually maintained.|System-assigned: tied to resource lifecycle. User-assigned: independent of resource lifecycle.|
|**Credential Management**|Requires manual handling of secrets or certificates.|Credentials and key rotation handled entirely by Azure.|
|**Scope**|Can span across multiple subscriptions, tenants, and resources.|System-assigned: specific to a single resource. User-assigned: sharable across multiple resources.|
|**Permissions**|Must assign roles manually using RBAC.|Roles also assigned using RBAC, but no need to handle credentials.|
|**Use Case**|Suitable for external apps, CI/CD tools, or multi-tenant apps.|Ideal for Azure-native workloads like VMs, Functions, and App Services accessing Azure services.|
|**Security**|Prone to mismanagement if credentials are exposed or not rotated.|More secure — no secret exposure and built-in credential rotation by Azure.|

---

### 🔄 **Azure to AWS Identity Mapping**

|**Azure Concept**|**AWS Equivalent**|
|---|---|
|**Service Principal**|**IAM User** or **IAM Role with static credentials**|
|**Managed Identity (System-assigned)**|**IAM Role attached to an EC2 instance (Instance Profile)**|
|**Managed Identity (User-assigned)**|**Reusable IAM Role attached to multiple services**|
|**Azure RBAC Role Assignment**|**IAM Policy Attachment**|
|**Azure Key Vault Access via MSI**|**S3 / Secrets Manager access via IAM Role**|
|**Token from Azure AD**|**Temporary security token from AWS STS**|

---
