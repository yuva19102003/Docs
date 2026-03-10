# Lifecycle Meta-Argument

The `lifecycle` block controls how Terraform manages resource creation and destruction.

---

## 1. create_before_destroy

**Purpose:** Create replacement before destroying the old resource.

### Without create_before_destroy (Default)

```
┌─────────────────────────────────────────┐
│  Default Behavior                       │
├─────────────────────────────────────────┤
│                                         │
│  1. Destroy old resource                │
│  2. Create new resource                 │
│                                         │
│  ⚠️ Downtime during replacement         │
└─────────────────────────────────────────┘
```

### With create_before_destroy

```
┌─────────────────────────────────────────┐
│  create_before_destroy = true           │
├─────────────────────────────────────────┤
│                                         │
│  1. Create new resource                 │
│  2. Update references                   │
│  3. Destroy old resource                │
│                                         │
│  ✅ Zero downtime                       │
└─────────────────────────────────────────┘
```

### Example

```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity = 3
  max_size         = 5
  min_size         = 1
  
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
```

---

## 2. prevent_destroy

**Purpose:** Prevent accidental destruction of critical resources.

```hcl
resource "aws_db_instance" "production" {
  identifier        = "prod-database"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  lifecycle {
    prevent_destroy = true
  }
}

# If you try to destroy this resource:
# terraform destroy
# Error: Instance cannot be destroyed
```

**Use cases:**
- Production databases
- State storage buckets
- Critical infrastructure
- Resources with important data

---

## 3. ignore_changes

**Purpose:** Ignore changes to specific attributes.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
  }
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags,
      # Ignore changes to user_data
      user_data,
    ]
  }
}
```
