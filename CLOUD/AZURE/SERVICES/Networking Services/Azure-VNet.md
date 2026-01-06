
## 🌐 What is an Azure Virtual Network (VNet)?

An **Azure Virtual Network (VNet)** is the fundamental building block for private networking in Azure. It is analogous to a traditional on-premises network, but in the cloud.

> A VNet allows Azure resources like VMs, containers, databases, and more to securely communicate with each other, the internet, and on-premises networks.

---

## 📚 Table of Contents

1. **Basics and Purpose**
    
2. **Core Components**
    
3. **VNet Addressing (CIDR)**
    
4. **Subnets**
    
5. **Network Security (NSGs, ASGs)**
    
6. **Peering and Routing**
    
7. **Connecting On-Prem (VPN, ExpressRoute)**
    
8. **Service Endpoints & Private Endpoints**
    
9. **Real-World Use Case**
    
10. **Create VNet via Portal & CLI**
    
11. **Best Practices**
    
12. **Common Interview Questions**
    

---

## 1️⃣ Basics and Purpose

|Concept|Description|
|---|---|
|VNet|An isolated network environment in Azure|
|Purpose|Secure communication between Azure resources|
|Scope|Bound to a single **region**|
|Internet|Resources **can** access internet via public IP or NAT|

---

## 2️⃣ Core Components of a VNet

| Component                              | Description                             |
| -------------------------------------- | --------------------------------------- |
| **Subnets**                            | Divide VNet into smaller address ranges |
| **IP Address Space**                   | CIDR block like `10.0.0.0/16`           |
| **Route Tables**                       | Custom control of traffic routing       |
| **NSGs (Network Security Groups)**     | Control inbound/outbound traffic        |
| **ASGs (Application Security Groups)** | Logical group for NSG rules             |
| **Service Endpoints**                  | Extend VNet to Azure services           |
| **Private Endpoints**                  | Private IP access to PaaS services      |

---

## 3️⃣ Address Space (CIDR Notation)

- When creating a VNet, define an IP range using **CIDR**:
    
    - Example: `10.0.0.0/16`
        
- You can define multiple non-overlapping address spaces.
    

|Example|CIDR|IPs Available|
|---|---|---|
|`10.0.0.0/16`|65,536||
|`10.0.1.0/24`|256||
|`192.168.0.0/24`|256||

---

## 4️⃣ Subnets

- **Divide VNet into subnets** for better isolation and management.
    
- Assign **NSGs**, **UDRs**, or **delegations** to subnets.
    

> 🧠 Azure reserves 5 IPs per subnet (first 4 and last 1).

|Subnet Name|CIDR|Usage|
|---|---|---|
|web-subnet|10.0.1.0/24|Public-facing resources|
|db-subnet|10.0.2.0/24|Databases, backend|
|mgmt-subnet|10.0.3.0/24|Bastion, jump box, firewall|

---

## 5️⃣ Network Security: NSG & ASG

### 🔐 NSG (Network Security Group)

- Controls traffic at subnet or NIC level
    
- Has **inbound** and **outbound** rules
    

|Rule|Source|Destination|Port|Action|
|---|---|---|---|---|
|AllowHTTP|Internet|VM|80|Allow|
|DenyAll|Any|Any|*|Deny|

### 👥 ASG (Application Security Group)

- Group NICs by **application**, then use in NSG
    
- Dynamic and scalable
    

---

## 6️⃣ VNet Peering and Routing

### 🔁 Peering

- Connect two VNets **privately**
    
- Low latency and high-speed Azure backbone
    
- **Global Peering** allows cross-region
    

|Type|Scope|
|---|---|
|VNet Peering|Same region|
|Global VNet Peering|Cross-region|

### 🧭 Routing

- **System routes**: Default, automatically created
    
- **User-defined routes (UDR)**: Custom traffic redirection (e.g., to NVA)
    

---

## 7️⃣ Connecting to On-Prem

### 🌉 VPN Gateway

- Encrypted tunnel over the public internet
    
- Supports **Site-to-Site**, **Point-to-Site**, and **VNet-to-VNet**
    

### 🏢 ExpressRoute

- Dedicated private connection to Azure
    
- SLA-backed and highly reliable
    

---

## 8️⃣ Service Endpoints & Private Endpoints

### 🚪 Service Endpoints

- Extend VNet identity to Azure services like:
    
    - Storage, SQL, Cosmos DB
        
- Traffic remains in Azure backbone
    

### 🔒 Private Endpoints

- Connect to Azure PaaS services via **private IP**
    
- No public internet exposure
    

---

## 9️⃣ Real-World Architecture

Example:

|Component|Subnet|Role|
|---|---|---|
|Web App|`10.0.1.0/24`|Public|
|App Tier|`10.0.2.0/24`|Logic|
|DB|`10.0.3.0/24`|Private|
|Bastion|`10.0.4.0/24`|Secure remote access|

Use **NSG** + **ASG** + **Private Link** + **Azure Firewall** for complete protection.

---

## 🔧 10. How to Create VNet

### ➤ Using Azure Portal

1. Go to **Virtual Networks** → **Create**
    
2. Fill:
    
    - Name: `my-vnet`
        
    - Region: East US
        
    - Address Space: `10.0.0.0/16`
        
    - Subnet: `web` → `10.0.1.0/24`
        
3. Review + Create
    

---

### ➤ Using Azure CLI

```bash
# Create VNet
az network vnet create \
  --name my-vnet \
  --resource-group my-rg \
  --address-prefix 10.0.0.0/16 \
  --subnet-name web-subnet \
  --subnet-prefix 10.0.1.0/24
```

```bash
# Add another subnet
az network vnet subnet create \
  --resource-group my-rg \
  --vnet-name my-vnet \
  --name db-subnet \
  --address-prefix 10.0.2.0/24
```

---

## ✅ 11. Best Practices

|Practice|Description|
|---|---|
|CIDR Planning|Avoid overlapping IPs for hybrid and peering|
|Subnet Design|Isolate by tier/function|
|NSG Rules|Use least privilege|
|Peering|Use global peering for multi-region|
|Monitor|Use NSG flow logs, Azure Monitor, and Traffic Analytics|

---

## ✅ 11. How to Create VNet Using Terraform

Below is a **complete Terraform setup** to:

- Create a **Resource Group**
    
- Create a **VNet**
    
- Add **Subnets**
    
- Create **NSG** and assign to a subnet
    

---

### 📁 Folder Structure

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
```

---

### 🔸 `main.tf`

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_nsg_assoc" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

---

### 🔸 `variables.tf`

```hcl
variable "resource_group_name" {
  default = "my-rg"
}

variable "location" {
  default = "East US"
}

variable "vnet_name" {
  default = "my-vnet"
}

variable "vnet_address_space" {
  default = "10.0.0.0/16"
}
```

---

### 🔸 `outputs.tf`

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "web_subnet_id" {
  value = azurerm_subnet.web.id
}
```

---

### 🔸 `terraform.tfvars`

```hcl
resource_group_name = "vnet-demo-rg"
location            = "East US"
vnet_name           = "demo-vnet"
vnet_address_space  = "10.0.0.0/16"
```

---

### ▶️ Terraform Commands to Run

```bash
terraform init
terraform plan
terraform apply
```

---

## 🔁 To Add Peering (Optional)

In `main.tf`, define:

```hcl
resource "azurerm_virtual_network_peering" "peer1_to_peer2" {
  name                      = "peer1-to-peer2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = "<remote-vnet-id>"
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
```

> Replace `<remote-vnet-id>` with the actual ID of another VNet.

---
