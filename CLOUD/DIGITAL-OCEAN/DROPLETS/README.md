# DigitalOcean Droplets Documentation

Complete documentation for DigitalOcean Droplets - virtual machines that power your cloud infrastructure.

## 📚 Documentation Index

### Core Documentation

1. **[Droplets Overview](./0-DROPLETS-OVERVIEW.md)**
   - What are Droplets?
   - Droplet types and sizing
   - Supported operating systems
   - Pricing and use cases
   - Architecture overview

2. **[Creating Droplets](./1-CREATING-DROPLETS.md)**
   - Creation methods (Control Panel, CLI, API, Terraform)
   - Step-by-step guides
   - Configuration options
   - Best practices
   - Common patterns

3. **[Managing Droplets](./2-MANAGING-DROPLETS.md)**
   - Power management
   - Resizing Droplets
   - Snapshots and backups
   - Monitoring and metrics
   - Maintenance tasks

## 🚀 Quick Start

### Create Your First Droplet (5 Minutes)

```bash
# 1. Install doctl
brew install doctl  # macOS
# or
snap install doctl  # Linux

# 2. Authenticate
doctl auth init

# 3. Create SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# 4. Add SSH key to DigitalOcean
doctl compute ssh-key import my-key \
  --public-key-file ~/.ssh/id_ed25519.pub

# 5. Create Droplet
doctl compute droplet create my-first-droplet \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header) \
  --wait

# 6. Get IP address
doctl compute droplet list --format Name,PublicIPv4

# 7. SSH into Droplet
ssh root@<droplet-ip>
```

## 💡 Common Use Cases

### 1. Web Server

```bash
# Create web server Droplet
doctl compute droplet create web-server \
  --region nyc3 \
  --size s-1vcpu-2gb \
  --image ubuntu-22-04-x64 \
  --user-data-file - << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw --force enable
EOF
```

### 2. Database Server

```bash
# Create database Droplet
doctl compute droplet create db-server \
  --region nyc3 \
  --size m-2vcpu-16gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid <vpc-id> \
  --enable-backups \
  --tag-names database,production
```

### 3. Development Environment

```bash
# Create dev Droplet with Docker
doctl compute droplet create dev-env \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image docker-20-04 \
  --enable-monitoring \
  --tag-names development
```

## 📊 Droplet Types Comparison

| Type | Best For | CPU | Starting Price |
|------|----------|-----|----------------|
| **Basic** | Development, testing, low-traffic sites | Shared | $4/month |
| **General Purpose** | Production apps, medium traffic | Dedicated | $63/month |
| **CPU-Optimized** | CI/CD, video encoding, ML | High-frequency | $42/month |
| **Memory-Optimized** | Databases, caching, analytics | Dedicated | $126/month |
| **Storage-Optimized** | Data warehousing, logs | Dedicated | $168/month |

## 🏗️ Architecture Patterns

### Three-Tier Web Application

```
                    Internet
                        │
                ┌───────▼────────┐
                │ Load Balancer  │
                └───────┬────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐     ┌────▼────┐    ┌────▼────┐
   │  Web    │     │  Web    │    │  Web    │
   │ Droplet │     │ Droplet │    │ Droplet │
   └────┬────┘     └────┬────┘    └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                ┌───────▼────────┐
                │  App Droplets  │
                └───────┬────────┘
                        │
                ┌───────▼────────┐
                │   Database     │
                │    Droplet     │
                └────────────────┘
```

### High Availability Setup

```
Region: NYC3                    Region: SFO3
┌─────────────────────┐        ┌─────────────────────┐
│  Primary Droplets   │        │  Backup Droplets    │
│  ├─> Web Tier       │◄──────►│  ├─> Web Tier       │
│  ├─> App Tier       │  Sync  │  ├─> App Tier       │
│  └─> DB Primary     │        │  └─> DB Replica     │
└─────────────────────┘        └─────────────────────┘
```

## 🔧 Management Commands

### Power Management

```bash
# Power operations
doctl compute droplet-action power-off <droplet-id>
doctl compute droplet-action power-on <droplet-id>
doctl compute droplet-action reboot <droplet-id>
doctl compute droplet-action power-cycle <droplet-id>
```

### Resizing

```bash
# Resize with disk
doctl compute droplet-action resize <droplet-id> \
  --size s-2vcpu-4gb \
  --resize-disk

# Resize without disk (flexible)
doctl compute droplet-action resize <droplet-id> \
  --size s-2vcpu-4gb
```

### Snapshots

```bash
# Create snapshot
doctl compute droplet-action snapshot <droplet-id> \
  --snapshot-name "backup-$(date +%Y%m%d)"

# List snapshots
doctl compute snapshot list --resource droplet

# Create Droplet from snapshot
doctl compute droplet create restored \
  --image <snapshot-id> \
  --region nyc3 \
  --size s-1vcpu-1gb
```

### Backups

```bash
# Enable backups
doctl compute droplet-action enable-backups <droplet-id>

# Disable backups
doctl compute droplet-action disable-backups <droplet-id>

# List backups
doctl compute droplet-backups <droplet-id>
```

## 🔒 Security Best Practices

### Initial Setup

```bash
# 1. Use SSH keys (not passwords)
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. Create Cloud Firewall
doctl compute firewall create web-firewall \
  --inbound-rules "protocol:tcp,ports:22,address:YOUR_IP/32 protocol:tcp,ports:80,address:0.0.0.0/0 protocol:tcp,ports:443,address:0.0.0.0/0" \
  --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0" \
  --droplet-ids <droplet-id>

# 3. Update system
ssh root@<droplet-ip> << 'EOF'
apt-get update
apt-get upgrade -y
apt-get install -y ufw fail2ban
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
systemctl enable fail2ban
systemctl start fail2ban
EOF
```

