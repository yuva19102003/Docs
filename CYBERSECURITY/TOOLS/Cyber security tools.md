
### **📌 Phase 1: Cybersecurity Core Tools**

**Goal:** Understand fundamental security and networking tools.

| **Topic**                                 | **Key Concepts**                    | **Tools**                       | **Link**                                                             |
| ----------------------------------------- | ----------------------------------- | ------------------------------- | -------------------------------------------------------------------- |
| **Networking & Security Analysis**        | Network traffic analysis            | Wireshark                       | [06-wireshark](06-wireshark.md)                                                     |
|                                           | Port scanning & network discovery   | Nmap                            | [07-Nmap](07-Nmap.md)                                                          |
|                                           | CLI-based packet analysis           | Tcpdump                         | [05-tcpdump](05-tcpdump.md)                                                       |
|                                           | Active connections monitoring       | Netstat / ss                    | [04-netstat](04-netstat.md)                                                       |
|                                           | Network troubleshooting             | Ping, Traceroute (tracert)      | [01-ping](01-ping.md) , [02-Traceroute-and-mtr](02-Traceroute-and-mtr.md)                              |
|                                           | DNS queries                         | Nslookup, Dig                   | [03-nslookup-and-dig](03-nslookup-and-dig.md)                                              |
| **Operating System Security & Hardening** | Log analysis                        | Windows Event Viewer            | [3-Active-Directory](3-Active-Directory.md)                                               |
|                                           | Windows security automation         | PowerShell & CMD                | [1.2-windows-fundamentals-overiew](1.2-windows-fundamentals-overiew.md)                                 |
|                                           | Security auditing                   | Linux Auditd                    | [1.1-linux-fundamentals-overview](1.1-linux-fundamentals-overview.md)                                  |
|                                           | Protect against brute-force attacks | Fail2Ban                        | None                                                                 |
|                                           | Linux firewall configuration        | iptables / ufw                  | [4.1-linux-firewall](4.1-linux-firewall.md)                                               |
| **Vulnerability Scanning & Pentesting**   | Web server vulnerability scanning   | Nikto                           | [5-nikto-vuln-scan](5-nikto-vuln-scan.md)                                                |
|                                           | Open-source vulnerability scanner   | OpenVAS                         | [4-OpenVAS](4-OpenVAS.md)                                                        |
|                                           | Exploitation & penetration testing  | Metasploit Framework, OWASP ZAP | [6-OWASP ZAP](6-OWASP%20ZAP.md) ,  [7-Metasploit Framework](7-Metasploit%20Framework.md)                        |
|                                           | Web application security testing    | Burp Suite                      | [8-Burp Suite](8-Burp%20Suite.md)                                                     |
|                                           | Password cracking                   | John the Ripper / Hashcat       | None                                                                 |
|                                           | file and image scanning             | trivy / synk                    | [1-Trivy-scan](1-Trivy-scan.md),   [2-snyk-scan](2-snyk-scan.md),     [3-diff-btw-trivy-&-snyk](3-diff-btw-trivy-%26-snyk.md) |

📌 **Practice:** Use **TryHackMe (Beginner Labs)** for hands-on experience.

---

### **📌 Phase 2: SOC Analyst & Threat Hunting Tools**

**Goal:** Learn SIEM, endpoint security, and threat detection tools.

| **Topic**                                          | **Key Concepts**                  | **Tools**                      | **Link** |
| -------------------------------------------------- | --------------------------------- | ------------------------------ | -------- |
| **Security Information & Event Management (SIEM)** | Log analysis & SIEM               | Splunk                         |          |
|                                                    | Open-source SIEM                  | ELK Stack                      |          |
|                                                    | Log management & threat detection | Graylog                        |          |
|                                                    | Enterprise-grade SIEM             | QRadar (IBM)                   |          |
| **Threat Hunting & Incident Response**             | Threat intelligence framework     | MITRE ATT&CK                   |          |
|                                                    | Malware file and URL scanning     | VirusTotal                     |          |
|                                                    | Malware rule-based detection      | YARA                           |          |
|                                                    | OSINT tools                       | Shodan, TheHarvester, Maltego  |          |
| **Digital Forensics & Malware Analysis**           | Disk forensics                    | Autopsy / The Sleuth Kit       |          |
|                                                    | Memory forensics                  | Volatility                     |          |
|                                                    | Process monitoring                | ProcMon (Windows Sysinternals) |          |
|                                                    | Forensic disk imaging             | FTK Imager                     |          |

📌 **Practice:** Set up a **SOC lab with ELK or Splunk** and analyze security logs.

---

### **📌 Phase 3: Cloud Security & Compliance Tools**

**Goal:** Secure AWS, Azure, GCP environments and monitor cloud security.

| **Topic**                                    | **Key Concepts**                     | **Tools**                      | **Link** |
| -------------------------------------------- | ------------------------------------ | ------------------------------ | -------- |
| **Cloud Security Monitoring & Compliance**   | Logs all AWS API activity            | AWS CloudTrail                 |          |
|                                              | Threat detection in AWS              | AWS GuardDuty                  |          |
|                                              | SIEM for Azure environments          | Azure Sentinel                 |          |
|                                              | Threat monitoring in GCP             | Google Security Command Center |          |
| **Identity & Access Management (IAM)**       | Review IAM policies                  | AWS IAM Analyzer               |          |
|                                              | Cloud identity management            | Azure Active Directory (AAD)   |          |
|                                              | Identity access reviews              | GCP IAM Policy Analyzer        |          |
|                                              | Compliance & security best practices | Prisma Cloud, AWS Security Hub |          |
| **Cloud Security Posture Management (CSPM)** | Policy enforcement                   | Cloud Custodian                |          |
|                                              | Multi-cloud security auditing        | ScoutSuite                     |          |
|                                              | AWS security best practices checker  | Prowler                        |          |

📌 **Practice:** Configure IAM policies and security groups in **AWS Free Tier**.

---

### **📌 Phase 4: Hands-on Projects & Real-World Simulations**

**Goal:** Apply knowledge using labs and open-source security tools.

| **Topic**                           | **Key Concepts**                      | **Tools**                       | **Link**                |
| ----------------------------------- | ------------------------------------- | ------------------------------- | ----------------------- |
| **Hands-on Security Labs & CTFs**   | Beginner-friendly cybersecurity labs  | TryHackMe                       |                         |
|                                     | Penetration testing challenges        | HackTheBox                      |                         |
|                                     | SOC analyst practice                  | Blue Team Labs Online           |                         |
|                                     | Cloud security attack simulations     | RangeForce                      |                         |
| **Security Automation & Scripting** | Automate security tasks               | Python for Security             |                         |
|                                     | Windows security scripting            | PowerShell for Windows Security | in windows fundamentals |
|                                     | Automate firewall and logs monitoring | Bash for Linux Security         | in linux fundamentals   |

📌 **Practice:** Write Python scripts to automate **log analysis & threat detection**.

---
