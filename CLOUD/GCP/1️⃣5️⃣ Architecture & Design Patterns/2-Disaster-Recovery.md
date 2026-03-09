# Disaster Recovery

Strategies for business continuity and data protection.

---

## Overview

Disaster Recovery (DR) ensures your applications and data can be recovered in case of catastrophic failures.

---

## Key Metrics

**RTO (Recovery Time Objective):**
- Maximum acceptable downtime
- How quickly you need to recover

**RPO (Recovery Point Objective):**
- Maximum acceptable data loss
- How much data you can afford to lose

---

## DR Strategies

### 1. Backup and Restore

**Characteristics:**
- RTO: Hours to days
- RPO: Hours
- Cost: Low
- Complexity: Low

**Architecture:**
```
Production (us-central1)
    |
    | Automated Backups
    v
┌─────────────────────┐
│  Cloud Storage      │
│  (Multi-region)     │
└─────────────────────┘
    |
    | Manual Restore
    v
DR Site (us-east1)
```

**Implementation:**
```bash
# Automated Cloud SQL backups
gcloud sql instances patch prod-db \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --retained-backups-count=30

# GCS lifecycle for backups
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://backup-bucket
```

---

### 2. Pilot Light

**Characteristics:**
- RTO: Minutes to hours
- RPO: Minutes
- Cost: Medium
- Complexity: Medium

**Architecture:**
```
Production (us-central1)          DR (us-east1)
┌─────────────────────┐          ┌─────────────────────┐
│  • Full Stack       │          │  • Minimal Stack    │
│  • Active           │  ──────> │  • Database Only    │
│  • Auto-scaling     │  Repl.   │  • Standby          │
└─────────────────────┘          └─────────────────────┘
                                          |
                                    (On Failure)
                                          v
                                  Scale Up & Activate
```

**Implementation:**
```bash
# Primary region
gcloud sql instances create prod-db \
  --region=us-central1 \
  --availability-type=REGIONAL

# DR region - read replica
gcloud sql instances create dr-db \
  --master-instance-name=prod-db \
  --region=us-east1

# Promote replica on failure
gcloud sql instances promote-replica dr-db
```

---

### 3. Warm Standby

**Characteristics:**
- RTO: Minutes
- RPO: Seconds to minutes
- Cost: High
- Complexity: High

**Architecture:**
```
Production (us-central1)          DR (us-east1)
┌─────────────────────┐          ┌─────────────────────┐
│  • Full Stack       │          │  • Full Stack       │
│  • Active           │  ──────> │  • Running          │
│  • 100% Capacity    │  Sync    │  • 50% Capacity     │
└─────────────────────┘          └─────────────────────┘
         |                                |
         └────────────┬───────────────────┘
                      v
              Global Load Balancer
              (Failover on failure)
```

**Implementation:**
```bash
# Multi-region GKE
gcloud container clusters create prod-cluster \
  --region=us-central1 \
  --num-nodes=3

gcloud container clusters create dr-cluster \
  --region=us-east1 \
  --num-nodes=2

# Global load balancer
gcloud compute backend-services create global-backend \
  --global \
  --health-checks=health-check

gcloud compute backend-services add-backend global-backend \
  --global \
  --instance-group=us-central1-ig \
  --instance-group-region=us-central1

gcloud compute backend-services add-backend global-backend \
  --global \
  --instance-group=us-east1-ig \
  --instance-group-region=us-east1
```

---

### 4. Hot Standby (Active-Active)

**Characteristics:**
- RTO: None (automatic)
- RPO: None (synchronous)
- Cost: Very High
- Complexity: Very High

**Architecture:**
```
        Global Load Balancer
              (Anycast)
                 |
    ┌────────────┼────────────┐
    v            v            v
┌────────┐  ┌────────┐  ┌────────┐
│us-east1│  │eu-west1│  │asia-se1│
│ Active │  │ Active │  │ Active │
│ 100%   │  │ 100%   │  │ 100%   │
└────┬───┘  └───┬────┘  └───┬────┘
     |          |            |
     └──────────┼────────────┘
                v
         Cloud Spanner
         (Global DB)
```

**Implementation:**
```bash
# Cloud Spanner multi-region
gcloud spanner instances create global-db \
  --config=nam-eur-asia1 \
  --nodes=3 \
  --description="Global database"

# Regional GKE clusters
for region in us-east1 eu-west1 asia-southeast1; do
  gcloud container clusters create prod-$region \
    --region=$region \
    --num-nodes=3
done

# Global load balancer with health checks
gcloud compute health-checks create http global-health \
  --port=8080 \
  --request-path=/health
```

