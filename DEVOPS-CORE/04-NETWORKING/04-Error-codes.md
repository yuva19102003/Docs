# 🔥 Complete HTTP Status Code Guide (DevOps Version)

---

# 🟢 1xx – Informational (Rarely Used in Debugging)

| Code | Meaning             | DevOps Note          |
| ---- | ------------------- | -------------------- |
| 100  | Continue            | Client can send body |
| 101  | Switching Protocols | WebSocket upgrade    |

Usually not part of troubleshooting.

---

# 🟢 2xx – Success Codes

These mean the server handled the request correctly.

| Code | Meaning    | When You See It             |
| ---- | ---------- | --------------------------- |
| 200  | OK         | Normal website/API response |
| 201  | Created    | Resource created (POST)     |
| 202  | Accepted   | Async job started           |
| 204  | No Content | Health checks / DELETE      |

### 🔎 DevOps Tip:

If load balancer health check expects 200 but app returns 204 → can cause unhealthy status.

---

# 🟡 3xx – Redirection (Infrastructure-Level Important)

| Code | Meaning                   | DevOps Usage      |
| ---- | ------------------------- | ----------------- |
| 301  | Permanent Redirect        | Domain migration  |
| 302  | Temporary Redirect        | Short testing     |
| 307  | Temporary (strict method) | API-safe redirect |
| 308  | Permanent (strict method) | Modern 301        |

---

### 🔥 301 vs 302 Difference (Very Important)

| 301                        | 302                      |
| -------------------------- | ------------------------ |
| Browser caches permanently | Browser may not cache    |
| SEO transfers authority    | No SEO transfer          |
| Used in domain migration   | Used in temporary switch |

---

# 🔴 4xx – Client Errors (VERY COMMON)

These happen because of request issues.

---

## 🔹 400 – Bad Request

Malformed request.

**Causes:**

* Invalid JSON
* Wrong headers
* Corrupt cookies

---

## 🔹 401 – Unauthorized

Authentication required.

**Cause:**

* Missing token
* Expired JWT
* Wrong API key

---

## 🔹 403 – Forbidden

Server understood request but refuses.

**Common DevOps Causes:**

* Cloudflare WAF block
* Security group restriction
* Nginx deny rule
* IP blocked

---

## 🔹 404 – Not Found

Resource doesn’t exist.

**Causes:**

* Wrong route
* Deployment missing files
* Wrong ingress path (Kubernetes)

---

## 🔹 405 – Method Not Allowed

Wrong HTTP method used.

Example:
POST on GET-only route.

---

## 🔹 408 – Request Timeout

Client too slow.

---

## 🔹 409 – Conflict

Data conflict (DB level).

---

## 🔹 413 – Payload Too Large

Upload exceeded limit.

Often caused by:

* Nginx `client_max_body_size`
* Cloudflare upload limit

---

## 🔹 429 – Too Many Requests

Rate limiting.

Caused by:

* API gateway limit
* Cloudflare rate limiting
* WAF rule

---

# 🔥 5xx – Server Errors (Critical)

These are backend/server/infrastructure problems.

---

## 🔹 500 – Internal Server Error

Application crashed.

Check:

* App logs
* Stack trace
* Runtime error

---

## 🔹 501 – Not Implemented

Feature not supported.

---

## 🔹 502 – Bad Gateway (VERY COMMON)

Gateway received invalid response from backend.

Common Causes:

* Backend down
* Wrong upstream IP
* Docker container crashed
* Wrong port mapping
* Load balancer target unhealthy

DevOps golden rule:

> 502 = Upstream problem

---

## 🔹 503 – Service Unavailable

Server overloaded or down.

Causes:

* Auto-scaling delay
* Too much traffic
* Maintenance mode

---

## 🔹 504 – Gateway Timeout (VERY IMPORTANT)

Gateway waited too long.

Causes:

* Slow DB
* Slow backend API
* Long-running query
* Timeout mismatch (Nginx vs app)

DevOps rule:

> 504 = Performance problem

---

# 🔥 Cloudflare-Specific Errors (Important for You)

| Code | Meaning                 |
| ---- | ----------------------- |
| 520  | Unknown error           |
| 521  | Web server down         |
| 522  | Connection timed out    |
| 523  | Origin unreachable      |
| 525  | SSL handshake failed    |
| 526  | Invalid SSL certificate |

Example:
522 → Your server not responding
525 → SSL mode mismatch

---

# 🧠 DevOps Debug Flow Based on Status Code

### If 4xx:

* Check request
* Check auth
* Check WAF

### If 5xx:

* Check backend
* Check logs
* Check container status
* Check health checks
* Check timeouts

---

# 🔥 Real Interview Question

If interviewer asks:

> What is difference between 502 and 504?

Correct Answer:

* 502 → Bad response from upstream
* 504 → No response within timeout

---

# ⚡ Quick Cheat Sheet

| Code | Check This    |
| ---- | ------------- |
| 401  | Auth          |
| 403  | Firewall/WAF  |
| 404  | Route/Ingress |
| 429  | Rate limit    |
| 500  | App logs      |
| 502  | Backend down  |
| 503  | Overload      |
| 504  | Slow backend  |

---
