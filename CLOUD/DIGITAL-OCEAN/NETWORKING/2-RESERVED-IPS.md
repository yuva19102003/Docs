# DigitalOcean Reserved IPs (Floating IPs)

## Overview

Reserved IPs (formerly called Floating IPs) are static IP addresses that can be instantly remapped between Droplets in the same datacenter. They provide high availability and enable seamless failover without DNS propagation delays.

## Key Features

- **Static IP Address**: Permanent IP that persists independently of Droplets
- **Instant Remapping**: Switch between Droplets in seconds
- **High Availability**: Enable failover without DNS changes
- **Regional Resource**: Tied to a specific datacenter region
- **Free When Assigned**: No charge when assigned to a Droplet
- **API Support**: Automate failover and management
- **Anchor Droplet**: Can be assigned to one Droplet at a time

## How Reserved IPs Work

```
┌─────────────────────────────────────────────────────────────┐
│                    Reserved IP Architecture                  │
└─────────────────────────────────────────────────────────────┘

                    Reserved IP: 203.0.113.10
                            │
                            │ (Assigned to)
                            │
                    ┌───────▼────────┐
                    │   Droplet 1    │
                    │   (Primary)    │
                    │  10.0.0.5      │
                    └────────────────┘

                    ─── Failover ───>

                    Reserved IP: 203.0.113.10
                            │
                            │ (Reassigned to)
                            │
                    ┌───────▼────────┐
                    │   Droplet 2    │
                    │   (Backup)     │
                    │  10.0.0.6      │
                    └────────────────┘
```

## Reserved IP vs Regular IP

| Feature | Reserved IP | Regular Droplet IP |
|---------|-------------|-------------------|
| **Persistence** | Independent of Droplet | Tied to Droplet lifecycle |
| **Remapping** | Instant between Droplets | Lost when Droplet destroyed |
| **Failover** | Seconds | Requires DNS change (minutes/hours) |
| **Cost** | $4/month when unassigned | Free with Droplet |
| **Use Case** | High availability | Standard deployments |

## Architecture Patterns

### 1. Active-Passive Failover

```
                        Internet
                            │
                            │
                    ┌───────▼────────┐
                    │  Reserved IP   │
                    │  203.0.113.10  │
                    └───────┬────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
        ┌───────▼────────┐      ┌──────▼──────┐
        │  Primary Web   │      │ Backup Web  │
        │    Droplet     │      │   Droplet   │
        │   (Active)     │      │  (Standby)  │
        └───────┬────────┘      └──────┬──────┘
                │                       │
                └───────────┬───────────┘
                            │
                    ┌───────▼────────┐
                    │   Database     │
                    │    Cluster     │
                    └────────────────┘

Monitoring detects failure → Reassigns Reserved IP → Traffic flows to backup
```

### 2. Load Balancer with Reserved IP

```
                        Internet
                            │
                    ┌───────▼────────┐
                    │  Reserved IP   │
                    │  203.0.113.10  │
                    └───────┬────────┘
                            │
                    ┌───────▼────────┐
                    │ Load Balancer  │
                    │  (Primary)     │
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
   │ Droplet │         │ Droplet │        │ Droplet │
   │  Web 1  │         │  Web 2  │        │  Web 3  │
   └─────────┘         └─────────┘        └─────────┘
```

### 3. Multi-Tier Application

```
                    Public Reserved IP
                      203.0.113.10
                            │
                    ┌───────▼────────┐
                    │   Web Tier     │
                    │   (Public)     │
                    └───────┬────────┘
                            │
                    Internal Reserved IP
                       10.0.0.100
                            │
                    ┌───────▼────────┐
                    │   App Tier     │
                    │   (Private)    │
                    └───────┬────────┘
                            │
                    Internal Reserved IP
                       10.0.0.200
                            │
                    ┌───────▼────────┐
                    │   DB Tier      │
                    │   (Private)    │
                    └────────────────┘
```

## Creating and Managing Reserved IPs

### Via Control Panel

1. **Create Reserved IP**
   - Navigate to **Networking** → **Reserved IPs**
   - Click **Create Reserved IP**
   - Select region (must match Droplet region)
   - Choose Droplet to assign (optional)
   - Click **Create**

2. **Assign to Droplet**
   - Select Reserved IP
   - Click **Assign to Droplet**
   - Choose target Droplet
   - Confirm assignment

