# 🔐 Shared Responsibility Model

Cloud security is a **shared responsibility** between Google Cloud and the customer. Understanding this division is critical for maintaining a secure cloud environment.

---

## Overview

```
┌────────────────────────────────────────────────────────────┐
│  Shared Responsibility Model                               │
└────────────────────────────────────────────────────────────┘

        Customer Responsibility ↑
        ═══════════════════════════════════════════
        │  Content & Data
        │  Access & Identity Management
        │  Application Security
        │  Network Configuration
        │  Guest OS & Middleware
        ───────────────────────────────────────────
        │  Encryption at Rest (optional)
        │  Encryption in Transit (optional)
        ═══════════════════════════════════════════
        │  Platform Services (managed)
        │  Compute Infrastructure
        │  Storage Infrastructure
        │  Network Infrastructure
        │  Physical Security
        │  Hardware & Global Infrastructure
        ═══════════════════════════════════════════
        Google Responsibility ↓
```

---

## Google's Responsibilities (Security OF the Cloud)

Google manages the **infrastructure layer** and ensures the platform is secure, reliable, and compliant.

### 1. Physical Security

```
┌────────────────────────────────────────────────────────┐
│  Data Center Security                                  │
├────────────────────────────────────────────────────────┤
│  • 24/7 security guards and monitoring                 │
│  • Biometric access controls                           │
│  • Metal detectors and security cameras                │
│  • Secure perimeter fencing                            │
│  • Visitor access logs and escorts                     │
│  • Secure destruction of decommissioned hardware       │
└────────────────────────────────────────────────────────┘
```

### 2. Hardware & Infrastructure

```
┌────────────────────────────────────────────────────────┐
│  Infrastructure Management                             │
├────────────────────────────────────────────────────────┤
│  • Custom-designed servers                             │
│  • Redundant power and cooling                         │
│  • Hardware lifecycle management                       │
│  • Secure boot and firmware verification               │
│  • Hardware security modules (HSM)                     │
│  • Automated hardware replacement                      │
└────────────────────────────────────────────────────────┘
```

### 3. Network Security

```
┌────────────────────────────────────────────────────────┐
│  Network Infrastructure                                │
├────────────────────────────────────────────────────────┤
│  • Private global fiber network                        │
│  • DDoS protection at edge                             │
│  • Network segmentation and isolation                  │
│  • Encrypted inter-service communication               │
│  • Automatic encryption in transit                     │
│  • Network monitoring and intrusion detection          │
└────────────────────────────────────────────────────────┘
```

### 4. Platform Security

```
┌────────────────────────────────────────────────────────┐
│  Platform & Services                                   │
├────────────────────────────────────────────────────────┤
│  • Hypervisor security and isolation                   │
│  • Automatic security patching (managed services)      │
│  • Service availability and redundancy                 │
│  • Data replication and backup (infrastructure)        │
│  • Compliance certifications (SOC 2, ISO 27001, etc.)  │
│  • Security audits and penetration testing             │
└────────────────────────────────────────────────────────┘
```

### 5. Operational Security

```
┌────────────────────────────────────────────────────────┐
│  Operations & Monitoring                               │
├────────────────────────────────────────────────────────┤
│  • Security incident response team                     │
│  • Vulnerability management program                    │
│  • Security monitoring and logging                     │
│  • Insider threat protection                           │
│  • Employee background checks                          │
│  • Security training for staff                         │
└────────────────────────────────────────────────────────┘
```

---

## Customer Responsibilities (Security IN the Cloud)

Customers are responsible for **securing their data, applications, and access controls** within GCP.

### 1. Identity & Access Management (IAM)

```
┌────────────────────────────────────────────────────────┐
│  Access Control                                        │
├────────────────────────────────────────────────────────┤
│  ✓ Configure IAM roles and permissions                │
│  ✓ Implement least privilege access                   │
│  ✓ Enable multi-factor authentication (MFA)           │
│  ✓ Manage service account keys                        │
│  ✓ Review and audit access logs                       │
│  ✓ Implement identity federation (SSO)                │
│  ✓ Rotate credentials regularly                       │
└────────────────────────────────────────────────────────┘

Example:
# Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:developer@company.com' \
  --role='roles/viewer'  # Read-only access
```

