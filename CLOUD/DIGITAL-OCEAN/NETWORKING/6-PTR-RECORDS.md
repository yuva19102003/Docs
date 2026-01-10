# DigitalOcean PTR Records (Reverse DNS)

## Overview

PTR (Pointer) records provide reverse DNS lookup, mapping IP addresses back to domain names. They are essential for email servers, improve security and trust, and help with troubleshooting. DigitalOcean allows you to configure PTR records for Droplets and Reserved IPs.

## Key Features

- **Reverse DNS Lookup**: Map IP to domain name
- **Email Deliverability**: Critical for mail servers
- **Free**: No additional cost
- **Easy Configuration**: Set via control panel or API
- **Automatic Validation**: Requires matching forward DNS
- **Per-IP Configuration**: Set for each Droplet or Reserved IP
- **Instant Updates**: Changes apply immediately

## What are PTR Records?

### Forward DNS (A Record)
```
Domain → IP Address
example.com → 203.0.113.10
```

### Reverse DNS (PTR Record)
```
IP Address → Domain
203.0.113.10 → mail.example.com
```

## How PTR Records Work

```
┌─────────────────────────────────────────────────────────────┐
│                  PTR Record Lookup Flow                      │
└─────────────────────────────────────────────────────────────┘

1. Email Server Receives Connection
   └─> From IP: 203.0.113.10

2. Perform Reverse DNS Lookup
   └─> Query: 10.113.0.203.in-addr.arpa
       (IP reversed + .in-addr.arpa)

3. DNS Returns PTR Record
   └─> Result: mail.example.com

4. Verify Forward DNS (A Record)
   └─> Query: mail.example.com
   └─> Result: 203.0.113.10

5. Check Match
   ├─> PTR: 203.0.113.10 → mail.example.com
   ├─> A:   mail.example.com → 203.0.113.10
   └─> Match: ✓ Valid

6. Accept or Reject
   └─> Valid PTR → Accept email
   └─> Invalid/Missing PTR → Reject or mark as spam
```

## Why PTR Records Matter

### 1. Email Deliverability

```
Without PTR Record:
┌──────────────┐         ┌──────────────┐
│ Your Mail    │ Email   │ Recipient    │
│ Server       ├────────>│ Mail Server  │
│ 203.0.113.10 │         │              │
└──────────────┘         └──────┬───────┘
                                │
                         Reverse DNS Check
                                │
                         No PTR Record ✗
                                │
                         ┌──────▼───────┐
                         │ Rejected or  │
                         │ Marked Spam  │
                         └──────────────┘

With PTR Record:
┌──────────────┐         ┌──────────────┐
│ Your Mail    │ Email   │ Recipient    │
│ Server       ├────────>│ Mail Server  │
│ 203.0.113.10 │         │              │
└──────────────┘         └──────┬───────┘
                                │
                         Reverse DNS Check
                                │
                         PTR: mail.example.com ✓
                         A: 203.0.113.10 ✓
                                │
                         ┌──────▼───────┐
                         │   Accepted   │
                         └──────────────┘
```

### 2. Security and Trust

- Verifies server identity
- Prevents IP spoofing
- Builds sender reputation
- Required by many mail servers
- Improves spam score

### 3. Troubleshooting

- Identify server ownership
- Trace network issues
- Verify DNS configuration
- Debug connectivity problems

## Email Server Requirements

### SPF, DKIM, DMARC, and PTR

```
Complete Email Authentication:

1. SPF (Sender Policy Framework)
   └─> TXT record: "v=spf1 ip4:203.0.113.10 ~all"
   └─> Authorizes IP to send email

2. DKIM (DomainKeys Identified Mail)
   └─> TXT record with public key
   └─> Signs emails cryptographically

3. DMARC (Domain-based Message Authentication)
   └─> TXT record: "v=DMARC1; p=quarantine; rua=mailto:..."
   └─> Specifies policy for failed checks

4. PTR (Reverse DNS)
   └─> PTR record: 203.0.113.10 → mail.example.com
   └─> Verifies server identity

All four improve deliverability and prevent spoofing!
```

