# Self-Hosted GitHub Actions Runner - Advanced Setups

Comprehensive guide to advanced self-hosted runner configurations including cloud platforms, VM orchestration, and specialized environments.

## Multi-Cloud Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Multi-Cloud Runner Architecture                      │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                         GitHub                                │
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   Workflow   │────────>│  Job Queue   │                  │
│  │   Trigger    │         │              │                  │
│  └──────────────┘         └──────┬───────┘                  │
└─────────────────────────────────┼───────────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      AWS        │    │      Azure      │    │      GCP        │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │    EC2    │  │    │  │   VMSS    │  │    │  │    MIG    │  │
│  │Auto Scaling│  │    │  │           │  │    │  │           │  │
│  └─────┬─────┘  │    │  └─────┬─────┘  │    │  └─────┬─────┘  │
│        │        │    │        │        │    │        │        │
│        ▼        │    │        ▼        │    │        ▼        │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Launch   │  │    │  │    ARM    │  │    │  │ Instance  │  │
│  │ Template  │  │    │  │  Template │  │    │  │ Template  │  │
│  └─────┬─────┘  │    │  └─────┬─────┘  │    │  └─────┬─────┘  │
│        │        │    │        │        │    │        │        │
│        ▼        │    │        ▼        │    │        ▼        │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Runner   │  │    │  │  Runner   │  │    │  │  Runner   │  │
│  │Instances  │  │    │  │    VMs    │  │    │  │ Instances │  │
│  │           │  │    │  │           │  │    │  │           │  │
│  │  • i1     │  │    │  │  • vm1    │  │    │  │  • i1     │  │
│  │  • i2     │  │    │  │  • vm2    │  │    │  │  • i2     │  │
│  │  • iN     │  │    │  │  • vmN    │  │    │  │  • iN     │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                      │
         └──────────────────────┴──────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                    On-Premises                                │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Physical   │  │   Virtual    │  │  Containers  │      │
│  │   Servers    │  │   Machines   │  │              │      │
│  │              │  │              │  │  • Docker    │      │
│  │  • Server 1  │  │  • VM 1      │  │  • K8s       │      │
│  │  • Server 2  │  │  • VM 2      │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

(Continuing with remaining diagrams in the same ASCII style...)

