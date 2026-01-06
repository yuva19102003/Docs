# Load Balancing Patterns

## Overview
Load balancing distributes incoming network traffic across multiple servers to ensure no single server bears too much load. This improves application responsiveness, availability, and scalability while preventing server overload.

---

## Problem Statement

### Single Server Limitations
```
All Traffic → Single Server
                   │
                   ▼
              ┌─────────┐
              │ Server  │ ← Overloaded!
              │ CPU: 95%│
              │ RAM: 90%│
              └─────────┘
                   │
              Slow Response
              or Crash
```

### Issues Without Load Balancing
- **Single Point of Failure** - Server down = service down
- **Limited Capacity** - Can't handle traffic spikes
- **Poor Performance** - Slow response times under load
- **No Scalability** - Can't add more servers easily
- **Maintenance Downtime** - Updates require service interruption

### When to Use Load Balancing
✅ High traffic applications  
✅ Need high availability (99.9%+)  
✅ Horizontal scaling required  
✅ Zero-downtime deployments  
✅ Geographic distribution  
✅ Microservices architecture  

---

## Architecture Diagram

### Basic Load Balancer Setup
```
                    ┌─────────────────┐
                    │     Client      │
                    └────────┬────────┘
                             │
                             │ HTTPS Request
                             │
                             ▼
                    ┌─────────────────┐
                    │ Load Balancer   │
                    │  (NGINX/HAProxy)│
                    │                 │
                    │ • Health Checks │
                    │ • SSL Termination│
                    │ • Session Sticky│
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   Server 1    │    │   Server 2    │    │   Server 3    │
│               │    │               │    │               │
│ CPU: 45%      │    │ CPU: 50%      │    │ CPU: 40%      │
│ Status: UP    │    │ Status: UP    │    │ Status: DOWN  │
│ Connections:50│    │ Connections:60│    │ (Unhealthy)   │
└───────────────┘    └───────────────┘    └───────────────┘
        │                    │                    
        └────────────────────┴────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Database     │
                    └─────────────────┘
```

### Multi-Layer Load Balancing
```
                         ┌──────────┐
                         │  Client  │
                         └─────┬────┘
                               │
                               ▼
                    ┌──────────────────┐
                    │   DNS (Route53)  │
                    │  Geographic LB   │
                    └─────┬────────────┘
                          │
            ┌─────────────┼─────────────┐
            │             │             │
            ▼             ▼             ▼
      ┌──────────┐  ┌──────────┐  ┌──────────┐
      │ US-East  │  │ US-West  │  │  Europe  │
      │   LB     │  │   LB     │  │   LB     │
      └────┬─────┘  └────┬─────┘  └────┬─────┘
           │             │             │
    ┌──────┴──────┐      │      ┌──────┴──────┐
    │             │      │      │             │
    ▼             ▼      ▼      ▼             ▼
┌────────┐  ┌────────┐  ...  ┌────────┐  ┌────────┐
│ App 1  │  │ App 2  │       │ App 1  │  │ App 2  │
└────────┘  └────────┘       └────────┘  └────────┘
```

---

## Load Balancing Algorithms

### 1. Round Robin
**Description:** Distributes requests sequentially across servers

```
Request 1 → Server 1
Request 2 → Server 2
Request 3 → Server 3
Request 4 → Server 1  (cycle repeats)
Request 5 → Server 2
Request 6 → Server 3
```

**Pros:**
- Simple to implement
- Fair distribution
- No server state needed

**Cons:**
- Doesn't consider server load
- Ignores server capacity differences
- No session affinity

**Use Case:** Stateless applications with similar server specs

**NGINX Configuration:**
```nginx
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### 2. Weighted Round Robin
**Description:** Assigns weights to servers based on capacity

```
Server 1 (weight: 3) → Gets 3 requests
Server 2 (weight: 2) → Gets 2 requests
Server 3 (weight: 1) → Gets 1 request

