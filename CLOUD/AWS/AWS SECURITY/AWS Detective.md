
## Table of Contents

1. Overview
    
2. Key Features
    
3. Prerequisites
    
4. Setting Up AWS Detective
    
5. Using AWS Detective for Security Investigations
    
6. Integrations with Other AWS Services
    
7. Best Practices
    
8. Summary
    

---

## 1. Overview

**AWS Detective** is a fully managed security service that helps you **investigate, analyze, and quickly identify the root cause of potential security issues or suspicious activities** across your AWS workloads. It automatically collects and processes logs from AWS CloudTrail, VPC Flow Logs, and Amazon GuardDuty findings, organizing data into a **graph model** that reveals relationships and patterns.

---

## 2. Key Features

- Automated data aggregation from CloudTrail, GuardDuty, and VPC Flow Logs.
    
- Visualizations of resource interactions and account activities.
    
- Fast, intuitive investigation workflows with context.
    
- Integration with GuardDuty for streamlined alert triage.
    
- No need to set up or manage infrastructure for data collection or analysis.
    

---

## 3. Prerequisites

- AWS account with Detective service enabled.
    
- AWS GuardDuty enabled and configured (Detective uses GuardDuty findings).
    
- Necessary IAM permissions to access Detective (e.g., `AmazonDetectiveFullAccess`).
    
- Logs from CloudTrail and VPC Flow Logs enabled for your AWS environment.
    

---

## 4. Setting Up AWS Detective

### Step 1: Enable AWS Detective

- Go to AWS Management Console → AWS Detective.
    
- Click **Get started** and enable Detective for your AWS account.
    

### Step 2: Enable GuardDuty (if not already)

- AWS Console → GuardDuty → Enable GuardDuty.
    
- Configure data sources like CloudTrail and VPC Flow Logs.
    

### Step 3: Invite other AWS accounts (optional)

- You can invite member accounts in an AWS Organization to share findings and investigations.
    

---

## 5. Using AWS Detective for Security Investigations

### Step 1: Access Detective Console

- Open Detective in the AWS Console.
    
- Select the **Graphs** tab, which shows interactive graphs for your AWS environment.
    

### Step 2: Investigate GuardDuty Findings

- From GuardDuty console, click on a finding → Choose **Investigate in Detective**.
    
- Detective opens a graph centered on the resource or entity involved in the finding.
    

### Step 3: Analyze Entity Behavior

- Explore timelines of activity for AWS resources (IAM users, EC2 instances, IP addresses).
    
- View relationships like API calls, network traffic, resource usage patterns.
    
- Detect anomalies or suspicious behavior by visual correlation.
    

### Step 4: Use Search and Filters

- Search entities by name, IP address, or resource ID.
    
- Filter activity by time window or type (network, API, authentication).
    

---

## 6. Integrations with Other AWS Services

- **Amazon GuardDuty:** Detective automatically processes GuardDuty findings for detailed investigation.
    
- **AWS CloudTrail:** Detective ingests CloudTrail logs to build activity graphs.
    
- **VPC Flow Logs:** Helps visualize network traffic between resources.
    
- **AWS Security Hub:** Findings can be routed for centralized management, with links to Detective for investigations.
    

---

## 7. Best Practices

- Regularly review GuardDuty findings and investigate with Detective.
    
- Enable CloudTrail across all AWS regions for complete data.
    
- Use multi-account setup with Detective for centralized security investigations.
    
- Train your security team on interpreting Detective graphs and workflows.
    
- Automate notifications for GuardDuty findings to trigger timely investigations.
    

---

## 8. Summary Table

|Feature|Description|Use Case|
|---|---|---|
|Automated Data Aggregation|Combines CloudTrail, VPC Flow Logs, GuardDuty|Centralized, correlated security data|
|Visual Interactive Graphs|Visualize relationships and resource activity|Quickly understand root causes|
|GuardDuty Integration|Direct links from findings to investigation|Streamlined alert triage|
|Multi-account Support|Invite member accounts|Centralized cross-account investigation|
|No Infrastructure Management|Fully managed, no setup for data collection|Easy to deploy and scale|

---