---

## Database DR Strategies

### Cloud SQL

**Cross-Region Replica:**
```bash
# Create replica in different region
gcloud sql instances create dr-replica \
  --master-instance-name=prod-instance \
  --region=us-east1

# Promote to standalone on failure
gcloud sql instances promote-replica dr-replica
```

### Cloud Spanner

**Multi-Region Configuration:**
```bash
# Automatic multi-region replication
gcloud spanner instances create multi-region-db \
  --config=nam-eur-asia1 \
  --nodes=3
```

### Firestore

**Multi-Region by Default:**
```bash
# Firestore automatically replicates across regions
# No additional configuration needed
```

---

## Application DR

**Terraform for Infrastructure:**
```hcl
# main.tf
module "primary" {
  source = "./modules/infrastructure"
  region = "us-central1"
  environment = "production"
}

module "dr" {
  source = "./modules/infrastructure"
  region = "us-east1"
  environment = "dr"
}

# Deploy to both regions
terraform apply
```

**Container Images:**
```bash
# Multi-region artifact registry
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us \
  --description="Multi-region repository"

# Push image (automatically replicated)
docker push us-docker.pkg.dev/PROJECT/my-repo/app:latest
```

---

## Testing DR

**DR Drill Checklist:**
```markdown
1. Pre-Drill
   - [ ] Document current state
   - [ ] Notify stakeholders
   - [ ] Prepare rollback plan

2. Failover
   - [ ] Trigger failover
   - [ ] Verify DNS propagation
   - [ ] Test application functionality
   - [ ] Verify data consistency

3. Validation
   - [ ] Run smoke tests
   - [ ] Check monitoring
   - [ ] Verify backups
   - [ ] Test rollback

4. Post-Drill
   - [ ] Document findings
   - [ ] Update procedures
   - [ ] Schedule next drill
```

**Automated Testing:**
```bash
#!/bin/bash
# dr-test.sh

# 1. Promote DR database
gcloud sql instances promote-replica dr-db

# 2. Update DNS
gcloud dns record-sets transaction start --zone=my-zone
gcloud dns record-sets transaction add \
  --name=app.example.com \
  --type=A \
  --zone=my-zone \
  --ttl=300 \
  DR_IP_ADDRESS
gcloud dns record-sets transaction execute --zone=my-zone

# 3. Run health checks
curl -f https://app.example.com/health || exit 1

# 4. Run integration tests
./run-tests.sh

echo "DR test completed successfully"
```

---

## Backup Strategies

**3-2-1 Rule:**
- 3 copies of data
- 2 different media types
- 1 offsite copy

**Implementation:**
```bash
# Primary data (production)
# Copy 1: Cloud SQL automated backups
# Copy 2: Export to Cloud Storage
gcloud sql export sql prod-db \
  gs://backup-bucket/$(date +%Y%m%d)/backup.sql \
  --database=mydb

# Copy 3: Cross-region replication
gsutil rsync -r gs://backup-bucket gs://backup-bucket-dr
```

---

## Monitoring DR Readiness

```bash
# Create alert for replication lag
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Replication Lag" \
  --condition-threshold-value=300 \
  --condition-filter='metric.type="cloudsql.googleapis.com/database/replication/replica_lag"'

# Monitor backup success
gcloud logging read \
  'resource.type="cloudsql_database" AND protoPayload.methodName="cloudsql.instances.backup"' \
  --limit=10
```

---

## Best Practices

✓ Define clear RTO and RPO  
✓ Regular DR testing  
✓ Automate failover  
✓ Document procedures  
✓ Monitor replication lag  
✓ Test backup restoration  
✓ Use infrastructure as code  
✓ Implement health checks  

---

## DR Runbook Template

```markdown
# Disaster Recovery Runbook

## Trigger Conditions
- Primary region unavailable
- Data corruption detected
- Security breach

## Pre-Failover Checklist
- [ ] Verify incident severity
- [ ] Notify stakeholders
- [ ] Check DR site health
- [ ] Review recent backups

## Failover Steps
1. Promote DR database
2. Update DNS records
3. Scale up DR resources
4. Verify application health
5. Monitor for issues

## Rollback Steps
1. Verify primary region health
2. Sync data from DR to primary
3. Update DNS to primary
4. Scale down DR resources

## Post-Incident
- [ ] Document incident
- [ ] Update procedures
- [ ] Schedule post-mortem
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
