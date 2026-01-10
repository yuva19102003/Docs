# Managing DigitalOcean Droplets

## Overview

This guide covers day-to-day Droplet management operations including power management, resizing, snapshots, backups, and maintenance tasks.

## Power Management

### Power Operations

```
┌─────────────────────────────────────────────────────────────┐
│                  Power Management States                     │
└─────────────────────────────────────────────────────────────┘

Active (Running)
├─> Droplet is powered on
├─> Consuming resources
├─> Billing active
└─> Accessible via network

Powered Off
├─> Graceful shutdown
├─> Data preserved
├─> Still billed (resources reserved)
└─> Can be powered on quickly

Powered Off (Hard)
├─> Force shutdown
├─> May cause data loss
├─> Use only if necessary
└─> Still billed

Destroyed
├─> Droplet deleted
├─> Data lost (unless snapshot taken)
├─> Billing stopped
└─> Cannot be recovered
```

### Via Control Panel

```
1. Navigate to Droplets
2. Click on Droplet name
3. Click "Power" dropdown
4. Select action:
   ├─> Power On
   ├─> Power Off
   ├─> Power Cycle
   └─> Reboot
```

### Via doctl CLI

```bash
# Power off (graceful)
doctl compute droplet-action power-off DROPLET_ID

# Power on
doctl compute droplet-action power-on DROPLET_ID

# Reboot (graceful)
doctl compute droplet-action reboot DROPLET_ID

# Power cycle (hard reboot)
doctl compute droplet-action power-cycle DROPLET_ID

# Shutdown (graceful, via OS)
doctl compute droplet-action shutdown DROPLET_ID
```

### Via API

```bash
# Power off
curl -X POST \
  -H "Authorization: Bearer $DO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"power_off"}' \
  "https://api.digitalocean.com/v2/droplets/DROPLET_ID/actions"

# Power on
curl -X POST \
  -H "Authorization: Bearer $DO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"power_on"}' \
  "https://api.digitalocean.com/v2/droplets/DROPLET_ID/actions"
```

## Resizing Droplets

### Resize Types

**Disk Resize (Permanent)**
```
Changes:
├─> CPU
├─> RAM
├─> Disk (increases only)
└─> Cannot downgrade disk

Process:
├─> Power off Droplet
├─> Select new size
├─> Resize (5-10 minutes)
└─> Power on
```

**Flexible Resize (Reversible)**
```
Changes:
├─> CPU
├─> RAM
└─> Disk stays same

Process:
├─> Power off Droplet
├─> Select new size
├─> Resize (2-5 minutes)
├─> Power on
└─> Can resize up or down
```

### Resizing Process

#### Via Control Panel

```
1. Power off Droplet
2. Navigate to Droplet → Resize
3. Choose resize type:
   ├─> Resize disk (permanent)
   └─> Resize CPU/RAM only (flexible)
4. Select new size
5. Click "Resize Droplet"
6. Wait for completion
7. Power on Droplet
```

#### Via doctl CLI

```bash
# Resize with disk
doctl compute droplet-action resize DROPLET_ID \
  --size s-2vcpu-4gb \
  --resize-disk

# Resize without disk (flexible)
doctl compute droplet-action resize DROPLET_ID \
  --size s-2vcpu-4gb

# Check resize status
doctl compute droplet-action get DROPLET_ID --action-id ACTION_ID
```

### Resize Planning

```
Before Resizing:
├─> Create snapshot (backup)
├─> Plan downtime window
├─> Notify users
├─> Test application compatibility
└─> Document changes

During Resize:
├─> Monitor progress
├─> Check for errors
└─> Verify completion

After Resize:
├─> Power on Droplet
├─> Verify services running
├─> Check application performance
├─> Monitor resource usage
└─> Update documentation
```

## Snapshots

### What are Snapshots?

```
Snapshots:
├─> Point-in-time backup
├─> Full disk image
├─> Can create new Droplets
├─> Stored in same region
└─> Billed at $0.06/GB/month

Use Cases:
├─> Before major changes
├─> Template for new Droplets
├─> Disaster recovery
├─> Testing environments
└─> Migration between regions
```

### Creating Snapshots

#### Via Control Panel

```
1. Power off Droplet (recommended)
2. Navigate to Droplet → Snapshots
3. Enter snapshot name
4. Click "Take Snapshot"
5. Wait for completion (5-30 minutes)
```

#### Via doctl CLI

```bash
# Create snapshot
doctl compute droplet-action snapshot DROPLET_ID \
  --snapshot-name "web-prod-01-2026-01-10"

# List snapshots
doctl compute snapshot list --resource droplet

# Delete snapshot
doctl compute snapshot delete SNAPSHOT_ID
```

### Snapshot Best Practices

```
Naming Convention:
<droplet-name>-<date>-<purpose>

Examples:
├─> web-prod-01-2026-01-10-pre-upgrade
├─> db-primary-2026-01-10-daily
├─> api-staging-2026-01-10-template
└─> worker-01-2026-01-10-backup

Schedule:
├─> Before major changes
├─> Weekly for production
├─> Monthly for stable systems
└─> Before OS upgrades

Retention:
├─> Keep last 3-5 snapshots
├─> Delete old snapshots
├─> Monitor storage costs
└─> Archive important snapshots
```

