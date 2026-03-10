# 🎯 Terraform Interview Questions

## Basic Level Questions

### 1. What is Terraform?

**Answer:** Terraform is an open-source Infrastructure as Code (IaC) tool developed by HashiCorp. It allows you to define and provision infrastructure using a declarative configuration language (HCL). Terraform manages infrastructure across multiple cloud providers and on-premises environments.

**Key Points:**
- Declarative approach
- Multi-cloud support
- State management
- Provider-based architecture

---

### 2. What is the difference between Terraform and other IaC tools?

**Answer:**

| Feature | Terraform | CloudFormation | Ansible |
|---------|-----------|----------------|---------|
| Approach | Declarative | Declarative | Imperative |
| Cloud Support | Multi-cloud | AWS only | Multi-cloud |
| State Management | Yes | Yes | No |
| Agent Required | No | No | No |
| Language | HCL | JSON/YAML | YAML |

---

### 3. Explain Terraform workflow

**Answer:** The core Terraform workflow consists of:

1. **Write** - Author infrastructure as code
2. **Init** - Initialize working directory and download providers
3. **Plan** - Preview changes before applying
4. **Apply** - Create or update infrastructure
5. **Destroy** - Remove infrastructure when needed

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

### 4. What is Terraform state?

**Answer:** Terraform state is a JSON file that maps your configuration to real-world resources. It:
- Tracks resource metadata
- Improves performance
- Enables collaboration
- Stores resource dependencies

**Important:** State may contain sensitive data and should be secured.

---

### 5. What is the difference between count and for_each?

**Answer:**

**count:**
- Uses numeric index
- Fragile when removing items from middle
- Good for simple duplication

```hcl
resource "aws_instance" "web" {
  count = 3
  # Creates web[0], web[1], web[2]
}
```

**for_each:**
- Uses map keys or set values
- Stable when items are added/removed
- Better for dynamic lists

```hcl
resource "aws_instance" "web" {
  for_each = toset(["web1", "web2", "web3"])
  # Creates web["web1"], web["web2"], web["web3"]
}
```

---

## Intermediate Level Questions

### 6. Explain Terraform backends

**Answer:** Backends determine where Terraform state is stored and how operations are executed.

**Types:**
- **Local** - Default, stores state on local disk
- **Remote** - S3, GCS, Azure Blob, Terraform Cloud

**Benefits of Remote Backends:**
- Team collaboration
- State locking
- Encryption
- Version history

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

### 7. What are Terraform modules?

**Answer:** Modules are containers for multiple resources used together. They enable:
- Code reusability
- Organization
- Encapsulation
- Versioning

**Structure:**
```
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

**Usage:**
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}
```

---

### 8. How do you handle secrets in Terraform?

**Answer:**

**Best Practices:**
1. Use environment variables
```bash
export TF_VAR_db_password="secret"
```

2. Mark variables as sensitive
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

3. Use external secret management
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}
```

4. Never commit secrets to version control
```gitignore
*.tfvars
terraform.tfstate
```

---

### 9. What is terraform taint and why is it deprecated?

**Answer:**

**Old Way (Deprecated):**
```bash
terraform taint aws_instance.web
terraform apply
```

**New Way (Recommended):**
```bash
terraform apply -replace=aws_instance.web
```

**Reason for deprecation:** The `-replace` flag is more explicit and doesn't modify the state file before apply.

---

### 10. Explain Terraform workspaces

**Answer:** Workspaces allow managing multiple environments with the same configuration.

```bash
# Create workspace
terraform workspace new dev

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select prod

# Show current
terraform workspace show
```

**Use in configuration:**
```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t2.large" : "t2.micro"
  
  tags = {
    Environment = terraform.workspace
  }
}
```

**Note:** CLI workspaces ≠ Terraform Cloud workspaces


---

## Advanced Level Questions

### 11. How does Terraform handle dependencies?

**Answer:**

**Implicit Dependencies (Preferred):**
```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
}
```

**Explicit Dependencies:**
```hcl
resource "aws_instance" "web" {
  depends_on = [aws_iam_role_policy.example]
}
```

**Terraform builds a dependency graph to determine the correct order of operations.**

---

### 12. What is the difference between terraform refresh and terraform apply -refresh-only?

**Answer:**

**terraform refresh (Deprecated):**
- Updates state without modifying infrastructure
- Can be dangerous if used incorrectly

**terraform apply -refresh-only (Recommended):**
- Shows what would be updated
- Requires confirmation
- Safer alternative

```bash
# Old way
terraform refresh

