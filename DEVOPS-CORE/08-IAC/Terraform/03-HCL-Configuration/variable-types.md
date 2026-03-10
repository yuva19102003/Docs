# Variable Types in Terraform

## Primitive Types

### 1. String

```hcl
variable "instance_name" {
  type    = string
  default = "web-server"
}

# Usage
resource "aws_instance" "web" {
  tags = {
    Name = var.instance_name
  }
}
```

### 2. Number

```hcl
variable "instance_count" {
  type    = number
  default = 3
}

# Usage
resource "aws_instance" "web" {
  count = var.instance_count
  # ...
}
```

### 3. Bool

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}

# Usage
resource "aws_instance" "web" {
  monitoring = var.enable_monitoring
  # ...
}
```

---

## Collection Types

### 1. List

```hcl
variable "availability_zones" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

# Usage
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  # ...
}
```

### 2. Map

```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t2.large"
  }
}

# Usage
resource "aws_instance" "web" {
  instance_type = var.instance_types["prod"]
  # ...
}
```

### 3. Set

```hcl
variable "allowed_ports" {
  type = set(number)
  default = [80, 443, 8080]
}

# Usage
resource "aws_security_group" "web" {
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```


---

## Structural Types

### 1. Object

```hcl
variable "instance_config" {
  type = object({
    instance_type = string
    ami           = string
    monitoring    = bool
    tags          = map(string)
  })
  
  default = {
    instance_type = "t2.micro"
    ami           = "ami-0c55b159cbfafe1f0"
    monitoring    = true
    tags = {
      Environment = "dev"
    }
  }
}

# Usage
resource "aws_instance" "web" {
  instance_type = var.instance_config.instance_type
  ami           = var.instance_config.ami
  monitoring    = var.instance_config.monitoring
  tags          = var.instance_config.tags
}
```

### 2. Tuple

```hcl
variable "network_config" {
  type = tuple([string, number, bool])
  default = ["10.0.0.0/16", 3, true]
}

# Usage
locals {
  vpc_cidr    = var.network_config[0]
  subnet_count = var.network_config[1]
  enable_nat   = var.network_config[2]
}
```

### 3. Any (Use Sparingly)

```hcl
variable "custom_config" {
  type        = any
  description = "Flexible configuration"
}

# Can accept any type
# Not recommended for production use
```

---

## Variable Precedence

```
┌─────────────────────────────────────────────────┐
│  Variable Precedence (Lowest to Highest)       │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. Default value in variable block             │
│  2. terraform.tfvars                            │
│  3. *.auto.tfvars (alphabetical)                │
│  4. -var-file flag                              │
│  5. -var flag                                   │
│  6. TF_VAR_name environment variable ← HIGHEST  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Example Files

**variables.tf**
```hcl
variable "environment" {
  type    = string
  default = "dev"  # Precedence: 1 (lowest)
}
```

**terraform.tfvars**
```hcl
environment = "staging"  # Precedence: 2
```

**prod.auto.tfvars**
```hcl
environment = "production"  # Precedence: 3
```

**Command line**
```bash
# Precedence: 4
terraform apply -var-file="custom.tfvars"

# Precedence: 5
terraform apply -var="environment=test"

# Precedence: 6 (highest)
export TF_VAR_environment="override"
terraform apply
```
