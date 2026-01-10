# DigitalOcean Backups & Snapshots

Data protection through automated backups and manual snapshots.

## Features
- Automated Droplet backups
- Manual snapshots
- Volume snapshots
- Database backups
- Point-in-time recovery

## Documentation
- [Backups & Snapshots Overview](./0-BACKUPS-SNAPSHOTS-OVERVIEW.md)

## Quick Start
```bash
# Enable backups on Droplet
doctl compute droplet-action enable-backups <droplet-id>

# Create snapshot
doctl compute droplet-action snapshot <droplet-id> --snapshot-name "backup-2026-01-10"
```

## Links
- [Official Docs](https://docs.digitalocean.com/products/images/)
- [Pricing](https://www.digitalocean.com/pricing)
