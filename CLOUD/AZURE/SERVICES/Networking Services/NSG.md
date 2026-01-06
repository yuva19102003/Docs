
## 🔐 What is an NSG (Network Security Group)?

An **NSG** is a **firewall-like resource** in Azure that controls **inbound and outbound network traffic** to and from **Azure resources** in a **Virtual Network (VNet)**.

> Think of it as a **cloud version of an access control list (ACL)** — used to secure communication between subnets, NICs (VMs), and internet.

---

## 📚 Table of Contents

1. What Can NSGs Do?
    
2. NSG vs Azure Firewall
    
3. NSG Rule Components
    
4. Default NSG Rules
    
5. Where Can You Apply NSGs?
    
6. NSG with ASG (Application Security Group)
    
7. NSG Hands-On: Create via Portal & CLI
    
8. Real-World Examples
    
9. Troubleshooting NSG Issues
    
10. NSG Best Practices
    
11. Interview Questions
    

---

## 1️⃣ What Can NSGs Do?

|Feature|Description|
|---|---|
|Allow/Deny traffic|Based on IP, port, protocol|
|Inbound/Outbound|Separate rules for each direction|
|Scope|VM NIC and/or Subnet|
|Granular control|Based on source/destination|
|Logging|NSG Flow Logs (via NSG Diagnostic Settings)|

---

## 2️⃣ NSG vs Azure Firewall

|Feature|NSG|Azure Firewall|
|---|---|---|
|Layer|Network layer (Layer 3/4)|Application + Network (Layer 3–7)|
|Use Case|Basic traffic filtering|Centralized security, FQDN, threat intel|
|Cost|Free|Paid|

---

## 3️⃣ NSG Rule Components

|Component|Description|
|---|---|
|**Name**|Unique name for the rule|
|**Priority**|Number from 100–4096 (lower = higher priority)|
|**Direction**|Inbound / Outbound|
|**Protocol**|TCP / UDP / Any|
|**Source / Destination**|CIDR, IP, ASG, or Tag (e.g. Internet, VirtualNetwork)|
|**Port**|80, 443, *|
|**Action**|Allow or Deny|

---

## 4️⃣ Default NSG Rules

Every NSG has built-in rules (lowest priority):

|Priority|Name|Direction|Action|Description|
|---|---|---|---|---|
|65000|AllowVNetInBound|Inbound|Allow|Within same VNet|
|65001|AllowAzureLoadBalancerInBound|Inbound|Allow|Health probes|
|65500|DenyAllInbound|Inbound|Deny|Everything else|
|65000|AllowVNetOutBound|Outbound|Allow|To VNet|
|65500|DenyAllOutbound|Outbound|Deny|Everything else|

---

## 5️⃣ Where Can You Apply NSGs?

|Level|Applies To|
|---|---|
|Subnet|Affects all resources in that subnet|
|NIC|Affects individual VM NICs (overrides subnet NSG)|

> If both **subnet and NIC NSGs** are used, **both must allow** the traffic.

---

## 6️⃣ NSG with ASG (Application Security Group)

**ASG = Logical group of VMs**, used in NSG rules.

Example:

```text
Allow traffic from ASG: WebServers → ASG: AppServers on port 443
```

You don't need to specify IPs — just manage VMs in ASG.

---

## 7️⃣ Hands-On: Creating an NSG

### ✨ Azure Portal

1. Go to **"Network Security Groups"** → **Create**
    
2. Enter:
    
    - Name: `web-nsg`
        
    - Resource Group
        
    - Region
        
3. After creation, add rules:
    
    - **Inbound Rule**:
        
        - Name: `Allow-HTTP`
            
        - Priority: `100`
            
        - Port: `80`
            
        - Source: `Any`
            
        - Action: `Allow`
            
4. Associate it with:
    
    - Subnet or
        
    - VM Network Interface (NIC)
        

---

### 💻 Azure CLI

```bash
# Create NSG
az network nsg create \
  --resource-group my-rg \
  --name web-nsg

# Create inbound rule to allow HTTP
az network nsg rule create \
  --resource-group my-rg \
  --nsg-name web-nsg \
  --name allow-http \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-range 80 \
  --source-address-prefix '*' \
  --destination-address-prefix '*'

# Associate NSG with subnet
az network vnet subnet update \
  --vnet-name my-vnet \
  --name web-subnet \
  --resource-group my-rg \
  --network-security-group web-nsg
```

---

## 8️⃣ Real-World NSG Rules Example

|Priority|Name|Direction|Source|Destination|Port|Action|
|---|---|---|---|---|---|---|
|100|Allow-SSH|Inbound|Internet|VM|22|Allow|
|110|Allow-HTTP|Inbound|Internet|VM|80|Allow|
|200|Deny-All|Inbound|Any|Any|*|Deny|

---

## 9️⃣ Troubleshooting NSG Issues

|Symptom|Possible Fix|
|---|---|
|VM unreachable|NSG blocks port (check Inbound)|
|Can't SSH to VM|Port 22 not allowed|
|Can't access Web App|NSG missing rule for port 80/443|
|Internal VM can't reach DB|Check both subnet and NIC NSG|

Use:

```bash
az network watcher security-group-view ...
```

---

## 🔟 Best Practices

- 🧠 **Name rules clearly** (e.g., `Allow-HTTPS-From-AppTier`)
    
- 📊 **Enable NSG Flow Logs** for auditing
    
- 🧱 Use **ASGs** to simplify rule management
    
- ✅ Apply NSG at **subnet level** unless special case
    
- 🔍 Periodically **review unused rules**
    

---