Pattern: S1, S1, S1, S2, S2, S3, (repeat)
```

**NGINX Configuration:**
```nginx
upstream backend {
    server backend1.example.com weight=3;  # Powerful server
    server backend2.example.com weight=2;  # Medium server
    server backend3.example.com weight=1;  # Smaller server
}
```

**Use Case:** Servers with different capacities

### 3. Least Connections
**Description:** Routes to server with fewest active connections

```
Server 1: 10 connections
Server 2: 5 connections  ← Next request goes here
Server 3: 8 connections
```

**Pros:**
- Better for long-lived connections
- Considers current load
- Dynamic load distribution

**Cons:**
- Requires connection tracking
- More complex than round robin

**NGINX Configuration:**
```nginx
upstream backend {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}
```

**Use Case:** Applications with varying request processing times

### 4. Least Response Time
**Description:** Routes to server with lowest response time

```
Server 1: 200ms average
Server 2: 150ms average ← Next request goes here
Server 3: 300ms average
```

**Use Case:** Performance-critical applications

### 5. IP Hash
**Description:** Routes based on client IP address hash

```
Client IP: 192.168.1.100
Hash(192.168.1.100) % 3 = 1
→ Always routes to Server 1
```

**Pros:**
- Session persistence
- No session storage needed
- Simple implementation

**Cons:**
- Uneven distribution possible
- Doesn't handle server failures well

**NGINX Configuration:**
```nginx
upstream backend {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}
```

**Use Case:** Applications requiring session affinity

### 6. Consistent Hashing
**Description:** Minimizes redistribution when servers change

```
Hash Ring:
    0° ─────────────────────────────── 360°
    │    S1    │    S2    │    S3    │
    
Client Hash: 45° → Routes to S1
Client Hash: 180° → Routes to S2

If S2 fails:
    │    S1    │         S3          │
    
Only S2's clients redistributed (not all clients)
```

**Use Case:** Distributed caching, CDN

### 7. Random
**Description:** Randomly selects a server

```
Request 1 → Server 2
Request 2 → Server 1
Request 3 → Server 3
Request 4 → Server 2
```

**Use Case:** Simple stateless applications

---

## Load Balancer Types

### Layer 4 (Transport Layer) Load Balancing
```
┌──────────┐
│  Client  │
└────┬─────┘
     │ TCP/UDP
     ▼
┌─────────────────┐
│  L4 Load Balancer│
│  (TCP/UDP)      │
│                 │
│ • Fast          │
│ • No SSL decrypt│
│ • IP/Port based │
└────┬────────────┘
     │
     ▼
┌─────────────┐
│   Servers   │
└─────────────┘
```

**Characteristics:**
- Routes based on IP and port
- No content inspection
- Very fast (low latency)
- Can't make routing decisions based on HTTP headers

**Tools:**
- AWS Network Load Balancer (NLB)
- HAProxy (L4 mode)
- NGINX (stream module)

**Configuration Example:**
```nginx
stream {
    upstream backend {
        server backend1.example.com:3306;
        server backend2.example.com:3306;
    }
    
    server {
        listen 3306;
        proxy_pass backend;
    }
}
```

### Layer 7 (Application Layer) Load Balancing
```
┌──────────┐
│  Client  │
└────┬─────┘
     │ HTTPS
     ▼