## Configuring PTR Records

### Prerequisites

1. **Own the Domain**: You must control the domain
2. **Forward DNS**: Create A record first
3. **Match Required**: PTR must match forward DNS

### Step 1: Create Forward DNS (A Record)

```bash
# In DigitalOcean DNS or your DNS provider
mail.example.com → 203.0.113.10
```

### Step 2: Set PTR Record

#### Via Control Panel

1. Navigate to **Droplets** or **Networking** → **Reserved IPs**
2. Click on the Droplet or Reserved IP
3. Find **PTR Record** section
4. Enter domain name: `mail.example.com`
5. Click **Update**

#### Via API (Droplet)

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"data": "mail.example.com"}' \
  "https://api.digitalocean.com/v2/droplets/droplet-id/actions" \
  --data-urlencode "type=enable_ipv6"
```

#### Via API (Reserved IP)

```bash
# PTR records for Reserved IPs are set via the Droplet they're assigned to
# First assign Reserved IP to Droplet, then set PTR on Droplet
```

#### Via doctl CLI

```bash
# Set PTR record for Droplet
doctl compute droplet action enable-ipv6 droplet-id

# Note: Direct PTR configuration via doctl is limited
# Use API or control panel for full functionality
```

### Step 3: Verify Configuration

```bash
# Check PTR record
dig -x 203.0.113.10

# Expected output:
# 10.113.0.203.in-addr.arpa. 3600 IN PTR mail.example.com.

# Verify forward DNS matches
dig mail.example.com

# Expected output:
# mail.example.com. 3600 IN A 203.0.113.10
```

## PTR Record Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Complete DNS Configuration                      │
└─────────────────────────────────────────────────────────────┘

Forward DNS (A Record):
┌──────────────────────────────────────┐
│ Domain: mail.example.com             │
│ Type: A                              │
│ Value: 203.0.113.10                  │
│ TTL: 3600                            │
└──────────────────────────────────────┘
                │
                │ Must Match
                │
                ▼
Reverse DNS (PTR Record):
┌──────────────────────────────────────┐
│ IP: 203.0.113.10                     │
│ Type: PTR                            │
│ Value: mail.example.com              │
│ Zone: 113.0.203.in-addr.arpa         │
└──────────────────────────────────────┘

Additional Email Records:
┌──────────────────────────────────────┐
│ SPF Record:                          │
│ example.com TXT                      │
│ "v=spf1 ip4:203.0.113.10 ~all"      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ MX Record:                           │
│ example.com MX 10 mail.example.com   │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ DKIM Record:                         │
│ default._domainkey.example.com TXT   │
│ "v=DKIM1; k=rsa; p=..."              │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ DMARC Record:                        │
│ _dmarc.example.com TXT               │
│ "v=DMARC1; p=quarantine; ..."        │
└──────────────────────────────────────┘
```

## Email Server Setup Example

### Complete Configuration

```bash
# 1. Create Droplet for mail server
doctl compute droplet create mail-server \
  --region nyc3 \
  --size s-2vcpu-2gb \
  --image ubuntu-22-04-x64 \
  --tag-names mail

# 2. Note the IP address (e.g., 203.0.113.10)

# 3. Create DNS records in DigitalOcean DNS

# A Record
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "type": "A",
    "name": "mail",
    "data": "203.0.113.10",
    "ttl": 3600
  }' \
  "https://api.digitalocean.com/v2/domains/example.com/records"

# MX Record
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "type": "MX",
    "name": "@",
    "data": "mail.example.com",
    "priority": 10,
    "ttl": 3600
  }' \
  "https://api.digitalocean.com/v2/domains/example.com/records"

# SPF Record
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "type": "TXT",
    "name": "@",
    "data": "v=spf1 ip4:203.0.113.10 ~all",
    "ttl": 3600
  }' \
  "https://api.digitalocean.com/v2/domains/example.com/records"

# 4. Set PTR record via control panel
# Navigate to Droplet → Set PTR to "mail.example.com"

# 5. Install and configure mail server (Postfix, etc.)
# 6. Configure DKIM and DMARC
# 7. Test email deliverability
```

