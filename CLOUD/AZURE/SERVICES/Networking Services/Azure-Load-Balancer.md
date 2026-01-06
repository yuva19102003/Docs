
## ⚖️ What is Azure Load Balancer?

**Azure Load Balancer** is a **Layer 4 (Transport Layer - TCP/UDP)** load balancer that **distributes incoming traffic** across **multiple Azure resources** (like virtual machines) for **high availability and reliability**.

> It works at **TCP/UDP level**, unlike Application Gateway which works at HTTP/HTTPS (Layer 7).

---

## 📚 Table of Contents

1. Azure Load Balancer Overview
    
2. Types of Azure Load Balancer
    
3. Key Components
    
4. Real-World Use Cases
    
5. Load Balancer vs Application Gateway
    
6. Step-by-Step Setup (Portal & CLI)
    
7. Health Probes
    
8. High Availability Ports
    
9. Best Practices
    
10. Interview Questions
    

---

## 1️⃣ Azure Load Balancer Overview

|Feature|Description|
|---|---|
|Layer|L4 (TCP/UDP)|
|Protocol|TCP/UDP|
|Routing|Port-based|
|Modes|Public / Internal|
|HA|Spreads traffic among VMs in a backend pool|
|Cost|Free (Basic), Pay for data (Standard)|

---

## 2️⃣ Types of Load Balancer

|Type|Description|Use Case|
|---|---|---|
|**Public**|Exposes frontend IP to the internet|Inbound access to VMs|
|**Internal**|Uses private IP inside VNet|Internal app tiers, private services|
|**Basic SKU**|Legacy, no zone redundancy, limited|Dev/test|
|**Standard SKU**|Secure, scalable, supports availability zones|Production-grade apps|

---

## 3️⃣ Key Components

|Component|Description|
|---|---|
|**Frontend IP**|Public or Private IP exposed to client|
|**Backend Pool**|Set of VMs or NICs to receive traffic|
|**Health Probe**|Checks availability of backend instances|
|**Load Balancing Rule**|Defines mapping between frontend and backend (port/protocol)|
|**Inbound NAT Rules**|Allow direct access to backend VMs (e.g., RDP/SSH)|

---

## 4️⃣ Real-World Use Cases

|Scenario|Description|
|---|---|
|Web App Behind LB|Distribute HTTP traffic across multiple web servers|
|Internal Microservices|Use Internal LB for backend services|
|Active/Passive Failover|Use health probe for detecting node health|
|NAT Access|Use inbound NAT for SSH/RDP to backend VMs|

---

## 5️⃣ Load Balancer vs Application Gateway

|Feature|Load Balancer|App Gateway|
|---|---|---|
|Layer|4 (TCP/UDP)|7 (HTTP/HTTPS)|
|Protocol Aware|❌|✅|
|Path Routing|❌|✅|
|SSL Termination|❌|✅|
|WAF|❌|✅|
|Use Case|Any TCP/UDP app|Web apps (HTTP/S)|

---

## 6️⃣ Step-by-Step Setup

### ✅ Using Azure Portal (Public LB)

1. Go to **Create → Load Balancer**
    
2. Choose:
    
    - SKU: Standard
        
    - Type: Public
        
    - Frontend IP: Create new Public IP
        
3. Create **Backend Pool**
    
    - Add your VMs
        
4. Create **Health Probe**
    
    - Port: 80 (or any running service)
        
5. Create **Load Balancing Rule**
    
    - Frontend: Port 80
        
    - Backend: Port 80
        
    - Probe: Use created probe
        

---

### 💻 Azure CLI Example

```bash
# 1. Create public IP
az network public-ip create \
  --resource-group myRG \
  --name myPublicIP \
  --sku Standard

# 2. Create Load Balancer
az network lb create \
  --resource-group myRG \
  --name myLoadBalancer \
  --public-ip-address myPublicIP \
  --frontend-ip-name myFrontend \
  --backend-pool-name myBackendPool \
  --sku Standard

# 3. Add VMs to backend pool
az network nic ip-config address-pool add \
  --address-pool myBackendPool \
  --ip-config-name ipconfig1 \
  --nic-name myNic1 \
  --resource-group myRG \
  --lb-name myLoadBalancer \
  --frontend-ip-name myFrontend

# 4. Create Health Probe
az network lb probe create \
  --resource-group myRG \
  --lb-name myLoadBalancer \
  --name myHealthProbe \
  --protocol tcp \
  --port 80

# 5. Create Load Balancing Rule
az network lb rule create \
  --resource-group myRG \
  --lb-name myLoadBalancer \
  --name httpRule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name myFrontend \
  --backend-pool-name myBackendPool \
  --probe-name myHealthProbe
```

---

## 7️⃣ Health Probes

|Probe Type|Used For|
|---|---|
|TCP|Checks TCP connectivity|
|HTTP|Checks app health via HTTP 200 OK|
|HTTPS|Secure health probe|

Health probe removes unhealthy VMs from the backend pool automatically.

---

## 8️⃣ High Availability Ports

- **HA Ports** allow **all TCP/UDP traffic** from a single rule.
    
- Use with **Internal Load Balancer** for **SQL AlwaysOn, NVA scenarios**.
    

Example use:

```bash
az network lb rule create \
  --name allPortsRule \
  --load-distribution Default \
  --protocol All \
  --frontend-port 0 \
  --backend-port 0 \
  --enable-tcp-reset true
```

---

## 9️⃣ Best Practices

|Practice|Description|
|---|---|
|Use Standard SKU|More secure, zone redundant|
|Use availability sets or zones|For HA of backend pool VMs|
|Use custom health probes|Validate app-specific health (e.g., HTTP 200)|
|Avoid Basic SKU for production|No autoscaling, no security features|
|Use NAT rules for RDP/SSH|Access individual VMs securely|
|Monitor with Azure Monitor + Log Analytics|For traffic visibility|

---
