
# 🔐 AWS Security: Security Group vs NACL + Ephemeral Ports

---

## 🔷 What is a **Security Group (SG)?**

A **Security Group** is a **stateful virtual firewall** applied at the **ENI (Elastic Network Interface) / instance level**, controlling **inbound and outbound traffic** for AWS resources like EC2, RDS, and Lambda in VPC.

### ✅ Key Characteristics:

|Feature|Value|
|---|---|
|Type|**Stateful** firewall|
|Attached To|**Instances / ENIs / RDS**, etc.|
|Rule Scope|**Only allows** (no deny rules)|
|Rule Direction|Separate for inbound/outbound|
|Response Behavior|Return traffic is **automatically allowed**|
|Default Behavior|Inbound denied, Outbound allowed|

### 🛠️ Security Group Example:

```text
Inbound:
 - Allow TCP 22 from 203.0.113.0/24
 - Allow TCP 80 from 0.0.0.0/0
Outbound:
 - Allow ALL
```

---

## 🔷 What is a **Network ACL (NACL)?**

A **NACL** is a **stateless firewall** applied at the **subnet level**, controlling traffic entering and leaving the subnet.

### ✅ Key Characteristics:

|Feature|Value|
|---|---|
|Type|**Stateless** firewall|
|Attached To|**Subnets**|
|Rule Scope|Can **allow or deny** traffic|
|Rule Direction|Must configure both inbound and outbound|
|Rule Evaluation|Rules evaluated by number (lowest first)|
|Default Behavior|Allow all (you must change this for security)|

---

## 🔁 SG vs NACL Summary

|Feature|Security Group|Network ACL|
|---|---|---|
|Level|Instance/ENI|Subnet|
|Stateful?|✅ Yes|❌ No (stateless)|
|Allow/Deny|Only **allow**|Can **allow and deny**|
|Return Traffic|Allowed automatically|Must allow manually|
|Rule Evaluation|All rules|By rule number (lowest wins)|
|Default Rules|Inbound deny / Outbound allow|Allow all (can customize)|

---

## 🚀 Use Cases

|Scenario|Best Option|
|---|---|
|Control access to EC2 only from VPN|Security Group|
|Block malicious IP across subnet|NACL|
|Split traffic for public/private subnets|Both|
|Fine-grained port control|SG or NACL|

---

# 🔁 🔢 Ephemeral Ports in AWS

## 🧠 What Are Ephemeral Ports?

When an EC2 instance (or client) initiates an **outbound connection** (e.g., to a web server or S3), it uses **temporary random ports** called **ephemeral ports**.

|Term|Value|
|---|---|
|Purpose|Handle client-side response traffic|
|AWS Default|**32768–65535** (Linux)|

> These must be **explicitly allowed in NACLs** to enable return traffic.

---

## 🧰 Why Are Ephemeral Ports Needed in NACLs?

Since **NACLs are stateless**, return traffic from the internet (on ephemeral ports) **won’t be allowed unless you explicitly permit it** in the **inbound rules** of the NACL.

---

## ✅ NACL Example with Ephemeral Ports

### 📤 Outbound Rules (from EC2 in Private Subnet):

|Rule #|Direction|Protocol|Port Range|Destination|Action|
|---|---|---|---|---|---|
|100|Outbound|TCP|443|0.0.0.0/0|ALLOW|
|110|Outbound|TCP|32768–65535|0.0.0.0/0|ALLOW|

### 📥 Inbound Rules (to allow return traffic):

|Rule #|Direction|Protocol|Port Range|Source|Action|
|---|---|---|---|---|---|
|100|Inbound|TCP|32768–65535|0.0.0.0/0|ALLOW|

> 💡 Also add default `* → DENY` for both inbound and outbound as catch-all.

---

## 🧠 Common Mistakes

|Mistake|Fix|
|---|---|
|Only allowing outbound port (e.g., 443)|Also allow **ephemeral range** outbound + inbound|
|Assuming SGs and NACLs are the same|Understand SG = stateful, NACL = stateless|
|Forgetting return path in NACL|Add inbound rule for `32768–65535`|

---

## 🛡️ Best Practices

|Practice|Why It’s Important|
|---|---|
|Use SGs for day-to-day access|Easier to manage, allow-based, stateful|
|Use NACLs to block IPs/subnets|For broader subnet-level security|
|Always allow ephemeral port range in NACLs|Ensures successful return connections|
|Monitor with VPC Flow Logs|Helps troubleshoot dropped packets|
|Tag all SGs/NACLs clearly|For visibility and audit|

---

## 🎨 Full Flow Diagram (Simplified)

```text
          Internet
              ↓
      ┌───────────────┐
      │ Internet Gateway │
      └───────────────┘
              ↓
 ┌────────────────────────────┐
 │ Public Subnet (NACL allows 22, 80, 443) │
 │  └── Bastion / NAT Gateway             │
 └────────────────────────────┘
              ↓
 ┌────────────────────────────┐
 │ Private Subnet (NACL allows 443 out, 32768–65535 in) │
 │  └── App Server (SG allows SSH only from Bastion)    │
 └────────────────────────────┘
```

---

## ✅ TL;DR Summary

|Topic|Key Points|
|---|---|
|Security Groups|Stateful, allow-only, per-instance|
|NACLs|Stateless, allow/deny, per-subnet, rule number ordered|
|Ephemeral Ports|32768–65535 (needed in NACL for return traffic)|
|Combine SG + NACL|For secure, fine-grained VPC traffic control|

---
