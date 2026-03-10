# 🗂️ Workspaces

## What are Workspaces?

Workspaces allow you to manage multiple environments with the same configuration.

```
┌────────────────────────────────────────────────────┐
│  Workspace Concept                                 │
├────────────────────────────────────────────────────┤
│                                                    │
│  Same Configuration                                │
│         ↓                                          │
│  ┌──────────────┐  ┌──────────────┐              │
│  │   dev        │  │   staging    │              │
│  │  workspace   │  │  workspace   │              │
│  │              │  │              │              │
│  │  state file  │  │  state file  │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
│  ┌──────────────┐                                 │
│  │   prod       │                                 │
│  │  workspace   │                                 │
│  │              │                                 │
│  │  state file  │                                 │
│  └──────────────┘                                 │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Workspace Commands

### List Workspaces

```bash
# List all workspaces
terraform workspace list

# Output:
#   default
# * dev
#   staging
#   prod
```

### Create Workspace

```bash
# Create new workspace
terraform workspace new dev

# Create and switch
terraform workspace new staging
```

### Switch Workspace

```bash
# Switch to existing workspace
terraform workspace select prod

# Output:
# Switched to workspace "prod".
```

### Show Current Workspace

```bash
# Show current workspace
terraform workspace show

# Output:
# dev
```

### Delete Workspace

```bash
# Delete workspace (must not be active)
terraform workspace delete staging

# Force delete (even with resources)
terraform workspace delete -force staging
```

---

## Using Workspaces in Configuration

### terraform.workspace Variable

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = terraform.workspace == "prod" ? "t2.large" : "t2.micro"
  
  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

### Environment-Specific Configuration

```hcl
locals {
  env_config = {
    dev = {
      instance_count = 1
      instance_type  = "t2.micro"
      db_size        = "db.t3.micro"
    }
    staging = {
      instance_count = 2
      instance_type  = "t2.small"
      db_size        = "db.t3.small"
    }
    prod = {
      instance_count = 5
      instance_type  = "t2.large"
      db_size        = "db.t3.large"
    }
  }
  
  current_env = local.env_config[terraform.workspace]
}

resource "aws_instance" "web" {
  count         = local.current_env.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = local.current_env.instance_type
  
  tags = {
    Name        = "web-${terraform.workspace}-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```
