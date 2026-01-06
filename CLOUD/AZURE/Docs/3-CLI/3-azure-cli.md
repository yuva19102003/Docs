# ☁️ Azure CLI – Full Practical Tutorial

---

## 1️⃣ What is Azure CLI?

Azure CLI (`az`) is a **cross-platform command-line tool** to:

* Create and manage Azure resources
* Automate infrastructure
* Use in CI/CD (GitHub Actions, Azure DevOps)
* Avoid portal clicking

✔ Works on Linux, macOS, Windows
✔ Used heavily in DevOps

---

## 2️⃣ Install Azure CLI

### Linux (Ubuntu / Debian)

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Verify

```bash
az version
```

---

## 3️⃣ Login & Account Basics

### Login

```bash
az login
```

Browser opens → authenticate.

### List Subscriptions

```bash
az account list --output table
```

### Set Default Subscription

```bash
az account set --subscription "<SUBSCRIPTION_ID>"
```

### Show Current Context

```bash
az account show
```

---

## 4️⃣ Resource Groups (Foundation)

### Create Resource Group

```bash
az group create \
  --name rg-pay2chat-dev \
  --location eastus
```

### List Resource Groups

```bash
az group list --output table
```

### Delete Resource Group

```bash
az group delete \
  --name rg-pay2chat-dev \
  --yes --no-wait
```

---

## 5️⃣ App Service (Backend) via Azure CLI

### Create App Service Plan (Linux)

```bash
az appservice plan create \
  --name asp-pay2chat-dev \
  --resource-group rg-pay2chat-dev \
  --sku B1 \
  --is-linux
```

### Create Web App (Node.js)

```bash
az webapp create \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev \
  --plan asp-pay2chat-dev \
  --runtime "NODE|18-lts"
```

### View Web App

```bash
az webapp show \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev
```

---

## 6️⃣ App Settings (Environment Variables)

### Add App Settings

```bash
az webapp config appsettings set \
  --resource-group rg-pay2chat-dev \
  --name pay2chat-backend-dev \
  --settings \
  NODE_ENV=production \
  PORT=8080
```

### List App Settings

```bash
az webapp config appsettings list \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev \
  --output table
```

---

## 7️⃣ Enable Managed Identity (Very Important)

```bash
az webapp identity assign \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev
```

### Verify

```bash
az webapp identity show \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev
```

---

## 8️⃣ Azure Key Vault (CLI-Only Workflow)

### Create Key Vault

```bash
az keyvault create \
  --name kv-pay2chat-dev \
  --resource-group rg-pay2chat-dev \
  --location eastus
```

### Add Secret

```bash
az keyvault secret set \
  --vault-name kv-pay2chat-dev \
  --name DB-CONNECTION-STRING \
  --value "postgres://user:pass@host:5432/db"
```

### Get Secret (manual)

```bash
az keyvault secret show \
  --vault-name kv-pay2chat-dev \
  --name DB-CONNECTION-STRING
```

---

## 9️⃣ Grant Key Vault Access to App Service

### Get Managed Identity Object ID

```bash
az webapp identity show \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev \
  --query principalId \
  --output tsv
```

### Assign Key Vault Policy

```bash
az keyvault set-policy \
  --name kv-pay2chat-dev \
  --object-id <PRINCIPAL_ID> \
  --secret-permissions get list
```

---

## 🔟 Use Key Vault Reference in App Settings

```bash
az webapp config appsettings set \
  --resource-group rg-pay2chat-dev \
  --name pay2chat-backend-dev \
  --settings \
  DB_URL="@Microsoft.KeyVault(SecretUri=https://kv-pay2chat-dev.vault.azure.net/secrets/DB-CONNECTION-STRING/)"
```

✔ No SDK
✔ No secrets in code
✔ Auto rotation

---

## 1️⃣1️⃣ Deployment via Azure CLI (Zip Deploy)

```bash
zip -r app.zip .
```

```bash
az webapp deploy \
  --resource-group rg-pay2chat-dev \
  --name pay2chat-backend-dev \
  --src-path app.zip \
  --type zip
```

---

## 1️⃣2️⃣ Logs & Monitoring

### Stream Logs

```bash
az webapp log tail \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev
```

### Enable Logs

```bash
az webapp log config \
  --name pay2chat-backend-dev \
  --resource-group rg-pay2chat-dev \
  --application-logging filesystem \
  --level information
```

---

## 1️⃣3️⃣ Static Web Apps (CLI)

```bash
az staticwebapp create \
  --name raiden-frontend-dev \
  --resource-group rg-pay2chat-dev \
  --source https://github.com/username/repo \
  --branch Development \
  --app-location "/" \
  --output-location "build"
```

---

## 1️⃣4️⃣ Role-Based Access Control (RBAC)

### Assign Role

```bash
az role assignment create \
  --assignee user@domain.com \
  --role "Contributor" \
  --resource-group rg-pay2chat-dev
```

### List Roles

```bash
az role assignment list --output table
```

---

## 1️⃣5️⃣ Clean-up (Very Important)

```bash
az group delete \
  --name rg-pay2chat-dev \
  --yes --no-wait
```

---

## 1️⃣6️⃣ Azure CLI in GitHub Actions

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Create Resource Group
  run: |
    az group create --name rg-ci-dev --location eastus
```

---

## 1️⃣7️⃣ Must-Know Azure CLI Commands (Cheat Sheet)

```bash
az help
az find "webapp"
az configure --defaults location=eastus
az resource list --output table
az upgrade
```

---

## 1️⃣8️⃣ Real-World Best Practices ⭐

✔ Use CLI for automation
✔ Use Bicep/Terraform for infra-as-code
✔ Never hardcode secrets
✔ Prefer Managed Identity
✔ Use `--output table` for readability
✔ Use `--query` for scripting

---

## What You Should Practice Next

* Deploy App Service **only using CLI**
* Key Vault + Managed Identity via CLI
* CI/CD with Azure CLI
* Automate cleanup scripts
* Combine CLI + Terraform/Bicep

---

