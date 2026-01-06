


# **🔹 Nmap Cheat Sheet with Examples** 🚀 [Cheetsheet for more ](https://www.stationx.net/nmap-cheat-sheet/)

| **Command**                                                      | **Description**                              | **Example**                                                               |
| ---------------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------- |
| `nmap <target>`                                                  | Basic scan                                   | `nmap 192.168.1.1`                                                        |
| `nmap -p 80,443 <target>`  or `sudo nmap -sT -p 80,443 <subnet>` | Scan specific ports                          | `nmap -p 80,443 192.168.1.1` or `sudo nmap -sT -p 80,443 192.168.31.0/24` |
| `nmap -p- <target>`                                              | Scan all 65535 ports                         | `nmap -p- 192.168.1.1`                                                    |
| `nmap --top-ports 1000 <target>`                                 | Scan top 1000 common ports                   | `nmap --top-ports 1000 192.168.1.1`                                       |
| `nmap <IP1> <IP2>`                                               | Scan multiple hosts                          | `nmap 192.168.1.1 192.168.1.2`                                            |
| `nmap <subnet>` or `nmap -sP <subnet>`                           | Scan a subnet                                | `nmap 192.168.1.0/24` or `nmap -sP 192.168.1.0/24`                        |
| `nmap <domain>`                                                  | Scan a website                               | `nmap example.com`                                                        |
| `nmap -sV <target>`                                              | Detect services & versions                   | `nmap -sV 192.168.1.1`                                                    |
| `nmap -O <target>`                                               | Detect OS                                    | `nmap -O 192.168.1.1`                                                     |
| `nmap -A <target>`                                               | Full aggressive scan (OS, services, scripts) | `nmap -A 192.168.1.1`                                                     |
| `nmap -sS <target>`                                              | Stealth SYN scan                             | `nmap -sS 192.168.1.1`                                                    |
| `nmap -sU <target>`                                              | UDP scan                                     | `nmap -sU 192.168.1.1`                                                    |
| `nmap -f <target>`                                               | Fragmented packets (bypass firewalls)        | `nmap -f 192.168.1.1`                                                     |
| `nmap -S <fake-IP> <target>`                                     | Spoof source IP                              | `nmap -S 192.168.1.100 192.168.1.1`                                       |
| `nmap -oN output.txt <target>`                                   | Save scan results as text                    | `nmap -oN scan.txt 192.168.1.1`                                           |
| `nmap -oX output.xml <target>`                                   | Save scan results as XML                     | `nmap -oX scan.xml 192.168.1.1`                                           |

Now you have a **quick and easy reference** for Nmap! 🚀
