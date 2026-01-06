
## Table of Contents

1. **Introduction to AWS Systems Manager**
    
2. **Prerequisites**
    
3. **AWS Systems Manager Node Tools Overview**
    
4. **1. Compliance**
    
5. **2. Distributor**
    
6. **3. Fleet Manager**
    
7. **4. Hybrid Activations**
    
8. **5. Inventory**
    
9. **6. Patch Manager**
    
10. **7. Run Command**
    
11. **8. Session Manager**
    
12. **9. State Manager**
    
13. **Best Practices and Tips**
    
14. **Summary**
    

---

## 1. Introduction to AWS Systems Manager (SSM)

AWS Systems Manager helps you automatically apply OS patches, collect software inventory, configure OS and applications at scale, and automate operational tasks on AWS EC2 instances, on-premises servers, and virtual machines (VMs).

**Node Tools** are components of Systems Manager that help manage individual instances (nodes).

---

## 2. Prerequisites

- AWS Account with appropriate permissions (SSM roles/policies).
    
- EC2 instances with SSM Agent installed and running.
    
- IAM roles attached to EC2 instances (e.g., `AmazonSSMManagedInstanceCore`).
    
- AWS CLI configured or AWS Management Console access.
    
- (For hybrid) On-premises servers or VMs reachable with Hybrid Activation.
    

---

## 3. AWS Systems Manager Node Tools Overview

|Tool|Description|
|---|---|
|Compliance|Assess and enforce configuration compliance of your instances.|
|Distributor|Distribute software packages and scripts to managed nodes.|
|Fleet Manager|Centralized management console for your managed instances' OS and applications.|
|Hybrid Activations|Manage on-premises servers or VMs with Systems Manager.|
|Inventory|Collect metadata about your instances and installed software.|
|Patch Manager|Automate patching of OS and software on instances.|
|Run Command|Execute commands or scripts remotely on instances.|
|Session Manager|Securely connect to instances without SSH/RDP.|
|State Manager|Automate configuration management and maintain desired states.|

---

## 4. Compliance

### Overview

Compliance allows you to scan instances for compliance against policies (patching, configuration, etc.) and take remediation actions.

### Practical Steps

1. **Define Compliance Items:**
    

- Use predefined compliance types (e.g., patch compliance).
    
- Custom compliance can be created with AWS Config or custom scripts.
    

2. **View Compliance:**
    

- Go to AWS Console > Systems Manager > Compliance.
    
- See compliance summary and details per instance.
    

3. **Example: Create Patch Compliance**
    

- Use Patch Manager to define patch baselines.
    
- Apply baselines to patch groups.
    
- View patch compliance reports.
    

---

## 5. Distributor

### Overview

Distributor lets you package and distribute software or scripts to managed nodes.

### Practical Steps

1. **Create a Distributor Package:**
    

- Prepare your software/script and package as `.zip`.
    
- Go to Systems Manager > Distributor > Create Package.
    
- Upload your package and define install/uninstall commands.
    

2. **Distribute Package:**
    

- Target instances or tags.
    
- Monitor distribution progress.
    

3. **Example: Distribute a Custom Script**
    

- Create a script (e.g., `install_myapp.sh`).
    
- Package it with a manifest.
    
- Distribute and verify installation via Run Command.
    

---

## 6. Fleet Manager

### Overview

Fleet Manager provides a unified UI to view and manage your fleet of instances.

### Practical Steps

1. **Access Fleet Manager:**
    

- AWS Console > Systems Manager > Fleet Manager.
    
- Select instance, view instance info (CPU, disk, memory), users, processes.
    

2. **Manage Instances:**
    

- View logs, files, and perform common management tasks.
    
- Connect to instance shells using Session Manager.
    

3. **Example: Use Fleet Manager to troubleshoot an instance**
    

- View running processes.
    
- View disk usage.
    
- Connect to shell for manual inspection.
    

---

## 7. Hybrid Activations

### Overview

