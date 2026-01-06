# ⚙️ Systemctl - Linux Service Management

**Complete guide to managing services with systemd and systemctl**

---

## 🎯 Overview

`systemctl` is the central management tool for controlling the systemd system and service manager. It's used to start, stop, restart, enable, disable, and check the status of services in modern Linux distributions.

---

## 📚 Understanding Systemd

### What is Systemd?

**Systemd** is a system and service manager for Linux operating systems. It:
- Initializes the system during boot
- Manages system services
- Handles system states
- Manages system resources

### Unit Types

Systemd manages different types of units:

| Unit Type | Extension | Purpose |
|-----------|-----------|---------|
| Service | `.service` | System services and daemons |
| Socket | `.socket` | IPC or network sockets |
| Device | `.device` | Device units |
| Mount | `.mount` | Mount points |
| Automount | `.automount` | Automount points |
| Target | `.target` | Group of units (like runlevels) |
| Timer | `.timer` | Timer-based activation |

---

## 🔧 Basic Service Management

### Start Services

```bash
# Start a service
sudo systemctl start service_name

# Start multiple services
sudo systemctl start service1 service2 service3
```

**Examples:**
```bash
sudo systemctl start nginx          # Start NGINX
sudo systemctl start apache2        # Start Apache
sudo systemctl start mysql          # Start MySQL
sudo systemctl start docker         # Start Docker
```

---

### Stop Services

```bash
# Stop a service
sudo systemctl stop service_name

# Stop multiple services
sudo systemctl stop service1 service2
```

**Examples:**
```bash
sudo systemctl stop nginx           # Stop NGINX
sudo systemctl stop apache2         # Stop Apache
```

---

### Restart Services

```bash
# Restart a service (stop then start)
sudo systemctl restart service_name

# Reload configuration without stopping
sudo systemctl reload service_name

# Reload if possible, otherwise restart
sudo systemctl reload-or-restart service_name
```

**Examples:**
```bash
sudo systemctl restart nginx        # Restart NGINX
sudo systemctl reload nginx         # Reload NGINX config
sudo systemctl reload-or-restart apache2
```

---

### Check Service Status

```bash
# Check service status
systemctl status service_name

# Check if service is active
systemctl is-active service_name

# Check if service is enabled
systemctl is-enabled service_name

# Check if service failed
systemctl is-failed service_name
```

**Examples:**
```bash
systemctl status nginx              # Detailed status
systemctl is-active nginx           # Returns: active or inactive
systemctl is-enabled nginx          # Returns: enabled or disabled
```

**Status Output Explained:**
```
● nginx.service - A high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2026-01-05 10:00:00 UTC; 2h 30min ago
     Docs: man:nginx(8)
 Main PID: 1234 (nginx)
    Tasks: 5 (limit: 4915)
   Memory: 10.5M
   CGroup: /system.slice/nginx.service
           ├─1234 nginx: master process /usr/sbin/nginx
           └─1235 nginx: worker process
```

---

## 🚀 Enable/Disable Services

### Enable Services (Start on Boot)

```bash
# Enable service to start on boot
sudo systemctl enable service_name

# Enable and start service immediately
sudo systemctl enable --now service_name
```

**Examples:**
```bash
sudo systemctl enable nginx         # Enable on boot
sudo systemctl enable --now docker  # Enable and start now
```

---

### Disable Services

```bash
# Disable service from starting on boot
sudo systemctl disable service_name

# Disable and stop service immediately
sudo systemctl disable --now service_name
```

**Examples:**
```bash
sudo systemctl disable apache2      # Disable on boot
sudo systemctl disable --now mysql  # Disable and stop now
```

---

### Mask/Unmask Services

```bash
# Mask service (prevent it from being started)
sudo systemctl mask service_name

# Unmask service
sudo systemctl unmask service_name
```

**Note:** Masked services cannot be started manually or automatically.

---

## 📋 Listing and Viewing Services

### List Services

```bash
# List all loaded units
systemctl list-units

# List all services
systemctl list-units --type=service

# List all active services
systemctl list-units --type=service --state=active

# List all failed services
systemctl list-units --type=service --state=failed

# List all installed unit files
systemctl list-unit-files

# List enabled services
systemctl list-unit-files --state=enabled
```

**Examples:**
```bash
systemctl list-units --type=service --state=running
systemctl list-units --type=service --state=failed
systemctl list-unit-files --type=service | grep enabled
```

---

### View Service Details

```bash
# Show service properties
systemctl show service_name

# Show specific property
systemctl show service_name -p Property

# View service file
systemctl cat service_name

# View service dependencies
systemctl list-dependencies service_name
```

**Examples:**
```bash
systemctl show nginx                        # All properties
systemctl show nginx -p MainPID             # Show PID
systemctl cat nginx                         # View service file
systemctl list-dependencies nginx           # Show dependencies
```

---

## 📝 Service Logs

### View Logs with journalctl

