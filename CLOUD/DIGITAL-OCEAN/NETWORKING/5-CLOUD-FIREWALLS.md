# DigitalOcean Cloud Firewalls

## Overview

Cloud Firewalls provide network-level security for your Droplets by controlling inbound and outbound traffic. They are stateful, free, and can be applied to multiple Droplets using tags, making them ideal for securing dynamic infrastructure.

## Key Features

- **Stateful Firewall**: Automatically tracks connection state
- **Free**: No additional cost
- **Tag-Based**: Apply rules to multiple Droplets using tags
- **Centralized Management**: Single firewall for multiple resources
- **Inbound & Outbound Rules**: Control both directions
- **Protocol Support**: TCP, UDP, ICMP
- **Source/Destination Filtering**: IP addresses, CIDR blocks, tags, Load Balancers
- **API & CLI Support**: Automate firewall management
- **No Performance Impact**: Managed outside Droplets

## Cloud Firewall Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet Traffic                          │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Cloud Firewall  │
                    │                 │
                    │ Inbound Rules:  │
                    │ ✓ Port 443      │
                    │ ✓ Port 80       │
                    │ ✗ Port 22       │
                    │   (from all)    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Droplet │         │ Droplet │         │ Droplet │
   │  Web 1  │         │  Web 2  │         │  Web 3  │
   │ tag:web │         │ tag:web │         │ tag:web │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Cloud Firewall  │
                    │                 │
                    │ Outbound Rules: │
                    │ ✓ Port 5432     │
                    │   (to tag:db)   │
                    │ ✓ Port 443      │
                    │   (to all)      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Database      │
                    │   tag:db        │
                    └─────────────────┘
```

## Firewall Rules Structure

### Inbound Rules
Control traffic coming TO your Droplets.

```
Protocol: TCP
Ports: 443
Sources: All IPv4, All IPv6
Action: ALLOW
```

### Outbound Rules
Control traffic going FROM your Droplets.

```
Protocol: TCP
Ports: 443
Destinations: All IPv4, All IPv6
Action: ALLOW
```

## Rule Components

### Protocol
- **TCP**: Web traffic, SSH, databases
- **UDP**: DNS, VPN, streaming
- **ICMP**: Ping, network diagnostics

### Ports
- Single port: `80`
- Port range: `8000-8999`
- All ports: `all` or `1-65535`

### Sources (Inbound) / Destinations (Outbound)
- **IP Address**: `203.0.113.10`
- **CIDR Block**: `203.0.113.0/24`
- **All IPv4**: `0.0.0.0/0`
- **All IPv6**: `::/0`
- **Droplet Tag**: `tag:web-tier`
- **Load Balancer**: `load_balancer:lb-uuid`

## Creating Cloud Firewalls

### Via Control Panel

1. Navigate to **Networking** → **Firewalls**
2. Click **Create Firewall**
3. Configure:
   - **Name**: web-firewall
   - **Inbound Rules**: Add rules
   - **Outbound Rules**: Add rules
   - **Apply to Droplets**: Select Droplets or tags
4. Click **Create Firewall**

### Via API

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "web-firewall",
    "inbound_rules": [
      {
        "protocol": "tcp",
        "ports": "443",
        "sources": {
          "addresses": ["0.0.0.0/0", "::/0"]
        }
      },
      {
        "protocol": "tcp",
        "ports": "80",
        "sources": {
          "addresses": ["0.0.0.0/0", "::/0"]
        }
      },
      {
        "protocol": "tcp",
        "ports": "22",
        "sources": {
          "addresses": ["203.0.113.0/24"]
        }
      }
    ],
    "outbound_rules": [
      {
        "protocol": "tcp",
        "ports": "all",
        "destinations": {
          "addresses": ["0.0.0.0/0", "::/0"]
        }
      },
      {
        "protocol": "udp",
        "ports": "all",
        "destinations": {
          "addresses": ["0.0.0.0/0", "::/0"]
        }
      },
      {
        "protocol": "icmp",
        "destinations": {
          "addresses": ["0.0.0.0/0", "::/0"]
        }
      }
    ],
    "droplet_ids": [],
    "tags": ["web-tier"]
  }' \
  "https://api.digitalocean.com/v2/firewalls"
```

