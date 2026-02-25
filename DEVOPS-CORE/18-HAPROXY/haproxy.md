# 🔥 1️⃣ What is HAProxy?

HAProxy = High Availability Proxy

It works as:

* Layer 4 (TCP) load balancer
* Layer 7 (HTTP) load balancer
* Reverse proxy
* SSL terminator

Used in:

* SaaS platforms
* Fintech systems
* Large-scale web apps

---

# 🔥 2️⃣ Install HAProxy (Local)

## 🟢 Windows (Docker Recommended)

```bash
docker run -d -p 80:80 haproxy
```

## 🟢 Ubuntu

```bash
sudo apt update
sudo apt install haproxy
```

Config file location:

```bash
/etc/haproxy/haproxy.cfg
```

---

# 🔥 3️⃣ Basic HAProxy Config Structure

Main config file:

```bash
haproxy.cfg
```

Structure:

```haproxy
global
defaults
frontend
backend
listen
```

---

# 🔥 4️⃣ Simple Reverse Proxy Example

Goal:

```
Client → HAProxy → Backend (port 3000)
```

### haproxy.cfg

```haproxy
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5s
    timeout client 50s
    timeout server 50s

frontend http_front
    bind *:80
    default_backend app_servers

backend app_servers
    server app1 127.0.0.1:3000
```

Restart:

```bash
sudo systemctl restart haproxy
```

---

# 🔥 5️⃣ Load Balancing (Multiple Servers)

```
Client → HAProxy → app1
                     app2
```

```haproxy
backend app_servers
    balance roundrobin
    server app1 127.0.0.1:3000 check
    server app2 127.0.0.1:3001 check
```

Algorithms:

* roundrobin
* leastconn
* source
* uri

---

# 🔥 6️⃣ Health Checks

Notice:

```haproxy
check
```

HAProxy checks if backend is alive.

If one fails:

* Traffic automatically stops to that server.

You can customize:

```haproxy
server app1 127.0.0.1:3000 check inter 5s fall 3 rise 2
```

---

# 🔥 7️⃣ SSL Termination

First generate certificate:

```bash
cat cert.pem key.pem > haproxy.pem
```

Config:

```haproxy
frontend https_front
    bind *:443 ssl crt /etc/ssl/haproxy.pem
    default_backend app_servers
```

Now HAProxy handles HTTPS.

---

# 🔥 8️⃣ Sticky Sessions (Important for Stateful Apps)

Used when:

* Sessions stored in memory
* Need same user → same backend

```haproxy
backend app_servers
    balance roundrobin
    cookie SERVERID insert indirect nocache
    server app1 127.0.0.1:3000 check cookie s1
    server app2 127.0.0.1:3001 check cookie s2
```

---

# 🔥 9️⃣ HAProxy Stats Dashboard

Add:

```haproxy
listen stats
    bind *:8404
    stats enable
    stats uri /
    stats refresh 10s
```

Access:

```
http://localhost:8404
```

Shows live backend status.

---

# 🔥 10️⃣ HAProxy With Docker Compose

## docker-compose.yml

```yaml
services:
  backend1:
    image: nginx
    expose:
      - "80"

  backend2:
    image: nginx
    expose:
      - "80"

  haproxy:
    image: haproxy:latest
    ports:
      - "80:80"
      - "8404:8404"
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
```

## haproxy.cfg

```haproxy
global
    daemon

defaults
    mode http

frontend http_front
    bind *:80
    default_backend web

backend web
    balance roundrobin
    server web1 backend1:80 check
    server web2 backend2:80 check

listen stats
    bind *:8404
    stats enable
    stats uri /
```

Run:

```bash
docker compose up
```

---

# 🔥 11️⃣ Layer 4 (TCP Mode)

For database load balancing:

```haproxy
frontend tcp_front
    bind *:3306
    default_backend mysql_servers

backend mysql_servers
    mode tcp
    balance leastconn
    server db1 127.0.0.1:3306 check
```

---

# 🔥 12️⃣ Advanced Routing (Path-Based)

```haproxy
frontend http_front
    bind *:80
    acl is_api path_beg /api
    use_backend api_servers if is_api
    default_backend web_servers
```

---

# 🔥 13️⃣ Production Best Practices

* Enable logging
* Set maxconn properly
* Use timeouts
* Enable health checks
* Use SSL offloading
* Monitor stats endpoint
* Use keep-alive tuning

---

# 🔥 14️⃣ Common Errors

502 → Backend down
503 → No backend available
Connection refused → Wrong IP/Port
Timeout → Backend slow

---

# 🔥 15️⃣ HAProxy vs NGINX

| HAProxy       | NGINX                 |
| ------------- | --------------------- |
| Strong L4     | Strong static serving |
| Enterprise LB | Web server + LB       |
| Very fast     | More flexible         |

---

# 🧠 Real DevOps Architecture Example

```
Internet
   ↓
HAProxy (SSL termination)
   ↓
App Servers (Docker/K8s)
   ↓
Database
```

---

