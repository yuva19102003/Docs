 
Wireshark is an open-source network protocol analyzer used for capturing and inspecting network traffic in real time. It allows users to analyze packets at a granular level, helping in troubleshooting network issues, monitoring security threats, and understanding network protocols.

### **Key Features of Wireshark**

✅ **Packet Capture** – Captures live network traffic from wired and wireless interfaces.  
✅ **Deep Packet Inspection** – Analyzes protocols and packet details.  
✅ **Filtering & Searching** – Supports display and capture filters to refine data.  
✅ **Traffic Analysis** – Helps diagnose slow networks, dropped packets, or security threats.  
✅ **Decryption Support** – Can decrypt protocols like TLS/SSL (if keys are available).  
✅ **Cross-Platform** – Works on Windows, Linux, and macOS.

💡 **Use Case Examples**  
🔹 Debugging network issues (e.g., packet loss, latency).  
🔹 Analyzing HTTP requests for web applications.  
🔹 Detecting unauthorized access attempts or cyber threats.

---

## **Wireshark Interface Overview**

Wireshark's interface is divided into several key sections, making it easy to capture, filter, and analyze network packets. Below is a breakdown of its interface:

---

#### **1. Menu Bar**

Located at the top, the **Menu Bar** provides access to various Wireshark functions.

- **File** – Open, save, and export capture files.
    
- **Edit** – Preferences, find packets, and configure Wireshark.
    
- **View** – Customize layout, coloring, and zoom levels.
    
- **Capture** – Start, stop, restart, and configure capture settings.
    
- **Analyze** – Apply display filters and follow network streams.
    
- **Statistics** – View protocol hierarchy, I/O graphs, and conversation details.
    
- **Help** – Access documentation and Wireshark community support.
    

---

#### **2. Toolbar**

Below the menu bar, the **Toolbar** provides quick access to essential functions.

🔹 **Start/Stop Capture** – Buttons to control packet capture.  
🔹 **Capture Options** – Configure interfaces, buffer size, and packet limits.  
🔹 **Open File** – Load previous captures (`.pcapng`, `.pcap`).  
🔹 **Apply Display Filter** – Enter filters like `ip.addr == 192.168.1.1`.  
🔹 **Color Filters** – Highlights specific protocols (TCP, DNS, ARP).

---

#### **3. Interface List (Capture Section)**

When starting Wireshark, you’ll see a list of available **network interfaces** (Wi-Fi, Ethernet, loopback, etc.).

- Select an **interface** (e.g., `eth0` for Ethernet, `wlan0` for Wi-Fi) to begin packet capture.
    
- Live traffic statistics (packet count, bytes per second) are displayed next to each interface.
    

💡 **Tip**: Use `Capture → Options` to customize capture settings before starting.

---

#### **4. Packet List Pane (Top Section)**

This pane displays captured packets in **real-time**.

Columns include:

- **No.** – Packet number in capture.
    
- **Time** – Timestamp (relative or absolute).
    
- **Source** – Sender’s IP address.
    
- **Destination** – Receiver’s IP address.
    
- **Protocol** – Identified protocol (e.g., TCP, HTTP, DNS).
    
- **Length** – Packet size in bytes.
    
- **Info** – Brief packet description.
    

🔹 **Clicking a packet** selects it for detailed analysis.

---

#### **5. Packet Details Pane (Middle Section)**

This pane shows a **structured breakdown** of the selected packet.

- **Frame Header** – Metadata (time, interface, length).
    
- **Ethernet Layer** – MAC addresses and frame type.
    
- **IP Layer** – Source/destination IP addresses, TTL, checksum.
    
- **Transport Layer** – TCP/UDP details (ports, sequence numbers).
    
- **Application Layer** – HTTP headers, DNS queries, encrypted payloads.
    

💡 **Tip**: Right-click on a field → **Apply as Filter** to quickly filter packets.

---

#### **6. Packet Bytes Pane (Bottom Section)**

This pane displays the **raw data** of the selected packet in **hexadecimal and ASCII** format.

