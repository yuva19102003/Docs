# IAM Best Practices

Enterprise-grade best practices for Identity and Access Management in Google Cloud Platform.

---

## 📚 Overview

This guide consolidates IAM best practices for building secure, scalable, and compliant cloud environments. Following these practices reduces security risks, improves operational efficiency, and ensures regulatory compliance.

---

## 🎯 Core Principles

### 1. Principle of Least Privilege

```
✓ Grant minimum permissions needed
✓ Start restrictive, expand as needed
✓ Use predefined roles over basic roles
✓ Regular permission reviews
✓ Remove unused access immediately
✓ Document permission rationale
✓ Use time-bound access when possible
✓ Implement just-in-time access

❌ Never grant roles/owner unless absolutely necessary
❌ Avoid roles/editor and roles/viewer in production
❌ Don't grant permanent access for temporary needs
❌ Never use "allUsers" or "allAuthenticatedUsers"
```

### 2. Defense in Depth

```
Layer 1: Organization Policies
  • Enforce security boundaries
  • Restrict resource locations
  • Require OS Login
  • Disable service account keys

Layer 2: IAM Roles and Policies
  • Least privilege access
  • Role-based access control
  • Conditional access
  • Regular audits

Layer 3: VPC Service Controls
  • Data exfiltration prevention
  • Service perimeters
  • Access levels
  • Ingress/egress rules

Layer 4: Identity-Aware Proxy
  • Application-level access
  • Context-aware decisions
  • Zero trust model
  • No VPN required

Layer 5: Monitoring and Logging
  • Audit all access
  • Alert on anomalies
  • Regular reviews
  • Incident response
```

### 3. Zero Trust Security

```
Never Trust, Always Verify:
✓ Verify every access request
✓ Assume breach mentality
✓ No implicit trust
✓ Continuous verification
✓ Context-aware access
✓ Micro-segmentation

Implementation:
✓ Identity-Aware Proxy (IAP)
✓ VPC Service Controls
✓ Binary Authorization
✓ Workload Identity
✓ Private Google Access
✓ Access Context Manager
```

---

## 👥 User Management

### 1. Use Groups, Not Individual Users

```bash
# ❌ BAD: Grant to individual users
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/compute.instanceAdmin.v1'

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:bob@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# ✓ GOOD: Grant to group
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:compute-admins@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Benefits:
# • Easier to manage
# • Consistent permissions
# • Simpler auditing
# • Faster onboarding/offboarding
```

### 2. Group Naming Convention

```
Format: [FUNCTION]-[ROLE]-[ENVIRONMENT]@company.com

Examples:
  compute-admins-prod@company.com
  storage-viewers-dev@company.com
  bigquery-editors-staging@company.com
  network-admins-all@company.com

Benefits:
  ✓ Clear purpose
  ✓ Easy to search
  ✓ Consistent structure
  ✓ Self-documenting
```

### 3. User Lifecycle Management

```
Onboarding:
1. Add user to appropriate groups
2. Assign required roles
3. Set up MFA
4. Provide training
5. Document access

Offboarding:
1. Remove from all groups immediately
2. Revoke all direct role assignments
3. Disable service account keys
4. Audit access logs
5. Document removal

Regular Reviews:
• Weekly: New access grants
• Monthly: Group memberships
• Quarterly: All access
• Annually: Full audit
```

---

## 🤖 Service Account Management

### 1. Service Account Best Practices

```
✓ One service account per application
✓ Descriptive names (app-backend, data-processor)
✓ Use Workload Identity (GKE)
✓ Use metadata server (Compute Engine)
✓ Avoid creating keys when possible
✓ Rotate keys every 90 days (if needed)
✓ Store keys in Secret Manager
✓ Never commit keys to source control
✓ Monitor service account usage
✓ Disable unused service accounts

❌ Don't use default service accounts
❌ Don't grant Editor/Owner to service accounts
❌ Don't share service accounts across apps
❌ Don't use user-managed keys unless necessary
```

### 2. Service Account Naming

