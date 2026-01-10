# DigitalOcean Domains & DNS Management

## Overview

DigitalOcean provides free DNS hosting for all customers, allowing you to manage domain names and DNS records directly from the control panel or API. The DNS service runs on a global anycast network for fast, reliable resolution worldwide.

## Key Features

- **Free DNS Hosting**: No additional cost for DNS management
- **Global Anycast Network**: Fast DNS resolution from anywhere
- **Full Record Support**: A, AAAA, CNAME, MX, TXT, SRV, NS, CAA records
- **API Access**: Automate DNS management via API
- **DNSSEC Support**: Enhanced security for DNS queries
- **Wildcard Records**: Support for wildcard DNS entries
- **Low TTL Values**: Minimum 30 seconds for quick updates

## Supported DNS Record Types

### A Record (IPv4 Address)
Maps a domain name to an IPv4 address.
```
example.com → 192.0.2.1
```

### AAAA Record (IPv6 Address)
Maps a domain name to an IPv6 address.
```
example.com → 2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

### CNAME Record (Canonical Name)
Creates an alias from one domain to another.
```
www.example.com → example.com
```

### MX Record (Mail Exchange)
Specifies mail servers for the domain.
```
example.com → mail.example.com (Priority: 10)
```

### TXT Record (Text)
Stores text information, often used for verification and SPF records.
```
example.com → "v=spf1 include:_spf.google.com ~all"
```

### SRV Record (Service)
Defines location of services.
```
_service._proto.example.com → server.example.com:port
```

### NS Record (Name Server)
Delegates a subdomain to different name servers.
```
subdomain.example.com → ns1.otherprovider.com
```

### CAA Record (Certification Authority Authorization)
Specifies which CAs can issue certificates.
```
example.com → 0 issue "letsencrypt.org"
```

## DNS Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Global DNS Query                          │
│                  (User requests example.com)                 │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Root DNS       │
                    │  Servers        │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  TLD DNS        │
                    │  (.com servers) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────────────────────────┐
                    │  DigitalOcean Anycast DNS Network   │
                    │  (ns1.digitalocean.com)             │
                    │  (ns2.digitalocean.com)             │
                    │  (ns3.digitalocean.com)             │
                    └────────┬────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │  DNS    │         │  DNS    │         │  DNS    │
   │  PoP    │         │  PoP    │         │  PoP    │
   │  NYC    │         │  LON    │         │  SGP    │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  DNS Response   │
                    │  192.0.2.1      │
                    └─────────────────┘
```

## Setting Up a Domain

### Step 1: Add Domain to DigitalOcean

1. Navigate to **Networking** → **Domains**
2. Enter your domain name
3. Click **Add Domain**

### Step 2: Update Name Servers at Registrar

Point your domain to DigitalOcean's name servers:
```
ns1.digitalocean.com
ns2.digitalocean.com
ns3.digitalocean.com
```

### Step 3: Create DNS Records

Add necessary records for your domain:

```
# A Record for root domain
@ → 192.0.2.1

# A Record for www subdomain
www → 192.0.2.1

# MX Records for email
@ → mail.example.com (Priority: 10)

# TXT Record for SPF
@ → "v=spf1 include:_spf.example.com ~all"

# CNAME for subdomain
blog → example.com
```

## Common DNS Configurations

### Basic Website Setup
```
Type    Name    Value               TTL
A       @       192.0.2.1           3600
A       www     192.0.2.1           3600
CNAME   *       example.com         3600
```

### Email Server Setup
```
Type    Name    Value               Priority    TTL
MX      @       mail.example.com    10          3600
A       mail    192.0.2.2           -           3600
TXT     @       "v=spf1..."         -           3600
TXT     _dmarc  "v=DMARC1..."       -           3600
```

### Subdomain Delegation
```
Type    Name        Value                   TTL
NS      subdomain   ns1.otherprovider.com   3600
NS      subdomain   ns2.otherprovider.com   3600
```

### CDN Configuration
```
Type    Name    Value                       TTL
CNAME   cdn     cdn.provider.com            3600
CNAME   www     example.cdn.provider.com    3600
```

## DNS Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    DNS Management Workflow                   │
└─────────────────────────────────────────────────────────────┘

