# DigitalOcean Load Balancers

## Overview

DigitalOcean Load Balancers distribute incoming traffic across multiple Droplets, providing high availability, scalability, and improved application performance. They support HTTP, HTTPS, HTTP/2, and TCP protocols with automatic health checks and SSL/TLS termination.

## Key Features

- **Automatic Traffic Distribution**: Round-robin and least connections algorithms
- **Health Checks**: Automatic detection and removal of unhealthy Droplets
- **SSL/TLS Termination**: Offload SSL processing from backend servers
- **HTTP/2 Support**: Modern protocol support for better performance
- **Sticky Sessions**: Session persistence based on cookies
- **Proxy Protocol**: Preserve client IP information
- **Let's Encrypt Integration**: Free automated SSL certificates
- **Regional**: Deployed in specific datacenter regions
- **Scalable**: Handle thousands of concurrent connections
- **Managed Service**: Fully managed by DigitalOcean

## Load Balancer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet Traffic                          │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   DNS Record    │
                    │  lb.example.com │
                    └────────┬────────┘
                             │
                    ┌────────▼────────────────────────┐
                    │   DigitalOcean Load Balancer    │
                    │  • SSL/TLS Termination          │
                    │  • Health Checks                │
                    │  • Session Persistence          │
                    │  • Algorithm: Round Robin       │
                    └────────┬────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Droplet │         │ Droplet │         │ Droplet │
   │  Web 1  │         │  Web 2  │         │  Web 3  │
   │ Healthy │         │ Healthy │         │ Failed  │
   │    ✓    │         │    ✓    │         │    ✗    │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   VPC Network   │
                    │  (Private Comm) │
                    └─────────────────┘
```

## Supported Protocols

### HTTP (Port 80)
- Standard web traffic
- No encryption
- Suitable for non-sensitive data

### HTTPS (Port 443)
- Encrypted web traffic
- SSL/TLS termination at load balancer
- Recommended for production

### HTTP/2
- Modern protocol with multiplexing
- Better performance than HTTP/1.1
- Automatic with HTTPS

### TCP (Custom Ports)
- Generic TCP load balancing
- Database connections
- Custom applications
- No protocol-specific features

## Load Balancing Algorithms

### Round Robin (Default)
Distributes requests evenly across all healthy Droplets.

```
Request 1 → Droplet 1
Request 2 → Droplet 2
Request 3 → Droplet 3
Request 4 → Droplet 1
Request 5 → Droplet 2
...
```

### Least Connections
Routes to Droplet with fewest active connections.

```
Droplet 1: 10 connections
Droplet 2: 5 connections  ← New request goes here
Droplet 3: 8 connections
```

## Traffic Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  Load Balancer Traffic Flow                  │
└─────────────────────────────────────────────────────────────┘

Client Request
    │
    ├─> HTTPS Request (443)
    │
    ▼
┌─────────────────────────┐
│   Load Balancer         │
│  1. SSL Termination     │
│  2. Health Check        │
│  3. Select Backend      │
│  4. Apply Algorithm     │
│  5. Check Sticky Session│
└───────┬─────────────────┘
        │
        ├─> Backend Selection
        │
        ▼
┌─────────────────────────┐
│  Available Backends     │
│  ✓ Droplet 1 (Healthy)  │
│  ✓ Droplet 2 (Healthy)  │
│  ✗ Droplet 3 (Failed)   │
└───────┬─────────────────┘
        │
        ├─> Forward to Droplet 1
        │
        ▼
┌─────────────────────────┐
│   Backend Droplet       │
│  • Receives HTTP        │
│  • Processes Request    │
│  • Returns Response     │
└───────┬─────────────────┘
        │
        ├─> Response
        │
        ▼
┌─────────────────────────┐
│   Load Balancer         │
│  • Receives Response    │
│  • Adds Headers         │
│  • Encrypts (SSL)       │
└───────┬─────────────────┘
        │
        ▼
    Client Response
```

## Creating a Load Balancer

### Via Control Panel

