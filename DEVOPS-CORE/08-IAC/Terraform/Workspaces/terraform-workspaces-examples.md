# Terraform Workspaces - Complete Guide

## Overview

Terraform workspaces allow you to manage multiple environments (dev, staging, production) using the same configuration files. Each workspace maintains its own state file, enabling environment isolation.

## Key Concepts

### What are Workspaces?

- **Workspaces** are isolated instances of state data within the same working directory
- Each workspace has its own state file
- Same configuration code can be used across multiple environments
- Default workspace is called `default`

### When to Use Workspaces

✅ **Good Use Cases:**
- Managing multiple environments (dev, staging, prod)
- Testing infrastructure changes
- Temporary infrastructure for feature branches
- Multi-tenant deployments

❌ **Not Recommended For:**
- Completely different infrastructure architectures
- Different cloud providers
- Long-term environment separation (use separate directories instead)

## Workspace Commands

### Basic Commands

```bash
# List all workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Create new workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch to workspace
terraform workspace select dev

# Delete workspace (must not be current workspace)
terraform workspace delete staging
```

## Practical Example

### Directory Structure

```
terraform-workspaces/
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

### main.tf

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use workspace name in resource naming
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${terraform.workspace}-app-server"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${terraform.workspace}-data"

  tags = {
    Name        = "${terraform.workspace}-data-bucket"
    Environment = terraform.workspace
  }
}

# Conditional resources based on workspace
resource "aws_db_instance" "database" {
  count = terraform.workspace == "prod" ? 1 : 0

  identifier        = "${terraform.workspace}-database"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = terraform.workspace != "prod"

  tags = {
    Environment = terraform.workspace
  }
}
```

### variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage" {
  description = "RDS storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### dev.tfvars

```hcl
aws_region    = "us-east-1"
instance_type = "t3.micro"
ami_id        = "ami-0c55b159cbfafe1f0"
db_username   = "devadmin"
db_password   = "DevPassword123!"  # Use secrets manager in production
```

### staging.tfvars

```hcl
aws_region    = "us-east-1"
instance_type = "t3.small"
ami_id        = "ami-0c55b159cbfafe1f0"
db_username   = "stagingadmin"
db_password   = "StagingPassword123!"
```

### prod.tfvars

```hcl
aws_region        = "us-east-1"
instance_type     = "t3.medium"
ami_id            = "ami-0c55b159cbfafe1f0"
db_instance_class = "db.t3.small"
db_storage        = 100
db_username       = "prodadmin"
db_password       = "ProdPassword123!"  # Use AWS Secrets Manager
```

### outputs.tf

```hcl
output "workspace_name" {
  description = "Current workspace name"
  value       = terraform.workspace
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.app_server.public_ip
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.data.id
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = terraform.workspace == "prod" ? aws_db_instance.database[0].endpoint : "N/A"
}
```

## Workflow Examples

### Development Environment

```bash
# Create and switch to dev workspace
terraform workspace new dev

# Initialize and plan
terraform init
terraform plan -var-file="dev.tfvars"

# Apply configuration
terraform apply -var-file="dev.tfvars"

# Verify resources
terraform show
```

### Staging Environment

```bash
# Create and switch to staging workspace
terraform workspace new staging

# Apply staging configuration
terraform apply -var-file="staging.tfvars"
```

### Production Environment

```bash
# Create and switch to prod workspace
terraform workspace new prod

# Plan with production variables
terraform plan -var-file="prod.tfvars"

# Apply with approval
terraform apply -var-file="prod.tfvars"
```

## Advanced Patterns

### Environment-Specific Configuration

```hcl
locals {
  environment_config = {
    dev = {
      instance_count = 1
      instance_type  = "t3.micro"
      enable_backup  = false
    }
    staging = {
      instance_count = 2
      instance_type  = "t3.small"
      enable_backup  = true
    }
    prod = {
      instance_count = 3
      instance_type  = "t3.medium"
      enable_backup  = true
    }
  }

  current_env = local.environment_config[terraform.workspace]
}

resource "aws_instance" "app" {
  count         = local.current_env.instance_count
  instance_type = local.current_env.instance_type
  ami           = var.ami_id

  tags = {
    Name        = "${terraform.workspace}-app-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```

