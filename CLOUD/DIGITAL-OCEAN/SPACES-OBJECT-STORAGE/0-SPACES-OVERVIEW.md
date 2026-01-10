# DigitalOcean Spaces Object Storage Overview

## Introduction

Spaces is DigitalOcean's S3-compatible object storage service designed for storing and serving large amounts of unstructured data. It's ideal for backups, media files, static assets, and data lakes.

## Key Features

- **S3-Compatible API**: Works with existing S3 tools and libraries
- **Global CDN**: Built-in content delivery network
- **Scalable**: Store unlimited data
- **Durable**: 99.999999999% (11 nines) durability
- **Affordable**: $5/month for 250 GB storage + 1 TB transfer
- **Access Control**: Fine-grained permissions with ACLs
- **CORS Support**: Cross-origin resource sharing
- **Lifecycle Policies**: Automatic data management
- **Versioning**: Keep multiple versions of objects
- **Custom Domains**: Use your own domain names


## Spaces Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Users / Applications                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   CDN (Optional)│
                    │  Edge Locations │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Spaces Bucket  │
                    │  (S3-Compatible)│
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Images  │         │ Videos  │         │ Backups │
   │ /images │         │ /videos │         │ /backup │
   └─────────┘         └─────────┘         └─────────┘

Storage: Distributed across multiple availability zones
CDN: 300+ edge locations worldwide
```

## Use Cases

### 1. Static Website Hosting
```
Use Case: Host static websites
├─> HTML, CSS, JavaScript files
├─> Images and media
├─> Single Page Applications (SPAs)
└─> Documentation sites

Benefits:
├─> Global CDN included
├─> Custom domains
├─> HTTPS support
└─> Cost-effective
```

### 2. Media Storage
```
Use Case: Store and serve media files
├─> Images (photos, thumbnails)
├─> Videos (streaming, downloads)
├─> Audio files
└─> Documents (PDFs, presentations)

Benefits:
├─> Unlimited storage
├─> Fast delivery via CDN
├─> Image optimization
└─> Bandwidth included
```

### 3. Backup and Archive
```
Use Case: Data backup and archival
├─> Database backups
├─> Application backups
├─> Log files
└─> Historical data

Benefits:
├─> Durable storage
├─> Lifecycle policies
├─> Versioning
└─> Cost-effective
```

### 4. Application Assets
```
Use Case: Store application files
├─> User uploads
├─> Generated reports
├─> Temporary files
└─> Cache storage

Benefits:
├─> S3-compatible API
├─> Easy integration
├─> Scalable
└─> Reliable
```

## Pricing

### Storage
```
$5/month includes:
├─> 250 GB storage
├─> 1 TB outbound transfer
└─> Unlimited inbound transfer

Additional:
├─> $0.02/GB storage over 250 GB
└─> $0.01/GB transfer over 1 TB
```

### CDN
```
$1/month per Space with CDN enabled
├─> Global edge caching
├─> Custom SSL certificates
├─> Purge cache
└─> 300+ edge locations
```

## S3 Compatibility

### Compatible Tools
```
AWS CLI:
├─> aws s3 cp
├─> aws s3 sync
├─> aws s3 ls
└─> Full S3 command support

SDKs:
├─> AWS SDK for JavaScript
├─> AWS SDK for Python (boto3)
├─> AWS SDK for Go
├─> AWS SDK for Java
├─> AWS SDK for PHP
└─> AWS SDK for Ruby

Third-Party Tools:
├─> Cyberduck
├─> Transmit
├─> S3 Browser
├─> CloudBerry
└─> rclone
```

### API Endpoints
```
Region Endpoints:
├─> NYC3: nyc3.digitaloceanspaces.com
├─> AMS3: ams3.digitaloceanspaces.com
├─> SGP1: sgp1.digitaloceanspaces.com
├─> SFO3: sfo3.digitaloceanspaces.com
└─> FRA1: fra1.digitaloceanspaces.com

