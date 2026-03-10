# Module Sources

## Local Path

```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "vpc_relative" {
  source = "../shared-modules/vpc"
}
```

---

## Terraform Registry

```hcl
# Official HashiCorp module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
}
```

**Registry URL Format:**
```
<NAMESPACE>/<MODULE_NAME>/<PROVIDER>

Examples:
- terraform-aws-modules/vpc/aws
- hashicorp/consul/aws
- Azure/network/azurerm
```

---

## GitHub

### HTTPS

```hcl
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
}

# Specific branch
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=master"
}

# Specific tag
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.1.2"
}

# Specific commit
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=abc123"
}

# Subdirectory
module "vpc" {
  source = "github.com/hashicorp/example//modules/vpc"
}
```

### SSH

```hcl
module "vpc" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"
}
```

---

## Generic Git

```hcl
# HTTPS
module "vpc" {
  source = "git::https://example.com/vpc.git"
}

# SSH
module "vpc" {
  source = "git::ssh://git@example.com/vpc.git"
}

# With ref
module "vpc" {
  source = "git::https://example.com/vpc.git?ref=v1.2.0"
}
```

---

## S3 Bucket

```hcl
module "vpc" {
  source = "s3::https://s3.amazonaws.com/my-bucket/vpc.zip"
}

# With specific region
module "vpc" {
  source = "s3::https://s3-eu-west-1.amazonaws.com/my-bucket/vpc.zip"
}
```

---

## GCS Bucket

```hcl
module "vpc" {
  source = "gcs::https://www.googleapis.com/storage/v1/my-bucket/vpc.zip"
}
```

---

## HTTP/HTTPS

```hcl
module "vpc" {
  source = "https://example.com/vpc.zip"
}
```
