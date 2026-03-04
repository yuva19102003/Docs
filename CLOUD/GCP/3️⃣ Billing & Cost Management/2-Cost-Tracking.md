# 2. Cost Tracking & Reports

Understanding where your money goes is the first step to optimizing cloud costs.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Cost Tracking Methods                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. Billing Reports (Console)                          │
│     • Visual dashboards                                │
│     • Interactive charts                               │
│     • Drill-down capabilities                          │
│                                                         │
│  2. Cost Table (Console)                               │
│     • Detailed cost breakdown                          │
│     • Filterable and sortable                          │
│     • Export to CSV                                    │
│                                                         │
│  3. BigQuery Export                                    │
│     • Complete billing data                            │
│     • SQL queries for analysis                         │
│     • Custom reports and dashboards                    │
│                                                         │
│  4. Billing API                                        │
│     • Programmatic access                              │
│     • Custom integrations                              │
│     • Automated reporting                              │
└────────────────────────────────────────────────────────┘
```

---

## Billing Reports

### Accessing Reports

```
Console Navigation:
  Billing → Reports

Features:
  • Time range selection (day, week, month, custom)
  • Group by: Project, Service, SKU, Location, Label
  • Filter by: Project, Service, Label, Location
  • Chart types: Line, stacked area, bar
  • Download as CSV or PNG
```

### Report Views

```
┌────────────────────────────────────────────────────────┐
│  Cost by Service (March 2026)                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine        ████████████████░░  $4,000  40% │
│  Cloud Storage         ██████████░░░░░░░░  $2,500  25% │
│  Networking            ██████░░░░░░░░░░░░  $1,500  15% │
│  Cloud SQL             ██████░░░░░░░░░░░░  $1,500  15% │
│  BigQuery              ██░░░░░░░░░░░░░░░░  $  300   3% │
│  Other                 ██░░░░░░░░░░░░░░░░  $  200   2% │
│                                                         │
│  Total: $10,000                                        │
│  Trend: ↑ 15% vs last month                           │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Cost by Project                                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  web-prod              ████████████████░░  $5,000  50% │
│  api-prod              ██████████░░░░░░░░  $3,000  30% │
│  data-prod             ██████░░░░░░░░░░░░  $2,000  20% │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Cost Trend (Last 6 Months)                            │
├────────────────────────────────────────────────────────┤
│                                                         │
│  $12k │                                          ╱     │
│       │                                      ╱╲╱      │
│  $10k │                                  ╱╲╱          │
│       │                              ╱╲╱              │
│   $8k │                          ╱╲╱                  │
│       │                      ╱╲╱                      │
│   $6k │                  ╱╲╱                          │
│       │              ╱╲╱                              │
│   $4k │          ╱╲╱                                  │
│       │      ╱╲╱                                      │
│   $2k │  ╱╲╱                                          │
│       └────────────────────────────────────────────   │
│        Oct  Nov  Dec  Jan  Feb  Mar                   │
│                                                         │
│  Average: $8,500/month                                │
│  Forecast: $11,500 next month                         │
└────────────────────────────────────────────────────────┘
```

---

## Cost Table

### Detailed Cost Breakdown

```
Console Navigation:
  Billing → Cost table

Columns:
  • Project
  • Service
  • SKU
  • Location
  • Cost
  • Usage amount
  • Usage unit
  • Credits
  • Labels

Filters:
  • Time range
  • Projects
  • Services
  • Locations
  • Labels
  • Cost > threshold
```

### Example Cost Table

```
┌──────────────────────────────────────────────────────────────────┐
│  Cost Table - March 2026                                         │
├──────────────────────────────────────────────────────────────────┤
│ Project   │ Service    │ SKU              │ Location │ Cost     │
├──────────────────────────────────────────────────────────────────┤
│ web-prod  │ Compute    │ N1 Standard 4    │ us-c1    │ $1,200   │
│ web-prod  │ Compute    │ Persistent Disk  │ us-c1    │ $  300   │
│ web-prod  │ Storage    │ Standard Storage │ us       │ $  800   │
│ web-prod  │ Networking │ Egress           │ us       │ $  500   │
│ api-prod  │ Compute    │ N1 Standard 2    │ us-c1    │ $  600   │
│ api-prod  │ Cloud SQL  │ PostgreSQL HA    │ us-c1    │ $1,200   │
│ data-prod │ BigQuery   │ On-demand        │ us       │ $  800   │
│ data-prod │ Storage    │ Nearline         │ us       │ $  400   │
└──────────────────────────────────────────────────────────────────┘

Export Options:
  • CSV
  • JSON
  • BigQuery
```

---

## BigQuery Billing Export

### Setup Billing Export

```bash
# 1. Create BigQuery dataset
bq mk --dataset \
  --location=US \
  --description="Billing export dataset" \
  PROJECT_ID:billing_export

