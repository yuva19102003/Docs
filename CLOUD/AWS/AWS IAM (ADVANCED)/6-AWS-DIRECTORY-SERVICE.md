
## 📘 What is AWS Directory Service?

AWS Directory Service allows you to **set up and run Microsoft Active Directory (AD)** on AWS. It supports:

- User and group management
    
- Integration with Microsoft applications
    
- Seamless domain join for EC2 instances
    
- Authentication for AWS apps like WorkSpaces, QuickSight, and RDS for SQL Server
    

---

## 🧱 Types of AWS Directory Service

|Type|Description|
|---|---|
|**AWS Managed Microsoft AD**|Fully managed, actual Microsoft AD|
|**Simple AD**|Lightweight, Samba-based AD-compatible directory|
|**AD Connector**|Proxy for on-premises AD|
|**Microsoft AD via EC2**|Manual setup on Windows Server|

---

## 🎯 When to Use Which?

- **Managed Microsoft AD**: For full compatibility and enterprise features.
    
- **Simple AD**: For dev/test or small workloads.
    
- **AD Connector**: When you already have an on-prem AD and want to extend it to AWS.
    
- **Self-managed AD on EC2**: Full control, but more overhead.
    

---

## 🛠️ Tutorial: Set Up AWS Managed Microsoft AD

### ✅ Prerequisites

- AWS account
    
- VPC with at least two subnets in different AZs (for high availability)
    
- Internet access / NAT for updates
    

---

### Step 1: Create a Directory

1. Go to **AWS Directory Service** in the console.
    
2. Click **Set up directory**.
    
3. Choose **AWS Managed Microsoft AD**.
    
4. Select **Standard** or **Enterprise** edition.
    
5. Fill in:
    
    - Directory DNS name (e.g., `corp.example.com`)
        
    - NetBIOS name (e.g., `CORP`)
        
    - Admin password
        
6. Choose VPC and two subnets in different AZs.
    
7. Review and create.
    

🕒 Wait ~20–40 minutes for provisioning.

---

### Step 2: Join an EC2 Instance to the Domain

1. Launch a Windows EC2 in the same VPC/subnet.
    
2. Ensure security group allows:
    
    - DNS (UDP/TCP 53)
        
    - AD ports: TCP/UDP 88, 389, 445, 464
        
3. Log into the instance.
    
4. Go to **System > Change settings > Domain**, and join the domain.
    
5. Reboot when prompted.
    

---

### Step 3: Create Users and Groups

1. Install **Remote Server Administration Tools (RSAT)** on your EC2 (Windows).
    
2. Open **Active Directory Users and Computers**.
    
3. Connect to your domain.
    
4. Create OUs, users, and groups as needed.
    

---

## 💡 Common Integrations

### ✅ Amazon WorkSpaces

- Create a directory in Directory Service.
    
- Launch WorkSpaces and select the domain for user login.
    
- Users log in with domain credentials.
    

### ✅ RDS for SQL Server

- Create RDS SQL Server instance.
    
- Enable **Directory Authentication** and choose your domain.
    
- Add users/groups in AD for access.
    

### ✅ EC2 Linux with SSSD

- Use **SSSD and realmd** to join Linux instances to the domain.
    
- Manage SSH logins with AD credentials.
    

---

## 📈 Monitoring and Logs

- CloudWatch logs
    
- Directory Service events
    
- Use **AWS Config** to track changes
    

---

## 🧪 Testing & Troubleshooting

### 🔍 Useful commands

- `nltest /dsgetdc:<domain>` – check domain controller
    
- `ipconfig /all` – verify DNS settings
    
- `dcdiag` – diagnose domain controller health
    

---

## 🔐 Security Best Practices

- Use **IAM policies** to restrict access to Directory Service
    
- Rotate the AD administrator password
    
- Enable **AWS Backup** for directory snapshots
    
- Use **AWS KMS** for encryption
    

---

## 🧩 Cost

- **Standard Edition**: ~~$0.15/hr (~~$110/month)
    
- **Enterprise Edition**: ~~$0.40/hr (~~$290/month)
    
- AD Connector and Simple AD are cheaper alternatives
    

