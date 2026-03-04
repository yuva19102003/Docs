# Recommender

AI-powered recommendations for cost optimization, security improvements, and performance enhancements in Google Cloud Platform.

---

## 📚 Overview

Google Cloud Recommender uses machine learning to analyze your resource usage and provide actionable recommendations:

- **Cost Optimization**: Identify opportunities to reduce spending
- **Security Improvements**: Enhance security posture
- **Performance Optimization**: Improve resource efficiency
- **Reliability**: Increase system reliability
- **Sustainability**: Reduce carbon footprint

---

## 🤖 Recommender Types

### 1. Cost Recommenders

```
┌────────────────────────────────────────────────────────┐
│  Cost-Related Recommenders                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Idle VM Recommender:                                  │
│  • Identifies VMs with low utilization                 │
│  • Suggests stopping or deleting                       │
│  • Potential savings: 100% of VM cost                  │
│                                                         │
│  Idle Persistent Disk Recommender:                     │
│  • Finds unattached disks                              │
│  • Suggests deletion or snapshotting                   │
│  • Potential savings: 100% of disk cost                │
│                                                         │
│  VM Machine Type Recommender:                          │
│  • Analyzes CPU/memory usage                           │
│  • Suggests right-sized machine types                  │
│  • Potential savings: 30-50%                           │
│                                                         │
│  Committed Use Discount Recommender:                   │
│  • Analyzes usage patterns                             │
│  • Suggests CUD purchases                              │
│  • Potential savings: 25-57%                           │
│                                                         │
│  Persistent Disk Snapshot Recommender:                 │
│  • Identifies old/unused snapshots                     │
│  • Suggests deletion                                   │
│  • Potential savings: Varies                           │
│                                                         │
│  Cloud SQL Idle Instance Recommender:                  │
│  • Finds idle database instances                       │
│  • Suggests stopping or deletion                       │
│  • Potential savings: 100% of instance cost            │
└────────────────────────────────────────────────────────┘
```

### 2. Security Recommenders

```
┌────────────────────────────────────────────────────────┐
│  Security-Related Recommenders                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  IAM Recommender:                                      │
│  • Identifies over-permissioned roles                  │
│  • Suggests least privilege roles                      │
│  • Removes unused permissions                          │
│                                                         │
│  Firewall Recommender:                                 │
│  • Finds overly permissive firewall rules              │
│  • Suggests tightening rules                           │
│  • Identifies unused rules                             │
│                                                         │
│  Service Account Recommender:                          │
│  • Identifies unused service accounts                  │
│  • Suggests disabling or deletion                      │
│  • Finds over-privileged accounts                      │
│                                                         │
│  Unattended Project Recommender:                       │
│  • Finds projects with no activity                     │
│  • Suggests review or deletion                         │
│  • Reduces attack surface                              │
└────────────────────────────────────────────────────────┘
```

### 3. Performance Recommenders

```
┌────────────────────────────────────────────────────────┐
│  Performance-Related Recommenders                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Persistent Disk Type Recommender:                     │
│  • Analyzes disk I/O patterns                          │
│  • Suggests optimal disk type                          │
│  • Balances cost and performance                       │
│                                                         │
│  Cloud SQL Performance Recommender:                    │
│  • Analyzes database performance                       │
│  • Suggests configuration changes                      │
│  • Improves query performance                          │
│                                                         │
│  GKE Recommender:                                      │
│  • Analyzes cluster resource usage                     │
│  • Suggests node pool optimization                     │
│  • Improves pod scheduling                             │
└────────────────────────────────────────────────────────┘
```

---

## 🎯 Using Recommender

### 1. Via Console

```
┌────────────────────────────────────────────────────────┐
│  Accessing Recommendations in Console                  │
└────────────────────────────────────────────────────────┘

Method 1: Recommender Hub
  Navigation: Recommender Hub (from main menu)
  • View all recommendations in one place
  • Filter by type, priority, impact
  • Bulk actions available

Method 2: Service-Specific
  Compute Engine:
    Navigation: Compute Engine → VM instances
    • Click "Recommendations" tab
    • View VM-specific recommendations

  IAM:
    Navigation: IAM & Admin → IAM
    • Click "Recommendations" icon
    • View role recommendations

  Cloud SQL:
    Navigation: SQL → Instances
    • Click instance → Recommendations
    • View database recommendations

Recommendation Details:
  • Description of issue
  • Potential savings/impact
  • Recommended action
  • Apply or dismiss options
```

### 2. Via gcloud CLI