1. Navigate to **Networking** → **Load Balancers**
2. Click **Create Load Balancer**
3. Configure settings:
   - **Region**: Select datacenter
   - **VPC**: Choose VPC network
   - **Forwarding Rules**: Configure ports and protocols
   - **Health Checks**: Set check parameters
   - **Sticky Sessions**: Enable if needed
   - **Backend Droplets**: Select Droplets or tags
   - **SSL Certificate**: Upload or use Let's Encrypt
4. Click **Create Load Balancer**

### Via API

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "web-lb-01",
    "algorithm": "round_robin",
    "region": "nyc3",
    "forwarding_rules": [
      {
        "entry_protocol": "https",
        "entry_port": 443,
        "target_protocol": "http",
        "target_port": 80,
        "certificate_id": "cert-id-here",
        "tls_passthrough": false
      },
      {
        "entry_protocol": "http",
        "entry_port": 80,
        "target_protocol": "http",
        "target_port": 80
      }
    ],
    "health_check": {
      "protocol": "http",
      "port": 80,
      "path": "/health",
      "check_interval_seconds": 10,
      "response_timeout_seconds": 5,
      "healthy_threshold": 3,
      "unhealthy_threshold": 3
    },
    "sticky_sessions": {
      "type": "cookies",
      "cookie_name": "lb",
      "cookie_ttl_seconds": 300
    },
    "droplet_ids": [12345678, 87654321],
    "tag": "web-tier"
  }' \
  "https://api.digitalocean.com/v2/load_balancers"
```

### Via doctl CLI

```bash
doctl compute load-balancer create \
  --name web-lb-01 \
  --region nyc3 \
  --forwarding-rules entry_protocol:https,entry_port:443,target_protocol:http,target_port:80,certificate_id:cert-id \
  --health-check protocol:http,port:80,path:/health,check_interval_seconds:10 \
  --droplet-ids 12345678,87654321 \
  --tag-name web-tier
```

## Forwarding Rules Configuration

### HTTPS to HTTP (SSL Termination)
```json
{
  "entry_protocol": "https",
  "entry_port": 443,
  "target_protocol": "http",
  "target_port": 80,
  "certificate_id": "cert-id-here"
}
```

### HTTP to HTTP (No SSL)
```json
{
  "entry_protocol": "http",
  "entry_port": 80,
  "target_protocol": "http",
  "target_port": 80
}
```

### HTTPS Passthrough (No SSL Termination)
```json
{
  "entry_protocol": "https",
  "entry_port": 443,
  "target_protocol": "https",
  "target_port": 443,
  "tls_passthrough": true
}
```

### TCP Load Balancing
```json
{
  "entry_protocol": "tcp",
  "entry_port": 3306,
  "target_protocol": "tcp",
  "target_port": 3306
}
```

## Health Checks

Health checks monitor backend Droplet availability and automatically remove unhealthy instances.

### HTTP Health Check
```json
{
  "protocol": "http",
  "port": 80,
  "path": "/health",
  "check_interval_seconds": 10,
  "response_timeout_seconds": 5,
  "healthy_threshold": 3,
  "unhealthy_threshold": 3
}
```

### TCP Health Check
```json
{
  "protocol": "tcp",
  "port": 80,
  "check_interval_seconds": 10,
  "response_timeout_seconds": 5,
  "healthy_threshold": 3,
  "unhealthy_threshold": 3
}
```

### Health Check Parameters

- **check_interval_seconds**: Time between checks (3-300 seconds)
- **response_timeout_seconds**: Max wait time for response (3-300 seconds)
- **healthy_threshold**: Consecutive successes to mark healthy (2-10)
- **unhealthy_threshold**: Consecutive failures to mark unhealthy (2-10)

### Health Check Workflow

```
┌─────────────────────────────────────────────────────────────┐
│              Health Check Workflow                           │
└─────────────────────────────────────────────────────────────┘

