
# 🔐 Authentication Methods for Azure

Authenticating to Azure involves verifying your identity (user or application) and granting access to Azure resources based on your credentials. Here are the main methods to authenticate to Azure:

- 🔵 Azure CLI
    
- 🆔 Managed Service Identity
    
- 📜 Service Principal + Client Certificate
    
- 🔑 Service Principal + Client Secret
    
- 🪪 Service Principal + OpenID Connect
    
- 🐳 AKS Workload Identity
    

---

## 🔵 Azure CLI

Prior to version 3.44, authenticating via the Azure CLI was only supported using a **User Account**. From 3.44+, **Service Principal** and **Managed Identity** are also supported.

### Logging into the Azure CLI

> Note: If you're using the **China** or **Government** Azure Clouds, configure it with:

```bash
az cloud set --name AzureChinaCloud
# or
az cloud set --name AzureUSGovernment
```

---

### Login Options

**User Account:**

```bash
az login
```

**Service Principal with Client Secret:**

```bash
az login --service-principal -u "CLIENT_ID" -p "CLIENT_SECRET" --tenant "TENANT_ID"
```

**Service Principal with Certificate:**

```bash
az login --service-principal -u "CLIENT_ID" -p "CERTIFICATE_PEM" --tenant "TENANT_ID"
```

**Service Principal with Open ID Connect (OIDC):**

```bash
az login --service-principal -u "CLIENT_ID" --tenant "TENANT_ID"
```

**Managed Identity (System/User Assigned):**

```bash
az login --identity
# or
az login --identity --username "CLIENT_ID"
```

---

### Set Subscription

```bash
az account list
az account set --subscription="SUBSCRIPTION_ID"
```

---

## 🆔 Managed Service Identity (System-Assigned)

Managed identities allow Azure resources to authenticate to services that support Azure AD without storing credentials.

### How It Works

- Uses **Azure Instance Metadata Service (IMDS)** to provide tokens to applications.
    
- No credentials stored on the VM.
    
- Lifecycle tied to the Azure resource.
    

---

### Lifecycle

1. **Creation**: Azure AD auto-generates identity when enabled.
    
2. **Service Principal**: Tied to a service principal for RBAC.
    
3. **Deletion**: Identity is deleted when the resource is deleted.
    

---

### Setup Steps

1. Assign appropriate RBAC role (e.g., Contributor).
    
2. Configure resource access (e.g., Key Vault, Storage).
    
3. Use `az login --identity` for token acquisition.
    

---

### Permissions Required

You must have either:

- **Owner**
    
- Or **Contributor + User Access Administrator**
    

---

## 📜 Service Principal + Client Certificate

This method is highly secure and avoids secrets. Ideal for automated workflows like Terraform in enterprise environments.

---

### 1. Generate a Certificate

```bash
openssl req -subj '/CN=myclientcertificate/O=MyCompany, Inc./ST=CA/C=US' \
  -new -newkey rsa:4096 -sha256 -days 730 -nodes -x509 \
  -keyout client.key -out client.crt

openssl pkcs12 -export -password pass:"Pa55w0rd123" \
  -out client.pfx -inkey client.key -in client.crt
```

---

### 2. Register the Application

- Go to **Azure AD > App Registrations > New Registration**
    
- Save:
    
    - **Application (client) ID**
        
    - **Directory (tenant) ID**
        

---

### 3. Upload Certificate

- Go to **Certificates & Secrets**
    
- Click **Upload Certificate**
    
- Add `.crt` or `.pem` file
    

---

### 4. Assign Role to Service Principal

- Go to **Subscriptions > Access Control (IAM) > Add Role Assignment**
    
- Assign **Contributor** or relevant role
    
- Select your app by name
    

---

## 🔑 Service Principal + Client Secret

This method is widely used in CI/CD pipelines and automation scripts.

---

### Create with Azure CLI