1. Purchase Domain
   └─> Register at domain registrar (Namecheap, GoDaddy, etc.)

2. Add to DigitalOcean
   └─> Control Panel → Networking → Domains → Add Domain

3. Update Name Servers
   └─> At registrar, point to DigitalOcean NS servers

4. Wait for Propagation
   └─> 24-48 hours (usually faster)

5. Create DNS Records
   ├─> A/AAAA records for IP addresses
   ├─> CNAME records for aliases
   ├─> MX records for email
   ├─> TXT records for verification
   └─> CAA records for SSL certificates

6. Verify Configuration
   └─> Use dig, nslookup, or online tools

7. Monitor & Update
   └─> Adjust TTL and records as needed
```

## Using the API

### Create a Domain Record
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"A","name":"www","data":"192.0.2.1","ttl":3600}' \
  "https://api.digitalocean.com/v2/domains/example.com/records"
```

### List Domain Records
```bash
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/domains/example.com/records"
```

### Update a Record
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"data":"192.0.2.2"}' \
  "https://api.digitalocean.com/v2/domains/example.com/records/RECORD_ID"
```

### Delete a Record
```bash
curl -X DELETE \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/domains/example.com/records/RECORD_ID"
```

## Best Practices

1. **Use Appropriate TTL Values**
   - Low TTL (300-600s) during migrations
   - Higher TTL (3600s+) for stable configurations
   - Balance between flexibility and DNS query load

2. **Implement Redundancy**
   - Multiple MX records with different priorities
   - Backup A records for critical services
   - Use multiple name servers

3. **Security Considerations**
   - Enable CAA records to control certificate issuance
   - Use SPF, DKIM, and DMARC for email authentication
   - Regularly audit DNS records
   - Avoid exposing internal infrastructure details

4. **Documentation**
   - Document all DNS records and their purposes
   - Track changes with version control
   - Maintain runbooks for DNS updates

5. **Monitoring**
   - Set up alerts for DNS resolution failures
   - Monitor DNS query performance
   - Track propagation times

## Troubleshooting

### DNS Not Resolving
```bash
# Check name servers
dig NS example.com

# Check A record
dig A example.com

# Query specific name server
dig @ns1.digitalocean.com example.com

# Check propagation
nslookup example.com 8.8.8.8
```

### Common Issues

1. **Name servers not updated at registrar**
   - Verify NS records point to DigitalOcean
   - Wait for propagation (up to 48 hours)

2. **Incorrect record configuration**
   - Verify record type and value
   - Check for typos in domain names
   - Ensure proper formatting

3. **TTL too high**
   - Old records cached by resolvers
   - Wait for TTL to expire or lower TTL before changes

4. **CNAME conflicts**
   - Cannot have CNAME at root (@)
   - CNAME cannot coexist with other records for same name

## DNS Security (DNSSEC)

DigitalOcean supports DNSSEC for enhanced security:

```
┌─────────────────────────────────────────┐
│         DNSSEC Validation Chain         │
└─────────────────────────────────────────┘

Root Zone (signed)
    │
    ├─> .com TLD (signed)
    │       │
    │       ├─> example.com (signed)
    │               │
    │               └─> DNS Records (verified)
    │
    └─> Trust Chain Validated ✓
```

### Enable DNSSEC
1. Generate DS records in DigitalOcean
2. Add DS records to your registrar
3. Verify DNSSEC validation

## Performance Optimization

- **Use CDN with DNS**: Combine with CDN for global performance
- **Geo-DNS**: Route users to nearest servers (via third-party)
- **Health Checks**: Integrate with monitoring for automatic failover
- **Caching**: Leverage DNS caching with appropriate TTLs

## Pricing

- **DNS Hosting**: Free for all DigitalOcean customers
- **No Query Limits**: Unlimited DNS queries
- **No Hidden Fees**: Completely free service

## Related Services

- [Reserved IPs](./2-RESERVED-IPS.md) - Static IPs for DNS records
- [Load Balancers](./3-LOAD-BALANCERS.md) - Point DNS to load balancers
- [PTR Records](./6-PTR-RECORDS.md) - Reverse DNS configuration
