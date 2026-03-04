# Least Privilege

Complete guide to implementing the principle of least privilege in Google Cloud Platform for maximum security.

---

## 📚 Overview

The principle of least privilege means granting only the minimum permissions necessary to perform a task. This fundamental security principle reduces risk, limits blast radius, and improves compliance.

**Key Benefits:**
- **Reduced Attack Surface**: Fewer permissions = fewer exploitation opportunities
- **Limited Blast Radius**: Compromised accounts have minimal impact
- **Compliance**: Meet regulatory requirements (SOC 2, ISO 27001, PCI DSS)
- **Audit Trail**: Clear understanding of who can do what

---

## 🎯 Core Principles

### 1. Least Privilege Definition

```
┌────────────────────────────────────────────────────────┐
│  Least Privilege Principle                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Grant the MINIMUM permissions needed to:              │
│  • Perform the required task                           │
│  • For the required duration                           │
│  • On the required resources                           │
│  • Nothing more                                        │
│                                                         │
│  Example:                                              │
│  ❌ Bad: Grant roles/editor to developer               │
│     • 3,000+ permissions                               │
│     • Can modify almost everything                     │
│     • Permanent access                                 │
│                                                         │
│  ✓ Good: Grant specific roles                          │
│     • roles/compute.instanceAdmin.v1                   │
│     • roles/storage.objectViewer                       │
│     • ~100 permissions                                 │
│     • Only what's needed                               │
│                                                         │
│  ✓✓ Better: Add time constraints                       │
│     • Same specific roles                              │
│     • With expiration condition                        │
│     • Automatic revocation                             │
└────────────────────────────────────────────────────────┘
```

### 2. Zero Trust Model

```
┌────────────────────────────────────────────────────────┐
│  Zero Trust Principles                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Never Trust, Always Verify:                          │
│  • No implicit trust based on network location         │
│  • Verify every access request                         │
│  • Assume breach mentality                             │
│  • Continuous verification                             │
│                                                         │
│  Implementation in GCP:                                │
│  ✓ Identity-Aware Proxy (IAP)                          │
│  ✓ VPC Service Controls                                │
│  ✓ Context-aware access                                │
│  ✓ Binary Authorization                                │
│  ✓ Workload Identity                                   │
│  ✓ Private Google Access                               │
└────────────────────────────────────────────────────────┘
```

---

## 🔧 Implementation Strategies

### 1. Start with Minimal Access

```bash
# ❌ WRONG: Start with broad access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:newdev@company.com' \
  --role='roles/editor'

# ✓ RIGHT: Start with read-only
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:newdev@company.com' \
  --role='roles/viewer'

# Then add specific permissions as needed
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:newdev@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Principle: Start restrictive, expand as needed
# Never start permissive and try to restrict later
```

### 2. Use Predefined Roles Over Basic Roles

```
┌────────────────────────────────────────────────────────┐
│  Role Selection Hierarchy                              │
└────────────────────────────────────────────────────────┘

Level 1: Predefined Roles (BEST)
├─ Service-specific
├─ Curated by Google
├─ Regularly updated
└─ Example: roles/compute.instanceAdmin.v1

Level 2: Custom Roles (GOOD)
├─ Tailored to exact needs
├─ You maintain
├─ More work to manage
└─ Example: custom.vmOperator

Level 3: Basic Roles (AVOID)
├─ Too broad
├─ Legacy
├─ Not recommended
└─ Example: roles/editor

Level 4: Owner Role (NEVER)
├─ Full control
├─ Can delete project
├─ Highest risk
└─ Example: roles/owner
```

### 3. Implement Time-Bound Access

```bash
# Temporary access with expiration
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=request.time < timestamp("2026-06-30T23:59:59Z"),title=Q2 Contract,description=Access expires end of Q2 2026'

# Business hours only access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:support@company.com' \
  --role='roles/compute.viewer' \
  --condition='expression=request.time.getHours("UTC") >= 9 && request.time.getHours("UTC") < 17,title=Business Hours,description=9 AM to 5 PM UTC only'

# Weekend access for maintenance
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:maintenance@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=request.time.getDayOfWeek("UTC") == 0 || request.time.getDayOfWeek("UTC") == 6,title=Weekend Only,description=Saturday and Sunday only'
```

### 4. Resource-Specific Permissions