🔹 Useful for deep-level protocol analysis or investigating **malware payloads**.  
🔹 Can be **copied/exported** for further analysis.

---

#### **7. Status Bar (Bottom Section)**

Displays **summary information** about the capture session.

- **Packet count** – Total captured packets.
    
- **Displayed packets** – Number of packets after applying a filter.
    
- **Dropped packets** – Shows if any packets were lost during capture.
    
- **Profile selection** – Switch between custom analysis profiles.
    

---
### **Steps to Capture and Save Packets in Wireshark**

1️⃣ **Open Wireshark**  
2️⃣ **Select a Network Interface** (e.g., Ethernet, Wi-Fi)  
3️⃣ **Start Capture** (Click the Shark Fin icon or press `Ctrl + E`)  
4️⃣ **Stop Capture** (Click the Red Square icon or press `Ctrl + E`)  
5️⃣ **Save Capture** → **File → Save As** → Choose `.pcapng` or `.pcap`

✅ Done! Your packet capture is saved for analysis. 🚀

---

### **Filters in Wireshark**

Filters in Wireshark help refine captured network traffic for easier analysis. They allow users to focus on specific packets based on IP addresses, protocols, ports, or other parameters.

#### **Types of Filters in Wireshark**

1️⃣ **Capture Filters** (Before capturing packets)

- Applied **before** packet capture to limit data collection.
    
- Example:
    
    ```plaintext
    host 192.168.1.10  # Capture traffic from/to this IP
    port 80            # Capture only HTTP traffic
    ```
    

2️⃣ **Display Filters** (After capturing packets)

- Applied **after** packet capture to refine displayed results.
    
- Example:
    
    ```plaintext
    ip.addr == 192.168.1.10  # Show packets from/to this IP
    tcp.port == 443          # Show only HTTPS traffic
    dns                      # Show only DNS packets
    ```
    

💡 **Tip**: Use `Expression Editor` in Wireshark to create complex filters easily! 🚀

---

### **How to Capture and View Unencrypted HTTP Data in Wireshark**

🚨 **Note:** This works **only** for unencrypted HTTP traffic. If the website uses HTTPS (TLS encryption), you won’t see readable data unless you have the decryption keys.

#### **Steps to Capture HTTP Packets**

1️⃣ **Open Wireshark**  
2️⃣ **Select Network Interface** (e.g., Wi-Fi or Ethernet)  
3️⃣ **Apply Capture Filter (Optional)**

```
tcp port http
```

4️⃣ **Start Capture** (`Ctrl + E`) and Visit an HTTP Website

- Example: `http://example.com`  
    5️⃣ **Stop Capture** (`Ctrl + E`)  
    6️⃣ **Apply Display Filter to Show Only HTTP Traffic**
    

```
http.request.method
```

7️⃣ **Analyze HTTP Packets**

- Find **GET** and **POST** requests.
    
- Click a packet → Expand **Hypertext Transfer Protocol**.
    
- Right-click → **Follow HTTP Stream** to see raw data.
    

✅ **Now you can see unencrypted data (usernames, passwords, cookies) if the site does not use HTTPS!** 🚀

---

### **Wireshark Filters: Protocol, Address, and Port Filters**

#### **1️⃣ Protocol Filters** (Filter by network protocol)

Used to display packets for a specific protocol (TCP, UDP, HTTP, DNS, etc.).

📌 **Examples:**

```plaintext
http        # Show only HTTP traffic  
dns         # Show only DNS packets  
tcp         # Show only TCP packets  
udp         # Show only UDP packets  
icmp        # Show only ICMP (ping) packets  
```

---

#### **2️⃣ Address Filters** (Filter by IP/MAC address)

Used to show packets from or to a specific device.

📌 **Examples:**

```plaintext
ip.addr == 192.168.1.10       # Show packets where 192.168.1.10 is source or destination  
ip.src == 192.168.1.10        # Show packets where 192.168.1.10 is the source  
ip.dst == 192.168.1.10        # Show packets where 192.168.1.10 is the destination  
eth.addr == 00:1A:2B:3C:4D:5E # Show packets from/to a specific MAC address  
```

