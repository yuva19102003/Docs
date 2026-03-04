# Advanced IAM

Advanced Identity and Access Management features for enterprise-scale security and governance in Google Cloud Platform.

---

## 📚 Overview

Advanced IAM features enable sophisticated access control patterns, external identity integration, and enterprise-grade security for complex cloud environments.

**Topics Covered:**
- Workload Identity Federation
- Organization Policies
- VPC Service Controls
- Access Context Manager
- Policy Intelligence
- IAM Simulator

---

## 🌐 Workload Identity Federation

### 1. What is Workload Identity Federation?

```
┌────────────────────────────────────────────────────────┐
│  Workload Identity Federation                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Problem: Applications outside GCP need GCP access     │
│  Traditional Solution: Service account keys            │
│  • Keys can be leaked                                  │
│  • Manual rotation required                            │
│  • Security risk                                       │
│                                                         │
│  Workload Identity Federation Solution:                │
│  • No service account keys needed                      │
│  • Use external identity provider                      │
│  • Short-lived tokens                                  │
│  • Automatic rotation                                  │
│                                                         │
│  Supported Identity Providers:                         │
│  ✓ AWS (use AWS credentials)                           │
│  ✓ Azure (use Azure AD)                                │
│  ✓ On-premises Active Directory                        │
│  ✓ OIDC providers (Okta, Auth0, etc.)                  │
│  ✓ SAML 2.0 providers                                  │
│  ✓ GitHub Actions                                      │
│  ✓ GitLab CI                                           │
└────────────────────────────────────────────────────────┘
```

### 2. Setting Up Workload Identity Federation

**For AWS:**
```bash
# Create workload identity pool
gcloud iam workload-identity-pools create aws-pool \
  --location=global \
  --display-name="AWS Pool"

# Create AWS provider
gcloud iam workload-identity-pools providers create-aws aws-provider \
  --location=global \
  --workload-identity-pool=aws-pool \
  --account-id=AWS_ACCOUNT_ID

# Grant access to service account
gcloud iam service-accounts add-iam-policy-binding \
  my-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/aws-pool/attribute.aws_role/arn:aws:sts::AWS_ACCOUNT_ID:assumed-role/ROLE_NAME"

# Get credential configuration
gcloud iam workload-identity-pools create-cred-config \
  projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/aws-pool/providers/aws-provider \
  --service-account=my-sa@PROJECT_ID.iam.gserviceaccount.com \
  --aws \
  --output-file=aws-credentials.json

# Use in application
export GOOGLE_APPLICATION_CREDENTIALS=aws-credentials.json
# Application now uses AWS credentials to access GCP!
```

**For GitHub Actions:**
```bash
# Create workload identity pool
gcloud iam workload-identity-pools create github-pool \
  --location=global \
  --display-name="GitHub Pool"

# Create OIDC provider for GitHub
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location=global \
  --workload-identity-pool=github-pool \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository_owner=='YOUR_GITHUB_ORG'"

# Grant access to service account
gcloud iam service-accounts add-iam-policy-binding \
  github-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_ORG/YOUR_REPO"
```

**GitHub Actions Workflow:**
```yaml
name: Deploy to GCP
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Required for OIDC
    
    steps:
    - uses: actions/checkout@v3
    
    - id: auth
      uses: google-github-actions/auth@v1
      with:
        workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
        service_account: 'github-sa@PROJECT_ID.iam.gserviceaccount.com'
    
    - name: Deploy
      run: |
        gcloud run deploy my-service \
          --image=gcr.io/PROJECT_ID/my-image \
          --region=us-central1
```

---

## 🏢 Organization Policies

### 1. Policy Types