```bash
# Grant access to specific bucket only
gcloud storage buckets add-iam-policy-binding gs://app-data-prod \
  --member='serviceAccount:app@project.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Grant access to specific VM only
gcloud compute instances add-iam-policy-binding my-vm \
  --zone=us-central1-a \
  --member='user:admin@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Use conditions for resource-based access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:developer@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=resource.labels.environment == "dev",title=Dev VMs Only,description=Can only manage VMs labeled as dev'
```

---

## 📊 Access Review Process

### 1. Regular Access Audits

```bash
# Weekly: Review new access grants
gcloud logging read \
  'protoPayload.methodName="SetIamPolicy"' \
  --limit=50 \
  --format='table(timestamp,protoPayload.authenticationInfo.principalEmail,resource.labels.project_id)'

# Monthly: Review all project access
gcloud projects get-iam-policy PROJECT_ID \
  --format='table(bindings.role,bindings.members.flatten())' > access-report-$(date +%Y%m%d).txt

# Quarterly: Full organization audit
gcloud asset search-all-iam-policies \
  --scope=organizations/ORG_ID \
  --query="policy:user:*@company.com" \
  --format=json > org-access-audit-$(date +%Y%m%d).json
```

### 2. IAM Recommender Integration

```bash
# Get over-permission recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global \
  --format='table(name,primaryImpact.category,stateInfo.state,description)'

# Get detailed recommendation
gcloud recommender recommendations describe RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global

# Apply recommendation
gcloud recommender recommendations mark-claimed RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global

# After applying changes
gcloud recommender recommendations mark-succeeded RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global
```

### 3. Automated Access Review Script

```python
#!/usr/bin/env python3
"""
Automated IAM access review script
Identifies over-privileged accounts and generates report
"""

from google.cloud import resourcemanager_v3
from google.cloud import recommender_v1
from datetime import datetime
import csv

def review_project_access(project_id):
    """Review and report on project IAM access"""
    
    # Get project IAM policy
    client = resourcemanager_v3.ProjectsClient()
    policy = client.get_iam_policy(
        request={"resource": f"projects/{project_id}"}
    )
    
    issues = []
    
    # Check for basic roles (Owner, Editor, Viewer)
    for binding in policy.bindings:
        if binding.role in ['roles/owner', 'roles/editor', 'roles/viewer']:
            for member in binding.members:
                issues.append({
                    'severity': 'HIGH' if binding.role == 'roles/owner' else 'MEDIUM',
                    'member': member,
                    'role': binding.role,
                    'issue': f'Using basic role instead of predefined role',
                    'recommendation': 'Replace with specific predefined roles'
                })
    
    # Check for service accounts with Editor/Owner
    for binding in policy.bindings:
        if binding.role in ['roles/owner', 'roles/editor']:
            for member in binding.members:
                if member.startswith('serviceAccount:'):
                    issues.append({
                        'severity': 'CRITICAL',
                        'member': member,
                        'role': binding.role,
                        'issue': 'Service account with overly broad permissions',
                        'recommendation': 'Use least privilege service account roles'
                    })
    
    # Get IAM Recommender suggestions
    recommender_client = recommender_v1.RecommenderClient()
    parent = f"projects/{project_id}/locations/global/recommenders/google.iam.policy.Recommender"
    
    try:
        recommendations = recommender_client.list_recommendations(parent=parent)
        for rec in recommendations:
            if rec.state.name == "ACTIVE":
                issues.append({
                    'severity': 'MEDIUM',
                    'member': 'See recommendation',
                    'role': 'Various',
                    'issue': rec.description,
                    'recommendation': 'Review IAM Recommender in Console'
                })
    except Exception as e:
        print(f"Could not fetch recommendations: {e}")
    
    return issues

def generate_report(project_id, output_file):
    """Generate CSV report of access issues"""
    issues = review_project_access(project_id)
    
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['severity', 'member', 'role', 'issue', 'recommendation']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for issue in issues:
            writer.writerow(issue)
    
    print(f"Report generated: {output_file}")
    print(f"Total issues found: {len(issues)}")
    
    # Print summary
    critical = sum(1 for i in issues if i['severity'] == 'CRITICAL')
    high = sum(1 for i in issues if i['severity'] == 'HIGH')
    medium = sum(1 for i in issues if i['severity'] == 'MEDIUM')
    
    print(f"\nSummary:")
    print(f"  CRITICAL: {critical}")
    print(f"  HIGH: {high}")
    print(f"  MEDIUM: {medium}")

# Usage
if __name__ == "__main__":
    project_id = "your-project-id"
    output_file = f"iam-review-{datetime.now().strftime('%Y%m%d')}.csv"
    generate_report(project_id, output_file)
```

