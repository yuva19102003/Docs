# Linux Networking

## Overview
Understanding Linux networking is essential for DevOps, system administration, and troubleshooting connectivity issues. This guide covers network configuration, diagnostics, and common networking tools.

---

## Network Interfaces

### Understanding Interface Names

Modern Linux uses predictable network interface names:

**Common interface types:**
```
lo          - Loopback interface (localhost)
eth0        - Traditional Ethernet naming
enp4s0      - Ethernet (PCI bus 4, slot 0)
wlp3s0      - Wireless (PCI bus 3, slot 0)
docker0     - Docker bridge network
br-*        - Docker custom bridge networks
```

### Network Interface Naming Convention

**Format:** `<type><bus><slot>`
- **en** = Ethernet
- **wl** = Wireless
- **p** = PCI bus number
- **s** = Slot number

**Examples:**
- `enp4s0` - Ethernet, PCI bus 4, slot 0
- `wlp3s0` - Wireless, PCI bus 3, slot 0

---

## Network Configuration Commands

### `ifconfig` - Traditional Network Configuration
Display and configure network interfaces (older tool).

```bash
ifconfig                      # Show all active interfaces
ifconfig -a                   # Show all interfaces (including down)
ifconfig eth0                 # Show specific interface
```

**Configure interface:**
```bash
sudo ifconfig eth0 up                        # Bring interface up
sudo ifconfig eth0 down                      # Bring interface down
sudo ifconfig eth0 192.168.1.100             # Set IP address
sudo ifconfig eth0 netmask 255.255.255.0     # Set netmask
```

### `ip` - Modern Network Configuration
Recommended replacement for ifconfig (more powerful).

**View interfaces:**
```bash
ip addr                       # Show all interfaces with IP addresses
ip addr show                  # Same as above
ip addr show eth0             # Show specific interface
ip -4 addr                    # Show only IPv4
ip -6 addr                    # Show only IPv6
ip -br addr                   # Brief output
```

**Configure interfaces:**
```bash
sudo ip link set eth0 up                     # Bring interface up
sudo ip link set eth0 down                   # Bring interface down
sudo ip addr add 192.168.1.100/24 dev eth0   # Add IP address
sudo ip addr del 192.168.1.100/24 dev eth0   # Remove IP address
```

**View statistics:**
```bash
ip -s link                    # Show interface statistics
ip -s link show eth0          # Show stats for specific interface
```

---

## Common Network Interfaces Explained

### 1. Loopback Interface (lo)
**Purpose:** Internal communication within the local machine

```bash
# Typical configuration
lo: flags=73<UP,LOOPBACK,RUNNING>
    inet 127.0.0.1  netmask 255.0.0.0
    inet6 ::1  prefixlen 128
```

**Usage:**
- Testing network applications locally
- Inter-process communication
- Always available, never goes down

**Examples:**
```bash
ping localhost                # Test loopback
ping 127.0.0.1                # Same as above
curl http://localhost:8080    # Access local service
```

### 2. Ethernet Interface (enp4s0)
**Purpose:** Wired network connection

```bash
# Typical configuration
enp4s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>
    inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
```

**Usage:**
- Primary network connectivity
- Stable, high-speed connection
- Preferred for servers

**Management:**
```bash
# Check status
ip link show enp4s0

# Bring up/down
sudo ip link set enp4s0 up
sudo ip link set enp4s0 down

# Configure IP
sudo ip addr add 192.168.1.100/24 dev enp4s0
```

### 3. Wireless Interface (wlp3s0)
**Purpose:** Wi-Fi network connection

```bash
# Typical configuration
wlp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>
    inet 192.168.1.101  netmask 255.255.255.0
```

**Usage:**
- Wireless network connectivity
- Mobile devices and laptops
- Managed by NetworkManager or wpa_supplicant

**Management:**
```bash
# Check wireless status
iwconfig wlp3s0

# Scan for networks
sudo iwlist wlp3s0 scan

# Using NetworkManager
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD
```

### 4. Docker Bridge (docker0)
**Purpose:** Default Docker container networking

```bash
# Typical configuration
docker0: flags=4099<UP,BROADCAST,MULTICAST>
    inet 172.17.0.1  netmask 255.255.0.0
```

**Usage:**
- Connects Docker containers
- Provides NAT for container internet access
- Default network for containers

**Management:**
```bash
# View Docker networks
docker network ls

# Inspect docker0 bridge
docker network inspect bridge
ip addr show docker0

# View connected containers
docker network inspect bridge | grep -A 5 Containers
```

