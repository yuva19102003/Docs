
## 🧠 What is Amazon QLDB?

**Amazon QLDB** is a **serverless ledger database** purpose-built for recording changes to your application data. It keeps a **complete, immutable history** of all changes and provides **cryptographic proof** that the history hasn't been tampered with.

|Feature|Description|
|---|---|
|**Ledger database**|Immutable and transparent journal of data changes|
|**Cryptographic hash**|Verifiable integrity using SHA-256 Merkle trees|
|**SQL-compatible**|Uses **PartiQL** (SQL-like language for semi-structured data)|
|**Immutable**|Data cannot be updated or deleted from the journal|
|**Fully managed**|No provisioning, scales automatically|

---

## 🧾 Use Cases

- Financial transactions (e.g., banking, accounting)
    
- Supply chain tracking
    
- Insurance claim history
    
- HR records
    
- Audit trails
    
- Vehicle registration (like DMV)
    

---

## 🧩 QLDB Architecture

```
                          +-----------------------+
  PartiQL Queries  <----> |   Amazon QLDB Ledger  |
                          +-----------------------+
                                    |
                          +-----------------------+
                          | Journal (immutable log)|
                          +-----------------------+
                                    |
                          | Merkle Tree (SHA-256) |
                          +-----------------------+
```

---

## ⚙️ Key Concepts

|Term|Description|
|---|---|
|**Ledger**|A QLDB database that contains tables and an immutable journal|
|**Journal**|An **append-only log** of every transaction|
|**Revision**|A version of a document at a point in time|
|**Digest**|SHA-256 hash representing the current state of the journal|
|**Proof**|JSON document to verify that a revision is part of a digest|
|**PartiQL**|SQL-compatible query language used in QLDB|

---

## 🚀 Getting Started with QLDB

### Step 1: Create a Ledger

#### Using Console:

- Go to QLDB > **Create ledger**
    
- Name it: `vehicle_ledger`
    
- Permissions mode: **Standard**
    
- Encryption: Enable KMS (default)
    

#### CLI:

```bash
aws qldb create-ledger \
  --name vehicle_ledger \
  --permissions-mode STANDARD
```

---

### Step 2: Create a Table

```sql
CREATE TABLE VehicleRegistration;
```

### Step 3: Insert a Document

```sql
INSERT INTO VehicleRegistration {
  'VIN': '1HGCM82633A004352',
  'Owner': 'Alice',
  'Make': 'Honda',
  'Model': 'Civic',
  'Year': 2019
};
```

> Each insert creates a new **revision** stored in the **journal**.

---

### Step 4: Query Data

```sql
SELECT * FROM VehicleRegistration;
```

> PartiQL lets you run standard SQL-like queries on **JSON documents**.

---

### Step 5: Update Data (Appends to Journal)

```sql
UPDATE VehicleRegistration
SET Owner = 'Bob'
WHERE VIN = '1HGCM82633A004352';
```

> Old data is **never deleted**, only the current version is updated. All revisions are recorded.

---

## 🔐 Cryptographic Verification (Digest & Proof)

### ✅ Get Digest (latest hash):

```bash
aws qldb get-digest \
  --name vehicle_ledger
```

### 🔍 Get Revision Proof:

```bash
aws qldb get-revision \
  --name vehicle_ledger \
  --block-address '...' \
  --document-id '...'
```

> Combine with digest to verify document **was not tampered**.

---

## 🧪 Query History (Immutable Audit Trail)

```sql
SELECT * FROM history(VehicleRegistration)
WHERE VIN = '1HGCM82633A004352';
```

This shows:

- All changes to a document
    
- When changes occurred
    
- Who made the change (if IAM integrated)
    

---

## 🧰 Integrations

|Service|Integration Capability|
|---|---|
|**Lambda**|Write/read from QLDB using Boto3/SDK|
|**Step Functions**|Use QLDB for audit logging or approvals|
|**IAM**|Fine-grained access control (standard mode)|
|**CloudTrail**|Audit QLDB API access|
|**Kinesis**|Send QLDB digests or events downstream (manually via Lambda)|

---

## 💲 Pricing

|Pricing Element|Cost (approx)|
|---|---|
|**Journal writes**|$0.03 per 1 million write I/Os|
|**Data storage**|$0.10 per GB-month|
|**Indexed storage**|$0.07 per GB-month|
|**Indexed reads**|$0.03 per 1 million read I/Os|

---

## 🛡️ Security

- **Encryption at rest**: AWS KMS
    
- **Encryption in transit**: TLS
    
- **IAM Policies**: Standard or Extended Permissions Mode
    
- **VPC access**: Not yet supported (public endpoint only, use Lambda proxy)
    

---

## 🧠 Example IAM Policy for Ledger Access

```json
{
  "Effect": "Allow",
  "Action": [
    "qldb:SendCommand",
    "qldb:ExecuteStatement"
  ],
  "Resource": "arn:aws:qldb:us-east-1:123456789012:ledger/vehicle_ledger"
}
```

---

## 🧰 SDK Example (Python + Boto3)

```python
import boto3

qldb = boto3.client('qldb-session')

# Execute simple statement
response = qldb.send_command(
    SessionToken='token',
    ExecuteStatement={
        'Statement': 'SELECT * FROM VehicleRegistration'
    }
)
```

> Recommended: Use the [QLDB driver](https://docs.aws.amazon.com/qldb/latest/developerguide/getting-started.driver.html) for higher-level APIs.

---

## 📦 Terraform Support (Basic Example)

```hcl
resource "aws_qldb_ledger" "vehicle_ledger" {
  name              = "vehicle_ledger"
  permissions_mode  = "STANDARD"
  deletion_protection = false
}
```

---

## ❗ Limitations

|Limitation|Description|
|---|---|
|Max document size|128 KB|
|No joins or subqueries|PartiQL has limited relational support|
|No VPC/private access|Must use public endpoint with IAM|
|No TTL or auto-purge|Manual archival/deletion required|
|Write-only journal|Can't update or delete historical records|

---

## ✅ Summary

|Feature|Description|
|---|---|
|Type|Ledger database with immutable history|
|Query Language|PartiQL (SQL-like for JSON)|
|Cryptographic|SHA-256 Merkle tree verification|
|Storage|Journal + indexed documents|
|Audit Trail|Full version history per record|
|Use Case|Compliance, financial records, audit logs|

---