```bash
az login
az account set --subscription="SUBSCRIPTION_ID"

az ad sp create-for-rbac --role="Contributor" \
  --scopes="/subscriptions/SUBSCRIPTION_ID"
```

#### Output:

```json
{
  "appId": "...",
  "displayName": "...",
  "password": "...",
  "tenant": "..."
}
```

---

### Login and Test

```bash
az login --service-principal -u APP_ID -p PASSWORD --tenant TENANT_ID
az vm list-sizes --location westus
```

---

### Create via Azure Portal

1. Go to **Azure AD > App Registrations > New Registration**
    
2. Generate a **Client Secret** under **Certificates & Secrets**
    
3. Assign role via **IAM** in Subscription
    

---

## 🪪 Service Principal + Open ID Connect (OIDC)

OIDC is used for **federated identity authentication**, e.g., GitHub Actions, Azure DevOps.

---

### Steps to Configure

1. **Register an App**:
    
    - Azure AD > App Registrations > New Registration
        
    - Note down **client_id**, **tenant_id**
        
2. **Add Federated Credential**:
    
    - Go to **Certificates & Secrets > Federated Credentials**
        
    - Add a credential (e.g., GitHub repo and branch)
        
3. **Assign RBAC Role**:
    
    - Subscription > IAM > Add Role Assignment
        

---

### GitHub Actions Sample

```yaml
permissions:
  id-token: write
  contents: read
```

---

### Terraform with OIDC

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

---

### Azure CLI REST API for Federated Credential

```bash
az rest --method POST \
  --uri https://graph.microsoft.com/beta/applications/${APP_OBJ_ID}/federatedIdentityCredentials \
  --headers Content-Type='application/json' \
  --body @body.json
```

`body.json` example:

```json
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:owner/repo:ref:refs/heads/main",
  "description": "GitHub Main Branch",
  "audiences": ["api://AzureADTokenExchange"]
}
```

---

## 🐳 AKS Workload Identity

Kubernetes pods running in Azure Kubernetes Service (AKS) can authenticate to Azure services without secrets.

---
### **How It Works**

1. **Service Account & Pod Configuration**:
    
    - A Kubernetes service account is linked to an Azure AD identity, and this identity is assigned to pods.
    - At runtime, the pod receives a federated identity token and environment variables (like `AZURE_CLIENT_ID` and `AZURE_TENANT_ID`) to authenticate with Azure.
2. **Federated Identity Token**:
    
    - The pod uses this token to authenticate with Azure AD and obtain access tokens for Azure resources.
3. **Access Azure Resources**:
    
    - Pods can securely access Azure resources (e.g., Key Vault, Storage) based on their Azure AD roles.

---

### **Benefits**

- **No Credential Management**: No need to manage secrets within Kubernetes.
- **Secure Access**: Pods authenticate via Azure AD, reducing risks.
- **Centralized Access Control**: Access to Azure resources is managed through Azure AD.

---

### **Configuration Steps**

1. **Enable Managed Identity on AKS**.
2. **Create and link an Azure Identity**.
3. **Assign Azure RBAC roles** for resource access.
4. **Bind Kubernetes service accounts** to the Azure identity.
5. **Deploy pods**, which will authenticate using the injected identity.

---

### Setup Steps

1. Enable **Managed Identity** on AKS
    
2. Create **Azure Identity**
    
3. Assign **RBAC roles**
    
4. Link K8s **ServiceAccount** to Azure Identity
    
5. Deploy pod using that ServiceAccount
    

---

### Use Case Examples

- Accessing Azure Key Vault
    
- Accessing Azure Storage
    
- Accessing Cosmos DB
    

---

### 📌 Security Best Practices

- Prefer **Managed Identities** or **OIDC** over **Client Secrets**
    
- Store certificates in **Azure Key Vault**
    
- Apply **least privilege principle** with RBAC
    
- Rotate credentials regularly
    

---
