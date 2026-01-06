# Ports and Protocols - Complete Guide

## Overview

Ports are communication endpoints that direct network traffic to the correct application or service on a device. Understanding ports and protocols is essential for network configuration, security, and troubleshooting.

## Table of Contents

1. [What are Ports](#what-are-ports)
2. [Port Categories](#port-categories)
3. [Common Ports](#common-ports)
4. [Port Types (TCP/UDP)](#port-types-tcp-udp)
5. [Port Management](#port-management)

---

## What are Ports?

**Ports** are virtual endpoints in an operating system that help identify specific processes or services. They work alongside IP addresses to ensure data reaches the correct application.

### Port Number Range

```
┌─────────────────────────────────────────────────────────────────┐
│                    Port Number Ranges                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  0 - 65535 (Total Available Ports)                              │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Well-Known Ports: 0 - 1023                              │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Reserved for system/well-known services           │  │  │
│  │  │  Examples: HTTP (80), HTTPS (443), SSH (22)        │  │  │
│  │  │  Requires root/admin privileges to bind            │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Registered Ports: 1024 - 49151                          │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Assigned by IANA for user processes/applications │  │  │
│  │  │  Examples: MySQL (3306), PostgreSQL (5432)         │  │  │
│  │  │  Can be used by regular users                      │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Dynamic/Private Ports: 49152 - 65535                   │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Used for client-side communications               │  │  │
│  │  │  Dynamically assigned by OS                        │  │  │
│  │  │  Ephemeral ports for temporary connections         │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Port Categories

### 1. Well-Known Ports (0-1023)

Reserved for system or well-known services:
- HTTP (Port 80)
- HTTPS (Port 443)
- SSH (Port 22)
- FTP (Port 21)
- DNS (Port 53)

### 2. Registered Ports (1024-49151)

Assigned by IANA for user processes or applications:
- MySQL (Port 3306)
- PostgreSQL (Port 5432)
- MongoDB (Port 27017)
- Redis (Port 6379)

### 3. Dynamic/Private Ports (49152-65535)

Used for client-side communications:
- Dynamically assigned by the operating system
- Ephemeral ports for temporary connections
- Used when a client initiates a connection

---

## Common Ports

### Web Services

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 80 | HTTP | Web Server | Unencrypted web traffic |
| 443 | HTTPS | Secure Web | Encrypted web traffic (SSL/TLS) |
| 8080 | HTTP-Alt | Web Proxy | Alternative HTTP port |
| 8443 | HTTPS-Alt | Secure Alt | Alternative HTTPS port |

### File Transfer

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 20 | FTP-Data | FTP | File Transfer Protocol (data) |
| 21 | FTP-Control | FTP | File Transfer Protocol (control) |
| 22 | SFTP/SCP | SSH | Secure file transfer |
| 69 | TFTP | TFTP | Trivial File Transfer Protocol |
| 445 | SMB | SMB/CIFS | Windows file sharing |

### Email Services

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 25 | SMTP | Mail Send | Simple Mail Transfer Protocol |
| 110 | POP3 | Mail Receive | Post Office Protocol v3 |
| 143 | IMAP | Mail Access | Internet Message Access Protocol |
| 465 | SMTPS | Secure Mail | SMTP over SSL |
| 587 | SMTP | Mail Submit | Mail submission (with STARTTLS) |
| 993 | IMAPS | Secure IMAP | IMAP over SSL |
| 995 | POP3S | Secure POP3 | POP3 over SSL |

### Remote Access

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 22 | SSH | Secure Shell | Encrypted remote access |
| 23 | Telnet | Telnet | Unencrypted remote access (insecure) |
| 3389 | RDP | Remote Desktop | Windows remote desktop |
| 5900 | VNC | VNC | Virtual Network Computing |

### Database Services

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 1433 | MS SQL | SQL Server | Microsoft SQL Server |
| 1521 | Oracle | Oracle DB | Oracle Database |
| 3306 | MySQL | MySQL | MySQL/MariaDB Database |
| 5432 | PostgreSQL | PostgreSQL | PostgreSQL Database |
| 27017 | MongoDB | MongoDB | MongoDB Database |
| 6379 | Redis | Redis | Redis Cache/Database |

### Network Services

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 53 | DNS | Domain Name | Domain Name System |
| 67 | DHCP | DHCP Server | Dynamic Host Configuration (server) |
| 68 | DHCP | DHCP Client | Dynamic Host Configuration (client) |
| 123 | NTP | Time Sync | Network Time Protocol |
| 161 | SNMP | Monitoring | Simple Network Management Protocol |
| 162 | SNMP | Traps | SNMP Trap messages |
| 514 | Syslog | Logging | System logging |

### Container & Orchestration

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 2375 | Docker | Docker API | Docker daemon (unencrypted) |
| 2376 | Docker | Docker API | Docker daemon (encrypted) |
| 6443 | Kubernetes | K8s API | Kubernetes API server |
| 10250 | Kubernetes | Kubelet | Kubelet API |
| 2379 | etcd | etcd Client | etcd client communication |
| 2380 | etcd | etcd Peer | etcd peer communication |

---

## How Ports Work

### Port Communication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│              Port Communication Workflow                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Client Device (192.168.1.100)                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  Web Browser                                              │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Request: https://example.com                        │ │  │
│  │  │  Source: 192.168.1.100:54321 (ephemeral port)       │ │  │
│  │  │  Destination: 93.184.216.34:443 (HTTPS)             │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                       │
│                         │ Packet with:                          │
│                         │ - Source IP: 192.168.1.100            │
│                         │ - Source Port: 54321                  │
│                         │ - Dest IP: 93.184.216.34              │
│                         │ - Dest Port: 443                      │
│                         ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                    Internet                              │  │
│  └─────────────────────┬───────────────────────────────────┘  │
│                         │                                       │
│                         ▼                                       │
│  Server (93.184.216.34)                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │  │
│  │  │   Port 80   │  │  Port 443   │  │  Port 22    │     │  │
│  │  │   (HTTP)    │  │  (HTTPS)    │  │   (SSH)     │     │  │
│  │  └─────────────┘  └──────┬──────┘  └─────────────┘     │  │
│  │                           │                              │  │
│  │                           ▼                              │  │
│  │                  ┌─────────────────┐                    │  │
│  │                  │  Web Server     │                    │  │
│  │                  │  (Nginx/Apache) │                    │  │
│  │                  │  Listening on   │                    │  │
│  │                  │  Port 443       │                    │  │
│  │                  └─────────────────┘                    │  │
│  │                           │                              │  │
│  │                           │ Response                     │  │
│  │                           ▼                              │  │
│  │  Response sent back to 192.168.1.100:54321              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Key Points:                                                    │
│  - Client uses ephemeral port (54321)                          │
│  - Server listens on well-known port (443)                     │
│  - Port + IP = Socket (unique endpoint)                        │
│  - Multiple connections can use same server port               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Port Types (TCP/UDP)

### TCP Ports (Transmission Control Protocol)

**Characteristics**:
- Connection-oriented
- Reliable, ordered delivery
- Error-checked
- Flow control
- Slower but more reliable

**Use Cases**:
- Web browsing (HTTP/HTTPS)
- Email (SMTP, IMAP, POP3)
- File transfer (FTP, SFTP)
- Remote access (SSH, RDP)

### UDP Ports (User Datagram Protocol)

**Characteristics**:
- Connectionless
- Faster but less reliable
- No error checking
- No flow control
- Lower overhead

**Use Cases**:
- DNS queries
- Video streaming
- VoIP (Voice over IP)
- Online gaming
- DHCP

### TCP vs UDP Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│                    TCP vs UDP                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TCP (Transmission Control Protocol)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Client          Server                                   │  │
│  │    │               │                                      │  │
│  │    │─── SYN ──────>│  (3-Way Handshake)                  │  │
│  │    │<── SYN-ACK ───│                                      │  │
│  │    │─── ACK ──────>│                                      │  │
│  │    │               │                                      │  │
│  │    │─── Data ─────>│  (Reliable Transfer)                │  │
│  │    │<── ACK ───────│                                      │  │
│  │    │─── Data ─────>│                                      │  │
│  │    │<── ACK ───────│                                      │  │
│  │    │               │                                      │  │
│  │    │─── FIN ──────>│  (Connection Close)                 │  │
│  │    │<── ACK ───────│                                      │  │
│  │                                                           │  │
│  │  ✅ Reliable  ✅ Ordered  ✅ Error-checked               │  │
│  │  ❌ Slower    ❌ More overhead                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  UDP (User Datagram Protocol)                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Client          Server                                   │  │
│  │    │               │                                      │  │
│  │    │─── Data ─────>│  (No Handshake)                     │  │
│  │    │─── Data ─────>│                                      │  │
│  │    │─── Data ─────>│                                      │  │
│  │    │               │  (No Acknowledgment)                │  │
│  │                                                           │  │
│  │  ✅ Fast      ✅ Low overhead                            │  │
│  │  ❌ Unreliable ❌ No ordering  ❌ No error checking      │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Port Management

### Port Scanning

A technique used to identify open ports on a network.

**Common Tools**:
```bash
# Nmap - Network scanner
nmap -p 1-65535 192.168.1.1

# Netcat - Network utility
nc -zv 192.168.1.1 80

# Telnet - Test port connectivity
telnet 192.168.1.1 80
```

**Security Implications**:
- Open ports can be security vulnerabilities
- Close unnecessary ports
- Use firewalls to restrict access
- Monitor for unauthorized port scanning

### Port Forwarding

Allows external devices to access services on a private network.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Port Forwarding                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Internet                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  External Client: 203.0.113.50                           │  │
│  │  Wants to access: 198.51.100.1:8080                     │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                       │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Router/Firewall (198.51.100.1)                          │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Port Forwarding Rule:                             │  │  │
│  │  │  External Port 8080 → Internal 192.168.1.10:80    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                       │
│                         ▼                                       │
│  Private Network (192.168.1.0/24)                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Web Server (192.168.1.10:80)                       │ │  │
│  │  │  Receives traffic forwarded from router             │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Example: Forward external port 8080 to internal web server    │
└─────────────────────────────────────────────────────────────────┘
```

### Port Binding

Port binding associates a specific application with a particular port number.

**Example**:
```bash
# Web server binds to port 80
nginx -g 'daemon off;'  # Listens on port 80

# Application binds to port 3000
node server.js  # Listens on port 3000

# Database binds to port 5432
postgres -D /var/lib/postgresql/data  # Listens on port 5432
```

### Firewall and Ports

Firewalls use ports to filter traffic and control access.

**Common Firewall Commands**:

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp      # Allow SSH
sudo ufw allow 80/tcp      # Allow HTTP
sudo ufw allow 443/tcp     # Allow HTTPS
sudo ufw deny 23/tcp       # Deny Telnet

# iptables (Linux)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# firewalld (CentOS/RHEL)
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-service=http --permanent
```

---

## Monitoring Ports

### Tools for Port Monitoring

**1. Netstat** - Show active connections
```bash
# Show all listening ports
netstat -tuln

# Show all connections with process info
netstat -tulnp

# Show specific port
netstat -an | grep :80
```

**2. SS** - Socket statistics (modern replacement for netstat)
```bash
# Show all listening TCP ports
ss -tln

# Show all listening ports with process info
ss -tlnp

# Show specific port
ss -tln sport = :80
```

**3. Lsof** - List open files (including network connections)
```bash
# Show all network connections
lsof -i

# Show specific port
lsof -i :80

# Show connections for specific process
lsof -i -P -n | grep nginx
```

**4. Nmap** - Network scanner
```bash
# Scan common ports
nmap 192.168.1.1

# Scan all ports
nmap -p- 192.168.1.1

# Scan specific ports
nmap -p 80,443,8080 192.168.1.1
```

---

## Troubleshooting Ports

### Common Port Issues

**1. Port Already in Use**
```bash
# Error: Address already in use
# Solution: Find and kill the process
lsof -i :8080
kill -9 <PID>
```

**2. Port Blocked by Firewall**
```bash
# Check firewall rules
sudo ufw status
sudo iptables -L

# Allow port through firewall
sudo ufw allow 8080/tcp
```

**3. Port Not Listening**
```bash
# Check if service is running
systemctl status nginx

# Check if port is bound
netstat -tuln | grep :80
```

**4. Cannot Connect to Port**
```bash
# Test connectivity
telnet 192.168.1.1 80
nc -zv 192.168.1.1 80

# Check routing
traceroute 192.168.1.1
```

### Troubleshooting Steps

1. **Check Port Status**: Use `netstat`, `ss`, or `lsof`
2. **Test Connectivity**: Use `telnet`, `nc`, or `curl`
3. **Check Firewall Rules**: Verify firewall isn't blocking
4. **Verify Service**: Ensure application is running
5. **Check Logs**: Review application and system logs
6. **Test Locally**: Try connecting from localhost first

---

## Best Practices

### Security Best Practices

1. **Close Unnecessary Ports**: Only open ports that are actively used
2. **Use Non-Standard Ports**: Change default ports for added security
3. **Implement Firewalls**: Filter traffic based on ports
4. **Monitor Port Activity**: Regularly scan for open ports
5. **Use Encryption**: Prefer encrypted protocols (HTTPS over HTTP)
6. **Restrict Access**: Limit port access to specific IP addresses
7. **Regular Audits**: Periodically review open ports and services

### Configuration Best Practices

1. **Document Port Usage**: Maintain inventory of port assignments
2. **Use Standard Ports**: When possible, use well-known ports
3. **Avoid Port Conflicts**: Check for conflicts before assigning
4. **Plan Port Ranges**: Organize ports by service type
5. **Test Thoroughly**: Verify port accessibility after changes
6. **Use Port Forwarding Carefully**: Only forward necessary ports
7. **Implement Rate Limiting**: Protect against port scanning

---

## Summary

- **Ports** are virtual endpoints for network communication
- **Port ranges**: Well-known (0-1023), Registered (1024-49151), Dynamic (49152-65535)
- **TCP**: Reliable, connection-oriented protocol
- **UDP**: Fast, connectionless protocol
- **Port management**: Scanning, forwarding, binding, monitoring
- **Security**: Close unnecessary ports, use firewalls, monitor activity
- **Troubleshooting**: Use netstat, ss, lsof, nmap for diagnostics

Understanding ports and protocols is fundamental for network administration, security, and application deployment.
