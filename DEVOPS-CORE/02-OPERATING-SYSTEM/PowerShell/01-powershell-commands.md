# 🔥 Complete Linux → PowerShell Command Cheat Sheet

---

# 📂 FILE & DIRECTORY COMMANDS

| Linux            | PowerShell                         |
| ---------------- | ---------------------------------- |
| `ls`             | `Get-ChildItem`                    |
| `ls -a`          | `Get-ChildItem -Force`             |
| `pwd`            | `Get-Location`                     |
| `cd dir`         | `Set-Location dir`                 |
| `mkdir dir`      | `New-Item -ItemType Directory dir` |
| `touch file.txt` | `New-Item file.txt`                |
| `rm file.txt`    | `Remove-Item file.txt`             |
| `rm -r dir`      | `Remove-Item dir -Recurse`         |
| `cp file1 file2` | `Copy-Item file1 file2`            |
| `mv file1 file2` | `Move-Item file1 file2`            |
| `clear`          | `Clear-Host`                       |

---

# 📄 FILE CONTENT COMMANDS

| Linux                      | PowerShell                      |
| -------------------------- | ------------------------------- |
| `cat file.txt`             | `Get-Content file.txt`          |
| `less file.txt`            | `Get-Content file.txt -Wait`    |
| `head -n 10 file.txt`      | `Get-Content file.txt -Head 10` |
| `tail -n 10 file.txt`      | `Get-Content file.txt -Tail 10` |
| `tail -f file.txt`         | `Get-Content file.txt -Wait`    |
| `echo "hello"`             | `Write-Output "hello"`          |
| `echo "hello" > file.txt`  | `Set-Content file.txt "hello"`  |
| `echo "hello" >> file.txt` | `Add-Content file.txt "hello"`  |

---

# 🔎 SEARCHING (grep equivalent)

| Linux                   | PowerShell                                            |
| ----------------------- | ----------------------------------------------------- |
| `grep text file.txt`    | `Select-String "text" file.txt`                       |
| `grep -i text file.txt` | `Select-String "text" file.txt -CaseSensitive:$false` |
| `grep -r text .`        | `Select-String "text" -Path * -Recurse`               |

---

# ⚙️ PROCESS MANAGEMENT

| Linux         | PowerShell                    |                       |
| ------------- | ----------------------------- | --------------------- |
| `ps`          | `Get-Process`                 |                       |
| `ps aux`      | `Get-Process`                 |                       |
| `top`         | `Get-Process                  | Sort CPU -Descending` |
| `kill PID`    | `Stop-Process -Id PID`        |                       |
| `kill -9 PID` | `Stop-Process -Id PID -Force` |                       |

---

# 🔧 SERVICE MANAGEMENT

| Linux                     | PowerShell              |
| ------------------------- | ----------------------- |
| `systemctl status nginx`  | `Get-Service nginx`     |
| `systemctl start nginx`   | `Start-Service nginx`   |
| `systemctl stop nginx`    | `Stop-Service nginx`    |
| `systemctl restart nginx` | `Restart-Service nginx` |

---

# 🌐 NETWORK COMMANDS

| Linux                   | PowerShell                           |
| ----------------------- | ------------------------------------ |
| `ifconfig`              | `ipconfig`                           |
| `ip a`                  | `Get-NetIPAddress`                   |
| `ping google.com`       | `Test-Connection google.com`         |
| `netstat -an`           | `Get-NetTCPConnection`               |
| `curl https://api.com`  | `Invoke-RestMethod https://api.com`  |
| `wget https://file.com` | `Invoke-WebRequest https://file.com` |

---

# 💾 DISK COMMANDS

| Linux   | PowerShell                                                       |
| ------- | ---------------------------------------------------------------- |
| `df -h` | `Get-PSDrive`                                                    |
| `du -h` | `Get-ChildItem -Recurse \| Measure-Object -Property Length -Sum` |
| `mount` | `Get-Volume`                                                     |

---

# 👤 USER MANAGEMENT

| Linux          | PowerShell           |
| -------------- | -------------------- |
| `whoami`       | `whoami`             |
| `id`           | `whoami /groups`     |
| `adduser user` | `New-LocalUser user` |
| `passwd user`  | `Set-LocalUser user` |

---

# 🔐 PERMISSIONS

| Linux             | PowerShell                   |
| ----------------- | ---------------------------- |
| `chmod 755 file`  | `icacls file`                |
| `chown user file` | `icacls file /setowner user` |

---

# 📦 PACKAGE MANAGEMENT

| Linux               | PowerShell             |
| ------------------- | ---------------------- |
| `apt install nginx` | `winget install nginx` |
| `yum install nginx` | `winget install nginx` |
| `apt update`        | `winget upgrade`       |

