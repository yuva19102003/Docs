
## 🧠 What is Amazon Timestream?

Amazon **Timestream** is a **fully managed**, **purpose-built time series database** optimized for data such as application metrics, IoT sensor data, and DevOps monitoring logs.

|Feature|Description|
|---|---|
|**Time series optimized**|Stores data with time-based partitions, ingestion, and compression|
|**Serverless**|No servers or capacity planning required|
|**Multi-tier storage**|Data moves from memory → magnetic automatically (configurable retention)|
|**Fast queries**|Optimized query engine for time series analytics (aggregations, filters)|
|**SQL-based**|Uses **Timestream Query Language (subset of SQL)**|

---

## 📊 Use Cases

- Application performance monitoring (APM)
    
- Infrastructure and system metrics (CPU, memory, latency)
    
- IoT sensor data (temperature, humidity, GPS)
    
- Business KPIs over time
    
- Event-driven architecture metrics
    

---

## ⚙️ Architecture Overview

```
                    +----------------------------+
     Data Sources → |   Amazon Timestream       | ← Queries via SDK / CLI / Console
                    +----------------------------+
                           ↓            ↓
              Memory Store       Magnetic Store
              (fast access)       (cheap, historical)
```

---

## 🔧 Key Concepts

|Concept|Description|
|---|---|
|**Database**|Logical group of tables|
|**Table**|Stores time series data in dimensions, measures, and time|
|**Measure**|The numeric or string value being recorded (e.g., temperature)|
|**Dimension**|Metadata that describes the source (e.g., device_id, region)|
|**Time**|The timestamp of the measurement|
|**Memory store**|Fast, in-memory, short-term storage|
|**Magnetic store**|Long-term, cost-efficient storage|

---

## 🏗️ Creating a Timestream Database and Table

### Step 1: Create a Database

#### Using CLI

```bash
aws timestream-write create-database \
  --database-name MyIoTDB
```

---

### Step 2: Create a Table

```bash
aws timestream-write create-table \
  --database-name MyIoTDB \
  --table-name SensorMetrics \
  --retention-properties MemoryStoreRetentionPeriodInHours=24,MagneticStoreRetentionPeriodInDays=7
```

- Data stays in memory for 24 hours, then moves to magnetic storage for 7 days.
    

---

## 📝 Sample Record Format

A Timestream record contains:

```json
{
  "Dimensions": [
    { "Name": "device_id", "Value": "sensor-001" },
    { "Name": "location", "Value": "factory-1" }
  ],
  "MeasureName": "temperature",
  "MeasureValue": "31.2",
  "MeasureValueType": "DOUBLE",
  "Time": "1718203893000"
}
```

---

## 🚀 Writing Data to Timestream

### Using AWS SDK (Python Example)

```python
import boto3
import time

client = boto3.client('timestream-write')

response = client.write_records(
    DatabaseName='MyIoTDB',
    TableName='SensorMetrics',
    Records=[
        {
            'Dimensions': [
                {'Name': 'device_id', 'Value': 'sensor-001'},
                {'Name': 'location', 'Value': 'factory-1'}
            ],
            'MeasureName': 'temperature',
            'MeasureValue': '30.5',
            'MeasureValueType': 'DOUBLE',
            'Time': str(int(time.time() * 1000))  # Unix epoch in ms
        }
    ]
)
```

---

## 🔍 Querying Data

Timestream uses **SQL-compatible syntax** to analyze time series data.

### Sample Queries

```sql
-- Get last 10 temperature records
SELECT * FROM "MyIoTDB"."SensorMetrics"
WHERE MeasureName = 'temperature'
ORDER BY time DESC
LIMIT 10;
```

```sql
-- Average temperature per device in last 1 hour
SELECT device_id,
       AVG(measure_value::double) AS avg_temp
FROM "MyIoTDB"."SensorMetrics"
WHERE MeasureName = 'temperature'
  AND time > ago(1h)
GROUP BY device_id;
```

```sql
-- Count all metrics per 5-minute window
SELECT bin(time, 5m) AS binned_time,
       COUNT(*) as records
FROM "MyIoTDB"."SensorMetrics"
WHERE time > ago(12h)
GROUP BY bin(time, 5m)
ORDER BY binned_time DESC;
```

---

## 📈 Visualization

|Tool|Integration|
|---|---|
|**Amazon QuickSight**|Native connector|
|**Grafana**|Timestream plugin available|
|**AWS IoT Core**|Can directly write to Timestream|
|**Lambda**|Stream data into Timestream|

---

## 🔐 Security

|Feature|Description|
|---|---|
|**IAM Auth**|Fine-grained write & query permissions|
|**Encryption**|KMS-managed encryption at rest|
|**Private VPC Access**|Supported via Interface VPC Endpoints|
|**CloudTrail**|Logs all access and usage|

---

## 🔔 Monitoring and Logging

|Service|What it Monitors|
|---|---|
|**CloudWatch**|Write success/failure metrics|
|**CloudTrail**|Logs API activity|
|**Service Quotas**|Limits on databases, tables, write rate|

---

## 💰 Pricing

|Cost Component|Approx. Cost|
|---|---|
|Write Requests|$0.50 per million write units|
|Query|$0.01 per GB scanned|
|Memory Store|$0.036 per GB/hour|
|Magnetic Store|$0.03 per GB/month|

> **Pro Tip**: Tune retention settings to reduce memory storage costs.

---

## 🧰 Terraform Sample

```hcl
resource "aws_timestreamwrite_database" "iot" {
  database_name = "MyIoTDB"
}

resource "aws_timestreamwrite_table" "metrics" {
  database_name = aws_timestreamwrite_database.iot.database_name
  table_name    = "SensorMetrics"

  retention_properties {
    memory_store_retention_period_in_hours = 24
    magnetic_store_retention_period_in_days = 7
  }
}
```

---

## ✅ Summary

|Feature|Description|
|---|---|
|Purpose|Time series data ingestion and analysis|
|Storage Tier|Memory (short-term), Magnetic (long-term)|
|Query Language|SQL-compatible (Timestream SQL)|
|Write Format|Dimensions + Measure + Time|
|Use Case|IoT, app monitoring, business metrics|
|Security|IAM, encryption, VPC endpoints|
|Pricing|Pay-per-use (write/query/storage)|

---
