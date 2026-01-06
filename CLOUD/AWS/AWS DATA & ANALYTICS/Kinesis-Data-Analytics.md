
## 🧠 What is Kinesis Data Analytics?

**Amazon Kinesis Data Analytics (KDA)** is a **fully managed service** that allows you to **analyze streaming data in real time** using standard SQL, Apache Flink, or Java.

> ✅ It's built to ingest data from **Kinesis Data Streams**, **Kinesis Data Firehose**, or **Kafka**, process it in real-time, and output it to destinations like **S3, Redshift, Elasticsearch**, or **another stream**.

---

## 📦 Key Use Cases

|Use Case|Why KDA?|
|---|---|
|📈 Real-time metrics & dashboards|Aggregate events (clicks, orders) in seconds|
|🛡️ Anomaly detection|Spot fraud or unusual spikes with streaming pattern logic|
|📊 Log analytics|Analyze logs from apps or IoT devices in near real time|
|🔁 Stream enrichment|Join streams with static data (e.g., reference lookup)|
|🧠 ML inference|Use pre-trained models in Flink for scoring events live|

---

## 🧰 Types of Applications in KDA

|Type|Language / Framework|Description|
|---|---|---|
|**SQL**|SQL-92|Easy, serverless stream processing|
|**Apache Flink**|Java, Scala, Python|Advanced event processing, ML, stateful apps|

---

## 🏗️ Architecture Overview

```
        +------------------+
        | Kinesis Stream   | ← Ingested data (IoT, logs, etc.)
        +--------+---------+
                 |
                 ↓
      +--------------------------+
      |  Kinesis Data Analytics  | ← (SQL or Flink app)
      +--------+-----------------+
               ↓
     +----------------+----------------+----------------+
     |     S3         |    Redshift    |   OpenSearch   |
     +----------------+----------------+----------------+
```

You can optionally enrich the stream using **reference data from S3** or embed **ML models** in Flink.

---

## 🔢 SQL vs Apache Flink

|Feature|KDA SQL|KDA Flink|
|---|---|---|
|Language|ANSI SQL-92|Java, Scala, Python (Flink)|
|Complexity|Low (simple joins, aggregates)|High (complex logic, ML, windows, stateful)|
|Latency|Sub-second|Sub-second|
|ML Support|❌ No|✅ Yes (Apache Flink APIs)|
|Stateful processing|❌ Limited|✅ Yes|
|Custom connectors|❌ No|✅ Yes|

---

## 🧑‍💻 Example SQL in KDA

```sql
CREATE OR REPLACE STREAM "DEST_STREAM" (
    region VARCHAR(16),
    total_sales DOUBLE
);

CREATE OR REPLACE PUMP "STREAM_PUMP" AS
INSERT INTO "DEST_STREAM"
SELECT region, SUM(sales) AS total_sales
FROM "SOURCE_SQL_STREAM_001"
GROUP BY region;
```

---

## 🔄 Integration Points

|Source|Destination|
|---|---|
|Kinesis Data Streams|S3|
|Kinesis Data Firehose|Redshift|
|MSK (Managed Kafka)|OpenSearch (Elasticsearch)|
|Kafka (Self-managed on EC2)|Another Kinesis stream|
|IoT Core|Lambda, EventBridge|

---

## 🧠 Notable Features

|Feature|Description|
|---|---|
|**Streaming SQL**|Write SQL queries on continuous streams|
|**Apache Flink API**|Custom code, windowing, joins, aggregations|
|**Durable State**|Maintain state across events using Flink|
|**Autoscaling / Fault Tolerant**|Resilient with checkpointing and replay|
|**Managed Connectors**|Kafka, Kinesis, Flink S3 Sink|

---

## 💰 Pricing Summary (2024)

|Component|Price|
|---|---|
|**SQL apps**|$0.11 per GB of input|
|**Flink apps**|$0.11 per KDA Processing Unit (KPU) per hour|
|**Checkpointing storage**|Included up to 50 GB/month|
|**Max parallelism**|Controlled by KPUs|

🧠 **Tip**: 1 KPU = 1 vCPU + 4 GB RAM.

---

## 🛠️ Terraform Example — KDA for Apache Flink

```hcl
resource "aws_kinesisanalyticsv2_application" "flink_app" {
  name                   = "flink-example"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = aws_iam_role.flink_exec.arn

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = "arn:aws:s3:::my-flink-code"
          file_key   = "app.jar"
        }
      }
      code_content_type = "ZIP"
    }

    flink_application_configuration {
      parallelism_configuration {
        configuration_type = "DEFAULT"
      }
    }

    environment_properties {
      property_group {
        property_group_id = "FlinkAppProperties"
        properties = {
          input.stream = "my-kinesis-stream"
          output.bucket = "my-output-bucket"
        }
      }
    }

    application_snapshot_configuration {
      snapshots_enabled = true
    }
  }
}
```

---

## ✅ TL;DR Summary

|Feature|Amazon Kinesis Data Analytics|
|---|---|
|Serverless|✅ Yes|
|Languages|SQL, Java, Scala (Flink)|
|Use Cases|Real-time analytics, ETL, anomaly detection|
|Input Sources|Kinesis, Kafka, Firehose|
|Destinations|S3, Redshift, Elasticsearch, Kinesis|
|Stateful processing|✅ Flink only|
|Terraform support|✅ Yes (v2 apps only)|

---
