# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### 1. State Lock Issues

**Problem:** State is locked by another process

```
Error: Error acquiring the state lock
Lock Info:
  ID:        abc-123-def
  Path:      s3://bucket/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.6.0
  Created:   2024-01-15 10:30:00
```

**Solutions:**

```bash
# Option 1: Wait for the lock to be released naturally

# Option 2: Force unlock (use with caution!)
terraform force-unlock abc-123-def

# Option 3: Check if process is still running
# If not, force unlock is safe
```

**Prevention:**
- Use proper CI/CD pipelines
- Implement state locking with DynamoDB (AWS)
- Don't run multiple applies simultaneously

---

### 2. Provider Version Conflicts

**Problem:** Provider version mismatch

```
Error: Failed to query available provider packages
Could not retrieve the list of available versions for provider
hashicorp/aws: locked provider registry.terraform.io/hashicorp/aws
5.0.0 does not match configured version constraint ~> 4.0
```

**Solutions:**

```bash
# Option 1: Update lock file
terraform init -upgrade

# Option 2: Update version constraint in configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Update this
    }
  }
}

# Option 3: Reconfigure
terraform init -reconfigure
```

---

### 3. Resource Already Exists

**Problem:** Resource exists but not in state

```
Error: Error creating EC2 Instance: InvalidParameterValue:
Instance with name 'web-server' already exists
```

**Solutions:**

```bash
# Option 1: Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Option 2: Remove existing resource manually
# Then run terraform apply

# Option 3: Use different name/identifier
```

---

### 4. Dependency Errors

**Problem:** Resources created in wrong order

```
Error: Error creating Instance: InvalidSubnet.NotFound
The subnet 'subnet-123' does not exist
```

**Solutions:**

```hcl
# Option 1: Use implicit dependencies (preferred)
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id  # Implicit dependency
}

# Option 2: Use explicit dependencies
resource "aws_instance" "web" {
  depends_on = [aws_subnet.public]
}
```

---

### 5. State Drift

**Problem:** Real infrastructure doesn't match state

```
# terraform plan shows unexpected changes
```

**Solutions:**

```bash
# Option 1: Refresh state
terraform apply -refresh-only

# Option 2: Import missing resources
terraform import <resource_type>.<name> <id>

# Option 3: Remove from state if resource deleted
terraform state rm <resource_address>
```


---

### 6. Timeout Errors

**Problem:** Operation times out

```
Error: timeout while waiting for state to become 'available'
```

**Solutions:**

```hcl
# Increase timeout in resource configuration
resource "aws_db_instance" "main" {
  # ... other config ...
  
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
```

---

### 7. Circular Dependencies

**Problem:** Resources depend on each other

```
Error: Cycle: aws_security_group.web, aws_security_group.db
```

**Solutions:**

```hcl
# BAD: Circular dependency
resource "aws_security_group" "web" {
  ingress {
    security_groups = [aws_security_group.db.id]
  }
}

resource "aws_security_group" "db" {
  ingress {
    security_groups = [aws_security_group.web.id]
  }
}

# GOOD: Use separate security group rules
resource "aws_security_group" "web" {
  # No ingress here
}

resource "aws_security_group" "db" {
  # No ingress here
}

resource "aws_security_group_rule" "web_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
}
```

---

## Debugging Commands

### Enable Debug Logging

```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run terraform command
terraform apply

# View logs
cat terraform.log

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

### Log Levels

```bash
# TRACE - Most verbose
export TF_LOG=TRACE

# DEBUG - Detailed debugging
export TF_LOG=DEBUG

# INFO - General information
export TF_LOG=INFO

# WARN - Warnings only
export TF_LOG=WARN

# ERROR - Errors only
export TF_LOG=ERROR
```

### Validate Configuration

```bash
# Check syntax
terraform validate

# Format check
terraform fmt -check -recursive

# Show plan with details
terraform plan -out=tfplan
terraform show tfplan
```

---

## Performance Issues

### Slow Plan/Apply

**Problem:** Terraform operations are slow

**Solutions:**

```bash
# 1. Use -target for specific resources
terraform apply -target=aws_instance.web

# 2. Reduce parallelism
terraform apply -parallelism=5

# 3. Use smaller state files (split environments)

# 4. Upgrade Terraform version
terraform version
# Download latest from terraform.io
```

### Large State Files

**Problem:** State file is too large

**Solutions:**

```bash
# 1. Split into multiple state files
# Use separate directories for different components

# 2. Use workspaces
terraform workspace new prod
terraform workspace new dev

# 3. Remove unused resources
terraform state rm <resource_address>
```