---

#### **3️⃣ Port Filters** (Filter by network ports)

Used to filter packets based on source or destination port numbers.

📌 **Examples:**

```plaintext
tcp.port == 80       # Show only HTTP packets  
udp.port == 53       # Show only DNS packets  
tcp.srcport == 443   # Show packets where the source port is HTTPS  
tcp.dstport == 22    # Show packets where the destination port is SSH  
```

💡 **Tip:** You can combine filters!

```plaintext
ip.addr  192.168.1.10 && tcp.port  80
```

This shows **only HTTP traffic** from/to `192.168.1.10`. 🚀

---

### **Logical Operators in Wireshark Filters**

Wireshark supports **logical operators** to combine multiple filter conditions for precise packet analysis.

#### **1️⃣ AND Operator (`&&` or `and`)**

✅ Matches **all** conditions (both must be true).  
📌 **Example:**

```plaintext
ip.addr  192.168.1.10 && tcp.port  80
```

🔹 Shows HTTP traffic only from/to `192.168.1.10`.

---

#### **2️⃣ OR Operator (`||` or `or`)**

✅ Matches **any** condition (at least one must be true).  
📌 **Example:**

```plaintext
tcp.port  80 || tcp.port  443
```

🔹 Shows both HTTP (`80`) and HTTPS (`443`) traffic.

---

#### **3️⃣ NOT Operator (`!` or `not`)**

✅ Excludes packets that match the condition.  
📌 **Example:**

```plaintext
!http
```

🔹 Hides all HTTP packets, showing everything else.

---

#### **4️⃣ Combining Operators**

✅ Complex filters using multiple conditions.  
📌 **Example:**

```plaintext
(ip.src  192.168.1.10 || ip.src  192.168.1.20) && tcp.port == 22
```

🔹 Shows SSH traffic (`22`) from **either** `192.168.1.10` or `192.168.1.20`.

💡 **Tip:** Use parentheses `()` for clarity! 🚀

---

## **Wireshark Coloring Rules** 🎨

Wireshark uses **coloring rules** to highlight packets for quick identification. These colors help distinguish protocols, errors, or specific traffic patterns.

#### **1️⃣ Default Coloring Rules**

Wireshark applies default colors:

- 🔵 **Light Blue** → TCP traffic
    
- 🟢 **Green** → HTTP traffic
    
- 🟡 **Yellow** → Warnings (e.g., retransmissions)
    
- 🔴 **Red** → Errors (e.g., malformed packets)
    
- ⚫ **Black** → Rejected or dropped packets
    

---

#### **2️⃣ Viewing & Editing Coloring Rules**

📌 **Steps to Open Coloring Rules:**

- Go to **View → Coloring Rules**
    
- Modify existing rules or add new ones
    

📌 **Creating a New Rule:**

1. Click **+** (Add Rule)
    
2. Enter a **filter condition** (e.g., `tcp.port == 443`)
    
3. Choose a **foreground & background color**
    
4. Click **OK → Apply**
    

---

#### **3️⃣ Example Custom Rules**

✅ Highlight all DNS traffic in **Purple**:

```plaintext
dns
```

✅ Mark all SSH packets in **Orange**:

```plaintext
tcp.port == 22
```

✅ Highlight traffic from a specific IP in **Pink**:

```plaintext
ip.addr == 192.168.1.100
```

---

### **Wireshark Profiles** 🛠️

A **Wireshark Profile** is a customized workspace with specific settings for different analysis needs.

#### **1️⃣ Features of Profiles**

- **Custom Display Filters**
    
- **Coloring Rules**
    
- **Capture Settings**
    
- **Column Layouts**
    

#### **2️⃣ Create a New Profile**

📌 **Steps:**

1. **Edit → Configuration Profiles**
    
2. Click **New** → Enter a Name
    
3. Customize settings (filters, columns, colors, etc.)
    
4. Click **OK** to save
    

#### **3️⃣ Switching Profiles**

- **Bottom-right corner** → Select a profile from the list
    