### 2. Data Security

```
┌────────────────────────────────────────────────────────┐
│  Data Protection                                       │
├────────────────────────────────────────────────────────┤
│  ✓ Classify and label sensitive data                  │
│  ✓ Enable encryption at rest (CMEK/CSEK)              │
│  ✓ Configure data retention policies                  │
│  ✓ Implement data loss prevention (DLP)               │
│  ✓ Backup critical data regularly                     │
│  ✓ Control data access and sharing                    │
│  ✓ Comply with data residency requirements            │
└────────────────────────────────────────────────────────┘

Example:
# Enable customer-managed encryption
gcloud compute disks create encrypted-disk \
  --kms-key=projects/PROJECT_ID/locations/LOCATION/keyRings/KEYRING/cryptoKeys/KEY
```

### 3. Network Configuration

```
┌────────────────────────────────────────────────────────┐
│  Network Security                                      │
├────────────────────────────────────────────────────────┤
│  ✓ Configure VPC firewall rules                       │
│  ✓ Implement network segmentation                     │
│  ✓ Use Private Google Access                          │
│  ✓ Enable VPC Flow Logs                               │
│  ✓ Configure Cloud NAT and Cloud VPN                  │
│  ✓ Implement Cloud Armor (WAF)                        │
│  ✓ Use Private Service Connect                        │
└────────────────────────────────────────────────────────┘

Example:
# Create restrictive firewall rule
gcloud compute firewall-rules create allow-ssh \
  --network=vpc-network \
  --allow=tcp:22 \
  --source-ranges=203.0.113.0/24  # Specific IP range only
```

### 4. Application Security

```
┌────────────────────────────────────────────────────────┐
│  Application Layer                                     │
├────────────────────────────────────────────────────────┤
│  ✓ Secure application code (OWASP Top 10)             │
│  ✓ Implement input validation and sanitization        │
│  ✓ Use secure authentication mechanisms                │
│  ✓ Protect against injection attacks                  │
│  ✓ Implement rate limiting and throttling             │
│  ✓ Regular security testing and code reviews          │
│  ✓ Dependency vulnerability scanning                  │
└────────────────────────────────────────────────────────┘
```

### 5. Operating System & Middleware

```
┌────────────────────────────────────────────────────────┐
│  OS & Runtime Security (IaaS/Compute Engine)           │
├────────────────────────────────────────────────────────┤
│  ✓ Apply OS security patches regularly                │
│  ✓ Harden OS configuration                            │
│  ✓ Configure host-based firewalls                     │
│  ✓ Install and configure antivirus/antimalware        │
│  ✓ Implement intrusion detection systems              │
│  ✓ Disable unnecessary services and ports             │
│  ✓ Configure secure logging and monitoring            │
└────────────────────────────────────────────────────────┘

Note: For managed services (Cloud Run, App Engine),
      Google handles OS patching automatically.
```

### 6. Compliance & Governance

```
┌────────────────────────────────────────────────────────┐
│  Compliance Management                                 │
├────────────────────────────────────────────────────────┤
│  ✓ Implement organization policies                    │
│  ✓ Enable audit logging (Cloud Audit Logs)            │
│  ✓ Configure security monitoring and alerts           │
│  ✓ Conduct regular security assessments               │
│  ✓ Maintain compliance documentation                  │
│  ✓ Implement incident response procedures             │
│  ✓ Train staff on security best practices             │
└────────────────────────────────────────────────────────┘
```

---

## Responsibility by Service Model

The level of customer responsibility varies based on the service model.

### IaaS (Infrastructure as a Service)