Every 10 seconds:
    │
    ├─> Send HTTP GET /health to Droplet 1
    │   └─> Response: 200 OK (Healthy) ✓
    │
    ├─> Send HTTP GET /health to Droplet 2
    │   └─> Response: 200 OK (Healthy) ✓
    │
    └─> Send HTTP GET /health to Droplet 3
        └─> Response: Timeout (Unhealthy) ✗
            │
            ├─> Failure Count: 1
            ├─> Failure Count: 2
            └─> Failure Count: 3
                │
                └─> Remove from pool
                    │
                    └─> No traffic sent to Droplet 3

When Droplet 3 recovers:
    │
    ├─> Success Count: 1
    ├─> Success Count: 2
    └─> Success Count: 3
        │
        └─> Add back to pool
```

## SSL/TLS Configuration

### Let's Encrypt (Free)

DigitalOcean provides free automated SSL certificates via Let's Encrypt:

1. Add domain to DigitalOcean DNS
2. Point domain to Load Balancer IP
3. Select "Let's Encrypt" when creating Load Balancer
4. Automatic renewal every 90 days

### Custom Certificate

Upload your own SSL certificate:

```bash
# Upload certificate via API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "web-cert",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...",
    "leaf_certificate": "-----BEGIN CERTIFICATE-----\n...",
    "certificate_chain": "-----BEGIN CERTIFICATE-----\n..."
  }' \
  "https://api.digitalocean.com/v2/certificates"
```

### SSL Termination vs Passthrough

**SSL Termination (Recommended)**
```
Client ─[HTTPS]─> Load Balancer ─[HTTP]─> Droplet
       (Encrypted)              (Unencrypted)
```
- Load Balancer decrypts traffic
- Backend receives plain HTTP
- Reduces CPU load on Droplets
- Easier certificate management

**SSL Passthrough**
```
Client ─[HTTPS]─> Load Balancer ─[HTTPS]─> Droplet
       (Encrypted)              (Encrypted)
```
- End-to-end encryption
- Droplets handle SSL
- More secure for sensitive data
- Higher CPU usage on Droplets

## Sticky Sessions

Maintain session persistence by routing requests from the same client to the same backend.

### Cookie-Based Sticky Sessions
```json
{
  "type": "cookies",
  "cookie_name": "lb",
  "cookie_ttl_seconds": 300
}
```

### How It Works

```
First Request:
Client → Load Balancer → Droplet 1
         ↓
    Set-Cookie: lb=droplet1_hash

Subsequent Requests:
Client → Load Balancer → Droplet 1 (same)
  (Cookie: lb=droplet1_hash)
```

## Backend Management

### Using Droplet IDs
```json
{
  "droplet_ids": [12345678, 87654321, 11223344]
}
```

### Using Tags (Recommended)
```json
{
  "tag": "web-tier"
}
```

Tag-based management automatically adds/removes Droplets:
- Tag a Droplet with "web-tier" → Automatically added to pool
- Remove tag → Automatically removed from pool
- No manual Load Balancer updates needed

## Advanced Configurations

### Multi-Tier Architecture

```
                    Internet
                        │
                ┌───────▼────────┐
                │  Load Balancer │
                │   (Public)     │
                └───────┬────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐     ┌────▼────┐    ┌────▼────┐
   │  Web 1  │     │  Web 2  │    │  Web 3  │
   └────┬────┘     └────┬────┘    └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                ┌───────▼────────┐
                │  Load Balancer │
                │   (Internal)   │
                └───────┬────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐     ┌────▼────┐    ┌────▼────┐
   │  App 1  │     │  App 2  │    │  App 3  │
   └────┬────┘     └────┬────┘    └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                ┌───────▼────────┐
                │   Database     │
                │    Cluster     │
                └────────────────┘
```

### Blue-Green Deployment

```
                Load Balancer
                      │
        ┌─────────────┴─────────────┐
        │                           │
   ┌────▼────┐                 ┌────▼────┐
   │  Blue   │                 │  Green  │
   │ (v1.0)  │                 │ (v2.0)  │
   │ Active  │                 │ Standby │
   └─────────┘                 └─────────┘

