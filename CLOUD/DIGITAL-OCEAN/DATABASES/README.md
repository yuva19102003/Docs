# DigitalOcean Managed Databases

Fully managed database clusters with automated backups, high availability, and easy scaling.

## Supported Engines
- PostgreSQL (12-16)
- MySQL (8.0)
- Redis (6-7)
- MongoDB (5-7)
- Kafka (3.5-3.6)
- OpenSearch (1.x-2.x)

## Documentation
- [Databases Overview](./0-DATABASES-OVERVIEW.md)

## Quick Start
```bash
# Create PostgreSQL database
doctl databases create my-db --engine pg --region nyc3 --size db-s-2vcpu-4gb

# Get connection info
doctl databases connection my-db
```

## Links
- [Official Docs](https://docs.digitalocean.com/products/databases/)
- [Pricing](https://www.digitalocean.com/pricing/managed-databases)
