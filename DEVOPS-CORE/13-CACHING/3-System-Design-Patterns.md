# Caching System Design Patterns

## Overview
This guide covers common caching architectures and patterns used in production systems. Understanding these patterns helps you design scalable, performant applications.

---

## 1. Basic Cache-Aside Pattern (Lazy Loading)

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│  Redis  │         │ Database │
│          │         │              │         │  Cache  │         │          │
└──────────┘         └──────────────┘         └─────────┘         └──────────┘
                            │                      │                     │
                            │  1. Check Cache      │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │  2. Cache Miss       │                     │
                            │◄─────────────────────│                     │
                            │                                            │
                            │  3. Query Database                         │
                            │───────────────────────────────────────────►│
                            │                                            │
                            │  4. Return Data                            │
                            │◄───────────────────────────────────────────│
                            │                                            │
                            │  5. Store in Cache   │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │  6. Return to Client │                     │
                            │                      │                     │
```

### Flow Explanation
1. **Client Request** → API Server receives request
2. **Check Cache** → API checks Redis for data
3. **Cache Miss** → Data not found in cache
4. **Query Database** → Fetch from primary database
5. **Store in Cache** → Save result in Redis with TTL
6. **Return Response** → Send data to client

### When to Use
- ✅ Read-heavy applications
- ✅ Data doesn't change frequently
- ✅ Acceptable to have slightly stale data
- ✅ Most common pattern (90% of use cases)

### Pros & Cons
**Pros:**
- Simple to implement
- Cache only what's needed
- Resilient (cache failure doesn't break app)

**Cons:**
- First request is always slow (cold start)
- Cache stampede risk on expiry
- Requires cache invalidation logic

---

## 2. Read-Through Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│  Cache Layer    │────────►│ Database │
│          │         │              │         │  (Smart Cache)  │         │          │
└──────────┘         └──────────────┘         └─────────────────┘         └──────────┘
                            │                          │                         │
                            │  1. Request Data         │                         │
                            │─────────────────────────►│                         │
                            │                          │                         │
                            │                          │  2. Cache Miss          │
                            │                          │  (Auto-fetch from DB)   │
                            │                          │────────────────────────►│
                            │                          │                         │
                            │                          │  3. Return Data         │
                            │                          │◄────────────────────────│
                            │                          │                         │
                            │  4. Return to Client     │                         │
                            │◄─────────────────────────│                         │
```

### Flow Explanation
1. **Client Request** → API requests data from cache layer
2. **Cache Handles Everything** → Cache layer checks itself
3. **Auto-Fetch on Miss** → Cache automatically loads from DB
4. **Return Response** → Cache returns data to API

### When to Use
- ✅ Want to simplify application code
- ✅ Cache layer can handle DB logic
- ✅ Using cache proxy/middleware

### Pros & Cons
**Pros:**
- Simplified application logic
- Consistent caching behavior
- Centralized cache management

**Cons:**
- More complex cache layer
- Tight coupling between cache and DB
- Harder to debug

---

## 3. Write-Through Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│  Redis  │────────►│ Database │
│          │         │              │         │  Cache  │         │          │
└──────────┘         └──────────────┘         └─────────┘         └──────────┘
                            │                      │                     │
                            │  1. Write Data       │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │                      │  2. Write to DB     │
                            │                      │────────────────────►│
                            │                      │                     │
                            │                      │  3. Confirm Write   │
                            │                      │◄────────────────────│
                            │                      │                     │
                            │  4. Confirm to API   │                     │
                            │◄─────────────────────│                     │
                            │                      │                     │
                            │  5. Return Success   │                     │
```

### Flow Explanation
1. **Write Request** → Client sends data to update
2. **Write to Cache** → Data written to Redis first
3. **Write to Database** → Cache writes to DB synchronously
4. **Confirm Write** → DB confirms successful write
5. **Return Success** → Client receives confirmation

### When to Use
- ✅ Need strong consistency
- ✅ Read-heavy with occasional writes
- ✅ Can tolerate slower writes

### Pros & Cons
**Pros:**
- Cache always consistent with DB
- No stale data
- Simple read logic

**Cons:**
- Slower writes (synchronous)
- Cache can fill with unused data
- Higher write latency

---

## 4. Write-Back (Write-Behind) Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│  Redis  │────────►│ Database │
│          │         │              │         │  Cache  │  Async  │          │
└──────────┘         └──────────────┘         └─────────┘  Write  └──────────┘
                            │                      │                     │
                            │  1. Write Data       │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │  2. Immediate ACK    │                     │
                            │◄─────────────────────│                     │
                            │                      │                     │
                            │                      │  3. Async Write     │
                            │                      │  (Later/Batch)      │
                            │                      │────────────────────►│
```

