# 1. Billing Accounts

A **Billing Account** is a cloud-level resource that defines who pays for a given set of GCP resources.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Billing Account Characteristics                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose:                                              │
│  • Payment method container                            │
│  • Links to one or more projects                       │
│  • Tracks charges and usage                            │
│  • Manages payment profiles                            │
│                                                         │
│  Types:                                                │
│  • Self-serve (credit card, bank account)              │
│  • Invoiced (monthly invoicing)                        │
│                                                         │
│  Structure:                                            │
│  • Billing Account ID: 012345-6789AB-CDEF01           │
│  • Display Name: Production Billing                    │
│  • Currency: USD, EUR, GBP, etc.                       │
│  • Payment Profile: Linked payment method              │
└────────────────────────────────────────────────────────┘
```

---

## Billing Account Types

### 1. Self-Serve Billing Account

```
┌────────────────────────────────────────────────────────┐
│  Self-Serve Billing Account                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Payment Methods:                                      │
│  • Credit card (Visa, Mastercard, Amex)                │
│  • Debit card                                          │
│  • Bank account (ACH in US)                            │
│                                                         │
│  Billing Cycle:                                        │
│  • Automatic monthly charging                          │
│  • Charges when threshold reached ($1,000 default)     │
│  • Or on 1st of month                                  │
│                                                         │
│  Best For:                                             │
│  • Small to medium businesses                          │
│  • Startups                                            │
│  • Individual developers                               │
│  • Monthly spend < $50,000                             │
│                                                         │
│  Features:                                             │
│  • Instant setup                                       │
│  • No minimum commitment                               │
│  • Pay-as-you-go                                       │
│  • Online payment management                           │
└────────────────────────────────────────────────────────┘
```

### 2. Invoiced Billing Account

```
┌────────────────────────────────────────────────────────┐
│  Invoiced Billing Account                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Payment Methods:                                      │
│  • Wire transfer                                       │
│  • Check                                               │
│  • ACH                                                 │
│                                                         │
│  Billing Cycle:                                        │
│  • Monthly invoicing                                   │
│  • Net 30 payment terms (typically)                    │
│  • Consolidated billing                                │
│                                                         │
│  Requirements:                                         │
│  • Credit check required                               │
│  • Minimum spend commitment                            │
│  • Contract with Google                                │
│  • Enterprise agreement                                │
│                                                         │
│  Best For:                                             │
│  • Large enterprises                                   │
│  • Monthly spend > $50,000                             │
│  • Organizations requiring invoicing                   │
│  • Companies with procurement processes                │
│                                                         │
│  Features:                                             │
│  • Dedicated support                                   │
│  • Custom payment terms                                │
│  • Volume discounts                                    │
│  • Consolidated invoicing                              │
└────────────────────────────────────────────────────────┘
```

---

## Billing Account Structure

### Single Billing Account

```
┌────────────────────────────────────────────────────────┐
│  Simple Structure (Small Organization)                 │
└────────────────────────────────────────────────────────┘

Payment Profile
      │
      ▼
┌─────────────────┐
│ Billing Account │
│ ID: 012345-ABC  │
└────────┬────────┘
         │
    ┌────┼────┬────┬────┐
    │    │    │    │    │
┌───▼┐ ┌─▼─┐ ┌▼──┐ ┌▼──┐ ┌▼──┐
│Proj│ │Proj│ │Proj│ │Proj│ │Proj│
│ 1  │ │ 2  │ │ 3  │ │ 4  │ │ 5  │
└────┘ └───┘ └───┘ └───┘ └───┘

Benefits:
  ✓ Simple management
  ✓ Single invoice
  ✓ Consolidated billing
  ✓ Easy cost tracking

Drawbacks:
  ✗ No cost separation
  ✗ Single payment method
  ✗ All projects share limits
```

### Multiple Billing Accounts

```
┌────────────────────────────────────────────────────────┐
│  Multi-Account Structure (Enterprise)                  │
└────────────────────────────────────────────────────────┘

