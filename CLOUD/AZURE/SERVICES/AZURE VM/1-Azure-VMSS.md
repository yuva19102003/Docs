
## 🔁 Auto-Scaling in Azure

Azure VM **auto-scaling** is supported through **Virtual Machine Scale Sets (VMSS)**.

### 🌀 What is VMSS?

A Virtual Machine Scale Set allows you to:

- Automatically increase/decrease VM count based on demand.
    
- Distribute traffic using a load balancer.
    
- Ensure high availability.
    

### ⚙️ Configure Auto-scaling

1. Go to **Virtual Machine Scale Sets**
    
2. Click **Create**
    
3. Fill in basic info and choose the OS image
    
4. Enable **Auto-scaling**:
    
    - Metric-based (e.g., CPU > 75%)
        
    - Schedule-based (e.g., scale on weekends)
        
5. Attach to a Load Balancer (optional)
    

### 🧠 Example Auto-scale Rule

- Scale-out: If CPU > 70% for 10 min → Add 1 instance
    
- Scale-in: If CPU < 30% for 10 min → Remove 1 instance
    

---
