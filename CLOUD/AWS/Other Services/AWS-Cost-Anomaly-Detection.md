
## 🧠 What Is AWS Cost Anomaly Detection?

**AWS Cost Anomaly Detection** is a **machine learning–based service** that continuously monitors your AWS cost and usage data and **automatically detects anomalies** (sudden spikes or drops) at the **service, account, or tag** level.

> ✅ It helps you **proactively catch billing surprises**, such as unintended usage, configuration errors, or cost increases.

---

## 🚀 Why Use It?

|Purpose|Benefit|
|---|---|
|🧭 **Early Detection**|Find unexpected cost spikes before monthly invoice|
|📬 **Automatic Notifications**|Alert you via email or SNS on anomaly detection|
|🎯 **Granular Control**|Detect anomalies by service, account, or cost center|
|🔁 **Daily Monitoring**|Automatic, no manual querying|
|📈 **Visualizations**|Integrated with Cost Explorer and Budgets|

---

## 🧱 Core Components

|Component|Description|
|---|---|
|**Monitor**|Defines the scope of anomaly detection (e.g., by linked account, service)|
|**Threshold**|Defines what qualifies as an anomaly (based on historical baseline)|
|**Subscription**|Defines who gets notified (via email or SNS)|
|**Linked Accounts**|Detect anomalies per account (useful for AWS Organizations)|

---

## 🎯 Supported Dimensions for Monitors

You can create a monitor by:

- **Service** (e.g., EC2, S3, Lambda)
    
- **Linked Account** (if using AWS Organizations)
    
- **Linked Account + Service**
    
- **Tag** (e.g., Project, Environment)
    

---

## 🔧 How It Works (Workflow)

1. 📈 **ML model is trained** on past 5 weeks of cost/usage data
    
2. 🚨 **When usage deviates from normal**, an anomaly is flagged
    
3. 📬 **You receive an email/SNS alert** with anomaly details
    
4. 👀 **Investigate the anomaly** in the AWS Console or Cost Explorer
    

---

## 🖥️ Setting It Up (Console Steps)

1. **Go to AWS Cost Anomaly Detection** in the console
    
2. Click **“Create monitor”**
    
3. Choose:
    
    - **Monitor type** (Service, Linked Account, etc.)
        
    - **Name**
        
4. Create a **subscription**:
    
    - Add **email addresses** or **SNS topics** for alerts
        
5. Review and create
    

---

## 💬 Example: Email Alert from Anomaly

You’ll receive something like:

```
Subject: [Anomaly Detected] EC2 cost for Dev account increased by 260%

Details:
Service: AmazonEC2
Timeframe: June 10 – June 11
Expected Cost: $1.25
Actual Cost: $4.50
```

---

## 📦 Terraform (Not yet officially supported directly)

Cost Anomaly Detection **does not yet have native Terraform resource support** as of 2025, but you can use the **AWS SDK** or **CloudFormation custom resources** as a workaround.

---

## 💰 Pricing

|Feature|Cost|
|---|---|
|Creating Monitors|✅ Free|
|Receiving Alerts (Email/SNS)|✅ Free|
|Underlying ML Engine|✅ Free|

> ✅ **AWS Cost Anomaly Detection is entirely free to use.**

---

## ✅ TL;DR Summary

|Feature|AWS Cost Anomaly Detection|
|---|---|
|Goal|Detect and alert on unexpected AWS cost spikes|
|Uses ML?|✅ Yes (based on 5 weeks of historical data)|
|Delivery Methods|Email, SNS|
|Monitor by|Service, Account, Tag|
|Frequency|Daily check, alerts in near real-time|
|Cost|✅ Free|
|Terraform Support|❌ Not yet, but scriptable via SDK|

---
