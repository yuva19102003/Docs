# Memorystore - Managed Redis and Memcached

Complete guide to Google Cloud Memorystore - fully managed in-memory data store service.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Redis](#redis)
3. [Memcached](#memcached)
4. [Configuration](#configuration)
5. [Data Operations](#data-operations)
6. [High Availability](#high-availability)
7. [Performance](#performance)
8. [Monitoring](#monitoring)
9. [Cost Optimization](#cost-optimization)
10. [Best Practices](#best-practices)

---

## Introduction

Memorystore provides fully managed Redis and Memcached services for sub-millisecond data access.

### Key Features

✅ Sub-millisecond latency  
✅ Fully managed service  
✅ High availability (99.9% SLA)  
✅ Automatic failover  
✅ Scaling support  
✅ VPC integration  
✅ Monitoring and alerting  
✅ Backup and restore (Redis)  
✅ Import/export (Redis)  
✅ Redis 6.x and 7.x support  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│          Memorystore Instance                       │
├─────────────────────────────────────────────────────┤
│  Redis / Memcached                                  │
│  ┌──────────────────────────────────────────────┐   │
│  │  Primary Node                                │   │
│  │  - In-memory data                            │   │
│  │  - Read/Write operations                     │   │
│  └──────────────────────────────────────────────┘   │
│           │                                         │
│           │ Replication (Redis Standard)            │
│           v                                         │
│  ┌──────────────────────────────────────────────┐   │
│  │  Replica Node                                │   │
│  │  - Read operations                           │   │
│  │  - Automatic failover                        │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  VPC Network                                        │
│  - Private IP only                                  │
│  - No public endpoints                              │
└─────────────────────────────────────────────────────┘
```

---

## Redis

### Redis Tiers

| Tier | Description | Availability | Use Case |
|------|-------------|--------------|----------|
| **Basic** | Single node | 99.0% SLA | Development, caching |
| **Standard** | Primary + replica | 99.9% SLA | Production |

### Create Redis Instance

```bash
# Create Basic tier instance
gcloud redis instances create my-redis \
  --size=1 \
  --region=us-central1 \
  --tier=basic \
  --redis-version=redis_7_0

# Create Standard tier instance
gcloud redis instances create prod-redis \
  --size=5 \
  --region=us-central1 \
  --tier=standard \
  --redis-version=redis_7_0 \
  --replica-count=1 \
  --read-replicas-mode=READ_REPLICAS_ENABLED

# Create with specific network
gcloud redis instances create my-redis \
  --size=1 \
  --region=us-central1 \
  --network=projects/PROJECT_ID/global/networks/default \
  --connect-mode=PRIVATE_SERVICE_ACCESS
```

### Redis Versions

- Redis 6.x
- Redis 7.0 (recommended)
- Redis 7.2

### Terraform Configuration

```hcl
resource "google_redis_instance" "cache" {
  name           = "my-redis"
  tier           = "STANDARD_HA"
  memory_size_gb = 5
  region         = "us-central1"
  
  redis_version     = "REDIS_7_0"
  display_name      = "Production Redis"
  reserved_ip_range = "10.0.0.0/29"
  
  authorized_network = google_compute_network.vpc.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  
  redis_configs = {
    maxmemory-policy = "allkeys-lru"
    notify-keyspace-events = "Ex"
  }
  
  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 4
        minutes = 0
      }
    }
  }
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}
```

### Redis Features

**Data Structures:**
- Strings
- Lists
- Sets
- Sorted Sets
- Hashes
- Bitmaps
- HyperLogLogs
- Streams
- Geospatial indexes

**Advanced Features:**
- Pub/Sub messaging
- Transactions
- Lua scripting
- Pipelining
- Persistence (RDB, AOF)
- Replication
- Cluster mode (Redis Cluster)

---

## Memcached

### Create Memcached Instance

```bash
# Create Memcached instance
gcloud memcache instances create my-memcache \
  --node-count=3 \
  --node-cpu=1 \
  --node-memory=1GB \
  --region=us-central1 \
  --memcached-version=memcached_1_6

# Create with specific network
gcloud memcache instances create my-memcache \
  --node-count=3 \
  --node-cpu=1 \
  --node-memory=1GB \
  --region=us-central1 \
  --network=projects/PROJECT_ID/global/networks/default
```

### Terraform Configuration

```hcl
resource "google_memcache_instance" "cache" {
  name               = "my-memcache"
  region             = "us-central1"
  authorized_network = google_compute_network.vpc.id
  
  node_config {
    cpu_count      = 1
    memory_size_mb = 1024
  }
  
  node_count = 3
  
  memcache_version = "MEMCACHE_1_6"
  
  maintenance_policy {
    weekly_maintenance_window {
      day      = "SUNDAY"
      duration = "14400s"
      start_time {
        hours   = 4
        minutes = 0
      }
    }
  }
  
  labels = {
    environment = "production"
  }
}
```

### Memcached vs Redis

| Feature | Redis | Memcached |
|---------|-------|-----------|
| **Data Structures** | Multiple | Key-value only |
| **Persistence** | Yes | No |
| **Replication** | Yes | No |
| **Pub/Sub** | Yes | No |
| **Transactions** | Yes | No |
| **Multi-threading** | No | Yes |
| **Use Case** | Complex caching | Simple caching |

---

## Configuration

### Redis Configuration

```bash
# Update Redis configuration
gcloud redis instances update my-redis \
  --update-redis-config=maxmemory-policy=allkeys-lru,\
timeout=300

# Common Redis configurations
maxmemory-policy: allkeys-lru, volatile-lru, allkeys-lfu, volatile-lfu
timeout: Connection timeout in seconds
notify-keyspace-events: Keyspace notifications
```

**Eviction Policies:**

| Policy | Description |
|--------|-------------|
| **noeviction** | Return error when memory limit reached |
| **allkeys-lru** | Evict least recently used keys |
| **volatile-lru** | Evict LRU keys with expire set |
| **allkeys-lfu** | Evict least frequently used keys |
| **volatile-lfu** | Evict LFU keys with expire set |
| **allkeys-random** | Evict random keys |
| **volatile-random** | Evict random keys with expire set |
| **volatile-ttl** | Evict keys with shortest TTL |

### Scaling

```bash
# Scale Redis instance
gcloud redis instances update my-redis \
  --size=10

# Scale Memcached nodes
gcloud memcache instances update my-memcache \
  --node-count=5
```

---

## Data Operations

### Redis Operations

**Python Client:**

```python
import redis

# Connect to Redis
r = redis.Redis(
    host='10.0.0.3',
    port=6379,
    decode_responses=True
)

# String operations
r.set('key', 'value')
r.set('key', 'value', ex=3600)  # With expiration
value = r.get('key')

# Hash operations
r.hset('user:1', mapping={
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30
})
user = r.hgetall('user:1')

# List operations
r.lpush('queue', 'task1', 'task2', 'task3')
task = r.rpop('queue')

# Set operations
r.sadd('tags', 'python', 'redis', 'cache')
tags = r.smembers('tags')

# Sorted set operations
r.zadd('leaderboard', {'player1': 100, 'player2': 200, 'player3': 150})
top_players = r.zrevrange('leaderboard', 0, 9, withscores=True)

# Increment/Decrement
r.incr('counter')
r.decr('counter')
r.incrby('counter', 10)

# Pub/Sub
pubsub = r.pubsub()
pubsub.subscribe('channel')

for message in pubsub.listen():
    print(message)

# Publish
r.publish('channel', 'Hello World')

# Transactions
pipe = r.pipeline()
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
pipe.incr('counter')
pipe.execute()

# Lua scripting
script = """
local value = redis.call('GET', KEYS[1])
if value then
    return redis.call('INCR', KEYS[1])
else
    redis.call('SET', KEYS[1], ARGV[1])
    return ARGV[1]
end
"""
result = r.eval(script, 1, 'counter', 1)
```

**Connection Pooling:**

```python
import redis

# Create connection pool
pool = redis.ConnectionPool(
    host='10.0.0.3',
    port=6379,
    max_connections=50,
    decode_responses=True
)

# Use pool
r = redis.Redis(connection_pool=pool)
r.set('key', 'value')
```

### Memcached Operations

**Python Client:**

```python
from pymemcache.client import base

# Connect to Memcached
client = base.Client(('10.0.0.4', 11211))

# Set value
client.set('key', 'value')
client.set('key', 'value', expire=3600)

# Get value
value = client.get('key')

# Delete value
client.delete('key')

# Increment/Decrement
client.incr('counter', 1)
client.decr('counter', 1)

# Multiple operations
client.set_many({'key1': 'value1', 'key2': 'value2'})
values = client.get_many(['key1', 'key2'])

# Close connection
client.close()
```

**Connection Pooling:**

```python
from pymemcache.client.hash import HashClient

# Create client with multiple servers
client = HashClient([
    ('10.0.0.4', 11211),
    ('10.0.0.5', 11211),
    ('10.0.0.6', 11211)
])

client.set('key', 'value')
```

---

## High Availability

### Redis Standard Tier

```
┌─────────────────────────────────────────┐
│     Redis Standard Tier                 │
├─────────────────────────────────────────┤
│  Zone A                                 │
│  ┌──────────────────────────────────┐   │
│  │  Primary Node                    │   │
│  │  - Read/Write                    │   │
│  └──────────────────────────────────┘   │
│           │                             │
│           │ Replication                 │
│           v                             │
│  Zone B                                 │
│  ┌──────────────────────────────────┐   │
│  │  Replica Node                    │   │
│  │  - Read operations               │   │
│  │  - Automatic failover            │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Features:                              │
│  - 99.9% availability SLA               │
│  - Automatic failover (< 60s)           │
│  - Read replicas                        │
└─────────────────────────────────────────┘
```

### Failover Testing

```bash
# Trigger manual failover
gcloud redis instances failover my-redis \
  --region=us-central1 \
  --data-protection-mode=limited-data-loss
```

---

## Performance

### Redis Performance

**Typical Performance:**
- Latency: < 1ms (p50), < 2ms (p99)
- Throughput: 100K+ ops/sec per GB
- Max memory: 300 GB

**Optimization Tips:**

```python
# Use pipelining
pipe = r.pipeline()
for i in range(1000):
    pipe.set(f'key{i}', f'value{i}')
pipe.execute()

# Use connection pooling
pool = redis.ConnectionPool(host='10.0.0.3', port=6379, max_connections=50)
r = redis.Redis(connection_pool=pool)

# Use appropriate data structures
# Bad: Multiple keys
r.set('user:1:name', 'John')
r.set('user:1:email', 'john@example.com')

# Good: Hash
r.hset('user:1', mapping={'name': 'John', 'email': 'john@example.com'})

# Set expiration
r.setex('session:123', 3600, 'data')

# Use Lua scripts for atomic operations
script = r.register_script("""
    local current = redis.call('GET', KEYS[1])
    if tonumber(current) < tonumber(ARGV[1]) then
        redis.call('SET', KEYS[1], ARGV[1])
        return 1
    end
    return 0
""")
result = script(keys=['max_value'], args=[100])
```

### Memcached Performance

**Typical Performance:**
- Latency: < 1ms
- Throughput: 1M+ ops/sec
- Max memory: 5 GB per node

---

## Monitoring

### Metrics

```bash
# View Redis metrics
gcloud monitoring time-series list \
  --filter='metric.type="redis.googleapis.com/stats/cpu_utilization"' \
  --format=json

# View Memcached metrics
gcloud monitoring time-series list \
  --filter='metric.type="memcache.googleapis.com/node/cpu/utilization"' \
  --format=json
```

**Key Metrics:**

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **CPU Utilization** | CPU usage | > 80% |
| **Memory Usage** | Memory utilization | > 90% |
| **Hit Ratio** | Cache hit rate | < 80% |
| **Evicted Keys** | Keys evicted | Increasing |
| **Connected Clients** | Active connections | Near max |
| **Operations/sec** | Throughput | Baseline |

### Alerting

```bash
# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Redis CPU" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s \
  --condition-filter='metric.type="redis.googleapis.com/stats/cpu_utilization"'
```

---

## Cost Optimization

### Pricing

**Redis:**
- Basic tier: $0.049/GB/hour ($35.28/GB/month)
- Standard tier: $0.078/GB/hour ($56.16/GB/month)

**Memcached:**
- $0.0375/GB/hour ($27/GB/month)
- $0.0375/vCPU/hour ($27/vCPU/month)

### Optimization Strategies

**1. Right-size instances:**

```bash
# Monitor memory usage
gcloud monitoring time-series list \
  --filter='metric.type="redis.googleapis.com/stats/memory/usage_ratio"'

# Resize if usage < 70%
gcloud redis instances update my-redis \
  --size=3
```

**2. Use Basic tier for non-production:**

```bash
# Development instance
gcloud redis instances create dev-redis \
  --size=1 \
  --tier=basic
```

**3. Implement eviction policies:**

```bash
# Configure LRU eviction
gcloud redis instances update my-redis \
  --update-redis-config=maxmemory-policy=allkeys-lru
```

**4. Monitor and optimize hit ratio:**

```python
# Check hit ratio
info = r.info('stats')
hits = info['keyspace_hits']
misses = info['keyspace_misses']
hit_ratio = hits / (hits + misses) if (hits + misses) > 0 else 0

print(f'Hit ratio: {hit_ratio:.2%}')

# Optimize TTL
r.setex('key', 3600, 'value')  # 1 hour
```

**5. Delete unused instances:**

```bash
# List instances
gcloud redis instances list

# Delete unused
gcloud redis instances delete unused-redis \
  --region=us-central1
```

### Cost Example

**Scenario:** Production caching layer

```
Redis Standard (5 GB):
- Instance: 5 GB × $56.16 = $280.80/month

Memcached (3 nodes, 1 GB each):
- Memory: 3 GB × $27 = $81/month
- CPU: 3 vCPU × $27 = $81/month
- Total: $162/month

Savings with Memcached: 42%
```

---

## Best Practices

### Redis

✅ Use Standard tier for production  
✅ Implement connection pooling  
✅ Use pipelining for batch operations  
✅ Set appropriate TTLs  
✅ Use appropriate data structures  
✅ Monitor hit ratio  
✅ Implement eviction policies  
✅ Use Lua scripts for atomic operations  
✅ Regular backups (Standard tier)  
✅ Test failover procedures  

### Memcached

✅ Use multiple nodes for distribution  
✅ Implement consistent hashing  
✅ Set appropriate TTLs  
✅ Monitor hit ratio  
✅ Use connection pooling  
✅ Handle cache misses gracefully  
✅ Implement cache warming  
✅ Regular performance testing  

### Security

✅ Use VPC for network isolation  
✅ No public IP endpoints  
✅ Use IAM for access control  
✅ Enable audit logging  
✅ Implement least privilege  
✅ Regular security audits  
✅ Use TLS in transit (Redis)  
✅ Rotate credentials  

### Performance

✅ Use connection pooling  
✅ Implement pipelining  
✅ Use appropriate data structures  
✅ Set TTLs appropriately  
✅ Monitor latency  
✅ Optimize key design  
✅ Use Lua scripts  
✅ Regular performance testing  

### Cost Management

✅ Right-size instances  
✅ Use Basic tier for dev/test  
✅ Monitor usage  
✅ Implement eviction policies  
✅ Delete unused instances  
✅ Optimize TTLs  
✅ Regular cost reviews  
✅ Use appropriate tier  

---

## Troubleshooting

### High Latency

```python
# Check latency
import time

start = time.time()
r.ping()
latency = (time.time() - start) * 1000
print(f'Latency: {latency:.2f}ms')

# Check slow log (Redis)
slow_log = r.slowlog_get(10)
for entry in slow_log:
    print(f'Command: {entry["command"]}, Duration: {entry["duration"]}μs')
```

### Low Hit Ratio

```python
# Check hit ratio
info = r.info('stats')
hits = info['keyspace_hits']
misses = info['keyspace_misses']
hit_ratio = hits / (hits + misses)

print(f'Hit ratio: {hit_ratio:.2%}')
print(f'Hits: {hits}, Misses: {misses}')

# Analyze keys
keys = r.keys('*')
for key in keys[:10]:
    ttl = r.ttl(key)
    print(f'Key: {key}, TTL: {ttl}')
```

### Connection Issues

```python
# Test connection
try:
    r.ping()
    print('Connected')
except redis.ConnectionError as e:
    print(f'Connection error: {e}')

# Check max connections
info = r.info('clients')
print(f'Connected clients: {info["connected_clients"]}')
print(f'Max clients: {info["maxclients"]}')
```

---

## Next Steps

- **[Database Comparison](6-Database-Comparison.md)** - Detailed comparison
- **[Best Practices](7-Best-Practices.md)** - Production guidelines
- **[Cloud SQL](1-Cloud-SQL.md)** - Relational databases

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