3. **Reassign to Different Droplet**
   - Select Reserved IP
   - Click **Reassign**
   - Choose new Droplet
   - Confirm (takes 5-10 seconds)

### Via API

#### Create Reserved IP
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"assign","droplet_id":12345678,"region":"nyc3"}' \
  "https://api.digitalocean.com/v2/floating_ips"
```

#### List Reserved IPs
```bash
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/floating_ips"
```

#### Assign to Droplet
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"assign","droplet_id":87654321}' \
  "https://api.digitalocean.com/v2/floating_ips/203.0.113.10/actions"
```

#### Unassign from Droplet
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"unassign"}' \
  "https://api.digitalocean.com/v2/floating_ips/203.0.113.10/actions"
```

#### Delete Reserved IP
```bash
curl -X DELETE \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/floating_ips/203.0.113.10"
```

### Via doctl CLI

```bash
# Create and assign Reserved IP
doctl compute floating-ip create --region nyc3 --droplet-id 12345678

# List Reserved IPs
doctl compute floating-ip list

# Assign to Droplet
doctl compute floating-ip-action assign 203.0.113.10 --droplet-id 87654321

# Unassign from Droplet
doctl compute floating-ip-action unassign 203.0.113.10

# Delete Reserved IP
doctl compute floating-ip delete 203.0.113.10
```

## Configuring Reserved IP on Droplet

### Automatic Configuration (Recommended)

DigitalOcean automatically configures Reserved IPs via cloud-init on supported images. No manual configuration needed.

### Manual Configuration (Ubuntu/Debian)

If automatic configuration fails, configure manually:

```bash
# Edit network configuration
sudo nano /etc/network/interfaces.d/60-floating-ip.cfg

# Add configuration
auto eth0:1
iface eth0:1 inet static
    address 203.0.113.10
    netmask 255.255.255.255

# Restart networking
sudo systemctl restart networking

# Verify
ip addr show eth0
```

### Manual Configuration (CentOS/RHEL)

```bash
# Create network script
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0:1

# Add configuration
DEVICE=eth0:1
BOOTPROTO=static
IPADDR=203.0.113.10
NETMASK=255.255.255.255
ONBOOT=yes

# Restart networking
sudo systemctl restart network

# Verify
ip addr show eth0
```

## Automated Failover Implementation

### Using Heartbeat

```bash
# Install heartbeat on both Droplets
sudo apt-get update
sudo apt-get install heartbeat

# Configure /etc/ha.d/ha.cf
debugfile /var/log/ha-debug
logfile /var/log/ha-log
logfacility local0
keepalive 2
deadtime 30
warntime 10
initdead 120
udpport 694
ucast eth0 10.0.0.6  # IP of other node
auto_failback on
node primary-droplet
node backup-droplet

# Configure /etc/ha.d/haresources
primary-droplet IPaddr::203.0.113.10/32/eth0:1

# Configure /etc/ha.d/authkeys
auth 1
1 sha1 your-secret-key-here

# Set permissions
sudo chmod 600 /etc/ha.d/authkeys

# Start heartbeat
sudo systemctl start heartbeat
sudo systemctl enable heartbeat
```

### Using Custom Script with API

```python
#!/usr/bin/env python3
import requests
import time
import subprocess

DIGITALOCEAN_TOKEN = "your_token_here"
RESERVED_IP = "203.0.113.10"
BACKUP_DROPLET_ID = "87654321"
CHECK_INTERVAL = 30  # seconds

def check_primary_health():
    """Check if primary service is healthy"""
    try:
        response = subprocess.run(
            ["curl", "-f", "http://localhost/health"],
            capture_output=True,
            timeout=5
        )
        return response.returncode == 0
    except:
        return False