### Workspace Validation

```hcl
locals {
  valid_workspaces = ["dev", "staging", "prod"]
  
  validate_workspace = contains(local.valid_workspaces, terraform.workspace) ? true : tobool("Invalid workspace: ${terraform.workspace}. Must be one of: ${join(", ", local.valid_workspaces)}")
}
```

## Best Practices

### 1. Naming Conventions

```hcl
# Include workspace in resource names
resource "aws_instance" "web" {
  tags = {
    Name = "${terraform.workspace}-web-server"
  }
}

# Use workspace in bucket names
resource "aws_s3_bucket" "data" {
  bucket = "${var.project}-${terraform.workspace}-data"
}
```

### 2. State Management

```hcl
# Use remote backend with workspace support
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    
    # Workspace-specific state files are automatically created
    # Format: env:/workspace-name/project/terraform.tfstate
  }
}
```

### 3. Variable Files

```bash
# Use workspace-specific variable files
terraform apply -var-file="${terraform.workspace}.tfvars"

# Or use a script
#!/bin/bash
WORKSPACE=$(terraform workspace show)
terraform apply -var-file="${WORKSPACE}.tfvars"
```

### 4. Conditional Resources

```hcl
# Only create in production
resource "aws_cloudwatch_alarm" "high_cpu" {
  count = terraform.workspace == "prod" ? 1 : 0
  # ... alarm configuration
}

# Different settings per environment
resource "aws_autoscaling_group" "app" {
  min_size = terraform.workspace == "prod" ? 3 : 1
  max_size = terraform.workspace == "prod" ? 10 : 3
}
```

## Common Pitfalls

### ❌ Don't Do This

```hcl
# Hardcoded environment names
resource "aws_instance" "web" {
  tags = {
    Name = "prod-web-server"  # Wrong!
  }
}

# Sharing state across workspaces
# Each workspace should have isolated state
```

### ✅ Do This Instead

```hcl
# Use workspace variable
resource "aws_instance" "web" {
  tags = {
    Name = "${terraform.workspace}-web-server"
  }
}

# Ensure proper state isolation
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "project/terraform.tfstate"
    # Workspaces automatically create separate state files
  }
}
```

## Workspace vs Separate Directories

### Use Workspaces When:
- Same infrastructure, different scale
- Temporary environments
- Quick environment switching
- Shared configuration

### Use Separate Directories When:
- Completely different architectures
- Different teams managing environments
- Different backend configurations
- Long-term environment isolation

## Troubleshooting

### Check Current Workspace

```bash
terraform workspace show
```

### List All Workspaces

```bash
terraform workspace list
```

### Switch Workspace

```bash
terraform workspace select dev
```

### Delete Workspace

```bash
# Must switch to different workspace first
terraform workspace select default
terraform workspace delete old-workspace
```

### View Workspace State

```bash
# Show resources in current workspace
terraform state list

# Show specific resource
terraform state show aws_instance.app_server
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Terraform Workspace Deploy

on:
  push:
    branches:
      - dev
      - staging
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
      
      - name: Determine Environment
        id: env
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "workspace=prod" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" == "refs/heads/staging" ]; then
            echo "workspace=staging" >> $GITHUB_OUTPUT
          else
            echo "workspace=dev" >> $GITHUB_OUTPUT
          fi
      
      - name: Terraform Init
        run: terraform init
      
      - name: Select Workspace
        run: |
          terraform workspace select ${{ steps.env.outputs.workspace }} || \
          terraform workspace new ${{ steps.env.outputs.workspace }}
      
      - name: Terraform Plan
        run: terraform plan -var-file="${{ steps.env.outputs.workspace }}.tfvars"
      
      - name: Terraform Apply
        if: github.event_name == 'push'
        run: terraform apply -auto-approve -var-file="${{ steps.env.outputs.workspace }}.tfvars"
```

## Summary

Terraform workspaces provide a lightweight way to manage multiple environments with the same configuration. They're ideal for:

- Development, staging, and production environments
- Feature branch testing
- Multi-tenant deployments
- Quick environment provisioning

Remember to use workspace-aware naming, maintain separate variable files, and ensure proper state isolation for production workloads.
