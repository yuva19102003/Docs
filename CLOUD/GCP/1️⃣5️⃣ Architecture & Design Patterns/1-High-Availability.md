# High Availability Architecture

Design patterns for building highly available systems on GCP.

---

## Overview

High availability ensures your applications remain operational and accessible even during failures.

---

## Availability Tiers

```
Single Zone:     99.5%   (43.8 hours downtime/year)
Multi-Zone:      99.99%  (52.6 minutes downtime/year)
Multi-Region:    99.999% (5.26 minutes downtime/year)
```

---

## Multi-Zone Architecture

**Regional GKE Cluster:**
```bash
# Create regional cluster (3 zones)
gcloud container clusters create ha-cluster \
  --region=us-central1 \
  --num-nodes=1 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10 \
  --enable-autorepair \
  --enable-autoupgrade
```

**Regional Cloud SQL:**
```bash
# Create HA instance
gcloud sql instances create ha-db \
  --database-version=POSTGRES_14 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --availability-type=REGIONAL \
  --backup-start-time=03:00
```

**Architecture:**
```
┌─────────────────────────────────────┐
│  Region: us-central1                │
├─────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐        │
│  │ Zone A   │  │ Zone B   │        │
│  │ • GKE    │  │ • GKE    │        │
│  │ • SQL    │  │ • SQL    │        │
│  │ Primary  │  │ Replica  │        │
│  └──────────┘  └──────────┘        │
│         ▲             ▲             │
│         └──────┬──────┘             │
│    Regional Load Balancer           │
└─────────────────────────────────────┘
```

---

## Multi-Region Architecture

**Global Load Balancer:**
```bash
# Create global HTTP(S) load balancer
gcloud compute backend-services create global-backend \
  --global \
  --protocol=HTTP \
  --health-checks=health-check \
  --enable-cdn

# Add backends in multiple regions
gcloud compute backend-services add-backend global-backend \
  --global \
  --instance-group=us-central1-ig \
  --instance-group-region=us-central1

gcloud compute backend-services add-backend global-backend \
  --global \
  --instance-group=europe-west1-ig \
  --instance-group-region=europe-west1
```

**Cloud Spanner (Global Database):**
```bash
# Create multi-region instance
gcloud spanner instances create global-db \
  --config=nam-eur-asia1 \
  --nodes=3 \
  --description="Global database"
```

**Architecture:**
```
        Global Load Balancer
              (Anycast)
                 |
    ┌────────────┼────────────┐
    v            v            v
┌────────┐  ┌────────┐  ┌────────┐
│us-east1│  │eu-west1│  │asia-se1│
│ • GKE  │  │ • GKE  │  │ • GKE  │
└────────┘  └────────┘  └────────┘
    |            |            |
    └────────────┼────────────┘
                 v
          Cloud Spanner
           (Global DB)
```

---

## Health Checks

**HTTP Health Check:**
```bash
gcloud compute health-checks create http health-check \
  --port=8080 \
  --request-path=/health \
  --check-interval=10s \
  --timeout=5s \
  --unhealthy-threshold=3 \
  --healthy-threshold=2
```

**Application Health Endpoint:**
```python
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

@app.route('/health')
def health():
    try:
        # Check database connection
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        conn.close()
        
        return jsonify({"status": "healthy"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 503
```

---

## Graceful Degradation

**Circuit Breaker Pattern:**
```python
import time
from functools import wraps

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if self.state == 'OPEN':
                if time.time() - self.last_failure_time > self.timeout:
                    self.state = 'HALF_OPEN'
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                if self.state == 'HALF_OPEN':
                    self.state = 'CLOSED'
                    self.failure_count = 0
                return result
            except Exception as e:
                self.failure_count += 1
                self.last_failure_time = time.time()
                
                if self.failure_count >= self.failure_threshold:
                    self.state = 'OPEN'
                
                raise e
        
        return wrapper
```

---

## Backup and Recovery

**Automated Backups:**
```bash
# Cloud SQL automated backups
gcloud sql instances patch my-instance \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --retained-backups-count=7

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
        "action": {"type": "Delete"},
        "condition": {"age": 365}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://backup-bucket
```

---

## Disaster Recovery

**RTO and RPO:**
```
Strategy          RTO        RPO        Cost
─────────────────────────────────────────────
Backup/Restore    Hours      Hours      Low
Pilot Light       Minutes    Minutes    Medium
Warm Standby      Seconds    Seconds    High
Hot Standby       None       None       Very High
```

**Cross-Region Replication:**
```bash
# Cloud Storage cross-region replication
gsutil mb -c STANDARD -l US gs://primary-bucket
gsutil mb -c STANDARD -l EU gs://replica-bucket

# Set up replication
gsutil rewrite -r gs://primary-bucket/* gs://replica-bucket/
```

---

## Best Practices

✓ Use regional resources for HA  
✓ Implement health checks  
✓ Design for failure  
✓ Automate recovery  
✓ Test failover regularly  
✓ Monitor availability metrics  
✓ Implement graceful degradation  
✓ Document recovery procedures  

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
