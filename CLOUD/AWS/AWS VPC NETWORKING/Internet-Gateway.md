
## 🌐 What is an **Internet Gateway** (IGW)?

An **Internet Gateway** is a **horizontally-scaled, redundant AWS-managed gateway** that allows your resources (like EC2 instances) in a **VPC** to connect to the **internet**.

It enables:

- **Outbound traffic**: EC2 to internet
    
- **Inbound traffic**: Internet to EC2 (if allowed by security)
    

---

## 🏗️ How Internet Access Works in AWS

For an EC2 instance to reach the internet, **ALL** these must be true:

|Component|Must Be Present ✅|
|---|---|
|**Internet Gateway**|Attached to the VPC|
|**Route Table**|Has `0.0.0.0/0` → IGW route|
|**Subnet**|Associated with above route table|
|**Public IP / EIP**|Instance must have one|
|**Security Group**|Must allow HTTP, SSH, etc.|
|**NACL**|Must allow traffic|

---

## 📚 Example Architecture

```
VPC: 10.0.0.0/16
│
├── Subnet: 10.0.1.0/24 (Public)
│   ├── EC2 instance (public IP)
│   └── Route table: 0.0.0.0/0 → Internet Gateway
│
└── Internet Gateway (IGW)
```

---

## ⚙️ How to Create and Attach an IGW

### ✅ Using AWS Console

1. Go to **VPC Dashboard**
    
2. Click **Internet Gateways > Create Internet Gateway**
    
3. Give it a name
    
4. Click **Attach to VPC**, select your VPC
    

---

### ✅ Using AWS CLI

```bash
# Create IGW
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=MyIGW}]'

# Attach it to your VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id igw-0abc12345678 \
  --vpc-id vpc-0123456789abcdef0
```

---

## 🔁 Route Table Example (to connect public subnet to IGW)

```bash
aws ec2 create-route \
  --route-table-id rtb-0123456789abcde \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id igw-0abc12345678
```

---

## 🛡️ Security Considerations

|Area|Rule|
|---|---|
|Security Group|Must allow inbound traffic (e.g., port 80, 443, 22)|
|NACL|Should allow desired inbound and outbound ports|
|Public IP|EC2 must have a public IP or Elastic IP|

---

## 🚫 What IGW **does not** do

- It **doesn’t NAT** private IPs. For that, use **NAT Gateway** or **NAT Instance**.
    
- It doesn’t apply any **firewall or filtering** — that's the job of **Security Groups and NACLs**.
    

---

## ✅ Internet Gateway vs NAT Gateway

|Feature|Internet Gateway|NAT Gateway|
|---|---|---|
|Purpose|Connect **public subnets** to internet|Allow **private subnets** to access internet|
|Inbound Traffic|✅ Allowed|❌ Blocked|
|Public IP Needed?|✅ Yes (on EC2)|❌ No (uses NAT IP)|
|Cost|Free|Paid (hourly + GB data)|

---

## 🧠 Summary

|Item|Description|
|---|---|
|What is IGW?|Connects VPC to the internet|
|Required for public?|✅ Yes, must route 0.0.0.0/0 → IGW|
|Public IP needed?|✅ Instance must have one|
|IGW cost|Free|
|CLI Create Steps|`create-internet-gateway`, `attach-internet-gateway`|
|Common Mistake|Not adding IGW route in route table|

---
