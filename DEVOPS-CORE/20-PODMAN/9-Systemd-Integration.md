# Podman systemd Integration

## Overview

Podman integrates seamlessly with systemd for managing containers as system services with auto-start, restart policies, and logging.

## Generate systemd Unit Files

### For Containers

```bash
# Run container
podman run -d --name web -p 8080:80 nginx

# Generate unit file
podman generate systemd --name web > ~/.config/systemd/user/container-web.service

# For system-wide (requires root)
sudo podman generate systemd --name web > /etc/systemd/system/container-web.service
```

### For Pods

```bash
# Create pod
podman pod create --name webapp -p 8080:80

# Add containers
podman run -d --pod webapp --name web nginx
podman run -d --pod webapp --name app myapp

# Generate unit files for pod
podman generate systemd --name webapp --files

# This creates:
# - pod-webapp.service
# - container-webapp-web.service
# - container-webapp-app.service
```

## User Services (Rootless)

### Setup User Services

```bash
# Enable lingering (services run without login)
loginctl enable-linger $USER

# Create user systemd directory
mkdir -p ~/.config/systemd/user/
```

### Create Service

```bash
# Run container
podman run -d --name myapp -p 8080:80 myapp:latest

# Generate service file
podman generate systemd --new --name myapp > ~/.config/systemd/user/myapp.service

# Reload systemd
systemctl --user daemon-reload

# Enable service
systemctl --user enable myapp.service

# Start service
systemctl --user start myapp.service

# Check status
systemctl --user status myapp.service
```

### Manage User Services

```bash
# Start service
systemctl --user start myapp

# Stop service
systemctl --user stop myapp

# Restart service
systemctl --user restart myapp

# Enable on boot
systemctl --user enable myapp

# Disable
systemctl --user disable myapp

# View logs
journalctl --user -u myapp -f
```

## System Services (Root)

### Create System Service

```bash
# Run as root
sudo podman run -d --name web -p 80:80 nginx

# Generate service
sudo podman generate systemd --new --name web > /etc/systemd/system/web.service

# Reload systemd
sudo systemctl daemon-reload

# Enable and start
sudo systemctl enable --now web.service
```

### Manage System Services

```bash
# Start
sudo systemctl start web

# Stop
sudo systemctl stop web

# Status
sudo systemctl status web

# Logs
sudo journalctl -u web -f
```

## Service File Options

### Basic Service File

```ini
[Unit]
Description=My Application Container
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
Restart=always
RestartSec=10
ExecStartPre=/usr/bin/podman pull myapp:latest
ExecStart=/usr/bin/podman run -d --name myapp -p 8080:80 myapp:latest
ExecStop=/usr/bin/podman stop -t 10 myapp
ExecStopPost=/usr/bin/podman rm -f myapp

[Install]
WantedBy=multi-user.target
```

### Advanced Options

```ini
[Unit]
Description=Web Application
After=network-online.target
Wants=network-online.target
Requires=container-db.service
After=container-db.service

[Service]
Type=forking
Restart=on-failure
RestartSec=30
TimeoutStartSec=300
TimeoutStopSec=70

# Environment
Environment="PODMAN_SYSTEMD_UNIT=%n"
EnvironmentFile=/etc/myapp.env

# Pre-start
ExecStartPre=/usr/bin/podman pull myapp:latest
ExecStartPre=/usr/bin/podman network create mynet || true

# Start
ExecStart=/usr/bin/podman run \
  --name myapp \
  --network mynet \
  -p 8080:80 \
  -v myapp-data:/data \
  myapp:latest

# Stop
ExecStop=/usr/bin/podman stop -t 10 myapp
ExecStopPost=/usr/bin/podman rm -f myapp

# Reload
ExecReload=/usr/bin/podman restart myapp

[Install]
WantedBy=multi-user.target
```

## Pod Services

### Generate Pod Services

```bash
# Create pod
podman pod create --name webapp -p 8080:80

# Add containers
podman run -d --pod webapp --name web nginx
podman run -d --pod webapp --name app myapp

# Generate all services
podman generate systemd --new --files --name webapp

# Move to systemd directory
mv pod-webapp.service ~/.config/systemd/user/
mv container-webapp-*.service ~/.config/systemd/user/

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable pod-webapp.service
systemctl --user start pod-webapp.service
```

