# 4️⃣ Identity & Access Management (IAM)

Complete guide to securing and controlling access to Google Cloud Platform resources.

---

## 📚 What You'll Learn

Master GCP IAM to implement secure, scalable access control:

- **Identity Management**: Users, groups, and service accounts
- **Access Control**: Roles, permissions, and policies
- **Security**: Least privilege, conditions, and best practices
- **Automation**: Programmatic IAM management
- **Advanced Features**: IAP, Workload Identity, Organization Policies

---

## 📖 Table of Contents

### [1. IAM Fundamentals](./1-IAM-Fundamentals.md)
**Core Concepts and Architecture**

```
Topics Covered:
  • IAM model (Who, What, Where)
  • Members (users, groups, service accounts)
  • Roles (basic, predefined, custom)
  • Permissions structure
  • Policy hierarchy and inheritance
  • IAM policy anatomy
  • Resource hierarchy impact
```

**Key Concepts:**
- Identity types
- Role-based access control (RBAC)
- Policy binding
- Permission inheritance

---

### [2. IAM Roles](./2-IAM-Roles.md)
**Understanding and Using Roles**

```
Topics Covered:
  • Basic roles (Owner, Editor, Viewer)
  • Predefined roles (service-specific)
  • Custom roles (tailored permissions)
  • Role hierarchy
  • Role recommendations
  • Role management
  • Role testing and validation
```

**Key Concepts:**
- 3000+ predefined roles
- Custom role creation
- Role permissions
- Role lifecycle

---

### [3. Service Accounts](./3-Service-Accounts.md)
**Application Identity and Authentication**

```
Topics Covered:
  • Service account types
  • Creating and managing service accounts
  • Service account keys
  • Impersonation
  • Workload Identity (GKE)
  • Service account best practices
  • Key rotation and security
```

**Key Concepts:**
- Application authentication
- Key management
- Workload Identity Federation
- Service account impersonation

---

### [4. IAM Policies](./4-IAM-Policies.md)
**Policy Management and Binding**

```
Topics Covered:
  • Policy structure
  • Policy binding
  • Policy inheritance
  • Conditional access (IAM Conditions)
  • Policy troubleshooting
  • Policy analyzer
  • Bulk policy management
```

**Key Concepts:**
- Allow policies
- Deny policies (new)
- Policy evaluation
- Conditions and constraints

---

### [5. Least Privilege](./5-Least-Privilege.md)
**Security Best Practices**

```
Topics Covered:
  • Principle of least privilege
  • Permission boundaries
  • Just-in-time access
  • Temporary access grants
  • Access reviews
  • IAM Recommender
  • Security hardening
```

**Key Concepts:**
- Minimal permissions
- Time-bound access
- Regular audits
- Automated recommendations

---

### [6. Identity-Aware Proxy (IAP)](./6-Identity-Aware-Proxy.md)
**Application-Level Access Control**

```
Topics Covered:
  • IAP architecture
  • Enabling IAP
  • IAP for web applications
  • IAP for SSH/TCP
  • Context-aware access
  • IAP policies
  • Troubleshooting IAP
```

**Key Concepts:**
- Zero-trust security
- Context-aware access
- Application-level authentication
- BeyondCorp principles

---

### [7. Advanced IAM](./7-Advanced-IAM.md)
**Enterprise Features**

```
Topics Covered:
  • Workload Identity Federation
  • Organization policies
  • VPC Service Controls
  • Access Context Manager
  • Policy Intelligence
  • IAM Simulator
  • Audit logging
```

**Key Concepts:**
- External identity federation
- Policy enforcement
- Security perimeters
- Access analytics

---

### [8. Best Practices](./8-Best-Practices.md)
**Enterprise IAM Strategy**

```
Topics Covered:
  • IAM governance framework
  • Security hardening
  • Automation strategies
  • Compliance requirements
  • Incident response
  • Regular audits
  • Documentation
```

---

## 🔐 IAM Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP IAM Model                                 │
└─────────────────────────────────────────────────────────────────┘

WHO (Members)                    CAN DO WHAT (Roles)
┌──────────────────┐            ┌──────────────────┐
│ • Google Account │            │ • Basic Roles    │
│ • Google Group   │            │ • Predefined     │
│ • Service Account│────────────│ • Custom Roles   │
│ • Cloud Identity │            │                  │
│ • All Users      │            │ Contains:        │
│ • All Authd Users│            │ • Permissions    │
└──────────────────┘            └──────────────────┘
         │                               │
         │                               │
         └───────────┬───────────────────┘
                     │
                     ▼
              ON WHICH RESOURCE
            ┌──────────────────┐
            │ • Organization   │
            │ • Folder         │
            │ • Project        │
            │ • Resource       │
            └──────────────────┘