- **Edit → Configuration Profiles** to manage profiles
    

---

## Wireshark Statistics Explained 📊

Wireshark provides various statistical tools for analyzing network traffic. Below is a detailed explanation of each option available under the Statistics menu.

---

1️⃣ Capture File Properties

📌 Location: Statistics → Capture File Properties
🔹 Provides basic information about the capture file:

File name, size, and format
Capture duration (start & end time)
Packet count and average packet size
Interface and capture filter used

---

2️⃣ Resolved Addresses

📌 Location: Statistics → Resolved Addresses
🔹 Displays resolved MAC, IP, and DNS names from packet captures.
✅ Useful for identifying human-readable names instead of raw IPs or MACs.

---

3️⃣ Protocol Hierarchy

📌 Location: Statistics → Protocol Hierarchy
🔹 Shows the breakdown of network protocols used in the capture.
✅ Useful for understanding protocol distribution and identifying dominant traffic types.

---

4️⃣ Conversations

📌 Location: Statistics → Conversations
🔹 Displays active connections based on:

Ethernet (MAC addresses)
IPv4/IPv6 (IP addresses)
TCP/UDP (ports used in communication)
✅ Helps analyze communication between specific devices.

---

5️⃣ Endpoints

📌 Location: Statistics → Endpoints
🔹 Shows all network devices involved in communication.
✅ Useful for identifying top talkers and analyzing device-level traffic.

---

6️⃣ Packet Lengths

📌 Location: Statistics → Packet Lengths
🔹 Displays the distribution of packet sizes in the capture.
✅ Helps detect:
Too many small packets (inefficiency)
Too many large packets (bulk data transfers)

---

7️⃣ I/O Graph

📌 Location: Statistics → I/O Graph
🔹 Provides a graphical representation of network traffic over time.
✅ Helps in performance monitoring, DDoS detection, and traffic analysis.

---

8️⃣ Service Response Time

📌 Location: Statistics → Service Response Time
🔹 Measures response time of different services (HTTP, DNS, etc.).
✅ Helps detect latency issues in network services.

---

9️⃣ DHCP (BOOTP) Statistics

📌 Location: Statistics → DHCP (BOOTP)
🔹 Displays statistics on DHCP requests, offers, and leases.
✅ Useful for analyzing DHCP issues in networks.

---

🔟 NetPerfMeter Statistics

📌 Location: Statistics → NetPerfMeter
🔹 Analyzes network performance metrics, such as bandwidth and delay.

---

11️⃣ ONC-RPC Programs

📌 Location: Statistics → ONC-RPC Programs
🔹 Displays statistics for Remote Procedure Calls (RPCs).
✅ Helps troubleshoot NFS and other RPC-based services.

---

12️⃣ 29West Statistics

📌 Location: Statistics → 29West
🔹 Displays statistics related to 29West messaging middleware (used in financial services).

---

13️⃣ ANCP Statistics

📌 Location: Statistics → ANCP
🔹 Displays statistics for Access Node Control Protocol (ANCP), used in DSL networks.

---

14️⃣ BACnet Statistics

📌 Location: Statistics → BACnet
🔹 Analyzes BACnet protocol (used in building automation).

---

15️⃣ Collectd Statistics

📌 Location: Statistics → Collectd
🔹 Displays statistics for Collectd, a system performance monitoring daemon.

---

16️⃣ DNS Statistics

📌 Location: Statistics → DNS
🔹 Provides an overview of DNS queries and responses.
✅ Helps detect slow DNS resolution or DNS attacks.

---

17️⃣ Flow Graph

📌 Location: Statistics → Flow Graph
🔹 Visualizes packet flow between devices.
✅ Helps in troubleshooting network communication issues.

---

18️⃣ HART-IP Statistics

📌 Location: Statistics → HART-IP
🔹 Analyzes HART-IP protocol (used in industrial automation).

---

19️⃣ HPFeeds Statistics

📌 Location: Statistics → HPFeeds
🔹 Displays statistics for HPFeeds, a protocol for honeypot data collection.

---

