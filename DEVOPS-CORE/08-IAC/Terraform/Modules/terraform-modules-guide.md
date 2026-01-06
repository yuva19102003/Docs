# Terraform Modules - Complete Guide

## Overview

Terraform modules are containers for multiple resources that are used together. They enable code reusability, organization, and abstraction of infrastructure components.

## What are Modules?

A module is a collection of `.tf` files in a directory that:
- Groups related resources together
- Provides reusable infrastructure components
- Encapsulates complexity
- Enables standardization across teams

### Module Types

1. **Root Module**: The main working directory where you run Terraform commands
2. **Child Modules**: Modules called by the root module or other modules
3. **Published Modules**: Modules shared via Terraform Registry or private registries

## Module Structure

### Basic Module Structure

```
modules/
├── ec2-instance/
│   ├── main.tf          # Main resource definitions
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── README.md        # Documentation
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── s3-bucket/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

## Creating a Module

### Example: EC2 Instance Module

#### modules/ec2-instance/main.tf

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

# Security Group
resource "aws_security_group" "instance" {
  name_prefix = "${var.name}-"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = var.key_name

  user_data = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = var.enable_encryption
  }

  monitoring = var.enable_monitoring

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Elastic IP (optional)
resource "aws_eip" "this" {
  count    = var.associate_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-eip"
    }
  )
}
```

#### modules/ec2-instance/variables.tf

```hcl
variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where the instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"
}

variable "enable_encryption" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "associate_eip" {
  description = "Associate Elastic IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

#### modules/ec2-instance/outputs.tf

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.this.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.associate_eip ? aws_eip.this[0].public_ip : null
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.instance.id
}
```

## Using Modules

### Root Module Example

#### main.tf

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

# Data sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Web Server Module
module "web_server" {
  source = "./modules/ec2-instance"

  name          = "web-server"
  ami_id        = var.ami_id
  instance_type = "t3.small"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
  key_name      = var.key_name

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.admin_cidr]
    }
  ]

  root_volume_size  = 30
  enable_monitoring = true
  associate_eip     = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Role        = "web-server"
  }
}

# Application Server Module
module "app_server" {
  source = "./modules/ec2-instance"

  name          = "app-server"
  ami_id        = var.ami_id
  instance_type = "t3.medium"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
  key_name      = var.key_name

  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.default.cidr_block]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.admin_cidr]
    }
  ]

  root_volume_size  = 50
  enable_monitoring = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Role        = "app-server"
  }
}
```

#### variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block for admin access"
  type        = string
}
```

#### outputs.tf

```hcl
output "web_server_public_ip" {
  description = "Web server public IP"
  value       = module.web_server.elastic_ip
}

output "web_server_id" {
  description = "Web server instance ID"
  value       = module.web_server.instance_id
}

output "app_server_private_ip" {
  description = "App server private IP"
  value       = module.app_server.private_ip
}

output "app_server_id" {
  description = "App server instance ID"
  value       = module.app_server.instance_id
}
```

## Advanced Module Patterns

### 1. VPC Module

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${count.index + 1}"
      Type = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${count.index + 1}"
      Type = "private"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}
```

### 2. S3 Bucket Module

```hcl
# modules/s3-bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}
```

## Module Sources

### Local Path

```hcl
module "vpc" {
  source = "./modules/vpc"
  # ...
}
```

### Git Repository

```hcl
module "vpc" {
  source = "git::https://github.com/organization/terraform-modules.git//vpc?ref=v1.0.0"
  # ...
}
```

### Terraform Registry

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
  # ...
}
```

### S3 Bucket

```hcl
module "vpc" {
  source = "s3::https://s3.amazonaws.com/my-bucket/terraform-modules/vpc.zip"
  # ...
}
```

## Best Practices

### 1. Module Versioning

```hcl
# Use version constraints
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Any 5.x version
  # ...
}

# Pin to specific version in production
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
  # ...
}
```

### 2. Input Validation

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = can(regex("^t3\\.(micro|small|medium|large)$", var.instance_type))
    error_message = "Instance type must be t3.micro, t3.small, t3.medium, or t3.large."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 3. Output Documentation

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}
```

### 4. Module Documentation

Create a comprehensive README.md for each module:

```markdown
# EC2 Instance Module

## Description
Creates an EC2 instance with security group and optional Elastic IP.

## Usage
```hcl
module "web_server" {
  source = "./modules/ec2-instance"

  name          = "web-server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Instance name | string | n/a | yes |
| ami_id | AMI ID | string | n/a | yes |
| instance_type | Instance type | string | t3.micro | no |

## Outputs
| Name | Description |
|------|-------------|
| instance_id | EC2 instance ID |
| public_ip | Public IP address |
```

### 5. Module Composition

```hcl
# Compose modules together
module "vpc" {
  source = "./modules/vpc"
  name   = "production"
  # ...
}

module "web_servers" {
  source = "./modules/ec2-instance"
  count  = 3

  name      = "web-${count.index + 1}"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[count.index]
  # ...
}

module "database" {
  source = "./modules/rds"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  # ...
}
```

## Testing Modules

### Using Terratest (Go)

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestEC2Module(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/ec2-instance",
        Vars: map[string]interface{}{
            "name":          "test-instance",
            "ami_id":        "ami-0c55b159cbfafe1f0",
            "instance_type": "t3.micro",
            "vpc_id":        "vpc-12345678",
            "subnet_id":     "subnet-12345678",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    instanceID := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, instanceID)
}
```

## Common Patterns

### Multi-Environment Deployment

```hcl
# environments/dev/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"

  environment   = "dev"
  instance_type = "t3.micro"
  instance_count = 1
}

# environments/prod/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"

  environment   = "prod"
  instance_type = "t3.large"
  instance_count = 3
}
```

### Module Registry Publishing

```hcl
# Publish to private registry
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Use from private registry
module "vpc" {
  source  = "app.terraform.io/my-org/vpc/aws"
  version = "1.0.0"
}
```

## Summary

Terraform modules enable:
- **Reusability**: Write once, use many times
- **Consistency**: Standardize infrastructure patterns
- **Abstraction**: Hide complexity behind simple interfaces
- **Collaboration**: Share modules across teams
- **Maintainability**: Update modules centrally

Key takeaways:
- Keep modules focused and single-purpose
- Document inputs, outputs, and usage
- Version modules properly
- Validate inputs
- Test modules thoroughly
- Use semantic versioning
