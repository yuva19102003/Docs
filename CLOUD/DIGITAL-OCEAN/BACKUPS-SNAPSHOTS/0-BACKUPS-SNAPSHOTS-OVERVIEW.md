# DigitalOcean Backups & Snapshots Overview

## Introduction

Protect your data with automated backups and manual snapshots for Droplets, Volumes, and Databases.

## Backups vs Snapshots

| Feature | Backups | Snapshots |
|---------|---------|-----------|
| **Frequency** | Weekly (auto) | Manual |
| **Retention** | 4 backups | Unlimited |
| **Cost** | 20% of resource | $0.05/GB/month |
| **Use Case** | Ongoing protection | Templates, migrations |

## Droplet Backups

```bash
# Enable backups
doctl compute droplet-action enable-backups <droplet-id>

# Cost: 20% of Droplet price
# Frequency: Weekly
# Retention: 4 most recent backups
```

## Droplet Snapshots

```bash
# Create snapshot
doctl compute droplet-action snapshot <droplet-id> \
  --snapshot-name "backup-2026-01-10"

# Cost: $0.05/GB/month
# Use for: Templates, disaster recovery
```

## Volume Snapshots

```bash
# Create volume snapshot
doctl compute volume-snapshot create \
  --volume-id <volume-id> \
  --snapshot-name "db-backup-2026-01-10"
```

## Database Backups

```
Automated:
├─> Daily backups
├─> 7-day retention
├─> Point-in-time recovery
└─> Free (included)
```

## Best Practices

1. Enable backups for production Droplets
2. Create snapshots before major changes
3. Test restore procedures regularly
4. Use snapshots for templates
5. Clean up old snapshots
