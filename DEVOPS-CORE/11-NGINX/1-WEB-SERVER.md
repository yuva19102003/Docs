
# 🚀 **END-TO-END TUTORIAL: WEB SERVER USING NGINX**

This tutorial includes:

1️⃣ Install NGINX  
2️⃣ Set up file structure  
3️⃣ Create a website  
4️⃣ Configure NGINX server block  
5️⃣ Enable & test  
6️⃣ Deploy with firewall rules  
7️⃣ Add HTTPS (SSL)  
8️⃣ Logs + Monitoring  
9️⃣ Performance tuning

---

# ✅ **1. Install NGINX**

### **Ubuntu / Debian**

```bash
sudo apt update
sudo apt install nginx -y
```

Start + enable:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Check status:

```bash
systemctl status nginx
```

Check default page:  
Visit **http://YOUR_SERVER_IP**

---

# ✅ **2. Create Your Website Directory**

You should not use `/var/www/html`.  
Create your own folder:

```bash
sudo mkdir -p /var/www/mywebsite
sudo chown -R $USER:$USER /var/www/mywebsite
```

Add sample site:

```bash
nano /var/www/mywebsite/index.html
```

Paste:

```html
<h1>Hello from my Nginx Web Server 🚀</h1>
<p>Deployment successful!</p>
```

Save → exit.

---

# ✅ **3. Create NGINX Server Block (Virtual Host)**

Create a config file:

```bash
sudo nano /etc/nginx/sites-available/mywebsite
```

Paste this:

```
server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/mywebsite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

> Replace `example.com` with your domain or public server IP.

---

# ✅ **4. Enable the Site**

Enable the config file:

```bash
sudo ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled/
```

Disable the default site (optional but recommended):

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Test configuration:

```bash
sudo nginx -t
```

Reload:

```bash
sudo systemctl reload nginx
```

Now your website lives at:

👉 [http://your-domain](http://your-domain/)  
or  
👉 [http://your-server-ip](http://your-server-ip/)

---

# 🔥 **5. Setup Firewall (Important)**

If using **UFW**:

```bash
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

---

# 🔒 **6. Add HTTPS (Free SSL Certificate)**

Use **Certbot (Let's Encrypt)**:

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
```

Run:

```bash
sudo certbot --nginx -d example.com -d www.example.com
```

Certbot will:

✔ Auto-configure HTTPS  
✔ Auto-redirect HTTP → HTTPS  
✔ Renew certificates automatically (cron job)

---

# 📁 **7. NGINX Directory Structure Overview**

|Path|Description|
|---|---|
|`/etc/nginx/nginx.conf`|Main config|
|`/etc/nginx/sites-available/`|Virtual hosts (inactive)|
|`/etc/nginx/sites-enabled/`|Active sites|
|`/var/www/mywebsite/`|Website files|
|`/var/log/nginx/`|Access + error logs|

---

# 📊 **8. Logging + Monitoring**

### View access logs

```bash
tail -f /var/log/nginx/access.log
```

### View error logs

```bash
tail -f /var/log/nginx/error.log
```

### Basic monitoring command

```bash
sudo systemctl status nginx
```

---

# ⚡ **9. Performance Optimization Basics**

### Enable GZIP compression

Edit:

```bash
sudo nano /etc/nginx/nginx.conf
```

Add inside `http {}`:

```
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

---

### Increase worker connections

Inside `nginx.conf`:

```
worker_processes auto;
events {
    worker_connections 4096;
}
```

---

# 🎉 Deployment Completed!

✔ NGINX installed  
✔ Website directory created  
✔ Virtual host configured  
✔ Firewall set  
✔ HTTPS added  
✔ Logs working  
✔ Performance optimized

---