### 5. Custom Docker Bridge (br-*)
**Purpose:** User-defined Docker networks

```bash
# Example: br-34a35fdfe682
br-34a35fdfe682: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>
    inet 172.18.0.1  netmask 255.255.0.0
```

**Usage:**
- Isolated container networks
- Custom network configurations
- Better container communication control

**Management:**
```bash
# Create custom network
docker network create mynetwork

# Connect container to network
docker network connect mynetwork container_name

# Inspect custom network
docker network inspect mynetwork
```

---

## Network Diagnostics

### `ping` - Test Connectivity
Test network connectivity to a host.

```bash
ping example.com              # Ping continuously (Ctrl+C to stop)
ping -c 4 example.com         # Send 4 packets
ping -i 2 example.com         # 2 second interval
ping -W 5 example.com         # 5 second timeout
```

**Interpreting results:**
```bash
64 bytes from example.com (93.184.216.34): icmp_seq=1 ttl=56 time=15.2 ms
```
- **ttl**: Time to live (hops remaining)
- **time**: Round-trip time (latency)

**Common scenarios:**
```bash
# Test local network
ping 192.168.1.1              # Gateway/router

# Test internet connectivity
ping 8.8.8.8                  # Google DNS
ping 1.1.1.1                  # Cloudflare DNS

# Test DNS resolution
ping google.com               # If this fails but 8.8.8.8 works, DNS issue
```

### `traceroute` / `tracepath` - Trace Network Path
Show the route packets take to destination.

```bash
traceroute example.com        # Trace route
tracepath example.com         # Alternative (no root needed)
mtr example.com               # Continuous traceroute (requires install)
```

### `netstat` - Network Statistics
Display network connections and statistics (older tool).

```bash
netstat -tuln                 # TCP/UDP listening ports
netstat -tulnp                # Include process names (requires root)
netstat -r                    # Routing table
netstat -i                    # Interface statistics
netstat -s                    # Protocol statistics
```

