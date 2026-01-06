## 🌐 Azure Load Balancer

### 🔄 What is Load Balancer?

Azure Load Balancer distributes **incoming traffic across multiple VMs** to ensure:

- High availability
    
- Scalability
    
- Failover handling
    

### 🔧 Types

|Type|Use Case|
|---|---|
|**Public**|Internet-facing traffic|
|**Internal**|Within Azure VNet (e.g., microservices)|

### 🧰 Setup Steps (Portal)

1. Go to **Load Balancers**
    
2. Click **Create**
    
3. Select type: Public or Internal
    
4. Add **Frontend IP** (Public IP)
    
5. Add **Backend Pool** (Add VMs)
    
6. Add **Health Probes** (e.g., TCP on port 80)
    
7. Add **Load Balancing Rule**
    
    - Port 80 frontend → Port 80 backend
        

### 📌 Health Probes

Checks the availability of VMs. Common probe types:

- **TCP probe**
    
- **HTTP GET probe**
    

---
