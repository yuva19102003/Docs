# 1️⃣2️⃣ Security - Overview

Learn how to secure applications on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Security Layers](#security-layers)
3. [Security Services](#security-services)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Compliance](#compliance)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP provides multiple layers of security to protect your applications, data, and infrastructure.

### Security Stack

```
┌─────────────────────────────────────────────────────┐
│              Security Layers                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Identity & Access (IAM, Identity Platform)  │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Network Security (VPC, Firewall, Armor)     │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Data Protection (KMS, Secret Manager)       │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Threat Detection (SCC, Chronicle)           │ │
│  └──────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

## Security Layers

### 1. Identity & Access Management

**Control who can access what resources**

```
┌─────────────────────────────────────┐
│      Identity & Access              │
├─────────────────────────────────────┤
│  Components:                        │
│  • Cloud IAM                        │
│  • Service Accounts                 │
│  • Identity Platform                │
│  • Identity-Aware Proxy             │
│  • Workload Identity                │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Fine-grained permissions         │
│  • Role-based access control        │
│  • Multi-factor authentication      │
│  • Single sign-on                   │
└─────────────────────────────────────┘
```

**Key Concepts:**
- Principle of least privilege
- Service accounts for applications
- Workload identity for GKE
- IAM conditions for context-aware access

### 2. Network Security

**Protect network traffic and prevent attacks**

```
┌─────────────────────────────────────┐
│      Network Security               │
├─────────────────────────────────────┤
│  Components:                        │
│  • VPC & Subnets                    │
│  • Firewall Rules                   │
│  • Cloud Armor (DDoS, WAF)          │
│  • VPC Service Controls             │
│  • Private Google Access            │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Network isolation                │
│  • DDoS protection                  │
│  • Web application firewall         │
│  • Private connectivity             │
└─────────────────────────────────────┘
```

**Key Concepts:**
- Defense in depth
- Zero trust networking
- Private service access
- Perimeter security

### 3. Data Protection

**Encrypt and protect sensitive data**

```
┌─────────────────────────────────────┐
│      Data Protection                │
├─────────────────────────────────────┤
│  Components:                        │
│  • Cloud KMS (Key Management)       │
│  • Secret Manager                   │
│  • Data Loss Prevention (DLP)       │
│  • Encryption at rest               │
│  • Encryption in transit            │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Key management                   │
│  • Secret storage                   │
│  • Sensitive data detection         │
│  • Automatic encryption             │
└─────────────────────────────────────┘
```

**Key Concepts:**
- Encryption by default
- Customer-managed keys (CMEK)
- Secret rotation
- Data classification

### 4. Threat Detection & Response

**Detect and respond to security threats**

```
┌─────────────────────────────────────┐
│   Threat Detection & Response       │
├─────────────────────────────────────┤
│  Components:                        │
│  • Security Command Center          │
│  • Chronicle (SIEM)                 │
│  • Event Threat Detection           │
│  • Web Security Scanner             │
│  • Binary Authorization             │
├─────────────────────────────────────┤
│  Capabilities:                      │
│  • Vulnerability scanning           │
│  • Threat intelligence              │
│  • Security analytics               │
│  • Incident response                │
└─────────────────────────────────────┘
```

**Key Concepts:**
- Continuous monitoring
- Automated threat detection
- Security posture management
- Incident response

---

## Security Services

### Service Matrix

| Service | Purpose | Use Case | Cost |
|---------|---------|----------|------|
| **Cloud IAM** | Access control | All resources | Free |
| **Secret Manager** | Secret storage | API keys, passwords | $0.06/secret/month |
| **Cloud KMS** | Key management | Encryption keys | $0.06/key/month |
| **Cloud Armor** | DDoS/WAF protection | Web applications | $5/policy/month |
| **Security Command Center** | Security posture | Enterprise security | Varies |
| **VPC Service Controls** | Perimeter security | Data exfiltration prevention | Free |
| **Identity Platform** | User authentication | Customer-facing apps | Free tier available |
| **Binary Authorization** | Container security | GKE deployments | Free |

---

## Decision Framework

### Security Service Selection

```
What do you need to secure?
    |
    ├─> User access?
    |   ├─> Internal users → Cloud IAM
    |   └─> External users → Identity Platform
    |
    ├─> Secrets/Keys?
    |   ├─> Application secrets → Secret Manager
    |   └─> Encryption keys → Cloud KMS
    |
    ├─> Network traffic?
    |   ├─> DDoS protection → Cloud Armor
    |   └─> Data exfiltration → VPC Service Controls
    |
    └─> Overall security posture?
        └─> Security Command Center
```

---

## Architecture Patterns

### Pattern 1: Defense in Depth

```
Internet
    |
    v
┌─────────────────────┐
│  Cloud Armor        │  <-- DDoS/WAF Protection
│  (DDoS Protection)  │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Cloud Load         │
│  Balancer (HTTPS)   │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Identity-Aware     │  <-- Authentication
│  Proxy (IAP)        │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  VPC Firewall       │  <-- Network Security
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Application        │  <-- Application Security
│  (Cloud Run/GKE)    │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Database           │  <-- Data Encryption
│  (Encrypted)        │
└─────────────────────┘
```

### Pattern 2: Zero Trust Architecture

```
┌─────────────────────────────────────┐
│      VPC Service Controls           │
│      (Security Perimeter)           │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Private Google Access       │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Workload Identity           │  │
│  │  (No service account keys)   │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  IAM Conditions              │  │
│  │  (Context-aware access)      │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Pattern 3: Secrets Management

```
Application
    |
    v
┌─────────────────────┐
│  Secret Manager     │
│  • API Keys         │
│  • Passwords        │
│  • Certificates     │
└──────────┬──────────┘
           |
    (Encrypted with)
           v
┌─────────────────────┐
│  Cloud KMS          │
│  • Encryption Keys  │
│  • Key Rotation     │
└─────────────────────┘
```

### Pattern 4: Container Security

```
Developer
    |
    v
┌─────────────────────┐
│  Source Code        │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Cloud Build        │
│  • Vulnerability    │
│    Scanning         │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Artifact Registry  │
│  • Signed Images    │
└──────────┬──────────┘
           v
┌─────────────────────┐
│  Binary             │
│  Authorization      │  <-- Policy Enforcement
└──────────┬──────────┘
           v
┌─────────────────────┐
│  GKE Cluster        │
│  • Workload Identity│
│  • Network Policies │
└─────────────────────┘
```

---

## Compliance

### Certifications & Standards

GCP complies with major security and privacy standards:

**Global Standards:**
- ISO/IEC 27001, 27017, 27018
- SOC 1, 2, 3
- PCI DSS
- HIPAA
- FedRAMP

**Regional Standards:**
- GDPR (Europe)
- CCPA (California)
- PIPEDA (Canada)
- LGPD (Brazil)

### Compliance Tools

```bash
# Enable Security Command Center
gcloud services enable securitycenter.googleapis.com

# Run compliance scan
gcloud scc findings list ORGANIZATION_ID \
  --filter="category='COMPLIANCE_VIOLATION'"

# Export audit logs
gcloud logging sinks create audit-logs-sink \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/audit_logs \
  --log-filter='logName:"cloudaudit.googleapis.com"'
```

---

## Quick Reference

### Secret Manager

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret \
  --data-file=-

# Access secret
gcloud secrets versions access latest --secret=my-secret

# Grant access
gcloud secrets add-iam-policy-binding my-secret \
  --member=serviceAccount:SA_EMAIL \
  --role=roles/secretmanager.secretAccessor
```

### Cloud KMS

```bash
# Create key ring
gcloud kms keyrings create my-keyring --location=global

# Create key
gcloud kms keys create my-key \
  --keyring=my-keyring \
  --location=global \
  --purpose=encryption

# Encrypt data
gcloud kms encrypt \
  --key=my-key \
  --keyring=my-keyring \
  --location=global \
  --plaintext-file=data.txt \
  --ciphertext-file=data.enc
```

### Cloud Armor

```bash
# Create security policy
gcloud compute security-policies create my-policy \
  --description="My security policy"

# Add rule
gcloud compute security-policies rules create 1000 \
  --security-policy=my-policy \
  --expression="origin.region_code == 'CN'" \
  --action=deny-403

# Attach to backend service
gcloud compute backend-services update my-backend \
  --security-policy=my-policy
```

### VPC Service Controls

```bash
# Create access policy
gcloud access-context-manager policies create \
  --organization=ORG_ID \
  --title="My Policy"

# Create service perimeter
gcloud access-context-manager perimeters create my-perimeter \
  --policy=POLICY_ID \
  --resources=projects/PROJECT_NUMBER \
  --restricted-services=storage.googleapis.com
```

---

## Best Practices

### Identity & Access

✅ Enable MFA for all users  
✅ Use service accounts for applications  
✅ Implement least privilege principle  
✅ Regular IAM audits  
✅ Use workload identity for GKE  
✅ Avoid service account keys  
✅ Use IAM conditions  
✅ Implement separation of duties  

### Network Security

✅ Use VPC for network isolation  
✅ Implement firewall rules (deny by default)  
✅ Enable VPC Flow Logs  
✅ Use Private Google Access  
✅ Implement Cloud Armor for public services  
✅ Use VPC Service Controls  
✅ Enable DDoS protection  
✅ Regular security assessments  

### Data Protection

✅ Enable encryption at rest (default)  
✅ Use CMEK for sensitive data  
✅ Store secrets in Secret Manager  
✅ Implement data classification  
✅ Enable audit logging  
✅ Regular key rotation  
✅ Use DLP for sensitive data detection  
✅ Implement data retention policies  

### Monitoring & Response

✅ Enable Security Command Center  
✅ Set up security alerts  
✅ Regular vulnerability scanning  
✅ Implement incident response plan  
✅ Enable audit logging  
✅ Monitor security events  
✅ Regular security reviews  
✅ Security training for team  

---

## Next Steps

1. **[Secret Manager](1-Secret-Manager.md)** - Secrets management
2. **[Cloud KMS](2-Cloud-KMS.md)** - Key management
3. **[Cloud Armor](3-Cloud-Armor.md)** - DDoS and WAF protection
4. **[Security Command Center](4-Security-Command-Center.md)** - Security posture
5. **[VPC Service Controls](5-VPC-Service-Controls.md)** - Perimeter security
6. **[Best Practices](6-Best-Practices.md)** - Security guidelines

---

## Additional Resources

- [Security Best Practices](https://cloud.google.com/security/best-practices)
- [Security Command Center](https://cloud.google.com/security-command-center)
- [Compliance Resource Center](https://cloud.google.com/security/compliance)
- [Security Blueprints](https://cloud.google.com/architecture/security-foundations)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