**Options explained:**
- `-t` = TCP connections
- `-u` = UDP connections
- `-l` = Listening sockets
- `-n` = Numeric (don't resolve names)
- `-p` = Show process/program

### `ss` - Socket Statistics
Modern replacement for netstat (faster and more detailed).

```bash
ss -tuln                      # TCP/UDP listening ports
ss -tulnp                     # Include process names
ss -s                         # Summary statistics
ss -t state established       # Show established TCP connections
ss -o                         # Show timer information
```

**Practical examples:**
```bash
# Find what's using port 80
ss -tulnp | grep :80
sudo lsof -i :80

# Show all established connections
ss -t state established

# Show listening ports only
ss -tuln | grep LISTEN
```

### `nslookup` / `dig` - DNS Lookup
Query DNS servers for domain information.

```bash
# nslookup (simple)
nslookup example.com
nslookup example.com 8.8.8.8  # Use specific DNS server

# dig (detailed)
dig example.com               # Full DNS query
dig example.com +short        # Brief output
dig @8.8.8.8 example.com      # Use specific DNS server
dig -x 8.8.8.8                # Reverse DNS lookup
dig example.com ANY           # All record types
```

### `host` - Simple DNS Lookup
```bash
host example.com              # Basic lookup
host -t MX example.com        # Mail servers
host -t NS example.com        # Name servers
```

---

## Network Connectivity Testing

### Check Network Interface Status
```bash
# Modern method
ip link show

# Check if interface is up
ip link show eth0 | grep "state UP"

# Traditional method
ifconfig eth0
```

### Test Local Network
```bash
# Ping gateway
ping -c 4 $(ip route | grep default | awk '{print $3}')

# Check routing table
ip route
route -n
```

### Test Internet Connectivity
```bash
# Test DNS resolution
ping -c 4 google.com

# Test without DNS
ping -c 4 8.8.8.8

# Test HTTP connectivity
curl -I https://www.google.com
wget --spider https://www.google.com
```

---

## SSH - Secure Shell

### Basic SSH Usage
```bash
ssh username@hostname         # Connect to remote server
ssh username@192.168.1.100    # Connect using IP
ssh -p 2222 username@host     # Custom port
```

### SSH Key Authentication
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096
ssh-keygen -t ed25519         # Modern, more secure

# Copy public key to server
ssh-copy-id username@hostname

# Manual copy
cat ~/.ssh/id_rsa.pub | ssh username@hostname "cat >> ~/.ssh/authorized_keys"
```

### SSH Configuration
```bash
# User SSH config: ~/.ssh/config
Host myserver
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa

# Connect using alias
ssh myserver
```

### SSH Tunneling
```bash
# Local port forwarding
ssh -L 8080:localhost:80 username@remote

# Remote port forwarding
ssh -R 8080:localhost:80 username@remote

# Dynamic port forwarding (SOCKS proxy)
ssh -D 1080 username@remote
```

### SCP - Secure Copy
```bash
# Copy file to remote
scp file.txt username@remote:/path/

# Copy file from remote
scp username@remote:/path/file.txt .

# Copy directory recursively
scp -r directory/ username@remote:/path/

# Copy with custom port
scp -P 2222 file.txt username@remote:/path/
```

### SFTP - Secure FTP
```bash
# Connect to remote server
sftp username@hostname

# SFTP commands
put file.txt                  # Upload file
get file.txt                  # Download file
ls                            # List remote files
lls                           # List local files
cd /path                      # Change remote directory
lcd /path                     # Change local directory
```

---

## Firewall Management

### `ufw` - Uncomplicated Firewall (Ubuntu/Debian)
```bash
# Enable/disable firewall
sudo ufw enable
sudo ufw disable

# Check status
sudo ufw status
sudo ufw status verbose

# Allow/deny ports
sudo ufw allow 22             # Allow SSH
sudo ufw allow 80/tcp         # Allow HTTP
sudo ufw deny 23              # Deny Telnet

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Delete rule
sudo ufw delete allow 80
```

### `firewall-cmd` - Firewalld (RHEL/CentOS)
```bash
# Check status
sudo firewall-cmd --state

# List rules
sudo firewall-cmd --list-all

# Allow port
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# Allow service
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
```

---

## Network Configuration Files

### Debian/Ubuntu
```bash
# Network interfaces
/etc/network/interfaces

# DNS configuration
/etc/resolv.conf

# Hostname
/etc/hostname
/etc/hosts
```

### RHEL/CentOS
```bash
# Network scripts
/etc/sysconfig/network-scripts/ifcfg-eth0

# DNS configuration
/etc/resolv.conf

# Hostname
/etc/hostname
/etc/hosts
```

### NetworkManager
```bash
# Configuration directory
/etc/NetworkManager/

# Connection profiles
/etc/NetworkManager/system-connections/
```

---

## Practical Scenarios

### Troubleshoot No Internet Connection
```bash
# 1. Check interface status
ip link show

# 2. Check IP address
ip addr show

# 3. Ping gateway
ping -c 4 $(ip route | grep default | awk '{print $3}')

# 4. Ping external IP
ping -c 4 8.8.8.8

# 5. Test DNS
ping -c 4 google.com

# 6. Check DNS servers
cat /etc/resolv.conf
```

### Find What's Using a Port
```bash
# Using ss
sudo ss -tulnp | grep :80

# Using netstat
sudo netstat -tulnp | grep :80

# Using lsof
sudo lsof -i :80
```

### Monitor Network Traffic
```bash
# Install tools
sudo apt install iftop nethogs

# Monitor bandwidth by interface
sudo iftop -i eth0

# Monitor bandwidth by process
sudo nethogs eth0

# Simple packet monitoring
sudo tcpdump -i eth0
sudo tcpdump -i eth0 port 80
```

### Configure Static IP
```bash
# Using ip command (temporary)
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1

# Using NetworkManager (permanent)
nmcli con mod eth0 ipv4.addresses 192.168.1.100/24
nmcli con mod eth0 ipv4.gateway 192.168.1.1
nmcli con mod eth0 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con mod eth0 ipv4.method manual
nmcli con up eth0
```

---

## Best Practices

1. **Use modern tools** - Prefer `ip` over `ifconfig`, `ss` over `netstat`
2. **Document network changes** - Keep track of IP assignments and configurations
3. **Test before permanent changes** - Use temporary commands first
4. **Secure SSH** - Use key authentication, disable root login, change default port
5. **Monitor network usage** - Regular checks for unusual traffic
6. **Keep firewall enabled** - Only open necessary ports
7. **Use DNS properly** - Configure reliable DNS servers (8.8.8.8, 1.1.1.1)

---

## Related Topics
- [System Monitoring](06-System-Monitoring.md) - Network performance monitoring
- [Systemctl Services](04-Systemctl-Services.md) - Managing network services
- [Shell Scripting](09-Shell-Scripting.md) - Automating network tasks