### Hardening Checklist

- ✅ Use SSH keys (disable password auth)
- ✅ Enable Cloud Firewall
- ✅ Configure UFW on Droplet
- ✅ Install fail2ban
- ✅ Keep system updated
- ✅ Use VPC for internal communication
- ✅ Enable monitoring and alerts
- ✅ Regular backups/snapshots
- ✅ Implement least privilege
- ✅ Use strong passwords for services

## 💰 Cost Optimization

### Tips to Save Money

1. **Right-Size Your Droplets**
   ```bash
   # Monitor usage
   doctl compute droplet get <droplet-id> --format ID,Name,Memory,Disk,Vcpus
   
   # Resize if needed
   doctl compute droplet-action resize <droplet-id> --size s-1vcpu-1gb
   ```

2. **Use Snapshots for Idle Droplets**
   ```bash
   # Take snapshot
   doctl compute droplet-action snapshot <droplet-id> --snapshot-name "idle-backup"
   
   # Destroy Droplet
   doctl compute droplet delete <droplet-id>
   
   # Recreate when needed
   doctl compute droplet create restored --image <snapshot-id>
   ```

3. **Clean Up Unused Resources**
   ```bash
   # List all Droplets
   doctl compute droplet list
   
   # Delete unused Droplets
   doctl compute droplet delete <droplet-id>
   
   # Clean up old snapshots
   doctl compute snapshot list --resource droplet
   doctl compute snapshot delete <snapshot-id>
   ```

4. **Use Basic Droplets for Dev/Test**
   - Development: Basic $6-12/month
   - Staging: Basic $12-24/month
   - Production: General Purpose $63+/month

## 📈 Monitoring

### Built-in Metrics

```bash
# Enable monitoring
doctl compute droplet-action enable-monitoring <droplet-id>

# View metrics via control panel:
# - CPU usage
# - Memory usage
# - Disk usage
# - Bandwidth
# - Network traffic
```

### Custom Monitoring

```bash
# Install monitoring agent
ssh root@<droplet-ip> << 'EOF'
# Install Prometheus Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service << 'SERVICE'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
EOF
```

## 🔄 Automation with Terraform

### Basic Configuration

```hcl
# main.tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  count  = 3
  name   = "web-${count.index + 1}"
  region = "nyc3"
  size   = "s-1vcpu-2gb"
  image  = "ubuntu-22-04-x64"
  
  ssh_keys = [var.ssh_key_id]
  
  tags = ["web", "production"]
  
  vpc_uuid   = digitalocean_vpc.main.id
  monitoring = true
  backups    = true
}

resource "digitalocean_loadbalancer" "web" {
  name   = "web-lb"
  region = "nyc3"
  
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port     = 80
    target_protocol = "http"
  }
  
  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"
  }
  
  droplet_ids = digitalocean_droplet.web[*].id
}
```

## 🐛 Troubleshooting

### Common Issues

**Cannot SSH into Droplet**
```bash
# Check Droplet status
doctl compute droplet get <droplet-id>

# Check firewall rules
doctl compute firewall list-by-droplet <droplet-id>

# Use recovery console
# Access via Control Panel → Droplet → Access → Launch Console
```

**High CPU Usage**
```bash
# Check processes
ssh root@<droplet-ip> "top -bn1 | head -20"

# Check system load
ssh root@<droplet-ip> "uptime"

# Consider resizing
doctl compute droplet-action resize <droplet-id> --size s-2vcpu-4gb
```

**Out of Disk Space**
```bash
# Check disk usage
ssh root@<droplet-ip> "df -h"

# Find large files
ssh root@<droplet-ip> "du -h / | sort -rh | head -20"

# Clean up
ssh root@<droplet-ip> << 'EOF'
apt-get autoremove -y
apt-get autoclean
journalctl --vacuum-time=7d
EOF

# Or resize with more disk
doctl compute droplet-action resize <droplet-id> --size s-2vcpu-4gb --resize-disk
```

## 📚 Additional Resources

### Official Documentation
- [DigitalOcean Droplets Docs](https://docs.digitalocean.com/products/droplets/)
- [API Reference](https://docs.digitalocean.com/reference/api/)
- [doctl CLI Reference](https://docs.digitalocean.com/reference/doctl/)

### Community Resources
- [Community Tutorials](https://www.digitalocean.com/community/tutorials)
- [Community Q&A](https://www.digitalocean.com/community/questions)
- [DigitalOcean Blog](https://www.digitalocean.com/blog/)

### Tools & Integrations
- [Terraform Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
- [Ansible Collection](https://galaxy.ansible.com/community/digitalocean)
- [Pulumi Provider](https://www.pulumi.com/registry/packages/digitalocean/)

## 🎯 Next Steps

1. **Get Started**: [Create your first Droplet](./1-CREATING-DROPLETS.md)
2. **Learn Management**: [Managing Droplets guide](./2-MANAGING-DROPLETS.md)
3. **Explore Networking**: [Droplet Networking](../NETWORKING/README.md)
4. **Set Up Monitoring**: [Monitoring guide](./7-DROPLET-MONITORING.md)
5. **Automate**: [Automation with API/CLI](./8-DROPLET-AUTOMATION.md)

---

**Last Updated**: January 2026  
**Version**: 1.0  
**Maintained by**: DevOps Documentation Team
