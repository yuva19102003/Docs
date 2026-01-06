
## 🧠 What Is AWS Cost Explorer?

**AWS Cost Explorer** is a **free built-in AWS tool** that lets you **visualize, analyze, and manage your AWS costs and usage** over time using **interactive graphs, filters, and forecasts**.

> ✅ It helps identify spending trends, anomalies, unused resources, and supports budget planning and cost allocation.

---

## 🎯 Why Use AWS Cost Explorer?

|Benefit|Description|
|---|---|
|✅ **Track costs by service**|EC2, S3, Lambda, RDS, etc.|
|✅ **Forecast future costs**|Up to 12 months using historical trends|
|✅ **Filter and group**|By service, region, tag, usage type, account|
|✅ **Identify savings**|Show underutilized resources and recommendations|
|✅ **Optimize RI/SP usage**|Track Reserved Instances/Savings Plan coverage and utilization|
|✅ **Build custom reports**|Save views based on your filters and granularity|

---

## 📊 What You Can See in Cost Explorer

|View Type|Description|
|---|---|
|**Daily/Monthly Cost Trends**|Breakdown by date and service|
|**Forecasts**|Predict future spend based on past usage|
|**RI/SP Reports**|Coverage and utilization reports for Reserved Instances|
|**Linked Account Breakdown**|For organizations using consolidated billing|
|**Usage Reports**|e.g., EC2 hours, GB storage, API calls|
|**Cost by Tag**|Analyze costs based on user-defined tags|

---

## 🧱 Key Features

### 1. **Service Filtering**

Filter usage and costs by:

- Service (e.g., EC2, Lambda, S3)
    
- Region (e.g., us-east-1)
    
- Usage type (e.g., EC2 running hours)
    
- Linked account
    
- Tags (e.g., Environment=Prod)
    

### 2. **Custom Reports**

You can:

- Save filtered views
    
- Set time ranges (up to last 13 months)
    
- Export to CSV
    

### 3. **Forecasting**

- Cost Explorer uses **machine learning** to project future costs.
    
- Can forecast **monthly spending for up to 12 months.**
    

---

## 📦 Example Use Cases

|Scenario|How Cost Explorer Helps|
|---|---|
|📈 Spending spike detection|Spot sudden increases in cost by service|
|🏷️ Chargeback by team|Use cost allocation tags (e.g., Project, Owner)|
|💸 Idle resource identification|Find low-utilization EC2, EBS, etc.|
|🧮 Planning with Reserved Instances|Analyze RI usage and plan purchases|
|🔍 Analyzing S3 cost growth|Filter by S3 service, region, and storage class|

---

## ⚙️ Cost Explorer Interface Walkthrough

|Section|Description|
|---|---|
|**Dashboard**|Overview with current & forecasted costs|
|**Reports**|Default and custom saved reports|
|**Filters Panel**|Filter by service, tags, accounts, etc.|
|**Grouping Options**|Group by service, tag, usage type|
|**Time Interval**|Choose daily or monthly granularity|
|**RI/SP Utilization**|Reports on coverage and savings|

---

## 🔐 Permissions (IAM)

To allow a user to access Cost Explorer:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:*",
        "aws-portal:ViewBilling",
        "cur:DescribeReportDefinitions"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 🛠️ CLI/SDK Access

You can use **AWS CLI** or **SDKs** to get cost data programmatically.

### Example CLI: Get cost for last 7 days

```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '7 days ago' +%F),End=$(date +%F) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## 📈 Cost Explorer vs. CUR

|Tool|Use Case|
|---|---|
|**Cost Explorer**|Visual reports, dashboards, filtering|
|**Cost and Usage Report (CUR)**|Raw detailed cost data, full granularity, stored in S3|

Use **CUR** for external BI tools or custom processing; use **Cost Explorer** for quick insights and visualization.

---

## 💰 Pricing

|Feature|Cost|
|---|---|
|Cost Explorer UI|✅ Free|
|API Access|Free up to 1M requests/month|
|Forecasting, RI/SP reports|✅ Included|

---

## ✅ TL;DR Summary

|Feature|AWS Cost Explorer|
|---|---|
|Visualization|✅ Yes (charts, tables)|
|Forecasting|✅ 12 months ahead|
|Tags, Services, Regions|✅ Filter and group by|
|Historical Data|✅ 13 months of cost + usage|
|Permissions Required|IAM policy (`ce:*`)|
|Pricing|Free (API & UI)|
|CLI Support|✅ Yes via `aws ce`|

---
