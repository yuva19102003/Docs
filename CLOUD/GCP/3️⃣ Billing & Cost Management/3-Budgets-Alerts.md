# 3. Budgets & Alerts

Proactive cost control through budgets, alerts, and automated responses.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  Budget & Alert System                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Purpose:                                              │
│  • Set spending limits                                 │
│  • Monitor cost trends                                 │
│  • Receive alerts before overspending                  │
│  • Automate cost control actions                       │
│                                                         │
│  Components:                                           │
│  • Budget amount (fixed or variable)                   │
│  • Alert thresholds (50%, 90%, 100%)                   │
│  • Notification channels (email, Pub/Sub)              │
│  • Scope (account, project, folder)                    │
└────────────────────────────────────────────────────────┘
```

---

## Creating Budgets

### Via Console

```
Navigation: Billing → Budgets & alerts → CREATE BUDGET

Step 1: Budget Scope
  • Billing account
  • Projects (all or specific)
  • Products/Services (all or specific)
  • Labels (filter by labels)
  • Credit types

Step 2: Budget Amount
  • Specified amount: $10,000/month
  • Last month's spend
  • Custom formula

Step 3: Alert Thresholds
  • 50% of budget
  • 90% of budget
  • 100% of budget
  • 110% of budget (optional)

Step 4: Notifications
  • Email recipients
  • Pub/Sub topic (for automation)
  • Monitoring notification channels
```

### Via gcloud

```bash
# Create budget with alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Production Budget" \
  --budget-amount=10000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100

# Create budget for specific projects
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Web App Budget" \
  --budget-amount=5000 \
  --filter-projects=projects/web-prod-2026 \
  --threshold-rule=percent=80,basis=FORECASTED_SPEND

# Create budget with Pub/Sub notification
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Alert Budget" \
  --budget-amount=1000 \
  --threshold-rule=percent=100 \
  --all-updates-rule-pubsub-topic=projects/PROJECT_ID/topics/budget-alerts
```

---

## Budget Types

### 1. Fixed Budget

```
Monthly Budget: $10,000

┌────────────────────────────────────────────────────────┐
│  January 2026                                          │
├────────────────────────────────────────────────────────┤
│  Budget: $10,000                                       │
│  Actual: $8,500                                        │
│  Status: ✓ Under budget                               │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  February 2026                                         │
├────────────────────────────────────────────────────────┤
│  Budget: $10,000                                       │
│  Actual: $11,200                                       │
│  Status: ✗ Over budget                                │
│  Alerts: Sent at 50%, 90%, 100%, 110%                 │
└────────────────────────────────────────────────────────┘

Use Case: Predictable workloads
```

### 2. Variable Budget (Last Month's Spend)

```
Budget: Based on previous month

┌────────────────────────────────────────────────────────┐
│  January 2026                                          │
├────────────────────────────────────────────────────────┤
│  Budget: $8,000 (Dec spend)                            │
│  Actual: $8,500                                        │
│  Status: ✗ 106% of budget                             │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  February 2026                                         │
├────────────────────────────────────────────────────────┤
│  Budget: $8,500 (Jan spend)                            │
│  Actual: $9,000                                        │
│  Status: ✗ 106% of budget                             │
└────────────────────────────────────────────────────────┘

Use Case: Growing workloads
```

### 3. Custom Formula Budget

```
Budget: Average of last 3 months + 10%

Example:
  Oct: $8,000
  Nov: $9,000
  Dec: $10,000
  Average: $9,000
  Budget: $9,900 (+ 10%)

Use Case: Seasonal variations
```

---

## Alert Thresholds

### Threshold Types

```
┌────────────────────────────────────────────────────────┐
│  Alert Threshold Options                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Actual Spend:                                         │
│  • Alert when actual spend reaches threshold           │
│  • Based on current month-to-date spending             │
│  • Example: Alert at 50%, 90%, 100%                    │
│                                                         │
│  Forecasted Spend:                                     │
│  • Alert when forecast exceeds threshold               │
│  • Predicts end-of-month spending                      │
│  • Early warning system                                │
│  • Example: Alert at 80% forecasted                    │
└────────────────────────────────────────────────────────┘
```

### Common Threshold Patterns

```
Pattern 1: Conservative
  • 50% - Early warning
  • 75% - Review spending
  • 90% - Take action
  • 100% - Critical alert

Pattern 2: Standard
  • 50% - Informational
  • 90% - Warning
  • 100% - Critical
  • 110% - Emergency

Pattern 3: Aggressive
  • 80% - Warning
  • 95% - Critical
  • 100% - Emergency action

Pattern 4: Forecasted
  • 80% forecasted - Early warning
  • 100% forecasted - Take action
```

---

## Notification Channels

### Email Notifications

```bash
# Budget with email notifications
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Email Alert Budget" \
  --budget-amount=10000 \
  --threshold-rule=percent=90

# Emails sent to:
# - Billing account administrators
# - Billing account users
# - Additional recipients (via Console)
```

### Pub/Sub Integration

```bash
# Create Pub/Sub topic
gcloud pubsub topics create budget-alerts

# Create budget with Pub/Sub
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Automated Budget" \
  --budget-amount=10000 \
  --threshold-rule=percent=100 \
  --all-updates-rule-pubsub-topic=projects/PROJECT_ID/topics/budget-alerts

# Subscribe to alerts
gcloud pubsub subscriptions create budget-alerts-sub \
  --topic=budget-alerts
```

### Monitoring Channels

```bash
# Create notification channel
gcloud alpha monitoring channels create \
  --display-name="Budget Alerts" \
  --type=email \
  --channel-labels=email_address=alerts@company.com

