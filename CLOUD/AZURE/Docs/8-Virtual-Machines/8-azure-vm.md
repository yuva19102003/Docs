# 🚀 Azure Virtual Machine – End-to-End Practical Tutorial

## What you’ll build

By the end, you will:

* Run a **secure Linux VM**
* SSH using **key-based auth**
* Serve traffic via **Nginx**
* **Harden** the VM (SSH + firewall)
* Create a **VM Scale Set**
* Enable **autoscaling**
* Perform **rolling updates (zero downtime)**

---

## 🧱 Architecture (Mental Model)

![Image](https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/media/multilayered-protection-azure-vm-architecture-diagram.svg)

![Image](https://k21academy.com/wp-content/uploads/2020/09/VM-Scale-set-e1603966905633-1024x410.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1332/0%2AJgb9qgl9IoU37YfA)

```
Internet
   |
Azure Load Balancer
   |
VM Scale Set
 ├─ VM Instance 1 (Nginx)
 ├─ VM Instance 2 (Nginx)
 └─ VM Instance N (Auto-scaled)
```

---

## 1️⃣ Create a Linux VM (Ubuntu)

### 🔐 Create SSH key (local machine)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/azure_vm_key
```

This creates:

* `azure_vm_key` (private)
* `azure_vm_key.pub` (public)

---

### ☁️ Create Resource Group

```bash
az group create \
  --name rg-azure-vm \
  --location eastus
```

---

### 🖥️ Create Linux VM

```bash
az vm create \
  --resource-group rg-azure-vm \
  --name demo-vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure_vm_key.pub \
  --public-ip-sku Standard
```

📌 **Why these choices**

* `Ubuntu2204` → LTS & stable
* `Standard_B2s` → cheap + enough for learning
* SSH keys → passwordless & secure

---

## 2️⃣ SSH into VM using Key

```bash
ssh -i ~/.ssh/azure_vm_key azureuser@<PUBLIC_IP>
```

✔️ You are now inside the VM.

---

## 3️⃣ Install & Verify Nginx

```bash
sudo apt update
sudo apt install nginx -y
```

Enable and start:

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
```

Check:

```bash
curl localhost
```

---

### 🌐 Open Port 80 (HTTP)

```bash
az vm open-port \
  --resource-group rg-azure-vm \
  --name demo-vm \
  --port 80
```

Open browser:

```
http://<PUBLIC_IP>
```

✅ Nginx default page should load.

---

## 4️⃣ Harden the VM (Very Important 🔒)

### 🔑 Disable password login & root login

```bash
sudo nano /etc/ssh/sshd_config
```

Change / ensure:

```
PasswordAuthentication no
PermitRootLogin no
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

---

### 🔥 Enable Firewall (UFW)

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw enable
sudo ufw status
```

✔️ Now:

* Only SSH + HTTP allowed
* Password login disabled
* Root login disabled

---

## 5️⃣ Create a VM Scale Set (VMSS)

> VMSS = **multiple identical VMs + auto-healing + auto-scaling**

![Image](https://k21academy.com/wp-content/uploads/2020/06/Scaling_Diagram.png)

![Image](https://www.cloudnativedeepdive.com/content/images/size/w960/2025/02/vnss.svg)

### Create VMSS

```bash
az vmss create \
  --resource-group rg-azure-vm \
  --name web-vmss \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure_vm_key.pub \
  --upgrade-policy-mode Rolling \
  --load-balancer web-lb
```

📌 Automatically creates:

* Load Balancer
* Backend pool
* 2 VM instances

---

## 6️⃣ Install Nginx on VMSS (Custom Script)

### Create script

```bash
nano nginx-install.sh
```

```bash
#!/bin/bash
apt update
apt install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from $(hostname)" > /var/www/html/index.html
```

---

### Apply script to VMSS

```bash
az vmss extension set \
  --resource-group rg-azure-vm \
  --vmss-name web-vmss \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris":[],"commandToExecute":"bash nginx-install.sh"}'
```

---

### 🌍 Access via Load Balancer IP

```bash
az network public-ip show \
  --resource-group rg-azure-vm \
  --name web-lb-ip \
  --query ipAddress -o tsv
```

Open in browser → traffic rotates between VMs.

---

## 7️⃣ Configure Autoscaling Rules

![Image](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/media/virtual-machine-scale-sets-autoscale-portal/enable-autoscale.png)

![Image](https://www.cloudnativedeepdive.com/content/images/size/w960/2025/02/vnss.svg)

### Create autoscale profile

```bash
az monitor autoscale create \
  --resource-group rg-azure-vm \
  --resource web-vmss \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name vmss-autoscale \
  --min-count 2 \
  --max-count 5 \
  --count 2
```

---

### Scale OUT (CPU > 70%)

```bash
az monitor autoscale rule create \
  --resource-group rg-azure-vm \
  --autoscale-name vmss-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

---

### Scale IN (CPU < 30%)

```bash
az monitor autoscale rule create \
  --resource-group rg-azure-vm \
  --autoscale-name vmss-autoscale \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1
```

---

## 8️⃣ Perform Rolling Updates (Zero Downtime)

Rolling upgrade ensures:

* One VM updates at a time
* Traffic continues flowing

### Change HTML content

```bash
nano nginx-install-v2.sh
```

```bash
#!/bin/bash
echo "🚀 Version 2 - Rolling Update" > /var/www/html/index.html
```

---

### Apply update

```bash
az vmss extension set \
  --resource-group rg-azure-vm \
  --vmss-name web-vmss \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris":[],"commandToExecute":"bash nginx-install-v2.sh"}'
```

✔️ Azure updates VMs **one by one**
✔️ No downtime
✔️ This is how production deployments work

---

## ✅ Final Checklist

✔ Linux VM created
✔ SSH with key
✔ Nginx installed
✔ VM hardened
✔ VM Scale Set created
✔ Autoscaling enabled
✔ Rolling updates performed

---

## 🧠 What You Just Learned (Interview Gold)

* Difference between **VM vs VMSS**
* Secure Linux VM setup
* Production-grade **autoscaling**
* **Zero-downtime deployments**
* Azure Load Balancer behavior

---
