
## 🔐 What is a Bastion Host?

A **Bastion Host** is a **secure server** that provides **administrative access (usually via SSH or RDP)** to private instances in your VPC — typically located in **private subnets**.

> 📌 It acts as a **“jump box”** to connect into a **secured private network** from the public internet.

---

## 🧠 Why Use a Bastion Host?

|Problem|Solution|
|---|---|
|You have EC2s in **private subnets** that **shouldn't have public IPs**, but you still need to connect to them for admin or debugging.|Use a **Bastion Host** in a **public subnet** with **SSH access** to jump into private resources.|

---

## 🏗️ Architecture: Bastion Host Setup

```
VPC: 10.0.0.0/16
├── Public Subnet: 10.0.1.0/24
│   └── Bastion Host (EC2, public IP)
│       └── SSH accessible from your IP
│
├── Private Subnet: 10.0.2.0/24
    └── App Server (EC2, NO public IP)
        └── Only accepts SSH from Bastion Host
```

---

## 🔐 How Bastion Host Works

### Steps:

1. You SSH into **Bastion Host** (public IP).
    
2. From the Bastion, you SSH into **private EC2s** using their **private IPs**.
    
3. Private EC2s don’t have public exposure — making the setup more secure.
    

---

## 🛡️ Security Group Configuration

### ✅ Bastion Host SG:

- **Inbound**:
    
    - Port `22` (SSH) → Your IP only (`x.x.x.x/32`)
        
- **Outbound**:
    
    - Port `22` → private subnet CIDR (e.g., `10.0.2.0/24`)
        

### ✅ Private EC2 SG:

- **Inbound**:
    
    - Port `22` → only **Bastion Host's security group**
        
- **Outbound**:
    
    - Allow all (or based on need)
        

---

## 💻 SSH Example

```bash
# 1. SSH into Bastion (public IP)
ssh -i my-key.pem ec2-user@<bastion-public-ip>

# 2. From Bastion, SSH into private EC2
ssh -i my-key.pem ec2-user@10.0.2.123
```

> ⚠️ Ensure both EC2s use the same key pair or you have both private keys on Bastion.

---

## 🏗️ Best Practices

|Practice|Why It Matters|
|---|---|
|Use IAM roles for EC2|Avoid hardcoding credentials|
|Enable logging (Session Manager, SSM)|Audit access|
|Use security group referencing|Avoid using CIDR blocks for internal access|
|Limit SSH source IPs|Only allow your office or VPN IP|
|Rotate keys|Periodically for better security|
|Use Amazon EC2 Instance Connect or SSM|Avoid Bastion entirely in secure environments|

---

## 🧠 Bastion Host vs Other Access Methods

|Option|Pros|Cons|
|---|---|---|
|Bastion Host|Simple, widely used|Requires key management & hardening|
|EC2 Instance Connect|No key required, IAM-controlled|Works only for Amazon Linux, Ubuntu|
|Systems Manager (SSM)|Agent-based, no SSH needed|Needs IAM, SSM Agent + proper setup|
|VPN Gateway|Access whole private network|More setup cost and complexity|

---

## 🧰 Bonus: Use SSH Agent Forwarding

If your private EC2 uses a different key that only exists on your local machine:

```bash
# On your local machine:
ssh-add my-private-key.pem

# SSH with agent forwarding
ssh -A ec2-user@<bastion-public-ip>
ssh ec2-user@10.0.2.123  # From inside Bastion
```

---

## 🧠 Summary

|Term|Description|
|---|---|
|Bastion Host|Public EC2 that acts as a jump server|
|Use Case|Securely access EC2 in private subnet|
|Protocol|SSH (Linux), RDP (Windows)|
|Location|Public subnet (with EIP)|
|Security|Hardened access, least privilege, audit trails|

---