# Link to budget (via Console)
```

---

## Automated Responses

### Cloud Function Trigger

```python
# Cloud Function triggered by budget alert
import base64
import json
from googleapiclient import discovery

def budget_alert(event, context):
    """Triggered by Pub/Sub budget alert"""
    
    # Decode Pub/Sub message
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    budget_data = json.loads(pubsub_message)
    
    # Extract budget info
    budget_name = budget_data['budgetDisplayName']
    cost_amount = budget_data['costAmount']
    budget_amount = budget_data['budgetAmount']
    threshold_percent = budget_data['alertThresholdExceeded']
    
    print(f"Budget Alert: {budget_name}")
    print(f"Cost: ${cost_amount}, Budget: ${budget_amount}")
    print(f"Threshold: {threshold_percent}%")
    
    # Take action based on threshold
    if threshold_percent >= 100:
        # Critical: Stop non-production VMs
        stop_dev_vms()
    elif threshold_percent >= 90:
        # Warning: Send Slack notification
        send_slack_alert(budget_name, cost_amount, budget_amount)
    
    return 'OK'

def stop_dev_vms():
    """Stop development VMs to reduce costs"""
    compute = discovery.build('compute', 'v1')
    project = 'my-project'
    zone = 'us-central1-a'
    
    # List VMs with label environment=dev
    result = compute.instances().list(
        project=project,
        zone=zone,
        filter='labels.environment=dev'
    ).execute()
    
    # Stop each VM
    for instance in result.get('items', []):
        print(f"Stopping VM: {instance['name']}")
        compute.instances().stop(
            project=project,
            zone=zone,
            instance=instance['name']
        ).execute()
```

### Automated Actions

```
┌────────────────────────────────────────────────────────┐
│  Budget Alert → Automated Actions                      │
└────────────────────────────────────────────────────────┘

50% Threshold:
  → Send informational email
  → Log to Cloud Logging
  → Update dashboard

75% Threshold:
  → Send warning email
  → Slack notification
  → Review spending report

90% Threshold:
  → Send critical alert
  → Page on-call engineer
  → Stop non-critical workloads
  → Scale down dev environments

100% Threshold:
  → Emergency alert
  → Stop all dev/test VMs
  → Disable non-essential services
  → Escalate to management
  → Create incident ticket

110% Threshold:
  → Executive notification
  → Emergency cost review meeting
  → Implement spending freeze
```

---

## Budget Scopes

### Billing Account Level

```bash
# Budget for entire billing account
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Organization Budget" \
  --budget-amount=50000 \
  --threshold-rule=percent=90

# Covers all projects in billing account
```

### Project Level

```bash
# Budget for specific projects
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Production Projects Budget" \
  --budget-amount=30000 \
  --filter-projects=projects/web-prod,projects/api-prod \
  --threshold-rule=percent=90
```

### Service Level

```bash
# Budget for specific services
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Compute Budget" \
  --budget-amount=15000 \
  --filter-services=services/6F81-5844-456A \
  --threshold-rule=percent=90

# Service IDs:
# Compute Engine: 6F81-5844-456A
# Cloud Storage: 95FF-2EF5-5EA1
# BigQuery: 24E6-581D-38E5
```

### Label-Based Budget

```bash
# Budget for resources with specific labels
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Team Backend Budget" \
  --budget-amount=10000 \
  --filter-labels=team=backend \
  --threshold-rule=percent=90
```

---

## Monitoring Budgets

### List Budgets

```bash
# List all budgets
gcloud billing budgets list \
  --billing-account=BILLING_ACCOUNT_ID

# Get budget details
gcloud billing budgets describe BUDGET_ID \
  --billing-account=BILLING_ACCOUNT_ID
```

### Budget Status

```
┌────────────────────────────────────────────────────────┐
│  Budget Dashboard                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Production Budget                                     │
│  ████████████████████░░  $9,500 / $10,000 (95%)       │
│  Status: ⚠️ Warning                                    │
│  Forecast: $10,200 (102%)                              │
│                                                         │
│  Development Budget                                    │
│  ████████░░░░░░░░░░░░░░  $2,000 / $5,000 (40%)        │
│  Status: ✓ On track                                    │
│  Forecast: $4,800 (96%)                                │
│                                                         │
│  Compute Budget                                        │
│  ████████████████████████  $15,500 / $15,000 (103%)   │
│  Status: ✗ Over budget                                │
│  Forecast: $16,000 (107%)                              │
└────────────────────────────────────────────────────────┘
```

---

## Best Practices

```
✓ Set budgets for all billing accounts
✓ Use multiple threshold levels
✓ Enable forecasted spend alerts
✓ Automate responses with Pub/Sub
✓ Review budgets monthly
✓ Adjust budgets based on trends
✓ Use label-based budgets for teams
✓ Test alert notifications
✓ Document budget policies
✓ Regular budget reviews with stakeholders
```

---

## Troubleshooting

```
Issue: Not receiving alerts
Solution:
  • Check email spam folder
  • Verify billing account permissions
  • Check notification channel configuration
  • Verify Pub/Sub topic permissions

Issue: Alerts too frequent
Solution:
  • Adjust threshold percentages
  • Use forecasted spend instead of actual
  • Increase budget amount
  • Filter by specific projects/services

Issue: Budget not tracking correctly
Solution:
  • Verify budget scope (projects, services)
  • Check label filters
  • Wait for billing data to update (24-48 hours)
  • Verify billing account linkage
```

---

## Next Steps

- **Cost Optimization** → [4-Cost-Optimization.md](./4-Cost-Optimization.md)
- **Recommender** → [5-Recommender.md](./5-Recommender.md)

---