### Flow Explanation
1. **Write Request** → Client sends data
2. **Write to Cache Only** → Data written to Redis
3. **Immediate Response** → Client gets instant confirmation
4. **Async DB Write** → Redis writes to DB later (batched)

### When to Use
- ✅ Need extremely fast writes
- ✅ Can tolerate potential data loss
- ✅ Write-heavy applications

### Pros & Cons
**Pros:**
- Fastest write performance
- Can batch writes for efficiency
- Reduces DB load

**Cons:**
- Risk of data loss if cache crashes
- Complex to implement correctly
- Eventual consistency only

---

## 5. Write-Around Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │         │  Redis  │         │ Database │
│          │         │              │         │  Cache  │         │          │
└──────────┘         └──────────────┘         └─────────┘         └──────────┘
                            │                      │                     │
                            │  1. Write Data       │                     │
                            │  (Bypass Cache)      │                     │
                            │─────────────────────────────────────────►  │
                            │                      │                     │
                            │  2. Confirm Write    │                     │
                            │◄─────────────────────────────────────────  │
                            │                      │                     │
                            │  3. Read Request     │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │  4. Cache Miss       │                     │
                            │                      │  5. Fetch from DB   │
                            │                      │────────────────────►│
```

### Flow Explanation
1. **Write Request** → Data written directly to database
2. **Bypass Cache** → Cache is not updated on write
3. **Read Request** → Later read checks cache
4. **Cache Miss** → Data not in cache yet
5. **Load from DB** → Fetch and cache on first read

### When to Use
- ✅ Data written once, read rarely
- ✅ Want to avoid cache pollution
- ✅ Write-heavy with infrequent reads

### Pros & Cons
**Pros:**
- Prevents cache pollution
- Good for write-heavy workloads
- Simple write logic

**Cons:**
- First read after write is slow
- Cache miss rate can be high
- Not suitable for read-heavy apps

---

## 6. Refresh-Ahead Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│  Smart Cache    │────────►│ Database │
│          │         │              │         │  (Predictive)   │         │          │
└──────────┘         └──────────────┘         └─────────────────┘         └──────────┘
                            │                          │                         │
                            │  1. Request Data         │                         │
                            │─────────────────────────►│                         │
                            │                          │                         │
                            │  2. Return Cached Data   │                         │
                            │◄─────────────────────────│                         │
                            │                          │                         │
                            │                          │  3. Proactive Refresh   │
                            │                          │  (Before TTL expires)   │
                            │                          │────────────────────────►│
                            │                          │                         │
                            │                          │  4. Update Cache        │
                            │                          │◄────────────────────────│
```

### Flow Explanation
1. **Read Request** → Client requests data
2. **Return from Cache** → Serve from cache
3. **Proactive Refresh** → Before TTL expires, refresh data
4. **Update Cache** → Keep cache fresh automatically

### When to Use
- ✅ Predictable access patterns
- ✅ Cannot tolerate cache misses
- ✅ Data changes regularly but predictably

### Pros & Cons
**Pros:**
- Eliminates cache misses
- Always fresh data
- Predictable performance

**Cons:**
- Complex to implement
- Can waste resources on unused data
- Requires access pattern prediction

---

## 7. Multi-Level Cache Pattern

### Architecture Diagram
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│   L1    │────────►│   L2    │────────►│ Database │
│          │         │              │         │  Local  │         │  Redis  │         │          │
└──────────┘         └──────────────┘         │  Cache  │         │  Cache  │         └──────────┘
                            │                  └─────────┘         └─────────┘
                            │                      │                     │
                            │  1. Check L1         │                     │
                            │─────────────────────►│                     │
                            │                      │                     │
                            │  2. L1 Miss          │                     │
                            │  3. Check L2         │                     │
                            │─────────────────────────────────────────►  │
                            │                      │                     │
                            │  4. L2 Hit           │                     │
                            │◄─────────────────────────────────────────  │
                            │                      │                     │
                            │  5. Store in L1      │                     │
                            │─────────────────────►│                     │