Example Policy Binding:
  Member: user:alice@company.com
  Role: roles/compute.instanceAdmin.v1
  Resource: projects/web-prod-2026
  
  Result: Alice can manage Compute Engine instances in web-prod-2026
```

---

## 🎯 IAM Policy Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  IAM Policy Anatomy                                              │
└─────────────────────────────────────────────────────────────────┘

{
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "user:alice@company.com",
        "group:devops@company.com",
        "serviceAccount:app@project.iam.gserviceaccount.com"
      ],
      "condition": {
        "title": "Expires in 2026",
        "description": "Temporary access",
        "expression": "request.time < timestamp('2026-12-31T23:59:59Z')"
      }
    },
    {
      "role": "roles/viewer",
      "members": [
        "group:everyone@company.com"
      ]
    }
  ],
  "etag": "BwXhFJ5H8nY=",
  "version": 3
}

Components:
  • bindings: Array of role assignments
  • role: The role being granted
  • members: Who gets the role
  • condition: Optional access constraints
  • etag: Concurrency control
  • version: Policy version (1 or 3)
```

---

## 💡 Key Concepts

### 1. IAM Hierarchy and Inheritance

```
┌────────────────────────────────────────────────────────┐
│  Policy Inheritance Flow                               │
└────────────────────────────────────────────────────────┘

Organization
├─ Policy: alice@company.com → Organization Viewer
│  └─→ Alice can view ALL resources in organization
│
Folder: Production
├─ Policy: bob@company.com → Folder Editor
│  └─→ Bob can edit ALL projects in Production folder
│
Project: web-prod
├─ Policy: charlie@company.com → Project Owner
│  └─→ Charlie has full control of web-prod project
│
Resource: VM Instance
├─ Policy: dave@company.com → Compute Instance Admin
│  └─→ Dave can manage THIS specific VM

Effective Permissions (Cumulative):
  • alice: Viewer on ALL resources (from org)
  • bob: Editor on Production projects (from folder)
  • charlie: Owner on web-prod (from project)
  • dave: Instance Admin on specific VM (from resource)

Rules:
  ✓ Permissions are ADDITIVE (union of all levels)
  ✓ Child inherits parent permissions
  ✓ Cannot remove inherited permissions
  ✓ More permissive wins
  ✗ Cannot deny inherited permissions (use Deny policies)
```

### 2. Member Types

```
┌────────────────────────────────────────────────────────┐
│  IAM Member Types                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  user:alice@company.com                                │
│  • Individual Google Account                           │
│  • Gmail or Cloud Identity                             │
│  • Human user                                          │
│                                                         │
│  group:developers@company.com                          │
│  • Google Group                                        │
│  • Manage multiple users together                      │
│  • Recommended for teams                               │
│                                                         │
│  serviceAccount:app@project.iam.gserviceaccount.com    │
│  • Application identity                                │
│  • Non-human account                                   │
│  • For workloads and automation                        │
│                                                         │
│  domain:company.com                                    │
│  • All users in a domain                               │
│  • Cloud Identity or Workspace                         │
│  • Organization-wide access                            │
│                                                         │
│  allUsers                                              │
│  • Anyone on the internet                              │
│  • Public access                                       │
│  • Use with extreme caution                            │
│                                                         │
│  allAuthenticatedUsers                                 │
│  • Any authenticated Google Account                    │
│  • Not limited to your organization                    │
│  • Use carefully                                       │
└────────────────────────────────────────────────────────┘
```

### 3. Role Types

```
┌────────────────────────────────────────────────────────┐
│  IAM Role Types                                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  BASIC ROLES (Legacy - Not Recommended)                │
│  ├─ Owner (roles/owner)                                │
│  │  • Full control including IAM and billing           │
│  │  • Can delete project                               │
│  ├─ Editor (roles/editor)                              │
│  │  • Modify resources                                 │
│  │  • Cannot manage IAM                                │
│  └─ Viewer (roles/viewer)                              │
│     • Read-only access                                 │
│     • Cannot modify anything                           │
│                                                         │
│  PREDEFINED ROLES (Recommended)                        │
│  ├─ Service-specific roles                             │
│  │  • roles/compute.instanceAdmin.v1                   │
│  │  • roles/storage.objectViewer                       │
│  │  • roles/bigquery.dataEditor                        │
│  ├─ Curated by Google                                  │
│  ├─ Regularly updated                                  │
│  └─ 3000+ roles available                              │
│                                                         │
│  CUSTOM ROLES (Advanced)                               │
│  ├─ Tailored permissions                               │
│  ├─ Organization or project level                      │
│  ├─ Combine specific permissions                       │
│  └─ Maintain and update yourself                       │
└────────────────────────────────────────────────────────┘
```