```bash
# List all recommenders
gcloud recommender recommenders list

# List recommendations for specific recommender
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a

# Get recommendation details
gcloud recommender recommendations describe RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a

# Mark recommendation as claimed (you're working on it)
gcloud recommender recommendations mark-claimed RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a \
  --state-metadata=key1=value1,key2=value2

# Mark recommendation as succeeded (applied successfully)
gcloud recommender recommendations mark-succeeded RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a

# Mark recommendation as failed
gcloud recommender recommendations mark-failed RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a

# Dismiss recommendation
gcloud recommender recommendations mark-dismissed RECOMMENDATION_ID \
  --project=PROJECT_ID \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --location=us-central1-a
```

### 3. Via API

```python
from google.cloud import recommender_v1

# Initialize client
client = recommender_v1.RecommenderClient()

# List recommendations
project_id = "your-project-id"
location = "us-central1-a"
recommender = "google.compute.instance.MachineTypeRecommender"

parent = f"projects/{project_id}/locations/{location}/recommenders/{recommender}"

# Get recommendations
recommendations = client.list_recommendations(parent=parent)

for recommendation in recommendations:
    print(f"Recommendation: {recommendation.name}")
    print(f"Description: {recommendation.description}")
    print(f"Priority: {recommendation.priority}")
    print(f"Primary Impact: {recommendation.primary_impact}")
    print("---")

# Apply recommendation
recommendation_name = "projects/123/locations/us-central1-a/recommenders/google.compute.instance.MachineTypeRecommender/recommendations/abc123"

# Mark as claimed
client.mark_recommendation_claimed(
    name=recommendation_name,
    state_metadata={"applied_by": "automation"}
)

# After applying changes, mark as succeeded
client.mark_recommendation_succeeded(
    name=recommendation_name,
    state_metadata={"applied_at": "2026-03-04"}
)
```

---

## 📊 Recommendation Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Recommendation Lifecycle                                        │
└─────────────────────────────────────────────────────────────────┘

Step 1: Generation
┌─────────────────────────────────┐
│ • ML analyzes resource usage    │
│ • Identifies optimization       │
│ • Calculates potential impact   │
│ • Creates recommendation        │
└────────────┬────────────────────┘
             │
             ▼
Step 2: Review
┌─────────────────────────────────┐
│ • View in Console or CLI        │
│ • Assess impact and risk        │
│ • Validate recommendation       │
│ • Decide to apply or dismiss    │
└────────────┬────────────────────┘
             │
             ▼
Step 3: Claim (Optional)
┌─────────────────────────────────┐
│ • Mark as "claimed"             │
│ • Indicates you're working on it│
│ • Prevents duplicate work       │
│ • Add metadata for tracking     │
└────────────┬────────────────────┘
             │
             ▼
Step 4: Apply
┌─────────────────────────────────┐
│ • Implement recommendation      │
│ • Test changes                  │
│ • Monitor impact                │
│ • Document changes              │
└────────────┬────────────────────┘
             │
             ▼
Step 5: Mark Status
┌─────────────────────────────────┐
│ • Succeeded: Applied successfully│
│ • Failed: Couldn't apply        │
│ • Dismissed: Not applicable     │
│ • Track savings realized        │
└─────────────────────────────────┘

Recommendation States:
  • ACTIVE: New recommendation
  • CLAIMED: Being worked on
  • SUCCEEDED: Successfully applied
  • FAILED: Application failed
  • DISMISSED: Not applicable
