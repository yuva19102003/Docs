This is an introduction to Windows for penetration testers, covering key concepts like:

1. **Windows Overview** – Windows is one of the most common operating systems in IT environments, used in desktops and servers. Understanding Windows is crucial for both attacks and defense.
    
2. **Windows Versions** – Microsoft started Windows in 1985, evolving from MS-DOS to modern versions like Windows 11 and Windows Server. Different versions have unique features and vulnerabilities.
    
3. **Finding OS Info** – Use PowerShell's `Get-WmiObject` to check system details, processes, and services. Example:
    
    ```powershell
    Get-WmiObject -Class win32_OperatingSystem | select Version,BuildNumber
    ```
    
4. **Accessing Windows** –
    
    - **Local Access** – Directly using a device (keyboard, screen, etc.).
        
    - **Remote Access** – Connecting over a network using tools like:
        
        - **RDP (Remote Desktop Protocol)** – Windows' built-in remote access tool (port 3389).
            
        - **SSH, VPN, FTP** – Other remote access methods.
            
5. **Using RDP for Pentesting** –
    
    - On Windows: Use `mstsc.exe` (Remote Desktop Connection).
        
    - On Linux: Use `xfreerdp` to connect to Windows targets.
        
    - Saved `.rdp` files may store credentials, useful in pentesting.
        

**Key Takeaway**: Understanding Windows, its versions, access methods, and remote tools is essential for penetration testing.

---

## **Windows Root Directory and File System Navigation**

