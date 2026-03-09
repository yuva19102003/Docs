# Security Best Practices

Production-ready security guidelines for GCP.

---

## Identity & Access Management

### Principle of Least Privilege

```bash
# Use predefined roles when possible
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:developer@example.com \
  --role=roles/viewer

# Create custom role for specific needs
gcloud iam roles create customRole \
  --project=PROJECT_ID \
  --title="Custom Role" \
  --permissions=compute.instances.list,compute.instances.get
```

### Service Accounts

```
✓ Use service accounts for applications
✓ Avoid service account keys (use Workload Identity)
✓ Rotate keys regularly (if keys are necessary)
✓ One service account per application
✓ Grant minimal permissions
✓ Use short-lived tokens
```

### Multi-Factor Authentication

```
✓ Enforce MFA for all users
✓ Use security keys (FIDO2)
✓ Implement conditional access
✓ Regular access reviews
```

---

## Network Security

### VPC Security

```bash
# Create VPC with private subnets
gcloud compute networks create my-vpc \
  --subnet-mode=custom

gcloud compute networks subnets create private-subnet \
  --network=my-vpc \
  --region=us-central1 \
  --range=10.0.1.0/24 \
  --enable-private-ip-google-access

# Deny all ingress by default
gcloud compute firewall-rules create deny-all-ingress \
  --network=my-vpc \
  --action=DENY \
  --rules=all \
  --source-ranges=0.0.0.0/0 \
  --priority=65534
```

### Firewall Rules

```
✓ Deny by default
✓ Allow only necessary traffic
✓ Use service accounts as targets
✓ Implement egress controls
✓ Regular rule audits
✓ Use hierarchical firewall policies
```

### Private Google Access

```bash
# Enable Private Google Access
gcloud compute networks subnets update private-subnet \
  --region=us-central1 \
  --enable-private-ip-google-access
```

---

## Data Protection

### Encryption

```
At Rest:
  ✓ Use default encryption (Google-managed)
  ✓ Use CMEK for sensitive data
  ✓ Consider CSEK for highest security

In Transit:
  ✓ Use TLS 1.2 or higher
  ✓ Enable HTTPS everywhere
  ✓ Use Private Service Connect
```

### Secret Management

```bash
# Store secrets in Secret Manager
echo -n "db-password" | gcloud secrets create db-password \
  --data-file=-

# Grant access to service account only
gcloud secrets add-iam-policy-binding db-password \
  --member=serviceAccount:app@PROJECT.iam.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor
```

### Data Classification

```
Public: No restrictions
Internal: Company confidential
Confidential: Restricted access
Restricted: Highest security
```

---

## Monitoring & Logging

### Audit Logging

```bash
# Enable Data Access logs
gcloud logging settings update \
  --organization=ORG_ID \
  --enable-data-access-logs

# Export audit logs
gcloud logging sinks create audit-logs \
  bigquery.googleapis.com/projects/PROJECT/datasets/audit \
  --log-filter='logName:"cloudaudit.googleapis.com"'
```

### Security Monitoring

```
✓ Enable Security Command Center
✓ Set up security alerts
✓ Monitor failed login attempts
✓ Track IAM changes
✓ Review firewall logs
✓ Monitor data access
```

---

## Compliance

### Compliance Frameworks

```
Supported:
  • ISO 27001, 27017, 27018
  • SOC 1, 2, 3
  • PCI DSS
  • HIPAA
  • FedRAMP
  • GDPR
```

### Compliance Tools

```bash
# Security Command Center compliance reports
gcloud scc findings list ORGANIZATION_ID \
  --filter="category='COMPLIANCE_VIOLATION'"

# Export compliance data
gcloud scc findings export ORGANIZATION_ID \
  --destination=gs://compliance-bucket/findings.json
```

---

## Incident Response

### Response Plan

```markdown
1. Detection
   - Monitor alerts
   - Review logs
   - Identify scope

2. Containment
   - Isolate affected resources
   - Block malicious traffic
   - Preserve evidence

3. Eradication
   - Remove threat
   - Patch vulnerabilities
   - Update security rules

4. Recovery
   - Restore services
   - Verify security
   - Monitor closely

5. Lessons Learned
   - Document incident
   - Update procedures
   - Improve defenses
```

---

## Security Checklist

### Infrastructure

- [ ] VPC with private subnets
- [ ] Firewall rules (deny by default)
- [ ] Private Google Access enabled
- [ ] VPC Service Controls configured
- [ ] Cloud Armor enabled
- [ ] DDoS protection active

### Identity

- [ ] MFA enforced
- [ ] Service accounts used
- [ ] Least privilege implemented
- [ ] Regular access reviews
- [ ] Workload Identity enabled
- [ ] No service account keys

### Data

- [ ] Encryption at rest
- [ ] Encryption in transit
- [ ] CMEK for sensitive data
- [ ] Secrets in Secret Manager
- [ ] Data classification implemented
- [ ] Backup strategy defined

### Monitoring

- [ ] Audit logging enabled
- [ ] Security alerts configured
- [ ] Log exports set up
- [ ] Security Command Center enabled
- [ ] Regular security reviews
- [ ] Incident response plan

---

## Additional Resources

- [Security Best Practices](https://cloud.google.com/security/best-practices)
- [Security Command Center](https://cloud.google.com/security-command-center)
- [Compliance Resource Center](https://cloud.google.com/security/compliance)
- [Security Blueprints](https://cloud.google.com/architecture/security-foundations)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
