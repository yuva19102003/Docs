# Linux System Monitoring

## Overview
System monitoring is critical for maintaining healthy infrastructure, identifying performance bottlenecks, and troubleshooting issues. This guide covers essential tools and techniques for monitoring CPU, memory, disk, and system logs.

---

## Real-Time System Monitoring

### `top` - System Performance Overview
Display real-time system statistics and process information.

**Usage:**
```bash
top                           # Launch interactive monitor
top -d 5                      # Update every 5 seconds
top -u username               # Monitor specific user
top -b -n 1 > snapshot.txt    # Batch mode (single snapshot)
```

**Key metrics displayed:**
```
top - 10:30:45 up 5 days,  2:15,  3 users,  load average: 0.52, 0.48, 0.45
Tasks: 245 total,   2 running, 243 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.2 us,  2.1 sy,  0.0 ni, 92.5 id,  0.2 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  16384.0 total,   2048.5 free,   8192.3 used,   6143.2 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.   7168.4 avail Mem
```

**Understanding the header:**
- **Load average**: 1, 5, and 15-minute averages (< number of CPUs is good)
- **us**: User CPU time
- **sy**: System CPU time
- **id**: Idle CPU time
- **wa**: I/O wait time
- **buff/cache**: Memory used for buffers and cache

**Interactive commands:**
- `M` - Sort by memory usage
- `P` - Sort by CPU usage
- `k` - Kill a process
- `r` - Renice a process
- `1` - Show individual CPU cores
- `q` - Quit

### `htop` - Enhanced Interactive Monitor
More user-friendly alternative with better visualization.

```bash
# Install htop
sudo apt install htop         # Debian/Ubuntu
sudo yum install htop         # RHEL/CentOS

# Run htop
htop
```

**Features:**
- Color-coded CPU and memory bars
- Mouse support
- Tree view of processes
- Easy filtering and searching
- Function key shortcuts (F1-F10)

---

## CPU Monitoring

### Check CPU Information
```bash
# View CPU details
lscpu                         # Detailed CPU architecture info
cat /proc/cpuinfo             # Raw CPU information
nproc                         # Number of processing units

# CPU usage per core
mpstat -P ALL 1               # Requires sysstat package
```

### Monitor CPU Usage
```bash
# Overall CPU usage
top
htop

# CPU usage by process
ps aux --sort=-%cpu | head -10

# Continuous monitoring
vmstat 1                      # Update every second
sar -u 1 10                   # CPU usage, 10 samples, 1 sec apart
```

**Example output:**
```bash
vmstat 1
# procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
#  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
#  1  0      0 2048576 123456 6143232    0    0     5    10  100  200  5  2 92  1  0
```

---

## Memory Monitoring

### `free` - Memory Usage
Display amount of free and used memory.

```bash
free                          # Display in kilobytes
free -h                       # Human-readable format
free -m                       # Display in megabytes
free -g                       # Display in gigabytes
free -s 5                     # Update every 5 seconds
```

**Example output:**
```bash
free -h
#               total        used        free      shared  buff/cache   available
# Mem:           16Gi       8.0Gi       2.0Gi       256Mi       6.0Gi       7.0Gi
# Swap:         4.0Gi          0B       4.0Gi
```

**Understanding memory:**
- **total**: Total installed RAM
- **used**: Memory used by processes
- **free**: Completely unused memory
- **buff/cache**: Memory used for buffers and cache (can be freed if needed)
- **available**: Memory available for new processes (includes reclaimable cache)

### Memory by Process
```bash
# Top memory consumers
ps aux --sort=-%mem | head -10

# Detailed memory info for process
pmap PID                      # Memory map
cat /proc/PID/status | grep -i mem
```

### Check for Memory Leaks
```bash
# Monitor memory over time
watch -n 1 free -h

# Track specific process memory
watch -n 1 'ps aux | grep process_name'
```

---

## Disk Monitoring

### `df` - Disk Space Usage
Show disk space usage of file systems.

```bash
df                            # Display in 1K blocks
df -h                         # Human-readable format
df -h /path                   # Specific filesystem
df -i                         # Show inode usage
df -T                         # Show filesystem type
```

**Example output:**
```bash
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   35G   13G  74% /
# /dev/sdb1       500G  250G  225G  53% /data
# tmpfs           8.0G  1.2M  8.0G   1% /run
```

