
## 🌐 What is Azure DNS?

**Azure DNS** is a **Domain Name System (DNS) hosting service** that lets you host your **DNS domains** and manage **DNS records** using **Azure infrastructure**.

> It translates **human-readable domain names** (like `myapp.com`) into IP addresses (like `52.161.10.5`) to route traffic properly.

---

## 📚 Table of Contents

1. What is DNS? (Quick Recap)
    
2. What is Azure DNS?
    
3. Key Features
    
4. Azure DNS Types
    
5. Supported DNS Record Types
    
6. Hands-On Setup (Portal & CLI)
    
7. Custom Domain Mapping (Azure Web Apps)
    
8. Azure Private DNS
    
9. Best Practices
    
10. Interview Questions
    

---

## 1️⃣ What is DNS? (Quick Recap)

- **DNS** = Phonebook of the internet
    
- Maps domain names to IP addresses
    
- Works with **recursive** and **authoritative** name servers
    

---

## 2️⃣ What is Azure DNS?

Azure DNS allows you to:

- Host **public or private DNS zones**
    
- Manage DNS records with Azure CLI, PowerShell, REST
    
- Use **role-based access control (RBAC)** and **activity logs**
    

✅ **Low latency**  
✅ **Global reach**  
✅ **Secure & reliable**

---

## 3️⃣ Key Features

|Feature|Description|
|---|---|
|Public & Private DNS Zones|Support for internal and external name resolution|
|Record Management|A, AAAA, CNAME, MX, TXT, etc.|
|Azure Integration|VMs, App Services, Traffic Manager|
|Role-based Access|Control DNS using Azure RBAC|
|Fast Resolution|Powered by Azure’s global network of name servers|
|Monitoring|Activity logs, alerts, diagnostics|

---

## 4️⃣ Azure DNS Types

|Type|Description|Use Case|
|---|---|---|
|**Public DNS Zone**|DNS zone accessible from internet|Host public website or API|
|**Private DNS Zone**|Internal-only DNS within a VNet|Resolve internal VM names securely|

---

## 5️⃣ Supported DNS Record Types

|Record Type|Description|Example|
|---|---|---|
|**A**|Maps name to IPv4|`app.contoso.com` → `192.168.1.1`|
|**AAAA**|Maps name to IPv6|`app.contoso.com` → `2607:f8b0::1`|
|**CNAME**|Alias to another domain|`www.contoso.com` → `contoso.com`|
|**MX**|Mail server|For email routing|
|**TXT**|Text data|SPF, DKIM|
|**NS**|Name server|Delegation of zones|
|**PTR**|Reverse DNS|IP to domain name|
|**SRV**|Service location|Skype, LDAP|

---

## 6️⃣ Hands-On: Create a Public DNS Zone

### ✅ Azure Portal

1. Go to **DNS Zones** → **Create**
    
2. Enter:
    
    - Name: `example.com`
        
    - Resource group
        
3. Create records (e.g., A, CNAME)
    

### 💻 Azure CLI

```bash
# Create a DNS zone
az network dns zone create \
  --name example.com \
  --resource-group myRG

# Create an A record
az network dns record-set a add-record \
  --zone-name example.com \
  --resource-group myRG \
  --record-set-name www \
  --ipv4-address 52.160.10.10

# Create a CNAME record
az network dns record-set cname set-record \
  --zone-name example.com \
  --resource-group myRG \
  --record-set-name blog \
  --cname contoso.azurewebsites.net
```

---

## 7️⃣ Custom Domain Mapping (e.g., for App Service)

If you're using Azure Web App (`app.azurewebsites.net`) and want to map `www.myapp.com`:

1. Add a **CNAME** record in Azure DNS:
    
    ```text
    www → app.azurewebsites.net
    ```
    
2. Go to App Service → **Custom domains** → Add `www.myapp.com`
    
3. Validate DNS & bind it.
    

---

## 8️⃣ Azure Private DNS Zones

|Feature|Description|
|---|---|
|Internal-only name resolution||
|Uses VNet link to associate||
|Automatically resolves Azure VM names||
|No need for custom DNS servers||

### Example:

1. Create private zone: `internal.contoso.com`
    
2. Link it to your VNet
    
3. Add A record: `web1 → 10.1.1.4`
    
4. VMs in the VNet can now use `web1.internal.contoso.com`
    

---

## 9️⃣ Best Practices

|Practice|Why|
|---|---|
|Use Azure DNS for global reliability|Fast resolution using Azure’s DNS infrastructure|
|Use CNAME for web apps|Easier to change endpoints|
|Use Private DNS for internal services|Secure name resolution inside VNets|
|Use RBAC|Control who can edit DNS records|
|Enable DNS zone logging|Audit and monitor changes|

---