```
┌────────────────────────────────────────────────────────┐
│  Compute Engine (IaaS)                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Customer Manages:                                     │
│    ✓ Guest OS (patches, updates, hardening)           │
│    ✓ Middleware (web servers, databases)              │
│    ✓ Runtime (Java, Python, Node.js)                  │
│    ✓ Application code                                 │
│    ✓ Data                                             │
│    ✓ Network configuration (firewall rules)           │
│    ✓ IAM and access control                           │
│                                                         │
│  Google Manages:                                       │
│    ✓ Physical infrastructure                          │
│    ✓ Hypervisor                                       │
│    ✓ Network infrastructure                           │
│    ✓ Storage infrastructure                           │
└────────────────────────────────────────────────────────┘

Example: Compute Engine VM
  → You patch the OS
  → You configure the firewall
  → You manage application security
```

### PaaS (Platform as a Service)

```
┌────────────────────────────────────────────────────────┐
│  App Engine, Cloud Run (PaaS)                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Customer Manages:                                     │
│    ✓ Application code                                 │
│    ✓ Data                                             │
│    ✓ IAM and access control                           │
│    ✓ Application-level security                       │
│                                                         │
│  Google Manages:                                       │
│    ✓ Physical infrastructure                          │
│    ✓ Hypervisor                                       │
│    ✓ Network infrastructure                           │
│    ✓ Storage infrastructure                           │
│    ✓ Guest OS (automatic patching)                    │
│    ✓ Middleware and runtime                           │
│    ✓ Platform security                                │
└────────────────────────────────────────────────────────┘

Example: Cloud Run
  → Google patches the OS
  → You secure your application code
  → You configure IAM permissions
```

### SaaS (Software as a Service)

```
┌────────────────────────────────────────────────────────┐
│  Google Workspace, BigQuery (SaaS)                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Customer Manages:                                     │
│    ✓ Data                                             │
│    ✓ IAM and access control                           │
│    ✓ User management                                  │
│    ✓ Data classification                              │
│                                                         │
│  Google Manages:                                       │
│    ✓ Physical infrastructure                          │
│    ✓ Network infrastructure                           │
│    ✓ Storage infrastructure                           │
│    ✓ Operating system                                 │
│    ✓ Middleware and runtime                           │
│    ✓ Application software                             │
│    ✓ Application security                             │
└────────────────────────────────────────────────────────┘

Example: BigQuery
  → Google manages the database
  → You control who can query data
  → You classify sensitive data
```

---

## Shared Responsibilities

Some security aspects are **shared** between Google and the customer.

### Encryption

```
┌────────────────────────────────────────────────────────┐
│  Encryption Responsibilities                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Google Provides:                                      │
│    • Encryption at rest (default, automatic)          │
│    • Encryption in transit (TLS/SSL)                  │
│    • Key management infrastructure                     │
│                                                         │
│  Customer Chooses:                                     │
│    • Google-managed keys (default)                    │
│    • Customer-managed keys (CMEK via Cloud KMS)       │
│    • Customer-supplied keys (CSEK)                    │
│    • Application-level encryption                     │
└────────────────────────────────────────────────────────┘

Encryption Options:
  1. Default: Google-managed encryption (automatic)
  2. CMEK: You control key rotation and access
  3. CSEK: You provide and manage keys
  4. Client-side: Encrypt before uploading to GCP
```

### Monitoring & Logging

```
┌────────────────────────────────────────────────────────┐
│  Monitoring Responsibilities                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Google Provides:                                      │
│    • Infrastructure monitoring                         │
│    • Platform health metrics                          │
│    • Audit logging infrastructure                     │
│    • Security monitoring tools                        │
│                                                         │
│  Customer Configures:                                  │
│    • Enable audit logs (Admin, Data, System)          │
│    • Set up alerting policies                         │
│    • Configure log retention                          │
│    • Analyze logs for security events                 │
│    • Implement SIEM integration                       │
└────────────────────────────────────────────────────────┘
```

---

## Security Best Practices

### 1. Implement Defense in Depth

