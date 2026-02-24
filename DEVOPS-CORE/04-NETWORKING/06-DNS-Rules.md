# 🔥 Types of Rules Every DevOps Engineer Must Know

We’ll keep it vendor-neutral and production-focused.

---

# 1️⃣ Redirect Rules

Used to send traffic somewhere else.

### Example Use Cases:

* HTTP → HTTPS
* Old domain → new domain
* Force www → non-www
* Maintenance redirect

---

### Status Codes Used:

* 301 (Permanent)
* 302 (Temporary)
* 307 / 308 (Strict method preservation)

---

### Example Logic:

```
If host == example.com
→ Redirect to https://www.example.com (301)
```

---

# 2️⃣ Rewrite Rules

Changes URL internally without redirecting browser.

User sees:

```
example.com/blog
```

Backend receives:

```
example.com/index.php?page=blog
```

Used in:

* Clean URLs
* SEO routing
* API version mapping

---

# 3️⃣ Header Rules

Modify request or response headers.

### Examples:

Add security header:

```
Strict-Transport-Security
X-Frame-Options
X-Content-Type-Options
```

Add cache control:

```
Cache-Control: max-age=3600
```

Used for:

* Security hardening
* Performance tuning
* CORS handling

---

# 4️⃣ Cache Rules

Control what gets cached.

### Examples:

Cache only:

```
/images/*
/static/*
```

Don’t cache:

```
/api/*
/admin/*
```

Important for:

* Performance
* Reducing backend load
* Scaling

---

# 5️⃣ Rate Limiting Rules

Protect against abuse.

Example:

```
If IP sends > 100 requests per minute
→ Block for 10 minutes
```

Used for:

* Prevent brute force
* Protect login APIs
* Stop scraping
* Stop DDoS (basic layer)

---

# 6️⃣ Firewall / WAF Rules

Security filtering layer.

Block based on:

* IP
* Country
* User-Agent
* Path
* Bot score
* Request pattern

Example:

```
If country == X
→ Block
```

Or:

```
If path contains /wp-admin
→ Challenge
```

---

# 7️⃣ Origin Routing Rules

Control backend routing.

Example:

```
If path starts with /api
→ Send to backend A

If path starts with /static
→ Send to backend B
```

Used in:

* Microservices
* Kubernetes ingress
* Multi-server architecture

---

# 🔥 Rule Evaluation Order (CRITICAL)

This is very important in interviews.

Rules are evaluated:

1. Top → Bottom
2. First match wins (usually)

So order matters.

If you place:

Rule 1: Redirect all traffic
Rule 2: Allow /health

Rule 2 will never execute.

---

# 🔥 Common Production Mistakes

### ❌ Redirect Loop

Redirecting HTTP → HTTPS while server already forces HTTPS.

---

### ❌ Blocking Yourself

Firewall rule blocks your office IP.

---

### ❌ Caching API Responses

Leads to users seeing wrong data.

---

### ❌ Rate limiting Load Balancer Health Checks

System marks server unhealthy.

---

# 🔥 DevOps Debug Strategy for Rule Issues

If something breaks:

1. Check redirect status code:

   ```
   curl -I domain
   ```

2. Check headers:

   ```
   curl -I -v domain
   ```

3. Check rule order

4. Temporarily disable suspicious rule

5. Check logs

---
