# 3️⃣ Billing & Cost Management

Complete guide to understanding, managing, and optimizing costs in Google Cloud Platform.

---

## 📚 What You'll Learn

Master GCP billing and cost optimization through:

- **Billing Structure**: Understand how GCP charges for services
- **Cost Control**: Set budgets, alerts, and spending limits
- **Optimization**: Reduce costs through best practices and recommendations
- **Analysis**: Track and analyze spending patterns
- **Forecasting**: Predict future costs and plan budgets

---

## 📖 Table of Contents

### [1. Billing Accounts](./1-Billing-Accounts.md)
**Foundation of GCP Billing**

```
Topics Covered:
  • Billing account types
  • Account structure and hierarchy
  • Payment methods and profiles
  • Billing roles and permissions
  • Multiple billing accounts strategy
  • Billing account management
  • Invoicing and payments
```

**Key Concepts:**
- Self-serve vs Invoiced billing
- Billing account to project linkage
- Payment profiles and methods
- Billing IAM roles

---

### [2. Cost Tracking & Reports](./2-Cost-Tracking.md)
**Understanding Your Spending**

```
Topics Covered:
  • Cost breakdown by service
  • Project-level cost analysis
  • SKU-level details
  • Cost trends and patterns
  • Billing reports and exports
  • BigQuery billing analysis
  • Custom cost dashboards
```

**Key Concepts:**
- Cost allocation with labels
- Billing export to BigQuery
- Cost attribution
- Chargeback models

---

### [3. Budgets & Alerts](./3-Budgets-Alerts.md)
**Proactive Cost Control**

```
Topics Covered:
  • Creating budgets
  • Budget scopes (account, project, folder)
  • Alert thresholds
  • Notification channels
  • Programmatic budget management
  • Budget best practices
  • Alert automation
```

**Key Concepts:**
- Budget types (fixed, variable)
- Alert thresholds (50%, 90%, 100%)
- Pub/Sub integration
- Automated responses

---

### [4. Cost Optimization](./4-Cost-Optimization.md)
**Reducing Cloud Spend**

```
Topics Covered:
  • Committed use discounts (CUD)
  • Sustained use discounts (SUD)
  • Preemptible and Spot VMs
  • Right-sizing recommendations
  • Idle resource detection
  • Storage lifecycle policies
  • Network optimization
```

**Key Concepts:**
- Up to 57% savings with CUDs
- Automatic SUDs (up to 30%)
- 91% discount with Spot VMs
- Right-sizing for efficiency

---

### [5. Recommender](./5-Recommender.md)
**AI-Powered Cost Savings**

```
Topics Covered:
  • Cost recommendations
  • Performance recommendations
  • Security recommendations
  • Recommendation types
  • Applying recommendations
  • Recommendation API
  • Custom recommendation workflows
```

**Key Concepts:**
- Idle resource detection
- Underutilized resources
- Commitment recommendations
- Automated optimization

---

### [6. Pricing Models](./6-Pricing-Models.md)
**Understanding GCP Pricing**

```
Topics Covered:
  • Per-second billing
  • Resource-based pricing
  • Network pricing
  • Storage pricing tiers
  • Free tier and credits
  • Pricing calculator
  • Regional price differences
```

**Key Concepts:**
- Pay-as-you-go model
- No upfront costs
- Per-second billing
- Automatic discounts

---

### [7. Cost Allocation](./7-Cost-Allocation.md)
**Tracking and Chargeback**

```
Topics Covered:
  • Labels for cost tracking
  • Project-based allocation
  • Folder-based allocation
  • Department chargeback
  • Cost center mapping
  • Showback vs Chargeback
  • Allocation reports
```

**Key Concepts:**
- Label-based tracking
- Hierarchical allocation
- Chargeback automation
- Cost transparency

---

### [8. Best Practices](./8-Best-Practices.md)
**Enterprise Cost Management**

```
Topics Covered:
  • Cost governance framework
  • FinOps principles
  • Cost optimization culture
  • Regular review processes
  • Automation strategies
  • Multi-cloud cost management
  • Cost optimization checklist
```

---

