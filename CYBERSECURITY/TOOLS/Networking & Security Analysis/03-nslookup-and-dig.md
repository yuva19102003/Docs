### **`nslookup` Tutorial: A Guide to DNS Queries**

`nslookup` (Name Server Lookup) is a command-line tool used to query the Domain Name System (DNS) to obtain domain name or IP address mapping, as well as other DNS records.

---

## **1. Basic Syntax**

```
nslookup [options] [domain-name/IP]
```

---

## **2. Querying an IP Address for a Domain**

To find the IP address of a domain:

```
nslookup google.com
```

### **Example Output**

```
Server:  8.8.8.8
Address: 8.8.8.8#53

Non-authoritative answer:
Name:    google.com
Address: 142.250.182.14
```

- **Non-authoritative answer** means the response is from a caching DNS server, not the root DNS.

---

## **3. Reverse DNS Lookup (Find Domain from IP)**

To find the domain associated with an IP address:

```
nslookup 8.8.8.8
```

### **Example Output**

```
Server:  google-public-dns-a.google.com
Address: 8.8.8.8
```

---

## **4. Query a Specific DNS Server**

To use a specific DNS server (e.g., Cloudflare's `1.1.1.1`):

```
nslookup google.com 1.1.1.1
```

---

## **5. Getting Detailed DNS Information**

Enter interactive mode by running:

```
nslookup
```

Then type:

```
set type=any
google.com
```

This retrieves all available DNS records (A, MX, CNAME, TXT, etc.).

---

## **6. Query Specific DNS Records**

### **A Record (IPv4 Address)**

```
nslookup -type=A google.com
```

### **AAAA Record (IPv6 Address)**

```
nslookup -type=AAAA google.com
```

### **MX Record (Mail Exchange)**

```
nslookup -type=MX google.com
```

### **TXT Record (Text-based info, e.g., SPF, DKIM, DMARC)**

```
nslookup -type=TXT google.com
```

---

## **7. Non-Interactive Mode**

You can run a direct query without entering interactive mode:

```
nslookup -type=MX google.com 8.8.8.8
```

---

## **8. Debugging Mode**

For more details, use `debug` mode:

```
nslookup
> set debug
> google.com
```

---

## **9. Exit Interactive Mode**

To exit, type:

```
exit
```

---

### **Conclusion**

`nslookup` is a powerful tool for network troubleshooting and DNS verification. It's useful for checking domain resolution, mail servers, and identifying DNS misconfigurations.

---

# **`dig` (Domain Information Groper) Tutorial**

`dig` is a powerful DNS query tool used to retrieve domain name system (DNS) records, troubleshoot DNS issues, and analyze DNS configurations.

---

## **1. Basic Syntax**

```
dig [options] [domain-name] [record-type]
```

---

## **2. Simple DNS Lookup**

To find the IP address (A record) of a domain:

```
dig google.com
```

### **Example Output**

```
; <<>> DiG 9.16.1-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;google.com.            IN      A

;; ANSWER SECTION:
google.com.     300     IN      A       142.250.182.14

;; Query time: 10 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Sun Mar 23 12:00:00 UTC 2025
;; MSG SIZE  rcvd: 55
```

- **ANSWER SECTION**: Shows the IP address (A record).
- **Query time**: How long the query took.
- **SERVER**: The DNS server used (Google's `8.8.8.8` in this case).

---

## **3. Querying Specific DNS Records**

### **A Record (IPv4 Address)**

```
dig google.com A
```

### **AAAA Record (IPv6 Address)**

```
dig google.com AAAA
```

### **MX Record (Mail Exchange)**

```
dig google.com MX
```

### **NS Record (Name Servers)**

```
dig google.com NS
```

### **CNAME Record (Canonical Name)**

```
dig www.google.com CNAME
```

### **TXT Record (SPF, DKIM, DMARC, etc.)**

```
dig google.com TXT
```

---

## **4. Reverse DNS Lookup (PTR Record)**

To find the domain name associated with an IP address:

```
dig -x 8.8.8.8
```

---

## **5. Query a Specific DNS Server**

To use a specific DNS server (e.g., Cloudflare `1.1.1.1`):

```
dig @1.1.1.1 google.com
```

---

## **6. Get All DNS Records (`ANY` Query)**

```
dig google.com ANY
```

---

## **7. Short & Concise Output (`+short`)**

To get only the answer without extra details:

```
dig google.com A +short
```

Example Output:

```
142.250.182.14
```

---

## **8. Show Only the Answer Section (`+noall +answer`)**

```
dig google.com A +noall +answer
```

Example Output:

```
google.com.     300     IN      A       142.250.182.14
```

---

## **9. Debugging and Detailed Queries**

For additional debugging and verbose output:

```
dig google.com +trace
```

This will show the full DNS resolution path, starting from the root DNS servers.

---

## **10. Querying Multiple Domains at Once**

Create a file (`domains.txt`) with domains:

```
google.com
example.com
cloudflare.com
```

Then run:

```
dig -f domains.txt
```

---

### **Conclusion**

`dig` is a powerful tool for DNS queries, troubleshooting, and network diagnostics. It provides more detailed information than `nslookup` and is widely used in DevOps and networking.

---
