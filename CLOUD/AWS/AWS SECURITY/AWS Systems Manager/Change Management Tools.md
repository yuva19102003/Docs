
## Table of Contents

1. Overview of Change Management in AWS Systems Manager
    
2. Prerequisites
    
3. AWS Systems Manager Change Management Tools
    
    - 3.1 Automation
        
    - 3.2 Change Calendar
        
    - 3.3 Change Manager
        
    - 3.4 Documents
        
    - 3.5 Maintenance Windows
        
    - 3.6 Quick Setup
        
4. Best Practices
    
5. Summary
    

---

## 1. Overview of Change Management in AWS Systems Manager

AWS Systems Manager Change Management helps you plan, approve, implement, and audit changes in your AWS environment. It improves governance by automating workflows, scheduling maintenance, and integrating with your approval processes to reduce risks related to infrastructure changes.

---

## 2. Prerequisites

- AWS Account with required IAM permissions.
    
- EC2 instances managed by Systems Manager.
    
- Systems Manager Agent (SSM Agent) installed and running on managed instances.
    
- IAM roles and policies allowing Systems Manager operations.
    
- AWS CLI or AWS Management Console access.
    

---

## 3. AWS Systems Manager Change Management Tools

---

### 3.1 Automation

**Purpose:**  
Automate operational tasks and runbooks to reduce manual work and errors.

**Key Features:**

- Execute predefined or custom automation workflows.
    
- Use automation documents (runbooks) defined in JSON/YAML.
    
- Track execution history and outputs.
    

**Practical Tutorial:**

**Step 1:** Run an automation document.

- Go to AWS Console → Systems Manager → Automation → Execute Automation.
    
- Choose a document such as `AWS-UpdateLinuxAmi` or create your own.
    
- Specify parameters (e.g., InstanceIds).
    
- Start automation and monitor progress.
    

**Example:** Create a custom automation document to reboot instances.

```json
{
  "description": "Reboot EC2 instances",
  "schemaVersion": "0.3",
  "assumeRole": "{{ AutomationAssumeRole }}",
  "parameters": {
    "InstanceIds": {
      "type": "StringList",
      "description": "List of instance IDs to reboot"
    }
  },
  "mainSteps": [
    {
      "name": "rebootInstances",
      "action": "aws:runCommand",
      "inputs": {
        "DocumentName": "AWS-RunShellScript",
        "InstanceIds": "{{ InstanceIds }}",
        "Parameters": {
          "commands": ["sudo reboot"]
        }
      }
    }
  ]
}
```

**Step 2:** Execute this document via Console or CLI.

```bash
aws ssm start-automation-execution --document-name "MyRebootInstances" --parameters InstanceIds=["i-0123456789abcdef0"]
```

---

### 3.2 Change Calendar

**Purpose:**  
Define periods when changes are allowed or blocked (blackout windows).

**Use Case:**  
Prevent change execution during critical business hours or blackout periods.

**Practical Tutorial:**

**Step 1:** Create a change calendar.

- Go to Systems Manager → Change Calendar → Create calendar.
    
- Define calendar using JSON or plain text, e.g.:
    

```json
{
  "Version": "2018-05-10",
  "Properties": {
    "Name": "NoChangeWeekends",
    "Description": "Block changes on weekends",
    "Dates": ["FREQ=WEEKLY;BYDAY=SA,SU"]
  }
}
```

**Step 2:** Attach calendar to change requests or maintenance windows.

**Step 3:** View active calendars in the console.

---

### 3.3 Change Manager

**Purpose:**  
Manage the lifecycle of changes with workflows, approvals, and audit trails.

**Key Features:**

- Define change templates.
    
- Create and approve change requests.
    
- Integrate with automation and maintenance windows.
    

**Practical Tutorial:**

**Step 1:** Define a change template.

- Go to Systems Manager → Change Manager → Templates → Create template.
    
- Define the scope (resources), approval workflow, and automation steps.
    

**Step 2:** Create a change request using the template.

- Submit request with description, risk, and schedule.
    
- Approvers get notifications; they can approve or reject.
    

**Step 3:** Upon approval, the change executes automatically or manually.

---

### 3.4 Documents

**Purpose:**  
Store and manage automation runbooks, commands, and configuration documents.

**Types:**

- Command documents (AWS-RunShellScript)
    
- Automation documents
    
- Configuration documents
    

**Practical Tutorial:**

**Step 1:** Create a new SSM document.

- Go to Systems Manager → Documents → Create document.
    
- Choose document type (Automation, Command, etc.).
    
- Write content using YAML/JSON.
    

**Step 2:** Use documents with Run Command, Automation, State Manager.

---

### 3.5 Maintenance Windows

**Purpose:**  
Schedule time windows for change execution to avoid business impact.

**Use Case:**  
Run patching, updates, automation tasks only during approved maintenance hours.

**Practical Tutorial:**

**Step 1:** Create a Maintenance Window.

- Systems Manager → Maintenance Windows → Create maintenance window.
    
- Define name, schedule (cron or rate), duration, and cutoff.
    

**Step 2:** Register targets (instances or tags).

**Step 3:** Register tasks (Run Command, Automation, Patch Manager).

**Step 4:** Maintenance window triggers tasks during scheduled time.

---

### 3.6 Quick Setup

**Purpose:**  
Quickly configure Systems Manager features across accounts and regions.

**Use Case:**  
Enable best practice configurations like Patch Manager, Inventory, Run Command in bulk.

**Practical Tutorial:**

**Step 1:** Go to Systems Manager → Quick Setup.

**Step 2:** Select features to enable (Patch Manager, Inventory, etc.).

**Step 3:** Choose target accounts/regions.

**Step 4:** Quick Setup automates deployment of necessary roles and configurations.

---

## 4. Best Practices

- Use **Change Manager** with **Change Calendar** to enforce governance.
    
- Automate routine tasks with **Automation** documents.
    
- Schedule disruptive changes in **Maintenance Windows**.
    
- Use **Quick Setup** for rapid onboarding and standardization.
    
- Ensure proper IAM roles and least privilege.
    
- Monitor all change executions via CloudTrail and Systems Manager logs.
    

---

## 5. Summary Table

|Tool|Purpose|Key Use Case|
|---|---|---|
|Automation|Automate operational tasks|Patch updates, instance reboots, configuration changes|
|Change Calendar|Define allowed/blocked change periods|Block changes on weekends, business hours|
|Change Manager|Manage change lifecycle with approvals|Controlled infrastructure changes|
|Documents|Store commands and runbooks|Automation runbooks, remote commands|
|Maintenance Windows|Schedule maintenance time|Run patches, updates in maintenance hours|
|Quick Setup|Bulk configure SSM features|Rapid environment onboarding|

---

If you'd like, I can prepare detailed CLI commands, example JSON/YAML templates, or Terraform scripts for automating this entire change management setup — just ask!