### Via doctl CLI

```bash
doctl compute firewall create \
  --name web-firewall \
  --inbound-rules "protocol:tcp,ports:443,address:0.0.0.0/0 protocol:tcp,ports:80,address:0.0.0.0/0" \
  --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0" \
  --tag-names web-tier
```

## Common Firewall Configurations

### 1. Web Server (HTTP/HTTPS)

```json
{
  "name": "web-server-firewall",
  "inbound_rules": [
    {
      "protocol": "tcp",
      "ports": "443",
      "sources": {"addresses": ["0.0.0.0/0", "::/0"]}
    },
    {
      "protocol": "tcp",
      "ports": "80",
      "sources": {"addresses": ["0.0.0.0/0", "::/0"]}
    },
    {
      "protocol": "tcp",
      "ports": "22",
      "sources": {"addresses": ["YOUR_IP/32"]}
    }
  ],
  "outbound_rules": [
    {
      "protocol": "tcp",
      "ports": "all",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    },
    {
      "protocol": "udp",
      "ports": "53",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    },
    {
      "protocol": "icmp",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    }
  ],
  "tags": ["web"]
}
```

### 2. Database Server

```json
{
  "name": "database-firewall",
  "inbound_rules": [
    {
      "protocol": "tcp",
      "ports": "5432",
      "sources": {"tags": ["web", "app"]}
    },
    {
      "protocol": "tcp",
      "ports": "22",
      "sources": {"addresses": ["YOUR_IP/32"]}
    }
  ],
  "outbound_rules": [
    {
      "protocol": "tcp",
      "ports": "443",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    },
    {
      "protocol": "udp",
      "ports": "53",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    }
  ],
  "tags": ["database"]
}
```

### 3. Application Server

```json
{
  "name": "app-server-firewall",
  "inbound_rules": [
    {
      "protocol": "tcp",
      "ports": "8080",
      "sources": {"load_balancer_uids": ["lb-uuid"]}
    },
    {
      "protocol": "tcp",
      "ports": "22",
      "sources": {"addresses": ["YOUR_IP/32"]}
    }
  ],
  "outbound_rules": [
    {
      "protocol": "tcp",
      "ports": "5432",
      "destinations": {"tags": ["database"]}
    },
    {
      "protocol": "tcp",
      "ports": "6379",
      "destinations": {"tags": ["cache"]}
    },
    {
      "protocol": "tcp",
      "ports": "443",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    }
  ],
  "tags": ["app"]
}
```

### 4. SSH Bastion Host

```json
{
  "name": "bastion-firewall",
  "inbound_rules": [
    {
      "protocol": "tcp",
      "ports": "22",
      "sources": {"addresses": ["YOUR_IP/32", "OFFICE_IP/24"]}
    }
  ],
  "outbound_rules": [
    {
      "protocol": "tcp",
      "ports": "22",
      "destinations": {"tags": ["web", "app", "database"]}
    },
    {
      "protocol": "tcp",
      "ports": "443",
      "destinations": {"addresses": ["0.0.0.0/0", "::/0"]}
    }
  ],
  "tags": ["bastion"]
}
```

## Multi-Tier Architecture with Firewalls

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet (0.0.0.0/0)                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Web Firewall   │
                    │  IN: 443, 80    │
                    │  OUT: All       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │   Web   │         │   Web   │         │   Web   │
   │ tag:web │         │ tag:web │         │ tag:web │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  App Firewall   │
                    │  IN: 8080       │
                    │  (from tag:web) │
                    │  OUT: 5432, 6379│
                    │  (to tag:db)    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │   App   │         │   App   │         │   App   │
   │ tag:app │         │ tag:app │         │ tag:app │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   DB Firewall   │
                    │  IN: 5432, 6379 │
                    │  (from tag:app) │
                    │  OUT: 443       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │Database │         │  Redis  │         │Database │
   │ Primary │         │  Cache  │         │ Replica │
   │ tag:db  │         │ tag:db  │         │ tag:db  │
   └─────────┘         └─────────┘         └─────────┘
