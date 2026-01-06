
## 🌐 What is AWS Site-to-Site VPN?

**AWS Site-to-Site VPN** establishes a secure **IPSec VPN connection** between your **on-premises network (data center or office)** and your **Amazon VPC** over the internet.

> ✅ It creates an **encrypted tunnel** using **IPSec** — traffic is securely transmitted even though it travels over the public internet.

---

## 🎯 Use Case Examples

|Scenario|Reason to Use|
|---|---|
|Connect AWS VPC to on-premises network|Secure hybrid cloud setup|
|Backup local workloads to AWS|S3 or Glacier backup over VPN|
|Extend on-prem AD/LDAP to AWS|Directory Services integration|
|Run part of your services in AWS|Secure resource access between sites|

---

## 🧱 Key Components

|Component|Description|
|---|---|
|**Customer Gateway (CGW)**|Your **on-premises** side (router or firewall) — physical or virtual device|
|**Virtual Private Gateway (VGW)**|AWS side — logical VPN gateway attached to your VPC|
|**VPN Connection**|IPSec tunnel between VGW and CGW (includes 2 tunnels for redundancy)|
|**Route Table Updates**|So traffic from AWS VPC knows to route to the VPN|

---

## 📡 Architecture Overview

```
      ┌──────────────┐       Encrypted IPSec       ┌──────────────┐
      │ On-premises  │◀──────────────────────────▶│   AWS VGW     │
      │ Router (CGW) │          Tunnel 1 & 2       │ (VPN Gateway)│
      └──────────────┘                             └────┬──────────┘
                                                        │
                                                  ┌─────▼─────┐
                                                  │   VPC     │
                                                  │ Subnets   │
                                                  └───────────┘
```

---

## 🛠️ Step-by-Step Setup

### ✅ 1. Create a **Virtual Private Gateway (VGW)**

- Go to **VPC > VPN > Virtual Private Gateways**
    
- Create VGW
    
- Attach it to your VPC
    

```bash
aws ec2 create-vpn-gateway --type ipsec.1
aws ec2 attach-vpn-gateway --vpn-gateway-id vgw-abc123 --vpc-id vpc-xyz456
```

---

### ✅ 2. Create a **Customer Gateway (CGW)**

- You need:
    
    - Your **public static IP** of the on-prem router
        
    - Routing type: **static** or **BGP**
        
- Go to **VPC > Customer Gateways > Create**
    

```bash
aws ec2 create-customer-gateway \
  --type ipsec.1 \
  --public-ip 203.0.113.12 \
  --bgp-asn 65000 \
  --device-name "MyOfficeRouter"
```

---

### ✅ 3. Create the **VPN Connection**

- Choose:
    
    - Customer Gateway (created above)
        
    - Virtual Private Gateway (attached to your VPC)
        
    - Static or BGP routing
        
- AWS automatically provisions **two tunnels** for high availability
    

```bash
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-abc123 \
  --vpn-gateway-id vgw-xyz456 \
  --options '{"StaticRoutesOnly": true}'
```

---

### ✅ 4. Configure Your **On-Prem Device (CGW)**

- Download the **VPN configuration** file from AWS (supports Cisco, Juniper, Fortigate, pfSense, etc.)
    
- Import or manually configure:
    
    - Tunnel 1 & 2 IPs
        
    - Pre-shared keys
        
    - Encryption/authentication settings
        
    - Static or BGP routes
        

> 📥 You can find the config in:  
> **VPN > Your Connection > Download Configuration**

---

### ✅ 5. Add **Static Routes or BGP Routes**

If using **static routing**:

```bash
aws ec2 create-vpn-connection-route \
  --vpn-connection-id vpn-abc123 \
  --destination-cidr-block 10.0.0.0/16
```

---

### ✅ 6. Update Your **VPC Route Table**

- Route traffic to your on-prem network through the **VPN Gateway**
    
- Example: `192.168.1.0/24 → Target: vgw-abc123`
    

---

### ✅ 7. Configure **Security Groups and NACLs**

- Allow relevant traffic (e.g., SSH, HTTP, custom app ports)
    
- Ensure on-prem firewall/router also allows those ports
    

---

## 🔐 Security and Encryption

|Layer|Protocol|Notes|
|---|---|---|
|Tunnel|IPSec|AES-128 or AES-256|
|Auth|SHA-2, pre-shared keys or certificates||
|Redundancy|2 tunnels auto-created|Failover happens automatically|

---

## 🧠 Important Concepts

|Term|Description|
|---|---|
|**Tunnel**|An individual IPSec connection (2 per VPN by default)|
|**Pre-shared key (PSK)**|Used for authentication between CGW and VGW|
|**Dead Peer Detection**|Ensures automatic tunnel failover|
|**BGP**|Dynamic routing; auto-adapts to route changes|
|**Static Routing**|You manually configure destination CIDRs|

---

## ⚙️ Monitoring VPN Connection

- **CloudWatch**: Tunnel state, bytes in/out, latency, packet drop
    
- **Tunnel Status**: Green (up), Red (down), Yellow (partially up)
    
- Enable **VPC Flow Logs** to inspect actual traffic
    

---

## ⚠️ Limitations

|Limitation|Detail|
|---|---|
|Internet dependency|Traffic goes over the public internet|
|Throughput limit|~1.25 Gbps per tunnel (soft limit)|
|No support for transitive routing|Must peer or use TGW|
|No ECMP support on VGW|Unlike Transit Gateway|

---

## ✅ Best Practices

|Practice|Why|
|---|---|
|Use **2 tunnels**|For high availability|
|Use **CloudWatch Alarms** on tunnel state|Alert on disconnection|
|Use **BGP** where possible|Handles dynamic failover/routing|
|Set **VPC Flow Logs** and log VPN traffic|For audit and debugging|
|Use **Transit Gateway** if connecting multiple sites|Easier management and scalability|

---

## 🔚 TL;DR Summary

|Feature|Value|
|---|---|
|What it is|IPSec VPN between AWS VPC & on-prem|
|Components|CGW, VGW, VPN connection|
|Tunnels|2 for HA|
|Routing options|Static or BGP|
|Traffic encryption|IPSec AES-128/256|
|Monitoring|CloudWatch + Flow Logs|
|Alternative for scale|Transit Gateway VPN|

---
