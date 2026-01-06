
#### **What is Active Directory (AD)?**

Active Directory (AD) is a directory service used in Windows network environments for centralized management of users, computers, groups, policies, and network resources. It provides authentication and authorization functions within a Windows domain. AD is hierarchical and distributed, making it scalable but also prone to misconfigurations and security vulnerabilities.

#### **Active Directory Components**

- **Active Directory Domain Services (AD DS):** Stores user credentials and manages access rights.
    
- **Organizational Units (OUs):** Logical containers that group users, computers, and policies.
    
- **Group Policy Objects (GPOs):** Define security and system configurations across the domain.
    
- **Access Control Lists (ACLs):** Manage permissions for objects in AD.
    
- **Trusts:** Establish relationships between domains or forests for resource access.
    

#### **Active Directory Hierarchy**

- **Forest:** The highest-level security boundary, containing one or more domains.
    
- **Domains:** Contain users, computers, and groups within a network.
    
- **Subdomains:** Nested domains for further organization.
    
- **Objects:** Individual elements like users, computers, and policies.
    

#### **Security Concerns**

AD misconfigurations can allow attackers to:

- Gain unauthorized access through **privilege escalation** and **lateral movement**.
    
- Enumerate critical domain information using **low-privilege accounts**.
    
- Exploit **trust relationships** between domains and forests.
    

#### **Example Structure**

```
INLANEFREIGHT.LOCAL/
├── ADMIN.INLANEFREIGHT.LOCAL
│   ├── GPOs
│   └── OU
│       └── EMPLOYEES
│           ├── COMPUTERS
│           │   └── FILE01
│           ├── GROUPS
│           │   └── HQ Staff
│           └── USERS
│               └── barbara.jones
├── CORP.INLANEFREIGHT.LOCAL
└── DEV.INLANEFREIGHT.LOCAL
```

This structure represents a root domain (**INLANEFREIGHT.LOCAL**) with subdomains for different departments.

#### **Trust Relationships**

Organizations often link multiple domains/forests using **trust relationships** to allow resource sharing. However, improperly configured trusts can introduce security risks.

---
Here’s a structured table summarizing the **Active Directory (AD) Terminology**:

| **Term**                               | **Definition**                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Object**                             | Any resource in an AD environment.                                                                      |
| **Attributes**                         | Properties assigned to objects (e.g., hostname, DNS). Used in LDAP queries.                             |
| **Schema**                             | Blueprint defining object types and their attributes in AD.                                             |
| **Domain**                             | Group of logically connected objects that operate independently. Can be linked via trust relationships. |
| **Forest**                             | Collection of multiple domains under a single administrative control.                                   |
| **Tree**                               | A collection of domains beginning with a root domain.                                                   |
| **Container**                          | Holds objects in the directory hierarchy.                                                               |
| **Leaf**                               | Object at the end of a subtree hierarchy.                                                               |
| **Global Unique Identifier (GUID)**    | 128-bit unique ID for AD objects, similar to a MAC address.                                             |
| **Security Principles**                | Objects (users, groups) that control access to resources.                                               |
| **Security Identifier (SID)**          | Unique identifier for security principles (users, groups). Once assigned, it cannot be reused.          |
| **Distinguished Name (DN)**            | Full path to an object in AD.                                                                           |
| **sAMAccountName**                     | User’s logon name.                                                                                      |
| **User Principal Name (UPN)**          | Identifies users in AD (e.g., `bjones@inlanefreight.local`). Not mandatory.                             |
| **FSMO Roles**                         | Flexible Single Master Operation (FSMO) roles for AD management.                                        |
| **Global Catalog (GC)**                | Domain controller that stores partial copies of objects across the forest.                              |
| **Read-Only Domain Controller (RODC)** | DC with read-only data. No AD passwords cached.                                                         |
| **Service Principal Name (SPN)**       | Identifier for services used in **Kerberos authentication**.                                            |
| **Group Policy Object (GPO)**          | Virtual collection of policy settings assigned to objects.                                              |
| **Access Control List (ACL)**          | Collection of **Access Control Entries (ACEs)** defining permissions on objects.                        |
| **Access Control Entries (ACEs)**      | Defines access rights for a specific **trustee**.                                                       |
| **Fully Qualified Domain Name (FQDN)** | Complete name for a computer/host in AD.                                                                |
| **Tombstone**                          | Temporary container holding deleted AD objects before permanent removal.                                |
| **SYSVOL**                             | Stores system policies, GPOs, login scripts. Replicated across DCs.                                     |
| **dsHeuristics**                       | Attribute that defines multiple **forest-wide settings**.                                               |
| **NTDS.DIT**                           | Core AD database stored at `C:\Windows\NTDS\`. Contains user/group data and password hashes.            |

---
Here's a table summarizing the Active Directory objects:

|**Object**|**Description**|
|---|---|
|**Users**|Individual accounts within AD. They are security principals with SIDs and GUIDs. Users are leaf objects.|
|**Contacts**|External user representations (e.g., vendors, customers). They are leaf objects but not security principals (no SID, only GUID).|
|**Printers**|Objects that point to network-accessible printers. They are leaf objects and not security principals (no SID, only GUID).|
|**Computers**|Workstations or servers joined to AD. They are security principals with SIDs and GUIDs. They are leaf objects.|
|**Shared Folders**|Points to a shared folder on a specific system. They are not security principals (no SID, only GUID).|
|**Groups**|Containers that hold users, computers, or other groups. They are security principals with SIDs and GUIDs. Used for permission management.|
|**Organizational Units (OUs)**|Containers for grouping objects (users, groups, computers) to apply policies and delegate administrative control.|
|**Domain**|Logical structure of an AD network containing objects like users, groups, and policies. Each domain has a separate database and policies.|
|**Domain Controllers**|Servers that authenticate users, validate access, enforce security policies, and store AD object information.|
|**Sites**|Sets of computers connected over high-speed links. Used to optimize domain controller replication.|
|**Built-in**|A container in AD that holds default groups created when the domain is set up.|
|**Foreign Security Principals (FSPs)**|Placeholder objects for security principals from trusted external forests. Used in cross-forest authentication.|

---
### **Active Directory Functionality - Summary**

#### **FSMO Roles**

Active Directory has five **Flexible Single Master Operation (FSMO)** roles:

1. **Schema Master** – Manages the AD schema (object attributes).
    
2. **Domain Naming Master** – Manages domain names to prevent duplicates.
    
3. **RID Master** – Assigns unique security identifiers (SIDs) to domain objects.
    
4. **PDC Emulator** – Handles authentication, password changes, Group Policy, and time synchronization.
    
5. **Infrastructure Master** – Translates security identifiers (SIDs) between domains.
    

Issues with FSMO roles can cause authentication and authorization failures.

#### **Domain & Forest Functional Levels**

These levels define available **Active Directory Domain Services (AD DS)** features and supported Windows Server versions:

- **Domain Functional Levels** (Windows 2000 to 2016) introduce features like Universal Groups, Fine-grained Password Policies, Authentication Policies, and Kerberos improvements.
    
- **Forest Functional Levels** (Windows Server 2003 to 2016) introduced capabilities like **Forest Trusts, Domain Renaming, AD Recycle Bin, and Privileged Access Management (PAM).**
    

#### **Trusts**

Trusts enable authentication between **domains and forests**, allowing users to access external resources.

##### **Types of Trusts:**

|Trust Type|Description|
|---|---|
|**Parent-child**|Domains within the same forest. The child domain has a two-way transitive trust with the parent domain.|
|**Cross-link**|A trust between child domains to speed up authentication.|
|**External**|A non-transitive trust between two separate domains in different forests. Uses **SID filtering** for security.|
|**Tree-root**|A two-way transitive trust between a forest root domain and a new tree root domain.|
|**Forest**|A transitive trust between two forest root domains.|
![Pasted image 20250330152910.png](Pasted%20image%2020250330152910.png.md)
##### **Trust Properties:**

- **Transitive Trusts** – Extend trust to indirectly connected domains.
    
- **Non-transitive Trusts** – Limited to the directly trusted domain.
    
- **One-way Trusts** – Only the trusted domain users can access the trusting domain’s resources.
    
- **Two-way Trusts** – Both domains can access each other’s resources.
    

##### **Security Risks:**

- Improper trust configurations can create **vulnerabilities** (e.g., Kerberoasting attacks).
    
- **Mergers and acquisitions** may introduce **insecure bidirectional trusts**, leading to unintended security risks.