```
┌────────────────────────────────────────────────────────┐
│  Organization Policy Types                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  List Constraints:                                     │
│  • Allow or deny specific values                       │
│  • Example: Allowed VM machine types                   │
│  • Example: Allowed regions                            │
│                                                         │
│  Boolean Constraints:                                  │
│  • Enforce or not enforce a rule                       │
│  • Example: Require OS Login                           │
│  • Example: Disable service account key creation       │
│                                                         │
│  Custom Constraints:                                   │
│  • Define your own rules                               │
│  • CEL-based expressions                               │
│  • Advanced use cases                                  │
└────────────────────────────────────────────────────────┘
```

### 2. Common Organization Policies

```bash
# Restrict VM external IPs
cat > restrict-external-ips.yaml << EOF
constraint: compute.vmExternalIpAccess
listPolicy:
  deniedValues:
  - "*"
EOF

gcloud resource-manager org-policies set-policy \
  --organization=ORG_ID \
  restrict-external-ips.yaml

# Require OS Login
gcloud resource-manager org-policies enable-enforce \
  compute.requireOsLogin \
  --organization=ORG_ID

# Restrict resource locations
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

# Disable service account key creation
gcloud resource-manager org-policies enable-enforce \
  iam.disableServiceAccountKeyCreation \
  --organization=ORG_ID

# Restrict service account key upload
gcloud resource-manager org-policies enable-enforce \
  iam.disableServiceAccountKeyUpload \
  --organization=ORG_ID

# Domain restricted sharing
cat > domain-restriction.yaml << EOF
constraint: iam.allowedPolicyMemberDomains
listPolicy:
  allowedValues:
  - "C0123456"  # Your organization ID
  - "company.com"
EOF

gcloud resource-manager org-policies set-policy \
  --organization=ORG_ID \
  domain-restriction.yaml
```

### 3. Custom Organization Policies

```yaml
# custom-policy.yaml
name: organizations/ORG_ID/customConstraints/custom.requireLabels
resourceTypes:
- compute.googleapis.com/Instance
methodTypes:
- CREATE
condition: >
  resource.labels.exists(l, l == 'environment') &&
  resource.labels.exists(l, l == 'owner') &&
  resource.labels.exists(l, l == 'cost-center')
actionType: DENY
displayName: Require specific labels on VMs
description: All VMs must have environment, owner, and cost-center labels
```

```bash
# Create custom constraint
gcloud org-policies set-custom-constraint custom-policy.yaml

# Enforce custom constraint
cat > enforce-custom.yaml << EOF
name: organizations/ORG_ID/policies/custom.requireLabels
spec:
  rules:
  - enforce: true
EOF

gcloud org-policies set-policy enforce-custom.yaml --organization=ORG_ID
```

---

## 🛡️ VPC Service Controls

### 1. What are VPC Service Controls?

```
┌────────────────────────────────────────────────────────┐
│  VPC Service Controls                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose: Create security perimeters around GCP        │
│           resources to prevent data exfiltration       │
│                                                         │
│  Benefits:                                             │
│  ✓ Prevent data exfiltration                           │
│  ✓ Control access to services                          │
│  ✓ Restrict data movement                              │
│  ✓ Compliance (HIPAA, PCI DSS)                         │
│                                                         │
│  Components:                                           │
│  • Service Perimeter: Boundary around resources        │
│  • Access Levels: Who can access                       │
│  • Ingress/Egress Rules: Traffic control               │
│                                                         │
│  Protected Services:                                   │
│  • Cloud Storage                                       │
│  • BigQuery                                            │
│  • Cloud SQL                                           │
│  • Compute Engine                                      │
│  • 40+ GCP services                                    │
└────────────────────────────────────────────────────────┘
```

### 2. Creating Service Perimeters

