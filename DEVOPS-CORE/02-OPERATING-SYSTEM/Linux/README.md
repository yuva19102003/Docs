# Linux Fundamentals

## Overview
This directory contains comprehensive guides for Linux system administration and DevOps fundamentals. Each topic is organized into focused modules covering essential commands, concepts, and practical examples.

---

## Learning Path

### Beginner Level
1. **[Basics and Navigation](01-Basics-Navigation.md)** - Start here
   - File and directory navigation
   - Basic file operations (ls, cd, cp, mv, rm)
   - Viewing file contents (cat, less, head, tail)

2. **[Permissions](02-Permissions.md)**
   - Understanding Linux permissions
   - chmod, chown, chgrp
   - User and group management
   - Special permissions (SUID, SGID, Sticky Bit)

3. **[Package Management](03-Package-Management.md)**
   - APT (Debian/Ubuntu)
   - YUM/DNF (RHEL/CentOS/Fedora)
   - Alternative package managers (Snap, Flatpak)

### Intermediate Level
4. **[Systemctl Services](04-Systemctl-Services.md)**
   - Managing system services
   - Creating custom services
   - Systemd timers
   - Service troubleshooting

5. **[Process Management](05-Process-Management.md)**
   - Viewing processes (ps, top, htop)
   - Killing processes (kill, killall, pkill)
   - Process priority (nice, renice)
   - Background jobs

6. **[System Monitoring](06-System-Monitoring.md)**
   - CPU, memory, disk monitoring
   - System logs (journalctl, syslog)
   - Performance tools (vmstat, iostat, sar)
   - Resource troubleshooting

### Advanced Level
7. **[File Management](07-File-Management.md)**
   - Compression and archiving (tar, gzip, zip)
   - Searching files (find, locate)
   - Searching within files (grep)
   - Text processing (awk, sed, cut)

8. **[Networking](08-Networking.md)**
   - Network interfaces and configuration
   - Network diagnostics (ping, traceroute, netstat)
   - SSH and remote access
   - Firewall management

9. **[Shell Scripting](09-Shell-Scripting.md)**
   - Bash scripting fundamentals
   - Variables, loops, conditionals
   - Functions and arrays
   - Practical automation examples

---

## Quick Reference

### Essential Commands by Category

#### File Operations
```bash
ls -la                    # List files with details
cd /path                  # Change directory
cp source dest            # Copy file
mv old new                # Move/rename file
rm file                   # Remove file
mkdir dir                 # Create directory
```

#### File Viewing
```bash
cat file                  # Display entire file
less file                 # Page through file
head -n 20 file           # First 20 lines
tail -f file              # Follow file updates
```

#### Permissions
```bash
chmod 755 file            # Change permissions
chown user:group file     # Change owner
ls -l file                # View permissions
```

#### Process Management
```bash
ps aux                    # List all processes
top                       # Real-time process monitor
kill PID                  # Terminate process
killall name              # Kill by name
```

#### System Monitoring
```bash
free -h                   # Memory usage
df -h                     # Disk usage
du -sh dir                # Directory size
uptime                    # System load
```

#### Networking
```bash
ip addr                   # Show IP addresses
ping host                 # Test connectivity
ss -tuln                  # Show listening ports
ssh user@host             # Remote login
```

#### Package Management
```bash
# Debian/Ubuntu
apt update                # Update package list
apt install package       # Install package
apt remove package        # Remove package

# RHEL/CentOS
yum install package       # Install package
yum update                # Update packages
```

#### Services
```bash
systemctl start service   # Start service
systemctl stop service    # Stop service
systemctl status service  # Check status
systemctl enable service  # Enable at boot
```

---

## Common Use Cases

### System Administration
- **User Management**: Create users, set permissions, manage groups
- **Service Management**: Start/stop services, configure auto-start
- **Log Analysis**: Search logs, troubleshoot errors
- **Disk Management**: Monitor space, clean up old files
- **Security**: Configure firewall, manage SSH access

### DevOps Tasks
- **Automation**: Write scripts for repetitive tasks
- **Monitoring**: Set up system health checks
- **Deployment**: Manage application services
- **Troubleshooting**: Diagnose performance issues
- **Backup**: Automate backup procedures

### Development
- **Environment Setup**: Install development tools
- **Process Debugging**: Monitor application processes
- **Log Monitoring**: Track application logs
- **Network Testing**: Test connectivity and ports
- **File Management**: Organize and search code files

---

## Troubleshooting Guide