Allows you to register on-premises servers or VMs as managed instances.

### Practical Steps

1. **Create Hybrid Activation:**
    

- Systems Manager > Hybrid Activations > Create activation.
    
- Download activation code and ID.
    

2. **Install SSM Agent on on-prem servers:**
    

- Use activation code & ID to register on-prem server with AWS.
    

3. **Verify Managed Instance:**
    

- Confirm hybrid instance shows up in Systems Manager > Managed Instances.
    

---

## 8. Inventory

### Overview

Collects metadata (OS, applications, network configs) from your managed nodes.

### Practical Steps

1. **Enable Inventory Collection:**
    

- Go to Systems Manager > Inventory > Setup Inventory.
    
- Choose target instances or tags.
    

2. **View Collected Data:**
    

- Access Inventory reports showing installed applications, network config, etc.
    

3. **Example: Collect Inventory of Installed Packages**
    

- Enable AWS-RunInventory document.
    
- View inventory data in console or query via AWS CLI.
    

---

## 9. Patch Manager

### Overview

Automates patching of operating systems and software.

### Practical Steps

1. **Create Patch Baseline:**
    

- Go to Systems Manager > Patch Manager > Patch Baselines.
    
- Use AWS predefined baseline or create custom.
    

2. **Assign Patch Group:**
    

- Tag instances with patch group tag.
    
- Associate patch baseline with patch group.
    

3. **Run Patch Compliance Scan:**
    

- Manually or scheduled via maintenance windows.
    

4. **Example: Schedule Patching**
    

- Create maintenance window.
    
- Register patch task.
    
- Automate patch deployment and compliance reporting.
    

---

## 10. Run Command

### Overview

Run shell commands/scripts remotely on your instances.

### Practical Steps

1. **Run a Command:**
    

- Systems Manager > Run Command > Run a command.
    
- Select command document (AWS-RunShellScript).
    
- Specify instances or tags.
    
- Provide script/commands.
    

2. **View Results:**
    

- Check command status and output in console or via CLI.
    

3. **Example: Update Packages**
    

```bash
sudo yum update -y
```

- Run this as a command on your Linux instances.
    

---

## 11. Session Manager

### Overview

Securely connect to instances without SSH keys or open ports.

### Practical Steps

1. **Start Session:**
    

- Systems Manager > Session Manager > Start session.
    
- Select instance.
    

2. **Connect via CLI:**
    

```bash
aws ssm start-session --target instance-id
```

3. **Advanced: Enable port forwarding or logging.**
    

---

## 12. State Manager

### Overview

Maintain and enforce instance configuration at scale.

### Practical Steps

1. **Create Association:**
    

- Define document (e.g., AWS-ConfigureWindowsUpdate).
    
- Target instances or tags.
    
- Set schedule or event trigger.
    

2. **Example: Enforce NTP settings**
    

- Use a custom SSM document or predefined.
    
- Apply via State Manager association.
    

3. **Monitor compliance via console or CLI.**
    

---

## 13. Best Practices and Tips

- **Use IAM roles properly:** Ensure instances have `AmazonSSMManagedInstanceCore`.
    
- **Tagging:** Use consistent tagging for patch groups, inventory, and associations.
    
- **Use Maintenance Windows:** For patching and configuration changes to avoid disruptions.
    
- **Logging & Auditing:** Enable SSM Session Manager logging to CloudWatch or S3.
    
- **Security:** Use Session Manager instead of SSH, disable SSH inbound ports.
    

---

## 14. Summary

|Tool|Key Use Case|
|---|---|
|Compliance|Audit instance compliance|
|Distributor|Deploy software packages|
|Fleet Manager|Manage instance health and OS info|
|Hybrid Activations|Register on-prem servers as managed instances|
|Inventory|Collect system and software metadata|
|Patch Manager|Automate patching|
|Run Command|Execute commands remotely|
|Session Manager|Secure shell access without SSH|
|State Manager|Enforce configuration at scale|

---
