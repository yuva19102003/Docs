
## 💡 What is an Azure Virtual Machine?

_A VM in Azure lets you run applications on a virtualized environment with full control over the OS, compute, and networking._

---

## 🧱 Core Components of an Azure VM

|Component|Description|
|---|---|
|Image|OS template like Ubuntu or Windows|
|Size|CPU, RAM, Disk performance level|
|OS Disk|Main boot disk|
|Data Disk|Additional storage (optional)|
|VNet + Subnet|Networking infrastructure|
|NIC|Network Interface Card|
|Public IP|Optional external access|
|NSG|Network Security Group (firewall rules)|

---

## ⚙️ Steps to Create an Azure VM (via Portal)

**[Refer to earlier steps in original message]**

---

## 🧑‍💻 Connect to Your VM

- **Linux**: `ssh <user>@<public-ip>`
    
- **Windows**: Use **Remote Desktop Connection (RDP)**
    

---

## 💻 Create Azure VM with Terraform (Only VM Block)

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myOsDisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

---
