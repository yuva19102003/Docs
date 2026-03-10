# 📚 Terraform Associate 004 - Complete Study Guide

## Exam Overview

**Format:**
- 57 Questions
- 60 Minutes (just over 1 minute per question)
- 70% to Pass (40 correct answers needed)
- Multiple Choice & Multiple Select
- Online Proctored

**Cost:** $70.50 USD

**Validity:** 2 years

---

## Exam Domains & Weights

| Domain | Weight | Questions (approx) |
|--------|--------|-------------------|
| **Terraform Basics** | 32% | ~18 questions |
| **Terraform Cloud** | 25% | ~14 questions |
| **IaC Concepts** | 16% | ~9 questions |
| **Terraform State** | 16% | ~9 questions |
| **Terraform's Purpose** | 9% | ~5 questions |
| **Advanced Concepts** | 2% | ~1 question |

---

## Study Plan (8 Weeks)

### Week 1-2: Foundations
**Focus:** IaC Concepts & Terraform Basics (48% of exam)

**Topics to Master:**
- [ ] What is Infrastructure as Code
- [ ] Declarative vs Imperative
- [ ] Idempotency concept
- [ ] Day 0 vs Day 1+ operations
- [ ] Immutable vs Mutable infrastructure
- [ ] Terraform workflow (init, plan, apply, destroy)
- [ ] HCL syntax basics
- [ ] Resource and data blocks
- [ ] Variables and outputs

**Practice:**
```bash
# Install Terraform
terraform version

# Create first configuration
# Practice init, plan, apply cycle
# Experiment with variables
```

**Resources:**
- [IaC Concepts](../01-IaC-Concepts/README.md)
- [Core Workflow](../02-Core-Workflow/README.md)
- [HCL Configuration](../03-HCL-Configuration/README.md)

---

### Week 3-4: State & Configuration
**Focus:** State Management & Advanced HCL (32% of exam)

**Topics to Master:**
- [ ] Terraform state file purpose
- [ ] Local vs remote state
- [ ] State locking mechanisms
- [ ] Backend types (S3, GCS, Azure, TFC)
- [ ] State commands (list, show, mv, rm)
- [ ] Meta-arguments (count, for_each, depends_on)
- [ ] Lifecycle blocks
- [ ] Variable types and precedence
- [ ] Sensitive values

**Practice:**
```bash
# Configure remote backend
# Practice state commands
# Use count and for_each
# Implement lifecycle rules
```

**Resources:**
- [State Management](../04-State-Management/README.md)
- [Meta-Arguments](../03-HCL-Configuration/meta-arguments.md)
- [Lifecycle](../03-HCL-Configuration/lifecycle.md)

---

### Week 5-6: Terraform Cloud & Modules
**Focus:** Terraform Cloud (25% of exam)

**Topics to Master:**
- [ ] Terraform Cloud vs Enterprise
- [ ] Remote execution modes
- [ ] VCS-driven workflows
- [ ] Workspaces (CLI vs TFC)
- [ ] Sentinel policies
- [ ] Cost estimation
- [ ] Private registry
- [ ] Agent pools
- [ ] Module creation and usage
- [ ] Module sources

**Practice:**
```bash
# Create TFC account (free tier)
# Configure cloud block
# Create workspace
# Connect to VCS
# Publish module to private registry
```

**Resources:**
- [Terraform Cloud](../15-Terraform-Cloud/README.md)
- [Modules](../06-Modules/README.md)
- [Workspaces](../09-Workspaces/README.md)

---

### Week 7: Advanced Topics
**Focus:** Functions, Expressions, Security

**Topics to Master:**
- [ ] Built-in functions (string, collection, network)
- [ ] Conditional expressions
- [ ] For expressions
- [ ] Dynamic blocks
- [ ] Splat expressions
- [ ] Sensitive data handling
- [ ] Secret management
- [ ] Provider configuration
- [ ] Version constraints

**Practice:**
```bash
# Use functions in configurations
# Create dynamic blocks
# Implement security best practices
```

**Resources:**
- [Functions](../07-Functions/README.md)
- [Expressions & Loops](../08-Expressions-Loops/README.md)
- [Security](../16-Security-Best-Practices/README.md)
- [Providers](../05-Providers-Registry/README.md)

---

### Week 8: Review & Practice
**Focus:** Exam preparation and practice

**Activities:**
- [ ] Review cheat sheet daily
- [ ] Take practice exams
- [ ] Review interview questions
- [ ] Troubleshoot common issues
- [ ] Memorize key commands
- [ ] Understand exam traps

**Resources:**
- [Exam Cheat Sheet](../TERRAFORM-ASSOCIATE-004-CHEAT-SHEET.md)
- [Interview Questions](../14-Interview-Questions/README.md)
- [Troubleshooting](../13-Troubleshooting/README.md)

---

## Key Concepts to Memorize

### Commands (Must Know)

```bash
# Initialization
terraform init
terraform init -upgrade
terraform init -reconfigure

# Planning
terraform plan
terraform plan -out=tfplan

# Applying
terraform apply
terraform apply -auto-approve
terraform apply -replace=ADDR

# State Management
terraform state list
terraform state show ADDR
terraform state mv SRC DST
terraform state rm ADDR

# Other
terraform fmt
terraform validate
terraform output
terraform workspace list/new/select
```

### Deprecated Commands (Exam Traps!)

| Deprecated | Use Instead |
|------------|-------------|
| `terraform taint` | `terraform apply -replace=ADDR` |
| `terraform refresh` | `terraform apply -refresh-only` |

