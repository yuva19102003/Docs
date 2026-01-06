
### 🧰 **1. Compute Services**

| **Service**                     | **Purpose**                                    | Documentation |
| ------------------------------- | ---------------------------------------------- | --------------- |
| Azure Virtual Machines (VMs)    | General-purpose compute resources              | [SERVICES/AZURE VM/](SERVICES/AZURE%20VM/) |
| Azure App Services              | Host and scale web applications                | [SERVICES/AZURE-WEB-APP-SERVICE/](SERVICES/AZURE-WEB-APP-SERVICE/) |
| Azure Kubernetes Service (AKS)  | Managed Kubernetes for container orchestration | See README |
| Azure Container Instances (ACI) | Run containers without managing infrastructure | See README |
| Azure Functions                 | Serverless compute for event-driven workloads  | See README |

---

### 💾 **2. Storage & Database Services**

| **Service**        | **Purpose**                          | Pages |
| ------------------ | ------------------------------------ | ----- |
| Azure Blob Storage | Object storage for unstructured data |       |
| Azure Files        | Fully managed file shares via SMB    |       |
| Azure Disk Storage | Block storage for VMs                |       |
| Azure SQL Database | Managed relational SQL database      |       |
| Azure Cosmos DB    | Globally distributed NoSQL database  |       |

---

### 🌐 **3. Networking Services**

| **Service**                            | **Purpose**                                                                  | Documentation                              |
| -------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------- |
| **Virtual Network (VNet)**             | Creates an isolated and secure network for Azure resources                   | [Azure-VNet.md](SERVICES/Networking%20Services/Azure-VNet.md) |
| **Network Security Groups (NSGs)**     | Filters inbound and outbound traffic to resources using rule-based access    | [NSG.md](SERVICES/Networking%20Services/NSG.md) |
| **Application Security Groups (ASGs)** | Groups VMs logically to simplify and scale NSG rule application              | [ASG.md](SERVICES/Networking%20Services/ASG.md) |
| **Azure Application Gateway + WAF**    | Layer 7 load balancer with web application firewall for HTTP/HTTPS traffic   | [Azure-Application-Gateway-WAF.md](SERVICES/Networking%20Services/Azure-Application-Gateway-WAF.md) |
| **Azure Load Balancer**                | Layer 4 load balancer for TCP/UDP traffic distribution                       | [Azure-Load-Balancer.md](SERVICES/Networking%20Services/Azure-Load-Balancer.md) |
| **Azure DNS**                          | Hosts and manages DNS domains and resolves domain names                      | [Azure-DNS.md](SERVICES/Networking%20Services/Azure-DNS.md) |
| **Azure Firewall**                     | Stateful firewall to centrally log, control, and inspect traffic             | [Azure-Firewall.md](SERVICES/Networking%20Services/Azure-Firewall.md) |
| **Virtual Network Peering**            | Connects two VNets for seamless private communication                        | [VNet-Peering.md](SERVICES/Networking%20Services/VNet-Peering.md) |
| **VPN Gateway**                        | Provides secure, encrypted tunnel between on-premises network and Azure VNet | [Azure-VPN-Gateway.md](SERVICES/Networking%20Services/Azure-VPN-Gateway.md) |

---
### 🔄 **4. CI/CD & Code Management**

| **Service**                    | **Purpose**                                        | Pages |
| ------------------------------ | -------------------------------------------------- | ----- |
| Azure DevOps Services          | Full DevOps suite (Repos, Pipelines, Boards, etc.) |       |
| GitHub Actions                 | CI/CD pipeline within GitHub                       |       |
| Azure Container Registry (ACR) | Private container image registry                   |       |
| Bicep / ARM Templates          | Infrastructure as Code using Azure native format   |       |
| Terraform on Azure             | Popular IaC tool for managing infrastructure       |       |

---

### 📊 **5. Monitoring & Logging**

| **Service**            | **Purpose**                                                  | Pages |
| ---------------------- | ------------------------------------------------------------ | ----- |
| Azure Monitor          | Collect and analyze metrics from Azure resources             |       |
| Log Analytics          | Query and analyze collected logs                             |       |
| Application Insights   | Application performance and availability monitoring          |       |
| Azure Alerts / Actions | Set up notifications and automated responses to issues       |       |
| Azure Advisor          | Recommendations for cost, security, reliability, performance |       |

---

### 🔐 **6. Security & Identity (DevSecOps Focus)**

| **Service**                      | **Purpose**                                                   | Documentation                                        |
| -------------------------------- | ------------------------------------------------------------- | -------------------------------------------- |
| Microsoft Entra ID               | Identity and access management                                | [0-Microsoft-Entra-ID-(formerly Azure AD).md](SERVICES/MICROSOFT-INTRA-ID/0-Microsoft-Entra-ID-(formerly%20Azure%20AD).md) |
| Azure Key Vault                  | Secure management of secrets, keys, and certificates          | See README |
| Azure Policy                     | Define and enforce policies across resources                  | See README |
| Azure Blueprints                 | Package policy, RBAC, ARM templates as a repeatable blueprint | See README |
| Microsoft Defender for Cloud     | Cloud workload protection and posture management              | See README |
| Azure Sentinel                   | SIEM and SOAR for intelligent threat detection                | See README |


---

### 🧭 **7. Governance & Compliance**

| **Service**           | **Purpose**                                  | Pages |
| --------------------- | -------------------------------------------- | ----- |
| Azure Resource Locks  | Prevent accidental deletion or modification  |       |
| Azure Resource Graph  | Inventory and query Azure resources at scale |       |
| Azure Cost Management | Monitor and control Azure spending           |       |
| Azure Security Center | Centralized security policy enforcement      |       |

---

### ⚙️ **8. Automation & Orchestration**

| **Service**        | **Purpose**                                             | Pages |
| ------------------ | ------------------------------------------------------- | ----- |
| Azure Automation   | Automate tasks using runbooks and scripts               |       |
| Azure Logic Apps   | Build workflows with low-code automation                |       |
| Azure Event Grid   | Event routing for event-based architecture              |       |
| Azure Event Hubs   | Data streaming platform for telemetry and logs          |       |
| Azure DevTest Labs | Quickly create and manage development/test environments |       |

---

### 🌍 **9. Hybrid & Multicloud**

| **Service**      | **Purpose**                                             | Documentation                |
| ---------------- | ------------------------------------------------------- | -------------------- |
| Azure Arc        | Manage on-premises and multi-cloud resources from Azure | [Hybrid & Multicloud/](SERVICES/Hybrid%20&%20Multicloud/) |
| Azure Lighthouse | Manage multiple tenants (ideal for MSPs)                | [Hybrid & Multicloud/](SERVICES/Hybrid%20&%20Multicloud/) |

---

### 👨‍💻 **10. Developer Tools**

| **Tool**              | **Purpose**                                         | Documentation                 |
| --------------------- | --------------------------------------------------- | --------------------- |
| Azure CLI             | Command-line tool for managing Azure resources      | [Docs/3-CLI/](Docs/3-CLI/) |
| Azure PowerShell      | PowerShell cmdlets for Azure management             | See README |
| Azure Resource Groups | Core control plane for managing all Azure resources | [0-resource-groups.md](SERVICES/RESOURCE-GROUPS/0-resource-groups.md) |
| Azure REST API        | Programmatic access to Azure services               | See README |

---