## Table of Contents
- [AWS EC2 Auto-Scaling](#aws-ec2-auto-scaling)
- [Azure VM Scale Sets](#azure-vm-scale-sets)
- [Google Cloud Compute](#google-cloud-compute)
- [Terraform Automation](#terraform-automation)
- [Ansible Configuration](#ansible-configuration)
- [Windows Runners](#windows-runners)
- [macOS Runners](#macos-runners)
- [ARM Architecture](#arm-architecture)
- [Ephemeral Runners](#ephemeral-runners)
- [Runner Pools](#runner-pools)

## AWS EC2 Auto-Scaling

### Launch Template

Create `runner-launch-template.json`:

```json
{
  "LaunchTemplateName": "github-runner-template",
  "LaunchTemplateData": {
    "ImageId": "ami-0c55b159cbfafe1f0",
    "InstanceType": "t3.medium",
    "KeyName": "your-key-pair",
    "IamInstanceProfile": {
      "Name": "github-runner-role"
    },
    "SecurityGroupIds": ["sg-xxxxxxxxx"],
    "UserData": "BASE64_ENCODED_SCRIPT",
    "TagSpecifications": [
      {
        "ResourceType": "instance",
        "Tags": [
          {
            "Key": "Name",
            "Value": "github-runner"
          },
          {
            "Key": "Environment",
            "Value": "production"
          }
        ]
      }
    ]
  }
}
```

### User Data Script

Create `user-data.sh`:

```bash
#!/bin/bash

# Update system
yum update -y

# Install dependencies
yum install -y git curl wget docker

# Start Docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Create runner user
useradd -m -s /bin/bash github-runner
usermod -aG docker github-runner

# Switch to runner user
su - github-runner << 'EOF'

# Download runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Get registration token from AWS Secrets Manager
RUNNER_TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id github-runner-token \
  --query SecretString \
  --output text \
  --region us-east-1)

# Configure runner
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $RUNNER_TOKEN \
  --name $(hostname) \
  --labels self-hosted,aws,ec2 \
  --unattended \
  --ephemeral

# Run runner
./run.sh

EOF
```

### Auto Scaling Group

```bash
# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name github-runners-asg \
  --launch-template LaunchTemplateName=github-runner-template,Version='$Latest' \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 3 \
  --vpc-zone-identifier "subnet-xxxxx,subnet-yyyyy" \
  --health-check-type EC2 \
  --health-check-grace-period 300 \
  --tags Key=Name,Value=github-runner,PropagateAtLaunch=true
```

### CloudWatch-Based Scaling

```bash
# Scale up policy
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name github-runners-asg \
  --policy-name scale-up \
  --scaling-adjustment 2 \
  --adjustment-type ChangeInCapacity \
  --cooldown 300

# Scale down policy
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name github-runners-asg \
  --policy-name scale-down \
  --scaling-adjustment -1 \
  --adjustment-type ChangeInCapacity \
  --cooldown 300

# CloudWatch alarm for scale up
aws cloudwatch put-metric-alarm \
  --alarm-name github-runners-high-cpu \
  --alarm-description "Scale up when CPU > 70%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:autoscaling:region:account:scalingPolicy:policy-id
```

### Lambda-Based Auto-Scaling

Create `lambda-scaler.py`:

```python
import boto3
import requests
import os

def lambda_handler(event, context):
    # GitHub API
    github_token = os.environ['GITHUB_TOKEN']
    repo = os.environ['GITHUB_REPO']
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Get queued jobs
    url = f'https://api.github.com/repos/{repo}/actions/runs?status=queued'
    response = requests.get(url, headers=headers)
    queued_jobs = len(response.json()['workflow_runs'])
    
    # Auto Scaling
    asg_client = boto3.client('autoscaling')
    asg_name = os.environ['ASG_NAME']
    
    # Get current capacity
    response = asg_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )
    current_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']
    
    # Calculate desired capacity
    min_capacity = 2
    max_capacity = 20
    desired_capacity = min(max(queued_jobs, min_capacity), max_capacity)
    
    # Update capacity
    if desired_capacity != current_capacity:
        asg_client.set_desired_capacity(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=desired_capacity
        )
        print(f'Scaled from {current_capacity} to {desired_capacity}')
    
    return {
        'statusCode': 200,
        'body': f'Desired capacity: {desired_capacity}'
    }
```

## Azure VM Scale Sets

### ARM Template

Create `vmss-template.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmssName": {
      "type": "string",
      "defaultValue": "github-runners-vmss"
    },
    "instanceCount": {
      "type": "int",
      "defaultValue": 3
    }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachineScaleSets",
      "apiVersion": "2021-03-01",
      "name": "[parameters('vmssName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "Standard_D2s_v3",
        "tier": "Standard",
        "capacity": "[parameters('instanceCount')]"
      },
      "properties": {
        "overprovision": false,
        "upgradePolicy": {
          "mode": "Manual"
        },
        "virtualMachineProfile": {
          "osProfile": {
            "computerNamePrefix": "runner",
            "adminUsername": "azureuser",
            "customData": "[base64(variables('cloudInit'))]"
          },
          "storageProfile": {
            "imageReference": {
              "publisher": "Canonical",
              "offer": "UbuntuServer",
              "sku": "20.04-LTS",
              "version": "latest"
            }
          },
          "networkProfile": {
            "networkInterfaceConfigurations": [
              {
                "name": "nic",
                "properties": {
                  "primary": true,
                  "ipConfigurations": [
                    {
                      "name": "ipconfig",
                      "properties": {
                        "subnet": {
                          "id": "[variables('subnetId')]"
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
  ]
}
```

### Cloud-Init Script

```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - git
  - curl
  - wget
  - docker.io

runcmd:
  - systemctl start docker
  - systemctl enable docker
  - useradd -m -s /bin/bash github-runner
  - usermod -aG docker github-runner
  - |
    su - github-runner -c '
    mkdir actions-runner && cd actions-runner
    curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
      https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
    tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
    
    RUNNER_TOKEN=$(az keyvault secret show --name github-runner-token --vault-name my-keyvault --query value -o tsv)
    
    ./config.sh \
      --url https://github.com/YOUR_ORG/YOUR_REPO \
      --token $RUNNER_TOKEN \
      --name $(hostname) \
      --labels self-hosted,azure,vmss \
      --unattended \
      --ephemeral
    
    ./run.sh &
    '
```

### Auto-Scaling Rules

```bash
# Create autoscale profile
az monitor autoscale create \
  --resource-group myResourceGroup \
  --resource github-runners-vmss \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name github-runners-autoscale \
  --min-count 2 \
  --max-count 20 \
  --count 3

# Scale out rule
az monitor autoscale rule create \
  --resource-group myResourceGroup \
  --autoscale-name github-runners-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 2

# Scale in rule
az monitor autoscale rule create \
  --resource-group myResourceGroup \
  --autoscale-name github-runners-autoscale \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1
```

## Google Cloud Compute

### Instance Template

```bash
# Create instance template
gcloud compute instance-templates create github-runner-template \
  --machine-type=n1-standard-2 \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=50GB \
  --boot-disk-type=pd-standard \
  --tags=github-runner \
  --metadata-from-file=startup-script=startup.sh \
  --scopes=cloud-platform
```

### Startup Script

Create `startup.sh`:

```bash
#!/bin/bash

# Install dependencies
apt-get update
apt-get install -y git curl wget docker.io

# Start Docker
systemctl start docker
systemctl enable docker

# Create runner user
useradd -m -s /bin/bash github-runner
usermod -aG docker github-runner

# Get token from Secret Manager
RUNNER_TOKEN=$(gcloud secrets versions access latest --secret="github-runner-token")

# Setup runner
su - github-runner << 'EOF'
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $RUNNER_TOKEN \
  --name $(hostname) \
  --labels self-hosted,gcp,compute \
  --unattended \
  --ephemeral

./run.sh &
EOF
```

### Managed Instance Group

```bash
# Create managed instance group
gcloud compute instance-groups managed create github-runners-mig \
  --base-instance-name=github-runner \
  --template=github-runner-template \
  --size=3 \
  --zone=us-central1-a

# Configure autoscaling
gcloud compute instance-groups managed set-autoscaling github-runners-mig \
  --zone=us-central1-a \
  --min-num-replicas=2 \
  --max-num-replicas=20 \
  --target-cpu-utilization=0.7 \
  --cool-down-period=300
```

## Terraform Automation

### Complete Infrastructure

Create `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Security group for GitHub runners"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "github-runner-sg"
  }
}

# IAM Role
resource "aws_iam_role" "runner_role" {
  name = "github-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "github-runner-profile"
  role = aws_iam_role.runner_role.name
}

# Launch Template
resource "aws_launch_template" "runner_template" {
  name_prefix   = "github-runner-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.runner_profile.name
  }

  vpc_security_group_ids = [aws_security_group.runner_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    github_token = var.github_token
    repo_url     = var.repo_url
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "github-runner"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "runner_asg" {
  name                = "github-runners-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.runner_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "github-runner"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.runner_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.runner_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "github-runners-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.runner_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "github-runners-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.runner_asg.name
  }
}
```

Create `variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}

variable "repo_url" {
  description = "Repository URL"
  type        = string
}

variable "min_size" {
  description = "Minimum number of runners"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of runners"
  default     = 20
}

variable "desired_capacity" {
  description = "Desired number of runners"
  default     = 3
}
```

## Ansible Configuration

Create `playbook.yml`:

```yaml
---
- name: Setup GitHub Actions Runner
  hosts: runners
  become: yes
  vars:
    runner_version: "2.311.0"
    runner_user: "github-runner"
    repo_url: "https://github.com/YOUR_ORG/YOUR_REPO"
    runner_token: "{{ lookup('env', 'RUNNER_TOKEN') }}"

  tasks:
    - name: Update system
      apt:
        update_cache: yes
        upgrade: dist

    - name: Install dependencies
      apt:
        name:
          - git
          - curl
          - wget
          - docker.io
          - jq
        state: present

    - name: Start Docker
      systemd:
        name: docker
        state: started
        enabled: yes

    - name: Create runner user
      user:
        name: "{{ runner_user }}"
        shell: /bin/bash
        create_home: yes
        groups: docker
        append: yes

    - name: Create runner directory
      file:
        path: "/home/{{ runner_user }}/actions-runner"
        state: directory
        owner: "{{ runner_user }}"
        group: "{{ runner_user }}"

    - name: Download runner
      get_url:
        url: "https://github.com/actions/runner/releases/download/v{{ runner_version }}/actions-runner-linux-x64-{{ runner_version }}.tar.gz"
        dest: "/home/{{ runner_user }}/actions-runner/runner.tar.gz"
        owner: "{{ runner_user }}"
        group: "{{ runner_user }}"

    - name: Extract runner
      unarchive:
        src: "/home/{{ runner_user }}/actions-runner/runner.tar.gz"
        dest: "/home/{{ runner_user }}/actions-runner"
        remote_src: yes
        owner: "{{ runner_user }}"
        group: "{{ runner_user }}"

    - name: Configure runner
      become_user: "{{ runner_user }}"
      shell: |
        cd /home/{{ runner_user }}/actions-runner
        ./config.sh \
          --url {{ repo_url }} \
          --token {{ runner_token }} \
          --name {{ ansible_hostname }} \
          --labels self-hosted,ansible,{{ ansible_distribution | lower }} \
          --unattended \
          --replace
      args:
        creates: "/home/{{ runner_user }}/actions-runner/.runner"

    - name: Install runner service
      shell: |
        cd /home/{{ runner_user }}/actions-runner
        ./svc.sh install {{ runner_user }}
      args:
        creates: "/etc/systemd/system/actions.runner.*"

    - name: Start runner service
      systemd:
        name: "actions.runner.*.service"
        state: started
        enabled: yes
        daemon_reload: yes
```

## Windows Runners

### PowerShell Setup Script

Create `setup-windows-runner.ps1`:

```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dependencies
choco install -y git
choco install -y docker-desktop
choco install -y nodejs
choco install -y python

# Create runner directory
New-Item -ItemType Directory -Path C:\actions-runner -Force
Set-Location C:\actions-runner

# Download runner
$runnerVersion = "2.311.0"
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$runnerVersion/actions-runner-win-x64-$runnerVersion.zip" -OutFile "actions-runner.zip"

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner.zip", "$PWD")

# Configure
$repoUrl = "https://github.com/YOUR_ORG/YOUR_REPO"
$token = $env:RUNNER_TOKEN

.\config.cmd --url $repoUrl --token $token --name $env:COMPUTERNAME --labels self-hosted,windows --unattended --replace

# Install as service
.\svc.cmd install
.\svc.cmd start
```

## macOS Runners

### Setup Script

Create `setup-macos-runner.sh`:

```bash
#!/bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git
brew install node
brew install python

# Create runner directory
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download runner
curl -o actions-runner-osx-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz

# Configure
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $RUNNER_TOKEN \
  --name $(hostname) \
  --labels self-hosted,macos \
  --unattended \
  --replace

# Install as service
./svc.sh install
./svc.sh start
```

## ARM Architecture

### ARM64 Setup

```bash
#!/bin/bash

# For Raspberry Pi or ARM servers

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git curl wget docker.io

# Create runner user
sudo useradd -m -s /bin/bash github-runner
sudo usermod -aG docker github-runner

# Download ARM64 runner
su - github-runner << 'EOF'
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz

./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $RUNNER_TOKEN \
  --name $(hostname) \
  --labels self-hosted,arm64,linux \
  --unattended

./run.sh &
EOF
```

## Ephemeral Runners

### One-Time Use Configuration

```bash
# Configure ephemeral runner
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $RUNNER_TOKEN \
  --name ephemeral-runner-$(date +%s) \
  --labels self-hosted,ephemeral \
  --ephemeral \
  --unattended

# Runner will automatically deregister after one job
./run.sh
```

### Auto-Cleanup Script

```bash
#!/bin/bash

while true; do
  # Start runner
  ./run.sh
  
  # Clean up after job
  docker system prune -af
  rm -rf _work/*
  
  # Wait before next job
  sleep 10
done
```

## Runner Pools

### Multi-Environment Setup

```bash
# Production pool
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $PROD_TOKEN \
  --name prod-runner-01 \
  --labels self-hosted,production,linux \
  --runnergroup production

# Staging pool
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $STAGING_TOKEN \
  --name staging-runner-01 \
  --labels self-hosted,staging,linux \
  --runnergroup staging

# Development pool
./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token $DEV_TOKEN \
  --name dev-runner-01 \
  --labels self-hosted,development,linux \
  --runnergroup development
```

### Using in Workflows

```yaml
name: Multi-Environment Deployment

on: [push]

jobs:
  test-dev:
    runs-on: [self-hosted, development]
    steps:
      - uses: actions/checkout@v4
      - run: npm test
  
  deploy-staging:
    needs: test-dev
    runs-on: [self-hosted, staging]
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh staging
  
  deploy-production:
    needs: deploy-staging
    runs-on: [self-hosted, production]
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh production
```
