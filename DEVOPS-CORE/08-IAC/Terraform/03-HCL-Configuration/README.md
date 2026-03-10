# 📝 HCL Configuration & Syntax

## HashiCorp Configuration Language (HCL)

HCL is a declarative language designed for infrastructure configuration.

---

## Block Types

### 1. Resource Block

**Purpose:** Define infrastructure objects to be managed.

```hcl
resource "provider_type" "name" {
  argument1 = "value1"
  argument2 = "value2"
  
  nested_block {
    nested_argument = "value"
  }
}
```

**Example:**

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name        = "WebServer"
    Environment = "Production"
  }
}
```

### 2. Data Source Block

**Purpose:** Read information from existing resources.

```hcl
data "provider_type" "name" {
  # Filter criteria
  filter {
    name   = "tag:Name"
    values = ["my-resource"]
  }
}
```

**Example:**

```hcl
# Fetch latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Use the data source
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}
```


### 3. Variable Block

**Purpose:** Define input parameters.

```hcl
variable "name" {
  description = "Description of the variable"
  type        = string
  default     = "default_value"
  sensitive   = false
  
  validation {
    condition     = length(var.name) > 3
    error_message = "Name must be longer than 3 characters."
  }
}
```

**Example:**

```hcl
variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "demo"
  }
}
```

### 4. Output Block

**Purpose:** Export values from your configuration.

```hcl
output "name" {
  description = "Description of output"
  value       = resource.type.name.attribute
  sensitive   = false
}
```

**Example:**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_instance.web.public_ip
}

output "all_instance_ips" {
  description = "All instance IPs"
  value       = aws_instance.web[*].public_ip
}
```