```
Format: [APPLICATION]-[FUNCTION]-sa

Examples:
  web-backend-sa@project.iam.gserviceaccount.com
  data-processor-sa@project.iam.gserviceaccount.com
  cicd-deployer-sa@project.iam.gserviceaccount.com
  monitoring-agent-sa@project.iam.gserviceaccount.com

Benefits:
  ✓ Clear purpose
  ✓ Easy to identify
  ✓ Searchable
  ✓ Audit-friendly
```

### 3. Service Account Security

```bash
# Disable default service accounts
gcloud iam service-accounts disable \
  PROJECT_NUMBER-compute@developer.gserviceaccount.com

# Use Workload Identity instead of keys
# For GKE:
gcloud iam service-accounts add-iam-policy-binding \
  app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"

# Monitor service account key creation
gcloud logging read \
  'protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"' \
  --limit=50

# Alert on key creation
gcloud logging sinks create sa-key-alert \
  --log-filter='protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/security-alerts
```

---

## 🔐 Role Management

### 1. Role Selection Hierarchy

```
Priority 1: Predefined Roles (BEST)
  ✓ Curated by Google
  ✓ Regularly updated
  ✓ Service-specific
  ✓ Well-documented
  
  Examples:
  • roles/compute.instanceAdmin.v1
  • roles/storage.objectViewer
  • roles/bigquery.dataEditor

Priority 2: Custom Roles (GOOD)
  ✓ Tailored to exact needs
  ✓ Least privilege
  ✓ Requires maintenance
  
  When to use:
  • Predefined roles too broad
  • Specific permission combination needed
  • Compliance requirements

Priority 3: Basic Roles (AVOID)
  ❌ Too permissive
  ❌ Legacy
  ❌ Not recommended
  
  Never use in production:
  • roles/owner
  • roles/editor
  • roles/viewer
```

### 2. Custom Role Best Practices

```yaml
# custom-role.yaml
title: "Backend Developer"
description: "Permissions for backend developers"
stage: "GA"
includedPermissions:
# Only include what's needed
- compute.instances.get
- compute.instances.list
- compute.instances.start
- compute.instances.stop
- storage.objects.get
- storage.objects.list
- cloudsql.instances.connect
- logging.logEntries.list

# Document the role
# Version control this file
# Regular reviews and updates
# Test before deploying
```

```bash
# Create with documentation
gcloud iam roles create backendDeveloper \
  --project=PROJECT_ID \
  --file=custom-role.yaml

# Document in README
echo "# Custom Role: backendDeveloper
Purpose: Backend developers need to manage compute instances and access storage
Permissions: See custom-role.yaml
Review Schedule: Quarterly
Last Updated: 2026-03-04
" > roles/backend-developer-README.md
```

### 3. Role Assignment Patterns

```bash
# Pattern 1: Environment-based
# Production: Read-only
gcloud projects add-iam-policy-binding prod-project \
  --member='group:developers@company.com' \
  --role='roles/viewer'

# Development: Full access
gcloud projects add-iam-policy-binding dev-project \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Pattern 2: Resource-based with conditions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=resource.labels.environment == "dev",title=Dev Only'

# Pattern 3: Time-bound access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Contract Period'
```

---

## 📊 Monitoring and Auditing

### 1. Enable Comprehensive Logging

```bash
# Enable all audit logs
# Go to: IAM & Admin → Audit Logs
# Enable: Admin Read, Data Read, Data Write for all services

# Or via gcloud for specific service
gcloud projects set-iam-policy PROJECT_ID policy.json

# policy.json includes:
{
  "auditConfigs": [
    {
      "service": "allServices",
      "auditLogConfigs": [
        {"logType": "ADMIN_READ"},
        {"logType": "DATA_READ"},
        {"logType": "DATA_WRITE"}
      ]
    }
  ]
}
```

### 2. Set Up Critical Alerts