CDN Endpoint:
└─> <space-name>.cdn.digitaloceanspaces.com
```

## Access Control

### Access Methods
```
1. Access Keys
   ├─> Access Key ID
   ├─> Secret Access Key
   └─> Programmatic access

2. Bucket ACLs
   ├─> Private (default)
   ├─> Public-read
   └─> Custom permissions

3. CORS Policies
   ├─> Cross-origin requests
   ├─> Allowed origins
   └─> Allowed methods

4. Signed URLs
   ├─> Temporary access
   ├─> Time-limited
   └─> Secure sharing
```

## Features

### 1. CDN Integration
```
Enable CDN:
├─> Automatic edge caching
├─> Global distribution
├─> Custom TTL
├─> Cache purging
└─> SSL/TLS support

Benefits:
├─> Faster content delivery
├─> Reduced origin load
├─> Better user experience
└─> Lower bandwidth costs
```

### 2. Lifecycle Policies
```
Automate Data Management:
├─> Delete old files
├─> Move to archive
├─> Clean up incomplete uploads
└─> Expire versions

Example Rules:
├─> Delete files older than 90 days
├─> Remove incomplete uploads after 7 days
└─> Expire old versions after 30 days
```

### 3. Versioning
```
Object Versioning:
├─> Keep multiple versions
├─> Protect from deletion
├─> Recover old versions
└─> Audit changes

Use Cases:
├─> Accidental deletion protection
├─> Compliance requirements
├─> Version history
└─> Rollback capability
```

### 4. CORS Configuration
```
Cross-Origin Resource Sharing:
├─> Allow web apps to access
├─> Configure allowed origins
├─> Set allowed methods
└─> Define headers

Example:
├─> Allow GET from example.com
├─> Allow POST from app.example.com
└─> Allow DELETE from admin.example.com
```

## Quick Start

### Create Space via CLI
```bash
# Install doctl
brew install doctl

# Authenticate
doctl auth init

# Create Space
doctl compute space create my-space \
  --region nyc3

# List Spaces
doctl compute space list

# Enable CDN
doctl compute space cdn enable my-space
```

### Upload Files
```bash
# Using AWS CLI
aws s3 cp file.jpg s3://my-space/images/ \
  --endpoint=https://nyc3.digitaloceanspaces.com

# Using s3cmd
s3cmd put file.jpg s3://my-space/images/

# Using rclone
rclone copy file.jpg spaces:my-space/images/
```

## Best Practices

### 1. Organization
```
Folder Structure:
my-space/
├─> images/
│   ├─> products/
│   ├─> users/
│   └─> thumbnails/
├─> videos/
├─> documents/
└─> backups/
    ├─> daily/
    ├─> weekly/
    └─> monthly/
```

### 2. Security
- Use private buckets by default
- Generate signed URLs for temporary access
- Rotate access keys regularly
- Use CORS policies
- Enable versioning for critical data

### 3. Performance
- Enable CDN for public content
- Use appropriate cache headers
- Optimize file sizes
- Use parallel uploads
- Implement retry logic

### 4. Cost Optimization
- Use lifecycle policies
- Delete unused files
- Compress files before upload
- Monitor bandwidth usage
- Use CDN to reduce origin requests

## Documentation Structure

1. **[Spaces Overview](./0-SPACES-OVERVIEW.md)** - This page
2. **[Creating Spaces](./1-CREATING-SPACES.md)** - Setup and configuration
3. **[Managing Spaces](./2-MANAGING-SPACES.md)** - Operations and maintenance
4. **[CDN Configuration](./3-CDN-CONFIGURATION.md)** - Content delivery setup

## Next Steps

- [Create your first Space](./1-CREATING-SPACES.md)
- [Learn about CDN](./3-CDN-CONFIGURATION.md)
- [Explore management features](./2-MANAGING-SPACES.md)
