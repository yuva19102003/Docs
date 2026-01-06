
## 🌐 What is AWS Direct Connect?

**AWS Direct Connect** (DX) is a **dedicated private network connection** from your **on-premises data center, office, or colocation** facility to AWS.

> ✅ It **bypasses the public internet**, delivering **consistent performance, lower latency**, and **higher bandwidth** with **dedicated network lines**.

---

## 🎯 Why Use Direct Connect?

|Use Case|Benefit|
|---|---|
|Large-scale data transfer to/from AWS|Faster, cheaper per GB, stable bandwidth|
|Hybrid cloud with latency-sensitive applications|Lower and consistent latency|
|Compliance-sensitive workloads|Avoid public internet, increase security|
|BGP-controlled routing|Fine-grained routing and failover control|

---

## 🧱 Key Concepts & Components

|Component|Description|
|---|---|
|**Customer Router (CPE)**|Your on-premises router connected to DX|
|**Direct Connect Location**|AWS DX-enabled colocation data center|
|**AWS Router**|AWS-owned router at the DX location|
|**Virtual Interface (VIF)**|Logical connection into AWS (Public, Private, Transit VIF)|
|**Virtual Private Gateway (VGW)**|Used with Private VIF for VPC connectivity|
|**Transit Gateway**|Used to connect multiple VPCs over Direct Connect|

---

## 🚀 How Direct Connect Works

```
 ┌─────────────┐       Dedicated Fiber        ┌──────────────┐
 │ On-prem CPE │◀───────────────────────────▶│ AWS DX Router│
 └─────────────┘                             └──────┬───────┘
                                                   │
                              ┌────────────────────┴──────────────────┐
                              │         Virtual Interface (VIF)       │
                              │      ┌──────────────┐ ┌─────────────┐ │
                              │      │ Private VIF  │ │ Public VIF  │ │
                              │      └─────┬────────┘ └─────┬───────┘ │
                              │            │                │         │
                       ┌──────▼────┐  ┌────▼────┐     ┌─────▼────┐    │
                       │  VPC      │  │ Transit │     │ AWS S3,  │    │
                       │ (via VGW) │  │ Gateway │     │ DynamoDB │    │
                       └───────────┘  └─────────┘     └──────────┘    │
                              └───────────────────────────────────────┘
```

---

## 💡 Types of Virtual Interfaces (VIFs)

|VIF Type|Use Case|Connects To|
|---|---|---|
|**Private VIF**|Connect to VPC via VGW or Transit Gateway|Private AWS services (e.g. EC2, RDS)|
|**Public VIF**|Connect to public AWS endpoints (S3, DynamoDB)|AWS global services over public IPs|
|**Transit VIF**|Connect to multiple VPCs via Transit Gateway|Large-scale enterprise networking|

---

## 🛠️ Steps to Set Up Direct Connect

### 🔹 Step 1: Request a Connection

- Go to **AWS Console > Direct Connect**
    
- Choose:
    
    - AWS DX Location (e.g., Equinix Mumbai)
        
    - Port speed: 1 Gbps, 10 Gbps, or 100 Gbps
        
    - Either a **dedicated** or **hosted** connection
        

> 🧾 **Hosted connection** is provisioned by AWS Partner (e.g., Tata Comm, Airtel, Megaport)

---

### 🔹 Step 2: Connect to AWS Router

- In colocation center (or via Partner), run a fiber from your CPE to AWS router
    
- Configure **BGP peering**
    

---

### 🔹 Step 3: Create a Virtual Interface (VIF)

- Choose:
    
    - **Private VIF** for VPC access via VGW or Transit GW
        
    - **Public VIF** for public AWS service access
        
    - **Transit VIF** for centralized routing to multiple VPCs
        

---

### 🔹 Step 4: Configure Router (on-prem)

- BGP ASN, peer IPs
    
- Advertise prefixes (CIDR blocks)
    
- Match MTU (typically 1500 or 9001)
    

---

## 📏 Speeds and Pricing

|Type|Speed Options|Notes|
|---|---|---|
|Dedicated|1, 10, 100 Gbps|Available at AWS DX locations|
|Hosted Connection|50 Mbps to 10 Gbps|Provisioned by AWS Partner|
|Billing|Per port-hour + data transferred|No NAT charges like in VPN|

> 💸 **Cheaper per GB** than Site-to-Site VPN over long-term use

---

## 🔐 Direct Connect vs Site-to-Site VPN

|Feature|AWS Direct Connect|Site-to-Site VPN|
|---|---|---|
|Connection Type|Private, dedicated fiber|Over public internet (IPSec)|
|Latency|Low, consistent|Higher, variable|
|Throughput|Up to 100 Gbps|~1.25 Gbps per tunnel|
|Encryption|❌ Not encrypted by default|✅ Encrypted (IPSec)|
|Failover|Needs VPN backup|Built-in HA (2 tunnels)|
|Use Together?|✅ Yes — for hybrid HA|✅ Yes|
|Setup Time|Days to weeks|Minutes|
|Cost|Higher upfront, cheaper long-term|Lower setup, higher transfer costs|

---

## 🧠 Best Practices

|Practice|Reason|
|---|---|
|Use **VPN as backup** to DX|Ensures high availability|
|Monitor **BGP session health**|Detect connection issues early|
|Aggregate multiple VPCs via **Transit GW**|Simplifies routing|
|Enable **CloudWatch metrics**|For usage, latency, throughput visibility|
|Validate **MTU compatibility**|Avoid packet drops or fragmentation|
|Set **IAM and NACL restrictions**|For granular security control|

---

## ✅ TL;DR Summary

|Feature|Description|
|---|---|
|What is it?|Dedicated private link to AWS from on-prem|
|Speed|50 Mbps to 100 Gbps|
|Types of VIF|Public, Private, Transit|
|Bypasses internet?|✅ Yes|
|Encryption|❌ No (can add IPSec over DX)|
|Use with VPC?|✅ Yes (via VGW or Transit GW)|
|Use with VPN?|✅ Yes, for redundancy|
|Common use cases|Hybrid cloud, low latency apps, big data|

---
