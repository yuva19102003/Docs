
# 🚀 **NGINX API GATEWAY — END-TO-END TUTORIAL**

An **API Gateway** is a single entry point that receives all requests and routes them to various services:

```
Client → API Gateway (NGINX) → Auth Service
                                  User Service
                                  Product Service
                                  Payment Service
```

NGINX can perform:

✔ Routing  
✔ Authentication  
✔ Rate limiting  
✔ Caching  
✔ SSL termination  
✔ Logging & Monitoring

---

# 🧱 **1. Example Microservices Architecture**

We assume:

- **Auth Service** → [http://127.0.0.1:4001](http://127.0.0.1:4001/)
    
- **User Service** → [http://127.0.0.1:4002](http://127.0.0.1:4002/)
    
- **Product Service** → [http://127.0.0.1:4003](http://127.0.0.1:4003/)
    

API Gateway runs on port **80/443**.

---

# 📁 **2. Create the API Gateway Config**

Create file:

```bash
sudo nano /etc/nginx/sites-available/api_gateway
```

Paste this:

```
server {
    listen 80;
    server_name api.example.com;

    # -------- AUTH SERVICE --------
    location /auth/ {
        proxy_pass http://127.0.0.1:4001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # -------- USER SERVICE --------
    location /users/ {
        proxy_pass http://127.0.0.1:4002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # -------- PRODUCT SERVICE --------
    location /products/ {
        proxy_pass http://127.0.0.1:4003/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

# 🔌 **3. Enable the Gateway**

```bash
sudo ln -s /etc/nginx/sites-available/api_gateway /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Now your API Gateway is live:

```
/auth/login
/users/list
/products/all
```

---

# 🔥 **4. Add Rate Limiting (API Throttling)**

Add inside `server {}`:

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location / {
    limit_req zone=api_limit;
}
```

This means:

- Max **10 requests per second per IP**
    
- Extra requests → 429 Too Many Requests
    

---

# 🔐 **5. Add Basic Authentication (for Internal APIs)**

Create auth file:

```bash
sudo apt install apache2-utils -y
sudo htpasswd -c /etc/nginx/.api_pass admin
```

Enable authentication for any route:

```
location /products/ {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.api_pass;

    proxy_pass http://127.0.0.1:4003/;
}
```

---

# 🛑 **6. Block Unauthorized Traffic (Whitelist/Blacklist)**

### Block specific IP:

```
deny 123.45.67.89;
```

### Whitelist internal network:

```
allow 192.168.1.0/24;
deny all;
```

---

# 🔒 **7. Add HTTPS (SSL Termination)**

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
```

Run:

```bash
sudo certbot --nginx -d api.example.com
```

Your gateway now supports:

✔ HTTPS  
✔ Automatic redirect  
✔ Automatic renewal

---

# ⚡ **8. Add Caching for Specific APIs**

Inside location block:

```
proxy_cache my_cache;
proxy_cache_valid 200 10s;
add_header X-Cache $upstream_cache_status;
```

High-traffic API? Use **microcaching**:

```
proxy_cache_valid 200 1s;
```

---

# 🔁 **9. Load Balancing Behind API Gateway**

Add in upstream:

```
upstream users_service {
    least_conn;
    server 127.0.0.1:4002;
    server 127.0.0.1:4004;
}

location /users/ {
    proxy_pass http://users_service/;
}
```

This gives:

- Load balancing
    
- Failover
    
- High availability
    

---

# 🧪 **10. Add JWT Authentication (API Security)**

If you want to validate JWT tokens in API Gateway:

```
location /users/ {
    if ($http_authorization = "") {
        return 401;
    }

    # Forward authorization header
    proxy_set_header Authorization $http_authorization;
    proxy_pass http://127.0.0.1:4002/;
}
```

This works with:

- Auth0
    
- Firebase
    
- Cognito
    
- Your own Auth service
    

---

# 📊 **11. Logging & Monitoring**

Access logs:

```bash
tail -f /var/log/nginx/access.log
```

Error logs:

```bash
tail -f /var/log/nginx/error.log
```

You can integrate this with:

- Grafana
    
- Loki
    
- Prometheus
    
- ELK Stack
    

Let me know if you want full setup.

---

# 🎉 **Your API Gateway is Complete!**

You now have:

✔ Routing & Reverse Proxy  
✔ Multiple microservices  
✔ JWT Forwarding  
✔ Rate Limiting  
✔ Authentication  
✔ Load Balancing support  
✔ HTTPS SSL termination  
✔ Caching (microcaching)  
✔ IP filtering  
✔ Logging & Monitoring

---