```

## Tag-Based Firewall Management

### Workflow

```
1. Create Firewall with Tag
   └─> Firewall: "web-firewall" applies to tag "web"

2. Tag Droplets
   └─> Add tag "web" to Droplets

3. Automatic Application
   └─> Firewall rules automatically apply to tagged Droplets

4. Dynamic Scaling
   ├─> New Droplet created with tag "web"
   └─> Firewall rules automatically applied

5. Remove from Firewall
   ├─> Remove tag "web" from Droplet
   └─> Firewall rules automatically removed
```

### Example: Auto-Scaling Web Tier

```bash
# Create firewall for web tier
doctl compute firewall create \
  --name web-firewall \
  --inbound-rules "protocol:tcp,ports:443,address:0.0.0.0/0" \
  --tag-names web

# Create Droplet with tag (automatically gets firewall rules)
doctl compute droplet create web-server-1 \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --tag-names web

# Scale up: Create more Droplets with same tag
doctl compute droplet create web-server-2 \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --tag-names web

# All Droplets automatically protected by web-firewall
```

## Managing Firewalls

### List Firewalls

```bash
# Via API
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/firewalls"

# Via doctl
doctl compute firewall list
```

### Get Firewall Details

```bash
# Via API
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid"

# Via doctl
doctl compute firewall get firewall-uuid
```

### Update Firewall Rules

```bash
# Via API
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "web-firewall-updated",
    "inbound_rules": [...],
    "outbound_rules": [...]
  }' \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid"

# Via doctl
doctl compute firewall update firewall-uuid \
  --name web-firewall-updated
```

### Add Droplets to Firewall

```bash
# Via API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"droplet_ids": [12345678, 87654321]}' \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid/droplets"

# Via doctl
doctl compute firewall add-droplets firewall-uuid --droplet-ids 12345678,87654321
```

### Remove Droplets from Firewall

```bash
# Via API
curl -X DELETE \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"droplet_ids": [12345678]}' \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid/droplets"

# Via doctl
doctl compute firewall remove-droplets firewall-uuid --droplet-ids 12345678
```

### Add Tags to Firewall

```bash
# Via API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"tags": ["web-tier", "production"]}' \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid/tags"

# Via doctl
doctl compute firewall add-tags firewall-uuid --tag-names web-tier,production
```

### Delete Firewall

```bash
# Via API
curl -X DELETE \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/firewalls/firewall-uuid"

# Via doctl
doctl compute firewall delete firewall-uuid
```

## Firewall Rule Priority

Rules are evaluated in order:
1. Most specific rules first
2. Broader rules last
3. First match wins
4. Default deny if no match

```
Example Evaluation:

Inbound Rules:
1. Allow TCP 22 from 203.0.113.10/32  ← Checked first
2. Allow TCP 22 from 203.0.113.0/24   ← Checked second
3. Allow TCP 443 from 0.0.0.0/0       ← Checked third
4. Deny all (implicit)                 ← Default

Request from 203.0.113.10:22 → Matches rule 1 → ALLOW
Request from 203.0.113.50:22 → Matches rule 2 → ALLOW
Request from 198.51.100.10:443 → Matches rule 3 → ALLOW
Request from 198.51.100.10:22 → No match → DENY
```

## Security Best Practices

### 1. Principle of Least Privilege

```
❌ Bad: Allow all traffic
{
  "protocol": "tcp",
  "ports": "all",
  "sources": {"addresses": ["0.0.0.0/0"]}
}

✓ Good: Allow only necessary ports
{
  "protocol": "tcp",
  "ports": "443",
  "sources": {"addresses": ["0.0.0.0/0"]}
}
```

### 2. Restrict SSH Access

```
❌ Bad: SSH from anywhere
{
  "protocol": "tcp",
  "ports": "22",
  "sources": {"addresses": ["0.0.0.0/0"]}
}

✓ Good: SSH from specific IPs
{
  "protocol": "tcp",
  "ports": "22",
  "sources": {"addresses": ["YOUR_IP/32", "OFFICE_IP/24"]}
}
```

### 3. Use Tags for Dynamic Infrastructure

```
✓ Good: Tag-based rules
{
  "protocol": "tcp",
  "ports": "5432",
  "sources": {"tags": ["app-tier"]}
}