Deployment:
1. Deploy v2.0 to Green environment
2. Test Green environment
3. Switch Load Balancer to Green
4. Monitor for issues
5. Rollback to Blue if needed
```

### Canary Deployment

```
                Load Balancer
                      │
        ┌─────────────┼─────────────┐
        │ 90%         │ 10%         │
   ┌────▼────┐   ┌────▼────┐
   │ Stable  │   │ Canary  │
   │ (v1.0)  │   │ (v2.0)  │
   └─────────┘   └─────────┘

Gradual rollout:
1. 10% traffic to v2.0
2. Monitor metrics
3. Increase to 50%
4. Monitor metrics
5. Full rollout to 100%
```

## Monitoring and Metrics

### Available Metrics
- Request count
- Response time
- Error rate (4xx, 5xx)
- Active connections
- Backend health status
- SSL certificate expiration

### Via API
```bash
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/load_balancers/lb-id"
```

## Best Practices

1. **Health Checks**
   - Create dedicated health check endpoints
   - Return 200 OK only when truly healthy
   - Check database connectivity
   - Verify critical dependencies
   - Keep checks lightweight

2. **SSL/TLS**
   - Always use HTTPS in production
   - Enable HTTP to HTTPS redirect
   - Use Let's Encrypt for easy management
   - Monitor certificate expiration
   - Use strong cipher suites

3. **Backend Management**
   - Use tags for dynamic scaling
   - Implement graceful shutdown
   - Handle connection draining
   - Monitor backend health
   - Plan capacity appropriately

4. **Performance**
   - Use HTTP/2 for better performance
   - Enable compression at application level
   - Optimize backend response times
   - Monitor connection limits
   - Scale horizontally

5. **Security**
   - Use Cloud Firewalls with Load Balancers
   - Restrict backend access to Load Balancer only
   - Enable Proxy Protocol to preserve client IPs
   - Implement rate limiting at application level
   - Regular security audits

6. **High Availability**
   - Deploy backends across multiple availability zones
   - Use at least 3 backend Droplets
   - Configure appropriate health check thresholds
   - Test failover scenarios
   - Document recovery procedures

## Troubleshooting

### 502 Bad Gateway
```
Causes:
- All backends unhealthy
- Backend not listening on configured port
- Firewall blocking Load Balancer
- Backend application crashed

Solutions:
- Check backend health
- Verify application is running
- Review firewall rules
- Check application logs
```

### 504 Gateway Timeout
```
Causes:
- Backend response too slow
- Health check timeout too short
- Backend overloaded

Solutions:
- Optimize backend performance
- Increase timeout values
- Scale backend capacity
- Review slow queries
```

### SSL Certificate Issues
```
Causes:
- Certificate expired
- Invalid certificate chain
- Domain mismatch

Solutions:
- Renew certificate
- Upload complete chain
- Verify domain configuration
```

### Uneven Traffic Distribution
```
Causes:
- Sticky sessions enabled
- Long-lived connections
- Backend capacity differences

Solutions:
- Disable sticky sessions if not needed
- Use least connections algorithm
- Ensure backends have equal capacity
```

## Pricing

- **Basic Load Balancer**: $12/month
  - Up to 10,000 concurrent connections
  - Unlimited bandwidth (standard transfer rates apply)
  - SSL/TLS termination included
  - Let's Encrypt certificates included

## Limitations

- Maximum 100 Droplets per Load Balancer
- Regional resource (cannot span regions)
- Maximum 10 forwarding rules
- Maximum 10,000 concurrent connections (basic tier)

## Related Services

- [Reserved IPs](./2-RESERVED-IPS.md) - Assign static IP to Load Balancer
- [VPC](./4-VPC.md) - Private network for backends
- [Cloud Firewalls](./5-CLOUD-FIREWALLS.md) - Secure Load Balancer and backends
- [Domains & DNS](./1-DOMAINS-DNS.md) - Point domain to Load Balancer