## Auto-Update Containers

### Enable Auto-Updates

```bash
# Run with auto-update label
podman run -d \
  --name web \
  --label "io.containers.autoupdate=registry" \
  nginx:latest

# Generate service with auto-update
podman generate systemd --new --name web > web.service

# Enable auto-update timer
systemctl --user enable --now podman-auto-update.timer

# Check timer status
systemctl --user list-timers

# Manual update
podman auto-update
```

## Logging

### View Logs

```bash
# User service logs
journalctl --user -u myapp

# Follow logs
journalctl --user -u myapp -f

# Since boot
journalctl --user -u myapp -b

# Last 100 lines
journalctl --user -u myapp -n 100

# With timestamps
journalctl --user -u myapp -o short-precise
```

### Configure Logging

```ini
[Service]
# Log to journal
StandardOutput=journal
StandardError=journal

# Log level
SyslogLevel=info
SyslogIdentifier=myapp
```

## Dependencies

### Service Dependencies

```ini
[Unit]
Description=Web Application
Requires=container-db.service
After=container-db.service
Wants=container-cache.service
```

### Dependency Types

- `Requires=`: Hard dependency (fails if dependency fails)
- `Wants=`: Soft dependency (continues if dependency fails)
- `After=`: Start after specified unit
- `Before=`: Start before specified unit

## Health Checks

### Systemd Health Check

```ini
[Service]
Type=forking
ExecStart=/usr/bin/podman run -d --name web nginx
ExecStartPost=/usr/bin/bash -c 'until curl -f http://localhost:80; do sleep 1; done'
```

## Complete Example

### Multi-Service Application

#### Database Service
```ini
# ~/.config/systemd/user/db.service
[Unit]
Description=PostgreSQL Database
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
Restart=always
ExecStartPre=/usr/bin/podman pull postgres:13
ExecStart=/usr/bin/podman run -d \
  --name db \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:13
ExecStop=/usr/bin/podman stop -t 10 db
ExecStopPost=/usr/bin/podman rm -f db

[Install]
WantedBy=multi-user.target
```

#### Application Service
```ini
# ~/.config/systemd/user/app.service
[Unit]
Description=Application Server
After=network-online.target db.service
Wants=network-online.target
Requires=db.service

[Service]
Type=forking
Restart=always
ExecStartPre=/usr/bin/podman pull myapp:latest
ExecStart=/usr/bin/podman run -d \
  --name app \
  -p 8080:8080 \
  -e DB_HOST=db \
  myapp:latest
ExecStop=/usr/bin/podman stop -t 10 app
ExecStopPost=/usr/bin/podman rm -f app

[Install]
WantedBy=multi-user.target
```

### Enable Services

```bash
# Reload systemd
systemctl --user daemon-reload

# Enable services
systemctl --user enable db.service app.service

# Start services
systemctl --user start db.service app.service

# Check status
systemctl --user status db.service app.service
```

## Best Practices

1. **Use --new Flag**: Recreate containers on restart
2. **Enable Lingering**: For rootless services
3. **Proper Dependencies**: Define service order
4. **Health Checks**: Verify service startup
5. **Logging**: Configure journal logging
6. **Auto-Updates**: Enable for security patches
7. **Resource Limits**: Set systemd resource limits
8. **Restart Policies**: Configure appropriate restart behavior
9. **Timeout Values**: Set reasonable timeouts
10. **Documentation**: Document service dependencies

## Troubleshooting

### Service Won't Start

```bash
# Check status
systemctl --user status myapp

# View logs
journalctl --user -u myapp -n 50

# Check container
podman ps -a

# Test command manually
/usr/bin/podman run -d --name test myapp:latest
```

### Permission Issues

```bash
# Check lingering
loginctl show-user $USER | grep Linger

# Enable lingering
loginctl enable-linger $USER

# Check XDG_RUNTIME_DIR
echo $XDG_RUNTIME_DIR
```

## Next Steps

- [Security](10-Security.md) - Security best practices
- [Best Practices](12-Best-Practices.md) - Production guidelines
- [Troubleshooting](13-Troubleshooting.md) - Common issues
