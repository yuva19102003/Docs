

The difference between `URL`s and `FQDN`s is that:

- an `FQDN` (`www.hackthebox.eu`) only specifies the address of the "building" and
- an `URL` (`https://www.hackthebox.eu/example?floor=2&office=dev&employee=17`) also specifies the "`floor`," "`office`," "`mailbox`" and the corresponding "`employee`" for whom the package is intended.

----
There are three main types of VPNs, all aiming to make users feel as if they are connected to a different network:

1. **Site-to-Site VPN** – Connects entire networks (e.g., company branches) over the internet using network devices like routers or firewalls.
2. **Remote Access VPN** – Allows individual users to connect to a network remotely, often using software like OpenVPN. It can be **Split-Tunnel** (only specific traffic goes through the VPN) or **Full-Tunnel** (all traffic is routed through the VPN).
3. **SSL VPN** – Runs through a web browser, providing secure remote access to applications or full desktop sessions without requiring separate VPN software.

---

### Summary of Networking Topologies

A **network topology** defines how devices are physically or logically arranged in a network. It determines network components, transmission media, and data flow.

#### **Types of Network Topologies:**

1. **Point-to-Point** – Direct connection between two devices for communication.
2. **Bus** – All devices share a common transmission medium, with no central control.
3. **Star** – Devices connect to a central hub/switch, which manages data flow.
4. **Ring** – Devices are connected in a closed loop, with data flowing in one direction.
5. **Mesh** – Multiple redundant connections; can be **fully** or **partially** meshed.
6. **Tree** – A hierarchical extension of the star topology, used in large networks.
7. **Hybrid** – A combination of two or more topology types.
8. **Daisy Chain** – Devices are linked in a series, commonly used in automation.

---
#### **Proxy:**

A proxy is when a device or service sits in the middle of a connection and acts as a mediator. The `mediator` is the critical piece of information because it means the device in the middle must be able to inspect the contents of the traffic. Without the ability to be a `mediator`, the device is technically a `gateway`, not a proxy.

 > the average person has a mistaken idea of what a proxy is as they are most likely using a VPN to obfuscate their location, which technically is not a proxy. Most people think whenever an IP Address changes, it is a proxy.
 

If you have trouble remembering this, proxies will almost always operate at Layer 7 of the OSI Model. There are many types of proxy services, but the key ones are:

- `Dedicated Proxy` / `Forward Proxy`
- `Reverse Proxy`
- `Transparent Proxy`

### **Dedicated Proxy / Forward Proxy** 

A **Forward Proxy** acts as an intermediary between a client and the internet. It processes client requests and forwards them to the destination, often used in corporate networks to filter traffic and enhance security.[Helpful for the client]

![Pasted image 20250315175914.png](Pasted%20image%2020250315175914.png.md)
- **Security Benefits:** Blocks direct access to the internet, reducing malware risks. Malware must be proxy-aware or use non-traditional communication methods (C2) to bypass protections.
- **Browser Behavior:** Chrome, Edge, and Internet Explorer follow system proxy settings, while Firefox uses libcurl, making it harder for malware to detect proxy settings.
- **Detection Methods:** Organizations can monitor **DNS traffic** using tools like **Sysmon** to detect potential threats.
- **Example Tools:** **Burp Suite** is a common forward proxy for inspecting HTTP requests and can also function as a reverse or transparent proxy.


### ** Reverse Proxy**

A **Reverse Proxy** filters **incoming** traffic, unlike a Forward Proxy, which filters outgoing requests. It is commonly used to protect internal networks by forwarding external requests to backend servers.
[Helpful for the server]
![Pasted image 20250315180652.png](Pasted%20image%2020250315180652.png.md)
- **Security & Performance:** Organizations use **Cloudflare** to mitigate **DDoS attacks** and filter traffic before it reaches web servers.
- **Penetration Testing:** Attackers can set up a reverse proxy on an infected endpoint to route traffic back to them, bypassing **firewalls and intrusion detection systems (IDS)** using techniques like **SSH tunneling**.
- **Web Application Firewall (WAF):** Tools like **ModSecurity** analyze incoming web requests for threats. Cloudflare also offers WAF services but requires decrypting HTTPS traffic, which some organizations may avoid.


### ** (Non-) Transparent Proxy**

Proxies can function as **transparent** or **non-transparent**:

- **Transparent Proxy:**
    
    - The client is **unaware** of its presence.
    - It intercepts and forwards traffic **without client-side configuration**.
    - Acts as an intermediary while appearing as the original sender to external servers.
- **Non-Transparent Proxy:**
    
    - The client **must be configured** to use it.
    - Without proper settings, **Internet access is blocked**.
    - Used when organizations want **controlled** and **explicit traffic routing**.

---
