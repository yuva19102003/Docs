# Security Command Center

Centralized security and risk management platform.

---

## Overview

Security Command Center (SCC) provides centralized visibility into your organization's security posture across GCP resources.

---

## Key Features

- Asset discovery and inventory
- Vulnerability detection
- Threat detection
- Compliance monitoring
- Security findings
- Risk scoring
- Integration with third-party tools

---

## Tiers

**Standard (Free):**
- Asset discovery
- Basic vulnerability scanning
- Security Health Analytics
- Web Security Scanner

**Premium (Paid):**
- Event Threat Detection
- Container Threat Detection
- Virtual Machine Threat Detection
- Continuous exports
- Advanced compliance monitoring

---

## Enabling SCC

```bash
# Enable Security Command Center API
gcloud services enable securitycenter.googleapis.com

# List assets
gcloud scc assets list ORGANIZATION_ID

# List findings
gcloud scc findings list ORGANIZATION_ID \
  --filter="state=\"ACTIVE\""
```

---

## Security Sources

**Built-in Sources:**
- Security Health Analytics
- Web Security Scanner
- Event Threat Detection
- Container Threat Detection
- VM Threat Detection

**Third-party Integrations:**
- Palo Alto Networks
- Qualys
- Tenable
- Twistlock
- Aqua Security

---

## Findings

```bash
# List findings by severity
gcloud scc findings list ORGANIZATION_ID \
  --filter="severity=\"HIGH\""

# List findings by category
gcloud scc findings list ORGANIZATION_ID \
  --filter="category=\"OPEN_FIREWALL\""

# Update finding state
gcloud scc findings update FINDING_NAME \
  --state=INACTIVE \
  --source=SOURCE_ID
```

---

## Security Marks

```bash
# Add security mark
gcloud scc assets update-marks ASSET_NAME \
  --security-marks="environment=production,team=security"

# Query by security marks
gcloud scc assets list ORGANIZATION_ID \
  --filter="securityMarks.marks.environment=\"production\""
```

---

## Continuous Exports

```bash
# Export to Pub/Sub
gcloud scc notifications create my-notification \
  --organization=ORGANIZATION_ID \
  --pubsub-topic=projects/PROJECT_ID/topics/scc-notifications \
  --filter="state=\"ACTIVE\" AND severity=\"HIGH\""

# Export to BigQuery
gcloud scc bqexports create my-export \
  --organization=ORGANIZATION_ID \
  --dataset=projects/PROJECT_ID/datasets/scc_findings \
  --filter="state=\"ACTIVE\""
```

---

## Best Practices

✓ Enable Premium tier for production  
✓ Set up continuous exports  
✓ Configure notifications  
✓ Regular findings review  
✓ Integrate with SIEM  
✓ Use security marks for organization  
✓ Automate remediation  

---

**Last Updated:** March 2026