```bash
# Alert on Owner role grants
gcloud logging sinks create owner-role-alert \
  --log-filter='protoPayload.methodName="SetIamPolicy" AND protoPayload.request.policy.bindings.role="roles/owner"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/critical-alerts

# Alert on service account key creation
gcloud logging sinks create sa-key-alert \
  --log-filter='protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/security-alerts

# Alert on policy changes
gcloud logging sinks create policy-change-alert \
  --log-filter='protoPayload.methodName="SetIamPolicy"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/iam-changes

# Alert on failed access attempts
gcloud logging sinks create access-denied-alert \
  --log-filter='protoPayload.status.code=7' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/access-denied
```

### 3. Regular Access Reviews

```python
#!/usr/bin/env python3
"""
Automated monthly access review
"""

from google.cloud import resourcemanager_v3
from google.cloud import asset_v1
from datetime import datetime
import csv

def monthly_access_review(organization_id):
    """Generate monthly access review report"""
    
    client = asset_v1.AssetServiceClient()
    
    # Get all IAM policies
    request = asset_v1.SearchAllIamPoliciesRequest(
        scope=f"organizations/{organization_id}",
    )
    
    policies = client.search_all_iam_policies(request=request)
    
    # Analyze policies
    report = []
    issues = []
    
    for policy in policies:
        for binding in policy.policy.bindings:
            # Flag basic roles
            if binding.role in ['roles/owner', 'roles/editor', 'roles/viewer']:
                issues.append({
                    'severity': 'HIGH',
                    'resource': policy.resource,
                    'issue': f'Basic role {binding.role} in use',
                    'members': list(binding.members)
                })
            
            # Flag service accounts with broad permissions
            if binding.role in ['roles/owner', 'roles/editor']:
                for member in binding.members:
                    if member.startswith('serviceAccount:'):
                        issues.append({
                            'severity': 'CRITICAL',
                            'resource': policy.resource,
                            'issue': f'Service account with {binding.role}',
                            'member': member
                        })
            
            # Add to report
            for member in binding.members:
                report.append({
                    'resource': policy.resource,
                    'member': member,
                    'role': binding.role,
                    'has_condition': bool(binding.condition)
                })
    
    # Generate CSV reports
    timestamp = datetime.now().strftime('%Y%m%d')
    
    with open(f'access-review-{timestamp}.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['resource', 'member', 'role', 'has_condition'])
        writer.writeheader()
        writer.writerows(report)
    
    with open(f'access-issues-{timestamp}.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['severity', 'resource', 'issue', 'member'])
        writer.writeheader()
        writer.writerows(issues)
    
    print(f"Review complete: {len(report)} bindings, {len(issues)} issues")
    
    return report, issues

# Run monthly
monthly_access_review("123456789")
```

---

## 🏢 Organization-Level Best Practices

### 1. Organization Structure

```
Organization
├── Production Folder
│   ├── Strict policies
│   ├── Limited access
│   ├── Full audit logging
│   └── VPC Service Controls
│
├── Staging Folder
│   ├── Moderate policies
│   ├── Developer access
│   └── Standard logging
│
├── Development Folder
│   ├── Relaxed policies
│   ├── Full developer access
│   └── Basic logging
│
└── Sandbox Folder
    ├── Minimal policies
    ├── Experimental access
    └── Optional logging

Benefits:
✓ Clear separation
✓ Appropriate controls per environment
✓ Easy to manage
✓ Scalable
```

### 2. Organization Policies

```bash
# Essential organization policies

# 1. Require OS Login
gcloud resource-manager org-policies enable-enforce \
  compute.requireOsLogin \
  --organization=ORG_ID

# 2. Disable service account key creation
gcloud resource-manager org-policies enable-enforce \
  iam.disableServiceAccountKeyCreation \
  --organization=ORG_ID

# 3. Restrict resource locations
cat > restrict-locations.yaml << EOF
constraint: gcp.resourceLocations
listPolicy:
  allowedValues:
  - in:us-locations
  - in:eu-locations
EOF

gcloud resource-manager org-policies set-policy \
  --organization=ORG_ID \
  restrict-locations.yaml

# 4. Domain restricted sharing
cat > domain-restriction.yaml << EOF
constraint: iam.allowedPolicyMemberDomains
listPolicy:
  allowedValues:
  - "C0123456"  # Your org ID
  - "company.com"
EOF

gcloud resource-manager org-policies set-policy \
  --organization=ORG_ID \
  domain-restriction.yaml

# 5. Restrict VM external IPs (production only)
cat > restrict-external-ips.yaml << EOF
constraint: compute.vmExternalIpAccess
listPolicy:
  deniedValues:
  - "*"
EOF

gcloud resource-manager org-policies set-policy \
  --folder=PRODUCTION_FOLDER_ID \
  restrict-external-ips.yaml
```

