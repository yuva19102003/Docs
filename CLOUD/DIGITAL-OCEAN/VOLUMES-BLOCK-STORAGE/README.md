# DigitalOcean Volumes (Block Storage)

Highly available SSD block storage that can be attached to Droplets for persistent data storage.

## Documentation

- [Volumes Overview](./0-VOLUMES-OVERVIEW.md) - Introduction and key features

## Quick Start

```bash
# Create volume
doctl compute volume create db-data \
  --region nyc3 \
  --size 100GiB

# Attach to Droplet
doctl compute volume-action attach VOLUME_ID DROPLET_ID

# Format and mount
sudo mkfs.ext4 /dev/disk/by-id/scsi-0DO_Volume_db-data
sudo mkdir -p /mnt/db-data
sudo mount /dev/disk/by-id/scsi-0DO_Volume_db-data /mnt/db-data
```

## Quick Links

- [Official Documentation](https://docs.digitalocean.com/products/volumes/)
- [API Reference](https://docs.digitalocean.com/reference/api/api-reference/#tag/Block-Storage)
- [Pricing](https://www.digitalocean.com/pricing/block-storage)
