
## 🌐 What is **AWS Neptune**?

**Amazon Neptune** is a **fully managed graph database service** that supports:

|Model Type|Query Language|
|---|---|
|**Property Graph**|Apache TinkerPop Gremlin|
|**RDF Graph**|SPARQL|

Neptune is designed for use cases like social graphs, recommendation engines, fraud detection, and knowledge graphs.

---

## ⚡ What are **Neptune Streams**?

**Neptune Streams** capture real-time changes made to the graph (inserts and deletes of nodes and edges) and send them in **chronological order**.

These streams allow you to:

- Monitor changes
    
- Replicate data
    
- Trigger events
    
- Integrate with **Lambda, Kinesis, or analytics systems**
    

---

## 🧾 Key Concepts

|Feature|Description|
|---|---|
|**ChangeLog Stream**|Time-ordered log of inserts/deletes to the graph|
|**Stream Endpoint**|REST endpoint to read stream records (`/sparql/streams`)|
|**TTL**|Records in stream are retained for **7 days**|
|**Format**|JSON with operation type (INSERT, DELETE), affected nodes/edges, timestamp|
|**Ordering**|Changes are ordered by commit timestamp|

---

## 🧪 How to **Enable Neptune Streams**

You must **enable the stream** when creating the Neptune DB cluster or by modifying it.

### Option 1: **Console**

1. Go to **Amazon Neptune > Databases**
    
2. Select your cluster > **Modify**
    
3. Set **Neptune Streams** to `enabled`
    
4. Save and apply
    

### Option 2: **CLI**

```bash
aws neptune modify-db-cluster \
  --db-cluster-identifier my-cluster \
  --enable-streaming-engine \
  --apply-immediately
```

---

## 🔍 Sample Stream Record (JSON)

```json
{
  "commitTimestamp": 1687771234567,
  "eventId": "event-12345",
  "data": [
    {
      "op": "ADD",
      "type": "v",
      "id": "user123",
      "label": "User",
      "properties": {
        "name": "Alice",
        "joined": "2023-01-01"
      }
    },
    {
      "op": "ADD",
      "type": "e",
      "id": "edge567",
      "from": "user123",
      "to": "user456",
      "label": "follows"
    }
  ]
}
```

---

## 📥 How to **Read Stream Records**

Neptune exposes a REST endpoint for reading the stream:

### Endpoint Format

```
https://<neptune-endpoint>:8182/pg/streams
```

### Required Parameters:

|Param|Description|
|---|---|
|`commitNum`|The commit timestamp to start from|
|`limit`|Number of records to fetch (optional)|

### Example Request:

```bash
curl -X GET \
  "https://<neptune-endpoint>:8182/pg/streams?commitNum=1687771000000&limit=100" \
  -H "Accept: application/json"
```

> Note: You need to run this inside your VPC or through a Lambda/EC2 instance in the same VPC.

---

## 🔁 Integration Use Cases

|Use Case|Description|
|---|---|
|**Change Tracking**|Detect and log graph changes|
|**Streaming Analytics**|Send changes to Kinesis → Lambda → Elasticsearch|
|**Triggering Workflows**|Fire events on edge creation (e.g., notify users)|
|**Replication**|Sync Neptune changes to another data store|

---

## 🧬 Event Processing Architecture

```
[Neptune Streams]
        ↓
   [Lambda Function]
        ↓
   [SQS / SNS / Kinesis]
        ↓
 [Microservices / Analytics / Alerting]
```

- Use **Lambda** to poll Neptune Stream regularly
    
- Parse JSON and forward to downstream services
    
- Example: Send insert events to Slack, delete events to audit log
    

---

## 🧰 Example: Lambda to Poll Streams

```python
import requests
import boto3

NEPTUNE_ENDPOINT = 'https://<neptune-endpoint>:8182'
COMMIT_NUM = '1687770000000'  # store last read timestamp somewhere

def lambda_handler(event, context):
    url = f"{NEPTUNE_ENDPOINT}/pg/streams?commitNum={COMMIT_NUM}&limit=100"
    response = requests.get(url, verify=False)

    records = response.json().get('records', [])
    for record in records:
        process_record(record)

def process_record(record):
    print("Change:", record['op'], "on", record['id'])
    # Further processing...
```

---

## 🛡️ Security

- Streams are **read-only** and **VPC-only** (no internet access)
    
- Secure with IAM policies, security groups, and NACLs
    
- Best practice: Use **PrivateLink**, **VPC Endpoints**, or **Bastion host** to access
    

---

## 📊 Monitoring & Metrics

- Monitor with **CloudWatch Logs** (Lambda logs)
    
- Watch **CPU**, **Commit Latency**, and **StreamLatency** metrics
    
- Audit access via **CloudTrail**
    

---

## 🧪 Terraform (Enable Streams)

```hcl
resource "aws_neptune_cluster" "example" {
  cluster_identifier      = "my-neptune-cluster"
  engine                  = "neptune"
  neptune_streams_enabled = true
  iam_database_authentication_enabled = true
}
```

---

## ❗ Limitations

|Limitation|Detail|
|---|---|
|TTL|Records only retained for 7 days|
|No "update" op|Only `ADD` or `REMOVE` operations|
|Can't use from outside VPC|Must run inside VPC or VPN|
|Can't replay entire history|Only supports from a commit point|

---

## ✅ Summary

|Feature|Description|
|---|---|
|Streams|Change log of inserts/deletes|
|API Access|RESTful polling (`/streams`)|
|Retention|7 days (TTL)|
|Best Use Case|Change detection, analytics, ETL|
|Integration|Lambda, Kinesis, SQS, SNS, etc.|

---
