# Caching - Performance Optimization

## Overview
Caching is a critical technique for improving application performance by storing frequently accessed data in fast memory (RAM) instead of repeatedly querying slow data sources like databases or external APIs.

---

## What is Caching?

**Caching** means storing data temporarily in a fast location (RAM) so you don't repeatedly access slow storage (database, disk, external API).

### Simple Analogy
Instead of opening the fridge every time (slow), you keep your favorite drink on your table (fast).

### Why Caching Matters

**Without Cache:**
- Every request hits the database
- Database becomes slow under load
- Application response time increases
- High load can crash the database

**With Cache:**
- First request hits database
- Subsequent requests hit cache (RAM)
- Response time: 1-5ms instead of 50-500ms
- Database load reduced by 80-95%

---

## Learning Path

### Beginner Level
1. **[Caching Fundamentals](0-CACHING.md)** - Start here
   - What is caching and why it's needed
   - Cache-aside pattern explained
   - Popular profiles cache example
   - Cache strategies overview
   - TTL and expiration basics

2. **[System Design Patterns](3-System-Design-Patterns.md)**
   - Common caching architectures
   - When to use each pattern
   - Real-world examples

### Intermediate Level - Redis
3. **[Redis Fundamentals](Redis/0-Redis-Fundamentals.md)**
   - Redis architecture and data structures
   - Strings, hashes, lists, sets, sorted sets
   - TTL and expiry management
   - Pub/Sub and Streams
   - Persistence and security

4. **[Node.js + Redis Example](Redis/1-NodeJS-Redis-Example.md)**
   - Practical cache-aside implementation
   - Express.js integration
   - Error handling and fallbacks

5. **[Go + Redis Example](Redis/2-Go-Redis-Example.md)**
   - Go Redis client usage
   - Production patterns
   - Performance optimization

### Advanced Level - Production
6. **[Redis Deployment](Redis/3-Redis-Deployment.md)**
   - VM deployment
   - Docker deployment
   - Kubernetes deployment
   - Configuration management

7. **[Redis High Availability](Redis/4-Redis-High-Availability.md)**
   - Master-Replica with Sentinel
   - Redis Cluster (sharding + HA)
   - Backup strategies
   - Monitoring and alerting

---

## Quick Reference

### Common Cache Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Cache-Aside** | App checks cache, loads from DB on miss | Most common, read-heavy apps |
| **Read-Through** | Cache loads data automatically on miss | Simplified app logic |
| **Write-Through** | Write to cache and DB simultaneously | Strong consistency needed |
| **Write-Back** | Write to cache, DB updated async | High write performance |
| **Write-Around** | Write directly to DB, bypass cache | Infrequent reads |

### Cache Eviction Policies

| Policy | Description | Best For |
|--------|-------------|----------|
| **LRU** | Least Recently Used | General purpose |
| **LFU** | Least Frequently Used | Stable access patterns |
| **TTL** | Time-based expiration | Time-sensitive data |
| **FIFO** | First In First Out | Simple queues |
| **Random** | Random eviction | High traffic systems |

### Redis Data Types

| Type | Use Case | Example |
|------|----------|---------|
| **String** | Simple values, counters | Session tokens, feature flags |
| **Hash** | Structured data | User profiles, product info |
| **List** | Queues, stacks | Job queues, message buffers |
| **Set** | Unique items | Online users, tags |
| **Sorted Set** | Rankings, priorities | Leaderboards, rate limiting |
| **Stream** | Event logs | Activity feeds, audit logs |

---

## Common Use Cases

### Application Caching
- **API Response Caching** - Cache expensive API calls
- **Page Caching** - Store rendered HTML pages
- **Session Storage** - User session data
- **Token Caching** - Authentication tokens
- **Configuration** - App settings and feature flags

### Performance Optimization
- **Database Query Results** - Reduce DB load
- **Computed Values** - Cache expensive calculations
- **External API Responses** - Reduce API calls
- **Static Assets** - CDN caching
- **Search Results** - Cache search queries

### Real-Time Features
- **Leaderboards** - Gaming, social apps
- **Rate Limiting** - API throttling
- **Counters** - Analytics, metrics
- **Pub/Sub** - Real-time notifications
- **Presence** - Online/offline status

---

## Cache Problems and Solutions

### Cache Miss
**Problem:** Data not in cache, must fetch from source
**Solution:** 
- Implement cache warming
- Use predictive pre-loading
- Monitor miss rates

### Cache Stampede
**Problem:** Many requests hit DB when cache expires
**Solution:**
- Staggered TTL
- Cache locking
- Background refresh

### Stale Data
**Problem:** Cache contains outdated information
**Solution:**
- Short TTL
- Event-driven invalidation
- Version-based caching

### Hot Key Problem
**Problem:** One key gets extremely high traffic
**Solution:**
- Shard the key
- Replicate hot data
- Use local cache layer

### Memory Overflow
**Problem:** Cache grows too large
**Solution:**
- Set max memory limits
- Configure eviction policies
- Monitor memory usage

---

## Redis Architecture Patterns

### Single Instance
```
Application → Redis (Single Node) → Database
```
**Use:** Development, small applications
**Pros:** Simple, easy to setup
**Cons:** No high availability

### Master-Replica with Sentinel
```
Application → Redis Sentinel → Primary Redis
                              → Replica Redis
                              → Replica Redis
```
**Use:** Production with HA needs
**Pros:** Automatic failover, read scaling
**Cons:** More complex setup

