# Terraform Backends

## Backend Types

### 1. Local Backend (Default)

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

**Use case:** Single developer, testing, learning

---

### 2. S3 Backend (AWS)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Setup Steps:**

```bash
# 1. Create S3 bucket
aws s3api create-bucket \
  --bucket my-terraform-state \
  --region us-east-1

# 2. Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state \
  --versioning-configuration Status=Enabled

# 3. Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 4. Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**Complete Example:**

```hcl
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    
    # Optional: Use specific profile
    profile = "terraform"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```


---

### 3. GCS Backend (Google Cloud)

```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "prod"
  }
}
```

---

### 4. Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

---

### 5. Terraform Cloud Backend

```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

---

## State Locking

### What is State Locking?

```
┌────────────────────────────────────────────────────┐
│  Without Locking                                   │
├────────────────────────────────────────────────────┤
│                                                    │
│  User A: terraform apply (starts)                 │
│  User B: terraform apply (starts)                 │
│                                                    │
│  Result: Corrupted state, race conditions         │
│                                                    │
└────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│  With Locking                                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  User A: terraform apply (acquires lock)          │
│  User B: terraform apply (waits for lock)         │
│  User A: completes (releases lock)                │
│  User B: proceeds (acquires lock)                 │
│                                                    │
│  Result: Safe, sequential operations              │
│                                                    │
└────────────────────────────────────────────────────┘
```

### Force Unlock

```bash
# If lock is stuck
terraform force-unlock <LOCK_ID>

# Example
terraform force-unlock 1234567890abcdef
```