---

## 🔄 IAM Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Typical IAM Implementation Workflow                             │
└─────────────────────────────────────────────────────────────────┘

Step 1: Identify Requirements
┌─────────────────────────────────┐
│ • Who needs access?             │
│ • What do they need to do?      │
│ • Which resources?              │
│ • For how long?                 │
└────────────┬────────────────────┘
             │
             ▼
Step 2: Choose Appropriate Roles
┌─────────────────────────────────┐
│ • Use predefined roles first    │
│ • Create custom if needed       │
│ • Follow least privilege        │
│ • Document decisions            │
└────────────┬────────────────────┘
             │
             ▼
Step 3: Grant Access
┌─────────────────────────────────┐
│ • Use groups when possible      │
│ • Add IAM conditions if needed  │
│ • Set expiration dates          │
│ • Document grants               │
└────────────┬────────────────────┘
             │
             ▼
Step 4: Test Access
┌─────────────────────────────────┐
│ • Verify permissions work       │
│ • Test with actual user         │
│ • Check for over-permissions    │
│ • Use Policy Simulator          │
└────────────┬────────────────────┘
             │
             ▼
Step 5: Monitor and Review
┌─────────────────────────────────┐
│ • Regular access reviews        │
│ • Check IAM Recommender         │
│ • Audit logs monitoring         │
│ • Remove unused access          │
└─────────────────────────────────┘
```

---

## 🚀 Quick Start Guide

### Step 1: Grant User Access

```bash
# Grant Viewer role to user
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/viewer'

# Grant role to group (recommended)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='group:developers@company.com' \
  --role='roles/editor'

# Grant with condition (time-bound)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:contractor@company.com' \
  --role='roles/viewer' \
  --condition='expression=request.time < timestamp("2026-12-31T23:59:59Z"),title=Temporary Access'
```

### Step 2: Create Service Account

```bash
# Create service account
gcloud iam service-accounts create app-backend \
  --display-name="Backend Application" \
  --description="Service account for backend app"

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:app-backend@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectViewer'

# Create key (use Workload Identity instead when possible)
gcloud iam service-accounts keys create key.json \
  --iam-account=app-backend@PROJECT_ID.iam.gserviceaccount.com
```

### Step 3: Review Permissions

```bash
# List IAM policy for project
gcloud projects get-iam-policy PROJECT_ID

# Check what permissions a member has
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:alice@company.com"

# Test permissions
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.list,compute.instances.get
```

### Step 4: Use IAM Recommender

```bash
# List IAM recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global

# Apply recommendation
gcloud recommender recommendations mark-claimed \
  RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global
```

---

## 🛡️ Security Best Practices

### 1. Least Privilege Principle

```
┌────────────────────────────────────────────────────────┐
│  Implementing Least Privilege                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Start with minimal permissions                      │
│  ✓ Grant only what's needed                            │
│  ✓ Use predefined roles over basic roles               │
│  ✓ Create custom roles for specific needs              │
│  ✓ Regular permission reviews                          │
│  ✓ Remove unused permissions                           │
│  ✓ Use IAM Recommender                                 │
│  ✓ Implement time-bound access                         │
│  ✓ Use groups instead of individual users              │
│  ✓ Document permission rationale                       │
└────────────────────────────────────────────────────────┘

Example:
  ✗ Bad: Grant roles/editor to developer
  ✓ Good: Grant roles/compute.instanceAdmin.v1 to developer
  
  ✗ Bad: Grant roles/owner to service account
  ✓ Good: Grant specific roles like roles/storage.objectViewer