### System is Slow
1. Check CPU load: `top` or `htop`
2. Check memory: `free -h`
3. Check disk I/O: `iostat -x 1`
4. Check disk space: `df -h`
5. Review logs: `journalctl -p err`

### Service Won't Start
1. Check status: `systemctl status service`
2. View logs: `journalctl -u service -n 50`
3. Check configuration: Verify config files
4. Check permissions: Ensure proper file ownership
5. Check dependencies: Verify required services are running

### Network Issues
1. Check interface: `ip link show`
2. Check IP address: `ip addr show`
3. Ping gateway: `ping $(ip route | grep default | awk '{print $3}')`
4. Test DNS: `ping google.com`
5. Check firewall: `sudo ufw status` or `sudo firewall-cmd --list-all`

### Disk Full
1. Check usage: `df -h`
2. Find large files: `find / -type f -size +100M 2>/dev/null`
3. Find large directories: `du -h / | sort -rh | head -20`
4. Clean package cache: `apt clean` or `yum clean all`
5. Remove old logs: `find /var/log -name "*.log" -mtime +30 -delete`

---

## Best Practices

### Security
- Use SSH keys instead of passwords
- Keep system and packages updated
- Use sudo instead of root login
- Configure firewall properly
- Regular security audits

### Performance
- Monitor system resources regularly
- Set up automated alerts
- Clean up old files and logs
- Optimize service configurations
- Use appropriate process priorities

### Maintenance
- Regular backups
- Log rotation
- Package updates
- Security patches
- Documentation of changes

### Scripting
- Always test scripts before production
- Use version control for scripts
- Add error handling
- Document script purpose and usage
- Follow naming conventions

---

## Tools and Utilities

### System Monitoring
- `top` / `htop` - Process monitoring
- `vmstat` - Virtual memory statistics
- `iostat` - I/O statistics
- `sar` - System activity reporter
- `dstat` - Versatile resource statistics

### Network Tools
- `ping` - Test connectivity
- `traceroute` - Trace network path
- `ss` / `netstat` - Socket statistics
- `tcpdump` - Packet analyzer
- `iftop` - Bandwidth monitoring

### File Tools
- `find` - Search for files
- `grep` - Search within files
- `tar` - Archive files
- `rsync` - Sync files
- `diff` - Compare files

### Text Processing
- `awk` - Pattern scanning and processing
- `sed` - Stream editor
- `cut` - Extract columns
- `sort` - Sort lines
- `uniq` - Remove duplicates

---

## Additional Resources

### Man Pages
```bash
man command               # View manual for command
man -k keyword            # Search man pages
info command              # Alternative documentation
```

### Help Commands
```bash
command --help            # Quick help
command -h                # Short help
type command              # Show command type
which command             # Show command location
```

### Online Resources
- Linux Documentation Project: https://tldp.org/
- Arch Linux Wiki: https://wiki.archlinux.org/
- Ubuntu Documentation: https://help.ubuntu.com/
- Red Hat Documentation: https://access.redhat.com/documentation/

---

## Practice Exercises

### Beginner
1. Navigate to /var/log and list all files
2. Create a directory structure: ~/projects/web/frontend
3. Find all .conf files in /etc
4. View the last 50 lines of /var/log/syslog
5. Change permissions of a file to 644

### Intermediate
1. Create a script to backup a directory
2. Find all files larger than 100MB
3. Monitor CPU usage of a specific process
4. Set up a custom systemd service
5. Configure SSH key authentication

### Advanced
1. Write a script to monitor disk usage and send alerts
2. Create a log rotation script
3. Set up automated backups with compression
4. Build a system health check script
5. Implement a service monitoring and restart script

---

## Navigation

### Related Topics
- [DevOps Core README](../../README.md) - Main documentation index
- [Operating System Concepts](../README.md) - OS fundamentals
- [Networking](../../NETWORKING/README.md) - Network concepts
- [Shell Scripting Examples](../../DEVOPS-TOPICS/) - Advanced scripts

### Quick Links
- [Basics](01-Basics-Navigation.md) | [Permissions](02-Permissions.md) | [Packages](03-Package-Management.md)
- [Services](04-Systemctl-Services.md) | [Processes](05-Process-Management.md) | [Monitoring](06-System-Monitoring.md)
- [Files](07-File-Management.md) | [Networking](08-Networking.md) | [Scripting](09-Shell-Scripting.md)

---

## Contributing

If you find errors or have suggestions for improvements:
1. Document the issue clearly
2. Provide examples if applicable
3. Suggest corrections or additions
4. Test commands before submitting

---

**Last Updated:** January 2026
**Maintained by:** DevOps Documentation Team
