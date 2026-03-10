# Meta-Arguments in Terraform

Meta-arguments are special arguments that can be used with any resource type.

---

## 1. count

**Purpose:** Create multiple instances of a resource.

### Basic Example

```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server-${count.index}"
  }
}

# Creates:
# - web-server-0
# - web-server-1
# - web-server-2
```

### Conditional Creation

```hcl
variable "create_instance" {
  type    = bool
  default = true
}

resource "aws_instance" "web" {
  count = var.create_instance ? 1 : 0
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### Referencing count Resources

```hcl
# Reference all instances
output "all_ips" {
  value = aws_instance.web[*].public_ip
}

# Reference specific instance
output "first_ip" {
  value = aws_instance.web[0].public_ip
}
```

---

## 2. for_each

**Purpose:** Create multiple instances using a map or set.

### With Set

```hcl
variable "users" {
  type = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key
  
  tags = {
    User = each.value
  }
}
```

### With Map

```hcl
variable "instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
  
  default = {
    web = {
      instance_type = "t2.micro"
      ami           = "ami-abc123"
    }
    db = {
      instance_type = "t2.small"
      ami           = "ami-def456"
    }
  }
}

resource "aws_instance" "servers" {
  for_each = var.instances
  
  instance_type = each.value.instance_type
  ami           = each.value.ami
  
  tags = {
    Name = each.key
  }
}
```


### count vs for_each

```
┌──────────────────────────────────────────────────────────┐
│  count vs for_each                                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  count:                                                  │
│  ✅ Simple numeric iteration                            │
│  ✅ Conditional creation (count = condition ? 1 : 0)    │
│  ❌ Fragile when removing items from middle             │
│  ❌ Uses numeric index                                  │
│                                                          │
│  for_each:                                               │
│  ✅ Stable keys (no reordering issues)                  │
│  ✅ Works with maps and sets                            │
│  ✅ Better for dynamic lists                            │
│  ❌ Slightly more complex syntax                        │
│                                                          │
│  Recommendation: Use for_each for most cases            │
└──────────────────────────────────────────────────────────┘
```

---

## 3. depends_on

**Purpose:** Explicit dependency when implicit dependencies don't work.

```hcl
resource "aws_iam_role" "example" {
  name = "example-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "example" {
  name = "example-policy"
  role = aws_iam_role.example.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:*"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # Explicit dependency
  depends_on = [
    aws_iam_role_policy.example
  ]
}
```

**When to use:**
- Hidden dependencies (e.g., IAM eventual consistency)
- Dependencies on modules
- Dependencies that Terraform can't detect automatically

---

## 4. provider

**Purpose:** Use alternate provider configuration.

```hcl
# Default provider
provider "aws" {
  region = "us-east-1"
}

# Alternate provider with alias
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Use default provider
resource "aws_instance" "east" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# Use alternate provider
resource "aws_instance" "west" {
  provider = aws.west
  
  ami           = "ami-0d1cd67c26f5fca19"
  instance_type = "t2.micro"
}
```
