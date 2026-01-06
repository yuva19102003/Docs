
## 5️⃣ How to make Redis Highly Available (HA)

High availability = Redis should **keep working even if one node dies**.

There are two classic designs:

---

### 🧱 A. Redis Master–Replica + Sentinel

**Components:**

- 1 **Primary** (accepts writes)
    
- 1+ **Replicas** (copy data from primary)
    
- **Sentinel** processes watch Redis nodes and do failover.
    

**How it works:**

1. All apps write/read to the **primary** (via a VIP / DNS name).
    
2. Replicas constantly sync from primary.
    
3. If primary dies:
    
    - Sentinel promotes a replica to be new primary
        
    - Apps reconnect (library usually handles this with retry + new address).
        

**Pros:**

- Simple concept
    
- Good for many workloads
    

**Cons:**

- No automatic sharding (one primary is still a limit)
    
- Need more effort to set up & monitor Sentinel
    

---

### 🧩 B. Redis Cluster (sharding + HA)

- Data is **sharded** across multiple nodes
    
- Each shard has:
    
    - 1 primary
        
    - 1+ replicas
        
- Automatic **failover** and **rebalancing**.
    

**Pros:**

- Horizontal scale (more data, more throughput)
    
- Built-in HA
    

**Cons:**

- Client library must be Cluster-aware
    
- A bit more complex to operate
    

---

### 🛡️ Extra HA & Reliability Practices

No matter which design:

1. **Enable persistence**
    
    - RDB snapshots (periodic)
        
    - AOF (append-only file) for durability
        
2. **Backups**
    
    - Copy RDB/AOF files to S3/NFS/backup server
        
3. **Multi-AZ deployment**
    
    - Run nodes in different availability zones / racks
        
4. **Connection retries**
    
    - In Node.js/Go, configure Redis client with reconnect, timeouts
        
5. **Monitoring**
    
    - Use `redis_exporter` + Prometheus + Grafana
        
    - Track: memory, CPU, hit-rate, latency, evictions
        

---

### 🧠 Quick Cheat Sheet

- **Small dev / single server** → Single Redis on VM or Docker
    
- **Small production** → Primary + replica with Sentinel
    
- **Heavy traffic / large data** → Redis Cluster on VMs or K8s
    
- **You don’t want ops overhead** → (If allowed) use managed Redis like AWS ElastiCache / Azure Cache / GCP Memorystore
    

---