---

## 🎨 Common Patterns

### Pattern 1: Developer Access

```bash
# ❌ WRONG: Grant Editor role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/editor'

# ✓ RIGHT: Grant specific roles needed
# Compute access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# Storage read access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/storage.objectViewer'

# Cloud SQL client access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/cloudsql.client'

# Logging viewer
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/logging.viewer'

# Result: ~200 permissions instead of 3,000+
```

### Pattern 2: Service Account for Application

```bash
# Create service account
gcloud iam service-accounts create web-app-sa \
  --display-name="Web Application"

# ❌ WRONG: Grant broad access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/editor'

# ✓ RIGHT: Grant only what's needed
# Read from specific bucket
gcloud storage buckets add-iam-policy-binding gs://app-data \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Connect to Cloud SQL
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.client'

# Access secrets
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:web-app-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/secretmanager.secretAccessor'

# Result: ~20 permissions instead of 3,000+
```

### Pattern 3: Temporary Admin Access

```bash
# Grant temporary elevated access for incident response
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:oncall@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=request.time < timestamp("2026-03-05T23:59:59Z"),title=Incident Response,description=24-hour emergency access'

# Automatically expires after 24 hours
# No manual cleanup needed
```

### Pattern 4: Environment Separation

```bash
# Production: Read-only for most users
gcloud projects add-iam-policy-binding prod-project \
  --member='group:engineers@company.com' \
  --role='roles/viewer'

# Development: Full access
gcloud projects add-iam-policy-binding dev-project \
  --member='group:engineers@company.com' \
  --role='roles/editor'

# Or use resource labels with conditions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:engineers@company.com' \
  --role='roles/compute.instanceAdmin.v1' \
  --condition='expression=resource.labels.environment == "dev",title=Dev Only'
```

---

## 🛡️ Advanced Techniques

### 1. Just-In-Time (JIT) Access

```
┌────────────────────────────────────────────────────────┐
│  Just-In-Time Access Pattern                           │
└────────────────────────────────────────────────────────┘

Concept: Grant elevated access only when needed, for limited time

Implementation Options:

1. Manual JIT (Simple):
   • User requests access via ticket
   • Admin grants with time condition
   • Access auto-expires

2. Automated JIT (Advanced):
   • User requests via self-service portal
   • Approval workflow
   • Automatic grant with expiration
   • Audit logging

3. Context-Aware JIT:
   • Access based on context (location, device, time)
   • Risk-based decisions
   • Continuous verification

Benefits:
✓ Reduced standing privileges
✓ Lower attack surface
✓ Better audit trail
✓ Compliance friendly
```

### 2. Privilege Access Management (PAM)

```bash
# Example: Break-glass access for emergencies

# 1. Create break-glass service account
gcloud iam service-accounts create break-glass-admin \
  --display-name="Break Glass Admin"

# 2. Grant necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:break-glass-admin@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/owner'

# 3. Restrict who can impersonate
gcloud iam service-accounts add-iam-policy-binding \
  break-glass-admin@PROJECT_ID.iam.gserviceaccount.com \
  --member='group:incident-commanders@company.com' \
  --role='roles/iam.serviceAccountTokenCreator'

# 4. Set up alerting for any use
gcloud logging sinks create break-glass-alert \
  --log-filter='protoPayload.authenticationInfo.principalEmail="break-glass-admin@PROJECT_ID.iam.gserviceaccount.com"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/security-alerts

# Usage only in emergencies with full audit trail
```

### 3. Separation of Duties

```
┌────────────────────────────────────────────────────────┐
│  Separation of Duties Example                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Scenario: Deploy application to production            │
│                                                         │
│  Role 1: Developer                                     │
│  • Can write code                                      │
│  • Can create container images                         │
│  • Cannot deploy to production                         │
│                                                         │
│  Role 2: Approver                                      │
│  • Can approve deployments                             │
│  • Cannot write code                                   │
│  • Cannot create images                                │
│                                                         │
│  Role 3: Deployer (Service Account)                   │
│  • Can deploy to production                            │
│  • Requires approval                                   │
│  • Automated process                                   │
│                                                         │
│  Result: No single person can deploy without approval  │
└────────────────────────────────────────────────────────┘
```