```bash
# View service logs
sudo journalctl -u service_name

# Follow logs in real-time
sudo journalctl -u service_name -f

# View logs since boot
sudo journalctl -u service_name -b

# View logs from last hour
sudo journalctl -u service_name --since "1 hour ago"

# View logs with priority
sudo journalctl -u service_name -p err

# View last N lines
sudo journalctl -u service_name -n 50
```

**Examples:**
```bash
sudo journalctl -u nginx -f                 # Follow NGINX logs
sudo journalctl -u ssh --since today        # SSH logs from today
sudo journalctl -u docker -n 100            # Last 100 Docker log lines
sudo journalctl -u apache2 -p err           # Apache errors only
```

**Time Specifications:**
```bash
--since "2026-01-05 10:00:00"
--since "1 hour ago"
--since "yesterday"
--since "2 days ago"
--until "2026-01-05 12:00:00"
```

---

## 🎯 System State Management

### System Targets (Runlevels)

```bash
# Get current target
systemctl get-default

# Set default target
sudo systemctl set-default multi-user.target

# List available targets
systemctl list-units --type=target

# Switch to target
sudo systemctl isolate multi-user.target
```

**Common Targets:**
- `poweroff.target` - Shutdown
- `rescue.target` - Single-user mode
- `multi-user.target` - Multi-user, no GUI (runlevel 3)
- `graphical.target` - Multi-user with GUI (runlevel 5)
- `reboot.target` - Reboot

---

### System Control

```bash
# Reboot system
sudo systemctl reboot

# Shutdown system
sudo systemctl poweroff

# Suspend system
sudo systemctl suspend

# Hibernate system
sudo systemctl hibernate

# Reload systemd configuration
sudo systemctl daemon-reload
```

---

## 🔧 Creating Custom Services

### Basic Service File Structure

**Location:** `/etc/systemd/system/myservice.service`

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=username
WorkingDirectory=/path/to/app
ExecStart=/path/to/executable
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

### Service Types

| Type | Description |
|------|-------------|
| `simple` | Main process specified in ExecStart |
| `forking` | Process forks and parent exits |
| `oneshot` | Process exits before starting next unit |
| `dbus` | Service acquires D-Bus name |
| `notify` | Service sends notification when ready |
| `idle` | Delayed until all jobs are dispatched |

---

### Example: Node.js Application Service

```ini
[Unit]
Description=Node.js Application
After=network.target

[Service]
Type=simple
User=nodeuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/node /opt/myapp/server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=myapp
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

**Steps to deploy:**
```bash
# Create service file
sudo nano /etc/systemd/system/myapp.service

# Reload systemd
sudo systemctl daemon-reload

# Start service
sudo systemctl start myapp

# Enable on boot
sudo systemctl enable myapp

# Check status
systemctl status myapp

# View logs
sudo journalctl -u myapp -f
```

---

### Example: Python Application Service

```ini
[Unit]
Description=Python Flask Application
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/myapp
Environment="PATH=/var/www/myapp/venv/bin"
ExecStart=/var/www/myapp/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

### Example: Docker Container Service

```ini
[Unit]
Description=My Docker Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start mycontainer
ExecStop=/usr/bin/docker stop mycontainer
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## 💡 Practical Examples

### Example 1: Manage Web Server

```bash
# Install NGINX
sudo apt install nginx

# Start NGINX
sudo systemctl start nginx

# Enable on boot
sudo systemctl enable nginx

# Check status
systemctl status nginx

# Reload configuration
sudo systemctl reload nginx

# View logs
sudo journalctl -u nginx -f
```

---

### Example 2: Troubleshoot Failed Service

```bash
# Check failed services
systemctl --failed

# Check specific service status
systemctl status service_name

# View detailed logs
sudo journalctl -u service_name -n 100

# View errors only
sudo journalctl -u service_name -p err

# Restart service
sudo systemctl restart service_name

# If service file changed
sudo systemctl daemon-reload
sudo systemctl restart service_name
```

---

### Example 3: Create Backup Service with Timer

**Service file:** `/etc/systemd/system/backup.service`
```ini
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

**Timer file:** `/etc/systemd/system/backup.timer`
```ini
[Unit]
Description=Run backup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable timer:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
systemctl list-timers
```

---

## 🎯 Best Practices

### 1. Always Check Status After Changes
```bash
sudo systemctl restart nginx
systemctl status nginx
```

### 2. Use Reload Instead of Restart When Possible
```bash
sudo systemctl reload nginx  # Doesn't drop connections
```

### 3. Enable Services You Want on Boot
```bash
sudo systemctl enable --now service_name
```

### 4. Monitor Logs for Issues
```bash
sudo journalctl -u service_name -f
```

### 5. Use daemon-reload After Editing Service Files
```bash
sudo systemctl daemon-reload
```

### 6. Test Services Before Enabling
```bash
sudo systemctl start service_name
systemctl status service_name
# If OK, then enable
sudo systemctl enable service_name
```

---

## 🔗 Related Topics

- **Package Management:** `03-Package-Management.md`
- **Process Management:** `05-Process-Management.md`
- **System Monitoring:** `06-System-Monitoring.md`

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete

