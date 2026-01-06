
## 🌐 What is Azure Application Gateway?

**Azure Application Gateway** is a **Layer 7 (HTTP/HTTPS)** load balancer that routes web traffic based on **URL path**, **host headers**, **session affinity**, and **SSL termination**.

It includes a **built-in Web Application Firewall (WAF)** to protect against OWASP Top 10 attacks.

---

## 📚 Table of Contents

1. What is Azure Application Gateway?
    
2. Key Features
    
3. What is WAF (Web Application Firewall)?
    
4. Architecture Diagram
    
5. Use Cases
    
6. Deployment Modes
    
7. Step-by-Step Setup (Portal & CLI)
    
8. Application Gateway vs Azure Load Balancer
    
9. Best Practices
    
10. Interview Questions
    

---

## 1️⃣ Azure Application Gateway – Overview

|Feature|Description|
|---|---|
|Layer|7 (Application layer)|
|Protocols|HTTP, HTTPS|
|Routing|URL path-based, host-based|
|SSL Offloading|Yes|
|Autoscaling|Yes (Standard_v2/WAF_v2 SKU)|
|Web Application Firewall|Integrated (WAF SKU)|

---

## 2️⃣ Key Features

|Feature|Description|
|---|---|
|**URL-based Routing**|`/images/` → backend pool A, `/videos/` → backend pool B|
|**Host-based Routing**|`app1.com` → Pool A, `app2.com` → Pool B|
|**SSL Termination**|Decrypt HTTPS at gateway|
|**Cookie-based Session Affinity**|Sticky sessions|
|**Custom Probes**|Health checks for backend|
|**Autoscaling**|Dynamically adjusts instances|
|**WAF**|Protects against common threats (XSS, SQLi, etc.)|

---

## 3️⃣ What is Azure WAF?

**WAF (Web Application Firewall)** protects your web apps from **OWASP Top 10 vulnerabilities**, including:

- SQL Injection
    
- Cross-site Scripting (XSS)
    
- Remote File Inclusion
    
- Command Injection
    

> WAF is enabled at **Application Gateway** level using the **WAF SKU**.

### 🔐 WAF Modes

|Mode|Description|
|---|---|
|Detection|Logs threats, does not block|
|Prevention|Logs + blocks malicious traffic|

### 🧠 WAF Rulesets

- Based on **OWASP Core Rule Set (CRS)**: e.g., 3.2, 3.1
    
- You can enable/disable specific rules
    

---

## 4️⃣ Architecture Diagram

```
          ┌─────────────┐
Internet ─▶ App Gateway ├────────▶ Web App 1 (Path: /app1)
          │ + WAF       ├────────▶ Web App 2 (Path: /app2)
          └─────────────┘
                   │
          Azure VNet + Subnet
```

---

## 5️⃣ Real-World Use Cases

|Use Case|Description|
|---|---|
|Multi-website Hosting|Route different domains to different backends|
|Web App Protection|Block common attacks with WAF|
|Central SSL Offload|Decrypt HTTPS at gateway|
|Blue-Green Deployment|Route traffic based on paths|
|Global Load Balancing|Combine with Azure Front Door or Traffic Manager|

---

## 6️⃣ Deployment Modes

|Mode|Description|
|---|---|
|Standard_v2 / WAF_v2|Recommended, supports autoscaling & zone redundancy|
|WAF SKU|Enables Web Application Firewall|
|Public|Exposes App Gateway to Internet|
|Private|Use with Private IP only (for internal use)|

---

## 7️⃣ Step-by-Step Setup

### ✅ Azure Portal

#### Step 1: Create App Gateway

- Go to **"Application Gateway"** → **Create**
    
- SKU: **WAF_v2**
    
- Enable **autoscaling** (optional)
    
- Public or private IP
    
- Create **Frontend IP**, **Backend Pool**, **Listeners**, **Rules**
    

#### Step 2: Enable WAF

- Go to **"Web Application Firewall"** tab
    
- Enable WAF
    
- Set to **Prevention** or **Detection**
    
- Choose **OWASP rule set**
    

#### Step 3: Add Routing Rules

- Listener: e.g., `listener-https`
    
- Routing Rule: `/app1/*` → backend pool A  
    `/app2/*` → backend pool B
    

---

### 💻 Azure CLI Example

```bash
# Create public IP
az network public-ip create \
  --name myAppGatewayPIP \
  --resource-group myRG \
  --allocation-method Static \
  --sku Standard

# Create Application Gateway
az network application-gateway create \
  --name myAppGateway \
  --location eastus \
  --resource-group myRG \
  --sku WAF_v2 \
  --capacity 2 \
  --frontend-port 443 \
  --http-settings-protocol Https \
  --public-ip-address myAppGatewayPIP \
  --vnet-name myVNet \
  --subnet mySubnet \
  --waf-policy-type Managed \
  --waf-policy-mode Prevention
```

---

## 8️⃣ Application Gateway vs Load Balancer

|Feature|App Gateway|Load Balancer|
|---|---|---|
|Layer|7 (HTTP/S)|4 (TCP/UDP)|
|Routing|URL/path/host|Port-based|
|SSL Offload|✅|❌|
|WAF|✅|❌|
|Use Case|Web apps|Any TCP/UDP app|

---

## 9️⃣ Best Practices

|Practice|Reason|
|---|---|
|Use WAF_v2 SKU|Supports autoscaling, zones|
|Use Custom Probes|Ensure app health accurately|
|Enable WAF Logging|Diagnostic logs to Log Analytics|
|Separate App Gateway subnet|Must be isolated|
|Use HTTPS with SSL termination|Improve security|
|Use Path-based rules for microservices|Clean and scalable routing|

---
