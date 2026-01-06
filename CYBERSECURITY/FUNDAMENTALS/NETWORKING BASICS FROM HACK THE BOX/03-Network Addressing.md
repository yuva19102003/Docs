### ** Network Layer (OSI Layer 3)**

The **Network Layer (Layer 3)** in the OSI model manages the transfer of data packets across networks by handling **routing and logical addressing**. Since direct communication between sender and receiver isn't always possible, packets are forwarded through intermediate nodes (routers).

#### **Key Functions:**

- **Logical Addressing:** Assigns unique addresses (e.g., IPv4/IPv6).
- **Routing:** Determines the best path for data transmission.

#### **Common Protocols:**

- **IPv4 / IPv6** – Addressing and packet delivery.
- **IPsec** – Security for IP communications.
- **ICMP** – Error handling and diagnostics.
- **IGMP** – Manages multicast group memberships.
- **RIP, OSPF** – Routing protocols for determining paths.

It ensures **packet forwarding** between different subnets, even if they have **incompatible addressing schemes**. Nodes (routers) help forward packets by assigning them intermediate destinations until they reach the final recipient.

---
### ** IP Addresses and IPv4 Structure**

#### **1. IP Addressing and MAC Address**

- Devices in a network are identified by **MAC addresses** for local communication.
- Communication across networks requires **IP addresses (IPv4/IPv6)**, which consist of a **network part** and a **host part**.
- **MAC Address** is like an apartment number, while **IP Address** is like a building’s postal address.

#### **2. IPv4 Addressing and Structure**

- IPv4 uses a **32-bit** format, divided into **four 8-bit octets** (e.g., `192.168.1.1`).
- It allows for **4,294,967,296 unique addresses**.
- IP addresses were historically divided into **classes (A–E)**:
    - **Class A:** Large networks (1.0.0.0 – 127.255.255.255).
    - **Class B:** Medium-sized networks (128.0.0.0 – 191.255.255.255).
    - **Class C:** Small networks (192.0.0.0 – 223.255.255.255).
    - **Class D:** Multicast (224.0.0.0 – 239.255.255.255).
    - **Class E:** Reserved (240.0.0.0 – 255.255.255.255).

#### **3. Subnet Mask and Network Separation**

- Subnet masks determine which portion of an IP address is the **network part** and which is the **host part**.
- Common subnet masks:
    - **Class A:** `255.0.0.0 (/8)`
    - **Class B:** `255.255.0.0 (/16)`
    - **Class C:** `255.255.255.0 (/24)`

#### **4. Network and Gateway Addresses**

- **Network Address:** Identifies a subnet (e.g., `192.168.1.0`).
- **Broadcast Address:** Last IP in a subnet, used to send messages to all hosts (`192.168.1.255`).
- **Default Gateway:** Router's IP address that connects networks (`192.168.1.1`).

#### **5. Binary Representation of IPv4 Addresses**

- IPv4 addresses are converted between **binary and decimal** formats.
- Example: `192.168.10.39` in binary:
    
    ```
    1100 0000 . 1010 1000 . 0000 1010 . 0010 0111
    ```
    
- The **subnet mask** is calculated similarly.
---
### **Subnetting**

Subnetting is the process of dividing a large IP address range into smaller subnets, improving network organization and efficiency.

#### **Key Concepts**

- **Subnet**: A logical segment of a network with a common network address.
- **Subnet Mask**: Determines the separation between network and host parts.
- **Network & Host Parts**: Network bits remain fixed, while host bits can change.
- **CIDR Notation**: Used to specify subnet masks, e.g., `192.168.12.160/26`.

#### **Example Calculation**

Given:

- **IPv4 Address**: `192.168.12.160`
- **Subnet Mask**: `255.255.255.192` (`/26`)

##### **Network Details**

- **Network Address**: `192.168.12.128`
- **Broadcast Address**: `192.168.12.191`
- **First Host**: `192.168.12.129`
- **Last Host**: `192.168.12.190`
- **Usable Hosts**: `62`

#### **Subnetting into Smaller Networks**

If we divide the subnet into 4 smaller subnets:

- Increase subnet mask from `/26` to `/28`
- Each subnet has **16 addresses**, with **14 usable hosts**.

##### **Divided Subnets**

|Subnet No.|Network Address|First Host|Last Host|Broadcast Address|CIDR|
|---|---|---|---|---|---|
|1|192.168.12.128|192.168.12.129|192.168.12.142|192.168.12.143|/28|
|2|192.168.12.144|192.168.12.145|192.168.12.158|192.168.12.159|/28|
|3|192.168.12.160|192.168.12.161|192.168.12.174|192.168.12.175|/28|
|4|192.168.12.176|192.168.12.177|192.168.12.190|192.168.12.191|/28|

#### **Mental Subnetting**

- **Identifying subnet changes**: The **octet** that changes depends on subnet mask.
- **Modulo Operation (%)**: Helps determine the number of hosts per subnet.

