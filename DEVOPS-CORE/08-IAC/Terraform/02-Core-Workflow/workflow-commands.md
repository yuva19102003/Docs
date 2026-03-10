# Complete Workflow Commands Reference

## Step-by-Step Workflow

### Step 1: Initialize

```bash
# Navigate to your Terraform directory
cd /path/to/terraform/project

# Initialize Terraform
terraform init

# Expected output:
# - Downloads providers
# - Initializes backend
# - Creates .terraform directory
```

### Step 2: Validate

```bash
# Validate configuration syntax
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 3: Format

```bash
# Format all .tf files
terraform fmt

# Check formatting without changes
terraform fmt -check

# Format recursively
terraform fmt -recursive
```

### Step 4: Plan

```bash
# Preview changes
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Target specific resource
terraform plan -target=aws_instance.web
```

### Step 5: Apply

```bash
# Apply changes (with confirmation)
terraform apply

# Apply saved plan (no confirmation needed)
terraform apply tfplan

# Apply with auto-approve
terraform apply -auto-approve
```

### Step 6: Verify

```bash
# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web
```


### Step 7: Output Values

```bash
# Show all outputs
terraform output

# Show specific output
terraform output vpc_id

# Output in JSON format
terraform output -json
```

### Step 8: Destroy (when needed)

```bash
# Destroy all resources (with confirmation)
terraform destroy

# Destroy specific resource
terraform destroy -target=aws_instance.web

# Destroy with auto-approve
terraform destroy -auto-approve
```

---

## Advanced Commands

### terraform refresh (Deprecated)

```bash
# OLD WAY (deprecated)
terraform refresh

# NEW WAY (recommended)
terraform apply -refresh-only
```

### terraform import

```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Import with module
terraform import module.vpc.aws_vpc.main vpc-12345678
```

### terraform taint (Deprecated)

```bash
# OLD WAY (deprecated)
terraform taint aws_instance.web

# NEW WAY (recommended)
terraform apply -replace=aws_instance.web
```

### terraform get

```bash
# Download/update modules
terraform get

# Update modules
terraform get -update
```

### terraform console

```bash
# Interactive console
terraform console

# Example usage in console:
> var.region
"us-east-1"

> aws_vpc.main.id
"vpc-12345678"

> length(aws_instance.web)
2
```