┌─────────────────┐
│  L7 Load Balancer│
│  (HTTP/HTTPS)   │
│                 │
│ • Content-aware │
│ • SSL termination│
│ • URL routing   │
│ • Header inspect│
└────┬────────────┘
     │
     ├─ /api/* → API Servers
     ├─ /static/* → Static Servers
     └─ /* → App Servers
```

**Characteristics:**
- Routes based on HTTP content
- Can inspect headers, cookies, URL
- SSL termination
- Content-based routing
- Slower than L4 (more processing)

**Tools:**
- AWS Application Load Balancer (ALB)
- NGINX
- HAProxy
- Traefik

**Configuration Example:**
```nginx
upstream api_servers {
    server api1.example.com;
    server api2.example.com;
}

upstream web_servers {
    server web1.example.com;
    server web2.example.com;
}

server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Route API requests
    location /api/ {
        proxy_pass http://api_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Route web requests
    location / {
        proxy_pass http://web_servers;
        proxy_set_header Host $host;
    }
}
```

---

## Health Checks

### Active Health Checks
**Load balancer actively probes servers**

```
┌─────────────────┐
│ Load Balancer   │
└────┬────────────┘
     │
     │ Every 5s: GET /health
     │
     ├─────────────────────────────┐
     │                             │
     ▼                             ▼
┌─────────────┐              ┌─────────────┐
│  Server 1   │              │  Server 2   │
│ Status: 200 │              │ Status: 500 │
│ ✓ Healthy   │              │ ✗ Unhealthy │
└─────────────┘              └─────────────┘
```

**NGINX Configuration:**
```nginx
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    
    # Health check (NGINX Plus)
    health_check interval=5s
                 fails=3
                 passes=2
                 uri=/health
                 match=health_ok;
}

match health_ok {
    status 200;
    body ~ "OK";
}
```

**HAProxy Configuration:**
```
backend web_servers
    option httpchk GET /health
    http-check expect status 200
    
    server web1 192.168.1.10:80 check inter 5s fall 3 rise 2
    server web2 192.168.1.11:80 check inter 5s fall 3 rise 2
```

### Passive Health Checks
**Monitor actual traffic for failures**

```
Request → Server 1 → 500 Error (count: 1)
Request → Server 1 → 500 Error (count: 2)
Request → Server 1 → 500 Error (count: 3)
→ Mark Server 1 as unhealthy
→ Stop sending traffic
```

**NGINX Configuration:**
```nginx
upstream backend {
    server backend1.example.com max_fails=3 fail_timeout=30s;
    server backend2.example.com max_fails=3 fail_timeout=30s;
}
```

---

## Session Persistence (Sticky Sessions)

### Cookie-Based Stickiness
```
1. Client → Load Balancer
2. LB assigns Server 1
3. LB sets cookie: server_id=1
4. Client → LB (with cookie)
5. LB reads cookie → routes to Server 1
```

**NGINX Configuration:**
```nginx
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    
    sticky cookie srv_id expires=1h domain=.example.com path=/;
}
```

### IP-Based Stickiness
```nginx
upstream backend {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
}
```

---

## SSL/TLS Termination

### SSL Termination at Load Balancer
```
┌──────────┐
│  Client  │
└────┬─────┘
     │ HTTPS (encrypted)
     ▼
┌─────────────────┐
│ Load Balancer   │
│ • Decrypt SSL   │
│ • Certificate   │
└────┬────────────┘
     │ HTTP (plain)
     ▼
┌─────────────┐
│   Servers   │
└─────────────┘
```

**Benefits:**
- Offload SSL processing from servers
- Centralized certificate management
- Easier to inspect traffic

**NGINX Configuration:**
```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### End-to-End Encryption
```
┌──────────┐
│  Client  │
└────┬─────┘
     │ HTTPS (encrypted)
     ▼
┌─────────────────┐
│ Load Balancer   │
│ • SSL Passthrough│
└────┬────────────┘
     │ HTTPS (encrypted)
     ▼
┌─────────────┐
│   Servers   │
│ • Decrypt   │
└─────────────┘
```

---

## Implementation Examples

### NGINX Load Balancer
```nginx
# /etc/nginx/nginx.conf

http {
    # Upstream servers
    upstream web_backend {
        least_conn;
        
        server web1.example.com:8080 weight=3 max_fails=3 fail_timeout=30s;
        server web2.example.com:8080 weight=2 max_fails=3 fail_timeout=30s;
        server web3.example.com:8080 weight=1 max_fails=3 fail_timeout=30s backup;
        
        keepalive 32;
    }
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;
    
    server {
        listen 80;
        server_name example.com;
        
        # Redirect to HTTPS
        return 301 https://$server_name$request_uri;
    }
    
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        # SSL Configuration
        ssl_certificate /etc/ssl/certs/example.com.crt;
        ssl_certificate_key /etc/ssl/private/example.com.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # Security headers
        add_header Strict-Transport-Security "max-age=31536000" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        
        # Logging
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        
        # Rate limiting
        limit_req zone=mylimit burst=20 nodelay;
        
        location / {
            proxy_pass http://web_backend;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            
            # Keep-alive
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

### HAProxy Configuration
```
# /etc/haproxy/haproxy.cfg

global
    log /dev/log local0
    maxconn 4096
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

frontend https_front
    bind *:443 ssl crt /etc/ssl/certs/example.com.pem
    
    # ACLs
    acl is_api path_beg /api
    acl is_static path_beg /static
    
    # Routing
    use_backend api_servers if is_api
    use_backend static_servers if is_static
    default_backend web_servers

backend web_servers
    balance leastconn
    option httpchk GET /health
    http-check expect status 200
    
    server web1 192.168.1.10:8080 check inter 5s fall 3 rise 2
    server web2 192.168.1.11:8080 check inter 5s fall 3 rise 2
    server web3 192.168.1.12:8080 check inter 5s fall 3 rise 2 backup

backend api_servers
    balance roundrobin
    option httpchk GET /api/health
    
    server api1 192.168.1.20:8080 check
    server api2 192.168.1.21:8080 check

backend static_servers
    balance roundrobin
    
    server static1 192.168.1.30:8080 check
    server static2 192.168.1.31:8080 check

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
```

### AWS Application Load Balancer (Terraform)
```hcl
# ALB
resource "aws_lb" "main" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = true
  enable_http2              = true

  tags = {
    Name = "web-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600
    enabled         = true
  }
}

# Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Listener Rule (Path-based routing)
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
```

---

## Monitoring & Metrics

### Key Metrics
```
┌─────────────────────────────────────────┐
│      Load Balancer Metrics              │
├─────────────────────────────────────────┤
│ • Requests per second                   │
│ • Active connections                    │
│ • Response time (p50, p95, p99)         │
│ • Error rate (4xx, 5xx)                 │
│ • Healthy/Unhealthy hosts               │
│ • Backend connection errors             │
│ • SSL handshake time                    │
│ • Bytes in/out                          │
└─────────────────────────────────────────┘
```

### Prometheus Exporter
```yaml
# docker-compose.yml
version: '3.8'
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
  
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    ports:
      - "9113:9113"
    command:
      - -nginx.scrape-uri=http://nginx:8080/stub_status
```

---

## Best Practices

### Configuration
✅ **Enable Health Checks** - Detect failures quickly  
✅ **Set Appropriate Timeouts** - Prevent hanging connections  
✅ **Use Connection Pooling** - Reuse backend connections  
✅ **Enable Keep-Alive** - Reduce connection overhead  
✅ **Configure SSL Properly** - Use modern TLS versions  

### Security
✅ **Rate Limiting** - Prevent abuse  
✅ **DDoS Protection** - Use cloud provider features  
✅ **Security Headers** - HSTS, CSP, etc.  
✅ **IP Whitelisting** - Restrict admin access  
✅ **Regular Updates** - Keep software patched  

### Performance
✅ **Enable Caching** - Cache static content  
✅ **Compression** - Enable gzip/brotli  
✅ **HTTP/2** - Use modern protocols  
✅ **CDN Integration** - Offload static content  
✅ **Connection Limits** - Prevent resource exhaustion  

---

## Pros & Cons

### Advantages
✅ **High Availability** - No single point of failure  
✅ **Scalability** - Easy to add servers  
✅ **Performance** - Distribute load evenly  
✅ **Flexibility** - Multiple routing strategies  
✅ **Zero Downtime** - Rolling deployments  
✅ **SSL Offloading** - Centralized certificate management  

### Disadvantages
❌ **Complexity** - Additional component to manage  
❌ **Cost** - Hardware/cloud costs  
❌ **Single Point of Failure** - LB itself can fail  
❌ **Latency** - Additional network hop  
❌ **Session Management** - Sticky sessions complexity  

---

## Related Patterns
- [API Gateway Pattern](03-API-Gateway-Pattern.md)
- [Circuit Breaker Pattern](08-Circuit-Breaker.md)
- [Rate Limiting Pattern](09-Rate-Limiting.md)
- [CDN Architecture](11-CDN-Architecture.md)

---

## Tools & Resources

### Software Load Balancers
- **NGINX** - High-performance web server and LB
- **HAProxy** - Reliable, high-performance LB
- **Traefik** - Cloud-native edge router
- **Envoy** - Modern proxy for service mesh

### Cloud Load Balancers
- **AWS ALB/NLB** - Application/Network load balancers
- **Google Cloud Load Balancing** - Global load balancing
- **Azure Load Balancer** - Layer 4 load balancing
- **Cloudflare** - Global CDN with load balancing

---

**Last Updated:** January 5, 2026  
**Pattern Complexity:** Medium  
**Recommended For:** All production applications requiring high availability