## Testing PTR Records

### Using dig

```bash
# Test PTR record
dig -x 203.0.113.10 +short
# Expected: mail.example.com.

# Test forward DNS
dig mail.example.com +short
# Expected: 203.0.113.10

# Detailed PTR lookup
dig -x 203.0.113.10

# Output:
# ;; ANSWER SECTION:
# 10.113.0.203.in-addr.arpa. 3600 IN PTR mail.example.com.
```

### Using nslookup

```bash
# PTR lookup
nslookup 203.0.113.10

# Output:
# Server:  8.8.8.8
# Address: 8.8.8.8#53
#
# 10.113.0.203.in-addr.arpa name = mail.example.com.

# Forward lookup
nslookup mail.example.com

# Output:
# Server:  8.8.8.8
# Address: 8.8.8.8#53
#
# Name:    mail.example.com
# Address: 203.0.113.10
```

### Using host

```bash
# PTR lookup
host 203.0.113.10
# Output: 10.113.0.203.in-addr.arpa domain name pointer mail.example.com.

# Forward lookup
host mail.example.com
# Output: mail.example.com has address 203.0.113.10
```

### Online Tools

- **MXToolbox**: https://mxtoolbox.com/ReverseLookup.aspx
- **DNSChecker**: https://dnschecker.org/ptr-lookup.php
- **IntoDNS**: https://intodns.com/
- **Mail-Tester**: https://www.mail-tester.com/

## Common Use Cases

### 1. Email Server

```
Configuration:
├─> Droplet: mail-server
├─> IP: 203.0.113.10
├─> A Record: mail.example.com → 203.0.113.10
├─> PTR Record: 203.0.113.10 → mail.example.com
├─> MX Record: example.com → mail.example.com
└─> SPF Record: "v=spf1 ip4:203.0.113.10 ~all"

Result: Improved email deliverability
```

### 2. Multiple Mail Servers

```
Primary Mail Server:
├─> IP: 203.0.113.10
├─> PTR: mail1.example.com
└─> MX Priority: 10

Backup Mail Server:
├─> IP: 203.0.113.20
├─> PTR: mail2.example.com
└─> MX Priority: 20

Both need PTR records for best deliverability
```

### 3. Reserved IP with PTR

```
Reserved IP: 203.0.113.10
├─> Assigned to: mail-server-primary
├─> PTR: mail.example.com
└─> Failover: Can reassign to mail-server-backup
    └─> PTR remains: mail.example.com
    └─> No DNS changes needed
```

## Troubleshooting

### PTR Record Not Resolving

```bash
# 1. Check if PTR is set
dig -x 203.0.113.10

# 2. Verify forward DNS exists
dig mail.example.com

# 3. Check for typos in domain name

# 4. Wait for propagation (usually instant, but can take up to 24 hours)

# 5. Clear DNS cache
sudo systemd-resolve --flush-caches  # Linux
dscacheutil -flushcache              # macOS
ipconfig /flushdns                   # Windows
```

### Forward and Reverse DNS Mismatch

```bash
# Problem:
PTR: 203.0.113.10 → mail.example.com
A:   mail.example.com → 203.0.113.99  # Different IP!

# Solution:
# Update A record to match PTR
# Or update PTR to match A record
# They must match exactly
```

### Email Still Rejected