def reassign_reserved_ip():
    """Reassign Reserved IP to backup Droplet"""
    url = f"https://api.digitalocean.com/v2/floating_ips/{RESERVED_IP}/actions"
    headers = {
        "Authorization": f"Bearer {DIGITALOCEAN_TOKEN}",
        "Content-Type": "application/json"
    }
    data = {
        "type": "assign",
        "droplet_id": BACKUP_DROPLET_ID
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.status_code == 201

def main():
    consecutive_failures = 0
    
    while True:
        if check_primary_health():
            consecutive_failures = 0
        else:
            consecutive_failures += 1
            
            if consecutive_failures >= 3:
                print("Primary failed 3 times, initiating failover...")
                if reassign_reserved_ip():
                    print("Failover successful!")
                    break
                else:
                    print("Failover failed, retrying...")
        
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
```

## High Availability Workflow

```
┌─────────────────────────────────────────────────────────────┐
│              High Availability Workflow                      │
└─────────────────────────────────────────────────────────────┘

1. Normal Operation
   ├─> Reserved IP assigned to Primary Droplet
   ├─> Monitoring checks health every 30s
   └─> All traffic flows to Primary

2. Failure Detection
   ├─> Health check fails on Primary
   ├─> Wait for 3 consecutive failures (90s)
   └─> Trigger failover process

3. Failover Execution
   ├─> API call to reassign Reserved IP
   ├─> Reserved IP moves to Backup Droplet
   ├─> Takes 5-10 seconds to complete
   └─> DNS remains unchanged

4. Traffic Restoration
   ├─> New connections go to Backup
   ├─> Existing connections may drop
   ├─> Service restored in < 2 minutes
   └─> Alert administrators

5. Recovery
   ├─> Fix Primary Droplet
   ├─> Verify health
   ├─> Optional: Failback to Primary
   └─> Resume normal monitoring
```

## Use Cases

### 1. Web Application High Availability
- Assign Reserved IP to primary web server
- Monitor application health
- Automatic failover to backup server
- Zero DNS propagation delay

### 2. Database Failover
- Reserved IP for database master
- Standby replica ready for promotion
- Quick failover during maintenance or failure
- Applications reconnect automatically

### 3. API Gateway
- Reserved IP for API endpoint
- Multiple backend servers
- Seamless version upgrades
- Blue-green deployments

### 4. Email Server
- Reserved IP with PTR record
- Maintain sender reputation
- Failover without affecting deliverability
- Consistent IP for SPF records

## Best Practices

1. **Regional Planning**
   - Reserved IPs are regional resources
   - Plan Droplet placement in same region
   - Consider multi-region for disaster recovery

2. **Monitoring**
   - Implement robust health checks
   - Monitor both application and infrastructure
   - Set up alerting for failover events
   - Log all IP reassignments

3. **Testing**
   - Regularly test failover procedures
   - Verify backup Droplet readiness
   - Measure failover time
   - Document recovery procedures

4. **DNS Configuration**
   - Point DNS A records to Reserved IP
   - Use appropriate TTL values
   - Configure PTR records if needed
   - Document DNS setup

5. **Security**
   - Protect API tokens
   - Use Cloud Firewalls with Reserved IPs
   - Implement rate limiting
   - Monitor for unauthorized access

6. **Cost Management**
   - Always assign Reserved IPs to avoid charges
   - Delete unused Reserved IPs
   - Monitor billing for unassigned IPs
   - Plan capacity appropriately

## Limitations

- **Regional Scope**: Cannot move between regions
- **One Droplet**: Can only be assigned to one Droplet at a time
- **Same Region**: Droplet must be in same region as Reserved IP
- **IPv4 Only**: No IPv6 Reserved IPs currently
- **Charge When Unassigned**: $4/month if not assigned to a Droplet

## Troubleshooting

### Reserved IP Not Responding

```bash
# Check if IP is assigned
doctl compute floating-ip list

# Verify Droplet configuration
ip addr show

# Check firewall rules
sudo iptables -L -n

# Test connectivity
ping 203.0.113.10
curl -I http://203.0.113.10
```

### Failover Not Working

1. Verify API token permissions
2. Check Droplet is in same region
3. Ensure Droplet is powered on
4. Review API rate limits
5. Check monitoring script logs

### Configuration Issues

```bash
# Verify network configuration
ip addr show eth0

# Check routing
ip route show

# Test local binding
netstat -tulpn | grep 203.0.113.10

# Restart networking
sudo systemctl restart networking
```

## Pricing

- **Assigned to Droplet**: Free
- **Unassigned**: $4.00/month
- **No Data Transfer Charges**: Standard Droplet bandwidth applies

## Related Services

- [Domains & DNS](./1-DOMAINS-DNS.md) - Point DNS to Reserved IPs
- [Load Balancers](./3-LOAD-BALANCERS.md) - Combine for advanced HA
- [Cloud Firewalls](./5-CLOUD-FIREWALLS.md) - Secure Reserved IPs
- [PTR Records](./6-PTR-RECORDS.md) - Reverse DNS for Reserved IPs