##### **Subnet Size Calculation Table**

|Remainder|Hosts per Subnet|Exponential Form|Division Form|
|---|---|---|---|
|0|256|2⁸|256|
|1|128|2⁷|256/2|
|2|64|2⁶|256/4|
|3|32|2⁵|256/8|
|4|16|2⁴|256/16|
|5|8|2³|256/32|
|6|4|2²|256/64|
|7|2|2¹|256/128|

#### **Conclusion**

Subnetting allows efficient IP address allocation, ensuring optimized network management by dividing networks logically while minimizing address wastage.

---

10.200.20.0/27

11111111  11111111   11111111   111|00000  ---> 255.255.255.224/27 --> subnet mask
00001010  11101000    00010100   000|00000  --> 10.200.20.0 -->  ipv4

for network address
[changing 1 to 0 in host parts]
00001010  11101000    00010100   000|00000  --> 10.200.20.0

broadcast address 
[changing 0 to 1 in host parts]
00001010  11101000    00010100   000|11111 --> 10.200.20.31

first host --> 10.200.20.1
last host --> 10.200.20.30
total = 30 hosts

now divide it into 4 subnets
2^2 = 4, so add 2 bits

27 --> 29 bits --> 
11111111  11111111   11111111   11111|000  ---> 255.255.255.248 --> subnet mask
00001010  11101000    00010100   00000|000  --> 10.200.20.0 -->  ipv4

total ip including network address and broadcast address
32 / 4 = 8 hosts per subnets

network address        first host              last host            broadcast            cidr
10.200.20.0               10.200.20.1       10.200.20.6      10.200.20.7       10.200.20.0/29
10.200.20.8               10.200.20.9       10.200.20.14    10.200.20.15      10.200.20.8/29
10.200.20.16             10.200.20.17     10.200.20.22    10.200.20.23      10.200.20.16/29
10.200.20.24             10.200.20.25     10.200.20.30    10.200.20.31      10.200.20.24/29

---

### **MAC Addresses**

#### **Methodology:**

This document provides an in-depth explanation of MAC (Media Access Control) addresses, covering their structure, representations, and roles in network communication. Key aspects include:

1. **Structure of a MAC Address**
    
    - A MAC address is a **48-bit (6 octets)** identifier assigned to network interfaces.
    - Example formats:
        - **Colon-separated:** `DE:AD:BE:EF:13:37`
        - **Hyphen-separated:** `DE-AD-BE-EF-13-37`
        - **Dot-separated:** `DEAD.BEEF.1337`
2. **MAC Address Composition**
    
    - **First 3 bytes (OUI - Organizationally Unique Identifier):** Assigned by IEEE to manufacturers.
    - **Last 3 bytes (NIC - Network Interface Controller):** Assigned uniquely by the manufacturer.
3. **Addressing and Routing**
    
    - If a destination host is in the same subnet, the MAC address is used directly.
    - If the host is in another subnet, the MAC address of the router (default gateway) is used.
    - **Example:** If an Ethernet frame is destined for a remote host, it is first sent to the router’s MAC address.
4. **MAC Address Types**
    
    - **Unicast:** Sent to a single recipient.
        - Example: `DE:AD:BE:EF:13:37`
    - **Multicast:** Sent to multiple devices in a network.
        - Example: `01:00:5E:EF:13:37`
    - **Broadcast:** Sent to all devices in a network.
        - Example: `FF:FF:FF:FF:FF:FF`
5. **Locally vs. Globally Administered Addresses**
    
    - **Global (IEEE-assigned OUI):** `DC:AD:BE:EF:13:37`
    - **Locally Administered:** `DE:AD:BE:EF:13:37`
6. **Reserved MAC Address Ranges**
    
    - Examples of reserved local MAC addresses:
        - `02:00:00:00:00:00`
        - `06:00:00:00:00:00`

#### **Limitations:**

- MAC addresses can be **spoofed**, reducing their reliability for authentication.
- The document focuses only on **IPv4-based MAC resolution** (e.g., ARP) and does not cover **IPv6** mechanisms like **NDP (Neighbor Discovery Protocol)**.
- **Security concerns** related to MAC-based filtering and tracking are not discussed.

---

## ** Address Resolution Protocol (ARP) and MAC Address Spoofing**

### **Methodology:**

This document provides a detailed explanation of ARP, its role in network communication, and security vulnerabilities related to MAC address manipulation. It includes:

1. **MAC Address Manipulation and Security Concerns**
    
    - **MAC Spoofing:** Attackers alter a device’s MAC address to impersonate another device for unauthorized access.
    - **MAC Flooding:** Sending numerous packets with different MAC addresses to overwhelm a switch’s MAC table.
    - **MAC Address Filtering Bypass:** Attackers use spoofed MAC addresses to bypass network restrictions.
