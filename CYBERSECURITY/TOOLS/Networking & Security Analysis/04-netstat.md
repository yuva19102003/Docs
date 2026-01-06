## **`netstat` (Network Statistics) Tutorial**

`netstat` is a command-line tool used for displaying network connections, routing tables, interface statistics, and more. It helps in monitoring network activity and troubleshooting network issues.

---

## **1. Basic Syntax**

```
netstat [options]
```

---

## **2. Display All Active Connections**

To see all active TCP and UDP connections:

```
netstat -a
```

This shows:

- **Local and foreign addresses**
- **State of the connection** (e.g., LISTEN, ESTABLISHED, TIME_WAIT)

---

## **3. Show Only Listening Ports**

To display only ports that are actively listening for connections:

```
netstat -l
```

For only TCP listening ports:

```
netstat -lt
```

For only UDP listening ports:

```
netstat -lu
```

---

## **4. Show Process IDs (PID) for Connections**

To find which process is using a particular connection:

```
netstat -tp
```

This is useful for identifying services running on specific ports.

---

## **5. Display Numerical IP Addresses Instead of Hostnames**

```
netstat -n
```

This prevents DNS resolution and speeds up output.

---

## **6. Show Routing Table**

```
netstat -r
```

This displays the kernel routing table, similar to:

```
route -n
```

---

## **7. Show Network Interface Statistics**

To display statistics about packets sent/received:

```
netstat -i
```

For detailed statistics:

```
netstat -ie
```

---

## **8. Show Active Connections Continuously**

To monitor active connections in real-time:

```
netstat -c
```

---

## **9. Find Specific Port Usage**

To check if a specific port (e.g., 443) is in use:

```
netstat -an | grep :443
```

---

## **10. Alternative: `ss` (Faster Replacement)**

Modern Linux systems use `ss`, which is faster than `netstat`:

```
ss -tulnp
```

- `-t` → TCP
- `-u` → UDP
- `-l` → Listening ports
- `-n` → Numeric output
- `-p` → Show process names

---

### **Conclusion**

`netstat` is useful for network troubleshooting, finding open ports, and checking process-network mappings. However, it has been replaced by `ss` on newer Linux distributions.

---
