
### **1. User Connects to the Internet**

- The laptop connects to a **Wi-Fi router** or **Ethernet**.
- If Wi-Fi is used, it authenticates via **WPA2/WPA3**.
- The **DHCP server** in the router assigns an **IP address** (e.g., `192.168.1.10`).

---

### **2. DNS Resolution**

- The user enters `www.example.com` in the browser.
- The **laptop sends a DNS query** to the configured **DNS server** (ISP DNS, Google DNS, etc.).
- The DNS server **returns the IP address** (e.g., `93.184.216.34`).

---

### **3. Request Encapsulation (OSI Model)**

The browser **prepares the HTTP/HTTPS request** and passes it through the network stack:

|OSI Layer|Action|
|---|---|
|**Application Layer**|Browser creates an **HTTP request** (`GET /index.html`).|
|**Transport Layer**|Wraps the request in a **TCP segment** with **port 80 (HTTP) or 443 (HTTPS)**.|
|**Internet Layer**|Encapsulates in an **IP packet** (Source: `192.168.1.10`, Destination: `93.184.216.34`).|
|**Data Link Layer**|Adds **MAC address** (Source: Laptop MAC, Destination: Router MAC).|
|**Physical Layer**|Converts data into electrical signals for transmission.|

---

### **4. Router Performs NAT**

- The **router replaces** the laptop’s private IP (`192.168.1.10`) with its **public IP** (`203.0.113.45`).
- It forwards the packet to the **ISP** for internet routing.

---

### **5. Packet Travels Through the Internet**

- The request is routed through **multiple ISPs and routers**.
- Each **router reads the destination IP** (`93.184.216.34`) and **forwards** the packet accordingly.

---

### **6. Server Receives the Request**

- The packet reaches the **web server** (`93.184.216.34`).
- The **server’s firewall** checks if traffic on **port 80/443** is allowed.
- The **web server (e.g., Apache, Nginx)** processes the request and **prepares a response**.

---

### **7. Response Travels Back to the User**

- The **server sends an HTTP response** (`200 OK + webpage content`).
- The **return packet** follows the **same path back**.
- The router **reverses NAT** (public IP `203.0.113.45` → private IP `192.168.1.10`).

---

### **8. Decapsulation & Page Rendering**

- The laptop **removes all headers** (Ethernet, IP, TCP).
- The **browser processes HTML, CSS, JavaScript** and **displays the webpage**.

---

### **Data Flow Diagram**

```  [Laptop] 
      │ 1. Connects to Wi-Fi/Ethernet
      ▼
  [Router] 
      │ 2. Requests IP from DHCP
      ▼
  [DHCP Server] 
      │ 3. Assigns IP (e.g., 192.168.1.10)
      ▼
  [Laptop] 
      │ 4. DNS Query (www.example.com)
      ▼
  [Router] 
      │ 5. Forwards DNS query
      ▼
  [DNS Server] 
      │ 6. Resolves IP (93.184.216.34)
      ▼
  [Router] 
      │ 7. HTTP Request to Web Server (NAT Applied)
      ▼
  [Internet (ISPs, Routers)] 
      │ 8. Routes request to destination
      ▼
  [Web Server (example.com)] 
      │ 9. Processes request & sends HTTP response
      ▼
  [Internet (ISPs, Routers)] 
      │ 10. Routes response back
      ▼
  [Router] 
      │ 11. NAT Reverse (Public IP → Private IP)
      ▼
  [Laptop] 
      │ 12. Decapsulation & Render Page
      ▼
  [User Sees the Website]

```

---
