
# 🌐 Terraform Authentication Methods for Azure

Terraform uses the Azure Resource Manager (ARM) provider to authenticate and manage Azure resources. The following are supported authentication methods:

---

## 1️⃣ **Service Principal with Client Secret**

This is the most common method for CI/CD pipelines and local use.

### ✅ Required Environment Variables

```bash
export ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
export ARM_TENANT_ID="zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"
```

### ✅ Example `main.tf`

```hcl
provider "azurerm" {
  features {}
}
```

Terraform will automatically pick up the environment variables.

---

## 2️⃣ **Service Principal with Client Certificate**

Used for more secure environments where secrets are avoided.

### ✅ Required Environment Variables

```bash
export ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
export ARM_TENANT_ID="zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"
export ARM_CLIENT_CERTIFICATE_PATH="/path/to/client.pfx"
export ARM_CLIENT_CERTIFICATE_PASSWORD="your-pfx-password"
```

> 🔐 The certificate must be associated with the app in Azure AD.

---

## 3️⃣ **Azure CLI Authentication**

Useful for local development.

### ✅ Setup

```bash
az login
```

No environment variables are required.

### ✅ Example `main.tf`

```hcl
provider "azurerm" {
  features {}
  use_cli = true
}
```

---

## 4️⃣ **Managed Identity (System-Assigned or User-Assigned)**

Great for Terraform running on Azure VMs or in Azure DevOps pipelines on hosted agents.

### ✅ Required Environment Variables

For **System-Assigned** Managed Identity:

```bash
export ARM_USE_MSI=true
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

For **User-Assigned** Managed Identity (with client ID):

```bash
export ARM_USE_MSI=true
export ARM_CLIENT_ID="your-user-assigned-managed-identity-client-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

---

## 5️⃣ **OIDC Federated Identity (GitHub Actions or Azure DevOps)**

No secrets needed. Uses a federated identity between Azure AD and your CI/CD system.

### ✅ GitHub Actions Workflow

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Terraform Init
        run: terraform init
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

> ☁️ Use a federated credential on the Azure App Registration.

---

## 6️⃣ **AzureRM Provider Blocks with Explicit Credentials (Not Recommended)**

### Example (not recommended):

```hcl
provider "azurerm" {
  client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_secret   = "your-client-secret"
  tenant_id       = "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"
  subscription_id = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
  features {}
}
```

> ⚠️ **Hardcoding secrets is insecure** and should be avoided.

---

## 7️⃣ **Environment-Based Authentication via Azure DevOps Hosted Agents**

If Terraform is running on an agent that already has access (via Managed Identity), you can use:

```bash
export ARM_USE_MSI=true
```

Azure DevOps pipelines can also use service connections + federated identity.

---

# 📋 Summary Table

|Method|Secrets Required|Secure|CI/CD Friendly|Local Dev|Notes|
|---|---|---|---|---|---|
|Client Secret (SPN)|✅|⚠️|✅|✅|Common for automation|
|Client Certificate (SPN)|🔐|✅|✅|⚠️|Secure alternative|
|Azure CLI|❌|✅|❌|✅|Easy for dev|
|Managed Identity|❌|✅|✅|❌|Ideal for Azure-hosted runners|
|OIDC (Federated Identity)|❌|✅✅|✅✅|❌|Best practice for GitHub/Azure DevOps|
|Hardcoded in HCL|✅|❌|❌|⚠️|Avoid in production|

---


# ⚙️ Full `azurerm` Provider Configuration Reference

```hcl
provider "azurerm" {
  features {
    # Resource-specific feature flags
    api_management {
      purge_soft_delete_on_destroy       = false
      recover_soft_deleted               = false
    }

    application_insights {
      disable_generated_code_warning     = false
    }

    cognitive_account {
      purge_soft_delete_on_destroy       = false
      recover_soft_deleted               = false
    }

    container_registry {
      purge_soft_delete_on_destroy       = false
    }

    key_vault {
      purge_soft_delete_on_destroy       = false
      recover_soft_deleted               = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      purge_soft_deleted_secrets_on_destroy      = false
      purge_soft_deleted_storage_on_destroy      = false
    }

    log_analytics_workspace {
      permanently_delete_on_destroy      = false
    }

    network_interface {
      ignore_missing_network_security_group = false
    }

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    role_assignment {
      skip_service_principal_aad_check   = false
    }

    storage_account {
      prevent_cmk_vault_soft_delete      = false
    }

    synapse_workspace {
      purge_soft_delete_on_destroy       = false
    }
  }

  # Optional authentication fields
  client_id                      = var.client_id
  client_secret                  = var.client_secret
  tenant_id                      = var.tenant_id
  subscription_id                = var.subscription_id
  client_certificate_path        = var.certificate_path
  client_certificate_password    = var.certificate_password
  use_msi                        = var.use_msi
  msi_endpoint                   = var.msi_endpoint
  use_cli                        = var.use_cli
  use_oidc                       = var.use_oidc
  oidc_request_token             = var.oidc_token
  oidc_request_url               = var.oidc_url

  # Optional environment-specific config
  environment                   = "public" # or AzureChinaCloud, AzureUSGovernment, etc.

  # Optional debugging and network behavior
  skip_provider_registration     = false
  disable_terraform_partner_id   = false
  metadata_host                  = "169.254.169.254"
  auxiliary_tenant_ids           = []

  # Misc options
  partner_id                     = "partner-name"
}
```

---

## 🧱 `features {}` Block Resource-Specific Flags

|Resource Type|Feature Flag|Default|
|---|---|---|
|api_management|purge_soft_delete_on_destroy / recover_soft_deleted|false|
|application_insights|disable_generated_code_warning|false|
|cognitive_account|purge_soft_delete_on_destroy / recover_soft_deleted|false|
|container_registry|purge_soft_delete_on_destroy|false|
|key_vault|purge_*_on_destroy / recover_soft_deleted|false|
|log_analytics_workspace|permanently_delete_on_destroy|false|
|network_interface|ignore_missing_network_security_group|false|
|resource_group|prevent_deletion_if_contains_resources|false|
|role_assignment|skip_service_principal_aad_check|false|
|storage_account|prevent_cmk_vault_soft_delete|false|
|synapse_workspace|purge_soft_delete_on_destroy|false|

---

## 🛡️ Authentication Methods Supported in `provider` block

|Method|Required Fields|
|---|---|
|Client Secret|`client_id`, `client_secret`, `tenant_id`, `subscription_id`|
|Client Certificate|`client_id`, `client_certificate_path`, `client_certificate_password`|
|Managed Identity|`use_msi = true`, optionally `client_id`|
|Azure CLI|`use_cli = true`|
|OIDC Token (e.g. GitHub)|`use_oidc = true`, `oidc_request_token`, `oidc_request_url`|

---

## 🌍 Environment Options

|Environment Name|Description|
|---|---|
|`public`|Default (Azure Public Cloud)|
|`china`|Azure China Cloud|
|`usgovernment`|Azure US Government|
|`german`|Deprecated (was for Azure Germany)|

---

## ⚠️ Optional Behaviors

- `skip_provider_registration`: Skip automatic provider registration (useful for restricted permissions).
    
- `disable_terraform_partner_id`: Remove the Terraform partner tracking ID.
    
- `metadata_host`: Override default metadata host (rare use case).
    
- `auxiliary_tenant_ids`: Used for cross-tenant access (e.g., key vaults in different tenants).
    

---