# New way
terraform apply -refresh-only
```

---

### 13. Explain Terraform provisioners and why they should be avoided

**Answer:**

**Provisioners:**
- `local-exec` - Runs commands locally
- `remote-exec` - Runs commands on remote resource
- `file` - Copies files to remote resource

**Why avoid:**
- Not declarative
- Error-prone
- Hard to maintain
- Break Terraform's model

**Better alternatives:**
- Use `user_data` for cloud-init
- Use configuration management tools (Ansible, Chef)
- Use purpose-built providers

```hcl
# ❌ BAD: Using provisioner
resource "aws_instance" "web" {
  provisioner "remote-exec" {
    inline = ["sudo apt-get update"]
  }
}

# ✅ GOOD: Using user_data
resource "aws_instance" "web" {
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
  EOF
}
```

---

### 14. How do you import existing infrastructure into Terraform?

**Answer:**

**Steps:**

1. Write resource configuration
```hcl
resource "aws_instance" "web" {
  # Configuration matching existing resource
}
```

2. Import the resource
```bash
terraform import aws_instance.web i-1234567890abcdef0
```

3. Verify state
```bash
terraform state show aws_instance.web
```

4. Run plan to check
```bash
terraform plan
```

**Note:** Import only adds to state, doesn't generate configuration.

---

### 15. What are dynamic blocks?

**Answer:** Dynamic blocks generate repeated nested blocks.

```hcl
variable "ingress_rules" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
}

resource "aws_security_group" "example" {
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

---

### 16. Explain Terraform Cloud vs Terraform Enterprise

**Answer:**

| Feature | Terraform Cloud | Terraform Enterprise |
|---------|----------------|---------------------|
| Hosting | SaaS (HashiCorp) | Self-hosted |
| State Management | ✅ | ✅ |
| Remote Runs | ✅ | ✅ |
| VCS Integration | ✅ | ✅ |
| Sentinel Policies | Team & Governance plan | ✅ |
| SSO | Team & Governance plan | ✅ |
| Air-gapped | ❌ | ✅ |
| Audit Logging | Limited | Full |
| Cost | Free tier available | License required |

---

### 17. How do you handle Terraform state locking?

**Answer:**

**State locking prevents concurrent modifications.**

**AWS S3 + DynamoDB:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"  # Enables locking
  }
}
```

**If locked:**
```bash
# Check lock info
terraform force-unlock <LOCK_ID>
```

**Best practices:**
- Always use locking in team environments
- Use CI/CD to serialize operations
- Never force unlock unless certain

---

### 18. What is the lifecycle meta-argument?

**Answer:**

```hcl
resource "aws_instance" "web" {
  lifecycle {
    # Create new before destroying old
    create_before_destroy = true
    
    # Prevent accidental deletion
    prevent_destroy = true
    
    # Ignore changes to specific attributes
    ignore_changes = [tags, user_data]
    
    # Replace when referenced value changes
    replace_triggered_by = [aws_security_group.web.id]
  }
}
```

---

### 19. How do you manage multiple environments?

**Answer:**

**Option 1: Workspaces**
```bash
terraform workspace new dev
terraform workspace new prod
```

**Option 2: Separate Directories**
```
environments/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

**Option 3: Separate State Files**
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "${var.environment}/terraform.tfstate"
  }
}
```

---

### 20. What are Terraform functions you use most?

**Answer:**

**Common functions:**
```hcl
# String functions
lower("HELLO")
upper("hello")
format("Hello, %s!", "World")
join(",", ["a", "b", "c"])
split(",", "a,b,c")

# Collection functions
length([1, 2, 3])
merge({a=1}, {b=2})
concat([1, 2], [3, 4])
flatten([[1, 2], [3, 4]])

# Network functions
cidrsubnet("10.0.0.0/16", 8, 1)
cidrhost("10.0.0.0/24", 5)

# Type conversion
tostring(42)
tonumber("42")
tobool("true")

# Filesystem
file("path/to/file")
templatefile("template.tpl", {var = "value"})

# Encoding
jsonencode({key = "value"})
jsondecode('{"key":"value"}')
base64encode("hello")
```