---

# 🐳 DOCKER (Same in Both)

| Linux           | PowerShell      |
| --------------- | --------------- |
| `docker ps`     | `docker ps`     |
| `docker images` | `docker images` |
| `docker build`  | `docker build`  |
| `docker run`    | `docker run`    |

---

# 🔥 PIPELINE COMPARISON

Linux:

```bash
ps aux | grep nginx
```

PowerShell:

```powershell
Get-Process | Where-Object {$_.ProcessName -eq "nginx"}
```

---

# 🧠 JSON HANDLING

Linux:

```bash
curl api | jq .
```

PowerShell:

```powershell
Invoke-RestMethod api
```

---

# 🧾 ENVIRONMENT VARIABLES

| Linux              | PowerShell           |
| ------------------ | -------------------- |
| `printenv`         | `Get-ChildItem Env:` |
| `export VAR=value` | `$env:VAR="value"`   |
| `echo $VAR`        | `$env:VAR`           |

---

# 🛠️ ARCHIVE COMMANDS

| Linux                   | PowerShell                           |
| ----------------------- | ------------------------------------ |
| `tar -xvf file.tar`     | `tar -xvf file.tar`                  |
| `zip file.zip file.txt` | `Compress-Archive file.txt file.zip` |
| `unzip file.zip`        | `Expand-Archive file.zip`            |

---

# 🎯 Most Important PowerShell Commands (DevOps Must-Know)

```
Get-ChildItem
Get-Content
Set-Content
Add-Content
Select-String
Get-Process
Stop-Process
Get-Service
Start-Service
Restart-Service
Invoke-RestMethod
Invoke-WebRequest
Get-NetIPAddress
Test-Connection
Get-PSDrive
```

---

# 📂 FILE & DIRECTORY

```powershell
Get-ChildItem
Get-ChildItem -Force
Get-Location
Set-Location C:\Path\To\Folder
New-Item -ItemType Directory demo
New-Item file.txt
Remove-Item file.txt
Remove-Item folder -Recurse -Force
Copy-Item file1.txt file2.txt
Move-Item file1.txt file2.txt
Clear-Host
```

---

# 📄 FILE CONTENT

```powershell
Get-Content file.txt
Get-Content file.txt -Head 10
Get-Content file.txt -Tail 10
Get-Content file.txt -Wait
Set-Content file.txt "Hello"
Add-Content file.txt "Hello"
Clear-Content file.txt
```

---

# 🔎 SEARCH (grep equivalent)

```powershell
Select-String "text" file.txt
Select-String "text" -Path * -Recurse
Get-ChildItem -Recurse | Select-String "text"
```

---

# ⚙️ PROCESS

```powershell
Get-Process
Get-Process | Sort CPU -Descending
Stop-Process -Id 1234
Stop-Process -Name notepad -Force
```

---

# 🔧 SERVICES

```powershell
Get-Service
Get-Service spooler
Start-Service spooler
Stop-Service spooler
Restart-Service spooler
```

---

# 🌐 NETWORK

```powershell
ipconfig
Get-NetIPAddress
Test-Connection google.com
Get-NetTCPConnection
Invoke-RestMethod https://api.github.com
Invoke-WebRequest https://example.com
```

---

# 💾 DISK

```powershell
Get-PSDrive
Get-Volume
Get-Disk
```

---

# 👤 USERS

```powershell
whoami
whoami /groups
Get-LocalUser
New-LocalUser user1
Remove-LocalUser user1
```

---

# 🔐 PERMISSIONS

```powershell
icacls file.txt
icacls file.txt /grant username:F
icacls file.txt /remove username
```

---

# 🌍 ENVIRONMENT VARIABLES

```powershell
Get-ChildItem Env:
$env:VAR="value"
$env:VAR
```

---

# 📦 PACKAGE MANAGEMENT (Windows)

```powershell
winget search nginx
winget install nginx
winget upgrade
```

---

# 🗜️ ARCHIVE

```powershell
Compress-Archive file.txt file.zip
Expand-Archive file.zip
tar -xvf file.tar
```

---

# 🔥 PIPELINE EXAMPLES

```powershell
Get-Process | Where-Object {$_.CPU -gt 100}
Get-Service | Where-Object {$_.Status -eq "Running"}
Get-ChildItem | Sort-Object Length -Descending
```

---

# 🧠 JSON

```powershell
Invoke-RestMethod https://api.github.com
(Invoke-RestMethod https://api.github.com).current_user_url
```

---

# 🐳 DOCKER (same as Linux)

```powershell
docker ps
docker images
docker build -t app .
docker run -d -p 80:80 app
docker stop container_id
docker rm container_id
```

---
