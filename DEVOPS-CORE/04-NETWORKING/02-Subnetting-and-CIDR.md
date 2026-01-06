# Subnetting and CIDR - Complete Guide

## Overview

Subnetting is the practice of dividing a network into smaller, more manageable sub-networks. CIDR (Classless Inter-Domain Routing) provides a flexible method for IP address allocation and routing.

## Table of Contents

1. [What is Subnetting](#what-is-subnetting)
2. [Subnet Masks](#subnet-masks)
3. [5 Steps for Subnetting](#5-steps-for-subnetting)
4. [CIDR Notation](#cidr-notation)
5. [Practical Examples](#practical-examples)

---

## What is Subnetting?

**Subnetting** is the logical subdivision of an IP network into multiple smaller networks called subnets.

**Purpose**:
- Improves network performance
- Enhances security through network segmentation
- Efficient use of IP addresses
- Reduces broadcast traffic
- Simplifies network management

### Without Subnet vs With Subnet

```
┌─────────────────────────────────────────────────────────────────┐
│                    Without Subnetting                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Network: 192.168.1.0/24 (Single Flat Network)                 │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐       │  │
│  │  │ H1 │  │ H2 │  │ H3 │  │ H4 │  │ H5 │  │ H6 │       │  │
│  │  └────┘  └────┘  └────┘  └────┘  └────┘  └────┘       │  │
│  │   .1      .2      .3      .4      .5      .6           │  │
│  │                                                           │  │
│  │  All hosts in same broadcast domain                      │  │
│  │  All hosts can communicate directly                      │  │
│  │  254 usable addresses (192.168.1.1 - 192.168.1.254)     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    With Subnetting                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Network: 192.168.1.0/24 divided into 4 subnets (/26)          │
│                                                                  │
│  ┌──────────────────────────┐  ┌──────────────────────────┐   │
│  │  Subnet 1: .0/26         │  │  Subnet 2: .64/26        │   │
│  │  Range: .1 - .62         │  │  Range: .65 - .126       │   │
│  │  ┌────┐  ┌────┐          │  │  ┌────┐  ┌────┐         │   │
│  │  │ H1 │  │ H2 │          │  │  │ H3 │  │ H4 │         │   │
│  │  └────┘  └────┘          │  │  └────┘  └────┘         │   │
│  └──────────────────────────┘  └──────────────────────────┘   │
│                │                              │                 │
│                └──────────┬───────────────────┘                 │
│                           │                                     │
│                      ┌────▼────┐                               │
│                      │ Router  │ (Required for inter-subnet)   │
│                      └────┬────┘                               │
│                           │                                     │
│                ┌──────────┴───────────┐                        │
│                │                      │                        │
│  ┌─────────────▼────────┐  ┌─────────▼──────────┐            │
│  │  Subnet 3: .128/26   │  │  Subnet 4: .192/26 │            │
│  │  Range: .129 - .190  │  │  Range: .193 - .254│            │
│  │  ┌────┐  ┌────┐      │  │  ┌────┐  ┌────┐   │            │
│  │  │ H5 │  │ H6 │      │  │  │ H7 │  │ H8 │   │            │
│  │  └────┘  └────┘      │  │  └────┘  └────┘   │            │
│  └──────────────────────┘  └────────────────────┘            │
│                                                                  │
│  Benefits:                                                       │
│  - Isolated broadcast domains                                   │
│  - Better security (subnet isolation)                           │
│  - Improved performance                                         │
│  - Organized network structure                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Subnet Masks

A subnet mask determines which portion of an IP address represents the network and which represents the host.

### Default Subnet Masks

```
┌─────────────────────────────────────────────────────────────────┐
│                  Default Subnet Masks                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Class A: 255.0.0.0       (/8)                                  │
│  ┌────────┬─────────────────────────────────────┐              │
│  │Network │         Host                         │              │
│  │11111111│00000000.00000000.00000000            │              │
│  └────────┴─────────────────────────────────────┘              │
│  Example: 10.0.0.0/8                                            │
│  Hosts: 16,777,214                                              │
│                                                                  │
│  Class B: 255.255.0.0     (/16)                                 │
│  ┌──────────────────┬──────────────────┐                       │
│  │    Network       │      Host        │                       │
│  │11111111.11111111 │00000000.00000000 │                       │
│  └──────────────────┴──────────────────┘                       │
│  Example: 172.16.0.0/16                                         │
│  Hosts: 65,534                                                  │
│                                                                  │
│  Class C: 255.255.255.0   (/24)                                 │
│  ┌────────────────────────────┬────────┐                       │
│  │        Network             │  Host  │                       │
│  │11111111.11111111.11111111  │00000000│                       │
│  └────────────────────────────┴────────┘                       │
│  Example: 192.168.1.0/24                                        │
│  Hosts: 254                                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Subnet Mask Examples

| IP Address | Subnet Mask | Network Portion | Same Network? |
|------------|-------------|-----------------|---------------|
| 10.10.10.5 | 255.255.255.0 | 10.10.10.x | ✅ Yes |
| 10.10.10.8 | 255.255.255.0 | 10.10.10.x | ✅ Yes |
| 10.10.10.5 | 255.255.0.0 | 10.10.x.x | ✅ Yes |
| 10.10.20.5 | 255.255.0.0 | 10.10.x.x | ✅ Yes |
| 10.10.10.5 | 255.255.255.248 | Different subnets | ❌ No |
| 10.10.10.8 | 255.255.255.248 | Different subnets | ❌ No |

**Key Points**:
1. First two IP addresses with `/24` belong to the same subnet
2. If `255.255.255.0` means IPs starting with `10.10.10.xx` belong to same network
3. If `255.255.0.0` means IPs starting with `10.10.xx.xx` belong to same network
4. If `255.0.0.0` means IPs starting with `10.xx.xx.xx` belong to same network
5. A switch is enough for same subnet communication
6. A router is required for inter-subnet communication

---

## 5 Steps for Subnetting

```
┌─────────────────────────────────────────────────────────────────┐
│              5-Step Subnetting Process                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Identify Class and Default Subnet Mask                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  IP: 192.168.10.0                                         │  │
│  │  Class: C                                                 │  │
│  │  Default Mask: 255.255.255.0 (/24)                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Step 2: Convert Default Subnet Mask to Binary                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  255.255.255.0                                            │  │
│  │  11111111.11111111.11111111.00000000                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Step 3: Determine Hosts Required & Find Subnet Generator       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Required: 30 hosts per subnet                            │  │
│  │  Formula: 2^n - 2 ≥ 30                                   │  │
│  │  n = 5 (2^5 - 2 = 30 hosts)                              │  │
│  │  Subnet Generator: 2^(8-5) = 8                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Step 4: Generate New Subnet Mask                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Borrow 3 bits from host portion                         │  │
│  │  11111111.11111111.11111111.11100000                     │  │
│  │  255.255.255.224 (/27)                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Step 5: Generate Network Ranges                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Subnet 1: 192.168.10.0/27   (.1 - .30)                 │  │
│  │  Subnet 2: 192.168.10.32/27  (.33 - .62)                │  │
│  │  Subnet 3: 192.168.10.64/27  (.65 - .94)                │  │
│  │  Subnet 4: 192.168.10.96/27  (.97 - .126)               │  │
│  │  ... (8 subnets total)                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Detailed Example

**Scenario**: Subnet 192.168.10.0/24 to support 30 hosts per subnet

**Step 1**: Identify Class
- IP: 192.168.10.0
- Class: C
- Default Mask: 255.255.255.0 (/24)

**Step 2**: Convert to Binary
```
255.255.255.0 = 11111111.11111111.11111111.00000000
```

**Step 3**: Calculate Host Bits Needed
- Required hosts: 30
- Formula: 2^n - 2 ≥ 30
- n = 5 (2^5 - 2 = 30 usable hosts)
- Subnet bits: 8 - 5 = 3 bits
- Number of subnets: 2^3 = 8 subnets

**Step 4**: New Subnet Mask
```
Borrow 3 bits: 11111111.11111111.11111111.11100000
New Mask: 255.255.255.224 (/27)
```

**Step 5**: Subnet Ranges
| Subnet | Network Address | First Host | Last Host | Broadcast | Usable Hosts |
|--------|----------------|------------|-----------|-----------|--------------|
| 1 | 192.168.10.0 | 192.168.10.1 | 192.168.10.30 | 192.168.10.31 | 30 |
| 2 | 192.168.10.32 | 192.168.10.33 | 192.168.10.62 | 192.168.10.63 | 30 |
| 3 | 192.168.10.64 | 192.168.10.65 | 192.168.10.94 | 192.168.10.95 | 30 |
| 4 | 192.168.10.96 | 192.168.10.97 | 192.168.10.126 | 192.168.10.127 | 30 |
| 5 | 192.168.10.128 | 192.168.10.129 | 192.168.10.158 | 192.168.10.159 | 30 |
| 6 | 192.168.10.160 | 192.168.10.161 | 192.168.10.190 | 192.168.10.191 | 30 |
| 7 | 192.168.10.192 | 192.168.10.193 | 192.168.10.222 | 192.168.10.223 | 30 |
| 8 | 192.168.10.224 | 192.168.10.225 | 192.168.10.254 | 192.168.10.255 | 30 |

---

## CIDR Notation

**CIDR** = Classless Inter-Domain Routing

A method of IP address allocation and routing that allows for more efficient use of IP addresses.

### CIDR Representation

**Format**: `a.b.c.d/n`

Where:
- `a.b.c.d` = IP address
- `/n` = Number of network bits (prefix length)

**Example**: `192.168.1.0/22`

### CIDR Block Ranges

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIDR Block Ranges                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Class A: /8 to /32                                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  /8  = 16,777,214 hosts (255.0.0.0)                      │  │
│  │  /16 = 65,534 hosts     (255.255.0.0)                    │  │
│  │  /24 = 254 hosts        (255.255.255.0)                  │  │
│  │  /32 = 1 host           (255.255.255.255)                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Class B: /16 to /32                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  /16 = 65,534 hosts     (255.255.0.0)                    │  │
│  │  /20 = 4,094 hosts      (255.255.240.0)                  │  │
│  │  /24 = 254 hosts        (255.255.255.0)                  │  │
│  │  /32 = 1 host           (255.255.255.255)                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Class C: /24 to /32                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  /24 = 254 hosts        (255.255.255.0)                  │  │
│  │  /26 = 62 hosts         (255.255.255.192)                │  │
│  │  /28 = 14 hosts         (255.255.255.240)                │  │
│  │  /30 = 2 hosts          (255.255.255.252)                │  │
│  │  /32 = 1 host           (255.255.255.255)                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### CIDR Calculation Formula

**Formula for Available Hosts**:
```
Number of usable hosts = 2^(32 - n) - 2
```

Where:
- `n` = prefix length (number after the /)
- `-2` accounts for network and broadcast addresses

---

## Practical Examples

### Example 1: CIDR Notation `192.168.1.0/24`

**Step-by-Step Breakdown**:

1. **IP Address**: `192.168.1.0`
2. **Prefix Length**: `/24` (First 24 bits for network, last 8 bits for hosts)

3. **Binary Representation**:
```
11111111.11111111.11111111.00000000
```

4. **Subnet Mask**: `/24` = `255.255.255.0`

5. **Number of IP Addresses**:
```
2^8 = 256 IP addresses
```

6. **Reserved Addresses**:
- **Network address**: `192.168.1.0` (all 0s in host portion)
- **Broadcast address**: `192.168.1.255` (all 1s in host portion)

7. **Usable IP Addresses**:
```
256 - 2 = 254 usable addresses
Range: 192.168.1.1 to 192.168.1.254
```

### Example 2: CIDR Notation `192.168.0.0/16`

- **Subnet mask**: `255.255.0.0`
- **Usable IP addresses**: `2^16 - 2 = 65,534`
- **Range**: `192.168.0.1` to `192.168.255.254`

### Example 3: CIDR Notation `10.0.0.0/8`

- **Subnet mask**: `255.0.0.0`
- **Usable IP addresses**: `2^24 - 2 = 16,777,214`
- **Range**: `10.0.0.1` to `10.255.255.254`

### Example 4: CIDR Notation `192.168.1.0/28`

- **Subnet mask**: `255.255.255.240`
- **Usable IP addresses**: `2^4 - 2 = 14`
- **Range**: `192.168.1.1` to `192.168.1.14`

---

## CIDR Quick Reference Table

| CIDR | Subnet Mask | Wildcard Mask | # of IPs | Usable IPs | # of /24 nets |
|------|-------------|---------------|----------|------------|---------------|
| /8 | 255.0.0.0 | 0.255.255.255 | 16,777,216 | 16,777,214 | 65,536 |
| /16 | 255.255.0.0 | 0.0.255.255 | 65,536 | 65,534 | 256 |
| /17 | 255.255.128.0 | 0.0.127.255 | 32,768 | 32,766 | 128 |
| /18 | 255.255.192.0 | 0.0.63.255 | 16,384 | 16,382 | 64 |
| /19 | 255.255.224.0 | 0.0.31.255 | 8,192 | 8,190 | 32 |
| /20 | 255.255.240.0 | 0.0.15.255 | 4,096 | 4,094 | 16 |
| /21 | 255.255.248.0 | 0.0.7.255 | 2,048 | 2,046 | 8 |
| /22 | 255.255.252.0 | 0.0.3.255 | 1,024 | 1,022 | 4 |
| /23 | 255.255.254.0 | 0.0.1.255 | 512 | 510 | 2 |
| /24 | 255.255.255.0 | 0.0.0.255 | 256 | 254 | 1 |
| /25 | 255.255.255.128 | 0.0.0.127 | 128 | 126 | 1/2 |
| /26 | 255.255.255.192 | 0.0.0.63 | 64 | 62 | 1/4 |
| /27 | 255.255.255.224 | 0.0.0.31 | 32 | 30 | 1/8 |
| /28 | 255.255.255.240 | 0.0.0.15 | 16 | 14 | 1/16 |
| /29 | 255.255.255.248 | 0.0.0.7 | 8 | 6 | 1/32 |
| /30 | 255.255.255.252 | 0.0.0.3 | 4 | 2 | 1/64 |
| /31 | 255.255.255.254 | 0.0.0.1 | 2 | 2* | 1/128 |
| /32 | 255.255.255.255 | 0.0.0.0 | 1 | 1 | 1/256 |

**/31 is special**: Used for point-to-point links (RFC 3021), no network/broadcast addresses

---

## Best Practices

### Subnetting Best Practices

1. **Plan ahead**: Calculate future growth requirements
2. **Document everything**: Keep detailed subnet allocation records
3. **Use consistent schemes**: Apply logical patterns across your network
4. **Leave room for growth**: Don't use all available subnets immediately
5. **Align with VLANs**: Match subnets to VLAN structure
6. **Use appropriate sizes**: Don't waste IP space with oversized subnets

### CIDR Best Practices

1. **Use CIDR notation**: More flexible than classful addressing
2. **Aggregate routes**: Combine multiple networks into single routes
3. **Avoid fragmentation**: Plan contiguous address blocks
4. **Document allocations**: Track CIDR block assignments
5. **Use private ranges**: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
6. **Plan for IPv6**: Consider dual-stack implementation

---

## Common Subnetting Scenarios

### Scenario 1: Small Office (50 users)

**Requirement**: 50 hosts
**Solution**: Use /26 (62 usable hosts)
```
Network: 192.168.1.0/26
Range: 192.168.1.1 - 192.168.1.62
Broadcast: 192.168.1.63
```

### Scenario 2: Point-to-Point Link

**Requirement**: 2 hosts (router-to-router)
**Solution**: Use /30 (2 usable hosts)
```
Network: 10.0.0.0/30
Range: 10.0.0.1 - 10.0.0.2
Broadcast: 10.0.0.3
```

### Scenario 3: Large Enterprise (5000 users)

**Requirement**: 5000 hosts
**Solution**: Use /19 (8190 usable hosts)
```
Network: 172.16.0.0/19
Range: 172.16.0.1 - 172.16.31.254
Broadcast: 172.16.31.255
```

---

## Summary

- **Subnetting** divides networks into smaller, manageable segments
- **Subnet masks** determine network and host portions
- **5-step process** provides systematic approach to subnetting
- **CIDR** offers flexible, classless IP addressing
- **Formula**: Usable hosts = 2^(32-n) - 2
- **Planning** is crucial for efficient IP address utilization

Mastering subnetting and CIDR is essential for network design, optimization, and troubleshooting.
