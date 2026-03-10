# 🏗️ Infrastructure as Code (IaC) Concepts

## Overview

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

---

## Core Concepts

### 1. Infrastructure as Code (IaC)

**Definition:** Manage & provision infrastructure via machine-readable config files instead of manual processes.

**Benefits:**
- ✅ Version control for infrastructure
- ✅ Reproducible environments
- ✅ Automated provisioning
- ✅ Reduced human error
- ✅ Documentation as code

```
Traditional Approach          IaC Approach
─────────────────            ─────────────
Manual clicks in UI    →     Code in version control
Inconsistent setups    →     Reproducible deployments
Hard to track changes  →     Full audit trail
Slow provisioning      →     Automated & fast
```

---

## Declarative vs Imperative

### Declarative (Terraform's Approach)

You define **WHAT** the end state should be; Terraform figures out **HOW** to get there.

```hcl
# Declarative - You describe the desired state
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  count         = 3
  
  tags = {
    Name = "web-server"
  }
}
```

**Terraform automatically:**
- Creates 3 instances if none exist
- Updates instances if configuration changes
- Destroys extra instances if count is reduced
- Does nothing if state matches desired state

### Imperative (Traditional Scripting)

You define **HOW** to achieve the result step-by-step.

```bash
# Imperative - You describe the steps
for i in 1 2 3; do
  aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t2.micro \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=web-server-$i}]"
done
```

**You must handle:**
- Checking if instances already exist
- Updating existing instances
- Cleaning up old instances
- Error handling at each step

---

## Idempotency

**Definition:** Running the same configuration multiple times always produces the same result.

```
┌─────────────────────────────────────────────────────────┐
│  Idempotent Behavior                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Run 1: terraform apply → Creates 3 instances          │
│  Run 2: terraform apply → No changes (already exists)  │
│  Run 3: terraform apply → No changes (already exists)  │
│                                                         │
│  ✅ Safe to run multiple times                         │
│  ✅ No duplicate resources created                     │
│  ✅ Predictable outcomes                               │
└─────────────────────────────────────────────────────────┘
```

### Example: Idempotent Configuration

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-unique-bucket-name"
  
  tags = {
    Environment = "Production"
  }
}

# First apply: Creates bucket
# Second apply: No changes
# Third apply: No changes
# If bucket exists outside Terraform: Import it, then no changes
```

---

## Infrastructure Lifecycle

### Day 0 - Initial Provisioning

**Definition:** Initial provisioning of brand-new infrastructure.

```
┌──────────────────────────────────────────────────┐
│  Day 0: Initial Setup                            │
├──────────────────────────────────────────────────┤
│                                                  │
│  1. Write Terraform configuration                │
│  2. terraform init                               │
│  3. terraform plan                               │
│  4. terraform apply                              │
│                                                  │
│  Result: Infrastructure created from scratch     │
└──────────────────────────────────────────────────┘
```

**Example:**

```hcl
# Day 0: Creating initial infrastructure
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "public-subnet"
  }
}
```

### Day 1+ - Ongoing Maintenance

**Definition:** Ongoing changes and maintenance of existing infrastructure.

```
┌──────────────────────────────────────────────────┐
│  Day 1+: Ongoing Operations                      │
├──────────────────────────────────────────────────┤
│                                                  │
│  • Scaling resources up/down                     │
│  • Updating configurations                       │
│  • Adding new resources                          │
│  • Removing deprecated resources                 │
│  • Security patches                              │
│  • Cost optimization                             │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Example:**

```hcl
# Day 1+: Scaling and updating
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.small"  # Changed from t2.micro
  count         = 5            # Scaled from 3 to 5
  
  tags = {
    Name        = "web-server"
    Environment = "production"  # Added new tag
  }
}
```

---

## Immutable vs Mutable Infrastructure

### Immutable Infrastructure (Terraform's Approach)

**Definition:** Replace resources when changes are needed instead of modifying them in-place.

```
┌─────────────────────────────────────────────────────────┐
│  Immutable Infrastructure Pattern                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Old Server (v1.0)          New Server (v1.1)          │
│  ┌──────────────┐          ┌──────────────┐           │
│  │   Running    │          │   Creating   │           │
│  │   App v1.0   │   →      │   App v1.1   │           │
│  └──────────────┘          └──────────────┘           │
│         ↓                          ↓                   │
│    Terminate                   Running                 │
│                                                         │
│  ✅ No configuration drift                             │
│  ✅ Predictable deployments                            │
│  ✅ Easy rollback                                      │
└─────────────────────────────────────────────────────────┘
```