Organization
      │
      ├─────────────────┬─────────────────┬──────────────┐
      │                 │                 │              │
┌─────▼──────┐    ┌────▼─────┐    ┌─────▼──────┐  ┌───▼────┐
│  Billing   │    │ Billing  │    │  Billing   │  │Billing │
│  Account 1 │    │ Account 2│    │  Account 3 │  │Account4│
│ Production │    │   Dev    │    │   Shared   │  │ Partner│
└─────┬──────┘    └────┬─────┘    └─────┬──────┘  └───┬────┘
      │                │                 │             │
  ┌───┼───┐        ┌───┼───┐         ┌──┼──┐       ┌──┼──┐
  │   │   │        │   │   │         │  │  │       │  │  │
Proj Proj Proj   Proj Proj Proj    Proj Proj    Proj Proj
 1   2   3        4   5   6         7   8        9   10

Benefits:
  ✓ Cost separation by environment
  ✓ Different payment methods
  ✓ Separate budgets and limits
  ✓ Chargeback to departments
  ✓ Risk isolation

Use Cases:
  • Production vs Non-Production
  • Department separation
  • Customer/Partner isolation
  • Geographic separation
```

---

## Creating Billing Accounts

### Via Console

```
1. Navigate to: Billing → Manage billing accounts
2. Click: CREATE ACCOUNT
3. Enter:
   - Account name: "Production Billing"
   - Country: United States
   - Currency: USD
4. Add payment method:
   - Credit card or bank account
5. Accept terms and conditions
6. Click: CREATE

Account created with ID: 012345-6789AB-CDEF01
```

### Via gcloud

```bash
# List billing accounts
gcloud billing accounts list

# Get billing account details
gcloud billing accounts describe BILLING_ACCOUNT_ID

# Note: Cannot create billing accounts via gcloud
# Must use Console or Billing API
```

---

## Linking Projects to Billing Accounts

### Link Project

```bash
# Link project to billing account
gcloud billing projects link PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID

# Verify linkage
gcloud billing projects describe PROJECT_ID

# Output:
# billingAccountName: billingAccounts/012345-6789AB-CDEF01
# billingEnabled: true
# name: projects/my-project/billingInfo
# projectId: my-project
```

### Unlink Project

```bash
# Unlink project (disables billable services)
gcloud billing projects unlink PROJECT_ID

# Warning: This will:
# - Stop all billable resources
# - VMs will be stopped
# - Databases will be stopped
# - Data remains intact
```

### Bulk Linking

```bash
#!/bin/bash
# Link multiple projects to billing account

BILLING_ACCOUNT="012345-6789AB-CDEF01"
PROJECTS=("web-prod" "api-prod" "data-prod")

for project in "${PROJECTS[@]}"; do
  echo "Linking $project..."
  gcloud billing projects link $project \
    --billing-account=$BILLING_ACCOUNT
done
```

---

## Billing Account IAM

### Billing Roles

```
┌────────────────────────────────────────────────────────┐
│  Billing IAM Roles                                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Billing Account Administrator                         │
│  (roles/billing.admin)                                 │
│  • Full control over billing account                   │
│  • Manage payment methods                              │
│  • Link/unlink projects                                │
│  • View and export billing data                        │
│  • Manage IAM for billing account                      │
│                                                         │
│  Billing Account User                                  │
│  (roles/billing.user)                                  │
│  • Link projects to billing account                    │
│  • View billing account (not costs)                    │
│  • Typically granted at organization level             │
│  • Used by project creators                            │
│                                                         │
│  Billing Account Viewer                                │
│  (roles/billing.viewer)                                │
│  • View billing account information                    │
│  • View cost and usage data                            │
│  • Cannot modify billing settings                      │
│  • Read-only access                                    │
│                                                         │
│  Billing Account Costs Manager                         │
│  (roles/billing.costsManager)                          │
│  • View and export cost data                           │
│  • Create budgets and alerts                           │
│  • Cannot modify billing account                       │
│  • For finance teams                                   │
│                                                         │
│  Project Billing Manager                               │
│  (roles/billing.projectManager)                        │
│  • Link/unlink projects                                │
│  • View billing account                                │
│  • Cannot view costs                                   │
│  • For project administrators                          │
└────────────────────────────────────────────────────────┘
```

### Grant Billing Roles

```bash
# Grant Billing Account Administrator
gcloud billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
  --member='user:admin@company.com' \
  --role='roles/billing.admin'

