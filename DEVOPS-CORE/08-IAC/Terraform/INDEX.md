# 📚 Terraform Documentation Index

Complete guide for Terraform Associate 004 Certification

---

## 🎯 Quick Start

- [Terraform Associate 004 Cheat Sheet](./TERRAFORM-ASSOCIATE-004-CHEAT-SHEET.md) - Complete exam reference

---

## 📖 Core Concepts

### 1. Infrastructure as Code
- [IaC Concepts](./01-IaC-Concepts/README.md)
  - Declarative vs Imperative
  - Idempotency
  - Day 0 vs Day 1+
  - Immutable vs Mutable Infrastructure

### 2. Core Workflow
- [Workflow Commands](./02-Core-Workflow/README.md)
  - terraform init
  - terraform plan
  - terraform apply
  - terraform destroy
- [Complete Workflow Guide](./02-Core-Workflow/workflow-commands.md)
- [Examples](./02-Core-Workflow/examples/)

### 3. HCL Configuration
- [Configuration Syntax](./03-HCL-Configuration/README.md)
  - Resource blocks
  - Data sources
  - Variables
  - Outputs
- [Meta-Arguments](./03-HCL-Configuration/meta-arguments.md)
  - count
  - for_each
  - depends_on
  - provider
- [Lifecycle](./03-HCL-Configuration/lifecycle.md)
  - create_before_destroy
  - prevent_destroy
  - ignore_changes
- [Variable Types](./03-HCL-Configuration/variable-types.md)

### 4. State Management
- [State Overview](./04-State-Management/README.md)
  - terraform.tfstate
  - State commands
  - Remote state
- [Backends](./04-State-Management/backends.md)
  - S3
  - GCS
  - Azure
  - Terraform Cloud

### 5. Providers & Registry
- [Providers](./05-Providers-Registry/README.md)
  - Provider configuration
  - Version constraints
  - Provider aliases
  - .terraform.lock.hcl

### 6. Modules
- [Module Basics](./06-Modules/README.md)
  - Creating modules
  - Using modules
  - Module inputs/outputs
- [Module Sources](./06-Modules/module-sources.md)
  - Local paths
  - Terraform Registry
  - GitHub
  - Git
  - S3/GCS

### 7. Built-in Functions
- [Functions Reference](./07-Functions/README.md)
  - String functions
  - Collection functions
  - Filesystem functions
  - Network functions

### 8. Expressions & Loops
- [Expressions](./08-Expressions-Loops/README.md)
  - Conditional expressions
  - For expressions
  - Splat expressions
  - Dynamic blocks

### 9. Workspaces
- [Workspaces Guide](./09-Workspaces/README.md)
  - Creating workspaces
  - Switching workspaces
  - Using terraform.workspace
  - Environment-specific configs

### 10. Best Practices
- [Best Practices](./10-Best-Practices/README.md)
  - Project structure
  - Naming conventions
  - State management
  - Security practices

### 11. Terraform Cloud & Enterprise
- [Terraform Cloud](./15-Terraform-Cloud/README.md)
  - Remote state & execution
  - VCS integration
  - Workspaces
  - Sentinel policies
  - Cost estimation
  - Private registry
  - Agent pools

### 12. Security Best Practices
- [Security Guide](./16-Security-Best-Practices/README.md)
  - Sensitive data management
  - Secret management
  - State file security
  - IAM and access control
  - Encryption
  - Compliance and auditing

---

## 🎓 Exam Preparation

### Exam Objectives by Weight

| Domain | Weight | Topics |
|--------|--------|--------|
| **Terraform Basics** | 32% | Commands, HCL, Resources |
| **Terraform Cloud** | 25% | Workspaces, Remote state, VCS |
| **IaC Concepts** | 16% | Declarative, Idempotent, Immutable |
| **Terraform State** | 16% | State files, Backends, Locking |
| **Terraform's Purpose** | 9% | Benefits, Use cases |
| **Advanced Concepts** | 2% | Complex scenarios |

### Study Path

1. **Week 1-2:** Core Concepts & Workflow
   - IaC fundamentals
   - Basic commands (init, plan, apply)
   - HCL syntax

2. **Week 3-4:** Configuration & State
   - Variables and outputs
   - Meta-arguments
   - State management
   - Remote backends

3. **Week 5-6:** Advanced Topics
   - Modules
   - Functions
   - Workspaces
   - Terraform Cloud

4. **Week 7-8:** Practice & Review
   - Hands-on labs
   - Practice exams
   - Review cheat sheet

---

## 🔗 Quick Links

### Official Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

### Community
- [Terraform GitHub](https://github.com/hashicorp/terraform)
- [Terraform Discuss](https://discuss.hashicorp.com/c/terraform-core)

---

## 📝 Exam Tips

### Before the Exam
- ✅ Review the cheat sheet thoroughly
- ✅ Practice with hands-on labs
- ✅ Understand command differences (deprecated vs current)
- ✅ Know variable precedence order
- ✅ Memorize version constraint operators

### During the Exam
- 📖 Read questions carefully
- 🎯 Look for keywords: "best practice", "recommended"
- ⚠️ Watch for deprecated command traps
- 🔍 Eliminate obviously wrong answers
- ⏰ Manage your time (57 questions in 60 minutes)

### Common Traps
- `terraform taint` → Use `terraform apply -replace`
- `terraform refresh` → Use `terraform apply -refresh-only`
- `count` vs `for_each` → Prefer `for_each` for stability
- Backend config → Not shown in plan output
- CLI workspaces ≠ TFC workspaces

---

## 🚀 Getting Started

```bash
# 1. Install Terraform
# Download from: https://www.terraform.io/downloads

# 2. Verify installation
terraform version

# 3. Create your first configuration
mkdir my-terraform-project
cd my-terraform-project

# 4. Create main.tf
cat > main.tf <<EOF
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "HelloTerraform"
  }
}
EOF

# 5. Initialize
terraform init

# 6. Plan
terraform plan

# 7. Apply
terraform apply
```

---

**Good luck with your Terraform Associate 004 certification! 🎉**