---

## 📋 Compliance and Governance

### 1. Compliance Checklist

```
SOC 2 / ISO 27001:
✓ Least privilege access
✓ Regular access reviews
✓ Audit logging enabled
✓ MFA enforced
✓ Separation of duties
✓ Incident response plan
✓ Access revocation process
✓ Documentation maintained

HIPAA:
✓ VPC Service Controls
✓ Encryption at rest and in transit
✓ Access logging and monitoring
✓ BAA with Google
✓ PHI access controls
✓ Audit trails
✓ Breach notification process

PCI DSS:
✓ Network segmentation
✓ Access control measures
✓ Logging and monitoring
✓ Regular security testing
✓ Encryption requirements
✓ Vendor management
✓ Incident response
```

### 2. Documentation Requirements

```
Required Documentation:
1. IAM Policy Document
   • Who has what access
   • Why access is granted
   • Review schedule
   • Approval process

2. Role Definitions
   • Custom role purposes
   • Permission justifications
   • Usage guidelines
   • Review schedule

3. Service Account Inventory
   • Purpose of each SA
   • Permissions granted
   • Key management (if any)
   • Owner/contact

4. Access Review Procedures
   • Review frequency
   • Review process
   • Escalation procedures
   • Documentation requirements

5. Incident Response Plan
   • Detection procedures
   • Response procedures
   • Communication plan
   • Post-incident review
```

---

## ✅ Implementation Checklist

### Initial Setup
- [ ] Set up Cloud Identity or Google Workspace
- [ ] Create organization structure
- [ ] Define IAM governance policy
- [ ] Create groups for teams
- [ ] Implement organization policies
- [ ] Enable audit logging
- [ ] Set up monitoring and alerting

### User Management
- [ ] Use groups instead of individual users
- [ ] Implement consistent naming conventions
- [ ] Define onboarding/offboarding procedures
- [ ] Enforce MFA for all users
- [ ] Regular access reviews scheduled
- [ ] Document all access grants

### Service Accounts
- [ ] One SA per application
- [ ] Use Workload Identity (GKE)
- [ ] Avoid service account keys
- [ ] Descriptive SA names
- [ ] Minimal permissions
- [ ] Monitor SA usage
- [ ] Disable unused SAs

### Roles and Permissions
- [ ] Use predefined roles when possible
- [ ] Create custom roles for specific needs
- [ ] Implement least privilege
- [ ] Use time-bound access
- [ ] Document role assignments
- [ ] Regular permission reviews

### Security
- [ ] Enable all audit logs
- [ ] Set up critical alerts
- [ ] Implement VPC Service Controls
- [ ] Use Identity-Aware Proxy
- [ ] Regular security audits
- [ ] Incident response plan
- [ ] Break-glass procedures

### Compliance
- [ ] Document IAM policies
- [ ] Regular compliance audits
- [ ] Meet regulatory requirements
- [ ] Maintain audit trails
- [ ] Access review procedures
- [ ] Incident response documented

---

## 🎓 Summary

Key Takeaways:
1. Always follow least privilege principle
2. Use groups, not individual users
3. Avoid basic roles (Owner, Editor, Viewer)
4. Use predefined roles when possible
5. Enable comprehensive audit logging
6. Regular access reviews are critical
7. Automate where possible
8. Document everything
9. Monitor and alert on critical changes
10. Continuous improvement

---

**Last Updated:** March 2026
**Version:** 2.0