### Variable Precedence (Low to High)

1. Default value in variable block
2. `terraform.tfvars`
3. `*.auto.tfvars` (alphabetical)
4. `-var-file` flag
5. `-var` flag
6. `TF_VAR_name` environment variable ← **HIGHEST**

### Version Constraints

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Exact | `= 1.0.0` |
| `>=` | Greater or equal | `>= 1.0.0` |
| `~>` | Pessimistic | `~> 1.0` (allows 1.x, not 2.0) |
| `!=` | Not equal | `!= 1.2.0` |

### Meta-Arguments

- `count` - Numeric iteration (fragile)
- `for_each` - Map/set iteration (stable) ← **PREFERRED**
- `depends_on` - Explicit dependencies
- `provider` - Alternate provider
- `lifecycle` - Resource behavior control

### Lifecycle Options

- `create_before_destroy = true` - Zero downtime
- `prevent_destroy = true` - Block destruction
- `ignore_changes = [list]` - Ignore attribute changes
- `replace_triggered_by = [list]` - Force replacement

---

## Exam Tips & Strategies

### During the Exam

**Time Management:**
- 60 minutes ÷ 57 questions = ~1 minute per question
- Flag difficult questions and return later
- Don't spend more than 2 minutes on any question

**Reading Questions:**
- Read carefully - look for keywords
- "Best practice" = HashiCorp's recommended way
- "Most secure" = encryption, least privilege
- "Most efficient" = fewer resources, simpler config

**Common Keywords:**
- "Recommended" → Official HashiCorp guidance
- "Deprecated" → Old commands (taint, refresh)
- "Best practice" → Security, efficiency, maintainability
- "Required" → Mandatory configuration
- "Optional" → Can be omitted

### Common Traps

**1. CLI Workspaces vs TFC Workspaces**
- Different concepts!
- CLI: Same config, different state
- TFC: Full isolation, more features

**2. count vs for_each**
- `count` uses index (0, 1, 2...)
- `for_each` uses keys (stable)
- Prefer `for_each` for production

**3. Backend Configuration**
- Not shown in `terraform plan` output
- Requires `terraform init` to change
- Cannot use variables in backend block

**4. State File Security**
- Contains sensitive data
- Always encrypt
- Never commit to Git

**5. Provider Versions**
- `~> 1.0` allows 1.x, not 2.0
- `.terraform.lock.hcl` must be committed
- Use `-upgrade` to update providers

---

## Practice Questions

### Question 1
**What command should you use to force replacement of a resource?**

A. `terraform taint aws_instance.web`  
B. `terraform apply -replace=aws_instance.web`  
C. `terraform destroy -target=aws_instance.web`  
D. `terraform refresh aws_instance.web`

**Answer:** B - `terraform taint` is deprecated

---

### Question 2
**Which backend supports state locking?**

A. Local  
B. S3 with DynamoDB  
C. HTTP  
D. All of the above

**Answer:** B - S3 requires DynamoDB for locking

---

### Question 3
**What is the highest precedence for variable values?**

A. terraform.tfvars  
B. -var flag  
C. TF_VAR_name environment variable  
D. Default value in variable block

**Answer:** C - Environment variables have highest precedence

---

### Question 4
**Which is true about Terraform Cloud workspaces?**

A. Same as CLI workspaces  
B. Only store state differently  
C. Have separate variables and permissions  
D. Cannot integrate with VCS

**Answer:** C - TFC workspaces are more feature-rich

---

### Question 5
**What does `~> 1.2.0` allow?**

A. 1.2.x only  
B. 1.x.x  
C. 2.x.x  
D. Any version

**Answer:** A - Allows 1.2.x, not 1.3.0

---

## Final Checklist

### One Week Before Exam

- [ ] Review cheat sheet daily
- [ ] Understand all exam domains
- [ ] Practice with hands-on labs
- [ ] Memorize key commands
- [ ] Understand deprecated commands
- [ ] Know variable precedence
- [ ] Understand version constraints
- [ ] Review Terraform Cloud features

### Day Before Exam

- [ ] Light review only
- [ ] Get good sleep
- [ ] Prepare exam environment
- [ ] Test webcam and microphone
- [ ] Clear desk area
- [ ] Have ID ready

### Exam Day

- [ ] Arrive 15 minutes early
- [ ] Read questions carefully
- [ ] Flag difficult questions
- [ ] Manage time wisely
- [ ] Review flagged questions
- [ ] Stay calm and confident

---

## Additional Resources

### Official HashiCorp

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Exam Review Guide](https://learn.hashicorp.com/tutorials/terraform/associate-review)

### Practice

- HashiCorp Learn Tutorials
- Terraform Registry Examples
- GitHub Terraform Examples
- Local lab environment

### Community

- [Terraform Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [Terraform GitHub](https://github.com/hashicorp/terraform)
- Reddit r/Terraform
- Stack Overflow

---

## Success Tips

1. **Hands-on Practice** - Theory alone isn't enough
2. **Understand Concepts** - Don't just memorize
3. **Read Documentation** - Official docs are best
4. **Time Management** - Practice with timer
5. **Stay Updated** - Terraform evolves quickly
6. **Join Community** - Learn from others
7. **Build Projects** - Real-world experience helps
8. **Review Mistakes** - Learn from errors

---

**Good luck with your Terraform Associate 004 certification! 🚀**

Remember: The exam tests practical knowledge. If you can use Terraform effectively in real projects, you'll pass the exam!