### Restoring from Snapshots

```bash
# Create new Droplet from snapshot
doctl compute droplet create restored-droplet \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image SNAPSHOT_ID \
  --ssh-keys SSH_KEY_ID

# Rebuild existing Droplet from snapshot
doctl compute droplet-action rebuild DROPLET_ID \
  --image SNAPSHOT_ID
```

## Automated Backups

### Backup Features

```
Automated Backups:
├─> Weekly backups
├─> 4 backups retained
├─> Automatic rotation
├─> Cost: 20% of Droplet price
└─> Enabled per Droplet

Backup Schedule:
├─> Weekly (same day/time)
├─> During low-traffic hours
├─> Automatic rotation
└─> Cannot customize schedule

Retention:
├─> 4 most recent backups
├─> Oldest deleted automatically
├─> Can convert to snapshot
└─> Stored in same region
```

### Enabling Backups

#### Via Control Panel

```
1. Navigate to Droplet
2. Click "Backups"
3. Click "Enable Backups"
4. Confirm (adds 20% to cost)
```

#### Via doctl CLI

```bash
# Enable backups
doctl compute droplet-action enable-backups DROPLET_ID

# Disable backups
doctl compute droplet-action disable-backups DROPLET_ID

# List backups
doctl compute droplet-backups DROPLET_ID
```

### Backup vs Snapshot

| Feature | Backups | Snapshots |
|---------|---------|-----------|
| **Cost** | 20% of Droplet | $0.06/GB/month |
| **Frequency** | Weekly (auto) | Manual |
| **Retention** | 4 backups | Unlimited |
| **Control** | Limited | Full control |
| **Best For** | Production | Templates, migrations |

## Rebuilding Droplets

### Rebuild Process

```
Rebuild:
├─> Reinstalls OS
├─> Keeps IP address
├─> Keeps Droplet ID
├─> Deletes all data
└─> Use snapshot/backup to restore

When to Rebuild:
├─> System corruption
├─> Security compromise
├─> Fresh start needed
└─> OS upgrade
```

### Rebuilding Steps

```bash
# Rebuild from image
doctl compute droplet-action rebuild DROPLET_ID \
  --image ubuntu-22-04-x64

# Rebuild from snapshot
doctl compute droplet-action rebuild DROPLET_ID \
  --image SNAPSHOT_ID

# Rebuild from backup
doctl compute droplet-action restore DROPLET_ID \
  --image BACKUP_ID
```

## Monitoring and Metrics

### Built-in Monitoring

```
Available Metrics:
├─> CPU usage (%)
├─> Memory usage (%)
├─> Disk usage (%)
├─> Disk I/O
├─> Bandwidth (inbound/outbound)
└─> Public/Private network traffic

Retention:
├─> 1-minute intervals
├─> 30 days of data
└─> Free with monitoring enabled
```

### Viewing Metrics

#### Via Control Panel

```
1. Navigate to Droplet
2. Click "Graphs" tab
3. View metrics:
   ├─> CPU
   ├─> Memory
   ├─> Disk
   └─> Bandwidth
4. Adjust time range
```

#### Via API

```bash
# Get CPU metrics
curl -X GET \
  -H "Authorization: Bearer $DO_TOKEN" \
  "https://api.digitalocean.com/v2/monitoring/metrics/droplet/cpu?host_id=DROPLET_ID&start=START_TIME&end=END_TIME"
```

### Setting Up Alerts

```
Alert Types:
├─> CPU usage > threshold
├─> Memory usage > threshold
├─> Disk usage > threshold
├─> Bandwidth usage > threshold
└─> Droplet down

Notification Methods:
├─> Email
├─> Slack
└─> PagerDuty (via webhook)
```

## Tagging and Organization

### Tag Management

```bash
# Add tags to Droplet
doctl compute droplet tag DROPLET_ID \
  --tag-names production,web,frontend

# Remove tags
doctl compute droplet untag DROPLET_ID \
  --tag-names staging

# List Droplets by tag
doctl compute droplet list --tag-name production

# Bulk operations by tag
doctl compute droplet-action power-off \
  --tag-name staging
```

### Tag Strategies

```
Environment Tags:
├─> production
├─> staging
├─> development
└─> testing

Purpose Tags:
├─> web
├─> api
├─> database
├─> cache
└─> worker

Team Tags:
├─> frontend
├─> backend
├─> devops
└─> data

Project Tags:
├─> project-alpha
├─> project-beta
└─> internal-tools
```

## Kernel Updates

### Updating Kernel

```bash
# Check current kernel
uname -r

# Update packages
sudo apt-get update
sudo apt-get upgrade

# Reboot to apply kernel updates
sudo reboot

# Verify new kernel
uname -r
```

### Kernel Management

```
DigitalOcean Kernels:
├─> Managed by DigitalOcean (legacy)
├─> Updated via control panel
└─> Being phased out

Distribution Kernels:
├─> Managed by OS (modern)
├─> Updated via package manager
├─> Recommended approach
└─> More control
```

