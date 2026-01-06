# Packer Examples - Complete Guide

## Overview

Packer is an open-source tool for creating identical machine images for multiple platforms from a single source configuration. This guide provides comprehensive examples for building images across different platforms.

## Table of Contents

1. [AWS AMI Examples](#aws-ami-examples)
2. [Docker Image Examples](#docker-image-examples)
3. [Azure Image Examples](#azure-image-examples)
4. [GCP Image Examples](#gcp-image-examples)
5. [Multi-Platform Builds](#multi-platform-builds)

## AWS AMI Examples

### 1. Basic Ubuntu AMI

```hcl
# ubuntu-ami.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_name_prefix" {
  type    = string
  default = "ubuntu-22.04-custom"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ssh_username = "ubuntu"

  tags = {
    Name        = "${var.ami_name_prefix}"
    Environment = "production"
    OS          = "Ubuntu 22.04"
    BuildDate   = "{{timestamp}}"
    ManagedBy   = "Packer"
  }

  run_tags = {
    Name = "Packer Builder - ${var.ami_name_prefix}"
  }
}

build {
  name = "ubuntu-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Update system packages
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git vim htop"
    ]
  }

  # Install Docker
  provisioner "shell" {
    script = "scripts/install-docker.sh"
  }

  # Install monitoring agents
  provisioner "shell" {
    script = "scripts/install-monitoring.sh"
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "history -c"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}
```

### 2. Web Server AMI with Nginx

```hcl
# nginx-ami.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "nginx_version" {
  type    = string
  default = "latest"
}

source "amazon-ebs" "nginx" {
  ami_name      = "nginx-webserver-{{timestamp}}"
  instance_type = "t3.small"
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"

  tags = {
    Name      = "nginx-webserver"
    Role      = "webserver"
    BuildDate = "{{timestamp}}"
  }
}

build {
  sources = ["source.amazon-ebs.nginx"]

  # System updates
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # Install Nginx
  provisioner "shell" {
    inline = [
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx"
    ]
  }

  # Configure Nginx
  provisioner "file" {
    source      = "configs/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo nginx -t"
    ]
  }

  # Deploy default website
  provisioner "file" {
    source      = "website/"
    destination = "/tmp/website"
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/www/html/*",
      "sudo cp -r /tmp/website/* /var/www/html/",
      "sudo chown -R www-data:www-data /var/www/html"
    ]
  }

  # Install SSL certificates (Let's Encrypt)
  provisioner "shell" {
    script = "scripts/setup-ssl.sh"
  }

  # Security hardening
  provisioner "shell" {
    script = "scripts/harden-security.sh"
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*"
    ]
  }
}
```

## Docker Image Examples

### 3. Node.js Application Image

```hcl
# nodejs-docker.pkr.hcl

packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "node_version" {
  type    = string
  default = "20-alpine"
}

variable "image_name" {
  type    = string
  default = "myapp"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

source "docker" "nodejs" {
  image  = "node:${var.node_version}"
  commit = true
  changes = [
    "EXPOSE 3000",
    "ENV NODE_ENV=production",
    "WORKDIR /app",
    "CMD [\"node\", \"server.js\"]"
  ]
}

build {
  sources = ["source.docker.nodejs"]

  # Install system dependencies
  provisioner "shell" {
    inline = [
      "apk add --no-cache curl wget git",
      "apk add --no-cache --virtual .build-deps python3 make g++"
    ]
  }

  # Copy application files
  provisioner "file" {
    source      = "app/"
    destination = "/app"
  }

  # Install npm dependencies
  provisioner "shell" {
    inline = [
      "cd /app",
      "npm ci --only=production",
      "npm cache clean --force"
    ]
  }

  # Remove build dependencies
  provisioner "shell" {
    inline = [
      "apk del .build-deps",
      "rm -rf /var/cache/apk/*"
    ]
  }

  # Create non-root user
  provisioner "shell" {
    inline = [
      "addgroup -g 1000 nodejs",
      "adduser -D -u 1000 -G nodejs nodejs",
      "chown -R nodejs:nodejs /app"
    ]
  }

  post-processor "docker-tag" {
    repository = var.image_name
    tags       = [var.image_tag, "{{timestamp}}"]
  }

  post-processor "docker-push" {
    login          = true
    login_username = var.docker_username
    login_password = var.docker_password
  }
}
```

### 4. Nginx Docker Image

```hcl
# nginx-docker.pkr.hcl

packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "nginx_version" {
  type    = string
  default = "1.25-alpine"
}

source "docker" "nginx" {
  image  = "nginx:${var.nginx_version}"
  commit = true
  changes = [
    "EXPOSE 80 443",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]"
  ]
}

build {
  sources = ["source.docker.nginx"]

  # Install additional tools
  provisioner "shell" {
    inline = [
      "apk add --no-cache curl openssl",
      "mkdir -p /etc/nginx/ssl"
    ]
  }

  # Copy custom Nginx configuration
  provisioner "file" {
    source      = "nginx/nginx.conf"
    destination = "/etc/nginx/nginx.conf"
  }

  provisioner "file" {
    source      = "nginx/conf.d/"
    destination = "/etc/nginx/conf.d/"
  }

  # Copy static website files
  provisioner "file" {
    source      = "html/"
    destination = "/usr/share/nginx/html/"
  }

  # Generate self-signed SSL certificate
  provisioner "shell" {
    inline = [
      "openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\",
      "  -keyout /etc/nginx/ssl/nginx.key \\",
      "  -out /etc/nginx/ssl/nginx.crt \\",
      "  -subj '/C=US/ST=State/L=City/O=Organization/CN=localhost'"
    ]
  }

  # Test Nginx configuration
  provisioner "shell" {
    inline = [
      "nginx -t"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
      "rm -rf /tmp/*"
    ]
  }

  post-processor "docker-tag" {
    repository = "custom-nginx"
    tags       = ["latest", "{{timestamp}}"]
  }
}
```

## Azure Image Examples

### 5. Azure VM Image

```hcl
# azure-vm.pkr.hcl

packer {
  required_plugins {
    azure = {
      version = ">= 1.4.5"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id" {
  type    = string
  default = env("ARM_CLIENT_ID")
}

variable "client_secret" {
  type      = string
  default   = env("ARM_CLIENT_SECRET")
  sensitive = true
}

variable "subscription_id" {
  type    = string
  default = env("ARM_SUBSCRIPTION_ID")
}

variable "tenant_id" {
  type    = string
  default = env("ARM_TENANT_ID")
}

variable "resource_group" {
  type    = string
  default = "packer-images-rg"
}

variable "location" {
  type    = string
  default = "East US"
}

source "azure-arm" "ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  managed_image_resource_group_name = var.resource_group
  managed_image_name                = "ubuntu-22.04-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"

  location = var.location
  vm_size  = "Standard_B2s"

  azure_tags = {
    Environment = "Production"
    ManagedBy   = "Packer"
    OS          = "Ubuntu 22.04"
  }
}

build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git vim"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-azure-cli.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo waagent -force -deprovision+user",
      "export HISTSIZE=0",
      "sync"
    ]
  }
}
```

## GCP Image Examples

### 6. Google Compute Engine Image

```hcl
# gcp-image.pkr.hcl

packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "project_id" {
  type    = string
  default = env("GCP_PROJECT_ID")
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}

source "googlecompute" "ubuntu" {
  project_id   = var.project_id
  source_image_family = var.image_family
  zone         = var.zone
  image_name   = "custom-ubuntu-{{timestamp}}"
  image_family = "custom-ubuntu"
  ssh_username = "packer"
  machine_type = "n1-standard-1"

  image_labels = {
    environment = "production"
    managed_by  = "packer"
  }
}

build {
  sources = ["source.googlecompute.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-gcloud-sdk.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*"
    ]
  }
}
```

## Multi-Platform Builds

### 7. Multi-Cloud Image Build

```hcl
# multi-cloud.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 1.4.5"
      source  = "github.com/hashicorp/azure"
    }
    googlecompute = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

# AWS Source
source "amazon-ebs" "app" {
  ami_name      = "multi-cloud-app-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

# Azure Source
source "azure-arm" "app" {
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id

  managed_image_resource_group_name = "packer-images-rg"
  managed_image_name                = "multi-cloud-app-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"

  location = "East US"
  vm_size  = "Standard_B2s"
}

# GCP Source
source "googlecompute" "app" {
  project_id          = var.gcp_project_id
  source_image_family = "ubuntu-2204-lts"
  zone                = "us-central1-a"
  image_name          = "multi-cloud-app-{{timestamp}}"
  ssh_username        = "packer"
  machine_type        = "n1-standard-1"
}

build {
  sources = [
    "source.amazon-ebs.app",
    "source.azure-arm.app",
    "source.googlecompute.app"
  ]

  # Common provisioning steps
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git vim htop"
    ]
  }

  provisioner "file" {
    source      = "app/"
    destination = "/tmp/app"
  }

  provisioner "shell" {
    script = "scripts/install-app.sh"
  }

  # Cloud-specific provisioning
  provisioner "shell" {
    only   = ["amazon-ebs.app"]
    script = "scripts/aws-specific.sh"
  }

  provisioner "shell" {
    only   = ["azure-arm.app"]
    script = "scripts/azure-specific.sh"
  }

  provisioner "shell" {
    only   = ["googlecompute.app"]
    script = "scripts/gcp-specific.sh"
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*"
    ]
  }
}
```

## Helper Scripts

### install-docker.sh

```bash
#!/bin/bash
set -e

echo "Installing Docker..."

# Install prerequisites
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

echo "Docker installation completed!"
```

### harden-security.sh

```bash
#!/bin/bash
set -e

echo "Hardening security..."

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install security packages
sudo apt-get install -y ufw fail2ban unattended-upgrades

# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Configure fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Enable automatic security updates
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

echo "Security hardening completed!"
```

## Building Images

### Build Commands

```bash
# Initialize Packer
packer init .

# Validate configuration
packer validate ubuntu-ami.pkr.hcl

# Format configuration
packer fmt ubuntu-ami.pkr.hcl

# Build image
packer build ubuntu-ami.pkr.hcl

# Build with variables
packer build -var 'aws_region=us-west-2' ubuntu-ami.pkr.hcl

# Build with variable file
packer build -var-file=variables.pkrvars.hcl ubuntu-ami.pkr.hcl

# Build specific sources only
packer build -only='amazon-ebs.ubuntu' multi-cloud.pkr.hcl

# Debug mode
packer build -debug ubuntu-ami.pkr.hcl

# Parallel builds
packer build -parallel-builds=3 multi-cloud.pkr.hcl
```

### Variables File (variables.pkrvars.hcl)

```hcl
aws_region      = "us-east-1"
instance_type   = "t3.small"
ami_name_prefix = "production-ubuntu"
```

## Best Practices

1. **Use HCL2 format** - Modern Packer configuration language
2. **Version control** - Store Packer templates in Git
3. **Validate before building** - Always run `packer validate`
4. **Use variables** - Make templates reusable
5. **Tag images** - Include metadata for tracking
6. **Automate builds** - Integrate with CI/CD
7. **Test images** - Validate built images before deployment
8. **Clean up** - Remove temporary files and caches
9. **Security first** - Harden images during build
10. **Document** - Include README with usage instructions

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Packer Images

on:
  push:
    branches: [main]
    paths:
      - 'packer/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Packer
        uses: hashicorp/setup-packer@main
        with:
          version: 'latest'

      - name: Initialize Packer
        run: packer init .
        working-directory: packer

      - name: Validate Packer template
        run: packer validate ubuntu-ami.pkr.hcl
        working-directory: packer

      - name: Build AMI
        run: packer build ubuntu-ami.pkr.hcl
        working-directory: packer
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Summary

Packer enables:
- **Consistent images** across multiple platforms
- **Automated builds** integrated with CI/CD
- **Version control** for infrastructure images
- **Fast deployments** with pre-configured images
- **Multi-cloud** support with single configuration

Use these examples as starting points and customize them for your specific infrastructure needs.