# Grant Billing Account Viewer (for finance team)
gcloud billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
  --member='group:finance@company.com' \
  --role='roles/billing.viewer'

# Grant Billing Account User (at org level for project creators)
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member='group:developers@company.com' \
  --role='roles/billing.user'

# Grant Costs Manager
gcloud billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
  --member='user:financemanager@company.com' \
  --role='roles/billing.costsManager'

# List IAM policy
gcloud billing accounts get-iam-policy BILLING_ACCOUNT_ID
```

---

## Payment Methods

### Credit Card

```
┌────────────────────────────────────────────────────────┐
│  Credit Card Payment                                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Supported Cards:                                      │
│  • Visa                                                │
│  • Mastercard                                          │
│  • American Express                                    │
│  • Discover (US only)                                  │
│                                                         │
│  Charging:                                             │
│  • Automatic monthly                                   │
│  • When threshold reached ($1,000 default)             │
│  • Immediate for some services                         │
│                                                         │
│  Setup:                                                │
│  1. Navigate to: Billing → Payment method             │
│  2. Click: ADD PAYMENT METHOD                          │
│  3. Enter card details                                 │
│  4. Verify with small charge                           │
│  5. Set as primary (optional)                          │
└────────────────────────────────────────────────────────┘
```

### Bank Account (ACH)

```
┌────────────────────────────────────────────────────────┐
│  Bank Account Payment (US Only)                        │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Requirements:                                         │
│  • US bank account                                     │
│  • Routing number                                      │
│  • Account number                                      │
│  • Account verification (micro-deposits)               │
│                                                         │
│  Verification Process:                                 │
│  1. Add bank account details                           │
│  2. Google sends 2 small deposits                      │
│  3. Verify amounts (1-3 business days)                 │
│  4. Account activated                                  │
│                                                         │
│  Benefits:                                             │
│  • Lower transaction fees                              │
│  • Higher spending limits                              │
│  • Direct bank withdrawal                              │
└────────────────────────────────────────────────────────┘
```

---

## Billing Thresholds

### Automatic Charging

```
┌────────────────────────────────────────────────────────┐
│  Billing Threshold System                              │
└────────────────────────────────────────────────────────┘

Month Start: $0
      │
      ├─ Usage accumulates
      │
      ▼
Threshold: $1,000 (default)
      │
      ├─ Automatic charge
      ├─ Threshold resets
      │
      ▼
Continue usage
      │
      ├─ Threshold: $1,000 again
      │
      ▼
Month End
      │
      └─ Final charge for remaining balance

Example Month:
  Day 10: Charged $1,000 (threshold reached)
  Day 20: Charged $1,000 (threshold reached)
  Day 30: Charged $500 (month end)
  Total: $2,500

Threshold Increases:
  • Starts at $1,000
  • Increases with payment history
  • Can reach $50,000+
  • Automatic adjustment by Google
```

---

## Billing Cycle

### Monthly Billing

```
┌────────────────────────────────────────────────────────┐
│  Billing Cycle Timeline                                │
└────────────────────────────────────────────────────────┘

Day 1-31: Usage Period
├─ Resources consumed
├─ Costs accumulated
└─ Real-time cost tracking

Day 1 (Next Month): Billing Finalized
├─ Final costs calculated
├─ Invoice generated
├─ Payment processed
└─ Billing data available

