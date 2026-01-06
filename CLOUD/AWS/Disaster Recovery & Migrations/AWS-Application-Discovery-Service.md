
## 🧠 What Is AWS Application Discovery Service?

**AWS Application Discovery Service (ADS)** helps you **collect data** about your on-premises servers to plan and execute migrations to AWS.  
It identifies **server inventory**, **configuration**, **performance**, and **application dependencies**, enabling informed **migration planning**.

> ✅ Ideal for large-scale migrations, especially **data center to AWS** scenarios.

---

## 🔍 Key Use Cases

|Use Case|Description|
|---|---|
|**Cloud migration assessment**|Discover workloads and dependencies before migration|
|**Dependency mapping**|Identify which apps talk to each other|
|**Server performance analysis**|Understand CPU, memory, disk, and network usage|
|**Inventory generation**|Build CMDB-like list of servers and workloads|

---

## 🧱 Components of ADS

|Component|Purpose|
|---|---|
|**Discovery Agent**|Lightweight agent installed on Linux/Windows VMs for deep info|
|**Agentless Connector**|VMware-only, collects via vCenter (no installation on VMs)|
|**Discovery Data Collector**|Gathers and uploads information to AWS|
|**Migration Hub**|Central dashboard to visualize and analyze collected data|

---

## ⚙️ Agent vs Agentless Comparison

|Feature|Agent-Based|Agentless (VMware)|
|---|---|---|
|OS support|Windows, Linux|VMware ESXi only|
|Depth of data|Deep (network, processes)|Shallow (CPU, RAM, IP, etc.)|
|Setup complexity|Requires agent install|Needs access to vCenter|
|Dependency mapping|✅ Full|❌ Not available|
|Real-time updates|✅ Yes|❌ No|

---

## 📋 Data Collected

|Category|Sample Data Points|
|---|---|
|**Host details**|IP address, MAC, hostname, OS, version|
|**Resource usage**|CPU, memory, disk, network utilization|
|**Running processes**|List of processes and usage|
|**Open ports**|TCP/UDP connections|
|**App dependencies**|Who talks to whom (via ports/IP)|
|**Installed software**|List of packages|

---

## 🌐 Integration with AWS Migration Hub

Once collected, data appears in the **AWS Migration Hub**:

- Visualize dependencies
    
- Group servers into applications
    
- Plan migration waves
    
- Export data to **Migration Evaluator**, **SMS**, **DMS**, etc.
    

---

## 🛠️ How to Use ADS (Agent-Based Example)

1. **Enable ADS in your AWS account**
    
2. **Download the agent** from AWS console
    
3. Install on each source server:
    
    ```bash
    ./aws-discovery-agent install
    ```
    
4. The agent sends data securely to AWS
    
5. View all collected info in **Migration Hub**
    

---

## 🔐 Security & Permissions

|Feature|Support|
|---|---|
|**IAM Roles**|Required for agent auth|
|**Encryption**|TLS for data in transit|
|**VPC Endpoint**|Optional, for private access|
|**Data privacy**|Data remains in region selected|

---

## 📦 Terraform Note

There is **no native Terraform resource** for ADS, since it’s mostly CLI/UI-driven and agent-based. However:

- Use Terraform for downstream services (e.g., Migration Hub, EC2 targets)
    
- Automate agent install via EC2 user data or SSM
    

---

## 🧾 Pricing

|Item|Cost (as of 2024)|
|---|---|
|ADS|**Free** (no cost to use)|
|Storage of data|Covered under Migration Hub|
|Agent|No charge to install/use|

> 💡 You only pay for **related AWS services** (e.g., EC2, SMS, DMS) used **after discovery**.

---

## ✅ TL;DR Summary

|Feature|AWS Application Discovery Service|
|---|---|
|Purpose|Assess and plan cloud migrations|
|Input methods|Agent-based or VMware connector|
|Use cases|Inventory, performance, dependencies|
|Integration|AWS Migration Hub|
|Cost|✅ Free|
|Terraform support|❌ Not directly supported|

---