**Warning signs:**
- Usage > 90% - Risk of running out of space
- Inodes > 90% - Too many small files

### `du` - Directory Space Usage
Estimate file and directory space usage.

```bash
du -sh /path/to/directory     # Summary of directory
du -h --max-depth=1 /path     # Show subdirectories (1 level)
du -ah /path | sort -rh | head -20  # Top 20 largest files/dirs
```

**Find large files:**
```bash
# Find files larger than 100MB
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# Find largest directories
du -h / 2>/dev/null | sort -rh | head -20
```

### Disk I/O Monitoring
```bash
# Install iostat (part of sysstat)
sudo apt install sysstat      # Debian/Ubuntu
sudo yum install sysstat      # RHEL/CentOS

# Monitor disk I/O
iostat                        # Basic I/O statistics
iostat -x 1                   # Extended stats, update every second
iostat -d 2 5                 # Disk stats, 5 samples, 2 sec apart

# Monitor specific disk
iostat -x /dev/sda 1
```

**Example output:**
```bash
iostat -x 1
# Device  r/s   w/s  rkB/s  wkB/s  %util
# sda    10.5  25.3  256.2  512.8   15.2
```

---

## System Logs

### Log Locations
```bash
/var/log/syslog              # General system logs (Debian/Ubuntu)
/var/log/messages            # General system logs (RHEL/CentOS)
/var/log/auth.log            # Authentication logs
/var/log/kern.log            # Kernel logs
/var/log/dmesg               # Boot messages
/var/log/apache2/            # Apache web server logs
/var/log/nginx/              # Nginx web server logs
```

### Viewing Logs

**Using `less` (recommended for large files):**
```bash
less /var/log/syslog
# Press 'G' to go to end
# Press 'g' to go to beginning
# Press '/' to search
# Press 'q' to quit
```

**Using `tail`:**
```bash
tail /var/log/syslog          # Last 10 lines
tail -n 50 /var/log/syslog    # Last 50 lines
tail -f /var/log/syslog       # Follow log in real-time
tail -f /var/log/syslog | grep ERROR  # Filter for errors
```

**Using `head`:**
```bash
head /var/log/syslog          # First 10 lines
head -n 50 /var/log/syslog    # First 50 lines
```

**Using `cat`:**
```bash
cat /var/log/syslog           # Display entire file
cat /var/log/syslog | grep error  # Search for errors
```

### `journalctl` - Systemd Journal
Modern systems use systemd journal for logging.

```bash
# View all logs
journalctl

# Follow logs in real-time
journalctl -f

# Logs since boot
journalctl -b

# Logs for specific service
journalctl -u nginx.service
journalctl -u ssh.service

# Logs for specific time range
journalctl --since "2024-01-01 00:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday --until today

# Filter by priority
journalctl -p err             # Errors only
journalctl -p warning         # Warnings and above

# Show kernel messages
journalctl -k

# Limit output
journalctl -n 50              # Last 50 entries
journalctl --no-pager         # Don't use pager

# Export logs
journalctl -u nginx.service -o json  # JSON format
```

### Searching Logs
```bash
# Search for specific term
grep "error" /var/log/syslog
grep -i "failed" /var/log/auth.log    # Case-insensitive

# Search with context
grep -A 5 -B 5 "error" /var/log/syslog  # 5 lines before/after

# Search multiple files
grep -r "error" /var/log/

# Count occurrences
grep -c "error" /var/log/syslog

# Show only matching filenames
grep -l "error" /var/log/*
```

---

## Network Monitoring

### Basic Network Stats
```bash
# Network interface statistics
ifconfig                      # Traditional command
ip addr show                  # Modern alternative
ip -s link                    # Show statistics

# Active connections
netstat -tuln                 # TCP/UDP listening ports
ss -tuln                      # Modern alternative (faster)
ss -s                         # Summary statistics

# Monitor network traffic
iftop                         # Real-time bandwidth usage (requires install)
nethogs                       # Per-process bandwidth usage (requires install)
```

### Bandwidth Monitoring
```bash
# Install monitoring tools
sudo apt install iftop nethogs vnstat

# Monitor interface bandwidth
iftop -i eth0

# Monitor per-process bandwidth
sudo nethogs eth0

# Network statistics over time
vnstat -i eth0                # Summary
vnstat -l -i eth0             # Live traffic
```

