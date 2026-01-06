
## 🔗 What is VNet Peering?

**Virtual Network Peering** connects **two Azure VNets**, enabling them to **communicate privately over Azure’s backbone** without using a public IP, VPN, or gateway.

> Think of it as a **direct, private highway** between two VNets.

---

## 📚 Table of Contents

1. What is VNet Peering?
    
2. VNet Peering vs VNet Gateway
    
3. Types of Peering
    
4. Use Cases
    
5. Step-by-Step Setup (Portal & CLI)
    
6. Peering Across Subscriptions & Regions
    
7. Limitations
    
8. Security Considerations
    
9. Best Practices
    
10. Interview Questions
    

---

## 1️⃣ Why VNet Peering?

- Establish **low-latency, high-bandwidth** connectivity
    
- **Secure** communication within Azure
    
- Cheaper and faster than VPN or ExpressRoute
    

---

## 2️⃣ VNet Peering vs VNet Gateway

|Feature|VNet Peering|VNet-to-VNet via Gateway|
|---|---|---|
|Speed|Very fast (Azure backbone)|Slower (uses gateway)|
|Encryption|Not encrypted by default|Encrypted (IPsec)|
|Cost|Low (data transfer)|Higher (gateway cost)|
|Setup Complexity|Simple|Complex|
|Transitive Routing|❌ (manual workaround)|✅|

---

## 3️⃣ Types of VNet Peering

|Type|Description|
|---|---|
|**Intra-region**|VNets in the same region|
|**Global Peering**|VNets in different Azure regions|
|**Cross-subscription Peering**|Between VNets in different Azure subscriptions|

---

## 4️⃣ Use Cases

- Microservices across VNets
    
- Shared services hub (DNS, firewall, AD)
    
- On-prem → Hub → Spoke routing
    
- Connecting dev/test/prod networks
    

---

## 5️⃣ Step-by-Step Setup

### ✅ Using Azure Portal

1. Go to VNet A → **Peerings** → Add
    
2. Fill:
    
    - Name: `vnetA-to-vnetB`
        
    - Remote VNet: `vnetB`
        
    - Allow forwarded traffic: Yes/No
        
    - Allow gateway transit: Optional
        
3. Repeat the same **on VNet B** (or check "create peering in remote network" if allowed)
    

---

### 💻 Azure CLI

```bash
# Create Peering from VNet A → VNet B
az network vnet peering create \
  --name vnetA-to-vnetB \
  --resource-group RG1 \
  --vnet-name VNetA \
  --remote-vnet /subscriptions/<subB>/resourceGroups/RG2/providers/Microsoft.Network/virtualNetworks/VNetB \
  --allow-vnet-access

# Create reverse Peering from VNet B → VNet A
az network vnet peering create \
  --name vnetB-to-vnetA \
  --resource-group RG2 \
  --vnet-name VNetB \
  --remote-vnet /subscriptions/<subA>/resourceGroups/RG1/providers/Microsoft.Network/virtualNetworks/VNetA \
  --allow-vnet-access
```

---

## 6️⃣ Cross-Region & Cross-Subscription

- **Global peering**: Just check “Allow global peering” during setup.
    
- **Cross-subscription**:
    
    - Peering possible if both subscriptions are under the **same Azure AD tenant**
        
    - Requires contributor role on both VNets
        

---

## 7️⃣ Limitations

|Limitation|Details|
|---|---|
|Transitive peering|❌ Not supported (A ↔ B ↔ C does NOT mean A ↔ C)|
|Same/overlapping CIDRs|❌ Not allowed|
|Default encryption|🔒 Not encrypted (but data stays on Azure backbone)|
|Gateway sharing|✅ Only if explicitly allowed during peering|
|Max peers|~500 per VNet (Standard SKU)|

---

## 8️⃣ Security Considerations

- **Enable Network Security Groups (NSGs)** to restrict unwanted traffic
    
- **Do not allow forwarded traffic** unless necessary
    
- Use **service endpoints + private endpoints** where needed
    
- Use **firewalls in hub networks** if using Hub-Spoke
    

---

## 9️⃣ Best Practices

|Best Practice|Reason|
|---|---|
|Use Hub-Spoke model|Easier to manage shared services|
|Tag VNets & peerings clearly|Improve maintainability|
|Plan CIDRs ahead of time|Avoid overlapping IPs|
|Use NSGs and ASGs|Control traffic at subnet level|
|Monitor peered traffic with NSG flow logs|Gain visibility|

---

## 🔟 Interview Questions

1. **Can two VNets in different regions be peered?**
    
    - ✅ Yes, via Global VNet Peering
        
2. **What happens if IP ranges of VNets overlap?**
    
    - ❌ Peering fails
        
3. **Can peered VNets use each other’s VPN gateway?**
    
    - ✅ If gateway transit is enabled
        
4. **Is traffic encrypted over VNet peering?**
    
    - ❌ Not by default (but stays on Microsoft backbone)
        
5. **Is transitive peering supported?**
    
    - ❌ No. Must peer each VNet explicitly.
        

---
