
# 🚀 **END-TO-END: NGINX LOAD BALANCER TUTORIAL**

# 🎯 What You Will Learn

You will build:

- A **load balancer server (NGINX)**
    
- Multiple backend app servers (Node/Golang/Python, etc.)
    
- Load balancing algorithms (round-robin, least-conn, IP-hash)
    
- Health checks
    
- HTTPS on load balancer
    
- Logging + performance tuning
    

---

# 🧱 **1. What is Load Balancing?**

NGINX distributes incoming traffic across multiple backend servers:

```
Client → NGINX (Load Balancer) → App Server 1  
                                   App Server 2  
                                   App Server 3  
```

This gives:

✔ High availability  
✔ Better performance  
✔ Failover if one backend crashes  
✔ Scalability

---

# 🖥 **2. Example Setup**

We assume 3 backend servers:

- **App1** → [http://127.0.0.1:3001](http://127.0.0.1:3001/)
    
- **App2** → [http://127.0.0.1:3002](http://127.0.0.1:3002/)
    
- **App3** → [http://127.0.0.1:3003](http://127.0.0.1:3003/)
    

Your NGINX load balancer runs on port **80/443**.

You can replicate this even on a single machine.

---

# 📌 **3. Install NGINX**

```bash
sudo apt update
sudo apt install nginx -y
```

Start and enable:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

# 🔧 **4. Create Load Balancer Config**

Create a new config:

```bash
sudo nano /etc/nginx/sites-available/loadbalancer
```

Paste this:

```
upstream backend_cluster {
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    server 127.0.0.1:3003;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

# 🔄 **5. Enable Configuration**

```bash
sudo ln -s /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

You now have a **working NGINX load balancer**.

---

# ⚙️ **6. Load Balancing Methods**

Modify the `upstream` block based on algorithm.

---

### **A) Round Robin (default)**

```
upstream backend_cluster {
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    server 127.0.0.1:3003;
}
```

Traffic is evenly distributed.

---

### **B) Least Connections**

```
upstream backend_cluster {
    least_conn;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    server 127.0.0.1:3003;
}
```

Great for long-running requests.

---

### **C) IP Hash (sticky client sessions)**

```
upstream backend_cluster {
    ip_hash;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    server 127.0.0.1:3003;
}
```

Same client → same backend.

---

### **D) Weighted Load Balancing**

```
upstream backend_cluster {
    server 127.0.0.1:3001 weight=5;
    server 127.0.0.1:3002 weight=3;
    server 127.0.0.1:3003 weight=1;
}
```

Useful when servers have different CPU/RAM strengths.

---

# ❤️ **7. Backend Health Checks**

Add:

```
upstream backend_cluster {
    server 127.0.0.1:3001 max_fails=3 fail_timeout=10s;
    server 127.0.0.1:3002 max_fails=3 fail_timeout=10s;
    server 127.0.0.1:3003 max_fails=3 fail_timeout=10s;
}
```

If a server fails 3 times → NGINX automatically removes it temporarily.

---

# 🔒 **8. Enable HTTPS on Load Balancer**

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx -y
```

Run:

```bash
sudo certbot --nginx -d example.com
```

It will:

✔ Install SSL  
✔ Redirect HTTP → HTTPS  
✔ Update NGINX config automatically

---

# 📊 **9. Logs (Important for debugging)**

### Access logs:

```bash
tail -f /var/log/nginx/access.log
```

### Error logs:

```bash
tail -f /var/log/nginx/error.log
```

---

# 🚀 **10. Simple Backend Apps for Testing**

Example Node.js apps:

## App 1:

```js
const http = require("http");
http.createServer((req,res)=>{
    res.end("Response from Server 3001");
}).listen(3001);
```

## App 2:

```js
const http = require("http");
http.createServer((req,res)=>{
    res.end("Response from Server 3002");
}).listen(3002);
```

## App 3:

```js
const http = require("http");
http.createServer((req,res)=>{
    res.end("Response from Server 3003");
}).listen(3003);
```

Now refresh your browser multiple times:

You will see:

- Response from Server 3001
    
- Response from Server 3002
    
- Response from Server 3003
    

→ **Load balancing confirmed 🎉**

---

# 🚀 **11. Advanced: Load Balancer + Reverse Proxy + API Gateway**

If you want, I can give:

- Rate limiting
    
- JWT auth forwarding
    
- Path-based routing
    
- Microservices architecture
    
- Caching layer
    
- Sticky sessions
    
- Auto-scaling architecture
    

---

# 🎉 **Load Balancing Setup Completed!**

You now have:

✔ NGINX as load balancer  
✔ Multiple backend servers  
✔ Health checks  
✔ HTTPS  
✔ Traffic distribution methods  
✔ Logging + debugging  
✔ Production-ready setup

---
