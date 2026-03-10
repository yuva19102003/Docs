# ⚙️ Core Workflow Commands

## Terraform Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Terraform Core Workflow                        │
└─────────────────────────────────────────────────────────────┘

  WRITE → INIT → PLAN → APPLY → DESTROY (optional)
    ↓       ↓      ↓       ↓         ↓
  .tf    Download Preview Execute  Remove
  files  providers changes changes  resources
```

---

## 1. terraform init

**Purpose:** Initialize a Terraform working directory.

### What it does:
- Downloads provider plugins
- Initializes backend configuration
- Downloads modules
- Creates `.terraform` directory
- Creates or updates `.terraform.lock.hcl`

### Basic Usage

```bash
# Initialize current directory
terraform init
```

### Common Options

```bash
# Upgrade providers to latest allowed version
terraform init -upgrade

# Reconfigure backend (ignore existing state)
terraform init -reconfigure

# Migrate state from one backend to another
terraform init -migrate-state

# Skip backend initialization
terraform init -backend=false
```


### Example Output

```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0

Terraform has been successfully initialized!
```

### Directory Structure After Init

```
project/
├── .terraform/           # Created by init
│   └── providers/        # Downloaded providers
├── .terraform.lock.hcl   # Provider version lock file
├── main.tf
└── variables.tf
```

---

## 2. terraform plan

**Purpose:** Preview changes before applying them.

### What it shows:
- Resources to be created (+)
- Resources to be modified (~)
- Resources to be destroyed (-)
- Resources to be replaced (-/+)

### Basic Usage

```bash
# Preview changes
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Show detailed changes
terraform plan -detailed-exitcode
```


### Example Plan Output

```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami           = "ami-0c55b159cbfafe1f0"
      + instance_type = "t2.micro"
      + id            = (known after apply)
      + public_ip     = (known after apply)
    }

  # aws_security_group.web will be modified
  ~ resource "aws_security_group" "web" {
      ~ ingress {
          + cidr_blocks = ["0.0.0.0/0"]
        }
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

### Plan Symbols

| Symbol | Meaning |
|--------|---------|
| `+` | Resource will be created |
| `-` | Resource will be destroyed |
| `~` | Resource will be modified in-place |
| `-/+` | Resource will be destroyed and recreated |
| `<=` | Resource will be read during apply |

---

## 3. terraform apply

**Purpose:** Execute the planned changes.

### Basic Usage

```bash
# Apply with confirmation prompt
terraform apply

# Apply without confirmation (CI/CD)
terraform apply -auto-approve

# Apply a saved plan
terraform apply tfplan

# Apply with variable override
terraform apply -var="instance_count=5"
```
