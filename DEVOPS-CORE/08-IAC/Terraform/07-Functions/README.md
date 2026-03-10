# 🔧 Built-in Functions

Terraform includes many built-in functions for transforming and combining values.

---

## String Functions

### format()

```hcl
# String formatting
locals {
  instance_name = format("web-server-%03d", 5)
  # Result: "web-server-005"
  
  message = format("Hello, %s! You have %d messages.", "Alice", 3)
  # Result: "Hello, Alice! You have 3 messages."
}
```

### join() and split()

```hcl
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

locals {
  # Join list into string
  az_string = join(",", var.availability_zones)
  # Result: "us-east-1a,us-east-1b,us-east-1c"
  
  # Split string into list
  az_list = split(",", "us-east-1a,us-east-1b,us-east-1c")
  # Result: ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```

### lower() and upper()

```hcl
locals {
  env_lower = lower("PRODUCTION")
  # Result: "production"
  
  env_upper = upper("production")
  # Result: "PRODUCTION"
}
```

### replace()

```hcl
locals {
  # Replace substring
  formatted = replace("hello-world", "-", "_")
  # Result: "hello_world"
  
  # Replace with regex
  cleaned = replace("abc123def456", "/[0-9]/", "")
  # Result: "abcdef"
}
```

### substr()

```hcl
locals {
  # Extract substring
  short_id = substr("i-1234567890abcdef0", 0, 10)
  # Result: "i-12345678"
}
```

### trimspace()

```hcl
locals {
  cleaned = trimspace("  hello world  ")
  # Result: "hello world"
}
```

---

## Collection Functions

### length()

```hcl
variable "servers" {
  default = ["web1", "web2", "web3"]
}

locals {
  server_count = length(var.servers)
  # Result: 3
}
```

### concat()

```hcl
locals {
  list1 = ["a", "b"]
  list2 = ["c", "d"]
  
  combined = concat(list1, list2)
  # Result: ["a", "b", "c", "d"]
}
```

### merge()

```hcl
locals {
  default_tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
  
  custom_tags = {
    Project = "MyApp"
    Owner   = "TeamA"
  }
  
  all_tags = merge(local.default_tags, local.custom_tags)
  # Result: {
  #   Environment = "dev"
  #   ManagedBy   = "Terraform"
  #   Project     = "MyApp"
  #   Owner       = "TeamA"
  # }
}
```