```bash
# Create access policy (one per organization)
gcloud access-context-manager policies create \
  --organization=ORG_ID \
  --title="Production Policy"

# Get policy ID
POLICY_ID=$(gcloud access-context-manager policies list \
  --organization=ORG_ID \
  --format="value(name)")

# Create access level
gcloud access-context-manager levels create corporate_network \
  --title="Corporate Network" \
  --basic-level-spec=ip_subnetworks=203.0.113.0/24 \
  --policy=$POLICY_ID

# Create service perimeter
gcloud access-context-manager perimeters create production_perimeter \
  --title="Production Perimeter" \
  --resources=projects/PROJECT_NUMBER \
  --restricted-services=storage.googleapis.com,bigquery.googleapis.com \
  --access-levels=corporate_network \
  --policy=$POLICY_ID

# Add ingress rule
gcloud access-context-manager perimeters update production_perimeter \
  --add-ingress-rules=ingress-rule.yaml \
  --policy=$POLICY_ID
```

**ingress-rule.yaml:**
```yaml
- ingressFrom:
    identities:
    - serviceAccount:app@project.iam.gserviceaccount.com
    sources:
    - accessLevel: accessPolicies/POLICY_ID/accessLevels/corporate_network
  ingressTo:
    resources:
    - '*'
    operations:
    - serviceName: storage.googleapis.com
      methodSelectors:
      - method: '*'
```

---

## 🎯 Access Context Manager

### 1. Access Levels

```bash
# IP-based access level
gcloud access-context-manager levels create office_network \
  --title="Office Network" \
  --basic-level-spec=ip_subnetworks=203.0.113.0/24,198.51.100.0/24 \
  --policy=$POLICY_ID

# Device-based access level
gcloud access-context-manager levels create managed_devices \
  --title="Managed Devices" \
  --basic-level-spec=require_screen_lock=true,require_corp_owned=true,os_type=DESKTOP_CHROME_OS \
  --policy=$POLICY_ID

# Combined access level
gcloud access-context-manager levels create secure_access \
  --title="Secure Access" \
  --basic-level-spec=ip_subnetworks=203.0.113.0/24,require_screen_lock=true \
  --combine-function=AND \
  --policy=$POLICY_ID

# Region-based access level
gcloud access-context-manager levels create us_only \
  --title="US Only" \
  --basic-level-spec=regions=US \
  --policy=$POLICY_ID
```

### 2. Using Access Levels with IAM

```bash
# Grant access only from specific access level
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/bigquery.dataViewer' \
  --condition='expression=accessPolicies/POLICY_ID/accessLevels/corporate_network,title=Corporate Network Only'

# Multiple access levels (OR condition)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/storage.objectViewer' \
  --condition='expression=accessPolicies/POLICY_ID/accessLevels/corporate_network || accessPolicies/POLICY_ID/accessLevels/managed_devices,title=Corporate or Managed'
```

---

## 🔍 Policy Intelligence

### 1. Policy Analyzer

```bash
# Analyze who has access to a resource
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --full-resource-name="//compute.googleapis.com/projects/PROJECT_ID/zones/us-central1-a/instances/my-vm"

# Find all resources a user can access
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --identity="user:alice@company.com"

# Find all users with specific role
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --permissions="compute.instances.delete"

# Export analysis to BigQuery
gcloud asset analyze-iam-policy \
  --organization=ORG_ID \
  --output-bigquery-table="project.dataset.iam_analysis"
```

### 2. Policy Simulator

```bash
# Test if user would have access
gcloud policy-intelligence query-activity \
  --project=PROJECT_ID \
  --principal="user:alice@company.com" \
  --permission="compute.instances.create" \
  --resource="//compute.googleapis.com/projects/PROJECT_ID/zones/us-central1-a/instances/test-vm"

# Simulate policy change
gcloud policy-intelligence simulate-policy \
  --project=PROJECT_ID \
  --policy-file=new-policy.json \
  --principal="user:alice@company.com"
```

### 3. Activity Analyzer

```bash
# Analyze actual permission usage
gcloud policy-intelligence query-activity \
  --project=PROJECT_ID \
  --activity-type=PERMISSION_USAGE \
  --start-time=2026-01-01T00:00:00Z \
  --end-time=2026-03-01T00:00:00Z

# Find unused permissions
gcloud policy-intelligence query-activity \
  --project=PROJECT_ID \
  --activity-type=UNUSED_PERMISSIONS \
  --principal="user:alice@company.com"
```