```

### Flow Explanation
1. **Check L1** → Check local in-memory cache first
2. **L1 Miss** → Not in local cache
3. **Check L2** → Check Redis (shared cache)
4. **L2 Hit** → Found in Redis
5. **Populate L1** → Store in local cache for next time

### When to Use
- ✅ Need ultra-low latency
- ✅ Have multiple application instances
- ✅ Hot data accessed very frequently

### Pros & Cons
**Pros:**
- Fastest possible reads
- Reduces Redis load
- Scales horizontally

**Cons:**
- Cache invalidation complexity
- Potential inconsistency between L1 caches
- More memory usage

---

## 8. Complete Production Architecture

### Full System Diagram
```
                                    ┌─────────────────────────────────────┐
                                    │      Load Balancer / CDN            │
                                    └──────────────┬──────────────────────┘
                                                   │
                    ┌──────────────────────────────┼──────────────────────────────┐
                    │                              │                              │
            ┌───────▼────────┐          ┌─────────▼────────┐          ┌─────────▼────────┐
            │  API Server 1  │          │  API Server 2    │          │  API Server 3    │
            │  (with L1)     │          │  (with L1)       │          │  (with L1)       │
            └───────┬────────┘          └─────────┬────────┘          └─────────┬────────┘
                    │                              │                              │
                    └──────────────────────────────┼──────────────────────────────┘
                                                   │
                                        ┌──────────▼──────────┐
                                        │   Redis Cluster     │
                                        │   (L2 Cache)        │
                                        │   - Sharded         │
                                        │   - Replicated      │
                                        └──────────┬──────────┘
                                                   │
                                        ┌──────────▼──────────┐
                                        │   Database          │
                                        │   (Primary)         │
                                        │   + Read Replicas   │
                                        └─────────────────────┘
                                                   │
                                        ┌──────────▼──────────┐
                                        │   Monitoring        │
                                        │   - Prometheus      │
                                        │   - Grafana         │
                                        └─────────────────────┘
```

### Components Explained

**Load Balancer / CDN:**
- Distributes traffic across API servers
- Caches static assets at edge
- SSL termination

**API Servers (Multiple Instances):**
- L1 cache: In-memory (local to each instance)
- Business logic
- Horizontal scaling

**Redis Cluster (L2 Cache):**
- Shared cache across all API servers
- Sharded for horizontal scaling
- Replicated for high availability
- TTL-based expiration

**Database:**
- Primary for writes
- Read replicas for scaling reads
- Persistent storage

**Monitoring:**
- Track cache hit rates
- Monitor latency
- Alert on issues

---

## 9. Cache Invalidation Strategies

### Event-Driven Invalidation
```
┌──────────┐         ┌──────────────┐         ┌─────────┐         ┌──────────┐
│  Client  │────────►│  API Server  │────────►│ Database│────────►│  Kafka   │
│          │  Write  │              │  Write  │         │  Event  │  Events  │
└──────────┘         └──────────────┘         └─────────┘         └────┬─────┘
                                                                        │
                                                                        │ Consume
                                                                        │
                                                              ┌─────────▼─────────┐
                                                              │  Cache Invalidator│
                                                              │  Service          │
                                                              └─────────┬─────────┘
                                                                        │
                                                                        │ Delete
                                                                        │
                                                                  ┌─────▼─────┐
                                                                  │   Redis   │
                                                                  │   Cache   │
                                                                  └───────────┘
```

### TTL-Based Invalidation
- Set expiration time on all cache keys
- Automatic cleanup
- Simple but can serve stale data

### Manual Invalidation
- Delete cache keys on data updates
- Immediate consistency
- Requires careful implementation

---

## 10. Choosing the Right Pattern

### Decision Matrix

| Requirement | Recommended Pattern |
|-------------|---------------------|
| Read-heavy, simple | Cache-Aside |
| Need consistency | Write-Through |
| Need speed | Write-Back |
| Infrequent reads | Write-Around |
| Zero cache misses | Refresh-Ahead |
| Ultra-low latency | Multi-Level |
| Simplified code | Read-Through |

### Performance Comparison

| Pattern | Read Speed | Write Speed | Consistency | Complexity |
|---------|------------|-------------|-------------|------------|
| Cache-Aside | Fast | Fast | Eventual | Low |
| Read-Through | Fast | Fast | Eventual | Medium |
| Write-Through | Fast | Slow | Strong | Medium |
| Write-Back | Fast | Very Fast | Eventual | High |
| Write-Around | Medium | Fast | Strong | Low |
| Refresh-Ahead | Very Fast | Fast | Strong | High |
| Multi-Level | Ultra Fast | Fast | Eventual | Very High |

---

## Best Practices

1. **Always set TTL** - Prevent memory leaks
2. **Monitor hit rates** - Target > 80%
3. **Handle cache failures** - Graceful degradation
4. **Use consistent key naming** - `resource:id:field`
5. **Implement circuit breakers** - Protect against cascading failures
6. **Test cache invalidation** - Ensure data consistency
7. **Monitor memory usage** - Set appropriate limits
8. **Use compression** - For large values
9. **Implement retry logic** - Handle transient failures
10. **Document cache strategy** - For team understanding

---

## Related Topics
- [Caching Fundamentals](0-CACHING.md)
- [Redis Fundamentals](Redis/0-Redis-Fundamentals.md)
- [Redis High Availability](Redis/4-Redis-High-Availability.md) 