20️⃣ HTTP Statistics

📌 Location: Statistics → HTTP
🔹 Shows HTTP traffic details:

Requests & responses

Top accessed URLs

Response codes (200, 404, etc.)
✅ Helps analyze web traffic & performance issues.

---

21️⃣ HTTP2 Statistics

📌 Location: Statistics → HTTP2
🔹 Similar to HTTP statistics, but for the HTTP/2 protocol.

---

22️⃣ Sametime Statistics

📌 Location: Statistics → Sametime
🔹 Displays statistics for IBM Sametime, an enterprise messaging service.

---

23️⃣ TCP Stream Graph

📌 Location: Statistics → TCP Stream Graph
🔹 Graphs TCP performance metrics like:

Round Trip Time (RTT)

Throughput

Packet retransmissions
✅ Helps diagnose network slowness & packet loss.

---

24️⃣ UDP Multicast Streams

📌 Location: Statistics → UDP Multicast Streams
🔹 Displays multicast traffic statistics, used in IPTV and VoIP.

---

25️⃣ Reliable Server Pooling (RSerPool)

📌 Location: Statistics → RSerPool
🔹 Displays statistics for RSerPool, a protocol for high-availability server pooling.

---

26️⃣ SOME/IP Statistics

📌 Location: Statistics → SOME/IP
🔹 Analyzes SOME/IP protocol (used in automotive communication).

---

27️⃣ DTN Statistics

📌 Location: Statistics → DTN
🔹 Displays statistics for Delay-Tolerant Networking (DTN), used in space communication.

---

28️⃣ F5 Statistics

📌 Location: Statistics → F5
🔹 Shows traffic related to F5 load balancers.

---

29️⃣ IPv4 Statistics

📌 Location: Statistics → IPv4
🔹 Provides insights into IPv4 traffic, including:

Packet count & errors

Fragmentation analysis

---

30️⃣ IPv6 Statistics

📌 Location: Statistics → IPv6
🔹 Similar to IPv4 statistics, but for IPv6 traffic.

---


# **TCP Three-Way Handshake in Wireshark** 🕵️‍♂️

The **TCP three-way handshake** is the process of establishing a reliable connection between a client and a server. It ensures both sides are ready before data transfer begins.

---

## **🔹 Steps in the Three-Way Handshake**

### **1️⃣ SYN (Synchronize)**

📌 The client sends a **SYN** packet to the server.  
🔹 This packet contains:

- **SYN flag = 1** (indicates connection request)
    
- **Initial Sequence Number (ISN)** (random number)
    

👉 **Client → Server: SYN (Seq=1000)**

---

### **2️⃣ SYN-ACK (Synchronize-Acknowledge)**

📌 The server responds with a **SYN-ACK** packet.  
🔹 This packet contains:

- **SYN = 1** (server agrees to start connection)
    