# 2. Enable billing export (via Console)
# Navigation: Billing → Billing export → BigQuery export
# - Select billing account
# - Choose project and dataset
# - Enable standard or detailed export

# 3. Verify export
bq ls --project_id=PROJECT_ID billing_export

# Tables created:
# - gcp_billing_export_v1_BILLING_ACCOUNT_ID (standard)
# - gcp_billing_export_resource_v1_BILLING_ACCOUNT_ID (detailed)
```

### Standard vs Detailed Export

```
┌────────────────────────────────────────────────────────┐
│  Standard Export                                       │
├────────────────────────────────────────────────────────┤
│  • Daily cost data                                     │
│  • Service-level details                               │
│  • Project-level breakdown                             │
│  • SKU information                                     │
│  • Location data                                       │
│  • Labels                                              │
│  • Smaller data size                                   │
│  • Recommended for most users                          │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Detailed Export (Resource-Level)                      │
├────────────────────────────────────────────────────────┤
│  • All standard export data                            │
│  • Individual resource IDs                             │
│  • Resource-level usage                                │
│  • System labels                                       │
│  • Larger data size                                    │
│  • More granular analysis                              │
│  • Higher BigQuery costs                               │
└────────────────────────────────────────────────────────┘
```

---

## BigQuery Cost Analysis

### Basic Queries

```sql
-- Total cost by service (last 30 days)
SELECT
  service.description AS service,
  SUM(cost) AS total_cost,
  SUM(IFNULL((SELECT SUM(c.amount)
              FROM UNNEST(credits) c), 0)) AS total_credits
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service
ORDER BY total_cost DESC;

-- Cost by project
SELECT
  project.name AS project,
  SUM(cost) AS total_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY project
ORDER BY total_cost DESC;

-- Daily cost trend
SELECT
  DATE(usage_start_time) AS date,
  SUM(cost) AS daily_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY date
ORDER BY date;

-- Cost by location
SELECT
  location.location AS location,
  service.description AS service,
  SUM(cost) AS total_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND location.location IS NOT NULL
GROUP BY location, service
ORDER BY total_cost DESC;
```

### Advanced Queries

```sql
-- Cost by label (environment)
SELECT
  label.value AS environment,
  SUM(cost) AS total_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`,
UNNEST(labels) AS label
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND label.key = 'environment'
GROUP BY environment
ORDER BY total_cost DESC;

-- Top 10 most expensive SKUs
SELECT
  service.description AS service,
  sku.description AS sku,
  SUM(cost) AS total_cost,
  SUM(usage.amount) AS total_usage,
  usage.unit AS unit
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service, sku, unit
ORDER BY total_cost DESC
LIMIT 10;

-- Month-over-month cost comparison
WITH monthly_costs AS (
  SELECT
    FORMAT_DATE('%Y-%m', DATE(usage_start_time)) AS month,
    SUM(cost) AS total_cost
  FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
  WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY month
)
SELECT
  month,
  total_cost,
  LAG(total_cost) OVER (ORDER BY month) AS previous_month_cost,
  total_cost - LAG(total_cost) OVER (ORDER BY month) AS cost_change,
  ROUND((total_cost - LAG(total_cost) OVER (ORDER BY month)) / 
        LAG(total_cost) OVER (ORDER BY month) * 100, 2) AS percent_change
FROM monthly_costs
ORDER BY month DESC;

-- Cost anomaly detection (>20% increase)
WITH daily_costs AS (
  SELECT
    DATE(usage_start_time) AS date,
    project.name AS project,
    SUM(cost) AS daily_cost
  FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
  WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY date, project
)
SELECT
  date,
  project,
  daily_cost,
  AVG(daily_cost) OVER (
    PARTITION BY project 
    ORDER BY date 
    ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
  ) AS avg_previous_7_days,
  daily_cost - AVG(daily_cost) OVER (
    PARTITION BY project 
    ORDER BY date 
    ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
  ) AS cost_difference
FROM daily_costs
WHERE daily_cost > 1.2 * AVG(daily_cost) OVER (
    PARTITION BY project 
    ORDER BY date 
    ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
  )
ORDER BY date DESC, cost_difference DESC;
```

---

## Cost Attribution with Labels

### Labeling Strategy

```
┌────────────────────────────────────────────────────────┐
│  Recommended Label Keys                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  environment     → production, staging, development    │
│  team            → backend, frontend, data, devops     │
│  cost-center     → engineering, marketing, sales       │
│  application     → web-app, mobile-app, api            │
│  owner           → alice, bob, charlie                 │
│  project-code    → proj-001, proj-002                  │
│  budget-category → compute, storage, network           │
│  compliance      → pci, hipaa, sox                     │
│  lifecycle       → temporary, permanent                │
│  backup          → daily, weekly, none                 │
└────────────────────────────────────────────────────────┘
```

