# 💾 State Management

## What is Terraform State?

Terraform state is a JSON file that maps your configuration to real-world resources.

```
┌────────────────────────────────────────────────────────┐
│  Terraform State Purpose                               │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Configuration (.tf)  ←→  State  ←→  Real Resources   │
│                                                        │
│  What you want       Mapping      What exists         │
│  to create                         in cloud           │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## State Files

### terraform.tfstate

Default local state file storing current infrastructure state.

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 1,
  "lineage": "abc-123-def",
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t2.micro",
            "public_ip": "54.123.45.67"
          }
        }
      ]
    }
  ]
}
```

### terraform.tfstate.backup

Previous state backup; auto-created before each apply.

```
Before apply:  terraform.tfstate (version 5)
After apply:   terraform.tfstate (version 6)
               terraform.tfstate.backup (version 5)
```

---

## State Commands

### List Resources

```bash
# List all resources in state
terraform state list

# Output:
# aws_vpc.main
# aws_subnet.public
# aws_instance.web[0]
# aws_instance.web[1]
```


### Show Resource Details

```bash
# Show details of specific resource
terraform state show aws_instance.web

# Output:
# resource "aws_instance" "web" {
#     ami           = "ami-0c55b159cbfafe1f0"
#     id            = "i-1234567890abcdef0"
#     instance_type = "t2.micro"
#     public_ip     = "54.123.45.67"
#     ...
# }
```

### Move Resources

```bash
# Rename resource in state
terraform state mv aws_instance.web aws_instance.app

# Move to module
terraform state mv aws_instance.web module.ec2.aws_instance.web

# Move from module
terraform state mv module.ec2.aws_instance.web aws_instance.web
```

### Remove Resources

```bash
# Remove from state (does NOT destroy real resource)
terraform state rm aws_instance.web

# Remove all instances of a resource with count
terraform state rm 'aws_instance.web[*]'
```

### Pull/Push State

```bash
# Download remote state
terraform state pull > terraform.tfstate

# Upload local state (use carefully!)
terraform state push terraform.tfstate
```

---

## Remote State

### Why Use Remote State?

```
┌────────────────────────────────────────────────────┐
│  Local State Problems                              │
├────────────────────────────────────────────────────┤
│  ❌ No collaboration                               │
│  ❌ No locking                                     │
│  ❌ No backup                                      │
│  ❌ Stored on local disk                          │
│  ❌ Risk of loss                                   │
└────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│  Remote State Benefits                             │
├────────────────────────────────────────────────────┤
│  ✅ Team collaboration                             │
│  ✅ State locking                                  │
│  ✅ Automatic backup                               │
│  ✅ Encryption at rest                             │
│  ✅ Version history                                │
└────────────────────────────────────────────────────┘
```
