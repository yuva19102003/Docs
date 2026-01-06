
## 🔥 What is Azure Firewall?

**Azure Firewall** is a **cloud-native, stateful, Layer 4 and Layer 7 firewall service** built for highly secure and scalable network traffic filtering in Azure.

> It **centrally controls and logs traffic** across VNets and Azure services using rules for IPs, ports, protocols, and even FQDNs.

---

## 📚 Table of Contents

1. Overview of Azure Firewall
    
2. Features and Capabilities
    
3. Azure Firewall vs NSG vs WAF
    
4. Real-World Architecture Diagram
    
5. Types of Firewall Rules
    
6. How DNAT, SNAT Work
    
7. Hands-on Setup (Portal & CLI)
    
8. Monitoring & Logging
    
9. Best Practices
    
10. Interview Questions
    

---

## 1️⃣ Azure Firewall Overview

|Feature|Description|
|---|---|
|Type|Stateful, fully managed|
|Layers|L3 (IP), L4 (TCP/UDP), L7 (FQDN, HTTP/S)|
|High Availability|Built-in|
|Scale|Auto scales throughput|
|Logging|Full logging with Azure Monitor, Log Analytics|
|Deployment|Must be in a **dedicated subnet named `AzureFirewallSubnet`**|

---

## 2️⃣ Key Features

|Feature|Description|
|---|---|
|**Network Rules**|Filter by IPs, ports, protocols|
|**Application Rules**|Allow/Deny access by FQDN or domain|
|**DNAT**|Expose internal services to the internet|
|**SNAT**|Outbound internet access for private subnets|
|**Threat Intelligence**|Block traffic from known malicious IPs|
|**Forced Tunneling**|Route all traffic through Firewall (even to internet)|

---

## 3️⃣ Azure Firewall vs NSG vs WAF

|Feature|Azure Firewall|NSG|WAF|
|---|---|---|---|
|Layer|3–7|3–4|7|
|Stateful|✅|✅|❌|
|Protocol Aware|TCP/UDP/FQDN/HTTP|TCP/UDP|HTTP/S only|
|Outbound Control|✅|❌|❌|
|Threat Protection|✅|❌|✅ (only for web apps)|
|Use Case|Central security|Local subnet filtering|App-layer protection|

---

## 4️⃣ Architecture Diagram

```
       Internet
          │
    ┌─────▼─────┐
    │ Azure Firewall │
    └─────┬─────┘
          │
     ┌────▼────┐
     │ Hub VNet│  ← AzureFirewallSubnet
     └────┬────┘
          │
 ┌────────▼────────┐
 │ Spoke VNets (App, DB) │ ← Peered to Hub
 └───────────────────┘
```

> Use **Hub-and-Spoke** model for enterprise networks.

---

## 5️⃣ Firewall Rule Types

|Rule Type|Description|Use Case|
|---|---|---|
|**Network Rule**|IP, protocol, port|Allow RDP to VM|
|**Application Rule**|FQDN, HTTP/S|Allow `*.microsoft.com`|
|**NAT Rule**|Translate IP/port|Expose VM to internet|

---

## 6️⃣ DNAT & SNAT

### 🔄 DNAT (Destination NAT)

- Maps **public IP → private IP**
    
- Use for **publishing services** to the internet
    

> Example: Allow `20.50.50.1:3389` → `10.0.0.4:3389` (RDP)

### 🔁 SNAT (Source NAT)

- Allows outbound internet access from **private subnets**
    
- Uses Azure Firewall’s **public IP**
    

---

## 7️⃣ Hands-On Setup

### ✅ Azure Portal

1. **Create Virtual Network**
    
    - Add subnet: `AzureFirewallSubnet`
        
2. **Create Azure Firewall**
    
    - Choose public IP
        
    - Assign to `AzureFirewallSubnet`
        
3. **Create Route Table**
    
    - Add route: `0.0.0.0/0 → Azure Firewall IP`
        
    - Associate with subnets
        
4. **Create Rules**
    
    - Network Rule: Allow TCP/UDP by IP/Port
        
    - Application Rule: Allow FQDNs
        
    - DNAT Rule: Map public IP → VM IP
        

---

### 💻 Azure CLI Example

```bash
# Create resource group and VNet
az group create --name fw-rg --location eastus

az network vnet create \
  --name fw-vnet \
  --resource-group fw-rg \
  --address-prefix 10.0.0.0/16 \
  --subnet-name AzureFirewallSubnet \
  --subnet-prefix 10.0.1.0/24

# Create public IP for firewall
az network public-ip create \
  --name fw-pip \
  --resource-group fw-rg \
  --sku Standard \
  --location eastus

# Create Azure Firewall
az network firewall create \
  --name myFirewall \
  --resource-group fw-rg \
  --location eastus

# Attach public IP
az network firewall ip-config create \
  --firewall-name myFirewall \
  --name fw-config \
  --public-ip-address fw-pip \
  --resource-group fw-rg \
  --vnet-name fw-vnet

# Create rule collection
az network firewall network-rule create \
  --firewall-name myFirewall \
  --resource-group fw-rg \
  --collection-name allow-web \
  --name allow-http \
  --rule-type NetworkRule \
  --priority 100 \
  --action Allow \
  --protocols TCP \
  --source-addresses 10.0.0.0/24 \
  --destination-addresses 20.50.50.1 \
  --destination-ports 80
```

---

## 8️⃣ Monitoring & Logging

- Enable **Diagnostic Settings**:
    
    - Send logs to **Log Analytics**, **Storage**, or **Event Hub**
        
- Log types:
    
    - `AzureFirewallApplicationRule`
        
    - `AzureFirewallNetworkRule`
        
    - `AzureFirewallDnsProxy`
        

Query example in Log Analytics:

```kusto
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule"
| where action_s == "Deny"
```

---

## 9️⃣ Best Practices

|Practice|Reason|
|---|---|
|Use Standard SKU|Basic is deprecated|
|Use in Hub VNet|Enables central control|
|Use custom DNS with DNS proxy|For name-based outbound rules|
|Use route tables (UDR)|Force all traffic via Firewall|
|Use Threat Intelligence in Alert or Deny mode|Block malicious IPs|
|Always log and monitor|Audit traffic and detect misconfigurations|

---
