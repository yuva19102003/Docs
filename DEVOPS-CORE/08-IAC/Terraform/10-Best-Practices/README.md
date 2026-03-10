# 🎯 Terraform Best Practices

## Project Structure

### Recommended Directory Layout

```
terraform-project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── .gitignore
└── README.md
```

---

## Naming Conventions

### Resource Naming

```hcl
# ✅ GOOD: Descriptive and consistent
resource "aws_instance" "web_server" {
  # ...
}

resource "aws_security_group" "web_server_sg" {
  # ...
}

# ❌ BAD: Vague names
resource "aws_instance" "server1" {
  # ...
}
```

### Variable Naming

```hcl
# ✅ GOOD: Clear and descriptive
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
}

# ❌ BAD: Unclear names
variable "cidr" {
  type = string
}

variable "dns" {
  type = bool
}
```

---

## State Management

### ✅ DO

```hcl
# Use remote state
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

### ❌ DON'T

```bash
# Don't commit state files
git add terraform.tfstate  # ❌ NEVER DO THIS
```

---

## Security Best Practices

### Sensitive Data

```hcl
# ✅ GOOD: Mark sensitive variables
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# ✅ GOOD: Mark sensitive outputs
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}

# ✅ GOOD: Use environment variables
# export TF_VAR_db_password="secret"
```

### .gitignore

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore plan files
*.tfplan
```
