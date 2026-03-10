# ☁️ Terraform Cloud & Enterprise

**Exam Weight: 25%** - This is a major exam topic!

---

## What is Terraform Cloud?

Terraform Cloud is HashiCorp's SaaS platform for team collaboration, remote state management, and policy enforcement.

```
┌────────────────────────────────────────────────────┐
│  Terraform Cloud Architecture                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  Developer → VCS (GitHub) → Terraform Cloud       │
│                                  ↓                 │
│                            Remote Execution        │
│                                  ↓                 │
│                            Cloud Provider          │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Key Features

### 1. Remote State Management
- Automatic state storage
- State versioning and history
- State locking (automatic)
- Encryption at rest

### 2. Remote Execution
- Runs execute in Terraform Cloud infrastructure
- Consistent environment
- No local dependencies needed
- Parallel execution support

### 3. VCS Integration
- GitHub, GitLab, Bitbucket, Azure DevOps
- Automatic runs on commit
- Pull request integration
- Branch-based workflows

### 4. Workspaces
- Isolated environments
- Separate state per workspace
- Variable management
- Run history

### 5. Policy as Code (Sentinel)
- Enforce compliance rules
- Cost estimation
- Security policies
- Custom policies

---

## Terraform Cloud vs Terraform Enterprise

| Feature | Terraform Cloud | Terraform Enterprise |
|---------|----------------|---------------------|
| **Hosting** | SaaS (HashiCorp) | Self-hosted |
| **State Management** | ✅ | ✅ |
| **Remote Runs** | ✅ | ✅ |
| **VCS Integration** | ✅ | ✅ |
| **Sentinel Policies** | Team & Governance | ✅ |
| **SSO (SAML)** | Team & Governance | ✅ |
| **Audit Logging** | Limited | Full |
| **Air-gapped** | ❌ | ✅ |
| **Private Network** | ❌ | ✅ |
| **Cost** | Free tier available | License required |

---

## Terraform Cloud Pricing Tiers

### Free Tier
- Up to 5 users
- Remote state storage
- Remote execution
- VCS integration
- Community support

### Team & Governance
- Team management
- Sentinel policies
- Cost estimation
- SSO (SAML)
- Run tasks
- Priority support

### Business (Enterprise)
- Self-hosted option
- Audit logging
- Private network connectivity
- Clustering
- Custom support SLA

---

## Configuring Terraform Cloud

### 1. Cloud Block Configuration

```hcl
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

### 2. Multiple Workspaces

```hcl
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      tags = ["networking", "production"]
    }
  }
}
```

### 3. Authentication

```bash
# Login to Terraform Cloud
terraform login

# Manual token configuration
# Create ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR_TOKEN_HERE"
    }
  }
}
```

---

## Workspaces in Terraform Cloud

### CLI Workspaces vs TFC Workspaces

```
┌────────────────────────────────────────────────────┐
│  CLI Workspaces                                    │
├────────────────────────────────────────────────────┤
│  • Same configuration                              │
│  • Different state files                           │
│  • Local or remote backend                         │
│  • Simple environment separation                   │
└────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│  Terraform Cloud Workspaces                        │
├────────────────────────────────────────────────────┤
│  • Separate configurations possible                │
│  • Separate variables                              │
│  • Separate permissions                            │
│  • VCS integration                                 │
│  • Run history                                     │
│  • Cost estimation                                 │
│  • Policy enforcement                              │
└────────────────────────────────────────────────────┘
```

### Workspace Settings

**Execution Mode:**
- Remote - Runs in Terraform Cloud
- Local - Runs on local machine, state in TFC
- Agent - Runs on self-hosted agent

**Auto Apply:**
- Enabled - Automatically applies after plan
- Disabled - Requires manual approval

---

## VCS-Driven Workflow

```
┌────────────────────────────────────────────────────┐
│  VCS-Driven Workflow                               │
└────────────────────────────────────────────────────┘

1. Developer commits code to Git
        ↓
2. Terraform Cloud detects change
        ↓
3. Automatic terraform plan
        ↓
4. Team reviews plan
        ↓
5. Manual or auto apply
        ↓
6. Infrastructure updated
```

### Configuration

```hcl
# In Terraform Cloud UI:
# 1. Connect VCS provider
# 2. Select repository
# 3. Configure working directory
# 4. Set auto-apply (optional)
```

---

## Variables in Terraform Cloud

### Variable Types

