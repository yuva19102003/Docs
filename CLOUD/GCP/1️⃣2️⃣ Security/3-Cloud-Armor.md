# Cloud Armor

DDoS protection and Web Application Firewall (WAF).

---

## Overview

Cloud Armor provides DDoS protection and WAF capabilities for applications behind Google Cloud Load Balancers.

---

## Key Features

- DDoS protection
- WAF rules
- Rate limiting
- Geo-based access control
- Bot management
- Adaptive protection
- Custom rules

---

## Security Policies

```bash
# Create security policy
gcloud compute security-policies create my-policy \
  --description="My security policy"

# Add rule to block country
gcloud compute security-policies rules create 1000 \
  --security-policy=my-policy \
  --expression="origin.region_code == 'CN'" \
  --action=deny-403

# Add rate limiting rule
gcloud compute security-policies rules create 2000 \
  --security-policy=my-policy \
  --expression="true" \
  --action=rate-based-ban \
  --rate-limit-threshold-count=100 \
  --rate-limit-threshold-interval-sec=60 \
  --ban-duration-sec=600

# Attach to backend service
gcloud compute backend-services update my-backend \
  --security-policy=my-policy \
  --global
```

---

## Preconfigured WAF Rules

```bash
# Enable OWASP Top 10 protection
gcloud compute security-policies rules create 3000 \
  --security-policy=my-policy \
  --expression="evaluatePreconfiguredExpr('xss-stable')" \
  --action=deny-403

# SQL injection protection
gcloud compute security-policies rules create 3001 \
  --security-policy=my-policy \
  --expression="evaluatePreconfiguredExpr('sqli-stable')" \
  --action=deny-403
```

---

## Custom Rules

```bash
# Block specific IP
gcloud compute security-policies rules create 4000 \
  --security-policy=my-policy \
  --expression="inIpRange(origin.ip, '192.0.2.0/24')" \
  --action=deny-403

# Allow only specific user agents
gcloud compute security-policies rules create 4001 \
  --security-policy=my-policy \
  --expression="!has(request.headers['user-agent']) || request.headers['user-agent'].contains('bot')" \
  --action=deny-403
```

---

## Best Practices

✓ Enable adaptive protection  
✓ Use preconfigured WAF rules  
✓ Implement rate limiting  
✓ Monitor security events  
✓ Regular rule review  
✓ Test rules before production  

---

**Last Updated:** March 2026
