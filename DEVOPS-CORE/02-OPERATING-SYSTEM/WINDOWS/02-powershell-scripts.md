# 🟢 1️⃣ Basic Script Structure

Create file:

```
script.ps1
```

Run:

```powershell
.\script.ps1
```

If execution blocked:

```powersshell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

# 🟢 2️⃣ Variables

```powershell
$name = "Yuva"
$age = 25
$isDevOps = $true
```

---

# 🟢 3️⃣ Parameters (Command Line Arguments)

```powershell
param(
    [string]$Name,
    [int]$Age
)

Write-Output "Name: $Name"
Write-Output "Age: $Age"
```

Run:

```powershell
.\script.ps1 -Name Yuva -Age 25
```

---

# 🟢 4️⃣ If / Else

```powershell
if ($Age -gt 18) {
    Write-Output "Adult"
}
elseif ($Age -eq 18) {
    Write-Output "Exactly 18"
}
else {
    Write-Output "Minor"
}
```

Operators:

```
-eq  -ne  -gt  -lt  -ge  -le
-and -or  -not
```

---

# 🟢 5️⃣ Switch

```powershell
switch ($Name) {
    "Yuva" { "DevOps Engineer" }
    "Admin" { "System Admin" }
    default { "Unknown" }
}
```

---

# 🟢 6️⃣ Loops

### For

```powershell
for ($i=1; $i -le 5; $i++) {
    Write-Output $i
}
```

### Foreach

```powershell
$items = @("Azure","AWS","GCP")

foreach ($item in $items) {
    Write-Output $item
}
```

### While

```powershell
$i = 1
while ($i -le 5) {
    Write-Output $i
    $i++
}
```

---

# 🟢 7️⃣ Functions

```powershell
function Add-Numbers {
    param(
        [int]$a,
        [int]$b
    )

    return $a + $b
}

$result = Add-Numbers -a 5 -b 3
Write-Output $result
```

---

# 🟢 8️⃣ Arrays

```powershell
$servers = @("server1","server2","server3")

$servers[0]
$servers.Count
```

Add:

```powershell
$servers += "server4"
```

---

# 🟢 9️⃣ Hashtable (Dictionary)

```powershell
$user = @{
    Name = "Yuva"
    Role = "DevOps"
    Location = "India"
}

$user["Name"]
```

---

# 🟢 🔟 Objects

```powershell
$obj = [PSCustomObject]@{
    Name = "Yuva"
    Role = "DevOps"
}

$obj.Name
```

---

# 🟢 11️⃣ Reading File Line by Line

```powershell
Get-Content file.txt | ForEach-Object {
    Write-Output $_
}
```

---

# 🟢 12️⃣ Try / Catch (Error Handling)

```powershell
try {
    Get-Content "notexist.txt"
}
catch {
    Write-Output "File not found"
}
finally {
    Write-Output "Done"
}
```

Force error catching:

```powershell
Get-Content test.txt -ErrorAction Stop
```

---

# 🟢 13️⃣ Logging to File

```powershell
$logFile = "log.txt"
Add-Content $logFile "Script started at $(Get-Date)"
```

---

# 🟢 14️⃣ Checking If File Exists

```powershell
if (Test-Path "file.txt") {
    Write-Output "File exists"
}
```

---

# 🟢 15️⃣ Background Job

```powershell
Start-Job { Get-Process }
Get-Job
Receive-Job -Id 1
```

---

# 🟢 16️⃣ REST API Call

```powershell
$response = Invoke-RestMethod "https://api.github.com"
$response.current_user_url
```

POST example:

```powershell
$body = @{
    name = "demo"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.example.com" -Method Post -Body $body -ContentType "application/json"
```

---

# 🟢 17️⃣ Working with Services

```powershell
$service = Get-Service spooler

if ($service.Status -ne "Running") {
    Start-Service spooler
}
```

---

# 🟢 18️⃣ Scheduled Task (Basic)

```powershell
Register-ScheduledTask -Action (New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\script.ps1") -Trigger (New-ScheduledTaskTrigger -Daily -At 9am) -TaskName "MyTask"
```

---

# 🟢 19️⃣ Script Template (Production Style)

Copy this template:

```powershell
param(
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content "app.log" "$timestamp - $Message"
}

try {
    Write-Log "Script started for $Environment"

    if (-not (Test-Path "config.json")) {
        throw "Config file missing"
    }

    Write-Log "All checks passed"
}
catch {
    Write-Log "Error: $_"
}
finally {
    Write-Log "Script finished"
}
```

---

# 🟢 20️⃣ Execution Policy Types

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned
```

---

# 🟢 21️⃣ Most Used DevOps Commands Inside Scripts

```powershell
Get-ChildItem
Get-Process
Get-Service
Test-Connection
Invoke-RestMethod
Select-String
Test-Path
Start-Service
Stop-Process
```

---

# 🔥 DevOps Practical Mini Example

Health check script:

```powershell
$server = "google.com"

if (Test-Connection $server -Count 2 -Quiet) {
    Write-Output "$server is reachable"
}
else {
    Write-Output "$server is down"
}
```

---
