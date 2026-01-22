# Self-Hosted GitHub Actions Runner - Server Setup

Complete guide to setting up and managing self-hosted GitHub Actions runners on Linux servers.

## Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                  Self-Hosted Runner Server Architecture                 │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                         GitHub                                │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Repository  │─>│   Workflow   │─>│  Job Queue   │      │
│  └──────────────┘  └──────────────┘  └──────┬───────┘      │
└─────────────────────────────────────────────┼───────────────┘
                                              │
                                              │ HTTPS
                                              │
┌─────────────────────────────────────────────┼───────────────┐
│                    Linux Server             │               │
│                                             ▼               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              systemd Service                          │  │
│  │                                                       │  │
│  │  actions.runner.ORG-REPO.RUNNER-NAME.service        │  │
│  └────────────────────────┬─────────────────────────────┘  │
│                           │                                │
│                           ▼                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Runner Process (github-runner user)        │  │
│  │                                                       │  │
│  │  • Polls GitHub for jobs                            │  │
│  │  • Downloads workflow code                          │  │
│  │  • Executes steps                                   │  │
│  │  • Reports status                                   │  │
│  └────────────────────────┬─────────────────────────────┘  │
│                           │                                │
│         ┌─────────────────┼─────────────────┐             │
│         │                 │                 │             │
│         ▼                 ▼                 ▼             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │    Work     │  │   Docker    │  │    Build    │      │
│  │  Directory  │  │   Engine    │  │    Tools    │      │
│  │             │  │             │  │             │      │
│  │  _work/     │  │  • Build    │  │  • Node.js  │      │
│  │  • Jobs     │  │  • Run      │  │  • Python   │      │
│  │  • Logs     │  │  • Push     │  │  • Go       │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
└──────────────────────────────────────────────────────────┘
         │                 │                 │
         └─────────────────┴─────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                      Monitoring                               │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Health Checks │  │     Logs     │  │   Metrics    │      │
│  │              │  │              │  │              │      │
│  │  • Service   │  │  • journalctl│  │  • CPU       │      │
│  │  • Disk      │  │  • _diag/    │  │  • Memory    │      │
│  │  • Network   │  │  • Rotation  │  │  • Disk      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Runner Lifecycle

```
GitHub                    Runner Service              Job Execution
  │                            │                            │
  │  1. Job Available          │                            │
  ├───────────────────────────>│                            │
  │                            │                            │
  │  2. Request Job            │                            │
  │<───────────────────────────┤                            │
  │                            │                            │
  │  3. Assign Job             │                            │
  ├───────────────────────────>│                            │
  │                            │                            │
  │                            │  4. Start Execution        │
  │                            ├───────────────────────────>│
  │                            │                            │
  │                            │  5. Checkout Code          │
  │<───────────────────────────┼────────────────────────────┤
  │                            │                            │
  │                            │  6. Run Steps              │
  │                            │                            │
  │                            │  7. Build/Test             │
  │                            │                            │
  │                            │  8. Docker Build           │
  │                            │                            │
  │                            │  9. Job Complete           │
  │                            │<───────────────────────────┤
  │                            │                            │
  │  10. Report Status         │                            │
  │<───────────────────────────┤                            │
  │                            │                            │
  │  11. Acknowledge           │                            │
  ├───────────────────────────>│                            │
  │                            │                            │
  │                            │  12. Cleanup               │
  │                            ├───────────────────────────>│
  │                            │                            │
```

## System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                         System Components                               │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      Linux Server                             │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                  systemd Service                        │  │
│  │                                                         │  │
│  │  • Auto-start on boot                                  │  │
│  │  • Restart on failure                                  │  │
│  │  • Resource limits (CPU, Memory)                       │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│                           ▼                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Runner User (github-runner)               │  │
│  │                                                         │  │
│  │  • Isolated environment                                │  │
│  │  • Limited permissions                                 │  │
│  │  • Docker group membership                             │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│         ┌─────────────────┼─────────────────┐               │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    Work     │  │   Docker    │  │  Security   │        │
│  │  Directory  │  │   Socket    │  │             │        │
│  │             │  │             │  │  • Firewall │        │
│  │  /tmp/      │  │  /var/run/  │  │  • Audit    │        │
│  │  runner/    │  │  docker.sock│  │  • Limits   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└──────────────────────────────────────────────────────────────┘
         │                 │                 │
         └─────────────────┴─────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                    Monitoring & Logging                       │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Health Check  │  │  Prometheus  │  │ Log Rotation │      │
