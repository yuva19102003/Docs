
## 🔐 What is Azure VPN Gateway?

**Azure VPN Gateway** is a **networking service** that enables you to **send encrypted traffic between an Azure virtual network and your on-premises location**, or between Azure VNets, over the public Internet.

> It uses **IPsec/IKE** (Internet Key Exchange) protocols for secure communication.

---

## 📚 Table of Contents

1. What is Azure VPN Gateway?
    
2. Key Features
    
3. Architecture Diagram
    
4. Types of Azure VPN Connections
    
5. VPN Gateway SKUs
    
6. Step-by-Step Setup (Portal & CLI)
    
7. VPN Gateway vs VNet Peering vs ExpressRoute
    
8. Best Practices
    
9. Interview Questions
    

---

## 1️⃣ Overview of Azure VPN Gateway

|Feature|Description|
|---|---|
|Function|Encrypts traffic between Azure VNets or between Azure and on-premises|
|Protocols|IKEv2, IPsec, OpenVPN|
|Supports|Point-to-site, Site-to-site, VNet-to-VNet|
|Tunnel Type|IPSec VPN (Route-based or Policy-based)|
|Gateway Type|VPN (other: ExpressRoute)|
|Deployment|Requires **GatewaySubnet** in a VNet|

---

## 2️⃣ Key Features

|Feature|Description|
|---|---|
|Site-to-Site VPN|Connect on-prem network to Azure|
|Point-to-Site VPN|Individual client computers to Azure|
|VNet-to-VNet VPN|Connect VNets across regions|
|BGP Support|Dynamic routing between networks|
|Active-Active Mode|Two VPN tunnels for high availability|
|VPN Client|For Windows, macOS, and Linux (P2S)|

---

## 3️⃣ Architecture Diagram

```
+--------------------+              +----------------------+
| On-Prem Network    |              |   Azure Virtual Network |
| (Firewall + Router)| < VPN >  |     + GatewaySubnet     |
+--------------------+              |     + VPN Gateway        |
                                     +----------------------+
```

---

## 4️⃣ Types of Azure VPN Connections

|Type|Description|Use Case|
|---|---|---|
|**Site-to-Site (S2S)**|Connects Azure to on-premises|Enterprise WAN extension|
|**Point-to-Site (P2S)**|Connects single client to Azure VNet|Developer or remote user access|
|**VNet-to-VNet**|Connects VNets in same or different regions|Multi-region Azure apps|
|**Multi-Site**|Connects multiple on-prem sites|Global offices|

---

## 5️⃣ VPN Gateway SKUs

|SKU|Max Tunnels|Throughput (approx)|Features|
|---|---|---|---|
|**Basic**|10|~100 Mbps|Dev/test only|
|**VpnGw1–5**|10–30+|650 Mbps – 10 Gbps|Production use|
|**HighPerf**|More|Up to 10 Gbps|Large-scale workloads|
|**Zone-redundant**|Yes|Yes|For HA across zones|

🔸 All SKUs support BGP (except Basic)  
🔸 Active-active available in VpnGw2+ SKUs

---

## 6️⃣ Step-by-Step Setup

### ✅ Using Azure Portal (S2S VPN)

#### Step 1: Create Virtual Network + GatewaySubnet

- Name: `myVNet`
    
- Add subnet: `GatewaySubnet` (e.g., 10.0.255.0/27)
    

#### Step 2: Create Public IP for Gateway

#### Step 3: Create VPN Gateway

- Type: VPN
    
- SKU: VpnGw1+
    
- Region must match VNet
    
- Assign GatewaySubnet + Public IP
    

#### Step 4: Create Local Network Gateway

- Represents on-prem network
    
- Add your on-prem public IP and address space
    

#### Step 5: Create Connection

- Connection type: Site-to-site (IPSec)
    
- Link Azure VPN Gateway ↔ Local Network Gateway
    
- Add shared key (must match on both ends)
    

---

### 💻 Azure CLI Example

```bash
# 1. Create VNet and GatewaySubnet
az network vnet create \
  --name myVNet \
  --resource-group myRG \
  --location eastus \
  --address-prefix 10.1.0.0/16 \
  --subnet-name GatewaySubnet \
  --subnet-prefix 10.1.255.0/27

# 2. Create Public IP for VPN Gateway
az network public-ip create \
  --name myVNetGatewayIP \
  --resource-group myRG \
  --allocation-method Dynamic

# 3. Create VPN Gateway
az network vnet-gateway create \
  --name myVNetGateway \
  --resource-group myRG \
  --vnet myVNet \
  --public-ip-address myVNetGatewayIP \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw1 \
  --no-wait

# 4. Create Local Network Gateway (your on-prem router)
az network local-gateway create \
  --name myOnPremGateway \
  --resource-group myRG \
  --gateway-ip-address 203.0.113.1 \
  --local-address-prefixes 192.168.0.0/16

# 5. Create VPN connection
az network vpn-connection create \
  --name myConnection \
  --resource-group myRG \
  --vnet-gateway1 myVNetGateway \
  --local-gateway2 myOnPremGateway \
  --shared-key Azure123
```

---

## 7️⃣ VPN Gateway vs VNet Peering vs ExpressRoute

|Feature|VPN Gateway|VNet Peering|ExpressRoute|
|---|---|---|---|
|Encryption|✅ (IPSec)|❌ (uses Azure backbone)|✅ (optional)|
|Cost|Medium|Low|High|
|Uses Public Internet|✅|❌|❌|
|Supports On-Prem|✅|❌|✅|
|Speed|Medium|High|Very High|
|Best For|Hybrid cloud, secure remote|Intra-Azure networking|Mission-critical workloads|

---

## 8️⃣ Best Practices

|Tip|Why|
|---|---|
|Always use `GatewaySubnet`|Mandatory for VPN gateway|
|Use BGP for dynamic routing|More scalable than static routes|
|Use Active-Active mode for HA|Avoid single point of failure|
|Use Network Watcher for diagnosis|Troubleshoot VPN connectivity|
|Use proper shared keys|Ensure both sides match|
|Monitor VPN health with Log Analytics|Detect disconnections early|

---
