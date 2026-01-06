### **`traceroute` Command: Understanding Network Path to a Destination**

The `traceroute` command helps map the **path that packets take** to reach a destination. It shows each router (hop) along the way, along with the response time.

---

### **Basic Usage**

Run the following command to trace the route to Google's server:

```bash
traceroute google.com
```

OR, if `traceroute` is not installed, you can use `mtr`:

```bash
mtr google.com
```

---

### **Example Output**

```bash
traceroute to google.com (142.250.183.238), 30 hops max, 60 byte packets
 1  192.168.1.1 (192.168.1.1)  1.321 ms  1.220 ms  1.105 ms
 2  10.24.11.254 (10.24.11.254)  10.721 ms  11.084 ms  10.987 ms
 3  103.5.12.1 (103.5.12.1)  19.876 ms  18.655 ms  20.455 ms
 4  209.85.242.101 (209.85.242.101)  35.684 ms  34.987 ms  33.456 ms
 5  142.250.183.238 (142.250.183.238)  38.231 ms  36.998 ms  35.877 ms
```

---

### **Understanding the Output**
```
[Your Computer]
     │
     ▼
[Router (192.168.1.1)]
     │
     ▼
[ISP Gateway (10.24.11.254)]
     │
     ▼
[ISP Backbone (103.5.12.1)]
     │
     ▼
[Google Network (209.85.242.101)]
     │
     ▼
[Google Server (142.250.183.238)]
```

|Hop|IP Address / Hostname|RTT 1|RTT 2|RTT 3|
|---|---|---|---|---|
|1|`192.168.1.1` (Router)|1.3 ms|1.2 ms|1.1 ms|
|2|`10.24.11.254` (ISP Gateway)|10.7 ms|11.0 ms|10.9 ms|
|3|`103.5.12.1` (ISP Backbone)|19.8 ms|18.6 ms|20.4 ms|
|4|`209.85.242.101` (Google Network)|35.6 ms|34.9 ms|33.4 ms|
|5|`142.250.183.238` (Google.com)|38.2 ms|36.9 ms|35.8 ms|

- Each row is a **hop** (router) along the path.
- The **first hop** is usually your **local router** (`192.168.1.1`).
- The **second hop** is your **ISP’s gateway**.
- The **final hop** is the **destination** (Google in this case).
- The **RTT (Round Trip Time)** values (in ms) show the latency for each hop.
- If you see `* * *`, it means the hop **did not respond** (firewall, packet filtering, etc.).

---

### **Useful Options**

1. **Limit the number of hops (default is 30)**
    
    ```bash
    traceroute -m 20 google.com
    ```
    
2. **Use ICMP instead of UDP (better for firewalls)**
    
    ```bash
    traceroute -I google.com
    ```
    
3. **Use TCP (useful when ICMP/UDP is blocked)**
    
    ```bash
    traceroute -T google.com
    ```
    
4. **Set timeout per hop**
    
    ```bash
    traceroute -w 2 google.com  # 2 seconds timeout
    ```
    

---
# **`mtr` (My Traceroute) – A Real-Time Network Diagnostic Tool**

`mtr` is an advanced version of `traceroute` that continuously updates results in real-time, showing **packet loss, latency, and jitter** for each hop.

---

## **1️⃣ Installing `mtr`**

### 📌 **Linux (Debian/Ubuntu)**

```bash
sudo apt update && sudo apt install mtr -y
```

### 📌 **Linux (RHEL/CentOS)**

```bash
sudo yum install mtr -y
```

### 📌 **Linux (Arch)**

```bash
sudo pacman -S mtr
```

### 📌 **macOS (Homebrew)**

```bash
brew install mtr
```

### 📌 **Windows**

Use **WSL (Ubuntu on Windows)** or install **WinMTR** (GUI version).

---

## **2️⃣ Using `mtr`**

### 🔹 **Basic Usage**

```bash
mtr google.com
```

This continuously updates the **latency, packet loss, and jitter** for each hop.

---

## **3️⃣ Understanding the Output**

```
                             My traceroute  [v0.95]
yuvaraj (192.168.1.100) -> google.com (142.250.183.238)
-------------------------------------------------------------------
Host                    Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. 192.168.1.1         0.0%    10   1.2ms  1.1   1.0   1.5  0.1
 2. 10.24.11.254        0.0%    10  10.7ms 10.9  10.5  11.3  0.2
 3. 103.5.12.1          0.0%    10  19.8ms 18.6  18.0  20.5  0.3
 4. 209.85.242.101      0.0%    10  35.6ms 34.9  33.9  36.7  0.4
 5. 142.250.183.238     0.0%    10  38.2ms 36.9  35.8  39.5  0.5
```

|Column|Meaning|
|---|---|
|**Loss%**|Packet loss percentage|
|**Snt**|Number of packets sent|
|**Last**|Last recorded round-trip time|
|**Avg**|Average round-trip time|
|**Best**|Lowest round-trip time|
|**Wrst**|Highest round-trip time|
|**StDev**|Standard deviation (jitter)|

---

## **4️⃣ Useful Options**

### ✅ **Run `mtr` Once and Exit**

```bash
mtr -r google.com
```

### ✅ **Limit the Number of Packets Sent**

```bash
mtr -c 5 google.com
```

### ✅ **Show Detailed Report**

```bash
mtr -rw google.com
```

### ✅ **Use TCP Instead of ICMP (for Firewalls)**

```bash
mtr --tcp google.com
```

---

## **5️⃣ `mtr` vs. `traceroute`**

|Feature|`traceroute`|`mtr`|
|---|---|---|
|**Real-time updates**|❌ No|✅ Yes|
|**Continuous monitoring**|❌ No|✅ Yes|
|**Packet loss detection**|❌ No|✅ Yes|
|**Jitter measurement**|❌ No|✅ Yes|
|**TCP mode**|✅ Yes|✅ Yes|

---