---

## 🔐 Advanced Security Patterns

### 1. Break-Glass Access

```bash
# Create break-glass service account
gcloud iam service-accounts create break-glass \
  --display-name="Break Glass Emergency Access"

# Grant Owner role (emergency only)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:break-glass@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/owner'

# Restrict who can impersonate
gcloud iam service-accounts add-iam-policy-binding \
  break-glass@PROJECT_ID.iam.gserviceaccount.com \
  --member='group:incident-commanders@company.com' \
  --role='roles/iam.serviceAccountTokenCreator'

# Set up alerting for any use
gcloud logging sinks create break-glass-alert \
  --log-filter='protoPayload.authenticationInfo.principalEmail="break-glass@PROJECT_ID.iam.gserviceaccount.com"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/critical-alerts
```

### 2. Privileged Access Management

```python
#!/usr/bin/env python3
"""
Temporary privilege escalation system
"""

from google.cloud import resourcemanager_v3
from datetime import datetime, timedelta
import time

def grant_temporary_access(project_id, user_email, role, duration_hours=4):
    """Grant temporary elevated access"""
    
    client = resourcemanager_v3.ProjectsClient()
    
    # Calculate expiration
    expiration = datetime.utcnow() + timedelta(hours=duration_hours)
    expiration_str = expiration.strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Grant access with time condition
    condition = {
        'title': f'Temporary Access - Expires {expiration_str}',
        'description': f'Granted at {datetime.utcnow().isoformat()}',
        'expression': f'request.time < timestamp("{expiration_str}")'
    }
    
    # Get current policy
    policy = client.get_iam_policy(
        request={"resource": f"projects/{project_id}"}
    )
    
    # Add binding with condition
    from google.iam.v1 import policy_pb2
    binding = policy_pb2.Binding(
        role=role,
        members=[f'user:{user_email}'],
        condition=condition
    )
    policy.bindings.append(binding)
    
    # Set updated policy
    client.set_iam_policy(
        request={
            "resource": f"projects/{project_id}",
            "policy": policy
        }
    )
    
    print(f"Granted {role} to {user_email}")
    print(f"Expires: {expiration_str}")
    
    # Log the grant
    # Send notification
    # Create audit trail

# Usage
grant_temporary_access(
    "my-project",
    "oncall@company.com",
    "roles/compute.instanceAdmin.v1",
    duration_hours=4
)
```

---

## ✅ Advanced IAM Checklist

### Workload Identity Federation
- [ ] Identify external workloads needing GCP access
- [ ] Set up workload identity pools
- [ ] Configure identity providers
- [ ] Test authentication flow
- [ ] Remove service account keys
- [ ] Monitor federation usage

### Organization Policies
- [ ] Define security requirements
- [ ] Implement required constraints
- [ ] Test policy enforcement
- [ ] Document exceptions
- [ ] Regular policy reviews
- [ ] Monitor compliance

### VPC Service Controls
- [ ] Identify sensitive data
- [ ] Design service perimeters
- [ ] Configure access levels
- [ ] Set up ingress/egress rules
- [ ] Test data access
- [ ] Monitor perimeter violations

### Policy Intelligence
- [ ] Enable Policy Analyzer
- [ ] Regular access reviews
- [ ] Simulate policy changes
- [ ] Analyze permission usage
- [ ] Remove unused permissions
- [ ] Document findings

---

## 🎓 Next Steps

1. Review [Best Practices](./8-Best-Practices.md) for enterprise IAM
2. Return to [IAM Fundamentals](./1-IAM-Fundamentals.md) for basics
3. Learn about [Service Accounts](./3-Service-Accounts.md) for application identity
4. Implement [Least Privilege](./5-Least-Privilege.md) principles

---

**Last Updated:** March 2026
**Version:** 2.0