│  │   Script     │  │   Exporter   │  │              │      │
│  │              │  │              │  │  • Daily     │      │
│  │  • Cron Job  │  │  • Metrics   │  │  • Compress  │      │
│  │  • Every 5m  │  │  • Alerts    │  │  • Cleanup   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation on Linux Server](#installation-on-linux-server)
- [Configuration](#configuration)
- [Running as a Service](#running-as-a-service)
- [Security Best Practices](#security-best-practices)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- Linux server (Ubuntu 20.04+ recommended)
- Minimum 2 CPU cores
- Minimum 4GB RAM
- 20GB+ disk space
- Root or sudo access

### Required Software
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl wget git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev
```

## Installation on Linux Server

### Step 1: Create a Dedicated User

```bash
# Create runner user
sudo useradd -m -s /bin/bash github-runner

# Add to docker group (if using Docker)
sudo usermod -aG docker github-runner

# Switch to runner user
sudo su - github-runner
```

### Step 2: Download and Extract Runner

```bash
# Create a folder
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Optional: Validate the hash
echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### Step 3: Configure the Runner

#### For Repository-Level Runner

```bash
# Get token from: https://github.com/YOUR_ORG/YOUR_REPO/settings/actions/runners/new

./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN

# Configure with labels
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN --labels self-hosted,linux,x64,production
```

#### For Organization-Level Runner

```bash
# Get token from: https://github.com/organizations/YOUR_ORG/settings/actions/runners/new

./config.sh --url https://github.com/YOUR_ORG --token YOUR_TOKEN --labels self-hosted,linux,x64,production
```

### Step 4: Test the Runner

```bash
# Run the runner interactively (for testing)
./run.sh
```

## Running as a Service

### Install as systemd Service

```bash
# Exit from github-runner user
exit

# Install the service (as root/sudo)
cd /home/github-runner/actions-runner
sudo ./svc.sh install github-runner

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status

# Enable auto-start on boot
sudo systemctl enable actions.runner.YOUR_ORG-YOUR_REPO.YOUR_RUNNER_NAME.service
```

### Service Management Commands

```bash
# Start service
sudo ./svc.sh start

# Stop service
sudo ./svc.sh stop

# Check status
sudo ./svc.sh status

# View logs
sudo journalctl -u actions.runner.* -f

# Restart service
sudo ./svc.sh stop && sudo ./svc.sh start
```

## Configuration

### Environment Variables

Create `/home/github-runner/actions-runner/.env`:

```bash
# Custom environment variables
NODE_ENV=production
DOCKER_HOST=unix:///var/run/docker.sock
PATH=/usr/local/bin:/usr/bin:/bin

# Proxy settings (if needed)
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=http://proxy.example.com:8080
NO_PROXY=localhost,127.0.0.1
```

### Runner Configuration File

Edit `/home/github-runner/actions-runner/.runner`:

```json
{
  "agentId": 1,
  "agentName": "production-runner-01",
  "poolId": 1,
  "poolName": "Default",
  "serverUrl": "https://github.com/YOUR_ORG",
  "gitHubUrl": "https://github.com/YOUR_ORG/YOUR_REPO",
  "workFolder": "_work"
}
```

### Custom Labels

```bash
# Add labels during configuration
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token YOUR_TOKEN \
  --labels self-hosted,linux,x64,production,gpu,high-memory

# Or reconfigure existing runner
./config.sh remove --token YOUR_TOKEN
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token YOUR_TOKEN \
  --labels self-hosted,linux,x64,production,gpu
```

## Security Best Practices

### 1. Isolate Runner User

```bash
# Limit sudo access
sudo visudo

# Add this line (only if necessary)
github-runner ALL=(ALL) NOPASSWD: /usr/bin/docker

# Better: Don't give sudo access at all
```

### 2. Use Dedicated Network

```bash
# Configure firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow from 192.168.1.0/24 to any port 443
sudo ufw deny incoming
sudo ufw allow outgoing
```

### 3. Secure Docker Access

```bash
# Create docker group with limited permissions
sudo groupadd docker-runners
sudo usermod -aG docker-runners github-runner

# Configure Docker daemon
sudo nano /etc/docker/daemon.json
```

```json
{
  "userns-remap": "github-runner",
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### 4. Implement Resource Limits

Create `/etc/systemd/system/actions.runner.*.service.d/override.conf`:

```ini
[Service]
# CPU limit (50% of one core)
CPUQuota=50%

# Memory limit
MemoryLimit=2G
MemoryMax=2G

# Process limit
TasksMax=100

# Restart policy
Restart=always
RestartSec=10
```

Apply changes:
```bash
sudo systemctl daemon-reload
sudo systemctl restart actions.runner.*
```

### 5. Enable Audit Logging

```bash
# Install auditd
sudo apt install auditd

# Add audit rules
sudo nano /etc/audit/rules.d/github-runner.rules
```

```bash
# Monitor runner directory
-w /home/github-runner/actions-runner/ -p wa -k github_runner
-w /home/github-runner/actions-runner/_work/ -p wa -k github_runner_work

# Monitor service
-w /etc/systemd/system/actions.runner.* -p wa -k github_runner_service
```

```bash
# Reload audit rules
sudo augenrules --load
```

## Monitoring and Maintenance

### Health Check Script

Create `/home/github-runner/health-check.sh`:

```bash
#!/bin/bash

RUNNER_NAME="production-runner-01"
LOG_FILE="/var/log/github-runner-health.log"

# Check if service is running
if ! systemctl is-active --quiet actions.runner.*; then
    echo "$(date): Runner service is not running" >> $LOG_FILE
    sudo systemctl start actions.runner.*
fi

# Check disk space
DISK_USAGE=$(df -h /home/github-runner | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "$(date): Disk usage is at ${DISK_USAGE}%" >> $LOG_FILE
    # Clean old work directories
    find /home/github-runner/actions-runner/_work -type d -mtime +7 -exec rm -rf {} +
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}' | cut -d. -f1)
if [ $MEM_USAGE -gt 90 ]; then
    echo "$(date): Memory usage is at ${MEM_USAGE}%" >> $LOG_FILE
fi

# Check runner connectivity
if ! curl -s https://github.com > /dev/null; then
    echo "$(date): Cannot reach GitHub" >> $LOG_FILE
fi
```

```bash
chmod +x /home/github-runner/health-check.sh

# Add to crontab
crontab -e
```

```cron
# Run health check every 5 minutes
*/5 * * * * /home/github-runner/health-check.sh
```

### Monitoring with Prometheus

Create `/home/github-runner/runner-exporter.sh`:

```bash
#!/bin/bash

# Export runner metrics for Prometheus
cat << EOF > /var/lib/node_exporter/textfile_collector/github_runner.prom
# HELP github_runner_status Runner status (1=running, 0=stopped)
# TYPE github_runner_status gauge
github_runner_status{runner="production-runner-01"} $(systemctl is-active --quiet actions.runner.* && echo 1 || echo 0)

# HELP github_runner_jobs_total Total jobs executed
# TYPE github_runner_jobs_total counter
github_runner_jobs_total{runner="production-runner-01"} $(grep -c "Running job" /home/github-runner/actions-runner/_diag/*.log 2>/dev/null || echo 0)
EOF
```

### Log Rotation

Create `/etc/logrotate.d/github-runner`:

```
/home/github-runner/actions-runner/_diag/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 github-runner github-runner
}
```

### Cleanup Script

Create `/home/github-runner/cleanup.sh`:

```bash
#!/bin/bash

# Clean old work directories
find /home/github-runner/actions-runner/_work -type d -mtime +7 -exec rm -rf {} + 2>/dev/null

# Clean Docker resources
docker system prune -af --volumes --filter "until=168h"

# Clean old logs
find /home/github-runner/actions-runner/_diag -name "*.log" -mtime +7 -delete

# Clean package caches
sudo apt-get clean
sudo apt-get autoclean

echo "$(date): Cleanup completed" >> /var/log/github-runner-cleanup.log
```

```bash
chmod +x /home/github-runner/cleanup.sh

# Schedule weekly cleanup
crontab -e
```

```cron
# Run cleanup every Sunday at 2 AM
0 2 * * 0 /home/github-runner/cleanup.sh
```

## Using the Self-Hosted Runner

### In Workflow File

```yaml
name: Use Self-Hosted Runner

on: [push]

jobs:
  build:
    runs-on: self-hosted  # Use any self-hosted runner
    
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner"
  
  build-with-labels:
    runs-on: [self-hosted, linux, x64, production]  # Use specific runner
    
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on production runner"
```

## Troubleshooting

### Runner Not Connecting

```bash
# Check service status
sudo systemctl status actions.runner.*

# View logs
sudo journalctl -u actions.runner.* -n 100 --no-pager

# Check network connectivity
curl -v https://github.com

# Verify token
./config.sh --check
```

### High Resource Usage

```bash
# Check running processes
ps aux | grep Runner.Listener

# Check Docker containers
docker ps
docker stats

# Check disk usage
du -sh /home/github-runner/actions-runner/_work/*

# Clean up
./run.sh --once  # Run one job and exit
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R github-runner:github-runner /home/github-runner/actions-runner

# Fix permissions
chmod +x /home/github-runner/actions-runner/*.sh

# Check Docker permissions
sudo usermod -aG docker github-runner
newgrp docker
```

### Service Won't Start

```bash
# Remove and reconfigure
cd /home/github-runner/actions-runner
sudo ./svc.sh uninstall
./config.sh remove --token YOUR_TOKEN

# Reconfigure
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN

# Reinstall service
sudo ./svc.sh install github-runner
sudo ./svc.sh start
```

## Updating the Runner

```bash
# Stop the service
sudo ./svc.sh stop

# Download new version
cd /home/github-runner
wget https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Backup current installation
cp -r actions-runner actions-runner.backup

# Extract new version
cd actions-runner
tar xzf ../actions-runner-linux-x64-2.311.0.tar.gz

# Start the service
sudo ./svc.sh start
```

## Removing the Runner

```bash
# Stop the service
sudo ./svc.sh stop

# Uninstall the service
sudo ./svc.sh uninstall

# Remove runner from GitHub
./config.sh remove --token YOUR_TOKEN

# Delete runner directory
cd ~
rm -rf actions-runner

# Remove user (optional)
sudo userdel -r github-runner
```

## Multiple Runners on Same Server

```bash
# Create separate directories
mkdir -p ~/actions-runner-1 ~/actions-runner-2

# Configure each runner separately
cd ~/actions-runner-1
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token TOKEN1 --name runner-1

cd ~/actions-runner-2
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token TOKEN2 --name runner-2

# Install both as services
cd ~/actions-runner-1 && sudo ./svc.sh install github-runner
cd ~/actions-runner-2 && sudo ./svc.sh install github-runner

# Start both
sudo systemctl start actions.runner.*
```

## Best Practices Summary

1. **Isolation**: Run runners in isolated environments
2. **Security**: Limit permissions, use firewalls, enable audit logging
3. **Monitoring**: Implement health checks and monitoring
4. **Maintenance**: Regular cleanup and updates
5. **Scaling**: Use multiple runners for high workload
6. **Backup**: Keep configuration backups
7. **Documentation**: Document custom configurations
8. **Testing**: Test runner setup before production use