```bash
# Developer: Can build images
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/cloudbuild.builds.editor'

# Approver: Can approve releases
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:release-managers@company.com' \
  --role='roles/cloudrun.admin' \
  --condition='expression=resource.labels.approved == "true",title=Approved Only'

# Deployer SA: Can deploy (used by CI/CD)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:deployer@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/run.admin'
```

---

## 📈 Monitoring and Compliance

### 1. Access Monitoring

```bash
# Monitor privileged role assignments
gcloud logging read \
  'protoPayload.methodName="SetIamPolicy" AND 
   (protoPayload.request.policy.bindings.role="roles/owner" OR 
    protoPayload.request.policy.bindings.role="roles/editor")' \
  --limit=50 \
  --format=json

# Monitor service account key creation
gcloud logging read \
  'protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"' \
  --limit=50

# Monitor impersonation events
gcloud logging read \
  'protoPayload.serviceData.policyDelta.bindingDeltas.action="ADD" AND 
   protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/iam.serviceAccountTokenCreator"' \
  --limit=50
```

### 2. Compliance Reporting

```python
#!/usr/bin/env python3
"""
Generate compliance report for least privilege
"""

from google.cloud import resourcemanager_v3
from google.cloud import asset_v1
import json

def generate_compliance_report(organization_id):
    """Generate least privilege compliance report"""
    
    client = asset_v1.AssetServiceClient()
    
    # Search for all IAM policies
    request = asset_v1.SearchAllIamPoliciesRequest(
        scope=f"organizations/{organization_id}",
    )
    
    policies = client.search_all_iam_policies(request=request)
    
    violations = []
    
    for policy in policies:
        for binding in policy.policy.bindings:
            # Check for basic roles
            if binding.role in ['roles/owner', 'roles/editor', 'roles/viewer']:
                violations.append({
                    'resource': policy.resource,
                    'violation': 'Basic role usage',
                    'role': binding.role,
                    'members': list(binding.members),
                    'severity': 'HIGH' if binding.role == 'roles/owner' else 'MEDIUM'
                })
            
            # Check for service accounts with broad permissions
            if binding.role in ['roles/owner', 'roles/editor']:
                for member in binding.members:
                    if member.startswith('serviceAccount:'):
                        violations.append({
                            'resource': policy.resource,
                            'violation': 'Over-privileged service account',
                            'role': binding.role,
                            'member': member,
                            'severity': 'CRITICAL'
                        })
    
    # Generate report
    report = {
        'generated_at': datetime.now().isoformat(),
        'organization_id': organization_id,
        'total_violations': len(violations),
        'violations': violations
    }
    
    with open('compliance-report.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"Compliance report generated: {len(violations)} violations found")
    
    return report

# Usage
generate_compliance_report("123456789")
```

---

## ✅ Least Privilege Checklist

### Initial Setup
- [ ] Identify required permissions for each role
- [ ] Use predefined roles when possible
- [ ] Create custom roles for specific needs
- [ ] Document permission rationale
- [ ] Implement approval process

### Ongoing Management
- [ ] Weekly: Review new access grants
- [ ] Monthly: Review IAM Recommender
- [ ] Quarterly: Full access audit
- [ ] Remove unused permissions
- [ ] Update documentation

### Security Measures
- [ ] No basic roles in production
- [ ] Time-bound access for temporary needs
- [ ] Service accounts with minimal permissions
- [ ] Separation of duties implemented
- [ ] Break-glass procedures documented

### Monitoring
- [ ] Audit logging enabled
- [ ] Alerts for privileged operations
- [ ] Regular compliance reports
- [ ] Track permission changes
- [ ] Monitor for anomalies

---

## 🎓 Next Steps

1. Learn about [Identity-Aware Proxy](./6-Identity-Aware-Proxy.md) for application-level access control
2. Explore [Advanced IAM](./7-Advanced-IAM.md) features
3. Review [Best Practices](./8-Best-Practices.md) for enterprise IAM
4. Return to [IAM Policies](./4-IAM-Policies.md) for policy management

---

**Last Updated:** March 2026
**Version:** 2.0