## 💰 Billing Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP Billing Structure                         │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │  Payment Profile     │
                    │  • Credit card       │
                    │  • Bank account      │
                    │  • Invoice           │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Billing Account     │  ← Billing boundary
                    │  ID: 012345-6789AB   │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
        ┌─────▼─────┐    ┌────▼────┐    ┌─────▼─────┐
        │ Project 1 │    │Project 2│    │ Project 3 │
        │ $5,000/mo │    │$3,000/mo│    │ $2,000/mo │
        └─────┬─────┘    └────┬────┘    └─────┬─────┘
              │               │               │
        ┌─────▼─────┐    ┌───▼────┐    ┌────▼──────┐
        │ Resources │    │Resources│   │ Resources │
        │ • VMs     │    │• Storage│   │ • GKE     │
        │ • Storage │    │• BigQuery│  │ • Cloud   │
        │ • Network │    │• Pub/Sub│   │   SQL     │
        └───────────┘    └─────────┘   └───────────┘

Monthly Total: $10,000
├─ Compute: $4,000 (40%)
├─ Storage: $2,500 (25%)
├─ Networking: $1,500 (15%)
├─ Databases: $1,500 (15%)
└─ Other: $500 (5%)
```

---

## 🎯 Cost Management Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Monthly Cost Management Cycle                                  │
└─────────────────────────────────────────────────────────────────┘

Week 1: Planning & Budgeting
┌─────────────────────────────────┐
│ • Review previous month costs   │
│ • Set budgets for current month │
│ • Configure alerts              │
│ • Plan new resource deployments │
└────────────┬────────────────────┘
             │
             ▼
Week 2: Monitoring & Analysis
┌─────────────────────────────────┐
│ • Daily cost monitoring         │
│ • Check budget alerts           │
│ • Analyze spending trends       │
│ • Identify cost anomalies       │
└────────────┬────────────────────┘
             │
             ▼
Week 3: Optimization
┌─────────────────────────────────┐
│ • Review Recommender insights   │
│ • Apply cost optimizations      │
│ • Right-size resources          │
│ • Clean up idle resources       │
└────────────┬────────────────────┘
             │
             ▼
Week 4: Reporting & Review
┌─────────────────────────────────┐
│ • Generate cost reports         │
│ • Stakeholder review meeting    │
│ • Document savings achieved     │
│ • Plan next month's budget      │
└─────────────────────────────────┘
```

---

## 💡 Key Concepts

### 1. Billing Hierarchy

```
┌────────────────────────────────────────────────────────┐
│  Billing Account Hierarchy                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Organization                                          │
│  └─ Billing Account 1 (Production)                    │
│     ├─ Project A ($5,000/mo)                          │
│     ├─ Project B ($3,000/mo)                          │
│     └─ Project C ($2,000/mo)                          │
│                                                         │
│  └─ Billing Account 2 (Development)                   │
│     ├─ Project D ($500/mo)                            │
│     └─ Project E ($300/mo)                            │
│                                                         │
│  └─ Billing Account 3 (Shared Services)               │
│     └─ Project F ($1,000/mo)                          │
│                                                         │
│  Total: $11,800/month                                 │
└────────────────────────────────────────────────────────┘
```

### 2. Cost Optimization Strategies

```
┌────────────────────────────────────────────────────────┐
│  Cost Optimization Hierarchy                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Level 1: Quick Wins (Immediate)                       │
│  ├─ Delete idle resources                             │
│  ├─ Stop unused VMs                                   │
│  ├─ Delete old snapshots                              │
│  └─ Remove unattached disks                           │
│  Potential Savings: 10-20%                            │
│                                                         │
│  Level 2: Right-Sizing (1-2 weeks)                    │
│  ├─ Downsize over-provisioned VMs                     │
│  ├─ Optimize storage classes                          │
│  ├─ Adjust database tiers                             │
│  └─ Optimize network usage                            │
│  Potential Savings: 20-30%                            │
│                                                         │
│  Level 3: Commitments (1-3 months)                    │
│  ├─ Purchase committed use discounts                  │
│  ├─ Reserve capacity                                  │
│  ├─ Use preemptible/spot VMs                         │
│  └─ Implement autoscaling                             │
│  Potential Savings: 30-50%                            │
│                                                         │
│  Level 4: Architecture (3-6 months)                   │
│  ├─ Migrate to serverless                             │
│  ├─ Implement caching                                 │
│  ├─ Optimize data pipelines                           │
│  └─ Multi-region optimization                         │
│  Potential Savings: 40-60%                            │
└────────────────────────────────────────────────────────┘
```

