# Linux Process Management

## Overview
Process management is essential for monitoring, controlling, and troubleshooting running applications and system services. Understanding how to view, manage, and terminate processes is crucial for system administration and DevOps work.

---

## What is a Process?
A **process** is an instance of a running program. Each process has:
- **PID (Process ID)**: Unique identifier
- **PPID (Parent Process ID)**: ID of the parent process
- **User**: Owner of the process
- **State**: Running, sleeping, stopped, or zombie
- **Resources**: CPU, memory, file descriptors

---

## Viewing Running Processes

### `ps` - Process Status
Display currently running processes.

**Basic usage:**
```bash
ps                    # Show processes for current user in current terminal
ps aux                # Show all processes with detailed info
ps -ef                # Show all processes in full format
ps -u username        # Show processes for specific user
```

**Common options:**
- `a` - Show processes for all users
- `u` - Display user-oriented format
- `x` - Show processes not attached to a terminal
- `-e` - Select all processes
- `-f` - Full format listing

**Example output:**
```bash
ps aux
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.1 169416 11680 ?        Ss   Jan01   0:05 /sbin/init
# www-data  1234  2.5  1.2 456789 98765 ?        S    10:30   1:23 nginx: worker
```

### `top` - Real-time Process Monitor
Monitor system processes dynamically in real-time.

**Usage:**
```bash
top                   # Launch interactive process viewer
top -u username       # Show processes for specific user
top -p PID            # Monitor specific process
```

**Interactive commands (while top is running):**
- `k` - Kill a process (prompts for PID)
- `r` - Renice a process (change priority)
- `M` - Sort by memory usage
- `P` - Sort by CPU usage
- `q` - Quit top
- `h` - Help menu

**Key metrics:**
- **%CPU**: CPU usage percentage
- **%MEM**: Memory usage percentage
- **TIME+**: Total CPU time used
- **COMMAND**: Process name/command

### `htop` - Enhanced Process Viewer
More user-friendly alternative to `top` (requires installation).

```bash
# Install htop
sudo apt install htop      # Debian/Ubuntu
sudo yum install htop      # RHEL/CentOS

# Run htop
htop
```

**Features:**
- Color-coded display
- Mouse support
- Tree view of processes
- Easy process killing and renicing

---

## Process States

| State | Symbol | Description |
|-------|--------|-------------|
| Running | R | Currently executing or ready to run |
| Sleeping | S | Waiting for an event (interruptible) |
| Uninterruptible Sleep | D | Waiting for I/O (cannot be interrupted) |
| Stopped | T | Stopped by job control signal |
| Zombie | Z | Terminated but not reaped by parent |

---

## Terminating Processes

### `kill` - Send Signal to Process
Terminate or signal a process using its PID.

**Basic syntax:**
```bash
kill PID              # Send SIGTERM (graceful termination)
kill -9 PID           # Send SIGKILL (force kill)
kill -15 PID          # Send SIGTERM (same as default)
kill -STOP PID        # Pause process
kill -CONT PID        # Resume paused process
```

**Common signals:**
| Signal | Number | Description |
|--------|--------|-------------|
| SIGTERM | 15 | Graceful termination (default) |
| SIGKILL | 9 | Force kill (cannot be caught) |
| SIGHUP | 1 | Hangup (reload config) |
| SIGINT | 2 | Interrupt (Ctrl+C) |
| SIGSTOP | 19 | Stop process |
| SIGCONT | 18 | Continue stopped process |

**Examples:**
```bash
# Find and kill a process
ps aux | grep nginx
kill 1234

# Force kill unresponsive process
kill -9 1234

# Kill multiple processes
kill 1234 5678 9012

# Reload service configuration
kill -HUP $(cat /var/run/nginx.pid)
```

### `killall` - Kill by Process Name
Terminate all processes matching a name.

```bash
killall process_name          # Kill all instances
killall -9 process_name       # Force kill all instances
killall -u username           # Kill all processes for user
```

**Examples:**
```bash
killall firefox               # Close all Firefox instances
killall -9 chrome             # Force kill all Chrome processes
```

### `pkill` - Kill by Pattern
More flexible process killing using patterns.

```bash
pkill pattern                 # Kill processes matching pattern
pkill -u username             # Kill all processes for user
pkill -9 pattern              # Force kill matching processes
```

**Examples:**
```bash
pkill -f "python.*script.py"  # Kill Python processes running script.py
pkill -u testuser             # Kill all processes owned by testuser
```