```

---

## 💡 Common Recommendations

### 1. Idle VM Recommendation

```
Recommendation Details:
┌────────────────────────────────────────────────────────┐
│  Idle VM Detected                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Resource: web-server-dev-1                            │
│  Zone: us-central1-a                                   │
│  Machine Type: n1-standard-4                           │
│                                                         │
│  Issue:                                                │
│  • CPU utilization: 2% (last 14 days)                  │
│  • Network traffic: < 1 MB/day                         │
│  • Disk I/O: Minimal                                   │
│                                                         │
│  Recommendation:                                       │
│  Stop or delete this VM                                │
│                                                         │
│  Potential Savings:                                    │
│  • $121/month (100% of VM cost)                        │
│  • $1,452/year                                         │
│                                                         │
│  Action:                                               │
│  # Stop VM                                             │
│  gcloud compute instances stop web-server-dev-1 \      │
│    --zone=us-central1-a                                │
│                                                         │
│  # Or delete if not needed                             │
│  gcloud compute instances delete web-server-dev-1 \    │
│    --zone=us-central1-a                                │
└────────────────────────────────────────────────────────┘
```

### 2. Machine Type Recommendation

```
Recommendation Details:
┌────────────────────────────────────────────────────────┐
│  Over-Provisioned VM                                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Resource: api-server-prod-1                           │
│  Current: n1-standard-8 (8 vCPU, 30 GB RAM)           │
│  Cost: $243/month                                      │
│                                                         │
│  Usage Analysis (30 days):                             │
│  • CPU utilization: 25% average, 45% peak              │
│  • Memory utilization: 40% average, 60% peak           │
│                                                         │
│  Recommendation:                                       │
│  Change to n1-standard-4 (4 vCPU, 15 GB RAM)          │
│                                                         │
│  Potential Savings:                                    │
│  • $121/month (50% reduction)                          │
│  • $1,452/year                                         │
│                                                         │
│  Action:                                               │
│  # Stop VM                                             │
│  gcloud compute instances stop api-server-prod-1 \     │
│    --zone=us-central1-a                                │
│                                                         │
│  # Change machine type                                 │
│  gcloud compute instances set-machine-type \           │
│    api-server-prod-1 \                                 │
│    --machine-type=n1-standard-4 \                      │
│    --zone=us-central1-a                                │
│                                                         │
│  # Start VM                                            │
│  gcloud compute instances start api-server-prod-1 \    │
│    --zone=us-central1-a                                │
└────────────────────────────────────────────────────────┘
```

### 3. IAM Role Recommendation

```
Recommendation Details:
┌────────────────────────────────────────────────────────┐
│  Over-Permissioned IAM Role                            │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Member: developer@company.com                         │
│  Current Role: roles/editor (Project Editor)           │
│  Project: web-prod-2026                                │
│                                                         │
│  Usage Analysis (90 days):                             │
│  • Used permissions: 15 out of 2,000+                  │
│  • Unused permissions: 99%                             │
│  • Risk: High (can modify most resources)              │
│                                                         │
│  Recommendation:                                       │
│  Replace with: roles/compute.instanceAdmin.v1          │
│                                                         │
│  Impact:                                               │
│  • Maintains needed permissions                        │
│  • Removes 1,985+ unused permissions                   │
│  • Follows least privilege principle                   │
│  • Reduces security risk                               │
│                                                         │
│  Action:                                               │
│  # Remove Editor role                                  │
│  gcloud projects remove-iam-policy-binding \           │
│    web-prod-2026 \                                     │
│    --member='user:developer@company.com' \             │
│    --role='roles/editor'                               │
│                                                         │
│  # Add specific role                                   │
│  gcloud projects add-iam-policy-binding \              │
│    web-prod-2026 \                                     │
│    --member='user:developer@company.com' \             │
│    --role='roles/compute.instanceAdmin.v1'             │
└────────────────────────────────────────────────────────┘
```

---

## 🔄 Automation with Recommender

### 1. Automated Recommendation Processing

```python
#!/usr/bin/env python3
"""
Automated recommendation processor
Applies low-risk recommendations automatically
"""

from google.cloud import recommender_v1
from google.cloud import compute_v1
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RecommendationProcessor:
    def __init__(self, project_id):
        self.project_id = project_id
        self.recommender_client = recommender_v1.RecommenderClient()
        self.compute_client = compute_v1.InstancesClient()
    
    def process_idle_vm_recommendations(self, location):
        """Process idle VM recommendations"""
        recommender = "google.compute.instance.IdleResourceRecommender"
        parent = f"projects/{self.project_id}/locations/{location}/recommenders/{recommender}"
        
        recommendations = self.recommender_client.list_recommendations(parent=parent)
        
        for rec in recommendations:
            if rec.state.name == "ACTIVE":
                logger.info(f"Processing recommendation: {rec.name}")
                
                # Extract VM details
                vm_name = self.extract_vm_name(rec)
                zone = location
                
                # Check if safe to stop (add your logic)
                if self.is_safe_to_stop(vm_name, zone):
                    # Stop the VM
                    self.stop_vm(vm_name, zone)
                    
                    # Mark recommendation as succeeded
                    self.recommender_client.mark_recommendation_succeeded(
                        name=rec.name,
                        state_metadata={"automated": "true"}
                    )
                    logger.info(f"Stopped VM: {vm_name}")
                else:
                    logger.info(f"Skipped VM (not safe): {vm_name}")
    
    def extract_vm_name(self, recommendation):
        """Extract VM name from recommendation"""
        # Parse recommendation content
        # Implementation depends on recommendation structure
        pass
    
    def is_safe_to_stop(self, vm_name, zone):
        """Check if VM is safe to stop"""
        # Add your safety checks:
        # - Check labels (e.g., environment=dev)
        # - Check tags
        # - Check if part of managed instance group
        # - Check business hours
        return True  # Placeholder
    
    def stop_vm(self, vm_name, zone):
        """Stop a VM instance"""
        operation = self.compute_client.stop(
            project=self.project_id,
            zone=zone,
            instance=vm_name
        )
        operation.result()  # Wait for completion