The **Windows root directory** (e.g., `C:\`) contains essential system folders and files. Key directories include:

- **Perflogs** – Stores Windows performance logs (empty by default).
    
- **Program Files / Program Files (x86)** – Stores installed applications (64-bit in `Program Files`, 32-bit in `Program Files (x86)`).
    
- **ProgramData** – Hidden folder storing essential program data accessible to all users.
    
- **Users** – Contains user profiles, including the **Default** profile template and the **Public** folder for shared files.
    
- **AppData** – Stores user-specific application data in three subfolders:
    
    - **Roaming** (syncs across devices),
        
    - **Local** (device-specific),
        
    - **LocalLow** (lower security level).
        
- **Windows** – Contains core operating system files.
    
- **System, System32, SysWOW64** – Stores Windows API DLLs and essential system components.
    
- **WinSxS** – Windows Component Store with copies of system files, updates, and service packs.
    

### **Command-Line Navigation**

- `dir` – Lists directory contents (e.g., `dir C:\ /a` shows all files, including hidden ones).
    
- `tree` – Displays a graphical representation of the directory structure.
    
    - Example: `tree "C:\Program Files (x86)\VMware"` shows subfolders in VMware's installation.
        
    - `tree C:\ /f | more` lists all files and folders in `C:\` one page at a time.
        

These commands help explore and manage the Windows file system efficiently.
## **Windows File Systems & NTFS Permissions**

#### **Windows File Systems Overview**

Windows supports five file systems: **FAT12, FAT16, FAT32, NTFS, and exFAT**. However, modern Windows primarily uses **NTFS**, while **FAT32** and **exFAT** are common for external storage.

#### **FAT32 (File Allocation Table)**

- **Pros**: Compatible with most devices (PCs, gaming consoles, cameras, etc.), works across Windows, macOS, and Linux.
    
- **Cons**: Cannot store files larger than **4GB**, lacks built-in security and compression features.
    

#### **NTFS (New Technology File System)**

- **Pros**: More reliable, supports large partitions, includes **journaling**, **file compression**, and **permissions**.
    
- **Cons**: Not natively supported on some **mobile devices** and **older media players**.
    

---

#### **NTFS File Permissions**

NTFS allows setting granular access control on files and folders.

|**Permission Type**|**Description**|
|---|---|
|Full Control|Read, write, modify, delete files/folders.|
|Modify|Read, write, and delete files.|
|List Folder Contents|View and list folders/subfolders.|
|Read and Execute|Open and execute files.|
|Write|Add new files and write to existing ones.|
|Read|View file contents.|

- **Permissions are inherited** from parent folders but can be explicitly set.
    
- **Traverse Folder** allows moving through directories without listing contents.
    

---

#### **Managing NTFS Permissions with `icacls`**

The **`icacls`** command helps manage file/folder permissions via CLI.

#### **View NTFS Permissions**

```cmd
icacls C:\Windows
```

🔹 Lists access levels for different users.

#### **Grant Full Control to a User**

```cmd
icacls C:\Users /grant joe:f
```

🔹 Gives **"joe"** full control over the **C:\Users** folder.

#### **Remove User Permissions**

```cmd
icacls C:\Users /remove joe
```

🔹 Revokes **"joe"**'s access.

#### **Permission Codes**

- **F** – Full Access
    
- **D** – Delete Access
    
- **M** – Modify Access
    
- **RX** – Read & Execute
    
- **R** – Read-only
    
- **W** – Write-only
    

🔹 `icacls` is useful for **domain-wide access control, restricting user access, and managing file security**.

---


## **Windows and Malware**

- Windows holds over 70% of the desktop OS market share, making it a prime target for malware.
    
- The perception of Windows being less secure is due to its popularity rather than inherent flaws.
    
- Malware can be written for any OS; no system is truly immune.
    
- The **EternalBlue** vulnerability in SMBv1 is still exploited to spread ransomware.
    

#### **Server Message Block (SMB) and NTFS Permissions**

- **SMB** is used for sharing files and printers in Windows environments.
    
- **NTFS permissions** and **share permissions** are different but often apply to the same shared resource.
    

#### **Permissions Overview**

- **Share Permissions:**
    
    - _Full Control:_ All actions, including permission changes.
        
    - _Change:_ Modify, add, and delete files.
        
    - _Read:_ View contents only.
        
- **NTFS Permissions:**
    
    - _Full Control:_ Modify all files and permissions.
        
    - _Modify:_ Read, write, and delete files.
        
    - _Read & Execute:_ Open files and run programs.
        
    - _List Folder Contents:_ View files and folders.
        
    - _Write:_ Make changes to files.
        

#### **Creating a Network Share**

- A shared folder can be created via **Advanced Sharing**.
    
- SMB shares are commonly hosted on **NAS/SAN devices** in enterprises.
    
- **Access Control Lists (ACLs)** manage permissions for shared resources.
    

#### **Connecting to an SMB Share**

- `smbclient` can list available shares and connect to them.
    
- Windows Defender Firewall might block external SMB connections.
    
- Workgroup vs. Windows Domain authentication:
    
    - Workgroups use the local **SAM database**.
        
    - Domains use **Active Directory** for centralized authentication.
        
- Firewall settings impact connectivity and may need rule adjustments.

---

## **Windows Services**

Windows services are long-running processes that start automatically at boot and continue running in the background, even when users log out. They handle critical system functions such as networking, diagnostics, user authentication, and Windows updates. Services are managed via the **Service Control Manager (SCM)** through **services.msc** or the command line using `sc.exe` and PowerShell cmdlets like `Get-Service`.

#### **Managing Windows Services via PowerShell**

```powershell
PS C:\htb> Get-Service | ? {$_.Status -eq "Running"} | select -First 2 |fl
```

Example Output:

```
Name                : AdobeARMservice
DisplayName         : Adobe Acrobat Update Service
Status              : Running
...
Name                : Appinfo
DisplayName         : Application Information
Status              : Running
```

Services can have statuses like **Running, Stopped, Paused, Starting, or Stopping** and startup types like **Manual, Automatic, or Delayed Start**. Only users with **administrative privileges** can modify or delete services. Misconfigurations in service permissions can be used for **privilege escalation** in Windows systems.

### **Critical Windows System Services**

Some system services cannot be restarted without a system reboot. Examples include:

- **smss.exe** – Manages sessions
    
- **lsass.exe** – Handles authentication and security
    
- **winlogon.exe** – Manages user logins
    
- **services.exe** – Controls Windows services
    
- **svchost.exe** – Hosts services from DLLs
    

### **Processes in Windows**

Processes in Windows run in the background and can be system-managed or application-started. Some are critical and cannot be terminated without affecting system stability, such as **LSASS, System, and Windows Session Manager**.

#### **Local Security Authority Subsystem Service (LSASS)**

**lsass.exe** enforces security policies, handles authentication, and generates access tokens for logged-in users. It is a **high-value target for attackers** because it stores credentials in memory.

### **SysInternals Tools**

Microsoft’s **SysInternals Suite** provides powerful tools for system administration, available at `\\live.sysinternals.com\tools`.

#### **Using ProcDump from SysInternals**

```cmd
C:\htb> \\live.sysinternals.com\tools\procdump.exe -accepteula
```

ProcDump monitors and dumps process memory when specific criteria are met.

### **Task Manager and Process Monitoring**

**Windows Task Manager** provides insights into running processes, resource usage, and startup programs. It can be accessed via:

- `Ctrl + Shift + Esc`
    
- `Ctrl + Alt + Del > Task Manager`
    
- Running `taskmgr` in **CMD** or **PowerShell**
    

#### **Task Manager Tabs:**

- **Processes:** Lists applications and background processes with CPU, memory, and network usage.
    
- **Performance:** Displays real-time CPU, RAM, and disk usage graphs.
    
- **App History:** Tracks resource usage over time.
    
- **Startup:** Lists programs set to launch at boot.
    
- **Users:** Shows logged-in users and their process/resource usage.
    
- **Details:** Provides detailed process information, including **PID** and user ownership.
    
- **Services:** Displays installed services and their status.
    

### **Process Explorer**

A **SysInternals tool** that provides an advanced view of running processes, DLLs, and memory usage. It helps analyze **parent-child process relationships** and troubleshoot orphaned processes.

These tools are widely used for **system administration, security analysis, and penetration testing**.

---

## Windows Service Permissions

### Understanding Service Permissions

Services in Windows operating systems manage long-running processes. However, misconfigurations in service permissions can introduce security risks such as privilege escalation, persistence, and executing unauthorized applications.

### Importance of Service Accounts

When installing network services like DHCP or Active Directory Domain Services, the service runs using the credentials of the user performing the installation unless explicitly changed. Using personal accounts for services can lead to issues, such as service failures when the user account is disabled or removed. Best practices recommend using dedicated service accounts for running critical services.

### Examining Windows Services

#### Using services.msc

- `services.msc` allows viewing and managing all Windows services.
    
- The "Path to executable" field shows the program that runs when the service starts.
    
- If NTFS permissions for the directory are weak, attackers can replace executables with malicious files.
    
- Most services run under `LocalSystem`, which has the highest privilege level. Services should use the least privilege principle when possible.
    
- The "Recovery" tab allows configuring actions upon service failures, which attackers might exploit to execute malicious programs.
    

#### Using `sc` Command

- The `sc` (Service Control) command allows querying, configuring, and managing services.
    

#### Querying a Service

```
sc qc wuauserv
```

**Output Example:**

```
SERVICE_NAME: wuauserv
        TYPE               : 20  WIN32_SHARE_PROCESS
        START_TYPE         : 3   DEMAND_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : C:\WINDOWS\system32\svchost.exe -k netsvcs -p
        SERVICE_START_NAME : LocalSystem
```

#### Querying a Service on a Remote Device

```
sc //hostname_or_ip query ServiceName
```

#### Stopping a Service

```
sc stop wuauserv
```

If access is denied, the command must be executed with administrative privileges.

#### Changing the Service Executable Path

```
sc config wuauserv binPath=C:\Windows\PerfectlyLegitProgram.exe
```

**Verifying Changes:**

```
sc qc wuauserv
```

### Examining Service Permissions

#### Using `sc sdshow`

```
sc sdshow wuauserv
```

Output:

```
D:(A;;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)
```

- **D:** Represents Discretionary Access Control List (DACL) permissions.
    
- **AU:** Authenticated Users.
    
- **BA:** Built-in Administrators.
    
- **SY:** Local System.
    
- **Access Rights:**
    
    - `CC`: Query service configuration.
        
    - `LC`: Query service status.
        
    - `RP`: Start service.
        
    - `LO`: Query service current status.
        
    - `RC`: Read service security descriptor.
        

### Using PowerShell to Examine Service Permissions

```
Get-ACL -Path HKLM:\System\CurrentControlSet\Services\wuauserv | Format-List
```

This retrieves the access control list (ACL) for the Windows Update service registry entry.

### Security Best Practices

1. Use dedicated service accounts instead of user accounts.
    
2. Follow the principle of least privilege for service permissions.
    
3. Regularly audit service permissions using `sc` and PowerShell.
    
4. Secure service executable directories to prevent unauthorized modifications.
    
5. Monitor for unauthorized service configuration changes.
    

By understanding and securing Windows service permissions, administrators can mitigate security risks associated with service misconfigurations.

---
## **Interactive vs. Non-Interactive Accounts in Windows**

- **Interactive Logon:** Requires user credentials to access a system locally, via `runas`, or through Remote Desktop.
    
- **Non-Interactive Accounts:** Used by Windows to run services without user interaction. No passwords required.
    

**Types of Non-Interactive Accounts:**

1. **Local System Account (NT AUTHORITY\SYSTEM):** Most powerful, used for OS tasks and Windows services.
    
2. **Local Service Account (NT AUTHORITY\LocalService):** Limited privileges, similar to a local user.
    
3. **Network Service Account (NT AUTHORITY\NetworkService):** Similar to Local Service but can authenticate network sessions.
    
---
### **PowerShell Script Execution and Policies: A Complete Guide**

## **1. `Set-ExecutionPolicy`**

### **Overview**

PowerShell has security policies to control the execution of scripts. The `Set-ExecutionPolicy` cmdlet allows users to modify these policies to define what scripts can run on a system.

### **Syntax**

```powershell
Set-ExecutionPolicy <PolicyName> [-Scope <Scope>] [-Force] [-WhatIf] [-Confirm]
```

### **Common Execution Policies**

|Policy Name|Description|
|---|---|
|**Restricted**|Default for Windows. Scripts cannot run. Only interactive commands allowed.|
|**AllSigned**|Only scripts signed by a trusted publisher can run. Prevents running untrusted scripts.|
|**RemoteSigned**|Local scripts can run without a signature, but downloaded scripts require a trusted signature.|
|**Unrestricted**|All scripts can run, but downloaded scripts show a security warning before execution.|
|**Bypass**|No restrictions. Any script can run without warnings or prompts.|
|**Undefined**|Removes the set policy and falls back to the default policy (Restricted).|

### **Example Commands**

1. **Check current execution policies across all scopes**
    
    ```powershell
    Get-ExecutionPolicy -List
    ```
    
    **Output:**
    
    ```
       Scope          ExecutionPolicy
       -----          ---------------
       MachinePolicy  Undefined
       UserPolicy     Undefined
       Process        Undefined
       CurrentUser    Undefined
       LocalMachine   Restricted
    ```
    
2. **Temporarily allow script execution in the current session**
    
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process
    ```
    
    - Changes policy **only for the session**.
        
    - Once the session is closed, the change is lost.
        
3. **Permanently allow scripts for the current user**
    
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```
    
    - This setting persists across sessions for the **current user** only.
        
4. **Permanently allow scripts for all users on the machine**
    
    ```powershell
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine
    ```
    
    - **Requires Administrator privileges**.
        
5. **Remove execution policy (reset to default)**
    
    ```powershell
    Set-ExecutionPolicy Undefined -Scope LocalMachine
    ```
    

---

## **2. `Get-Module`**

### **Overview**

`Get-Module` lists PowerShell modules that are loaded in memory or available for import.

### **Syntax**

```powershell
Get-Module [-Name <ModuleName>] [-ListAvailable] [-All] [-FullyQualifiedName <ModuleName>] [-PSEdition <Edition>]
```

### **Common Uses**

1. **List currently loaded modules**
    
    ```powershell
    Get-Module
    ```
    
    **Output:**
    
    ```
    ModuleType Name         ExportedCommands
    ---------- ----         ----------------
    Script     Microsoft.PowerShell.Utility {Get-Random, New-Guid, ConvertTo-Json}
    Script     Microsoft.PowerShell.Management {Get-ChildItem, Set-Location, Move-Item}
    ```
    
2. **List all available modules (even if not loaded)**
    
    ```powershell
    Get-Module -ListAvailable
    ```
    
    **Output:**
    
    ```
    Directory: C:\Program Files\WindowsPowerShell\Modules
    
    ModuleType Name            Version  ExportedCommands
    ---------- ----            -------  ----------------
    Script     PSReadLine      2.1.0    {Get-PSReadLineKeyHandler, Set-PSReadLineKeyHandler}
    Manifest   AzureAD        2.0.2.130 {Get-AzureADUser, New-AzureADApplication}
    ```
    
3. **Show details of a specific module**
    
    ```powershell
    Get-Module -Name Microsoft.PowerShell.Management | Format-List
    ```
    
    **Output:**
    
    ```
    Name              : Microsoft.PowerShell.Management
    Path              : C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
    ExportedCommands  : {Get-Process, Stop-Process, Get-Service, Start-Service}
    ```
    
4. **Find what commands a module provides**
    
    ```powershell
    Get-Module | Select-Object Name, ExportedCommands | Format-List
    ```
    

---

## **3. Running Scripts & Command Execution**

### **Overview**

PowerShell allows executing scripts from local and remote locations. However, execution policies can block script execution for security reasons.

### **Example Script Execution**

1. **Running a PowerShell script from the current directory**
    
    ```powershell
    .\PowerView.ps1
    ```
    
    - `.\` means **execute from the current directory**.
        
    - If execution is blocked, use:
        
        ```powershell
        Set-ExecutionPolicy Bypass -Scope Process
        ```
        
2. **Running a script and a command in sequence**
    
    ```powershell
    .\PowerView.ps1; Get-LocalGroup | fl
    ```
    
    **Breakdown:**
    
    - `.\PowerView.ps1` → Runs the script.
        
    - `;` → Separates two commands in one line.
        
    - `Get-LocalGroup` → Lists local user groups.
        
    - `| fl` (Format-List) → Displays output in a detailed list format.
        
    
    **Example Output:**
    
    ```
    Name        : Administrators
    Description : Administrators have complete and unrestricted access to the computer/domain.
    
    Name        : Users
    Description : Users are prevented from making accidental or intentional system-wide changes.
    ```
    
3. **Running a remote script**
    
    ```powershell
    Invoke-Command -ComputerName Server01 -FilePath C:\Scripts\MyScript.ps1
    ```
    
    - Runs `MyScript.ps1` on `Server01` remotely.
        
4. **Running a script with arguments**
    
    ```powershell
    .\MyScript.ps1 -Param1 Value1 -Param2 Value2
    ```
    

---

### **Security Considerations for Script Execution**

- **Always verify the source of a script before running it.**
    
- **Use `RemoteSigned` instead of `Unrestricted` for better security.**
    
- **Avoid using `Bypass` unless necessary for temporary sessions.**
    
- **Use `Get-ExecutionPolicy -List` to check the policy before running scripts.**
    

---

## **Windows Management Instrumentation (WMI)** 

### 🔹 **Key Points About WMI**

1. **Core Windows Component**: Pre-installed since Windows 2000.
    
2. **Manages System Components**: Used to monitor hardware/software.
    
3. **Components**:
    
    - **WMI Service**: Manages communication.
        
    - **WMI Providers**: Gather system info.
        
    - **Classes & Methods**: Define operations.
        
    - **WMI Repository**: Stores static data.
        
    - **CIM Object Manager**: Handles queries.
        
    - **WMI API**: For external applications.
        

### 🔹 **Uses of WMI**

- Monitor local/remote systems.
    
- Configure security settings.
    
- Modify system properties.
    
- Schedule tasks and run commands.
    

### 🔹 **WMIC (Deprecated)**

- Previously used via `wmic` command.
    
- Example: `wmic os list brief` (Quick system info).
    

### 🔹 **PowerShell WMI Commands**

1. **Get System Info**:
    
    ```powershell
    Get-WmiObject -Class Win32_OperatingSystem | select SystemDirectory,BuildNumber,SerialNumber,Version | ft
    ```
    
2. **Invoke Methods (Example: Rename a File)**
    
    ```powershell
    Invoke-WmiMethod -Path "CIM_DataFile.Name='C:\users\public\spns.csv'" -Name Rename -ArgumentList "C:\Users\Public\kerberoasted_users.csv"
    ```
    

### 🚀 **PowerShell Replacements for WMIC**

Since **WMIC is deprecated**, use **PowerShell CIM Cmdlets** instead:

- `Get-WmiObject` → Use `Get-CimInstance`
    
    ```powershell
    Get-CimInstance -ClassName Win32_OperatingSystem
    ```
    
- `Invoke-WmiMethod` → Use `Invoke-CimMethod`
    
    ```powershell
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine="notepad.exe"}
    ```
    

---

### **Windows Server Core vs. Desktop Experience**

🔹 **Windows Server Core**

- **First Introduced**: Windows Server 2008
    
- **Purpose**: Minimalistic, command-line-based server installation
    
- **Benefits**:
    
    - **Smaller footprint** (uses less disk space and memory)
        
    - **Lower attack surface** (fewer components exposed to threats)
        
    - **Lower management requirements**
        
    - **Better performance for specific workloads**
        
- **Management Methods**:
    
    - **PowerShell & Command Prompt**
        
    - **Remote Management** (MMC, RSAT)
        
    - **Limited GUI tools** (Notepad, Task Manager, Registry Editor)
        
- **Common Use Cases**:
    
    - Domain Controllers
        
    - Web Servers
        
    - DNS/DHCP Servers
        
    - Hyper-V Hosts
        

🔹 **Windows Server (Desktop Experience)**

- **Full GUI Version** (Similar to Windows 10/11 interface)
    
- **Easier to Manage** (For admins less comfortable with CLI)
    
- **Supports More Applications** (e.g., Microsoft SCVMM, SharePoint)
    
- **More Resource-Intensive** (Consumes more CPU, RAM, and disk space)
    
- **Best For**:
    
    - Admins who need GUI-based management
        
    - Servers running applications requiring GUI
        

🔹 **Key Differences**

|Feature/Application|Server Core|Desktop Experience|
|---|---|---|
|**Command Prompt**|✅ Available|✅ Available|
|**PowerShell**|✅ Available|✅ Available|
|**Registry Editor (Regedit)**|✅ Available|✅ Available|
|**Task Manager**|✅ Available|✅ Available|
|**Windows Explorer**|❌ Not Available|✅ Available|
|**Server Manager**|❌ Not Available|✅ Available|
|**Control Panel**|❌ Not Available|✅ Available|
|**MMC (Microsoft Management Console)**|❌ Not Available|✅ Available|
|**Event Viewer (Eventvwr)**|❌ Not Available|✅ Available|
|**Disk Management (diskmgmt.msc)**|❌ Not Available|✅ Available|
|**Internet Explorer/Edge**|❌ Not Available|✅ Available|
|**Remote Desktop Services**|✅ Available|✅ Available|

---

### **When to Choose Server Core vs. Desktop Experience?**

✔ **Use Server Core if:**

- You need a lightweight, secure, and efficient server.
    
- The server will run without requiring a GUI for daily tasks.
    
- You are comfortable managing it via PowerShell or remote tools.
    

✔ **Use Desktop Experience if:**

- You require GUI-based management.
    
- The server must run applications that depend on GUI components.
    
- You are administering it locally rather than remotely.
    

🔹 **Important Note**: Since **Windows Server 2019**, **you must choose between Server Core or Desktop Experience at installation**, and it **cannot be changed later**.

---

### **Summary of Windows Security**

Windows security is essential due to its large attack surface, built-in features that can be abused, and historical vulnerabilities. Microsoft has continually improved Windows security by adding features that help system administrators harden systems and detect attacks.

#### **Key Security Principles**

- Windows controls access and authentication using **Security Identifiers (SIDs)**, which uniquely identify users, groups, or processes.
    
- **Security Accounts Manager (SAM)** and **Access Control Lists (ACLs)** manage permissions, defining which users or processes can access files or execute tasks.
    
- **User Account Control (UAC)** prevents unauthorized software installations by requiring user confirmation before executing administrative actions.
    

#### **Windows Registry**

- A hierarchical database storing system and application settings, divided into **HKEY root keys** (e.g., HKLM, HKCU).
    
- Registry values include **REG_DWORD, REG_SZ, REG_BINARY,** and others, defining different data types.
    
- System-wide registry settings are stored in **C:\Windows\System32\Config**, while user-specific settings are in **C:\Users<USERNAME>\Ntuser.dat**.
    

Windows security relies on authentication mechanisms, access control, and system configurations to prevent unauthorized access and protect against cyber threats.