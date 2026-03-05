# Billing & Cost Management Best Practices

## Overview

This comprehensive guide covers best practices for managing GCP billing and costs effectively. Implement these strategies to optimize spending, improve visibility, and maintain financial control.

---

## Table of Contents

1. [Cost Optimization Principles](#cost-optimization-principles)
2. [Organizational Setup](#organizational-setup)
3. [Monitoring & Alerting](#monitoring--alerting)
4. [Resource Management](#resource-management)
5. [Commitment & Discounts](#commitment--discounts)
6. [Security & Governance](#security--governance)
7. [Automation](#automation)
8. [Team Practices](#team-practices)
9. [Common Pitfalls](#common-pitfalls)
10. [Checklist](#checklist)

---

## Cost Optimization Principles

### The Four Pillars

```
┌────────────────────────────────────────────────────┐
│         Cost Optimization Framework                │
└────────────────────────────────────────────────────┘

1. VISIBILITY
   ├─ Know what you're spending
   ├─ Understand cost drivers
   └─ Track trends over time

2. OPTIMIZATION
   ├─ Right-size resources
   ├─ Use appropriate services
   └─ Eliminate waste

3. GOVERNANCE
   ├─ Set policies and controls
   ├─ Enforce standards
   └─ Regular reviews

4. AUTOMATION
   ├─ Automate cost management
   ├─ Scheduled optimization
   └─ Proactive alerts
```

### Cost-Aware Culture

✓ **Make costs visible to teams**
- Share cost dashboards
- Include costs in sprint planning
- Celebrate cost savings

✓ **Ownership and accountability**
- Assign cost center owners
- Regular cost reviews
- Budget responsibility

✓ **Education and training**
- GCP pricing training
- Cost optimization workshops
- Share best practices

---

## Organizational Setup

### 1. Billing Account Structure

**Best Practice: Separate billing accounts by environment**

```
Organization
│
├─── Production Billing Account
│    ├─ Critical workloads
│    ├─ Customer-facing services
│    └─ Strict budget controls
│
├─── Non-Production Billing Account
│    ├─ Development
│    ├─ Testing
│    └─ Staging
│
└─── Sandbox Billing Account
     ├─ Experiments
     ├─ Training
     └─ POCs (with spending limits)
```

**Implementation:**

```bash
# Create separate billing accounts
gcloud billing accounts create \
    --display-name="Production Billing"

gcloud billing accounts create \
    --display-name="Non-Production Billing"

# Link projects appropriately
gcloud billing projects link prod-project-001 \
    --billing-account=PROD-BILLING-ACCOUNT-ID

gcloud billing projects link dev-project-001 \
    --billing-account=NONPROD-BILLING-ACCOUNT-ID
```

### 2. Project Organization

**Best Practice: One project per application per environment**

```yaml
# Project naming convention
format: "<team>-<env>-<app>-<region>"

examples:
  - eng-prod-web-us
  - eng-dev-web-us
  - mkt-prod-analytics-eu
  - ds-staging-ml-us
```

### 3. Folder Structure

```
Organization: company.com
│
├─── Production/
│    ├─── Engineering/
│    │    ├─ eng-prod-web
│    │    └─ eng-prod-api
│    └─── Marketing/
│         └─ mkt-prod-analytics
│
├─── Non-Production/
│    ├─── Development/
│    └─── Staging/
│
└─── Shared-Services/
     ├─ shared-monitoring
     ├─ shared-security
     └─ shared-networking
```

---

## Monitoring & Alerting

### 1. Budget Configuration

**Best Practice: Multiple budget levels**

```python
# Create hierarchical budgets
from google.cloud import billing_budgets_v1

def create_budget_hierarchy():
    client = billing_budgets_v1.BudgetServiceClient()
    
    budgets = [
        {
            'name': 'Organization Budget',
            'amount': 100000,
            'thresholds': [0.5, 0.75, 0.9, 1.0]
        },
        {
            'name': 'Engineering Budget',
            'amount': 50000,
            'thresholds': [0.5, 0.75, 0.9, 1.0]
        },
        {
            'name': 'Project Budget',
            'amount': 10000,
            'thresholds': [0.5, 0.75, 0.9, 1.0, 1.1]
        }
    ]
    
    for budget_config in budgets:
        budget = billing_budgets_v1.Budget(
            display_name=budget_config['name'],
            budget_filter=billing_budgets_v1.Filter(
                # Configuration
            ),
            amount=billing_budgets_v1.BudgetAmount(
                specified_amount={'units': budget_config['amount']}
            ),
            threshold_rules=[
                billing_budgets_v1.ThresholdRule(
                    threshold_percent=threshold
                )
                for threshold in budget_config['thresholds']
            ]
        )
        
        # Create budget
        client.create_budget(parent=f"billingAccounts/{BILLING_ACCOUNT}", budget=budget)

create_budget_hierarchy()
```

### 2. Alert Configuration

**Best Practice: Multi-channel alerting**

```yaml
# Alert configuration
alerts:
  - name: "Budget 50% Alert"
    threshold: 0.5
    channels:
      - email: finops-team@company.com
      - slack: #cost-alerts
    
  - name: "Budget 90% Alert"
    threshold: 0.9
    channels:
      - email: finops-team@company.com
      - email: engineering-leads@company.com
      - slack: #cost-alerts
      - pagerduty: cost-incidents
    
  - name: "Budget 100% Alert"
    threshold: 1.0
    channels:
      - email: finops-team@company.com
      - email: cto@company.com
      - slack: #cost-alerts
      - pagerduty: cost-incidents
    actions:
      - disable_billing: false  # Be careful!
      - notify_executives: true
```

### 3. Cost Anomaly Detection

```sql
-- Detect cost anomalies
WITH daily_costs AS (
  SELECT
    DATE(usage_start_time) AS date,
    project.id AS project_id,
    SUM(cost) AS daily_cost
  FROM
    `billing_export.gcp_billing_export_v1_XXXXXX`
  WHERE
    usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  GROUP BY
    date, project_id
),
stats AS (
  SELECT
    project_id,
    AVG(daily_cost) AS avg_cost,
    STDDEV(daily_cost) AS stddev_cost
  FROM
    daily_costs
  GROUP BY
    project_id
)
SELECT
  d.date,
  d.project_id,
  d.daily_cost,
  s.avg_cost,
  s.stddev_cost,
  (d.daily_cost - s.avg_cost) / s.stddev_cost AS z_score,
  CASE
    WHEN ABS((d.daily_cost - s.avg_cost) / s.stddev_cost) > 2 THEN 'ANOMALY'
    ELSE 'NORMAL'
  END AS status
FROM
  daily_costs d
JOIN
  stats s ON d.project_id = s.project_id
WHERE
  d.date = CURRENT_DATE()
  AND ABS((d.daily_cost - s.avg_cost) / s.stddev_cost) > 2
ORDER BY
  z_score DESC;
```

---

## Resource Management

### 1. Right-Sizing

**Best Practice: Regular right-sizing reviews**

```python
# Identify oversized instances
from google.cloud import monitoring_v3
from google.cloud import compute_v1

def find_underutilized_instances():
    """
    Find instances with low CPU utilization
    """
    monitoring_client = monitoring_v3.MetricServiceClient()
    compute_client = compute_v1.InstancesClient()
    
    project_id = "your-project-id"
    
    # Query CPU utilization
    interval = monitoring_v3.TimeInterval({
        "end_time": {"seconds": int(time.time())},
        "start_time": {"seconds": int(time.time()) - 86400 * 7},  # 7 days
    })
    
    results = monitoring_client.list_time_series(
        request={
            "name": f"projects/{project_id}",
            "filter": 'metric.type="compute.googleapis.com/instance/cpu/utilization"',
            "interval": interval,
        }
    )
    
    underutilized = []
    for result in results:
        # Calculate average CPU
        values = [point.value.double_value for point in result.points]
        avg_cpu = sum(values) / len(values) if values else 0
        
        if avg_cpu < 0.2:  # Less than 20% utilization
            instance_name = result.resource.labels['instance_id']
            underutilized.append({
                'instance': instance_name,
                'avg_cpu': avg_cpu * 100,
                'recommendation': 'Consider downsizing'
            })
    
    return underutilized

# Generate report
instances = find_underutilized_instances()
for inst in instances:
    print(f"Instance: {inst['instance']}")
    print(f"Avg CPU: {inst['avg_cpu']:.2f}%")
    print(f"Recommendation: {inst['recommendation']}\n")
```

### 2. Idle Resource Cleanup

**Best Practice: Automated cleanup of idle resources**

```python
# Cloud Function to stop idle VMs
import functions_framework
from google.cloud import compute_v1
from datetime import datetime, timedelta

@functions_framework.http
def stop_idle_vms(request):
    """
    Stop VMs that have been idle for > 7 days
    """
    compute_client = compute_v1.InstancesClient()
    project_id = "your-project-id"
    zone = "us-central1-a"
    
    instances = compute_client.list(project=project_id, zone=zone)
    
    stopped_instances = []
    for instance in instances:
        # Check if instance has 'auto-stop' label
        if 'auto-stop' in instance.labels:
            # Check last activity (simplified)
            if should_stop_instance(instance):
                compute_client.stop(
                    project=project_id,
                    zone=zone,
                    instance=instance.name
                )
                stopped_instances.append(instance.name)
    
    return {
        'stopped_instances': stopped_instances,
        'count': len(stopped_instances)
    }

def should_stop_instance(instance):
    # Implement logic to check if instance is idle
    # Check CPU, network, disk metrics
    return False  # Placeholder
```

### 3. Scheduled Operations

**Best Practice: Stop non-production resources outside business hours**

```yaml
# Cloud Scheduler configuration
schedules:
  - name: "stop-dev-instances"
    schedule: "0 18 * * 1-5"  # 6 PM weekdays
    target: "stop-instances"
    filter: "labels.environment=development"
  
  - name: "start-dev-instances"
    schedule: "0 8 * * 1-5"   # 8 AM weekdays
    target: "start-instances"
    filter: "labels.environment=development"
```

```bash
# Create Cloud Scheduler jobs
gcloud scheduler jobs create http stop-dev-vms \
    --schedule="0 18 * * 1-5" \
    --uri="https://REGION-PROJECT.cloudfunctions.net/stop-instances" \
    --http-method=POST \
    --message-body='{"environment":"development"}'

gcloud scheduler jobs create http start-dev-vms \
    --schedule="0 8 * * 1-5" \
    --uri="https://REGION-PROJECT.cloudfunctions.net/start-instances" \
    --http-method=POST \
    --message-body='{"environment":"development"}'
```

---

## Commitment & Discounts

### 1. Committed Use Discounts (CUD)

**Best Practice: Analyze usage before committing**

```sql
-- Analyze compute usage for CUD opportunities
SELECT
  sku.description,
  usage.unit,
  SUM(usage.amount) AS total_usage,
  AVG(usage.amount) AS avg_daily_usage,
  MIN(usage.amount) AS min_daily_usage,
  -- Potential savings with 1-year CUD (25% discount)
  SUM(cost) * 0.25 AS potential_1yr_savings,
  -- Potential savings with 3-year CUD (52% discount)
  SUM(cost) * 0.52 AS potential_3yr_savings
FROM
  `billing_export.gcp_billing_export_v1_XXXXXX`
WHERE
  service.description = 'Compute Engine'
  AND usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND sku.description LIKE '%Instance Core%'
GROUP BY
  sku.description, usage.unit
HAVING
  min_daily_usage > 0  -- Consistent usage
ORDER BY
  potential_3yr_savings DESC;
```

### 2. Sustained Use Discounts (SUD)

**Best Practice: Maximize SUD by consolidating workloads**

```
Sustained Use Discount Tiers:
├─ 25% of month: 20% discount
├─ 50% of month: 40% discount
├─ 75% of month: 60% discount
└─ 100% of month: 30% discount (average)

Strategy:
✓ Keep instances running consistently
✓ Use same machine type in same region
✓ Avoid frequent start/stop cycles
```

### 3. Spot VMs

**Best Practice: Use Spot VMs for fault-tolerant workloads**

```hcl
# Terraform configuration for Spot VM
resource "google_compute_instance" "batch_processor" {
  name         = "batch-processor"
  machine_type = "n2-standard-4"
  zone         = "us-central1-a"
  
  # Enable Spot VM (up to 91% discount)
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    on_host_maintenance         = "TERMINATE"
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }
  
  labels = {
    workload_type = "batch"
    cost_optimized = "true"
  }
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network = "default"
  }
}
```

---

## Security & Governance

### 1. IAM for Billing

**Best Practice: Principle of least privilege**

```yaml
# Billing IAM roles
roles:
  billing_admin:
    members:
      - finops-team@company.com
    permissions:
      - Full billing account management
      - Create/modify budgets
      - Link/unlink projects
  
  billing_viewer:
    members:
      - engineering-leads@company.com
      - product-managers@company.com
    permissions:
      - View costs and usage
      - View budgets
      - Export billing data
  
  billing_user:
    members:
      - project-creators@company.com
    permissions:
      - Link projects to billing
      - View billing account info
```

```bash
# Grant billing roles
gcloud billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
    --member="group:finops-team@company.com" \
    --role="roles/billing.admin"

gcloud billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
    --member="group:engineering-leads@company.com" \
    --role="roles/billing.viewer"
```

### 2. Organization Policies

**Best Practice: Enforce cost controls via policies**

```yaml
# Organization policies for cost control
policies:
  - constraint: "compute.vmExternalIpAccess"
    action: "deny"
    reason: "Reduce data egress costs"
    exceptions:
      - projects/prod-web-frontend
  
  - constraint: "compute.requireShieldedVm"
    action: "enforce"
    reason: "Security and compliance"
  
  - constraint: "compute.restrictMachineTypes"
    allowed_values:
      - "e2-*"
      - "n2-*"
    reason: "Cost-effective machine types only"
```

### 3. Quota Management

**Best Practice: Set quotas to prevent runaway costs**

```bash
# Set project quotas
gcloud compute project-info describe --project=PROJECT_ID

# Request quota increase (if needed)
gcloud compute regions describe us-central1 \
    --project=PROJECT_ID \
    --format="table(quotas:format='table(metric,limit,usage)')"

# Set custom quotas via API
gcloud services quota update \
    --service=compute.googleapis.com \
    --consumer=projects/PROJECT_ID \
    --metric=compute.googleapis.com/cpus \
    --value=100 \
    --region=us-central1
```

---

## Automation

### 1. Infrastructure as Code

**Best Practice: Manage all resources via Terraform**

```hcl
# Terraform with cost-aware configuration
resource "google_compute_instance" "web_server" {
  name         = "web-server-${var.environment}"
  machine_type = var.environment == "production" ? "n2-standard-4" : "e2-medium"
  zone         = var.zone
  
  labels = {
    environment   = var.environment
    cost_center   = var.cost_center
    managed_by    = "terraform"
    auto_shutdown = var.environment != "production" ? "true" : "false"
  }
  
  # Use committed use discount in production
  scheduling {
    preemptible = var.environment != "production"
  }
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.environment == "production" ? 100 : 50
      type  = var.environment == "production" ? "pd-ssd" : "pd-standard"
    }
  }
  
  network_interface {
    network = google_compute_network.vpc.id
    
    # No external IP for non-production
    dynamic "access_config" {
      for_each = var.environment == "production" ? [1] : []
      content {}
    }
  }
}
```

### 2. Cost Optimization Automation

```python
# Automated cost optimization
from google.cloud import compute_v1, monitoring_v3
import schedule
import time

class CostOptimizer:
    def __init__(self, project_id):
        self.project_id = project_id
        self.compute_client = compute_v1.InstancesClient()
        self.monitoring_client = monitoring_v3.MetricServiceClient()
    
    def optimize_instances(self):
        """
        Daily optimization routine
        """
        print("Running cost optimization...")
        
        # 1. Find idle instances
        idle_instances = self.find_idle_instances()
        for instance in idle_instances:
            self.stop_instance(instance)
        
        # 2. Find oversized instances
        oversized = self.find_oversized_instances()
        for instance in oversized:
            self.recommend_resize(instance)
        
        # 3. Find unattached disks
        orphaned_disks = self.find_orphaned_disks()
        for disk in orphaned_disks:
            self.delete_disk(disk)
        
        print("Optimization complete!")
    
    def find_idle_instances(self):
        # Implementation
        return []
    
    def find_oversized_instances(self):
        # Implementation
        return []
    
    def find_orphaned_disks(self):
        # Implementation
        return []
    
    def stop_instance(self, instance):
        print(f"Stopping idle instance: {instance}")
    
    def recommend_resize(self, instance):
        print(f"Recommend resizing: {instance}")
    
    def delete_disk(self, disk):
        print(f"Deleting orphaned disk: {disk}")

# Schedule daily optimization
optimizer = CostOptimizer("your-project-id")
schedule.every().day.at("02:00").do(optimizer.optimize_instances)

while True:
    schedule.run_pending()
    time.sleep(3600)
```

---

## Team Practices

### 1. Cost Reviews

**Best Practice: Regular cost review meetings**

```yaml
# Cost review schedule
weekly_review:
  attendees:
    - FinOps team
    - Engineering leads
  agenda:
    - Review week-over-week changes
    - Identify anomalies
    - Quick wins

monthly_review:
  attendees:
    - FinOps team
    - Engineering leads
    - Product managers
    - Finance team
  agenda:
    - Month-over-month analysis
    - Budget vs actual
    - Optimization opportunities
    - Forecast next month

quarterly_review:
  attendees:
    - Executive team
    - FinOps team
    - Department heads
  agenda:
    - Quarterly trends
    - Strategic initiatives
    - Budget planning
    - Commitment decisions
```

### 2. Cost-Aware Development

**Best Practice: Include cost considerations in development**

```python
# Cost estimation in CI/CD
def estimate_deployment_cost(config):
    """
    Estimate monthly cost of deployment
    """
    costs = {
        'compute': estimate_compute_cost(config['instances']),
        'storage': estimate_storage_cost(config['storage']),
        'network': estimate_network_cost(config['traffic']),
        'database': estimate_database_cost(config['database'])
    }
    
    total = sum(costs.values())
    
    print(f"\n{'='*50}")
    print("ESTIMATED MONTHLY COST")
    print(f"{'='*50}")
    for service, cost in costs.items():
        print(f"{service.capitalize()}: ${cost:,.2f}")
    print(f"{'='*50}")
    print(f"Total: ${total:,.2f}")
    print(f"{'='*50}\n")
    
    # Fail if cost exceeds threshold
    if total > config.get('cost_threshold', float('inf')):
        raise Exception(f"Estimated cost ${total} exceeds threshold")
    
    return total

# Usage in CI/CD pipeline
config = {
    'instances': {'type': 'n2-standard-4', 'count': 3},
    'storage': {'size_gb': 1000, 'type': 'ssd'},
    'traffic': {'gb_per_month': 5000},
    'database': {'type': 'cloud-sql', 'size': 'db-n1-standard-2'},
    'cost_threshold': 5000
}

estimate_deployment_cost(config)
```

### 3. Documentation

**Best Practice: Document cost decisions**

```markdown
# Cost Decision Log

## Decision: Use Spot VMs for Batch Processing
- **Date:** 2026-03-01
- **Decision Maker:** Engineering Lead
- **Rationale:** Batch jobs are fault-tolerant and can handle interruptions
- **Expected Savings:** $15,000/month (75% reduction)
- **Risks:** Potential job delays during high demand
- **Mitigation:** Implement job queuing and retry logic

## Decision: Commit to 3-Year CUD for Production Compute
- **Date:** 2026-02-15
- **Decision Maker:** FinOps Team + CFO
- **Rationale:** Stable production workload with predictable growth
- **Expected Savings:** $50,000/year (52% discount)
- **Commitment:** 100 vCPUs for 3 years
- **Review Date:** 2026-08-15 (6-month check-in)
```

---

## Common Pitfalls

### ❌ Pitfall 1: No Budget Alerts

**Problem:** Unexpected bills with no warning

**Solution:**
```bash
# Always set up budget alerts
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="Project Budget" \
    --budget-amount=10000 \
    --threshold-rule=percent=0.5 \
    --threshold-rule=percent=0.9 \
    --threshold-rule=percent=1.0
```

### ❌ Pitfall 2: Orphaned Resources

**Problem:** Paying for unused disks, IPs, snapshots

**Solution:**
```python
# Regular cleanup script
def cleanup_orphaned_resources():
    """
    Find and delete orphaned resources
    """
    # Unattached disks
    disks = compute_client.list_disks()
    for disk in disks:
        if not disk.users:  # No attached instances
            print(f"Orphaned disk: {disk.name}")
            # Delete after confirmation
    
    # Unused static IPs
    addresses = compute_client.list_addresses()
    for addr in addresses:
        if addr.status == 'RESERVED' and not addr.users:
            print(f"Unused IP: {addr.address}")
            # Release after confirmation
    
    # Old snapshots
    snapshots = compute_client.list_snapshots()
    for snapshot in snapshots:
        age_days = (datetime.now() - snapshot.creation_timestamp).days
        if age_days > 90:  # Older than 90 days
            print(f"Old snapshot: {snapshot.name}")
            # Delete after confirmation
```

### ❌ Pitfall 3: Over-Provisioning

**Problem:** Resources larger than needed

**Solution:**
- Start small and scale up
- Monitor actual usage
- Regular right-sizing reviews

### ❌ Pitfall 4: No Cost Allocation

**Problem:** Can't track costs by team/project

**Solution:**
```bash
# Enforce labeling
gcloud resource-manager org-policies set-policy \
    --organization=ORG_ID \
    policy.yaml

# policy.yaml
constraint: compute.requireLabels
listPolicy:
  allowedValues:
    - "cost_center"
    - "team"
    - "environment"
```

### ❌ Pitfall 5: Ignoring Recommendations

**Problem:** Missing easy optimization opportunities

**Solution:**
```python
# Act on Recommender suggestions
from google.cloud import recommender_v1

def apply_recommendations():
    client = recommender_v1.RecommenderClient()
    
    parent = f"projects/{PROJECT_ID}/locations/global/recommenders/google.compute.instance.MachineTypeRecommender"
    
    recommendations = client.list_recommendations(parent=parent)
    
    for rec in recommendations:
        if rec.primary_impact.cost_projection.cost.units < 0:  # Saves money
            print(f"Recommendation: {rec.description}")
            print(f"Savings: ${abs(rec.primary_impact.cost_projection.cost.units)}")
            # Apply recommendation
```

---

## Checklist

### Initial Setup ✓

```
□ Create billing account structure
□ Set up billing export to BigQuery
□ Configure organization hierarchy
□ Define labeling taxonomy
□ Set up IAM roles for billing
□ Create initial budgets
□ Configure budget alerts
□ Set up cost dashboards
```

### Monthly Tasks ✓

```
□ Review budget vs actual
□ Analyze cost trends
□ Check for anomalies
□ Review Recommender suggestions
□ Audit resource labels
□ Clean up orphaned resources
□ Update forecasts
□ Generate chargeback reports
```

### Quarterly Tasks ✓

```
□ Review commitment usage
□ Evaluate new CUD opportunities
□ Audit organization policies
□ Review and update budgets
□ Assess cost allocation accuracy
□ Update cost optimization roadmap
□ Train teams on new features
```

### Annual Tasks ✓

```
□ Strategic cost planning
□ Review billing account structure
□ Evaluate multi-year commitments
□ Benchmark against industry
□ Update cost governance policies
□ Comprehensive audit
```

---

## Summary

Key best practices for GCP billing and cost management:

1. **Visibility First** - You can't optimize what you can't see
2. **Automate Everything** - Reduce manual effort and errors
3. **Regular Reviews** - Continuous improvement is key
4. **Team Accountability** - Make costs everyone's responsibility
5. **Proactive Monitoring** - Catch issues before they become problems
6. **Right-Size Resources** - Pay only for what you need
7. **Use Commitments Wisely** - Balance savings with flexibility
8. **Clean Up Regularly** - Eliminate waste consistently

### Quick Wins

```bash
# 1. Enable billing export
gcloud billing accounts describe BILLING_ACCOUNT_ID

# 2. Create budget
gcloud billing budgets create --billing-account=BILLING_ACCOUNT_ID \
    --display-name="Monthly Budget" --budget-amount=10000

# 3. Apply labels
gcloud compute instances add-labels INSTANCE \
    --labels=cost_center=CC-1001,team=engineering

# 4. Check recommendations
gcloud recommender recommendations list \
    --project=PROJECT_ID \
    --location=global \
    --recommender=google.compute.instance.MachineTypeRecommender

# 5. Find idle resources
gcloud compute instances list --filter="status:TERMINATED"
```

---

## Next Steps

- [Cost Allocation](./7-Cost-Allocation.md) - Implement chargeback
- [Cost Optimization](./4-Cost-Optimization.md) - Reduce spending
- [Recommender](./5-Recommender.md) - AI-powered savings

---

**Last Updated:** March 2026
