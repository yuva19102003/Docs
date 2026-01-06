
## 🌉 What is **VPC Peering**?

**VPC Peering** is a **network connection between two VPCs** that enables you to **route traffic between them using private IP addresses** — as if they were part of the same network.

> ✅ **Fully private, AWS-managed, no public internet involved**

---

## 🎯 Why Use VPC Peering?

|Use Case|Benefit|
|---|---|
|Microservices split across VPCs|Private communication|
|Separate VPCs for environments (Dev/Prod)|Segregation + secure access|
|VPCs in different accounts|Cross-account secure communication|
|AWS Organizations setup|Centralized services via peering|

---

## 📦 Key Characteristics

|Feature|Description|
|---|---|
|Connection Type|Point-to-point (VPC-to-VPC)|
|Scope|Same or different regions/accounts|
|Internet usage|❌ No — uses private IPs only|
|Transitive Routing Support|❌ No — not supported (A ↔ B, B ↔ C ≠ A ↔ C)|
|CIDR Overlap Allowed?|❌ No — both VPCs must have **non-overlapping CIDRs**|
|Peering Direction|Must accept on other side (2-way handshake)|

---

## 🛠️ Example Setup

|VPC|CIDR Block|Region|
|---|---|---|
|VPC-A (App)|`10.0.0.0/16`|`us-east-1`|
|VPC-B (DB)|`192.168.0.0/16`|`us-east-1`|

✅ You create a peering connection and update route tables like this:

### 📡 Routes:

- In **VPC-A's route table**: `192.168.0.0/16 → peering connection`
    
- In **VPC-B's route table**: `10.0.0.0/16 → peering connection`
    

---

## 🧱 Steps to Create VPC Peering

### ✅ 1. Using AWS Console:

1. Go to **VPC > Peering Connections**
    
2. Click **Create Peering Connection**
    
3. Choose:
    
    - Requester's VPC
        
    - Accepter's VPC (can be cross-account with Account ID + VPC ID)
        
4. Click **Create**
    
5. On other side, click **Accept Request**
    
6. Edit **Route Tables** on both VPCs to allow private communication
    
7. (Optional) Adjust **Security Groups** to allow traffic between VPCs
    

---

### ✅ 2. Using AWS CLI

```bash
# Create peering connection
aws ec2 create-vpc-peering-connection \
  --vpc-id vpc-aaaa1111 \
  --peer-vpc-id vpc-bbbb2222 \
  --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=App-DB-Peer}]'

# Accept the connection
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id pcx-0123456789abcdef0

# Update route tables
aws ec2 create-route \
  --route-table-id rtb-aaaa1111 \
  --destination-cidr-block 192.168.0.0/16 \
  --vpc-peering-connection-id pcx-0123456789abcdef0
```

---

## 🔐 Security Group + NACL Setup

You must also **explicitly allow traffic** in **Security Groups and NACLs**:

### ✅ Security Group Rule Example (VPC-A EC2):

```text
Inbound:
 - Allow TCP 3306 (MySQL) from `192.168.0.0/16`
```

---

## 🚫 Limitations of VPC Peering

|Limitation|Detail|
|---|---|
|❌ No transitive routing|A ↔ B, B ↔ C ≠ A ↔ C|
|❌ No overlapping CIDR blocks|CIDRs must be unique|
|❌ Can’t connect to Transit GW|Use Transit Gateway for complex networks|
|❌ Max connections per VPC: 125|As of 2025 (may vary per region)|

---

## 📊 VPC Peering vs Other Options

|Feature|VPC Peering|Transit Gateway|PrivateLink|
|---|---|---|---|
|Pattern|Point-to-point|Hub-and-spoke|Service consumer model|
|Transitive Routing|❌ No|✅ Yes|❌ No|
|Scale|1:1|1:Many|1:1|
|Use Case|App ↔ DB|Shared services|Expose services privately|
|CIDR Overlap Support|❌ No|✅ Yes (via TGW)|✅ Yes|
|Cross-account/region|✅ Yes|✅ Yes|✅ Yes|

---

## ✅ Best Practices

|Best Practice|Reason|
|---|---|
|Use non-overlapping CIDRs|Required for peering|
|Tag all resources|For cost allocation and management|
|Monitor with VPC Flow Logs|Helps debug traffic between VPCs|
|Use VPC endpoints instead when possible|Saves cost, avoids complexity|
|Consider Transit Gateway for large scale|For >10+ VPCs, Transit GW is more scalable|

---

## 🎨 Diagram: VPC Peering Setup

```
         VPC-A (10.0.0.0/16)
         ┌───────────────┐
         │   EC2/App     │
         └─────┬─────────┘
               │
         [ VPC Peering ]
               │
         ┌─────┴─────────┐
         │   EC2/DB      │
         └───────────────┘
         VPC-B (192.168.0.0/16)
```

---

## ✅ TL;DR Summary

|Feature|Description|
|---|---|
|What is it?|Private connection between two VPCs|
|CIDR restriction|❌ Overlap not allowed|
|Transitive traffic|❌ Not supported|
|Route table needed?|✅ Yes, both VPCs must update routes|
|Security Groups?|✅ Must allow traffic explicitly|
|Cost|Free (charges only for data transfer)|
|Alternatives|Transit Gateway, AWS PrivateLink|

---
