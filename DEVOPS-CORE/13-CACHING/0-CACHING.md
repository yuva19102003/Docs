
# 🧠 **What Is Caching? (Simple Definition)**

**Caching means storing data temporarily in a fast place (RAM) so that we don’t repeatedly go to a slow place (database).**

Think of it like:

- Instead of opening the fridge (slow)
    
- You keep your favourite drink on your table (fast)
    

---

# ⚡ Why Caching Is Needed?

Without cache:

- Every request → goes to DB
    
- DB becomes slow
    
- App becomes slow
    
- High load = DB crashes
    

With cache:

- Only first request hits DB
    
- Next thousands of requests hit cache
    
- System becomes super fast
    

---

# 📘 **Understanding Your First Diagram — Cache Aside Pattern**

This diagram shows one of the MOST COMMON caching strategies:  
👉 **Cache-Aside (Lazy Loading)**

Let's break it down.
![Cache-Aside Pattern](./Screenshot%202025-11-24%20220538.png)

---

# 🟢 **1. First Request (Cache MISS)**

_(Cache MISS = Not found in cache)_

### 🔹 Step-by-step:

### **Step 1: Web server asks cache → "Do you have this data?"**

Cache replies → ❌ **No**

### **Step 2: Web server goes to the database**

DB returns the actual data → ✔️

### **Step 3: Web server stores that data into cache**

Cache now saves the data in memory → ⚡

### **Step 4: Web server returns the response to user**

---

# 🟡 **2. Subsequent Requests (Cache HIT)**

_(Cache HIT = Found in cache)_

Now the data is already stored in cache.

### 🔹 Step-by-step:

### **Step 1: Web server again asks cache**

This time cache replies → ✔️ **Yes I have it**

### **Step 2: Cache instantly returns data**

Only 1–5 milliseconds → ⚡ SUPER FAST

No database is touched.  
No extra load.

---

# 🟠 Why This Pattern Is Called “Lazy Loading”?

Because:

- System does NOT store in cache by default
    
- It waits until someone asks for the data the first time
    

Only when the first request comes → cache is filled.

---

# 👤 **Understanding Your Second Diagram — Popular Profiles Cache**

This is an example of using cache for **hot data** (frequently accessed data).
![Popular Profiles Cache](./Screenshot%202025-11-24%20220631.png)
### Example:

Think of Instagram:

- Some users have **millions of profile visits**
    
- Their profiles would overload DB
    

So what Instagram does:

👉 It caches “popular profiles”  
👉 All requests for these profiles go directly to cache

---

# 📘 **Flow in This Diagram**

### 1️⃣ User requests a profile

Web server receives the request

### 2️⃣ Web server sends request to cache

If profile is popular → it already exists

### 3️⃣ Cache returns the profile

Super fast → no DB hit

### 4️⃣ Database is only used for NEW or LESS POPULAR users

Not for every request

---

# 🧰 **Why Redis Is Used for Cache?**

Redis is perfect for this because:

✔ It stores data in RAM (insanely fast)  
✔ Distributed (works across multiple servers)  
✔ Supports TTL (auto-expire data)  
✔ Good for session storage  
✔ Good for rate limiting  
✔ Good for real-time counters  
✔ Most popular cache tool globally

---

# 🏗️ **Full Cache Tutorial (Easy to Understand)**

---

# **1️⃣ When do you use caching?**

You use caching when:

- Database queries are slow
    
- Same data is requested frequently
    
- External API calls are expensive
    
- You have heavy traffic
    

Examples:

- Profile info
    
- Leaderboards
    
- Product pages
    
- Blockchain RPC data
    
- Dashboard metrics
    

---

# **2️⃣ Where does Redis sit in your architecture?**

```
Client → Backend → Redis Cache → Database
```

---

# **3️⃣ Popular Cache Strategies (explained like a story)**

---

## 🟢 A. Cache Aside (Lazy Load) — **Most used**

Already explained using your diagram.

Use when:

- Read-heavy apps
    
- Data doesn’t change frequently
    

Example:

- Profile info
    
- Product details
    

---

## 🟡 B. Write Through Cache

Write goes to:

1. Cache
    
2. Database
    

At the same time.

Useful when you want cache + DB always in sync.

---

## 🟠 C. Write Back (Write Behind)

Write goes **only to cache** → Redis writes to DB later.

Fastest writes  
But can lose data if cache crashes.

---

# **4️⃣ Cache Expiry — TTL**

Every cached key can expire automatically.

Example:

```
SET user:123 {"name": "Yuva"} EX 60
```

Meaning:

- Store profile for 60 seconds
    
- After that → auto delete
    

Helps avoid stale data.

---

# **5️⃣ Eviction Policies (When Cache Memory Is Full)**

Redis will remove:

- LRU → Least recently used
    
- LFU → Least frequently used
    
- TTL → Keys with expiry first
    
- NOEVICTION → Return error if full
    

---

# **6️⃣ Cache Problems (Simple Explanation)**

---

### ❌ Cache Miss

Data not found → Goes to DB.

---

### ❌ Cache Stampede

When cache expires → thousands of users hit DB at once.

Solution:

- Staggered TTL
    
- Cache locking
    
- Background refresh
    

---

### ❌ Stale Data

Cache contains old information.

Solution:

- Short TTL
    
- Invalidate when updating
    

---

# 🪄 **Real-World Example (Sui Network Monitoring)**

When you track:

- Epoch
    
- Checkpoints
    
- Transaction count
    
- Validator count
    
- Gas price
    

Instead of calling RPC every second:

👉 Store values in Redis for 5–10 seconds  
👉 All dashboards read from Redis  
👉 Backend becomes lightning fast  
👉 RPC node is safe from heavy load

---

# 🧩 **Summary (Very Simple)**

### ✔ Cache = fast memory

### ✔ Redis = the most powerful caching tool

### ✔ Cache Aside = most common approach

### ✔ First request → DB

### ✔ Next requests → Redis

### ✔ Fewer DB hits = faster system

### ✔ Great for dashboards, profiles, blockchain data

---
