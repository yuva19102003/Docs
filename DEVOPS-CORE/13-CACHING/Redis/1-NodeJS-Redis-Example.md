
## 1️⃣ Node.js + Redis (cache-aside example)

**Use case:**  
Get `user/:id` from DB.  
If present in Redis → return from cache.  
If not → read from DB → put into Redis with TTL.

### Install

```bash
npm init -y
npm install express redis
```

### `index.js`

```js
import express from "express";
import { createClient } from "redis";

const app = express();
const PORT = 3000;

// ---- Redis client ----
const redis = createClient({
  url: "redis://localhost:6379",
});

redis.on("error", (err) => console.error("Redis error", err));

await redis.connect();

// ---- Fake DB call ----
async function getUserFromDB(id) {
  console.log("⏳ Hitting DB for user", id);
  // pretend DB latency
  await new Promise((r) => setTimeout(r, 500));
  return { id, name: "User " + id, role: "admin" };
}

// ---- Route with caching ----
app.get("/users/:id", async (req, res) => {
  const { id } = req.params;
  const cacheKey = `user:${id}`;

  try {
    // 1) Check cache
    const cached = await redis.get(cacheKey);
    if (cached) {
      console.log("⚡ Cache hit");
      return res.json({ from: "cache", data: JSON.parse(cached) });
    }

    // 2) Cache miss → DB
    console.log("🐢 Cache miss");
    const user = await getUserFromDB(id);

    // 3) Store in cache with TTL 60s
    await redis.set(cacheKey, JSON.stringify(user), { EX: 60 });

    return res.json({ from: "db", data: user });
  } catch (err) {
    console.error(err);
    // On Redis failure, still fall back to DB
    const user = await getUserFromDB(id);
    return res.json({ from: "db-no-cache", data: user });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

Hit `http://localhost:3000/users/1` multiple times — first call is slow (DB), later ones fast (cache).

---