### Apply Labels

```bash
# Label VM
gcloud compute instances update VM_NAME \
  --zone=ZONE \
  --update-labels=environment=production,team=backend,cost-center=engineering

# Label project
gcloud projects update PROJECT_ID \
  --update-labels=environment=production,cost-center=engineering

# Label storage bucket
gsutil label ch -l environment:production gs://BUCKET_NAME

# Label Cloud SQL
gcloud sql instances patch INSTANCE_NAME \
  --labels=environment=production,team=data
```

### Query Costs by Labels

```sql
-- Cost by environment label
SELECT
  label.value AS environment,
  SUM(cost) AS total_cost,
  COUNT(DISTINCT project.id) AS num_projects
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`,
UNNEST(labels) AS label
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND label.key = 'environment'
GROUP BY environment
ORDER BY total_cost DESC;

-- Cost by team and cost-center
SELECT
  team.value AS team,
  cost_center.value AS cost_center,
  SUM(cost) AS total_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`,
UNNEST(labels) AS team,
UNNEST(labels) AS cost_center
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND team.key = 'team'
  AND cost_center.key = 'cost-center'
GROUP BY team, cost_center
ORDER BY total_cost DESC;

-- Resources without required labels
SELECT
  project.name AS project,
  service.description AS service,
  SUM(cost) AS total_cost
FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND NOT EXISTS (
    SELECT 1 FROM UNNEST(labels) AS label 
    WHERE label.key = 'environment'
  )
GROUP BY project, service
HAVING total_cost > 100
ORDER BY total_cost DESC;
```

---

## Custom Dashboards

### Data Studio Dashboard

```
1. Create Data Studio report
   https://datastudio.google.com

2. Add BigQuery data source
   - Connect to billing export table
   - Configure data freshness

3. Create visualizations:
   - Time series: Daily cost trend
   - Pie chart: Cost by service
   - Bar chart: Cost by project
   - Table: Top 10 expensive resources
   - Scorecard: Total monthly cost
   - Scorecard: Month-over-month change

4. Add filters:
   - Date range
   - Project
   - Service
   - Environment label

5. Share with stakeholders
```

### Looker Studio Example

```
Dashboard Layout:

┌─────────────────────────────────────────────────────────┐
│  Cloud Cost Dashboard - March 2026                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Total Cost   │  │ vs Last Month│  │ Forecast     │ │
│  │ $10,000      │  │ +15%         │  │ $11,500      │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐│
│  │  Cost Trend (Last 90 Days)                         ││
│  │  [Line chart showing daily costs]                  ││
│  └────────────────────────────────────────────────────┘│
│                                                          │
│  ┌──────────────────────┐  ┌──────────────────────────┐│
│  │ Cost by Service      │  │ Cost by Project          ││
│  │ [Pie chart]          │  │ [Bar chart]              ││
│  └──────────────────────┘  └──────────────────────────┘│
│                                                          │
│  ┌────────────────────────────────────────────────────┐│
│  │  Top 10 Expensive Resources                        ││
│  │  [Table with project, service, cost]               ││
│  └────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

## Cost Forecasting

### Forecast Query

```sql
-- Simple linear forecast (next 30 days)
WITH daily_costs AS (
  SELECT
    DATE(usage_start_time) AS date,
    SUM(cost) AS daily_cost
  FROM `project.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
  WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  GROUP BY date
),
trend AS (
  SELECT
    AVG(daily_cost) AS avg_daily_cost,
    STDDEV(daily_cost) AS stddev_daily_cost
  FROM daily_costs
)
SELECT
  avg_daily_cost * 30 AS forecasted_monthly_cost,
  (avg_daily_cost + stddev_daily_cost) * 30 AS high_estimate,
  (avg_daily_cost - stddev_daily_cost) * 30 AS low_estimate
FROM trend;
```

---

## Best Practices

```
✓ Enable billing export to BigQuery immediately
✓ Apply labels to all resources consistently
✓ Review costs weekly
✓ Set up automated cost reports
✓ Create custom dashboards for stakeholders
✓ Monitor cost trends and anomalies
✓ Document labeling conventions
✓ Regular label compliance audits
✓ Export historical data for analysis
✓ Use forecasting for budget planning
```

---

## Next Steps

- **Budgets & Alerts** → [3-Budgets-Alerts.md](./3-Budgets-Alerts.md)
- **Cost Optimization** → [4-Cost-Optimization.md](./4-Cost-Optimization.md)
- **Recommender** → [5-Recommender.md](./5-Recommender.md)

---
