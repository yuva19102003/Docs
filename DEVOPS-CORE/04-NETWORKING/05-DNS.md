# 🌍 How DNS Resolution Actually Works (Step-by-Step)

When a user enters:

```
https://example.com
```

### 1️⃣ Browser checks local cache

### 2️⃣ OS checks system DNS cache

### 3️⃣ Router cache

### 4️⃣ Recursive Resolver (ISP / Public DNS)

### 5️⃣ Root Nameserver

### 6️⃣ TLD Nameserver (.com)

### 7️⃣ Authoritative Nameserver

### 8️⃣ Returns IP address

Then browser connects to that IP.

---

# 🔥 Important DNS Record Types (DevOps Must Know)

---

# 1️⃣ A Record

Maps domain → IPv4 address

```
example.com → 203.0.113.10
```

### Used For:

* Web servers
* Load balancer IP
* Static server mapping

### DevOps Debug:

If site not loading:

```
dig example.com
```

Check returned IP.

---

# 2️⃣ AAAA Record

Maps domain → IPv6 address

```
example.com → 2001:db8::1
```

Important when infrastructure supports IPv6.

---

# 3️⃣ CNAME Record

Maps one domain → another domain

```
www → example.com
```

Not IP → Domain to domain.

### Rules:

* Cannot exist with other records at same hostname.
* Not allowed at root (in pure DNS standard).

---

# 4️⃣ MX Record (Mail Exchange)

Defines mail server.

```
Priority 10 → mail1.example.com
Priority 20 → mail2.example.com
```

Lower number = higher priority.

---

# 5️⃣ TXT Record

Stores text data.

Used for:

* Domain verification
* Email SPF
* DKIM
* DMARC
* Security proofs

Example:

```
v=spf1 include:_spf.provider.com ~all
```

---

# 6️⃣ NS Record (Nameserver)

Defines who controls DNS for domain.

```
ns1.provider.com
ns2.provider.com
```

Changing NS = moving DNS control.

---

# 7️⃣ SOA Record (Start of Authority)

Contains:

* Primary nameserver
* Email of admin
* Serial number
* Refresh time
* Retry time
* Expiry
* TTL

Important for DNS replication.

---

# 8️⃣ SRV Record

Defines service location with port.

Example:

```
_service._tcp.example.com
```

Used in:

* SIP
* LDAP
* Kubernetes
* Internal services

---

# 9️⃣ CAA Record

Controls which Certificate Authorities can issue SSL certificates.

Example:

```
example.com CAA 0 issue "letsencrypt.org"
```

Security-focused record.

---

# 🔥 DNS TTL (Time To Live)

Every record has TTL:

```
TTL = 300 seconds
```

Meaning cache for 5 minutes.

### DevOps Strategy:

Before migration:

* Lower TTL to 60 seconds
* Perform change
* Raise TTL back

---

# 🔥 DNS Propagation Reality

Propagation is not magic.

It depends on:

* TTL
* Resolver cache
* ISP caching

It is caching delay, not "internet propagation".

---

# 🔥 Common Production DNS Issues

---

## 🚨 1. Wrong IP in A record

Site unreachable.

---

## 🚨 2. Missing AAAA record but server supports IPv6

Partial users can’t access site.

---

## 🚨 3. CNAME + A record conflict

DNS resolution failure.

---

## 🚨 4. High TTL during migration

Users hit old server.

---

## 🚨 5. MX misconfiguration

Emails stop working.

---

# 🔥 DevOps Debug Commands

---

## Check A record

```
dig example.com
```

---

## Check specific record type

```
dig example.com MX
dig example.com TXT
dig example.com NS
```

---

## Trace full resolution path

```
dig +trace example.com
```

Shows root → TLD → authoritative flow.

---

## Check from another DNS resolver

```
dig example.com @8.8.8.8
```

---

## Check DNS quickly

```
nslookup example.com
```

---

# 🔥 Advanced DevOps DNS Concepts

---

## 🔹 Split-Horizon DNS

Internal users resolve to private IP
External users resolve to public IP

Used in:

* VPC internal services
* Hybrid cloud

---

## 🔹 DNS Load Balancing

Multiple A records:

```
example.com → 1.1.1.1
example.com → 2.2.2.2
```

DNS rotates responses.

Not true health-aware load balancing.

---

## 🔹 Failover Strategy

Primary A record
Secondary A record
Low TTL for faster failover

---