### 3. Discount Types

```
┌────────────────────────────────────────────────────────┐
│  GCP Discount Programs                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Sustained Use Discounts (SUD)                         │
│  • Automatic (no action required)                      │
│  • Up to 30% discount                                  │
│  • Based on monthly usage                              │
│  • Applies to Compute Engine, GKE                      │
│                                                         │
│  Committed Use Discounts (CUD)                         │
│  • 1-year or 3-year commitment                         │
│  • Up to 57% discount                                  │
│  • Requires upfront commitment                         │
│  • Flexible or resource-based                          │
│                                                         │
│  Preemptible/Spot VMs                                  │
│  • Up to 91% discount                                  │
│  • Can be terminated anytime                           │
│  • Best for batch/fault-tolerant workloads             │
│  • 24-hour maximum runtime                             │
│                                                         │
│  Free Tier                                             │
│  • Always free products                                │
│  • 12-month $300 credit for new users                  │
│  • Monthly free usage limits                           │
│  • No credit card required for trial                   │
└────────────────────────────────────────────────────────┘
```

---

## 📊 Cost Tracking Methods

### 1. Labels

```
Resource Labeling Strategy:

┌─────────────────────────────────────────────────────┐
│  Label Key          │  Label Value                  │
├─────────────────────────────────────────────────────┤
│  environment        │  production, staging, dev     │
│  team               │  backend, frontend, data      │
│  cost-center        │  engineering, marketing       │
│  application        │  web-app, api, analytics      │
│  owner              │  alice, bob, charlie          │
│  project-code       │  proj-001, proj-002           │
│  budget-category    │  compute, storage, network    │
└─────────────────────────────────────────────────────┘

Example VM with labels:
gcloud compute instances create web-vm \
  --labels=environment=production,team=backend,cost-center=engineering
```

### 2. Projects

```
Project-Based Cost Allocation:

Organization
├── Production Projects
│   ├── web-prod ($5,000/mo)
│   ├── api-prod ($3,000/mo)
│   └── data-prod ($2,000/mo)
│
├── Development Projects
│   ├── web-dev ($500/mo)
│   └── api-dev ($300/mo)
│
└── Shared Projects
    └── networking ($1,000/mo)

Total: $11,800/month
```

### 3. Folders

```
Folder-Based Cost Tracking:

Organization
├── Production Folder ($10,000/mo)
│   └── 50 projects
│
├── Development Folder ($2,000/mo)
│   └── 100 projects
│
└── Shared Services Folder ($1,000/mo)
    └── 10 projects

Query costs by folder in BigQuery
```

---

## 🚀 Quick Start Guide

### Step 1: Set Up Billing Account

```bash
# List billing accounts
gcloud billing accounts list

# Link project to billing account
gcloud billing projects link PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID

# Check billing status
gcloud billing projects describe PROJECT_ID
```

### Step 2: Enable Billing Export

```bash
# Export to BigQuery (via Console)
# Navigation: Billing → Billing export → BigQuery export

# Or use API
gcloud billing accounts update BILLING_ACCOUNT_ID \
  --bigquery-dataset=PROJECT_ID.billing_dataset
```

### Step 3: Create Budget

```bash
# Create budget with alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget" \
  --budget-amount=10000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100
```

### Step 4: Apply Labels

```bash
# Label resources for cost tracking
gcloud compute instances update VM_NAME \
  --update-labels=environment=production,team=backend

# Label projects
gcloud projects update PROJECT_ID \
  --update-labels=cost-center=engineering
```

### Step 5: Review Costs

