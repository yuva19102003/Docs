# 🔄 Expressions, Loops & Dynamic Blocks

## Conditional Expressions

### Ternary Operator

```hcl
# Syntax: condition ? true_value : false_value

variable "environment" {
  default = "prod"
}

locals {
  instance_type = var.environment == "prod" ? "t2.large" : "t2.micro"
  # If prod: t2.large, else: t2.micro
  
  instance_count = var.environment == "prod" ? 5 : 2
  # If prod: 5 instances, else: 2 instances
}

resource "aws_instance" "web" {
  count         = local.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = local.instance_type
}
```

### Conditional Resource Creation

```hcl
variable "create_database" {
  type    = bool
  default = true
}

resource "aws_db_instance" "main" {
  count = var.create_database ? 1 : 0
  
  identifier     = "mydb"
  engine         = "postgres"
  instance_class = "db.t3.micro"
}
```

---

## For Expressions

### List Transformation

```hcl
variable "users" {
  default = ["alice", "bob", "charlie"]
}

locals {
  # Convert to uppercase
  upper_users = [for user in var.users : upper(user)]
  # Result: ["ALICE", "BOB", "CHARLIE"]
  
  # Add prefix
  user_emails = [for user in var.users : "${user}@example.com"]
  # Result: ["alice@example.com", "bob@example.com", "charlie@example.com"]
}
```

### Map Transformation

```hcl
variable "instances" {
  default = {
    web = "t2.micro"
    db  = "t2.small"
    app = "t2.medium"
  }
}

locals {
  # Transform map values
  instance_sizes = {
    for name, type in var.instances :
    name => upper(type)
  }
  # Result: {
  #   web = "T2.MICRO"
  #   db  = "T2.SMALL"
  #   app = "T2.MEDIUM"
  # }
}
```

### Filtering

```hcl
variable "servers" {
  default = [
    { name = "web1", type = "web" },
    { name = "db1", type = "database" },
    { name = "web2", type = "web" },
  ]
}

locals {
  # Filter web servers only
  web_servers = [
    for server in var.servers :
    server.name if server.type == "web"
  ]
  # Result: ["web1", "web2"]
}
```

---

## Splat Expressions

```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# Get all IDs using splat
output "all_instance_ids" {
  value = aws_instance.web[*].id
  # Equivalent to: [for i in aws_instance.web : i.id]
}

# Get all public IPs
output "all_public_ips" {
  value = aws_instance.web[*].public_ip
}
```