### Redis Cluster
```
Application → Redis Cluster (Sharded)
              ├─ Shard 1 (Primary + Replicas)
              ├─ Shard 2 (Primary + Replicas)
              └─ Shard 3 (Primary + Replicas)
```
**Use:** Large-scale, high-traffic applications
**Pros:** Horizontal scaling, built-in HA
**Cons:** Most complex, requires cluster-aware clients

---

## Best Practices

### Design
- ✅ Always set TTL on cache keys
- ✅ Use appropriate data structures
- ✅ Implement cache warming for critical data
- ✅ Design for cache failures (fallback to DB)
- ✅ Use consistent key naming conventions

### Performance
- ✅ Keep values small (< 1MB)
- ✅ Use pipelining for bulk operations
- ✅ Monitor cache hit rates (target > 80%)
- ✅ Use connection pooling
- ✅ Implement circuit breakers

### Security
- ✅ Enable authentication (requirepass)
- ✅ Use TLS for network encryption
- ✅ Never expose Redis publicly
- ✅ Implement network isolation
- ✅ Regular security audits

### Operations
- ✅ Monitor memory usage
- ✅ Set up alerts for high memory
- ✅ Regular backups (RDB/AOF)
- ✅ Test failover procedures
- ✅ Document runbooks

### Development
- ✅ Use cache abstraction layers
- ✅ Implement graceful degradation
- ✅ Log cache operations
- ✅ Test with cache disabled
- ✅ Version cache keys

---

## Performance Metrics

### Key Metrics to Track

| Metric | Target | Description |
|--------|--------|-------------|
| **Hit Rate** | > 80% | Percentage of requests served from cache |
| **Latency** | < 5ms | Average response time |
| **Memory Usage** | < 80% | Percentage of max memory used |
| **Evictions** | Low | Number of keys evicted |
| **Connections** | Stable | Active client connections |

### Redis INFO Command
```bash
# Memory stats
INFO memory

# Stats overview
INFO stats

# Replication status
INFO replication

# Client connections
INFO clients
```

---

## Troubleshooting Guide

### High Memory Usage
1. Check key count: `DBSIZE`
2. Find large keys: `MEMORY USAGE key`
3. Check eviction policy: `CONFIG GET maxmemory-policy`
4. Review TTL settings
5. Implement key expiration

### Slow Performance
1. Check latency: `redis-cli --latency`
2. Monitor slow queries: `SLOWLOG GET 10`
3. Check memory fragmentation
4. Review client connection count
5. Check network latency

### Connection Issues
1. Verify Redis is running: `redis-cli PING`
2. Check network connectivity
3. Verify authentication
4. Check connection limits
5. Review firewall rules

### Data Loss
1. Check persistence settings
2. Verify backup schedule
3. Review AOF/RDB files
4. Check disk space
5. Test restore procedures

---

## Real-World Example

### E-commerce Product Catalog

**Without Cache:**
```
User Request → API → Database Query (500ms) → Response
```

**With Cache:**
```
User Request → API → Redis Check (2ms) → Response (Cache Hit)
                   → Database Query (500ms) → Redis Store → Response (Cache Miss)
```

**Results:**
- 95% cache hit rate
- Average response time: 50ms → 5ms (10x faster)
- Database load reduced by 95%
- Can handle 10x more traffic

---

## Tools and Resources

### Redis Tools
- **redis-cli** - Command-line interface
- **RedisInsight** - GUI for Redis
- **redis-benchmark** - Performance testing
- **redis-exporter** - Prometheus metrics

### Monitoring
- **Prometheus + Grafana** - Metrics and dashboards
- **Redis Sentinel** - High availability monitoring
- **CloudWatch/Datadog** - Managed monitoring

### Libraries
- **Node.js:** `ioredis`, `redis`
- **Go:** `go-redis/redis`
- **Python:** `redis-py`
- **Java:** `Jedis`, `Lettuce`

---

## Directory Structure

```
CACHING/
├── README.md                           # This file
├── 0-CACHING.md                        # Caching fundamentals
├── 3-System-Design-Patterns.md         # Architecture patterns
├── Screenshot 2025-11-24 220538.png    # Cache-aside diagram
├── Screenshot 2025-11-24 220631.png    # Popular profiles diagram
│
└── Redis/                              # Redis-specific content
    ├── 0-Redis-Fundamentals.md         # Redis basics and commands
    ├── 1-NodeJS-Redis-Example.md       # Node.js implementation
    ├── 2-Go-Redis-Example.md           # Go implementation
    ├── 3-Redis-Deployment.md           # Deployment strategies
    ├── 4-Redis-High-Availability.md    # HA and clustering
    └── docker-compose.yml              # Docker setup
```

---

## Quick Start

### 1. Run Redis Locally
```bash
# Using Docker
docker run -d --name redis -p 6379:6379 redis:7-alpine

# Test connection
redis-cli PING
```

### 2. Basic Operations
```bash
# Set value with TTL
SET user:123 "John Doe" EX 60

# Get value
GET user:123

# Check TTL
TTL user:123
```

### 3. Implement in Your App
See [Node.js Example](Redis/1-NodeJS-Redis-Example.md) or [Go Example](Redis/2-Go-Redis-Example.md)

---

## Related Topics
- [DevOps Core](../README.md) - Main documentation
- [Observability](../OBSERVABILITY/) - Monitoring caching systems
- [Containerization](../CONTAINERIZATION/) - Deploying Redis in containers
- [Networking](../NETWORKING/) - Network configuration for Redis

---

**Last Updated:** January 2026
**Maintained by:** DevOps Documentation Team
