
## 2️⃣ Go + Redis (cache-aside example)

### Install

```bash
go mod init redis-demo
go get github.com/redis/go-redis/v9
go get github.com/gin-gonic/gin
```

### `main.go`

```go
package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
)

var (
	ctx   = context.Background()
	rdb   *redis.Client
)

type User struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Role string `json:"role"`
}

func getUserFromDB(id string) (*User, error) {
	log.Println("⏳ Hitting DB for user", id)
	time.Sleep(500 * time.Millisecond) // simulate DB delay
	return &User{ID: id, Name: "User " + id, Role: "admin"}, nil
}

func main() {
	// ---- Redis client ----
	rdb = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})

	if err := rdb.Ping(ctx).Err(); err != nil {
		log.Fatal("Redis connection failed:", err)
	}

	router := gin.Default()

	router.GET("/users/:id", getUserHandler)

	log.Println("Server running on :3000")
	if err := router.Run(":3000"); err != nil {
		log.Fatal(err)
	}
}

func getUserHandler(c *gin.Context) {
	id := c.Param("id")
	cacheKey := "user:" + id

	// 1) try cache
	val, err := rdb.Get(ctx, cacheKey).Result()
	if err == nil {
		log.Println("⚡ Cache hit")
		var u User
		if err := json.Unmarshal([]byte(val), &u); err == nil {
			c.JSON(http.StatusOK, gin.H{"from": "cache", "data": u})
			return
		}
	} else if err != redis.Nil {
		log.Println("Redis error:", err)
	}

	// 2) cache miss → DB
	log.Println("🐢 Cache miss")
	user, err := getUserFromDB(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "db error"})
		return
	}

	// 3) store in cache with TTL
	data, _ := json.Marshal(user)
	if err := rdb.Set(ctx, cacheKey, data, 60*time.Second).Err(); err != nil {
		log.Println("Redis set error:", err)
	}

	c.JSON(http.StatusOK, gin.H{"from": "db", "data": user})
}
```

---
