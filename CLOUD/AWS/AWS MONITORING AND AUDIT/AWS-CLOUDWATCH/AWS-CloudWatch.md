
| Contents                        | Page                                |
| ------------------------------- | ----------------------------------- |
| CloudWatch Logs                 | [CloudWatch Logs](Cloudwatch-logs.md)                 |
| CloudWatch logs for EC2         | [CloudWatch Agents](CloudWatch-Agents.md)               |
| CloudWatch Alarms               | [CloudWatch Alarms](CloudWatch-Alarms.md)               |
| CloudWatch Container insights   | [CloudWatch Container Insights](CloudWatch-Container-Insights.md)   |
| CloudWatch lambda Insights      | [CloudWatch Lambda Insights](CloudWatch-Lambda-Insights.md)      |
| CloudWatch Contributor Insights | [CloudWatch Contributor Insights](CloudWatch-Contributor-Insights.md) |
| CloudWatch Application Insights | [CloudWatch Application Insights](CloudWatch-Application-Insights.md) |

# **What is Amazon CloudWatch?**

Amazon **CloudWatch** is an AWS monitoring service that collects **metrics, logs, and events** from AWS resources and applications. It helps track performance, detect issues, set alerts, and automate responses to ensure system reliability and efficiency. 🚀

---
# **CloudWatch Metrics**
Amazon **CloudWatch Metrics** are **time-series data** that track the performance of AWS resources and applications.
### **CloudWatch Metrics, Dimensions, Custom Metrics & Namespace**

✅ **Metrics (Standard AWS Metrics)**  
**Definition:** Time-series data tracking AWS resource performance.  
**Example:**
- `CPUUtilization` → Monitors CPU usage of an EC2 instance.
- `Latency` → Measures response time in API Gateway.

✅ **Dimensions**  
**Definition:** Key-value pairs to filter/group metrics.  
**Example:**
- `InstanceId=i-123456` → Filters CPU usage for a specific EC2 instance.
- `AutoScalingGroupName=web-servers` → Groups metrics for Auto Scaling.

✅ **Namespace**  
**Definition:** A container for storing related CloudWatch metrics. It helps categorize and isolate different metrics.  
**Example:**
- **AWS/EC2** → Contains EC2 instance metrics (CPU, disk, network).
- **AWS/Lambda** → Stores Lambda function metrics (invocations, duration).
- **Custom/MyApp** → User-defined namespace for application-specific metrics.

✅ **Custom Metrics**  
**Definition:** User-defined metrics for apps or non-AWS resources.  
**Example:**
- `ActiveUsers` → Tracks number of logged-in users.
- `FailedTransactions` → Monitors failed payments.

**How to Send a Custom Metric via AWS CLI:**
```sh
aws cloudwatch put-metric-data --namespace "Custom/MyApp" --metric-name "ActiveUsers" --value 150
```

---
#### **Types of CloudWatch Metrics**
✅ **System Metrics** – CPU, memory, disk, network usage (EC2, RDS, Lambda).  
✅ **Application Metrics** – API requests, response time, error rates (API Gateway, ALB).  
✅ **Security Metrics** – Unauthorized access, failed logins (CloudTrail, GuardDuty).  
✅ **Custom Metrics** – User-defined metrics (via AWS SDK or CloudWatch Agent).
📌 **Granularity:**
- **Basic Monitoring** – 5-minute intervals (default).
- **Detailed Monitoring** – 1-minute intervals (paid).

---
### **CloudWatch Metric Streams & Workflow Explanation**

![CloudWatch Metric Streams](Pasted%20image%2020250211000625.png)
#### **What is CloudWatch Metric Streams?**
CloudWatch Metric Streams is a feature that enables **continuous, near-real-time streaming** of CloudWatch metrics to a destination of your choice with low latency. It helps integrate AWS monitoring data with external analytics services and data lakes.
#### **Workflow Breakdown (Based on Image)**
1. **CloudWatch Metrics:** AWS collects performance data (e.g., CPU, latency).
2. **Kinesis Data Firehose:** Metrics are **filtered and streamed** to Kinesis for further processing.
3. **Destinations:** Kinesis Firehose forwards the data to:
    - **Amazon S3** (For storage, later analysis with Athena).
    - **Amazon Redshift** (For data warehousing and analytics).
    - **Amazon OpenSearch** (For log analysis and visualization).
4. **Third-Party Integrations:** Can send data to **Datadog, Dynatrace, Splunk, New Relic, Sumo Logic**, etc.

This setup ensures efficient metric collection, storage, and analysis for better monitoring and decision-making. 🚀

---
