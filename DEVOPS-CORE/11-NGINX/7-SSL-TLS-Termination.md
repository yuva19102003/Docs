
# 🚀 **SSL/TLS Termination — What It Means**

**SSL/TLS termination** means:

- Client connects to **NGINX via HTTPS**
    
- NGINX **decrypts** the traffic
    
- Sends **plain HTTP** internally to your backend services
    

```
Client (HTTPS)
       ↓
   NGINX (SSL Termination) → Backend (HTTP)
```

Benefits:

✔ Backend doesn’t need SSL  
✔ Faster performance  
✔ Central place for certificates  
✔ Easy renewal + rotation  
✔ Works well in microservices

---

# 🧱 **1. Requirements**

You need:

- A domain → example.com
    
- A server → Ubuntu / Debian / CentOS
    
- NGINX installed
    
- Port 80 and 443 open
    

---

# 📌 **2. Install NGINX**

```bash
sudo apt update
sudo apt install nginx -y
```

---

# 🔑 **3. Install Certbot (Free SSL — Let’s Encrypt)**

```bash
sudo apt install certbot python3-certbot-nginx -y
```

---

# 🌐 **4. Create Reverse Proxy (Before SSL)**

Example backend:

```bash
sudo nano /etc/nginx/sites-available/myapp
```

```
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable:

```bash
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

# 🔥 **5. Enable SSL/TLS Termination**

Run Certbot:

```bash
sudo certbot --nginx -d example.com -d www.example.com
```

Certbot will:

✔ Install SSL  
✔ Configure HTTPS  
✔ Redirect HTTP → HTTPS automatically  
✔ Create renewal cron  
✔ Generate cert files

---

# 📁 **6. Final NGINX SSL Configuration**

Certbot will generate something like:

```
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com www.example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

NGINX TERMINATES SSL HERE  
↓  
Backend receives **HTTP**.

---

# 🧪 **7. Test SSL**

```
curl -I https://example.com
```

You should see:

```
HTTP/2 200
```

Check certificate:

```
sudo certbot certificates
```

---

# 🔁 **8. Auto Renewal**

Certbot auto-renews daily.  
You can test:

```bash
sudo certbot renew --dry-run
```

---

# 🛡 **9. Strengthen HTTPS Security**

Add inside your HTTPS server block:

```
ssl_prefer_server_ciphers on;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_stapling on;
ssl_stapling_verify on;
```

---

# 🧰 **10. Disable Old TLS Versions (Optional)**

```
ssl_protocols TLSv1.3 TLSv1.2;
```

You get:

✔ Higher score on SSL Labs  
✔ Better security

---

# 🔥 **11. HTTP → HTTPS Redirect (Manual Version)**

If Certbot didn’t create redirect:

```
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```

---

# 🎯 **12. Using Self-Signed Certificate (Local Testing)**

```bash
sudo openssl req -x509 -newkey rsa:4096 -nodes \
 -keyout /etc/nginx/self.key \
 -out /etc/nginx/self.crt \
 -days 365
```

Then configure:

```
ssl_certificate /etc/nginx/self.crt;
ssl_certificate_key /etc/nginx/self.key;
```

---

# 🎉 **SSL/TLS Termination Setup Complete!**

You now have:

✔ HTTPS enabled  
✔ SSL termination at NGINX  
✔ Backend remains HTTP  
✔ Automatic certificate renewal  
✔ Hardened TLS configuration  
✔ Security best practices

---