## 🔹 DNS and CDN Interaction

When using reverse proxy:

* DNS points to proxy
* Proxy points to origin

Understanding this is critical.

---

# 🔥 1️⃣ Difference Between A Record and CNAME

### ✅ A Record

* Maps a domain → **IPv4 address**
* Direct resolution
* Faster lookup (1 step)

Example:

```
example.com → 203.0.113.10
```

### ✅ CNAME Record

* Maps a domain → **another domain**
* Indirect resolution (extra DNS lookup)

Example:

```
www.example.com → example.com
```

### 🔥 Key Differences

| A Record                     | CNAME                              |
| ---------------------------- | ---------------------------------- |
| Points to IP                 | Points to domain                   |
| Faster resolution            | Extra DNS lookup                   |
| Can exist with other records | Cannot coexist with other records  |
| Used at root domain          | Not allowed at root (standard DNS) |

### 💬 Interview Answer (Short Version)

> An A record maps a domain directly to an IP address, while a CNAME maps a domain to another domain name. CNAME adds an extra resolution step and cannot coexist with other record types at the same hostname.

---

# 🔥 2️⃣ Why Can't Root Domain Have CNAME?

Root domain (example.com) must contain:

* NS record
* SOA record

DNS standards say:

> A CNAME record cannot exist with any other record at the same name.

Since root must already have NS and SOA, adding CNAME would violate DNS rules.

That’s why:

* Subdomains → can use CNAME
* Root domain → must use A or ALIAS/ANAME (provider workaround)

### 💬 Interview Answer

> Because the root domain must contain SOA and NS records, and DNS standards do not allow a CNAME to coexist with other record types at the same name.

---

# 🔥 3️⃣ What Happens When TTL is High?

TTL = Time To Live (cache duration in seconds)

Example:

```
TTL = 86400 (24 hours)
```

Effects:

* DNS changes propagate slowly
* Users may hit old server
* Hard to rollback quickly
* Failover becomes slow

### 🔥 DevOps Impact

If migrating servers:

* High TTL = downtime risk
* Low TTL (60–300 seconds) = safer migration

### 💬 Interview Answer

> High TTL causes DNS responses to be cached longer, making infrastructure changes slow to propagate and reducing flexibility during migrations or failover events.

---

# 🔥 4️⃣ How to Migrate Server Without Downtime?

This is a very important DevOps scenario.

---

## ✅ Step-by-Step Zero Downtime Migration

### Step 1 – Lower TTL

Reduce TTL from:

```
86400 → 60 seconds
```

Wait for old TTL to expire.

---

### Step 2 – Prepare New Server

* Deploy application
* Test internally
* Sync database
* Verify SSL

---

### Step 3 – Switch A Record

Change IP to new server.

Because TTL is low:

* Most users switch within 1–5 minutes.

---

### Step 4 – Monitor Logs

Watch:

* Error rates
* CPU
* Traffic
* 5xx errors

---

### Step 5 – Increase TTL Again

After stable:

```
TTL = 3600 or 86400
```

---

### 🔥 Advanced Approach

For large systems:

* Blue-Green deployment
* Load balancer switch
* Gradual traffic shift

---

### 💬 Interview Answer

> Lower TTL in advance, prepare and test the new server, update DNS to point to the new IP, monitor traffic, then increase TTL once stable. This ensures minimal caching delay and avoids downtime.

---

# 🔥 5️⃣ What Is SOA Serial Used For?

SOA = Start of Authority

It contains:

* Primary nameserver
* Admin email
* Serial number
* Refresh interval
* Retry interval
* Expiry time

---

## 🔥 Serial Number Purpose

It tells secondary DNS servers:

> “Zone file has changed.”

If serial increases:

* Secondary servers pull updated records.

If serial doesn’t change:

* No update happens.

---

### Example Serial Format

```
2026022401
```

Common format:

```
YYYYMMDDNN
```

---

### 💬 Interview Answer

> The SOA serial number is used for zone versioning. When the serial increases, secondary DNS servers know the zone file has been updated and synchronize the changes.

---

# 🔥 Bonus: Strong DevOps-Level Summary

If interviewer asks all together:

* A record → Direct IP mapping
* CNAME → Domain alias
* Root can't use CNAME → Because SOA and NS must coexist
* High TTL → Slower propagation, risky for migration
* Zero downtime → Lower TTL, switch after preparation
* SOA serial → Zone replication control

---
