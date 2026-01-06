
```
                  ┌──────────────────────────┐
                  │  Client (SSH/HTTP)                          │
                  └────────────┬─────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
		            │          Azure Load Balancer     │
	                │           (Public Frontend)          │
                    └────────────┬────────┘
                                 │
          ┌──────────────────────┴──────────────────────┐
          │                                             │
          ▼                                             ▼
┌─────────────────────┐                                           ┌─────────────────────┐
│  VM Instance 1                        │                                           │  VM Instance 2                       │
│ (from VM Scale Set)                │◄───── Auto Scaling ──►│ (from VM Scale Set)               │
└────────┬────────────┘                                            └────────┬────────────┘
         │                                                                                                  │
         ▼                                                                                                 ▼
  ┌────────────┐                                                                     ┌────────────┐
  │ OS + App           │                                                                    │ OS + App           │
  └────────────┘                                                                     └────────────┘

                 Azure Virtual Network + Subnet
```

---

### 🔁 Components Mapped to Terraform:

- **Client**: Your SSH or HTTP client
    
- **Azure Load Balancer**: `azurerm_lb`, `azurerm_lb_rule`, `azurerm_public_ip`
    
- **VM Scale Set**: `azurerm_linux_virtual_machine_scale_set`
    
- **Auto Scaling**: `azurerm_monitor_autoscale_setting`
    
- **Subnet + VNet**: Needed for NIC and VMSS networking
    
---
## 🚀 Terraform Configuration for Load Balancer and VMSS

Below is the **complete Terraform code** for:

- A **Virtual Machine Scale Set** with auto-scaling
    
- A **Public Load Balancer** to distribute traffic across instances
    
- A **Linux image (Ubuntu)** with SSH access
    

---

### 🧱 Prerequisites (Brief)

Make sure you already have:

- `azurerm` provider block
    
- Resource Group
    
- Virtual Network
    
- Subnet
    
- Public IP
    

---

### ✅ Virtual Machine Scale Set (VMSS) + Load Balancer (Terraform)

```hcl
# Public IP
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lbPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "myLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name                = "backendPool"
  loadbalancer_id     = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg.name
}

# Health Probe
resource "azurerm_lb_probe" "http_probe" {
  name                = "http-probe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 22
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "lbRule"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_pool.id
  probe_id                       = azurerm_lb_probe.http_probe.id
}

# VMSS
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "myVMSS"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  upgrade_mode            = "Manual"
  disable_password_authentication = true

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
    }
  }

  health_probe_id = azurerm_lb_probe.http_probe.id
}
```

---

## 📌 Notes

- The **Load Balancer** will distribute **SSH traffic (port 22)** to all VMSS instances.
    
- You can change to HTTP (port 80) if you're hosting a web app.
    
- `upgrade_mode = "Manual"` lets you control upgrades. You can also use `Automatic`.
    

---

## ✅ Optional: Auto-Scaling (Basic Example)

Add this if you want **CPU-based auto-scaling**:

```hcl
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      minimum = "1"
      maximum = "5"
      default = "2"
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
```

---

## 🧹 Cleanup

```bash
terraform destroy
```

---
