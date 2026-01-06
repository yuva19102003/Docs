
# 🚀 **NGINX CACHING SERVER — END-TO-END TUTORIAL**

NGINX can act as a **cache layer** between the client and your backend server.  
This gives:

✔ Faster response times  
✔ Less load on backend  
✔ Handles more traffic  
✔ Reduces DB/API usage

---

# 📌 **1. What is NGINX Caching? (Simple Explanation)**

Flow:

```
Client → NGINX (Cache Layer) → Backend Server
```

When a request comes:

1. NGINX checks: _Is response already cached?_
    
2. If **YES → returns cached response instantly**
    
3. If **NO → fetches from backend → stores cache → returns response**
    

---

# 📁 **2. Prerequisites**

- Backend running on port: **[http://127.0.0.1:3000](http://127.0.0.1:3000/)**
    
- NGINX installed
    
- File system caching enabled
    

---

# 🧱 **3. Create Cache Directory**

```bash
sudo mkdir -p /var/cache/nginx_cache
sudo chmod 777 /var/cache/nginx_cache
```

---

# ⚙️ **4. Configure NGINX Cache**

Edit your site config:

```bash
sudo nano /etc/nginx/sites-available/cache_server
```

Paste this:

```
proxy_cache_path /var/cache/nginx_cache levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_cache my_cache;
        proxy_pass http://127.0.0.1:3000;

        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;

        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;

        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

### What each line means:

- **proxy_cache_path** → Where cache files are stored
    
- **keys_zone=my_cache:10m** → Cache index memory
    
- **max_size=1g** → Maximum cache size
    
- **inactive=60m** → Remove unused cache entries
    
- **proxy_cache_valid** → Cache success for 10 minutes
    
- **use_stale** → Serve old cache if backend fails
    
- **X-Cache-Status** → Shows HIT / MISS in response header
    

---

# 🔗 **5. Enable the Site**

```bash
sudo ln -s /etc/nginx/sites-available/cache_server /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

# 🧪 **6. Test Cache Behavior**

Make request:

```bash
curl -I http://your-domain
```

You will see:

- **MISS** → (first request, cache empty)
    
- **HIT** → (subsequent requests, served from cache)
    

Example:

```
X-Cache-Status: MISS
```

then:

```
X-Cache-Status: HIT
```

🎉 This confirms caching is working.

---

# ⚡ **7. Cache Control Per Path (Optional)**

### Cache `/api/products/` for 5 minutes:

```
location /api/products/ {
    proxy_cache my_cache;
    proxy_pass http://127.0.0.1:3000;
    proxy_cache_valid 200 5m;
}
```

---

### Disable cache for login routes:

```
location /login {
    proxy_no_cache 1;
    proxy_cache_bypass 1;
    proxy_pass http://127.0.0.1:3000;
}
```

---

# 🔐 **8. Ignore Cookies / Headers (Optional)**

### Don't let cookies break caching:

```
proxy_ignore_headers Cache-Control Expires Set-Cookie;
```

---

# ⭐ **9. Microcaching (High-Performance API Cache)**

Microcaching caches responses for **1–2 seconds** — reduces backend load massively.

```
proxy_cache_valid 200 1s;
```

This is used by:

✔ High-traffic APIs  
✔ E-commerce sites  
✔ Crypto dashboards  
✔ News feeds  
✔ Leaderboards

---

# 🔥 **10. Purge Cache (Manually)**

Clear entire cache:

```bash
sudo rm -rf /var/cache/nginx_cache/*
sudo systemctl reload nginx
```

---

# 📊 **11. Monitoring Cache**

View cache folder:

```bash
ls /var/cache/nginx_cache
```

Monitor logs:

```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

# 🛡 **12. Combine with Reverse Proxy + Load Balancer**

NGINX can do all 3 together:

```
Client → NGINX (Cache + SSL) → Load Balancer → Backend API cluster
```

Let me know if you want this architecture too.

---

# 🎉 **Caching Server Setup Completed!**

You now have:

✔ NGINX caching layer  
✔ File system cache  
✔ Per-path caching rules  
✔ Microcaching  
✔ Cache purge  
✔ Cache monitoring  
✔ Failover with stale cache

---

# ❓ What do you want next?

I can provide:

🔹 CDN-style caching (advanced)  
🔹 Cache + Load Balancer + Reverse Proxy combo  
🔹 High-availability caching architecture  
🔹 Cache invalidation rules for APIs  
🔹 Caching with Docker

Tell me what you want!