---

## 📚 Resources

- [AWS Directory Service Docs](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/what_is.html)
    
- [Tutorial: Join Linux to AWS Managed Microsoft AD](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/join_linux_instance.html)
    
- [Amazon WorkSpaces + Directory Service](https://docs.aws.amazon.com/workspaces/latest/adminguide/directory_services.html)
    

---
**Integrating AWS Managed Microsoft AD with Amazon RDS for SQL Server**. This setup allows **Windows Authentication** for RDS, meaning users from your domain can log into SQL Server using their AD credentials.

---

## ✅ Goal

> Join Amazon RDS for SQL Server to your **AWS Managed Microsoft AD** so you can:

- Use **Windows Authentication** (via AD) for RDS logins
    
- Control access through AD users and groups
    

---

## 🧱 Prerequisites

1. ✅ AWS Managed Microsoft AD is already set up
    
2. ✅ A SQL Server-compatible RDS instance (not Aurora)
    
3. ✅ The RDS and AD must be in the **same VPC**
    
4. ✅ At least 2 subnets in different AZs (required by AD)
    
5. ✅ An EC2 instance (domain-joined) for managing the database via SSMS (SQL Server Management Studio)
    

---

## 🛠️ Step-by-Step Setup

### 🔹 Step 1: Create or Use an AWS Managed Microsoft AD

If you haven’t already:

- Go to **Directory Service**
    
- Choose **AWS Managed Microsoft AD**
    
- Set up with a domain like `corp.example.com`
    

📌 Note the **Directory ID**

---

### 🔹 Step 2: Launch RDS for SQL Server

1. Go to **RDS > Create database**
    
2. Engine: **Microsoft SQL Server**
    
3. Choose **Standard** or **Enterprise** (Windows Auth not available in Express/Web)
    
4. In **Settings**:
    
    - DB instance identifier
        
    - Master username and password
        
5. In **Connectivity**:
    
    - Select **same VPC** as your AD
        
    - Enable **public access** if needed (for testing)
        
6. Under **Microsoft SQL Server Windows Authentication**, select your **Directory**.
    

> 🟡 RDS will join the domain during creation — this takes longer than normal DB launch (~20 minutes).

---

### 🔹 Step 3: Create a SQL Login Mapped to AD User

#### From your **domain-joined EC2**, install SSMS:

```powershell
winget install --id Microsoft.SQLServerManagementStudio
```

1. Open SSMS
    
2. Connect to the RDS instance using the **SQL admin login**
    
3. Run the following to add an AD user/group:
    

```sql
CREATE LOGIN [corp\john.doe] FROM WINDOWS;
```

💡 You can now assign roles:

```sql
EXEC sp_addsrvrolemember 'corp\john.doe', 'sysadmin';
```

---

### 🔹 Step 4: Test Domain Login

1. From the same domain-joined EC2, open SSMS
    
2. In login prompt:
    
    - Server name: `your-rds-endpoint`
        
    - Authentication: **Windows Authentication**
        

You should be able to log in using your **AD credentials**.

---

## 🧪 Bonus: Group-based Access

Instead of assigning users individually:

```sql
CREATE LOGIN [corp\SqlAdmins] FROM WINDOWS;
EXEC sp_addsrvrolemember 'corp\SqlAdmins', 'dbcreator';
```

Then just add users to `SqlAdmins` group in AD.

---

## 🔐 Security Best Practices

- Use **IAM roles** to control RDS and Directory access
    
- Use **TLS encryption** for SQL Server connections
    
- Rotate admin credentials regularly
    
- Restrict RDS to private subnets in production
    

---

## 📉 Cost Considerations

- RDS SQL Server Standard/Enterprise editions have licensing costs
    
- AWS Managed Microsoft AD adds cost per hour depending on edition
    
- Domain-joined EC2 for SSMS is optional (but often needed for GUI)
    

---

## 📚 Useful Links

- [AWS RDS Windows Auth Setup](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.AWSDirectoryService.WindowsAuth.html)
    
- [SSMS Download](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
    
- [AWS Directory Service Pricing](https://aws.amazon.com/directoryservice/pricing/)
    

---
