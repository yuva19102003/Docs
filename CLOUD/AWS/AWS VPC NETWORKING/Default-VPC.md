
## 🏗️ What is a **Default VPC** in AWS?

The **default VPC** is a **pre-created, ready-to-use network** that AWS sets up **automatically** in each AWS Region when you create an AWS account.

> 📌 It’s there to make it easier for users to **launch EC2 instances and other resources quickly** without needing to set up networking manually.

---

## 📦 Features of a Default VPC

|Feature|Description|
|---|---|
|CIDR Block|`172.31.0.0/16` (can accommodate 65,536 IPs)|
|Subnets|One **public subnet per Availability Zone** in the region|
|Internet Gateway|Attached automatically, allowing internet access|
|Route Table|Default route (`0.0.0.0/0`) points to Internet Gateway|
|Security Group|Default SG allows **inbound traffic from same SG** and **all outbound**|
|Network ACL|Stateless, allows all inbound/outbound by default|
|DNS Resolution|Enabled (so instances can resolve names)|

---

## 📁 Default VPC Structure (in a single region)

```
Default VPC: 172.31.0.0/16
│
├── Subnet A: 172.31.0.0/20 (AZ a)
├── Subnet B: 172.31.16.0/20 (AZ b)
├── Subnet C: 172.31.32.0/20 (AZ c)
│   └── All subnets are public (route to IGW)
│
├── Internet Gateway (attached)
├── Route Table: 0.0.0.0/0 → IGW
├── Default Security Group
└── Default Network ACL
```

---

## ✅ Use Cases for Default VPC

|Use Case|Why It's Useful|
|---|---|
|Quick EC2 deployment|Launch instances with public IPs instantly|
|Testing and learning|No need to create a custom VPC manually|
|Small dev/test environments|Faster setup for demos or proof of concepts|

---

## ⚠️ Limitations of Default VPC

|Limitation|Description|
|---|---|
|No private subnets|All default subnets are public (not suitable for secure apps)|
|Limited customization|CIDR range, subnet sizes, naming are fixed unless modified|
|Not production-ready|Lacks NAT, private subnets, custom routing, etc.|
|Can be accidentally deleted|While recoverable, it's best to avoid using it for production|

---

## 🔁 Recovering a Deleted Default VPC

If you deleted it:

### 📌 Use AWS Console:

1. Go to **VPC dashboard**
    
2. Click **"Actions" > "Create Default VPC"**
    

### 📌 Use AWS CLI:

```bash
aws ec2 create-default-vpc
```

---

## 🔧 Should You Use the Default VPC?

|Scenario|Recommendation|
|---|---|
|Quick test/dev|✅ Yes, default VPC is fine|
|Production|❌ No, use custom VPC with proper design|
|Learning AWS|✅ Great for experimenting|

---

## 🧱 Default VPC vs Custom VPC

|Feature|Default VPC|Custom VPC|
|---|---|---|
|CIDR Block|`172.31.0.0/16`|You define|
|Subnets|One per AZ (public)|You define (public + private)|
|NAT Gateway|❌ Not included|✅ Optional|
|Custom Routing|❌ Limited|✅ Full control|
|Use Case|Dev/Test|Production|

---

## 🧠 Summary

- Default VPC = AWS-created network per region
    
- CIDR: `172.31.0.0/16`
    
- Subnets: 1 public subnet per AZ
    
- Includes: IGW, route table, SG, NACL
    
- Great for quick use/testing
    
- **Avoid in production** → build a custom VPC
    

---
