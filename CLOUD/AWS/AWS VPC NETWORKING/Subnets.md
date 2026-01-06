
## 📦 What is a Subnet?

A **subnet (subnetwork)** is a smaller **division of a VPC's IP address range (CIDR block)**.

> It allows you to **group and isolate resources** (like EC2 instances) within a **smaller, controlled portion** of your network.

---

## 📚 Example:

If your VPC has the CIDR: `10.0.0.0/16`  
You can create subnets like:

- `10.0.1.0/24` → Public subnet
    
- `10.0.2.0/24` → Private subnet
    

Each subnet has:

- A **route table**
    
- Optionally, access to **internet/NAT**
    
- **Availability Zone (AZ)** location
    

---

## 🧠 Why Use Subnets?

| Purpose              | Benefit                                   |
| -------------------- | ----------------------------------------- |
| Public vs Private    | Control internet access                   |
| Security             | Apply different NACLs and security groups |
| High Availability    | Deploy across multiple AZs                |
| Network Segmentation | Separate apps, DBs, monitoring, etc.      |

---

## 🧰 Types of Subnets

| Type         | Internet Access | Route to Internet Gateway | Example Resources     |
| ------------ | --------------- | ------------------------- | --------------------- |
| **Public**   | ✅ Yes           | ✅ Yes                     | Web servers, ALBs     |
| **Private**  | ❌ No (direct)   | ❌ (uses NAT instead)      | DB, backend services  |
| **Isolated** | ❌ No            | ❌ None                    | Highly sensitive data |

---

## 🏗️ Subnet in AWS VPC

Let’s say:

- VPC: `10.0.0.0/16`
    
- AZs: `us-east-1a`, `us-east-1b`
    

### You create:

| Subnet Name    | CIDR          | AZ           | Type    |
| -------------- | ------------- | ------------ | ------- |
| PublicSubnet1  | `10.0.1.0/24` | `us-east-1a` | Public  |
| PrivateSubnet1 | `10.0.2.0/24` | `us-east-1a` | Private |
| PublicSubnet2  | `10.0.3.0/24` | `us-east-1b` | Public  |
| PrivateSubnet2 | `10.0.4.0/24` | `us-east-1b` | Private |

> You must **attach route tables** and **IGWs/NAT Gateways** accordingly.

---

## 🌐 How to Make a Subnet "Public"?

✅ Must meet **ALL**:

1. Subnet's route table has `0.0.0.0/0 → Internet Gateway`
    
2. Subnet is in VPC with an **attached IGW**
    
3. EC2 has **public IP** (enabled in subnet or manually assigned)
    

---

## 🔒 How to Make a Subnet "Private"?

✅ Must meet:

1. **No route to IGW**
    
2. For internet **egress**, must use:
    
    - NAT Gateway (managed, preferred)
        
    - NAT Instance (older approach)
        

---

## 🧮 Subnet Sizing

Subnet size is defined by CIDR:

- `/24` = 256 IPs (254 usable)
    
- `/25` = 128 IPs
    
- `/26` = 64 IPs
    
- `/28` = 16 IPs (AWS uses 5 for system, only 11 usable)
    

> ⚠️ **AWS reserves 5 IPs per subnet**:

```
.0 → Network
.1 → VPC router
.2 → DNS
.3 → Reserved
.255 → Broadcast
```

---

## 🛠️ CLI: Create Subnet Example

```bash
aws ec2 create-subnet \
  --vpc-id vpc-0abc12345 \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a
```

---

## 🔁 Subnet Best Practices

✅ Always:

- Use **multiple AZs** for HA
    
- Create **smaller subnets** to avoid waste
    
- Separate **public, private, DB** subnets
    
- Use **NAT Gateway** for private subnets to access the internet
    
- Tag subnets clearly: `Environment=Prod`, `Type=Private`, etc.
    

---

## ✅ Summary Table

| Term           | Meaning                                  |
| -------------- | ---------------------------------------- |
| VPC            | Virtual Private Cloud                    |
| Subnet         | Segment of VPC CIDR                      |
| Public Subnet  | Has route to Internet Gateway            |
| Private Subnet | No direct route to internet              |
| NAT Gateway    | Allows private subnet outbound internet  |
| IGW            | Enables internet access to public subnet |

---

## 📊 Visual Diagram (Simplified)

```
VPC: 10.0.0.0/16
│
├── Public Subnet (10.0.1.0/24)
│    └── EC2 (has public IP)
│    └── Route: 0.0.0.0/0 → IGW
│
├── Private Subnet (10.0.2.0/24)
     └── EC2 (no public IP)
     └── Route: 0.0.0.0/0 → NAT Gateway
```

---