---

## System Load and Uptime

### `uptime` - System Uptime and Load
```bash
uptime
# 10:30:45 up 5 days,  2:15,  3 users,  load average: 0.52, 0.48, 0.45
```

**Understanding load average:**
- Three numbers: 1-minute, 5-minute, 15-minute averages
- Represents number of processes waiting for CPU
- Compare to number of CPU cores:
  - Load < cores: System has spare capacity
  - Load = cores: System fully utilized
  - Load > cores: System overloaded

### `w` - Who is Logged In
```bash
w                             # Show logged-in users and their activity
who                           # Simple list of logged-in users
last                          # Show login history
```

---

## Performance Monitoring Tools

### `vmstat` - Virtual Memory Statistics
```bash
vmstat                        # Single snapshot
vmstat 1                      # Update every second
vmstat 1 10                   # 10 samples, 1 second apart
```

### `sar` - System Activity Reporter
Collect and report system activity (requires sysstat package).

```bash
# Install sar
sudo apt install sysstat
sudo systemctl enable sysstat

# CPU usage
sar -u 1 10                   # 10 samples, 1 second apart

# Memory usage
sar -r 1 10

# Disk I/O
sar -d 1 10

# Network statistics
sar -n DEV 1 10

# View historical data
sar -f /var/log/sysstat/sa01  # Data from 1st of month
```

### `dstat` - Versatile Resource Statistics
Combines vmstat, iostat, netstat functionality.

```bash
# Install dstat
sudo apt install dstat

# Basic usage
dstat                         # Default output
dstat -cdngy                  # CPU, disk, network, page, system
dstat -tcm 5                  # Time, CPU, memory every 5 seconds
```

---

## Practical Monitoring Scenarios

### Diagnose High CPU Usage
```bash
# 1. Check overall CPU usage
top

# 2. Find top CPU consumers
ps aux --sort=-%cpu | head -10

# 3. Monitor specific process
top -p PID

# 4. Check CPU per core
mpstat -P ALL 1
```

### Diagnose High Memory Usage
```bash
# 1. Check memory overview
free -h

# 2. Find memory hogs
ps aux --sort=-%mem | head -10

# 3. Check for memory leaks
watch -n 1 'ps aux | grep process_name'

# 4. Analyze memory details
cat /proc/meminfo
```

### Diagnose Disk Space Issues
```bash
# 1. Check overall disk usage
df -h

# 2. Find large directories
du -h / 2>/dev/null | sort -rh | head -20

# 3. Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# 4. Check inode usage
df -i
```

### Diagnose Slow System
```bash
# 1. Check load average
uptime

# 2. Check I/O wait
top  # Look at 'wa' in CPU line

# 3. Check disk I/O
iostat -x 1

# 4. Check for disk errors
dmesg | grep -i error
journalctl -p err
```

---

## Monitoring Best Practices

1. **Establish baselines** - Know normal resource usage for your system
2. **Monitor trends** - Track metrics over time, not just snapshots
3. **Set up alerts** - Use tools like Prometheus, Nagios for automated monitoring
4. **Regular log reviews** - Check logs daily for errors and warnings
5. **Document thresholds** - Define what constitutes high usage for your environment
6. **Automate monitoring** - Use scripts and cron jobs for regular checks
7. **Keep historical data** - Retain logs and metrics for trend analysis

---

## Automated Monitoring Script Example

```bash
#!/bin/bash
# system-health-check.sh

echo "=== System Health Check ==="
echo "Date: $(date)"
echo ""

echo "=== CPU Load ==="
uptime

echo ""
echo "=== Memory Usage ==="
free -h

echo ""
echo "=== Disk Usage ==="
df -h | grep -v tmpfs

echo ""
echo "=== Top 5 CPU Processes ==="
ps aux --sort=-%cpu | head -6

echo ""
echo "=== Top 5 Memory Processes ==="
ps aux --sort=-%mem | head -6

echo ""
echo "=== Recent Errors in Syslog ==="
tail -50 /var/log/syslog | grep -i error
```

---

## Related Topics
- [Process Management](05-Process-Management.md) - Managing running processes
- [Systemctl Services](04-Systemctl-Services.md) - Service monitoring and management
- [Shell Scripting](09-Shell-Scripting.md) - Automating monitoring tasks