Day 2-5: Detailed Billing Available
├─ Complete usage data
├─ SKU-level details
├─ Export to BigQuery updated
└─ Reports available

Timeline:
  March 1-31: Usage
  April 1: Invoice generated, payment charged
  April 2-5: Detailed data available
  April 30: Next cycle begins
```

---

## Managing Multiple Billing Accounts

### Strategy 1: Environment-Based

```
Organization
├── Production Billing Account
│   ├── Payment: Corporate credit card
│   ├── Budget: $50,000/month
│   └── Projects: 50 production projects
│
├── Development Billing Account
│   ├── Payment: Department credit card
│   ├── Budget: $5,000/month
│   └── Projects: 100 dev/test projects
│
└── Shared Services Billing Account
    ├── Payment: IT budget credit card
    ├── Budget: $10,000/month
    └── Projects: Networking, monitoring, security
```

### Strategy 2: Department-Based

```
Organization
├── Engineering Billing Account
│   ├── Cost Center: ENG-001
│   └── Projects: Engineering projects
│
├── Data Science Billing Account
│   ├── Cost Center: DS-001
│   └── Projects: ML and analytics
│
├── Marketing Billing Account
│   ├── Cost Center: MKT-001
│   └── Projects: Marketing tools
│
└── Finance Billing Account
    ├── Cost Center: FIN-001
    └── Projects: Financial systems
```

---

## Billing Export

### Enable Billing Export

```bash
# Export to BigQuery (via Console)
# Navigation: Billing → Billing export → BigQuery export

# Configure:
# 1. Select billing account
# 2. Choose project for BigQuery dataset
# 3. Create or select dataset
# 4. Enable standard or detailed export
# 5. Save

# Verify export
bq ls --project_id=PROJECT_ID

# Query billing data
bq query --use_legacy_sql=false '
SELECT
  billing_account_id,
  service.description,
  SUM(cost) as total_cost
FROM `project.dataset.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY billing_account_id, service.description
ORDER BY total_cost DESC
'
```

---

## Best Practices

### 1. Account Structure

```
✓ Separate billing accounts by environment
✓ Use descriptive account names
✓ Document account purpose
✓ Limit billing admins (2-3 people)
✓ Use groups for billing roles
✓ Regular access reviews
```

### 2. Payment Management

```
✓ Keep payment methods up to date
✓ Set up backup payment method
✓ Monitor payment failures
✓ Review charges monthly
✓ Enable billing alerts
✓ Export billing data
```

### 3. Cost Control

```
✓ Set budgets on billing accounts
✓ Enable billing export to BigQuery
✓ Apply labels to projects
✓ Regular cost reviews
✓ Monitor unusual spending
✓ Implement approval workflows
```

### 4. Security

```
✓ Enable MFA for billing admins
✓ Use least privilege for billing roles
✓ Audit billing account access
✓ Monitor billing IAM changes
✓ Separate billing from project access
✓ Document billing procedures
```

---

## Troubleshooting

```
Issue: Cannot create billing account
Solution:
  • Must use Console (not gcloud)
  • Verify payment method
  • Check country restrictions
  • Contact Google Cloud support

Issue: Project not charging to billing account
Solution:
  • Verify project is linked
  • Check billing account is active
  • Verify payment method is valid
  • Check for billing account suspension

Issue: Payment declined
Solution:
  • Verify card details
  • Check card limits
  • Contact bank
  • Add backup payment method
  • Check billing threshold

Issue: Cannot link project
Solution:
  • Verify billing.user role
  • Check billing account is active
  • Ensure project not already linked
  • Check organization policies
```

---

## Next Steps

- **Cost Tracking** → [2-Cost-Tracking.md](./2-Cost-Tracking.md)
- **Budgets & Alerts** → [3-Budgets-Alerts.md](./3-Budgets-Alerts.md)
- **Cost Optimization** → [4-Cost-Optimization.md](./4-Cost-Optimization.md)

---
