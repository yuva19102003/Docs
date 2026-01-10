# DigitalOcean Network File Storage

Scalable NFS-based shared file storage for multiple Droplets.

## Features
- NFS protocol support
- Shared across Droplets
- Scalable capacity
- High availability
- Regional storage

## Documentation
- [Network File Storage Overview](./0-NETWORK-FILE-STORAGE-OVERVIEW.md)

## Quick Start
```bash
# Create file storage
doctl compute file-system create my-nfs --region nyc3 --size 100GiB

# Mount on Droplet
sudo mount -t nfs <nfs-host>:/path /mnt/nfs
```

## Links
- [Official Docs](https://docs.digitalocean.com/products/file-storage/)
