# GCP Solution Architect Interview Questions

Comprehensive collection of interview questions with detailed answers.

---

## Table of Contents

1. [Fundamentals](#fundamentals)
2. [Compute](#compute)
3. [Networking](#networking)
4. [Storage & Databases](#storage--databases)
5. [Security](#security)
6. [Architecture & Design](#architecture--design)
7. [Scenario-Based Questions](#scenario-based-questions)

---

## Fundamentals

### Q1: What are the main differences between GCP, AWS, and Azure?

**Answer:**

**GCP Strengths:**
- Best-in-class Kubernetes (GKE)
- Superior data analytics (BigQuery)
- Global private network
- Per-second billing
- Automatic sustained use discounts
- Strong in ML/AI (Vertex AI)

**Key Differences:**
- Network: GCP uses private fiber network vs AWS/Azure public internet
- Billing: GCP per-second vs AWS/Azure per-minute/hour
- Discounts: GCP automatic vs AWS/Azure reserved instances
- Kubernetes: GKE is native vs EKS/AKS

---

### Q2: Explain GCP's resource hierarchy.

**Answer:**

```
Organization
    ↓
Folders (optional, can be nested)
    ↓
Projects
    ↓
Resources (VMs, databases, etc.)
```

**Key Points:**
- IAM policies inherit downward
- Billing is at project level
- Projects are isolation boundaries
- Organization is the root node
- Folders help organize by department/environment

**Example:**
```
Acme Corp (Organization)
├── Production (Folder)
│   ├── Web App (Project)
│   └── API (Project)
└── Development (Folder)
    └── Test (Project)
```

---

### Q3: What is the difference between regions and zones?

**Answer:**

**Region:**
- Geographic location (e.g., us-central1)
- Contains multiple zones
- Independent failure domains
- ~40+ regions globally

**Zone:**
- Deployment area within region (e.g., us-central1-a)
- Single failure domain
- Low latency between zones in same region
- 3+ zones per region

**Best Practices:**
- Multi-zone for HA (99.99%)
- Multi-region for global apps (99.999%)
- Regional resources for HA
- Zonal resources for cost optimization

---

## Compute

### Q4: When would you choose Cloud Run over GKE?

**Answer:**

**Choose Cloud Run when:**
- Stateless HTTP services
- Simple deployment needs
- Auto-scaling to zero required
- Pay-per-use pricing preferred
- No Kubernetes expertise
- Quick time to market

**Choose GKE when:**
- Complex microservices
- Need full Kubernetes features
- Stateful applications
- Custom networking required
- Multi-cloud portability
- Advanced orchestration needs

**Example Scenario:**
- API Gateway → Cloud Run
- Microservices Platform → GKE

---

### Q5: Explain the difference between preemptible and spot VMs.

**Answer:**

**Preemptible VMs (Legacy):**
- Up to 80% discount
- Max 24-hour runtime
- Can be preempted anytime
- 30-second shutdown notice

**Spot VMs (Current):**
- Up to 91% discount
- No maximum runtime
- Can be preempted anytime
- Dynamic pricing
- Better for batch workloads

**Use Cases:**
- Batch processing
- Fault-tolerant workloads
- Dataproc secondary workers
- CI/CD build agents
- Data processing pipelines

**Not Suitable For:**
- Databases
- Production web servers
- Stateful applications

---

## Networking

### Q6: Explain VPC peering vs Shared VPC.

**Answer:**

**VPC Peering:**
- Connects two VPCs
- Private RFC 1918 connectivity
- No overlapping IP ranges
- Transitive peering not supported
- Cross-project, cross-organization

**Shared VPC:**
- Centralized network management
- Multiple projects share one VPC
- Host project owns network
- Service projects use network
- Better for organizations

**When to Use:**
```
VPC Peering:
  • Connect different organizations
  • Temporary connections
  • Simple point-to-point

Shared VPC:
  • Enterprise environments
  • Centralized network team
  • Multiple projects, one network
```

---

### Q7: How does Cloud Load Balancing work?

**Answer:**

**Types:**

1. **Global HTTP(S) Load Balancer**
   - Layer 7
   - Anycast IP
   - SSL termination
   - URL-based routing
   - Global backends

2. **Regional Network Load Balancer**
   - Layer 4
   - TCP/UDP
   - Regional only
   - Pass-through

3. **Internal Load Balancer**
   - Private IPs only
   - Regional
   - Layer 4 or Layer 7

**Key Features:**
- Auto-scaling
- Health checks
- Session affinity
- CDN integration
- SSL certificates

---

## Storage & Databases

### Q8: When would you use Cloud Spanner vs Cloud SQL?

**Answer:**

**Cloud Spanner:**
- Global distribution needed
- Strong consistency required
- Horizontal scaling
- 99.999% availability
- Multi-region transactions
- Higher cost

**Cloud SQL:**
- Regional application
- Traditional SQL workload
- Vertical scaling
- 99.95% availability
- Lower cost
- Familiar MySQL/PostgreSQL

**Decision Matrix:**
```
Global app + Strong consistency → Cloud Spanner
Regional app + Cost-sensitive → Cloud SQL
Financial transactions → Cloud Spanner
Web application → Cloud SQL
```

---

### Q9: Explain BigQuery partitioning and clustering.

**Answer:**

**Partitioning:**
- Divides table into segments
- Based on column (date, timestamp, integer)
- Reduces data scanned
- Improves query performance
- Lowers costs

```sql
CREATE TABLE dataset.partitioned_table
PARTITION BY DATE(timestamp)
AS SELECT * FROM source;
```

**Clustering:**
- Sorts data within partitions
- Based on multiple columns
- Co-locates related data
- Further improves performance

```sql
CREATE TABLE dataset.clustered_table
PARTITION BY DATE(timestamp)
CLUSTER BY user_id, country
AS SELECT * FROM source;
```

**Best Practice:**
- Partition by date/timestamp
- Cluster by frequently filtered columns
- Use both for optimal performance

---

## Security

### Q10: Explain the principle of least privilege in GCP.

**Answer:**

**Concept:**
- Grant minimum permissions needed
- Use predefined roles when possible
- Create custom roles for specific needs
- Regular access reviews

**Implementation:**

```bash
# Bad: Too broad
gcloud projects add-iam-policy-binding PROJECT \
  --member=user:dev@example.com \
  --role=roles/editor

# Good: Specific permissions
gcloud projects add-iam-policy-binding PROJECT \
  --member=user:dev@example.com \
  --role=roles/compute.instanceAdmin.v1
```

**Best Practices:**
- Use service accounts for applications
- Avoid primitive roles (Owner, Editor, Viewer)
- Use IAM conditions for context-aware access
- Enable audit logging
- Regular permission reviews

---

### Q11: How do you secure secrets in GCP?

**Answer:**

**Secret Manager:**
```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
name = f"projects/{project}/secrets/{secret}/versions/latest"
response = client.access_secret_version(request={"name": name})
secret_value = response.payload.data.decode("UTF-8")
```

**Best Practices:**
- Never commit secrets to code
- Use Secret Manager for all secrets
- Rotate secrets regularly
- Use IAM for access control
- Enable audit logging
- Use Workload Identity (no keys)

**Integration:**
- Cloud Run: Mount as env var or volume
- GKE: Use Workload Identity
- Cloud Functions: Access via SDK
- Compute Engine: Use metadata server

---

## Architecture & Design

### Q12: Design a highly available web application on GCP.

**Answer:**

**Architecture:**
```
Internet
    ↓
Cloud Armor (DDoS protection)
    ↓
Global Load Balancer (HTTPS)
    ↓
Cloud CDN (Static content)
    ↓
┌─────────────────────────────┐
│  Regional GKE Cluster       │
│  (us-central1)              │
│  ┌──────────┐  ┌──────────┐│
│  │ Zone A   │  │ Zone B   ││
│  │ • Pods   │  │ • Pods   ││
│  └──────────┘  └──────────┘│
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│  Cloud SQL (Regional)       │
│  • Primary (Zone A)         │
│  • Replica (Zone B)         │
└─────────────────────────────┘
    ↓
Cloud Storage (Multi-region)
```

**Key Components:**
- Multi-zone GKE for HA
- Regional Cloud SQL with replica
- Global load balancer
- Cloud CDN for performance
- Cloud Armor for security
- Monitoring and logging

**SLA:** 99.99% availability

---

### Q13: How would you migrate a monolithic application to microservices on GCP?

**Answer:**

**Strategy: Strangler Fig Pattern**

**Phase 1: Assessment**
- Identify service boundaries
- Map dependencies
- Define APIs
- Plan data migration

**Phase 2: Incremental Migration**
```
Monolith → API Gateway → New Microservices
   ↓                          ↓
Old DB  ←─── Sync ────→  New DBs
```

**Phase 3: Implementation**
1. Deploy API Gateway (Cloud Endpoints)
2. Extract one service at a time
3. Deploy to Cloud Run/GKE
4. Route traffic gradually
5. Migrate data
6. Decommission old code

**Tools:**
- Cloud Run for stateless services
- GKE for complex services
- Cloud SQL/Spanner for databases
- Pub/Sub for async communication
- Cloud Build for CI/CD

---

## Scenario-Based Questions

### Q14: Your application is experiencing high latency. How do you troubleshoot?

**Answer:**

**Step 1: Identify the Problem**
```bash
# Check Cloud Monitoring
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_latencies"'

# Check Cloud Trace
# View distributed traces in console
```

**Step 2: Common Causes**
- Database queries (use Cloud SQL Insights)
- External API calls (check Cloud Trace)
- Cold starts (increase min instances)
- Network latency (use Cloud CDN)
- Resource constraints (check CPU/memory)

**Step 3: Solutions**
```bash
# Add caching
gcloud redis instances create cache \
  --size=1 \
  --region=us-central1

# Optimize database
CREATE INDEX idx_user_id ON users(user_id);

# Increase resources
gcloud run services update my-service \
  --memory=2Gi \
  --cpu=2 \
  --min-instances=1
```

---

### Q15: Design a real-time analytics pipeline.

**Answer:**

**Architecture:**
```
IoT Devices / Apps
    ↓
Pub/Sub (Ingestion)
    ↓
Dataflow (Stream Processing)
    ↓
┌─────────┬─────────┐
│         │         │
v         v         v
BigQuery  Bigtable  Pub/Sub
(Analytics) (Hot)   (Alerts)
```

**Implementation:**

1. **Ingestion:**
```python
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('project', 'events')

# Publish event
data = json.dumps(event).encode('utf-8')
publisher.publish(topic_path, data)
```

2. **Processing:**
```python
import apache_beam as beam

(pipeline
 | 'Read' >> beam.io.ReadFromPubSub(subscription=sub)
 | 'Parse' >> beam.Map(parse_json)
 | 'Window' >> beam.WindowInto(window.FixedWindows(60))
 | 'Aggregate' >> beam.CombinePerKey(sum)
 | 'Write' >> beam.io.WriteToBigQuery(table))
```

3. **Analysis:**
```sql
SELECT
  TIMESTAMP_TRUNC(timestamp, HOUR) as hour,
  COUNT(*) as event_count,
  AVG(value) as avg_value
FROM dataset.events
WHERE DATE(timestamp) = CURRENT_DATE()
GROUP BY hour
ORDER BY hour DESC;
```

---

## Tips for Interview Success

✅ Understand trade-offs between services  
✅ Know pricing models  
✅ Practice designing architectures  
✅ Understand security best practices  
✅ Know when to use each service  
✅ Be familiar with gcloud commands  
✅ Understand networking concepts  
✅ Practice scenario-based questions  

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
