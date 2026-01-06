
# 🚀 **END-TO-END: NGINX REVERSE PROXY TUTORIAL**

---

# ✅ **1. What is a Reverse Proxy (Easy Explanation)**

A **reverse proxy** sits in front of your backend app and forwards requests.

Flow:

```
Client → NGINX → Backend Server (Node/Golang/Python)
```

NGINX handles:

- Routing
    
- SSL/TLS
    
- Load balancing
    
- Caching
    
- Security
    
- Rate limiting
    

Your backend only handles business logic.

---

# ✅ **2. Example Setup**

We assume:

- Backend running at: **[http://localhost:3000](http://localhost:3000/)**
    
- NGINX receives requests at: **[http://your-domain](http://your-domain/)**
    

---

# 📌 **3. Install NGINX**

Ubuntu / Debian:

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

# 📁 **4. Create Reverse Proxy Config**

Create a new NGINX server block:

```bash
sudo nano /etc/nginx/sites-available/myapp
```

Paste this:

```
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> Replace `example.com` with your domain or IP.

---

# 🔌 **5. Enable the Reverse Proxy**

Enable config:

```bash
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
```

Remove default:

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Test config:

```bash
sudo nginx -t
```

Reload:

```bash
sudo systemctl reload nginx
```

---

# 🔥 **Now your backend is live!**

Visit:

👉 **[http://your-domain](http://your-domain/)**  
NGINX → Forwards → Backend server

---

# ⚡ **6. Add SSL (HTTPS) Automatically**

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx -y
```

Run:

```bash
sudo certbot --nginx -d example.com
```

Certbot will:

✔ Install SSL  
✔ Configure HTTPS  
✔ Redirect HTTP → HTTPS

---

# 📌 **7. Optional: Proxy for Specific Paths**

Example:

```
location /api/ {
    proxy_pass http://127.0.0.1:3000/;
}

location /auth/ {
    proxy_pass http://127.0.0.1:4000/;
}
```

---

# 🧪 **8. Optional: Reverse Proxy for WebSocket (Real-Time apps)**

Use this if your backend uses WebSocket:

```
location /ws/ {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

---

# 📊 **9. Logs for Debugging**

### Access logs:

```bash
tail -f /var/log/nginx/access.log
```

### Error logs:

```bash
tail -f /var/log/nginx/error.log
```

---

# 🛡 **10. Bonus: Improve Reverse Proxy Performance**

Add to `nginx.conf` → inside `http {}`:

```
proxy_read_timeout 60s;
proxy_connect_timeout 60s;
proxy_send_timeout 60s;

client_max_body_size 20M;
```

---

# 🎉 Reverse Proxy Setup Completed!

You now have:

✔ NGINX reverse proxy  
✔ Backend linked  
✔ SSL enabled  
✔ Path-based routing  
✔ WebSocket support  
✔ Optimized configuration

---