# Usage
processor = RecommendationProcessor("your-project-id")
processor.process_idle_vm_recommendations("us-central1-a")
```

### 2. Recommendation Report Generator

```python
#!/usr/bin/env python3
"""
Generate weekly recommendation report
"""

from google.cloud import recommender_v1
from datetime import datetime
import csv

def generate_recommendation_report(project_id, output_file):
    """Generate CSV report of all recommendations"""
    client = recommender_v1.RecommenderClient()
    
    # List of recommenders to check
    recommenders = [
        "google.compute.instance.MachineTypeRecommender",
        "google.compute.instance.IdleResourceRecommender",
        "google.compute.disk.IdleResourceRecommender",
        "google.iam.policy.Recommender",
    ]
    
    locations = ["us-central1-a", "us-east1-b", "europe-west1-b"]
    
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([
            'Recommender', 'Location', 'Resource', 'Description',
            'Priority', 'Potential Savings', 'State'
        ])
        
        for recommender in recommenders:
            for location in locations:
                parent = f"projects/{project_id}/locations/{location}/recommenders/{recommender}"
                
                try:
                    recommendations = client.list_recommendations(parent=parent)
                    
                    for rec in recommendations:
                        savings = ""
                        if rec.primary_impact.cost_projection:
                            savings = f"${rec.primary_impact.cost_projection.cost.units}/month"
                        
                        writer.writerow([
                            recommender.split('.')[-1],
                            location,
                            rec.content.get('resource', 'N/A'),
                            rec.description,
                            rec.priority,
                            savings,
                            rec.state.name
                        ])
                except Exception as e:
                    print(f"Error processing {recommender} in {location}: {e}")
    
    print(f"Report generated: {output_file}")

# Usage
generate_recommendation_report(
    "your-project-id",
    f"recommendations_{datetime.now().strftime('%Y%m%d')}.csv"
)
```

---

## 📈 Tracking Savings

### Savings Dashboard Query

```sql
-- BigQuery query to track realized savings from recommendations

WITH recommendation_savings AS (
  SELECT
    DATE(timestamp) as date,
    recommender_type,
    resource_name,
    estimated_monthly_savings,
    status
  FROM `project.dataset.recommendation_tracking`
  WHERE status = 'APPLIED'
    AND DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
)

SELECT
  date,
  recommender_type,
  COUNT(*) as recommendations_applied,
  SUM(estimated_monthly_savings) as total_monthly_savings,
  SUM(estimated_monthly_savings) * 12 as annual_savings
FROM recommendation_savings
GROUP BY date, recommender_type
ORDER BY date DESC, total_monthly_savings DESC;

-- Summary by recommender type
SELECT
  recommender_type,
  COUNT(*) as total_applied,
  SUM(estimated_monthly_savings) as total_monthly_savings,
  AVG(estimated_monthly_savings) as avg_savings_per_recommendation
FROM recommendation_savings
GROUP BY recommender_type
ORDER BY total_monthly_savings DESC;
```

---

## ✅ Best Practices

### 1. Regular Review Schedule

```
Weekly:
  ✓ Review new high-priority recommendations
  ✓ Apply quick wins (idle resources)
  ✓ Track applied recommendations

Monthly:
  ✓ Comprehensive review of all recommendations
  ✓ Analyze trends and patterns
  ✓ Report savings to stakeholders
  ✓ Adjust automation rules

Quarterly:
  ✓ Review dismissed recommendations
  ✓ Evaluate automation effectiveness
  ✓ Update safety rules
  ✓ Strategic planning based on insights
```

### 2. Automation Guidelines

```
Auto-Apply (Low Risk):
  ✓ Idle resource deletion (dev/test environments)
  ✓ Snapshot cleanup (old snapshots)
  ✓ Unused static IP release

Manual Review (Medium Risk):
  ✓ VM right-sizing (production)
  ✓ Disk type changes
  ✓ IAM role changes

Always Manual (High Risk):
  ✓ Production resource deletion
  ✓ Database configuration changes
  ✓ Network security changes
```

### 3. Safety Checks

```
Before Applying Recommendations:
  ✓ Verify resource is not critical
  ✓ Check for dependencies
  ✓ Review change window
  ✓ Have rollback plan
  ✓ Test in non-production first
  ✓ Document changes
  ✓ Notify stakeholders
```

---

## 🎓 Next Steps

1. Review [Pricing Models](./6-Pricing-Models.md) to understand cost structure
2. Implement [Cost Allocation](./7-Cost-Allocation.md) for tracking
3. Follow [Best Practices](./8-Best-Practices.md) for enterprise cost management
4. Return to [Cost Optimization](./4-Cost-Optimization.md) for implementation strategies

---

**Last Updated:** March 2026
**Version:** 2.0