```bash
# View costs in Console
# Navigation: Billing → Reports

# Query costs in BigQuery
bq query --use_legacy_sql=false '
SELECT
  service.description,
  SUM(cost) as total_cost
FROM `project.dataset.gcp_billing_export`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY service.description
ORDER BY total_cost DESC
'
```

---

## 💰 Cost Optimization Checklist

### Immediate Actions (Day 1)

```
✓ Enable billing export to BigQuery
✓ Set up budgets and alerts
✓ Apply labels to all resources
✓ Review current spending
✓ Identify idle resources
✓ Delete unused resources
✓ Stop non-production VMs after hours
```

### Short-Term (Week 1-2)

```
✓ Review Recommender insights
✓ Right-size over-provisioned VMs
✓ Implement storage lifecycle policies
✓ Optimize network usage
✓ Use preemptible VMs for batch jobs
✓ Enable sustained use discounts
✓ Set up cost anomaly alerts
```

### Medium-Term (Month 1-3)

```
✓ Evaluate committed use discounts
✓ Implement autoscaling
✓ Optimize database configurations
✓ Review and optimize data transfer
✓ Implement caching strategies
✓ Consolidate projects
✓ Regular cost review meetings
```

### Long-Term (Quarter 1-2)

```
✓ Architect for cost efficiency
✓ Migrate to serverless where appropriate
✓ Implement FinOps practices
✓ Build cost-aware culture
✓ Automate cost optimization
✓ Multi-cloud cost comparison
✓ Continuous optimization process
```

---

## 📈 Cost Analysis Examples

### Monthly Cost Breakdown

```
┌─────────────────────────────────────────────────────┐
│  March 2026 Cost Report                             │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Total: $10,000                                     │
│                                                      │
│  By Service:                                        │
│  ████████████████░░░░  Compute Engine    $4,000 40%│
│  ██████████░░░░░░░░░░  Cloud Storage     $2,500 25%│
│  ██████░░░░░░░░░░░░░░  Networking        $1,500 15%│
│  ██████░░░░░░░░░░░░░░  Cloud SQL         $1,500 15%│
│  ██░░░░░░░░░░░░░░░░░░  Other             $500   5% │
│                                                      │
│  By Project:                                        │
│  ████████████████░░░░  web-prod          $5,000 50%│
│  ██████████░░░░░░░░░░  api-prod          $3,000 30%│
│  ██████░░░░░░░░░░░░░░  data-prod         $2,000 20%│
│                                                      │
│  Trend: ↑ 15% vs last month                        │
│  Forecast: $11,500 next month                      │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ Tools & Resources

### GCP Native Tools

```
• Cloud Billing Console
• Billing Reports
• Cost Table
• Pricing Calculator
• Recommender
• Billing Export (BigQuery)
• Billing API
• Cloud Monitoring (cost metrics)
```

### Third-Party Tools

```
• CloudHealth by VMware
• Cloudability
• Apptio Cloudability
• Spot.io
• ProsperOps
• Densify
```

### Open Source

```
• Cloud Custodian
• Komiser
• Infracost (IaC cost estimation)
• Kubecost (Kubernetes cost)
```

---

## 📚 Additional Resources

### Documentation
- [GCP Billing Documentation](https://cloud.google.com/billing/docs)
- [Cost Optimization Best Practices](https://cloud.google.com/architecture/cost-optimization)
- [Pricing Calculator](https://cloud.google.com/products/calculator)

### Training
- [Cost Optimization on Google Cloud](https://www.cloudskillsboost.google/course_templates/655)
- [FinOps Foundation](https://www.finops.org/)

### Community
- [GCP Cost Optimization Community](https://www.googlecloudcommunity.com/)
- [r/googlecloud](https://www.reddit.com/r/googlecloud/)

---

## 🎓 Next Steps

After mastering Billing & Cost Management:

1. **IAM & Security** - Secure your resources
2. **Compute Services** - Deploy workloads efficiently
3. **Networking** - Optimize network costs
4. **Storage & Databases** - Choose cost-effective storage
5. **Monitoring & Logging** - Track resource usage

---

**Last Updated:** March 2026
**Version:** 2.0
