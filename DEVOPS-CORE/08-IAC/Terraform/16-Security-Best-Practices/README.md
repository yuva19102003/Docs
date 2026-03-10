# 🔒 Security Best Practices

## Sensitive Data Management

### 1. Mark Variables as Sensitive

```hcl
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true  # Redacts from output
}

variable "api_key" {
  description = "API key"
  type        = string
  sensitive   = true
}
```

### 2. Mark Outputs as Sensitive

```hcl
output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true  # Hidden in CLI output
}
```

### 3. Use sensitive() Function

```hcl
locals {
  connection_string = sensitive("${var.username}:${var.password}@${var.host}")
}
```

---

## Secret Management

### ❌ DON'T Store Secrets in Code

```hcl
# BAD - Never do this!
variable "password" {
  default = "MyPassword123"  # ❌ Hardcoded secret
}
```

### ✅ DO Use Environment Variables

```bash
# Set via environment
export TF_VAR_db_password="SecurePassword123"

# Use in Terraform
terraform apply
```

### ✅ DO Use External Secret Managers

**AWS Secrets Manager:**
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**HashiCorp Vault:**
```hcl
data "vault_generic_secret" "db_creds" {
  path = "secret/database"
}

resource "aws_db_instance" "main" {
  username = data.vault_generic_secret.db_creds.data["username"]
  password = data.vault_generic_secret.db_creds.data["password"]
}
```

---

## State File Security

### State Contains Sensitive Data

```json
{
  "resources": [{
    "instances": [{
      "attributes": {
        "password": "MySecretPassword",  // ⚠️ Visible in state
        "private_key": "-----BEGIN RSA..."
      }
    }]
  }]
}
```

### Secure State Storage

**S3 Backend with Encryption:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true  # Server-side encryption
    kms_key_id     = "arn:aws:kms:..."  # Optional: Use KMS
    dynamodb_table = "terraform-locks"
    
    # Access control
    acl = "private"
  }
}
```

**Terraform Cloud:**
```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "production"
    }
  }
}
# State automatically encrypted at rest
```

---

## .gitignore Configuration

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (may contain secrets)
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

# Ignore backup files
*.backup
```

---

## IAM and Access Control

### Principle of Least Privilege

```hcl
# ✅ GOOD: Specific permissions
resource "aws_iam_policy" "terraform" {
  name = "terraform-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:Describe*",
        "ec2:CreateTags",
        "ec2:RunInstances"
      ]
      Resource = "*"
    }]
  })
}

# ❌ BAD: Overly permissive
resource "aws_iam_policy" "bad_example" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "*"  # ❌ Too broad
      Resource = "*"
    }]
  })
}
```

### Use Assume Roles

```hcl
provider "aws" {
  region = "us-east-1"
  
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
  }
}
```

---

## Network Security

### Security Groups

```hcl
# ✅ GOOD: Restrictive rules
resource "aws_security_group" "web" {
  name = "web-sg"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only
  }
}

# ❌ BAD: Open to world
resource "aws_security_group" "bad" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ SSH open to internet
  }
}
```

### Use Variables for IP Ranges

```hcl
variable "allowed_ips" {
  description = "Allowed IP ranges"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

resource "aws_security_group" "app" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }
}
```

---

## Encryption

### Encrypt at Rest

```hcl
# S3 Bucket Encryption
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

# RDS Encryption
resource "aws_db_instance" "main" {
  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn
}

# EBS Encryption
resource "aws_ebs_volume" "data" {
  encrypted  = true
  kms_key_id = aws_kms_key.main.arn
}
```

### Encrypt in Transit

```hcl
# ALB with HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn
}

# RDS with SSL
resource "aws_db_instance" "main" {
  ca_cert_identifier = "rds-ca-2019"
}
```

---

## Compliance and Auditing

### Resource Tagging

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    Compliance  = "PCI-DSS"
  }
}

resource "aws_instance" "web" {
  tags = merge(
    local.common_tags,
    {
      Name = "web-server"
      Role = "WebServer"
    }
  )
}
```

### Enable Logging

```hcl
# S3 Access Logging
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id
  
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
```

---

## Secure CI/CD

### GitHub Actions Example

```yaml
name: Terraform

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
      
      - name: Terraform Init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Terraform Plan
        run: terraform plan
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

### Use OIDC Instead of Static Credentials

```hcl
# Configure AWS to trust GitHub OIDC
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = ["sts.amazonaws.com"]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}
```

---

## Security Checklist

### Before Deployment

- [ ] No hardcoded secrets in code
- [ ] Sensitive variables marked as sensitive
- [ ] State backend encrypted
- [ ] .gitignore configured properly
- [ ] IAM roles follow least privilege
- [ ] Security groups are restrictive
- [ ] Encryption enabled (at rest & in transit)
- [ ] Logging and monitoring enabled
- [ ] Resource tagging implemented
- [ ] Code reviewed by team

### After Deployment

- [ ] Verify no secrets in state file
- [ ] Check security group rules
- [ ] Validate encryption settings
- [ ] Review IAM permissions
- [ ] Monitor CloudTrail logs
- [ ] Regular security audits
- [ ] Rotate credentials regularly
- [ ] Update dependencies

---

## Common Security Mistakes

### 1. Exposing Secrets

```hcl
# ❌ BAD
variable "password" {
  default = "MyPassword123"
}

# ✅ GOOD
variable "password" {
  type      = string
  sensitive = true
  # No default - must be provided securely
}
```

### 2. Overly Permissive Security Groups

```hcl
# ❌ BAD
cidr_blocks = ["0.0.0.0/0"]

# ✅ GOOD
cidr_blocks = ["10.0.0.0/8"]
```

### 3. Unencrypted State

```hcl
# ❌ BAD
backend "s3" {
  bucket = "my-state"
  # No encryption!
}

# ✅ GOOD
backend "s3" {
  bucket  = "my-state"
  encrypt = true
}
```

### 4. Committing State Files

```bash
# ❌ BAD
git add terraform.tfstate

# ✅ GOOD
# Add to .gitignore
echo "*.tfstate*" >> .gitignore
```

---

## Summary

**Key Security Principles:**
1. Never hardcode secrets
2. Always encrypt state
3. Use least privilege IAM
4. Enable encryption everywhere
5. Implement proper logging
6. Regular security audits
7. Use .gitignore properly
8. Secure CI/CD pipelines