```bash
# Check all email authentication:

# 1. PTR Record
dig -x 203.0.113.10

# 2. SPF Record
dig example.com TXT | grep spf

# 3. DKIM Record
dig default._domainkey.example.com TXT

# 4. DMARC Record
dig _dmarc.example.com TXT

# 5. Check blacklists
# Use MXToolbox or similar to check if IP is blacklisted

# 6. Test email
# Send test email to mail-tester.com for score
```

### Cannot Set PTR Record

**Possible causes:**
1. Forward DNS (A record) doesn't exist
2. Forward DNS doesn't point to the IP
3. Domain not verified in DigitalOcean
4. IP address is dynamic (not Reserved IP)
5. Insufficient permissions

**Solutions:**
1. Create A record first
2. Ensure A record points to correct IP
3. Add domain to DigitalOcean DNS
4. Use Reserved IP for static addressing
5. Check API token permissions

## Best Practices

### 1. Match Forward and Reverse DNS

```
✓ Correct:
A Record:   mail.example.com → 203.0.113.10
PTR Record: 203.0.113.10 → mail.example.com

✗ Incorrect:
A Record:   mail.example.com → 203.0.113.10
PTR Record: 203.0.113.10 → server.example.com
```

### 2. Use Descriptive Hostnames

```
✓ Good:
mail.example.com
smtp.example.com
mx1.example.com

✗ Bad:
droplet-12345.example.com
server1.example.com
```

### 3. Set PTR Before Sending Email

```
Workflow:
1. Create Droplet
2. Note IP address
3. Create A record
4. Set PTR record
5. Wait for DNS propagation
6. Install mail server
7. Configure authentication (SPF, DKIM, DMARC)
8. Test deliverability
9. Start sending email
```

### 4. Use Reserved IPs for Mail Servers

```
Benefits:
├─> Static IP address
├─> Persistent PTR record
├─> Easy failover
├─> Maintain sender reputation
└─> No DNS changes during failover
```

### 5. Monitor Email Deliverability

```bash
# Regular checks:
├─> PTR record validity
├─> Blacklist status
├─> SPF/DKIM/DMARC configuration
├─> Bounce rates
└─> Spam complaints

# Tools:
├─> MXToolbox
├─> Mail-Tester
├─> Google Postmaster Tools
└─> Microsoft SNDS
```

## PTR Records for IPv6

### IPv6 PTR Configuration

```
IPv6 Address: 2001:db8::1

PTR Record Zone:
1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa

PTR Record:
1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa
→ mail.example.com
```

### Testing IPv6 PTR

```bash
# PTR lookup
dig -x 2001:db8::1

# Forward lookup
dig mail.example.com AAAA
```

## Security Considerations

### 1. Prevent Information Disclosure

```
✗ Avoid:
PTR: 203.0.113.10 → internal-db-master-prod.example.com

✓ Better:
PTR: 203.0.113.10 → mail.example.com
```

### 2. Consistent Naming

```
Use consistent naming scheme:
├─> mail1.example.com
├─> mail2.example.com
└─> mail3.example.com

Not:
├─> mail.example.com
├─> smtp-server.example.com
└─> mx-prod-01.example.com
```

### 3. Regular Audits

```bash
# Audit all PTR records
for ip in $(doctl compute droplet list --format PublicIPv4 --no-header); do
  echo "IP: $ip"
  dig -x $ip +short
  echo "---"
done
```

## Limitations

- PTR records require matching forward DNS
- One PTR record per IP address
- Cannot set PTR for IPs you don't control
- Some ISPs may block port 25 (SMTP)
- Shared IPs cannot have custom PTR records

## Pricing

- **PTR Records**: Free
- **No Limits**: Set for all Droplets and Reserved IPs
- **Instant Updates**: No propagation delay

## Related Services

- [Domains & DNS](./1-DOMAINS-DNS.md) - Create forward DNS records
- [Reserved IPs](./2-RESERVED-IPS.md) - Static IPs for mail servers
- [Cloud Firewalls](./5-CLOUD-FIREWALLS.md) - Secure mail servers
