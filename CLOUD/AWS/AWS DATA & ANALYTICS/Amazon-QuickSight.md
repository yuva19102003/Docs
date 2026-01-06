
## 🧠 What is Amazon QuickSight?

**Amazon QuickSight** is a **serverless Business Intelligence (BI) service** that allows you to visualize your data and derive actionable insights from it via **interactive dashboards**, **ad-hoc analysis**, and **ML-powered insights**.

> ✅ Unlike traditional BI tools, it’s **cloud-native**, **scalable**, **pay-per-use**, and directly integrates with AWS data sources.

---

## 📊 Core Use Cases

|Use Case|Why Use QuickSight?|
|---|---|
|📈 Executive Dashboards|Visualize KPIs in real-time from data lakes or warehouses|
|🧪 Data Exploration|Drill-down, filter, and pivot AWS data with ease|
|🔄 Cost Monitoring|Visualize AWS Cost & Usage Reports via Athena/S3|
|🔍 Log Analytics|Build dashboards on CloudTrail, VPC logs, etc.|
|🛠️ Embedded Analytics|Embed dashboards in your own apps using QuickSight API|

---

## 🧱 How It Works

```
       [S3]    [RDS]   [Redshift]   [Athena]   [Salesforce] ...
         ↓        ↓        ↓           ↓            ↓
      ┌───────────────────────────────────────────────┐
      │          Amazon QuickSight SPICE Engine       │
      │    (Super-fast, Parallel, In-memory Calculation) │
      └───────────────────────────────────────────────┘
                              ↓
               Dashboards, Reports, ML Insights
```

### Data Sources

- Amazon S3
    
- Amazon Redshift
    
- Amazon Athena
    
- RDS / Aurora
    
- Snowflake, Salesforce, MySQL, PostgreSQL, and more
    

---

## 🚀 Key Features

|Feature|Description|
|---|---|
|**SPICE Engine**|In-memory caching engine for fast and interactive analytics|
|**ML Insights**|Forecasting, anomaly detection, and narrative summaries using ML|
|**Interactive Dashboards**|Real-time filtering, drill-down, pivoting|
|**Scheduled Reports**|Send reports via email on schedule|
|**Embedded Analytics**|Embed dashboards into web apps with Row-level security|
|**Row-level Security (RLS)**|Show filtered data per user group|
|**Natural Language Querying**|Ask Q (ex: “sales last quarter”)|

---

## 🛡️ Security & Governance

|Security Feature|Description|
|---|---|
|**IAM Integration**|Fine-grained access to data sources|
|**RLS (Row-Level Security)**|Enforce user-specific data visibility|
|**Private VPC Access**|Access RDS or Redshift in private subnets|
|**Encryption at Rest**|KMS integration for dashboards and SPICE|
|**Audit Logging**|CloudTrail logs for dashboard activity and API usage|

---

## 💸 Pricing (2024)

### Two Modes:

|Mode|Pricing|
|---|---|
|**Standard**|$9/user/month (provisioned users only)|
|**Enterprise**|$18/user/month + $0.30/session for readers|
|**SPICE Storage**|$0.25 per GB/month (first 10 GB/user is free)|

🧠 **Tip**: Use **Reader Mode** with **pay-per-session** for large orgs with many consumers.

---

## 🧰 Terraform Integration (via `aws_quicksight_*` resources)

Here's a **Terraform snippet** to set up QuickSight access and a data source using Athena.

### 1. Enable QuickSight and Identity Federation

```hcl
resource "aws_quicksight_user" "admin" {
  user_name     = "quicksight-admin"
  email         = "admin@example.com"
  identity_type = "IAM"
  user_role     = "ADMIN"
  aws_account_id = data.aws_caller_identity.current.account_id
}
```

---

### 2. Create a Data Source (Athena Example)

```hcl
resource "aws_quicksight_data_source" "athena" {
  data_source_id = "athena-ds"
  name           = "athena-ds"
  type           = "ATHENA"

  aws_account_id = data.aws_caller_identity.current.account_id

  parameters {
    athena {
      work_group = "primary"
    }
  }

  permissions {
    principal = "arn:aws:quicksight:us-east-1:${data.aws_caller_identity.current.account_id}:user/default/quicksight-admin"

    actions = [
      "quicksight:DescribeDataSource",
      "quicksight:DescribeDataSourcePermissions",
      "quicksight:PassDataSource",
      "quicksight:UpdateDataSource",
      "quicksight:DeleteDataSource"
    ]
  }
}
```

---

## 🔄 Integrations

|Source|Supported?|
|---|---|
|**S3 via Athena/Glue**|✅|
|**RDS (MySQL, PostgreSQL)**|✅|
|**Amazon Redshift**|✅|
|**Salesforce**|✅|
|**Snowflake, Teradata**|✅|
|**JDBC/ODBC**|✅|

---

## 🧪 Best Practices

|Tip|Why It's Important|
|---|---|
|Use SPICE|Reduces latency and cost (offloads from data source)|
|Define RLS|Enforce data isolation by user/team|
|Enable CloudTrail|Track access and changes to dashboards|
|Use Embedding API|Add dashboards inside your app with access control|
|Use Athena for S3 log analytics|Fast ad-hoc queries from S3 stored logs|

---

## ✅ TL;DR Summary

|Feature|Amazon QuickSight|
|---|---|
|Serverless BI|✅ Yes|
|Cost Model|Per user/month + optional per session|
|SPICE Engine|Fast in-memory analytics engine|
|Security|IAM, VPC, RLS, KMS|
|Embeddable|✅ Yes (for apps and portals)|
|Integration|Athena, S3, RDS, Redshift, external DBs|
|Terraform Support|✅ (Partial but growing)|

---

## 🎯 When to Use QuickSight?

- Need **real-time dashboards** over Athena or Redshift
    
- Want a **cloud-native alternative** to Tableau/Power BI
    
- Need **embedded dashboards** in a SaaS product
    
- Have large teams needing **pay-per-session** access
    

---