```

### 2. Service Account Security

```
┌────────────────────────────────────────────────────────┐
│  Service Account Best Practices                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Use Workload Identity (GKE)                         │
│  ✓ Avoid service account keys when possible            │
│  ✓ Rotate keys regularly (90 days)                     │
│  ✓ Use short-lived tokens                              │
│  ✓ One service account per application                 │
│  ✓ Descriptive service account names                   │
│  ✓ Monitor service account usage                       │
│  ✓ Disable unused service accounts                     │
│  ✓ Use service account impersonation                   │
│  ✓ Never commit keys to source control                 │
└────────────────────────────────────────────────────────┘
```

### 3. Access Reviews

```
┌────────────────────────────────────────────────────────┐
│  Regular Access Review Schedule                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Weekly:                                               │
│  • Review new access grants                            │
│  • Check IAM Recommender                               │
│  • Monitor unusual activity                            │
│                                                         │
│  Monthly:                                              │
│  • Review all project-level access                     │
│  • Remove temporary access                             │
│  • Update documentation                                │
│                                                         │
│  Quarterly:                                            │
│  • Full organization IAM audit                         │
│  • Review service accounts                             │
│  • Update custom roles                                 │
│  • Compliance review                                   │
│                                                         │
│  Annually:                                             │
│  • Complete IAM strategy review                        │
│  • Update policies and procedures                      │
│  • Security training                                   │
│  • Disaster recovery testing                           │
└────────────────────────────────────────────────────────┘
```

---

## 📊 IAM Monitoring

### Audit Logging

```bash
# Enable audit logs (via Console)
# IAM & Admin → Audit Logs → Configure

# Query IAM changes
gcloud logging read \
  'protoPayload.methodName=~"SetIamPolicy"' \
  --limit=50 \
  --format=json

# Query service account key creation
gcloud logging read \
  'protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"' \
  --limit=50

# Monitor permission changes
gcloud logging read \
  'resource.type="project" AND protoPayload.methodName=~"IAM"' \
  --limit=50
```

### IAM Recommender

```bash
# List recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global \
  --format="table(name,primaryImpact.category,stateInfo.state)"

# Get recommendation details
gcloud recommender recommendations describe RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global
```

---

## 🔧 Common IAM Patterns

### Pattern 1: Development Team Access

```
Group: developers@company.com
├─ Project: dev-project
│  └─ Role: roles/editor
├─ Project: staging-project
│  └─ Role: roles/viewer
└─ Project: prod-project
   └─ Role: roles/viewer (read-only)

Benefits:
  ✓ Developers have full access to dev
  ✓ Can view staging for debugging
  ✓ Read-only access to production
  ✓ Single group management
```

### Pattern 2: Application Service Account

```
Service Account: web-app@project.iam.gserviceaccount.com
├─ Storage: roles/storage.objectViewer
├─ Cloud SQL: roles/cloudsql.client
├─ Secret Manager: roles/secretmanager.secretAccessor
└─ Pub/Sub: roles/pubsub.publisher

Benefits:
  ✓ Minimal permissions
  ✓ Service-specific roles
  ✓ No overly broad access
  ✓ Easy to audit
```

### Pattern 3: Temporary Contractor Access

```
User: contractor@external.com
├─ Role: roles/compute.viewer
├─ Condition: Expires 2026-12-31
└─ Project: specific-project-only

Benefits:
  ✓ Time-bound access
  ✓ Limited scope
  ✓ Automatic expiration
  ✓ No manual cleanup needed
```

---

## 🛠️ Tools & Resources

### GCP Native Tools

```
• IAM Console
• Policy Simulator
• Policy Analyzer
• IAM Recommender
• Policy Troubleshooter
• Access Context Manager
• VPC Service Controls
• Cloud Asset Inventory
```

### Third-Party Tools

```
• Terraform (IaC)
• Pulumi (IaC)
• CloudQuery (inventory)
• ScalR (governance)
• Forseti Security (deprecated, use SCC)
```

---

## ✅ IAM Checklist

### Initial Setup
- [ ] Enable Cloud Identity or Google Workspace
- [ ] Create organization structure
- [ ] Define IAM governance policy
- [ ] Create groups for teams
- [ ] Document role assignments
- [ ] Enable audit logging

### Ongoing Management
- [ ] Regular access reviews (monthly)
- [ ] Monitor IAM Recommender
- [ ] Rotate service account keys
- [ ] Remove unused access
- [ ] Update documentation
- [ ] Security training for team

### Security Hardening
- [ ] Enforce MFA for all users
- [ ] Use groups instead of individual users
- [ ] Implement least privilege
- [ ] Use IAM conditions
- [ ] Enable VPC Service Controls
- [ ] Monitor audit logs
- [ ] Incident response plan

---

## 🎓 Next Steps

After mastering IAM:

1. **Networking** - VPC and security
2. **Compute Services** - Secure workload deployment
3. **Storage & Databases** - Data access control
4. **Security** - Advanced security features
5. **Compliance** - Regulatory requirements

---

**Last Updated:** March 2026
**Version:** 2.0
