
| S.no | Service         | Page                 |
| ---- | --------------- | -------------------- |
| 1    | AWS CloudWatch  | [AWS CloudWatch](AWS-CLOUDWATCH/AWS-CloudWatch.md)   |
| 2    | AWS CloudTrail  | [AWS CloudTrail](AWS%20CLOUDTRAIL/AWS%20CloudTrail.md)   |
| 3    | AWS Config      | [AWS Config](AWS%20CONFIG/AWS-Config.md)       |
| 4    | AWS EventBridge | [AWS EventBridge](AWS%20EVENT%20BRIDGE/AWS-EVENT-BRIGDE.md) |

### **Monitoring vs. Audit (with AWS Services & Key Metrics)**  

### **1. Monitoring**  
**Definition:** Monitoring is the real-time tracking of system health, performance, and security to detect issues and optimize operations.  

**Purpose:**  
- Ensure availability and performance of applications and infrastructure.  
- Detect failures or performance bottlenecks.  
- Provide insights for auto-scaling and optimization.  

**AWS Services for Monitoring:**  
- **Amazon CloudWatch** – Collects metrics, logs, and sets alerts.  
- **AWS X-Ray** – Traces application requests to detect latency issues.  
- **Amazon CloudWatch Logs** – Stores and analyzes log data.  

---

### **2. Audit**  
**Definition:** Auditing is the periodic review of logs, configurations, and access history to ensure compliance, security, and accountability.  

**Purpose:**  
- Maintain compliance with industry regulations (e.g., GDPR, HIPAA).  
- Track changes in AWS resources.  
- Investigate security incidents and unauthorized access.  

**AWS Services for Audit:**  
- **AWS CloudTrail** – Logs all API actions in AWS for security analysis.  
- **AWS Config** – Monitors changes in AWS resources and ensures compliance.  
- **Amazon GuardDuty** – Uses AI to detect security threats.  

---

### **Key Metrics & AWS Services**  

| **Metric Type**      | **Key Metrics** | **AWS Service** |
|----------------------|----------------|-----------------|
| **System Metrics**  | CPU, Memory, Disk, Network | CloudWatch |
| **Application**  | Response Time, Errors, Throughput | X-Ray, CloudWatch Logs |
| **Security** | Failed Logins, Intrusions, Firewall Logs | CloudTrail, GuardDuty |
| **Compliance** | Resource Changes, Policy Violations | AWS Config |
| **Business** | Revenue, Churn Rate, API Usage | AWS Cost Explorer, CloudWatch |

Both **monitoring** and **auditing** are essential for maintaining a secure, efficient, and compliant cloud environment. Let me know if you need guidance on setting up these AWS services! 🚀

---

