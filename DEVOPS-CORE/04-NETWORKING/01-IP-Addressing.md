# IP Addressing - Complete Guide

## Overview

IP addressing is fundamental to network communication, allowing devices to identify and communicate with each other across networks. This guide covers IPv4, IPv6, and related concepts.

## Table of Contents

1. [IPv4 Addressing](#ipv4-addressing)
2. [IPv6 Addressing](#ipv6-addressing)
3. [Public vs Private IP](#public-vs-private-ip)
4. [APIPA](#apipa-automatic-private-ip-addressing)

---

## IPv4 Addressing

### What is IPv4?

**IPv4** stands for **Internet Protocol Version 4**

### Key Characteristics

1. **32-bit Address**: Composed of four octets (e.g., `192.168.1.1`)
2. **Dotted Decimal Notation**: Each octet ranges from 0 to 255
3. **Network and Host Parts**: Divides an address into network and host sections
4. **Subnetting**: Uses subnet masks to divide networks (e.g., `/24`)
5. **Limited Address Space**: Around 4.3 billion addresses, leading to exhaustion
6. **Public and Private IPs**: Public for global use, private for internal networks
7. **Broadcasting**: Allows sending data to all devices on a network
8. **Fragmentation**: Splits large packets to fit the MTU
9. **Loopback Address**: `127.0.0.1` reserved for testing on the same device

### Parts of IPv4 Address

| Component | Description | Example |
|-----------|-------------|---------|
| **Network Part** | Identifies the network an IP address belongs to | In `192.168.10.15/24`, the network part is `192.168.10` |
| **Host Part** | Identifies the specific device within the network | In `192.168.10.15/24`, the host part is `15` |
| **Subnet Mask** | Defines how much of the IP address is for the network vs. the host | A `/24` subnet mask means the first 24 bits are for the network, and the remaining 8 bits are for the host |

### IPv4 Address Structure Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    IPv4 Address: 192.168.10.15/24           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┬──────────┬──────────┬──────────┐             │
│  │   192    │   168    │    10    │    15    │             │
│  └──────────┴──────────┴──────────┴──────────┘             │
│                                                              │
│  ┌────────────────────────────────┬──────────┐             │
│  │      Network Part (24 bits)    │Host (8)  │             │
│  │        192.168.10.0            │   .15    │             │
│  └────────────────────────────────┴──────────┘             │
│                                                              │
│  Subnet Mask: 255.255.255.0 (/24)                          │
│  Network Address: 192.168.10.0                              │
│  Broadcast Address: 192.168.10.255                          │
│  Usable Hosts: 192.168.10.1 - 192.168.10.254 (254 hosts)  │
└─────────────────────────────────────────────────────────────┘
```

### Classes of IP Addresses

#### 1. Class A

- **Range**: `0.0.0.0` to `127.255.255.255`
- **Network/Host Bits**: 8 bits for the network, 24 bits for hosts
- **Usage**: Designed for large networks (e.g., ISPs)
- **Default Subnet Mask**: `255.0.0.0` or `/8`
- **Number of Networks**: 128 (2^7)
- **Hosts per Network**: 16,777,214 (2^24 - 2)

#### 2. Class B

- **Range**: `128.0.0.0` to `191.255.255.255`
- **Network/Host Bits**: 16 bits for the network, 16 bits for hosts
- **Usage**: Suitable for medium-sized networks
- **Default Subnet Mask**: `255.255.0.0` or `/16`
- **Number of Networks**: 16,384 (2^14)
- **Hosts per Network**: 65,534 (2^16 - 2)

#### 3. Class C

- **Range**: `192.0.0.0` to `223.255.255.255`
- **Network/Host Bits**: 24 bits for the network, 8 bits for hosts
- **Usage**: Ideal for small networks
- **Default Subnet Mask**: `255.255.255.0` or `/24`
- **Number of Networks**: 2,097,152 (2^21)
- **Hosts per Network**: 254 (2^8 - 2)

#### 4. Class D

- **Range**: `224.0.0.0` to `239.255.255.255`
- **Usage**: Reserved for multicast groups
- **No Network/Host Division**: Does not have a defined network/host structure

#### 5. Class E

- **Range**: `240.0.0.0` to `255.255.255.255`
- **Usage**: Reserved for experimental purposes
- **No Network/Host Division**: Not used for standard networking

### IP Address Classes Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    IPv4 Address Classes                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Class A: 0.0.0.0 - 127.255.255.255                            │
│  ┌────────┬─────────────────────────────────────┐              │
│  │Network │         Host                         │              │
│  │ 8 bits │           24 bits                    │              │
│  └────────┴─────────────────────────────────────┘              │
│  Default Mask: 255.0.0.0 (/8)                                   │
│  Example: 10.0.0.1                                              │
│                                                                  │
│  Class B: 128.0.0.0 - 191.255.255.255                          │
│  ┌──────────────────┬──────────────────┐                       │
│  │    Network       │      Host        │                       │
│  │    16 bits       │     16 bits      │                       │
│  └──────────────────┴──────────────────┘                       │
│  Default Mask: 255.255.0.0 (/16)                               │
│  Example: 172.16.0.1                                            │
│                                                                  │
│  Class C: 192.0.0.0 - 223.255.255.255                          │
│  ┌────────────────────────────┬────────┐                       │
│  │        Network             │  Host  │                       │
│  │        24 bits             │ 8 bits │                       │
│  └────────────────────────────┴────────┘                       │
│  Default Mask: 255.255.255.0 (/24)                             │
│  Example: 192.168.1.1                                           │
│                                                                  │
│  Class D: 224.0.0.0 - 239.255.255.255 (Multicast)             │
│  Class E: 240.0.0.0 - 255.255.255.255 (Experimental)           │
└─────────────────────────────────────────────────────────────────┘
```

### Summary Table

| Class | Address Range | Default Subnet Mask | Usage | Hosts per Network |
|-------|---------------|---------------------|-------|-------------------|
| A | `0.0.0.0` to `127.255.255.255` | `255.0.0.0` (`/8`) | Large networks | 16,777,214 |
| B | `128.0.0.0` to `191.255.255.255` | `255.255.0.0` (`/16`) | Medium-sized networks | 65,534 |
| C | `192.0.0.0` to `223.255.255.255` | `255.255.255.0` (`/24`) | Small networks | 254 |
| D | `224.0.0.0` to `239.255.255.255` | N/A | Multicast | N/A |
| E | `240.0.0.0` to `255.255.255.255` | N/A | Experimental purposes | N/A |

---

## IPv6 Addressing

### What is IPv6?

**IPv6** stands for **Internet Protocol Version 6**

Example: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`

### IPv6 Address Structure

An IPv6 address consists of eight groups of four hexadecimal digits separated by colons (':'), with each hex digit representing four bits, making the total length 128 bits.

```
┌─────────────────────────────────────────────────────────────────┐
│              IPv6 Address Structure (128 bits)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  2001:0db8:85a3:0000:0000:8a2e:0370:7334                       │
│                                                                  │
│  ┌──────────────────────┬────────┬─────────────────────┐       │
│  │  Global Routing      │Subnet  │    Interface ID     │       │
│  │  Prefix (48 bits)    │(16 bit)│    (64 bits)        │       │
│  └──────────────────────┴────────┴─────────────────────┘       │
│                                                                  │
│  ┌────────────────────────────────┬─────────────────────┐      │
│  │      Network Portion           │   Host Portion      │      │
│  │         (64 bits)              │    (64 bits)        │      │
│  └────────────────────────────────┴─────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

### IPv6 Address Components

**Format**: `gggg:gggg:gggg:ssss:xxxx:xxxx:xxxx:xxxx`

- **Global Routing Prefix** (First 48 bits): Identifies a specific network or subnet within the larger IPv6 internet. Assigned by an ISP or regional internet registry (RIR).

- **Subnet ID** (Next 16 bits): Used within an organization to identify subnets. Follows the Global Routing Prefix.

- **Interface ID** (Last 64 bits): Identifies a specific host on a network.

**Example**: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`

### Types of IPv6 Addresses

1. **Unicast**: One-to-one communication (single sender to single receiver)
2. **Multicast**: One-to-many communication (single sender to multiple receivers)
3. **Anycast**: One-to-nearest communication (single sender to nearest receiver in a group)

### IPv6 Address Shortening Rules

```
Original:  2001:0db8:0000:0000:0000:0000:0000:0001
Shortened: 2001:db8::1

Rules:
1. Leading zeros in each group can be omitted
2. Consecutive groups of zeros can be replaced with ::
3. :: can only be used once in an address
```

---

## IPv4 vs IPv6 Comparison

| Feature | IPv4 | IPv6 |
|---------|------|------|
| **Address Length** | 32 bits (4 bytes) | 128 bits (16 bytes) |
| **Address Format** | Decimal (dotted notation) (e.g., 192.168.1.1) | Hexadecimal (colon-separated) (e.g., 2001:0db8:85a3::1) |
| **Address Space** | Approximately 4.3 billion addresses | Approximately 340 undecillion addresses |
| **Address Classes** | Class-based (A, B, C, D, E) | Classless; uses CIDR |
| **Subnetting** | Complex subnetting with limited options | Simplified subnetting with prefix notation (e.g., /64) |
| **NAT Requirement** | Often requires NAT | Designed to eliminate the need for NAT |
| **Header Complexity** | More complex header (20-60 bytes) | Simplified header (40 bytes) |
| **Security** | IPsec is optional | IPsec is mandatory |
| **Broadcasting** | Supports broadcasting | No broadcast; uses multicast instead |
| **Configuration** | Manual or DHCP | SLAAC and DHCPv6 |
| **Fragmentation** | Routers and hosts can fragment packets | Only the sending host can fragment packets |
| **Routing** | More complex routing | Improved routing efficiency |

---

## Public IP vs Private IP

### Comparison Table

| Feature | Public IP Address | Private IP Address |
|---------|-------------------|-------------------|
| **Definition** | An IP address that is routable on the internet | An IP address used within a private network and not routable on the internet |
| **Address Range** | Any address outside the private ranges | **Class A**: `10.0.0.0` to `10.255.255.255`<br>**Class B**: `172.16.0.0` to `172.31.255.255`<br>**Class C**: `192.168.0.0` to `192.168.255.255` |
| **Routing** | Can be accessed from any device on the internet | Can only be accessed within the same local network |
| **Usage** | Used for devices that need to communicate over the internet | Used for devices within a LAN |
| **Example** | `203.0.113.1` | `192.168.1.1` |
| **NAT** | Not typically used with NAT | Often uses NAT to connect to the internet |
| **Security** | More exposed, requires security measures | More secure by default |
| **Ownership** | Assigned by ISPs (dynamic or static) | Assigned by network administrators |

### Public vs Private IP Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                  Public vs Private IP Flow                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Internet (Public Network)                                       │
│  ┌────────────────────────────────────────────┐                │
│  │  Public IP: 203.0.113.50                   │                │
│  │  ┌──────────────────────────────────────┐  │                │
│  │  │         ISP Router/Gateway           │  │                │
│  │  │  (NAT Translation Point)             │  │                │
│  │  └──────────────┬───────────────────────┘  │                │
│  └─────────────────┼──────────────────────────┘                │
│                    │                                             │
│                    │ NAT Translation                             │
│                    │ (Public ↔ Private)                         │
│                    │                                             │
│  Private Network (LAN)                                           │
│  ┌─────────────────┼──────────────────────────┐                │
│  │                 │                           │                │
│  │  ┌──────────────▼────────────┐             │                │
│  │  │  Router (Gateway)         │             │                │
│  │  │  Private IP: 192.168.1.1  │             │                │
│  │  └──────────────┬────────────┘             │                │
│  │                 │                           │                │
│  │     ┌───────────┼───────────┐              │                │
│  │     │           │           │              │                │
│  │  ┌──▼──┐    ┌──▼──┐    ┌──▼──┐           │                │
│  │  │ PC1 │    │ PC2 │    │ PC3 │           │                │
│  │  │.1.10│    │.1.11│    │.1.12│           │                │
│  │  └─────┘    └─────┘    └─────┘           │                │
│  │                                            │                │
│  │  All devices use private IPs internally   │                │
│  │  NAT translates to public IP for internet │                │
│  └────────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## APIPA (Automatic Private IP Addressing)

### What is APIPA?

An **Automatic Private IP Address (APIPA)** is what a device assigns itself when it can't get an IP address from a DHCP server. This happens when the device is set to obtain an IP automatically, but the DHCP server is unreachable.

### Key Characteristics

1. **Self-Assigned IP**: If the device can't reach the DHCP server, it gives itself an IP address in the range **169.254.0.0 to 169.254.255.255**
2. **Local Network Only**: Devices with APIPA can talk to other devices on the same local network, but **not** access the internet
3. **Subnet Mask**: Uses a subnet mask of **255.255.0.0** (/16)
4. **Purpose**: APIPA allows basic local network communication without a DHCP server, but indicates a potential network issue
5. **Retry Mechanism**: The device keeps checking for the DHCP server and will switch to a valid IP if it connects later

### APIPA Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    APIPA Assignment Process                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Device Boots Up                                         │
│  ┌──────────────────┐                                           │
│  │   Client Device  │                                           │
│  │  (No IP Address) │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           │ DHCP Discover Broadcast                             │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │  DHCP Server?    │ ◄─── No Response (Server Down/Unreachable)│
│  └──────────────────┘                                           │
│           │                                                      │
│           │ Timeout after multiple attempts                     │
│           ▼                                                      │
│  Step 2: APIPA Self-Assignment                                  │
│  ┌──────────────────┐                                           │
│  │  Client Device   │                                           │
│  │  Assigns:        │                                           │
│  │  169.254.x.x     │                                           │
│  │  Mask: /16       │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           │ ARP Check (Duplicate Detection)                     │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │  Local Network   │                                           │
│  │  Communication   │                                           │
│  │  (Limited)       │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           │ Continues to check for DHCP every 5 minutes         │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │  DHCP Available? │ ◄─── If Yes: Gets proper IP              │
│  └──────────────────┘      If No: Keeps APIPA                  │
│                                                                  │
│  Result: Limited local connectivity, no internet access         │
└─────────────────────────────────────────────────────────────────┘
```

### Special APIPA Address: 169.254.169.254

**Important Note**: `169.254.169.254` is used as a **metadata service endpoint** in cloud environments (AWS, Azure, Google Cloud).

**Purpose**:
- Provides instance details like:
  - Instance ID
  - IP addresses
  - IAM roles
  - Region information
- It's a **link-local address** (169.254.x.x), accessible only within the instance
- Ensures secure access to metadata without external API calls

**Example Usage in AWS**:
```bash
# Get instance metadata
curl http://169.254.169.254/latest/meta-data/

# Get instance ID
curl http://169.254.169.254/latest/meta-data/instance-id

# Get IAM role credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

## Best Practices

### IPv4 Best Practices

1. **Use Private IPs** for internal networks
2. **Implement NAT** for internet access from private networks
3. **Plan subnetting** carefully to avoid IP exhaustion
4. **Document IP allocations** for easier management
5. **Use DHCP** for dynamic IP assignment
6. **Reserve static IPs** for servers and network devices

### IPv6 Best Practices

1. **Plan for dual-stack** (IPv4 and IPv6) deployment
2. **Use SLAAC** for automatic configuration
3. **Implement proper security** (IPv6 doesn't hide behind NAT)
4. **Document IPv6 addressing scheme**
5. **Test IPv6 connectivity** before full deployment
6. **Use IPv6 privacy extensions** for client devices

### APIPA Troubleshooting

If you see an APIPA address (169.254.x.x):

1. **Check DHCP server** status
2. **Verify network connectivity** to DHCP server
3. **Check DHCP scope** for available addresses
4. **Restart network services**
5. **Manually assign IP** as temporary solution
6. **Check firewall rules** blocking DHCP traffic

---

## Summary

- **IPv4**: 32-bit addressing with ~4.3 billion addresses, uses classes and CIDR
- **IPv6**: 128-bit addressing with virtually unlimited addresses, simplified header
- **Public IPs**: Routable on the internet, assigned by ISPs
- **Private IPs**: Used internally, require NAT for internet access
- **APIPA**: Automatic fallback when DHCP is unavailable (169.254.x.x range)

Understanding IP addressing is crucial for network design, troubleshooting, and security implementation.
