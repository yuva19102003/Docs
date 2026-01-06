
## 🧠 What Is AWS Application Migration Service (MGN)?

**AWS MGN** is a fully managed **lift-and-shift (rehost)** migration tool that **replicates live servers** (physical, virtual, or cloud-based) **to AWS**, allowing you to launch them as EC2 instances with minimal downtime.

> ✅ It uses **continuous block-level replication** and supports **automated testing**, **cutover**, and **rollback**.

---

## 🎯 Why Use AWS MGN?

| Benefit                      | Description                                            |
| ---------------------------- | ------------------------------------------------------ |
| ✅ Minimal downtime           | Continuous replication enables quick cutovers          |
| ✅ Lift-and-shift made simple | No need to redesign or rewrite apps                    |
| ✅ Works across environments  | Migrate from on-prem, VMware, Hyper-V, or other clouds |
| ✅ Automated testing          | Perform launch validations before final cutover        |
| ✅ Cost-efficient             | Pay-as-you-go EC2, storage, and replication charges    |

---

## 🧱 Supported Source Environments

| Environment      | OS Support                                    |
| ---------------- | --------------------------------------------- |
| VMware/Hyper-V   | Windows Server, Linux (Red Hat, Ubuntu, etc.) |
| Physical servers | Windows/Linux                                 |
| Other clouds     | Azure, GCP, other AWS accounts                |

---

## ⚙️ How It Works (Architecture)

```text
[Source Server] --replication agent--> [Replication Server on AWS]
                                        |
                           [Staging Area (EBS volumes)]
                                        |
                          → Launch as EC2 during cutover
```

### Key Components:

- **Replication Agent**: Installed on source server
    
- **Staging Area**: Temporary EC2 + EBS volumes
    
- **Conversion Engine**: Converts system to bootable EC2 instance
    
- **Launch Templates**: Used to define instance configuration
    

---

## 🔁 Migration Flow (Step-by-Step)

1. **Install agent** on the source server
    
2. Data is replicated **continuously** to the staging area in AWS
    
3. You can **test** the launch (non-disruptive)
    
4. When ready → **cutover** to AWS (launch EC2)
    
5. Decommission source server
    

---

## 🛠️ Automation & Customization

| Feature                 | Description                                      |
| ----------------------- | ------------------------------------------------ |
| **Launch templates**    | Define EC2 instance type, subnet, security group |
| **Tags**                | Apply tags automatically to launched instances   |
| **Post-launch actions** | Install CloudWatch agent, join AD, run scripts   |
| **Rollback**            | Rollback if test/cutover fails                   |

---

## 🔐 Security

| Control            | Description                                 |
| ------------------ | ------------------------------------------- |
| **IAM roles**      | Used for replication and launch permissions |
| **TLS encryption** | In-transit replication is encrypted         |
| **KMS encryption** | Optional for EBS staging area volumes       |
| **VPC support**    | You choose subnets and security groups      |

---

## 📋 Requirements

| Requirement       | Details                                                      |
| ----------------- | ------------------------------------------------------------ |
| Agent installed   | On every source server                                       |
| Outbound internet | Needed for agent to reach AWS endpoint (or use VPC endpoint) |
| Permissions       | IAM role with `mgn:*`, `ec2:*`, `cloudwatch:*`               |

---

## 🚨 Limitations

| Limitation                 | Notes                                |
| -------------------------- | ------------------------------------ |
| Not for containerized apps | Use ECS/EKS migration tools instead  |
| No in-place OS conversion  | e.g., Windows to Linux not supported |
| Replication only to AWS    | Not multi-cloud                      |
| No Terraform resource yet  | Not natively supported in Terraform  |

---

## 💰 Pricing

| Resource               | Cost Type                             |
| ---------------------- | ------------------------------------- |
| **Replication server** | EC2 cost (usually t3.medium)          |
| **Staging area (EBS)** | Charged per GB-month                  |
| **Launched EC2**       | Standard EC2 pricing after cutover    |
| **Free tier**          | ✅ 90 days free for each source server |

> ❗ You do **not pay** for the agent or service usage itself.

---

## 🧪 Typical Use Case

| Scenario                   | AWS MGN Role                          |
| -------------------------- | ------------------------------------- |
| Legacy VM to AWS           | Rehost entire app as-is               |
| Data center evacuation     | Mass migration of hundreds of servers |
| Application test/dev clone | Migrate QA copy to AWS for testing    |
| Disaster recovery setup    | Use MGN for DR replication            |

---

## ✅ TL;DR Summary

| Feature            | AWS MGN                                    |
| ------------------ | ------------------------------------------ |
| Migration Type     | Lift-and-shift (rehost)                    |
| Supported OS       | Windows, Linux                             |
| Replication Method | Continuous block-level                     |
| Downtime           | Minimal (for cutover only)                 |
| Cost               | Free for 90 days/server, then EC2+EBS cost |
| Automation         | Yes, with post-launch actions              |
| Multi-cloud        | ❌ AWS-only                                 |
| Testing Supported  | ✅ Yes (test launch)                        |

---

## 🔧 CLI Sample (AWS MGN)

Install agent on Linux:

```bash
sudo ./aws-replication-agent installer \
  --aws-access-key-id YOUR_KEY \
  --aws-secret-access-key YOUR_SECRET \
  --region us-east-1
```

---
