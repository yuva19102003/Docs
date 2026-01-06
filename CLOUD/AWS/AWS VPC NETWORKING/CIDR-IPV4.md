
## 🔍 What is CIDR?

**CIDR (Classless Inter-Domain Routing)** is a method for **allocating IP addresses** and **routing IP packets** more efficiently than the old class-based system.

It uses a **prefix** and a **slash notation** to represent a range of IP addresses.  
Example: `192.168.1.0/24`

---

## 🧠 CIDR Basics

### 📌 CIDR Notation

CIDR uses the format:

```
<IP Address>/<Prefix Length>
```

- **IP Address** → Starting address of the range (in IPv4: 4 octets).
    
- **Prefix Length** → Number of bits used for the **network** part.
    

> Example: `192.168.1.0/24`  
> This means:

- First 24 bits = network
    
- Remaining 8 bits = hosts
    
- 2⁸ - 2 = 254 usable IPs
    

---

### 📌 Binary Representation of IPs

Each IPv4 address is **32 bits**, divided into **4 octets (bytes)**.

For example:

```
192.168.1.0 =
  11000000 . 10101000 . 00000001 . 00000000
```

Prefix `/24` means:

```
First 24 bits: Network
Last 8 bits: Hosts
```

---

## 🧮 Calculating CIDR Ranges

Let’s go through **CIDR calculations step-by-step**:

---

### 🔢 How Many IPs in a CIDR Block?

Use the formula:

```
Number of IPs = 2^(32 - CIDR prefix)
```

|CIDR|IPs|Usable IPs|Subnet Mask|
|---|---|---|---|
|/32|1|1|255.255.255.255|
|/30|4|2|255.255.255.252|
|/29|8|6|255.255.255.248|
|/28|16|14|255.255.255.240|
|/24|256|254|255.255.255.0|
|/16|65,536|65,534|255.255.0.0|
|/8|16,777,216|16,777,214|255.0.0.0|

> ⚠️ Subtract 2 IPs from total:
> 
> - One for **network address**
>     
> - One for **broadcast address**
>     

---

## 🛠 CIDR Examples

### ✅ Example 1: `192.168.10.0/24`

- IP Range: `192.168.10.0 – 192.168.10.255`
    
- Network Address: `192.168.10.0`
    
- Broadcast Address: `192.168.10.255`
    
- Usable IPs: `192.168.10.1 – 192.168.10.254`
    
- Total IPs: 256
    

---

### ✅ Example 2: `10.0.0.0/8`

- IP Range: `10.0.0.0 – 10.255.255.255`
    
- Usable IPs: `10.0.0.1 – 10.255.255.254`
    
- Total IPs: 16,777,216
    

---

## 🧩 CIDR vs Subnet Mask

|CIDR|Subnet Mask|
|---|---|
|/24|255.255.255.0|
|/16|255.255.0.0|
|/8|255.0.0.0|

> Both represent the same thing, but **CIDR is simpler** for routing and summarization.

---

## ⚒️ Subnetting with CIDR

Suppose you have a `/24` block and you want to create **4 subnets**:

- `/24` = 256 IPs
    
- 4 subnets → need 64 IPs each
    
- Each subnet will be `/26` (2⁶ = 64)
    

### Subnets:

```
192.168.1.0/26    → 192.168.1.0 – 192.168.1.63
192.168.1.64/26   → 192.168.1.64 – 192.168.1.127
192.168.1.128/26  → 192.168.1.128 – 192.168.1.191
192.168.1.192/26  → 192.168.1.192 – 192.168.1.255
```

---

## 🌐 CIDR in Real World Use

### 1. **AWS VPC**

- Create a VPC with CIDR block: `10.0.0.0/16`
    
- Subnets inside:
    
    - `10.0.1.0/24` → public
        
    - `10.0.2.0/24` → private
        

### 2. **Kubernetes**

- Pod CIDR: `10.244.0.0/16`
    
- Each node might get `/24` (256 pods per node)
    

### 3. **Firewalls & Routing**

- Define CIDR blocks for **allow/block rules**.
    
- Example: Allow only `192.168.0.0/16` traffic.
    

---

## 📘 CIDR Cheat Sheet

|Prefix|Subnet Mask|Hosts|
|---|---|---|
|/30|255.255.255.252|2|
|/29|255.255.255.248|6|
|/28|255.255.255.240|14|
|/27|255.255.255.224|30|
|/26|255.255.255.192|62|
|/25|255.255.255.128|126|
|/24|255.255.255.0|254|
|/23|255.255.254.0|510|
|/22|255.255.252.0|1022|

---

## 🔧 Tools

- **IP Calculator Tools:**
    
    - [https://www.subnet-calculator.com/](https://www.subnet-calculator.com/)
        
    - [https://www.ipcalc.org/](https://www.ipcalc.org/)
        
- **Command line (Linux):**
    
    - `ipcalc 192.168.1.0/24`
        
    - `sipcalc`
        

---

## 📌 Summary

|Concept|Meaning|
|---|---|
|CIDR Notation|`IP_address/Prefix_length`|
|Network Bits|First _N_ bits (CIDR prefix)|
|Host Bits|Remaining 32-N bits|
|Total IPs|2^(32 - prefix)|
|Usable IPs|Total - 2 (network + broadcast)|
|Use Cases|Routing, Subnetting, AWS VPCs, Kubernetes clusters|

---

Would you like a **CIDR practice quiz**, **PDF version**, or a **hands-on exercise (e.g., VPC subnetting)**?