2. **Address Resolution Protocol (ARP)**
    
    - ARP is used to map **IP addresses (Layer 3)** to **MAC addresses (Layer 2)** within a LAN.
    - Process:
        - A device broadcasts an **ARP request** asking for the MAC address of a specific IP.
        - The target device responds with an **ARP reply** containing its MAC address.
3. **Types of ARP Messages**
    
    - **ARP Request:** Sent as a broadcast to resolve an IP to a MAC address.
    - **ARP Reply:** Sent as a unicast message containing the resolved MAC address.
4. **Packet Capture Example (Tshark Capture of ARP Requests)**
    
    ```
    1   0.000000 10.129.12.100 -> 10.129.12.255 ARP 60  Who has 10.129.12.101? Tell 10.129.12.100  
    2   0.000015 10.129.12.101 -> 10.129.12.100 ARP 60  10.129.12.101 is at AA:AA:AA:AA:AA:AA  
    3   0.000030 10.129.12.102 -> 10.129.12.255 ARP 60  Who has 10.129.12.103? Tell 10.129.12.102  
    4   0.000045 10.129.12.103 -> 10.129.12.102 ARP 60  10.129.12.103 is at BB:BB:BB:BB:BB:BB  
    ```
    
    - "Who has" indicates an ARP request.
    - The ARP reply provides the corresponding MAC address.
5. **ARP Spoofing (Poisoning) Attack**
    
    - Attackers send falsified ARP messages to associate their MAC address with another device’s IP.
    - Tools such as **Ettercap** and **Cain & Abel** can perform ARP poisoning.
    
    **Example of ARP Spoofing Capture:**
    
    ```
    1   0.000000 10.129.12.100 -> 10.129.12.101 ARP 60  10.129.12.100 is at AA:AA:AA:AA:AA:AA  
    2   0.000015 10.129.12.100 -> 10.129.12.255 ARP 60  Who has 10.129.12.101? Tell 10.129.12.100  
    3   0.000030 10.129.12.101 -> 10.129.12.100 ARP 60  10.129.12.101 is at BB:BB:BB:BB:BB:BB  
    4   0.000045 10.129.12.100 -> 10.129.12.101 ARP 60  10.129.12.100 is at AA:AA:AA:AA:AA:AA  
    ```
    
    - The attacker (10.129.12.100) falsely claims the MAC address of the target (10.129.12.101).
6. **Mitigation Strategies for ARP-Based Attacks**
    
    - **Secure protocols:** Implement **IPSec, SSL/TLS** for encrypted communication.
    - **Static ARP entries:** Prevent ARP poisoning by manually setting MAC-IP mappings.
    - **Firewalls & IDS:** Detect and block suspicious ARP activity.
    - **Dynamic ARP Inspection (DAI):** Validate ARP responses to prevent spoofing.

### **Limitations:**

- ARP is inherently **insecure** as it lacks authentication, making it vulnerable to spoofing.
- MAC-based security is **not reliable** alone and requires **additional protections** like strong authentication.
- Focuses on **IPv4 ARP**; does not cover **IPv6 mechanisms** like Neighbor Discovery Protocol (NDP).

---

### **IPv6 Addressing **

#### **1. Introduction**

IPv6 is the successor to IPv4, featuring a **128-bit address length** compared to IPv4’s **32-bit**. It provides a much larger address space (~340 undecillion addresses) and is designed to replace IPv4 while supporting **dual stack** operation. IPv6 eliminates the need for NAT, allowing direct end-to-end communication.

#### **2. Advantages of IPv6**

- **Larger address space**
- **Address self-configuration** (SLAAC)
- **Multiple addresses per interface**
- **Faster routing**
- **Built-in IPsec for encryption**
- **Supports large data packets (up to 4GB)**

#### **3. IPv6 Address Types**

- **Unicast** – Identifies a single interface.
- **Anycast** – Sent to the nearest of multiple interfaces.
- **Multicast** – Sent to multiple interfaces (replaces broadcast).

#### **4. IPv6 Address Representation**

IPv6 addresses use **hexadecimal notation**, with **8 groups of 4 hex digits** separated by colons (`:`).

Example of an IPv6 address:

**Full IPv6 Address:**  
`fe80:0000:0000:0000:dd80:b1a9:6687:2d3b/64`

**Shortened IPv6 Address:**  
`fe80::dd80:b1a9:6687:2d3b/64`

#### **5. IPv6 Notation Rules (RFC 5952)**

- Use **lowercase** letters (`a-f`).
- **Omit leading zeros** in each block.
- **Replace consecutive zero blocks** with `::` (only once).

#### **6. IPv4 to Hexadecimal Conversion Example**

IPv4 Address: **192.168.12.160**

|Representation|1st Octet|2nd Octet|3rd Octet|4th Octet|
|---|---|---|---|---|
|**Binary**|1100 0000|1010 1000|0000 1100|1010 0000|
|**Hex**|C0|A8|0C|A0|
|**Decimal**|192|168|12|160|

IPv6 enhances **security, scalability, and efficiency**, making it the future standard for networking.

---