**Example:**

```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-"
  image_id      = "ami-new-version"  # New AMI
  instance_type = "t2.micro"
  
  # When this changes, new instances are created
  # Old instances are terminated
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "App Version 2.0"
  EOF
  )
}

resource "aws_autoscaling_group" "app" {
  desired_capacity = 3
  max_size         = 5
  min_size         = 1
  
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  # Rolling update strategy
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
```

### Mutable Infrastructure (Traditional Approach)

**Definition:** Update resources in-place without replacement.

```
┌─────────────────────────────────────────────────────────┐
│  Mutable Infrastructure Pattern                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Server (v1.0)              Server (v1.1)              │
│  ┌──────────────┐          ┌──────────────┐           │
│  │   Running    │          │   Running    │           │
│  │   App v1.0   │   →      │   App v1.1   │           │
│  └──────────────┘          └──────────────┘           │
│         ↓                          ↓                   │
│    Update in-place            Same server              │
│                                                         │
│  ⚠️ Configuration drift possible                       │
│  ⚠️ Harder to rollback                                 │
│  ⚠️ Inconsistent states                                │
└─────────────────────────────────────────────────────────┘
```

---

## IaC Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Terraform IaC Workflow                       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  Write Code  │  ← Define infrastructure in .tf files
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Version      │  ← Commit to Git (version control)
    │ Control      │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ terraform    │  ← Initialize & download providers
    │ init         │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ terraform    │  ← Preview changes
    │ plan         │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Review       │  ← Human review of planned changes
    │ Changes      │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ terraform    │  ← Apply changes to infrastructure
    │ apply        │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Infrastructure│ ← Real cloud resources created/updated
    │ Updated      │
    └──────────────┘
```

---

## Benefits of IaC with Terraform

### 1. Version Control
```
Git History
───────────
commit abc123: Add production VPC
commit def456: Scale web servers to 5
commit ghi789: Update security groups
commit jkl012: Add RDS database
```

### 2. Collaboration
```
Team Workflow
─────────────
Developer A: Creates feature branch
Developer B: Reviews pull request
Developer C: Approves changes
CI/CD: Automatically applies to staging
Team Lead: Promotes to production
```

### 3. Disaster Recovery
```
Disaster Recovery
─────────────────
Problem: Region failure
Solution: terraform apply in new region
Result: Identical infrastructure in minutes
```

### 4. Multi-Environment Management
```hcl
# Same code, different environments
module "infrastructure" {
  source = "./modules/infra"
  
  environment = var.environment  # dev, staging, prod
  instance_count = var.environment == "prod" ? 10 : 2
  instance_type  = var.environment == "prod" ? "t2.large" : "t2.micro"
}
```

---

## Best Practices

### ✅ DO
- Use version control for all Terraform code
- Write modular, reusable configurations
- Use remote state with locking
- Implement proper naming conventions
- Document your infrastructure code
- Use workspaces or separate state files for environments
- Run `terraform plan` before `apply`
- Use `.gitignore` for sensitive files

### ❌ DON'T
- Store state files in version control
- Hardcode credentials in configurations
- Make manual changes to managed resources
- Skip the plan step
- Use `terraform apply -auto-approve` in production
- Share state files without locking
- Ignore Terraform warnings

---

## Real-World Example: Complete Infrastructure

```hcl
# Complete example showing IaC principles
terraform {
  required_version = ">= 1.0"
  
  # Remote state (collaboration)
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Provider configuration
provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = "MyApp"
    }
  }
}

# Variables (parameterization)
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Declarative resource definition
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Outputs (documentation & integration)
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

---

## Summary

| Concept | Description | Terraform Approach |
|---------|-------------|-------------------|
| **IaC** | Infrastructure as code | ✅ Full support |
| **Declarative** | Define desired state | ✅ Core principle |
| **Idempotent** | Safe to run multiple times | ✅ Built-in |
| **Day 0** | Initial provisioning | ✅ Supported |
| **Day 1+** | Ongoing maintenance | ✅ Supported |
| **Immutable** | Replace vs update | ✅ Default behavior |

---

## Next Steps

- [Core Workflow Commands](../02-Core-Workflow/README.md)
- [HCL Configuration Syntax](../03-HCL-Configuration/README.md)
- [State Management](../04-State-Management/README.md)