```
┌────────────────────────────────────────────────────────┐
│  Multi-Layer Security                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Layer 1: Network Security                            │
│    → VPC firewall rules, Cloud Armor                  │
│                                                         │
│  Layer 2: Identity & Access                           │
│    → IAM, MFA, service accounts                       │
│                                                         │
│  Layer 3: Data Protection                             │
│    → Encryption, DLP, access controls                 │
│                                                         │
│  Layer 4: Application Security                        │
│    → Secure coding, input validation                  │
│                                                         │
│  Layer 5: Monitoring & Response                       │
│    → Logging, alerting, incident response             │
└────────────────────────────────────────────────────────┘
```

### 2. Follow Least Privilege Principle

```bash
# Bad: Overly permissive
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:developer@company.com' \
  --role='roles/owner'  # ❌ Too much access

# Good: Minimal necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:developer@company.com' \
  --role='roles/compute.instanceAdmin.v1'  # ✓ Specific role
```

### 3. Enable Security Monitoring

```bash
# Enable all audit logs
gcloud projects get-iam-policy PROJECT_ID \
  --format=json > policy.json

# Configure audit logging
cat > audit-config.yaml <<EOF
auditConfigs:
- auditLogConfigs:
  - logType: ADMIN_READ
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: allServices
EOF

# Apply audit configuration
gcloud projects set-iam-policy PROJECT_ID policy.json
```

### 4. Implement Network Segmentation

```
┌────────────────────────────────────────────────────────┐
│  Network Segmentation Example                          │
└────────────────────────────────────────────────────────┘

VPC: production-vpc
├── Subnet: web-tier (10.0.1.0/24)
│   ├── Public access allowed
│   └── Firewall: Allow HTTP/HTTPS from internet
│
├── Subnet: app-tier (10.0.2.0/24)
│   ├── Private (no external IP)
│   └── Firewall: Allow traffic only from web-tier
│
└── Subnet: db-tier (10.0.3.0/24)
    ├── Private (no external IP)
    └── Firewall: Allow traffic only from app-tier
```

---

## Compliance & Certifications

Google Cloud maintains numerous compliance certifications, but customers must ensure their use of GCP meets their specific compliance requirements.

```
┌────────────────────────────────────────────────────────┐
│  Compliance Certifications (Google Maintains)          │
├────────────────────────────────────────────────────────┤
│  • ISO/IEC 27001, 27017, 27018                         │
│  • SOC 1, SOC 2, SOC 3                                 │
│  • PCI DSS Level 1                                     │
│  • HIPAA (Business Associate Agreement available)     │
│  • GDPR (EU data protection)                           │
│  • FedRAMP (US government)                             │
│  • HITRUST CSF                                         │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Customer Compliance Responsibilities                  │
├────────────────────────────────────────────────────────┤
│  • Configure services to meet compliance requirements  │
│  • Implement required security controls                │
│  • Maintain audit trails and documentation             │
│  • Conduct regular compliance assessments              │
│  • Train staff on compliance requirements              │
└────────────────────────────────────────────────────────┘
```

---

## Security Incident Response

### Google's Role

```
• Monitor infrastructure for security threats
• Respond to platform-level security incidents
• Notify customers of relevant security issues
• Provide security bulletins and advisories
• Maintain incident response team (24/7)
```

### Customer's Role

```
• Monitor application and data access
• Respond to application-level security incidents
• Investigate suspicious activity in audit logs
• Implement incident response procedures
• Report security issues to Google (if platform-related)
```

---

## Key Takeaways

```
┌────────────────────────────────────────────────────────┐
│  Remember                                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. Google secures the INFRASTRUCTURE                 │
│     → Physical, network, platform                     │
│                                                         │
│  2. You secure YOUR WORKLOADS                         │
│     → Data, access, applications, configurations      │
│                                                         │
│  3. Responsibility varies by SERVICE MODEL            │
│     → IaaS: More customer responsibility              │
│     → PaaS: Shared responsibility                     │
│     → SaaS: More Google responsibility                │
│                                                         │
│  4. Security is a CONTINUOUS PROCESS                  │
│     → Regular audits, monitoring, updates             │
│                                                         │
│  5. Use DEFENSE IN DEPTH                              │
│     → Multiple layers of security controls            │
└────────────────────────────────────────────────────────┘
```

---
