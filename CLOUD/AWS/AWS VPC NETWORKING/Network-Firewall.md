
## 🔥 What is AWS Network Firewall?

**AWS Network Firewall** is a **stateful, managed network security service** that provides **deep packet inspection**, **domain filtering**, **custom rule engines**, and **IDS/IPS** capabilities — **at the VPC level**.

> ✅ Think of it as a **next-gen firewall** service designed for **centralized traffic inspection** in **east-west (VPC to VPC)** and **north-south (internet/VPN)** traffic.

---

## 🧱 Key Features

|Feature|Description|
|---|---|
|🔍 **Deep packet inspection**|Inspect Layer 3–7 traffic|
|✅ **Stateful & Stateless Rules**|Allow, deny, alert based on traffic patterns|
|🌐 **Domain-based filtering**|Block or allow domains (FQDN filtering)|
|🧠 **Threat detection**|Suricata-based IDS/IPS engine|
|🔐 **TLS Inspection**|(Planned/limited) — decrypt traffic for inspection|
|🏗️ **Managed service**|AWS handles HA, scaling, patches|

---

## 🧠 Where Is It Used?

You deploy it **inside a VPC**, in an **inspection subnet**, and route traffic through it using a **Gateway Load Balancer (GWLB)** or **VPC routing**.

Use it for:

|Traffic Type|Example Use Cases|
|---|---|
|North-South|Internet to/from VPC|
|East-West|VPC to VPC (via Transit Gateway)|
|Hybrid Cloud|VPN or Direct Connect inspection|
|Egress Control|Only allow known safe domains/IPs outbound|

---

## 🧠 AWS Network Firewall vs Other Tools

|Feature|Security Group|NACL|Network Firewall|
|---|---|---|---|
|Level|Instance/ENI|Subnet|VPC edge / centralized|
|Stateful|✅|❌ (stateless)|✅ (with stateless too)|
|Layer 7 filtering|❌|❌|✅ (FQDN, HTTP/HTTPS)|
|Custom signatures|❌|❌|✅ (Suricata rules)|
|DNS filtering|❌|❌|✅|
|Logging|Basic flow logs|Flow logs|✅ Full flow + alert logs|

---

## 🛠️ Key Components

|Component|Description|
|---|---|
|**Firewall Policy**|Collection of stateless/stateful rules|
|**Rule Group**|Reusable group of rules (can be Suricata-based)|
|**Firewall**|The actual instance applied to a subnet|
|**Logging Configuration**|Send logs to CloudWatch Logs, S3, or Kinesis|
|**Endpoint (ENI)**|AWS automatically manages endpoints in inspection subnets|

---

## 🏗️ How to Deploy AWS Network Firewall (Step-by-Step)

### ✅ Step 1: Create Rule Groups

- Stateless rule group: Match based on IP/port/protocol
    
- Stateful rule group: Use Suricata syntax or AWS managed rules
    

Example (Suricata-like):

```bash
alert http any any -> any any (msg:"Block evil domain"; content:"badsite.com"; sid:1000001;)
```

---

### ✅ Step 2: Create a Firewall Policy

- Attach the rule groups
    
- Define default action (drop/allow)
    
- Choose stateless vs stateful actions
    

---

### ✅ Step 3: Deploy Network Firewall

- Go to **VPC > Network Firewall > Create Firewall**
    
- Choose:
    
    - VPC
        
    - Subnets (1 per AZ) → These act as **inspection subnets**
        
    - Attach firewall policy
        

> 🔄 AWS creates **endpoints** in these subnets for traffic routing.

---

### ✅ Step 4: Route Traffic Through the Firewall

You must **explicitly route traffic** through Network Firewall:

#### 🛣️ Option 1: VPC Route Table Changes

- For example:
    
    - `0.0.0.0/0 → firewall endpoint`
        
- Used for **egress control** from private subnets
    

#### 🧰 Option 2: With Transit Gateway

- Attach the firewall to a **separate VPC**
    
- Route **TGW traffic** through this VPC for inspection
    
- Works well for **east-west** inspection across environments
    

#### 🧪 Option 3: With Gateway Load Balancer

- Use for **advanced inspection**, **3rd party firewalls**, or inline EC2 appliances
    

---

## 🎯 Example Use Cases

|Use Case|What to Do|
|---|---|
|Block access to `*.xyz` domains|Use stateful rule group with FQDN deny|
|Allow only whitelisted domains|Use allow-only Suricata rules|
|Block known malware IPs|Use Suricata threat intelligence feed or managed rule set|
|Monitor outbound traffic|Enable full flow and alert logging to CloudWatch|

---

## 📊 Logging Options

|Destination|Use Case|
|---|---|
|**CloudWatch Logs**|Realtime logs, dashboards, alerts|
|**S3**|Long-term archive, Athena queries|
|**Kinesis**|Streaming to SIEM or alerting pipeline|

---

## 💸 Pricing

|Component|Cost Model|
|---|---|
|Network Firewall Endpoint|Per AZ/per hour (e.g., ~$0.395/hr)|
|Traffic Inspection|Per GB processed|
|Rule Group Usage|Free unless using 3rd-party rules|
|Logging|CloudWatch/S3/Kinesis costs apply|

> 🧮 Firewall per AZ + traffic volume can affect cost significantly.

---

## ✅ Best Practices

|Best Practice|Reason|
|---|---|
|Use **VPC subnets dedicated to firewall**|Keep inspection separate and scalable|
|Combine with **Transit Gateway**|Scalable, centralized security|
|Separate **dev/stage/prod policies**|Avoid cross-contamination|
|Use **managed rule groups** for threats|Stay up-to-date with known threats|
|Enable **flow & alert logging**|For full visibility, compliance|

---

## 🆚 Comparison: Network Firewall vs WAF vs Security Group

|Feature|Network Firewall|AWS WAF|Security Group|
|---|---|---|---|
|Layer|3–7|Layer 7 (HTTP/S)|Layer 3–4|
|Stateful|✅|✅|✅|
|Application-specific|✅ (via Suricata rules)|✅ (HTTP only)|❌|
|Web protection|❌|✅ (SQLi, XSS, etc.)|❌|
|Internet vs VPC|VPC-wide|Internet-facing only|EC2 only|

---

## 🔚 Summary

|Feature|Description|
|---|---|
|What is it?|Managed network-level firewall for VPC traffic|
|Works at|VPC egress/ingress (via route table or TGW)|
|Rules|Stateless (5-tuple) and stateful (Suricata)|
|Ideal for|Egress control, hybrid inspection, east-west filtering|
|Logging|S3, CloudWatch, Kinesis|
|Compared to WAF/Security Groups|More advanced, centralized, packet-level filtering|

---