- **ACK = 1** (acknowledges client's SYN)
    
- **Server's ISN**
    

👉 **Server → Client: SYN-ACK (Seq=2000, Ack=1001)**

---

### **3️⃣ ACK (Acknowledge)**

📌 The client sends a final **ACK** packet to confirm the connection.  
🔹 This packet contains:

- **ACK = 1** (acknowledges server's SYN)
    

👉 **Client → Server: ACK (Seq=1001, Ack=2001)**

✅ **Connection Established!** 🎉

---

## **🔹 RST (Reset) Packet**

📌 **RST** is used to **abruptly terminate** a connection due to errors or unexpected behavior.  
🔹 When an RST packet is sent:

- The connection is **immediately closed**
    
- No further communication happens
    

👉 Example: **Server sends RST if it receives unexpected data.**

---

## **🔹 Viewing TCP Handshake in Wireshark**

### **🛠 Steps to Capture TCP Handshake**

1. **Open Wireshark** and start capturing packets.
    
2. **Apply a filter** to focus on TCP handshakes:
    
    ```
    tcp.flags.syn == 1
    ```
    
3. **Initiate a connection**, like opening a website or using SSH.
    
4. **Stop the capture** and analyze the handshake.
    

---

### **🔹 Identifying Handshake Packets in Wireshark**

|Step|Source → Destination|Flags|Info|
|---|---|---|---|
|1️⃣ SYN|Client → Server|SYN|`SYN, Seq=1000`|
|2️⃣ SYN-ACK|Server → Client|SYN, ACK|`SYN, ACK, Seq=2000, Ack=1001`|
|3️⃣ ACK|Client → Server|ACK|`ACK, Seq=1001, Ack=2001`|

✅ **Connection Established!**

---

### **🔹 Filtering TCP Reset (RST) Packets**

To find connections that were **abruptly closed**:

```
tcp.flags.reset == 1
```

This will show **RST packets**, which indicate a connection reset.

---

### **🔹 TCP Stream Graph in Wireshark**

1. Right-click on a **TCP packet** → **"Follow TCP Stream"**
    
2. See the **full conversation** between client and server.
    
3. Analyze TCP flow in **Statistics → TCP Stream Graphs**
    

---

### **📌 Quick Wireshark Filters**

|Filter|Description|
|---|---|
|`tcp`|Show all TCP packets|
|`tcp.flags.syn == 1`|Show only SYN packets|
|`tcp.flags.ack == 1`|Show only ACK packets|
|`tcp.flags.reset == 1`|Show only RST packets|

Now you can **analyze TCP handshakes like a pro!** 🚀

---

### **UDP, DNS, and DHCP in Wireshark** 🕵️‍♂️

---

## **🔹 UDP (User Datagram Protocol)**

UDP is a **connectionless** transport protocol used for fast, lightweight communication. Unlike TCP, it **does not** require a handshake or error correction.

### **🛠 Capturing UDP Packets in Wireshark**

1. Open Wireshark and start capturing packets.
    
2. Apply the UDP filter:
    
    ```
    udp
    ```
    
3. Look for **source** and **destination ports** (e.g., **53 for DNS, 67/68 for DHCP**).
    

### **🔹 Key UDP Fields**

- **Source Port**: The port from which the packet was sent.
    
- **Destination Port**: The receiving port.
    
- **Length**: Size of the UDP packet.
    
- **Checksum**: Used for error checking.
    

---

## **🔹 DNS (Domain Name System)**

DNS translates **domain names** (e.g., `google.com`) into **IP addresses**. It mainly uses **UDP port 53** but can use TCP for larger queries.

### **🛠 Capturing DNS Packets in Wireshark**

1. Start a capture and filter for DNS:
    
    ```
    dns
    ```
    
2. Visit any website or run:
    
    ```
    nslookup google.com
    ```
    
3. Look for:
    
    - **Query (Standard query A)**
        
    - **Response (Answer contains the IP address)**
        

### **🔹 Key DNS Fields**

- **Query Name**: The domain being resolved.
    
- **Response**: The resolved IP address.
    
- **Transaction ID**: Unique identifier for the request.
    

---

## **🔹 DHCP (Dynamic Host Configuration Protocol)**

DHCP assigns **IP addresses** dynamically to devices on a network. It uses **UDP ports 67 (server) and 68 (client)**.

### **🛠 Capturing DHCP Packets in Wireshark**

1. Start a capture and filter for DHCP:
    
    ```
    bootp
    ```
    
    (DHCP was originally called BOOTP, so Wireshark uses `bootp` for filtering.)
    
2. Restart your network interface to trigger a DHCP request.
    

### **🔹 Key DHCP Messages**

|Message|Description|
|---|---|
|**Discover**|Client requests an IP address.|
|**Offer**|Server offers an available IP.|
|**Request**|Client requests the offered IP.|
|**ACK**|Server confirms the lease.|

---

### **📌 Quick Wireshark Filters**

|Filter|Description|
|---|---|
|`udp`|Show all UDP packets|
|`dns`|Show only DNS packets|
|`bootp`|Show only DHCP packets|
|`udp.port == 53`|Show only DNS traffic|
|`udp.port == 67||

Now you can **analyze UDP, DNS, and DHCP like a pro!** 🚀

---
