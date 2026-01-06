
## 🔥 What is Kinesis Data Firehose?

**Amazon Kinesis Data Firehose** is a **fully managed, serverless data delivery service** that lets you **ingest, transform, and load streaming data** into destinations like **S3, Redshift, OpenSearch, and HTTP endpoints** in near real-time.

> ✅ Unlike Kinesis Data Streams, **Firehose doesn’t require consumers or management of shards** — it auto-scales and buffers the data for delivery.

---

## 🧠 Key Concepts

|Component|Description|
|---|---|
|**Delivery Stream**|The logical pipeline for ingestion and delivery|
|**Buffering**|Aggregates incoming records before delivery (1MB or 60 seconds default)|
|**Transformation**|Optional Lambda function to preprocess records|
|**Compression**|Supports GZIP, ZIP, Snappy before storing|
|**Encryption**|SSE-KMS supported for data at rest|

---

## 📦 Supported Destinations

|Destination|Notes|
|---|---|
|**Amazon S3**|Default destination for raw or transformed data|
|**Amazon Redshift**|Via S3 intermediary staging|
|**Amazon OpenSearch**|For near real-time search/indexing|
|**HTTP Endpoint**|Custom receiver apps (must respond 200 OK)|
|**DataDog/Splunk/NewRelic**|Built-in integration for observability data|

---

## 🎯 Common Use Cases

|Scenario|Why Use Firehose?|
|---|---|
|🔍 Log ingestion to S3/Redshift|Store app logs in S3 for archival and analytics|
|📈 Real-time metrics dashboards|Push telemetry to Redshift or OpenSearch|
|💹 Streaming ETL pipeline|Transform JSON or CSV with Lambda before storage|
|🛠️ Serverless analytics pipeline|No need to manage shards or consumers|

---

## 🔧 How Firehose Works

```
[Producer] → [Firehose Buffer (1MB or 60s)] → [Optional Lambda Transform] → [S3/Redshift/etc.]
```

---

## 🛠️ Terraform Example: Firehose to S3

### 1. Create an S3 Bucket

```hcl
resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "my-firehose-bucket"
}
```

### 2. Create Firehose IAM Role

```hcl
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "${aws_s3_bucket.firehose_bucket.arn}/*"
      }
    ]
  })
}
```

### 3. Create the Firehose Delivery Stream

```hcl
resource "aws_kinesis_firehose_delivery_stream" "to_s3" {
  name        = "firehose-to-s3"
  destination = "s3"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.firehose_bucket.arn
    buffering_size     = 5      # MB
    buffering_interval = 60     # Seconds
    compression_format = "GZIP"
  }
}
```

---

## 🔄 Optional: Lambda Transformation

You can use a Lambda function to **transform or filter incoming data** before delivery.

### Terraform Snippet

```hcl
extended_s3_configuration {
  role_arn           = aws_iam_role.firehose_role.arn
  bucket_arn         = aws_s3_bucket.firehose_bucket.arn
  processing_configuration {
    enabled = true

    processors {
      type = "Lambda"

      parameters {
        parameter_name  = "LambdaArn"
        parameter_value = aws_lambda_function.transformer.arn
      }
    }
  }
}
```

---

## 📊 Monitoring and Logging

|Tool|Metric/Log|
|---|---|
|CloudWatch|DeliverySuccess, DeliveryToS3Bytes, ThrottledPut|
|S3|Backup for failed records|
|CloudTrail|Logs management events|

---

## 🔐 Security

|Security Feature|Description|
|---|---|
|IAM|Fine-grained access for delivery roles|
|SSE-S3 / SSE-KMS|Encrypt data at rest|
|VPC Endpoint Support|For secure Firehose → S3 in private VPCs|

---

## 💰 Pricing (as of 2024)

|Component|Price|
|---|---|
|Firehose ingest|$0.029 per GB ingested|
|Data format conversion|$0.021 per GB (if JSON to Parquet/ORC)|
|Lambda transformation|Charged as regular Lambda invocation|
|Destination storage|Billed separately (S3, Redshift, etc.)|

---

## 🔁 Kinesis Firehose vs Kinesis Streams vs Kafka

|Feature|**Firehose**|**Kinesis Data Streams**|**Kafka / MSK**|
|---|---|---|---|
|Delivery Model|Managed push delivery|Pull-based consumer|Consumer pull|
|Transformation|Built-in (via Lambda)|Manual|Use Kafka Streams / Connect|
|Ordering|Not guaranteed|Per partition key|Per partition|
|Buffering|Automatic (1MB or 60s)|Manual shard read|Manual|
|Ideal Use Case|ETL pipelines|Real-time event processing|High-throughput log stream|
|Serverless|✅ Yes|✅ Yes|❌ (unless using Confluent)|

---

## ✅ TL;DR Summary

|Feature|Kinesis Data Firehose|
|---|---|
|Purpose|Ingest → Transform → Load streaming data|
|Destinations|S3, Redshift, OpenSearch, HTTP|
|Buffering|Automatic (time or size-based)|
|Transformation|✅ Lambda-based processing|
|Scaling|Fully managed and auto-scaled|
|Terraform Support|✅ Yes (`aws_kinesis_firehose_delivery_stream`)|
|Recommended For|Serverless ETL, log ingestion, metrics pipelines|

---