---

## Process Priority and Nice Values

### Understanding Nice Values
- Range: -20 (highest priority) to 19 (lowest priority)
- Default: 0
- Only root can set negative values

### `nice` - Start Process with Priority
```bash
nice -n 10 command            # Start with lower priority
nice -n -5 command            # Start with higher priority (requires root)
```

### `renice` - Change Running Process Priority
```bash
renice -n 5 -p PID            # Change priority of specific process
renice -n 10 -u username      # Change priority for all user processes
```

**Examples:**
```bash
# Start backup with low priority
nice -n 15 tar -czf backup.tar.gz /data

# Increase priority of critical process
sudo renice -n -10 -p 1234
```

---

## Background and Foreground Jobs

### Job Control
```bash
command &                     # Run command in background
jobs                          # List background jobs
fg %1                         # Bring job 1 to foreground
bg %1                         # Resume job 1 in background
Ctrl+Z                        # Suspend current foreground job
```

**Examples:**
```bash
# Start long-running process in background
./long_script.sh &

# List jobs
jobs
# [1]+  Running    ./long_script.sh &

# Bring to foreground
fg %1

# Suspend and resume
Ctrl+Z                        # Suspend
bg %1                         # Resume in background
```

---

## Advanced Process Management

### `pgrep` - Find Process IDs
```bash
pgrep process_name            # Get PIDs matching name
pgrep -u username             # Get PIDs for user
pgrep -l pattern              # List PIDs with names
```

### `pidof` - Find PID of Running Program
```bash
pidof nginx                   # Get PID(s) of nginx
pidof -s nginx                # Get single PID
```

### `/proc` Filesystem
Access process information directly.

```bash
# View process info
cat /proc/PID/status          # Process status
cat /proc/PID/cmdline         # Command line
cat /proc/PID/environ         # Environment variables
ls -l /proc/PID/fd            # Open file descriptors
```

---

## Monitoring Process Resources

### `pstree` - Display Process Tree
```bash
pstree                        # Show process hierarchy
pstree -p                     # Show with PIDs
pstree username               # Show for specific user
```

### `lsof` - List Open Files
```bash
lsof                          # List all open files
lsof -p PID                   # Files opened by process
lsof -u username              # Files opened by user
lsof -i :80                   # Processes using port 80
```

---

## Practical Examples

### Find and Kill Hung Process
```bash
# Find the process
ps aux | grep hung_app
# or
pgrep -l hung_app

# Try graceful termination
kill 1234

# Wait a few seconds, then force kill if needed
kill -9 1234
```

### Monitor Specific Application
```bash
# Watch process continuously
watch -n 1 'ps aux | grep myapp'

# Monitor with top
top -p $(pgrep myapp)
```

### Kill All Processes for User
```bash
# List processes first
ps -u username

# Kill all user processes
pkill -u username
# or
killall -u username
```

### Find Resource-Intensive Processes
```bash
# Top CPU consumers
ps aux --sort=-%cpu | head -10

# Top memory consumers
ps aux --sort=-%mem | head -10
```

---

## Best Practices

1. **Always try graceful termination first** - Use `kill` (SIGTERM) before `kill -9` (SIGKILL)
2. **Verify before killing** - Double-check PID to avoid killing wrong process
3. **Monitor after changes** - Ensure process terminated and didn't respawn
4. **Use appropriate tools** - `killall` for names, `pkill` for patterns, `kill` for specific PIDs
5. **Check dependencies** - Killing parent process may affect child processes
6. **Document critical processes** - Keep track of important PIDs and their purposes

---

## Troubleshooting

### Zombie Processes
```bash
# Find zombie processes
ps aux | grep 'Z'

# Zombies can't be killed directly - kill parent process
ps -o ppid= -p ZOMBIE_PID
kill PARENT_PID
```

### Process Won't Die
```bash
# Check process state
ps aux | grep PID

# If in 'D' state (uninterruptible sleep), wait for I/O to complete
# If still stuck, may need system reboot

# Check what process is waiting for
lsof -p PID
```

### Too Many Processes
```bash
# Check process limits
ulimit -u

# Count processes per user
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn

# Increase limits (temporary)
ulimit -u 4096
```

---

## Related Topics
- [System Monitoring](06-System-Monitoring.md) - Resource usage and performance
- [Systemctl Services](04-Systemctl-Services.md) - Managing system services
- [Shell Scripting](09-Shell-Scripting.md) - Automating process management