**Terraform Variables:**
```hcl
variable "region" {
  type = string
}
```

**Environment Variables:**
```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
TF_LOG
```

### Variable Precedence

1. Workspace variables (highest)
2. Variable sets
3. Default values in code (lowest)

### Sensitive Variables

```
Mark as sensitive in UI:
☑ Sensitive
```

---

## Sentinel Policy as Code

### What is Sentinel?

Policy as code framework for governance and compliance.

### Policy Types

**Advisory** - Warning only, doesn't block
**Soft Mandatory** - Can be overridden by authorized users
**Hard Mandatory** - Cannot be overridden

### Example Policy

```hcl
# Require tags on all resources
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.change.after.tags contains "Environment" and
    rc.change.after.tags contains "Owner"
  }
}
```

---

## Cost Estimation

Terraform Cloud can estimate infrastructure costs before apply.

**Supported Providers:**
- AWS
- Azure
- Google Cloud

**Features:**
- Cost per resource
- Monthly estimates
- Cost delta (change from current)
- Historical cost tracking

---

## Run Tasks

Integrate external systems into Terraform workflow.

**Use Cases:**
- Security scanning
- Compliance checks
- Custom validations
- Notifications

**Stages:**
- Pre-plan
- Post-plan
- Pre-apply (Enterprise)

---

## Private Registry

Host private modules and providers.

### Publishing a Module

```hcl
# Module source in private registry
module "vpc" {
  source  = "app.terraform.io/my-org/vpc/aws"
  version = "1.0.0"
}
```

### Benefits
- Version control
- Access control
- Module documentation
- Configuration designer

---

## Agent Pools

Self-hosted runners for Terraform Cloud.

**Use Cases:**
- Private network access
- Custom tools/dependencies
- Compliance requirements
- Air-gapped environments

**Configuration:**

```bash
# Start agent
terraform-agent run \
  -token="$AGENT_TOKEN" \
  -name="my-agent"
```

---

## API-Driven Workflow

Terraform Cloud provides full REST API.

### Example: Trigger Run

```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @payload.json \
  https://app.terraform.io/api/v2/runs
```

---

## Best Practices

### ✅ DO

- Use VCS integration for GitOps workflow
- Enable Sentinel policies for governance
- Use variable sets for shared variables
- Implement RBAC with teams
- Enable cost estimation
- Use private registry for modules
- Configure notifications
- Regular state backups

### ❌ DON'T

- Store secrets in VCS
- Use local execution for production
- Skip policy enforcement
- Share workspace access broadly
- Ignore cost estimates
- Manual state manipulation

---

## Exam Tips

### Key Concepts to Remember

1. **Terraform Cloud ≠ CLI Workspaces**
   - Different features and capabilities
   - TFC workspaces are more powerful

2. **Execution Modes**
   - Remote (default)
   - Local
   - Agent

3. **Sentinel Policy Levels**
   - Advisory
   - Soft Mandatory
   - Hard Mandatory

4. **VCS Integration**
   - Automatic runs on commit
   - Pull request workflows
   - Branch-based environments

5. **Cost Estimation**
   - Available in Team & Governance tier
   - Pre-apply cost analysis
   - Supports AWS, Azure, GCP

6. **State Management**
   - Automatic locking
   - Version history
   - Encryption at rest

---

## Common Exam Questions

**Q: What's the difference between Terraform Cloud and Terraform Enterprise?**
A: Terraform Cloud is SaaS; Enterprise is self-hosted with additional features like air-gap support and full audit logging.

**Q: Can you use Terraform Cloud for free?**
A: Yes, free tier supports up to 5 users with remote state and execution.

**Q: What are Sentinel policies?**
A: Policy as code for governance, available in Team & Governance tier.

**Q: How does VCS integration work?**
A: Terraform Cloud monitors VCS repository and automatically runs plan/apply on commits.

**Q: What is an agent pool?**
A: Self-hosted runners that execute Terraform runs in your infrastructure.

---

## Summary

Terraform Cloud provides:
- ✅ Remote state management
- ✅ Team collaboration
- ✅ VCS integration
- ✅ Policy enforcement
- ✅ Cost estimation
- ✅ Private registry
- ✅ Audit logging (Enterprise)
- ✅ Air-gap support (Enterprise)

**Remember:** This topic is 25% of the exam - make sure you understand the differences between Terraform Cloud and Enterprise, workspace concepts, and key features!
