# 🔌 Providers & Registry

## What is a Provider?

A provider is a plugin that lets Terraform interact with external APIs.

```
┌────────────────────────────────────────────────────┐
│  Terraform Architecture                            │
├────────────────────────────────────────────────────┤
│                                                    │
│  Terraform Core                                    │
│       ↓                                            │
│  Provider Plugin (AWS, Azure, GCP, etc.)          │
│       ↓                                            │
│  Cloud Provider API                                │
│       ↓                                            │
│  Real Infrastructure                               │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Provider Configuration

### Basic Provider

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Multiple Providers

```hcl
# Default AWS provider
provider "aws" {
  region = "us-east-1"
}

# West region provider
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Europe provider
provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}

# Use default provider
resource "aws_instance" "east" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# Use aliased provider
resource "aws_instance" "west" {
  provider = aws.west
  
  ami           = "ami-0d1cd67c26f5fca19"
  instance_type = "t2.micro"
}
```


---

## Version Constraints

### Constraint Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Exact version | `= 1.0.0` |
| `!=` | Exclude version | `!= 1.0.0` |
| `>` | Greater than | `> 1.0.0` |
| `>=` | Greater or equal | `>= 1.0.0` |
| `<` | Less than | `< 2.0.0` |
| `<=` | Less or equal | `<= 2.0.0` |
| `~>` | Pessimistic | `~> 1.0` |

### Pessimistic Constraint (~>)

```hcl
# ~> 1.0 means >= 1.0 and < 2.0
version = "~> 1.0"
# Allows: 1.0, 1.1, 1.9
# Blocks: 2.0, 2.1

# ~> 1.0.4 means >= 1.0.4 and < 1.1.0
version = "~> 1.0.4"
# Allows: 1.0.4, 1.0.5, 1.0.9
# Blocks: 1.1.0, 1.2.0

# ~> 1.2.0 means >= 1.2.0 and < 1.3.0
version = "~> 1.2.0"
# Allows: 1.2.0, 1.2.1, 1.2.9
# Blocks: 1.3.0, 2.0.0
```

### Multiple Constraints

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}
```

---

## Provider Lock File

### .terraform.lock.hcl

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abc123...",
    "zh:def456...",
  ]
}
```

**Important:**
- ✅ Commit to version control
- ✅ Ensures consistent provider versions
- ✅ Prevents unexpected upgrades
- ❌ Don't manually edit