Benefits:
- Automatic application to new Droplets
- Easier management at scale
- Consistent security policies
```

### 4. Separate Firewalls by Tier

```
Web Tier Firewall:
- Allow 443, 80 from internet
- Allow 22 from bastion

App Tier Firewall:
- Allow 8080 from web tier
- Allow 22 from bastion

Database Tier Firewall:
- Allow 5432 from app tier
- Allow 22 from bastion
```

### 5. Regular Audits

```bash
# Review firewall rules regularly
doctl compute firewall list --format ID,Name,Created

# Check which Droplets are protected
doctl compute firewall get firewall-uuid --format DropletIDs,Tags

# Verify rule effectiveness
# Monitor logs and adjust rules
```

## Stateful Firewall Behavior

Cloud Firewalls are stateful, meaning they track connection state:

```
Outbound Request:
Droplet → Internet (Port 443)
└─> Outbound rule allows

Return Traffic:
Internet → Droplet (Source Port 443)
└─> Automatically allowed (part of established connection)

No need for explicit inbound rule for return traffic!
```

## Combining with Host-Based Firewalls

### Defense in Depth

```
┌─────────────────────────────────────────┐
│         Cloud Firewall (Layer 1)        │
│  • Network-level protection             │
│  • Managed by DigitalOcean              │
│  • Applied before traffic reaches host  │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│      Host Firewall (Layer 2)            │
│  • iptables / ufw / firewalld           │
│  • Application-specific rules           │
│  • Additional protection layer          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Application (Layer 3)           │
│  • Authentication                       │
│  • Authorization                        │
│  • Input validation                     │
└─────────────────────────────────────────┘
```

### Example Configuration

```bash
# Cloud Firewall: Allow 443 from internet
# (Configured in DigitalOcean control panel)

# Host Firewall (ufw): Additional restrictions
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 443/tcp
sudo ufw allow from 10.10.0.0/16 to any port 22
sudo ufw enable

# Application: Authentication and authorization
# (Implemented in application code)
```

## Troubleshooting

### Cannot Connect to Droplet

```bash
# 1. Check Cloud Firewall rules
doctl compute firewall list-by-droplet droplet-id

# 2. Verify inbound rules allow your IP
doctl compute firewall get firewall-uuid

# 3. Check if Droplet has correct tags
doctl compute droplet get droplet-id --format Tags

# 4. Test connectivity
telnet droplet-ip port
nc -zv droplet-ip port

# 5. Check host firewall
sudo ufw status
sudo iptables -L -n
```

### Firewall Not Applying to Droplet

```bash
# Verify Droplet is in firewall
doctl compute firewall get firewall-uuid --format DropletIDs

# Check Droplet tags
doctl compute droplet get droplet-id --format Tags

# Add Droplet to firewall
doctl compute firewall add-droplets firewall-uuid --droplet-ids droplet-id

# Or add tag to Droplet
doctl compute droplet tag droplet-id --tag-names web-tier
```

### Rules Not Working as Expected

1. Check rule order (most specific first)
2. Verify protocol and port numbers
3. Confirm source/destination addresses
4. Test with temporary "allow all" rule
5. Review Droplet's host firewall
6. Check application logs

## Limitations

- Maximum 100 inbound rules per firewall
- Maximum 100 outbound rules per firewall
- Maximum 100 Droplets per firewall (via direct assignment)
- Unlimited Droplets via tags
- Cannot apply to resources outside DigitalOcean
- Regional scope (applies to Droplets in any region)

## Pricing

- **Cloud Firewalls**: Free
- **No Limits**: Unlimited firewalls and rules
- **No Performance Impact**: Managed service

## Related Services

- [VPC](./4-VPC.md) - Network isolation for resources
- [Load Balancers](./3-LOAD-BALANCERS.md) - Use as source in firewall rules
- [Reserved IPs](./2-RESERVED-IPS.md) - Protect static IPs with firewalls
