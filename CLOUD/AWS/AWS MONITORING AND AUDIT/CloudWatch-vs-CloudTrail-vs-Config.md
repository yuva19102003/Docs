
## 📊 **Amazon CloudWatch** – _"Monitoring and metrics"_

| Feature            | Description                                    |
| ------------------ | ---------------------------------------------- |
| **Purpose**        | Real-time monitoring of AWS resources and apps |
| **What it tracks** | Metrics (CPU, RAM, etc.), logs, alarms, events |
| **Use cases**      | Monitor EC2 health, set alarms, visualize logs |
| **Data type**      | Operational data (numbers, logs, dashboards)   |
| **Example**        | Create an alarm if EC2 CPU > 80% for 5 minutes |

### ✅ Use CloudWatch for:

- Infrastructure & application monitoring
    
- Centralized logging (via CloudWatch Logs)
    
- Creating custom dashboards & alerts
    

---

## 📜 **AWS CloudTrail** – _"Who did what?"_

| Feature            | Description                                           |
| ------------------ | ----------------------------------------------------- |
| **Purpose**        | Audit & track API activity (user and service actions) |
| **What it tracks** | API calls via AWS CLI, SDKs, Console                  |
| **Use cases**      | Security audits, forensics, compliance                |
| **Data type**      | Event logs (JSON) showing _who_ made _what_ request   |
| **Example**        | See if someone deleted an S3 bucket, and from where   |

### ✅ Use CloudTrail for:

- Tracking **user and service actions**
    
- Detecting **unauthorized access**
    
- Logging **API call history**
    

---

## 🧾 **AWS Config** – _"What is the state of my resources?"_

| Feature            | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| **Purpose**        | Tracks configuration history and compliance of AWS resources |
| **What it tracks** | State/configuration of AWS resources over time               |
| **Use cases**      | Compliance audits, change detection, config snapshots        |
| **Data type**      | Snapshots of resource state/config, compliance reports       |
| **Example**        | Detect if an S3 bucket becomes publicly readable             |

### ✅ Use AWS Config for:

- Tracking **resource config changes** over time
    
- Creating **compliance rules** (e.g., all EBS must be encrypted)
    
- Auditing configuration drift
    

---

## 🧠 Summary Table

| Feature        | CloudWatch             | CloudTrail                            | AWS Config                             |
| -------------- | ---------------------- | ------------------------------------- | -------------------------------------- |
| **Purpose**    | Monitoring & metrics   | Audit API calls                       | Resource config history & compliance   |
| **Monitors**   | Metrics, logs, alarms  | API activity (who, what, when, where) | Resource states (how it's configured)  |
| **Stores**     | Metrics, logs          | Event logs (JSON)                     | Resource snapshots & compliance states |
| **Real-time?** | Yes                    | Near real-time                        | Not real-time (event-based changes)    |
| **Example**    | Alert if EC2 CPU > 80% | See who deleted an RDS instance       | Detect public S3 buckets               |

---

## 🧩 Can They Work Together?

Yes! Here's a simple workflow:

- **CloudTrail** logs _who_ changed something.
    
- **AWS Config** shows _what_ changed in resource configuration.
    
- **CloudWatch** triggers alarms if metrics hit thresholds after the change.
    

---