## Recovery Console

### Accessing Console

```
Via Control Panel:
1. Navigate to Droplet
2. Click "Access" tab
3. Click "Launch Droplet Console"
4. Browser-based terminal opens

Use Cases:
├─> SSH not accessible
├─> Network issues
├─> Firewall lockout
├─> Emergency access
└─> Troubleshooting
```

### Recovery Mode

```
Recovery Mode:
├─> Boot from recovery ISO
├─> Access filesystem
├─> Fix boot issues
├─> Reset passwords
└─> Recover data

Steps:
1. Power off Droplet
2. Enable recovery mode
3. Power on Droplet
4. Access via console
5. Mount filesystem
6. Make repairs
7. Disable recovery mode
8. Reboot normally
```

## Droplet Metadata

### Accessing Metadata

```bash
# From within Droplet
curl http://169.254.169.254/metadata/v1/

# Get Droplet ID
curl http://169.254.169.254/metadata/v1/id

# Get hostname
curl http://169.254.169.254/metadata/v1/hostname

# Get region
curl http://169.254.169.254/metadata/v1/region

# Get public IPv4
curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address

# Get tags
curl http://169.254.169.254/metadata/v1/tags

# Get user data
curl http://169.254.169.254/metadata/v1/user-data
```

### Using Metadata in Scripts

```bash
#!/bin/bash
# Auto-configure based on metadata

DROPLET_ID=$(curl -s http://169.254.169.254/metadata/v1/id)
REGION=$(curl -s http://169.254.169.254/metadata/v1/region)
TAGS=$(curl -s http://169.254.169.254/metadata/v1/tags)

echo "Droplet ID: $DROPLET_ID"
echo "Region: $REGION"
echo "Tags: $TAGS"

# Configure based on tags
if echo "$TAGS" | grep -q "production"; then
    echo "Configuring for production..."
    # Production-specific configuration
fi
```

## Maintenance Best Practices

### Regular Maintenance

```
Weekly:
├─> Check disk space
├─> Review logs
├─> Monitor resource usage
├─> Check for security updates
└─> Verify backups

Monthly:
├─> Update packages
├─> Review access logs
├─> Audit user accounts
├─> Check firewall rules
└─> Test disaster recovery

Quarterly:
├─> Review Droplet sizing
├─> Optimize costs
├─> Update documentation
├─> Security audit
└─> Performance tuning
```

### Update Strategy

```bash
# Safe update process
# 1. Create snapshot
doctl compute droplet-action snapshot DROPLET_ID \
  --snapshot-name "pre-update-$(date +%Y%m%d)"

# 2. Update packages
ssh root@droplet-ip << 'EOF'
apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean
EOF

# 3. Reboot if needed
doctl compute droplet-action reboot DROPLET_ID

# 4. Verify services
ssh root@droplet-ip "systemctl status nginx"
```

## Cost Optimization

### Right-Sizing

```
Monitor Usage:
├─> CPU utilization
├─> Memory usage
├─> Disk I/O
├─> Network bandwidth
└─> Application performance

Optimization:
├─> Downsize if underutilized
├─> Upsize if overloaded
├─> Use appropriate Droplet type
├─> Consider reserved instances
└─> Delete unused Droplets
```

### Cost-Saving Tips

```
1. Delete Unused Droplets
   └─> Take snapshot first

2. Use Snapshots Instead of Idle Droplets
   └─> $0.06/GB vs full Droplet cost

3. Right-Size Droplets
   └─> Don't over-provision

4. Use Basic Droplets for Dev/Test
   └─> Cheaper than production sizes

5. Clean Up Old Snapshots
   └─> Delete unnecessary backups

6. Use Block Storage for Data
   └─> Cheaper than large Droplets

7. Monitor Bandwidth Usage
   └─> Optimize data transfer
```

## Troubleshooting

### Common Issues

**Droplet Not Responding**
```bash
# Check status
doctl compute droplet get DROPLET_ID

# Check via console
# Use recovery console in control panel

# Power cycle
doctl compute droplet-action power-cycle DROPLET_ID
```

**High CPU Usage**
```bash
# Check processes
top
htop

# Find CPU-intensive processes
ps aux --sort=-%cpu | head -10

# Check system load
uptime
```

**Out of Disk Space**
```bash
# Check disk usage
df -h

# Find large files
du -h / | sort -rh | head -20

# Clean up
apt-get autoremove
apt-get autoclean
journalctl --vacuum-time=7d
```

**Network Issues**
```bash
# Check network interfaces
ip addr show

# Test connectivity
ping -c 4 8.8.8.8

# Check DNS
nslookup google.com

# Review firewall
ufw status
iptables -L
```

## Next Steps

- [Learn about Droplet images](./3-DROPLET-IMAGES.md)
- [Configure networking](./4-DROPLET-NETWORKING.md)
- [Set up monitoring](./7-DROPLET-MONITORING.md)
- [Automate management](./8-DROPLET-AUTOMATION.md)
