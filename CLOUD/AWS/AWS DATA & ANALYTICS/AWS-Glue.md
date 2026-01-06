
## 🧠 What is AWS Glue?

**AWS Glue** is a **fully managed serverless ETL (Extract, Transform, Load) service** that helps you **prepare, transform, and move data** between data sources (e.g., S3, RDS, Redshift, DynamoDB).

> ✅ It includes a **data catalog**, **ETL engine**, **data preparation UI**, **event-driven workflows**, and **Python/Scala-based jobs**.

---

## 📦 Core Components

|Component|Description|
|---|---|
|**Glue Data Catalog**|Central metadata repository (like Hive Metastore) for databases/tables|
|**Glue Crawler**|Auto-detects schema of structured/semi-structured data|
|**Glue Job**|Code that performs ETL in PySpark or Scala|
|**Glue Workflow**|Manages job dependencies and triggers|
|**Glue Trigger**|Schedules or event-based invocations of jobs/workflows|
|**Glue Studio**|Visual ETL job authoring (drag & drop GUI)|
|**Glue DataBrew**|No-code UI for data cleaning and preparation|

---

## 🔁 How Glue Works

```plaintext
             ┌──────────────┐
             │   Crawler    │ ───── Scans S3/RDS/Redshift
             └─────┬────────┘
                   ↓
         ┌─────────────────────┐
         │   Glue Data Catalog │ ←── Queried by Athena, Redshift Spectrum
         └─────┬───────────────┘
               ↓
         ┌──────────────┐
         │     Jobs     │ ←──── Transforms (PySpark / Scala)
         └─────┬────────┘
               ↓
         ┌──────────────┐
         │   Target     │ ←──── S3 / RDS / Redshift / DynamoDB
         └──────────────┘
```

---

## 🧰 Use Cases

|Use Case|Why Glue?|
|---|---|
|🧪 Data lake ETL pipelines|Process and move data between S3, Redshift, RDS, etc.|
|🗂️ Centralized metadata catalog|Federated schema registry for Athena, Redshift Spectrum|
|💧 Data cleansing and wrangling|Glue Studio and DataBrew for visual/ML-powered data cleaning|
|⏱️ Scheduled batch ETL|Run Spark jobs on schedule or event triggers|
|🧠 ML feature engineering|Preprocess data for SageMaker models|

---

## 🏗️ Glue Data Catalog vs Crawlers

|Feature|Glue Data Catalog|Glue Crawlers|
|---|---|---|
|Purpose|Stores metadata (tables, databases)|Auto-generates metadata|
|Queryable by|Athena, Redshift Spectrum, EMR|No direct querying|
|Language|SQL, DDL|Point to S3, RDS, DynamoDB|
|Format Support|CSV, JSON, Parquet, ORC, Avro, XML|Same|

---

## 🔐 Security

|Layer|Description|
|---|---|
|**IAM Roles**|Used for job execution and access to S3, Redshift|
|**Encryption**|Supports KMS for job scripts, logs, and data|
|**VPC Access**|Jobs can run in private subnets (Glue version 2+)|
|**Column-level access**|With Lake Formation integration|

---

## 💰 Pricing (as of 2024)

|Item|Cost (approx.)|
|---|---|
|**Job (per DPU-hour)**|~$0.44 per DPU-hour (1 DPU = 4vCPU + 16GB RAM)|
|**Glue Studio Notebooks**|~$0.44 per DPU-hour|
|**Glue Crawlers**|~$0.44 per DPU-hour|
|**Data Catalog storage**|Free up to 1M objects/month, then ~$1 per 100k|

🧠 **Tip**: Use Glue **2.0 or 3.0**, which has **faster startup time** and **per-second billing**.

---

## 🛠️ Terraform Examples

### 1. Glue Catalog Database

```hcl
resource "aws_glue_catalog_database" "example" {
  name = "analytics_db"
}
```

---

### 2. Glue Catalog Table

```hcl
resource "aws_glue_catalog_table" "example" {
  name          = "sales_data"
  database_name = aws_glue_catalog_database.example.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://my-bucket/sales/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "order_id"
      type = "string"
    }

    columns {
      name = "amount"
      type = "double"
    }

    serde_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }
  }
}
```

---

### 3. Glue Job

```hcl
resource "aws_glue_job" "example" {
  name     = "etl-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://my-bucket/scripts/transform.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir" = "s3://my-bucket/temp/"
    "--job-language" = "python"
  }

  max_capacity   = 2  # DPUs
  glue_version   = "3.0"
  number_of_workers = 2
  worker_type    = "G.1X"
}
```

---

## 🔄 Glue vs Other Services

|Goal|Use Glue?|Alternatives|
|---|---|---|
|Query S3 with SQL|No (use Athena)|Amazon Athena|
|Realtime stream ETL|No (use Kinesis)|Amazon Kinesis + Lambda|
|Batch ETL on big data|✅ Yes|EMR, Lambda (lightweight)|
|No-code cleaning|✅ (via DataBrew)|Third-party tools (Trifacta)|

---

## ✅ TL;DR Summary

|Feature|AWS Glue|
|---|---|
|Serverless?|✅ Yes|
|Languages|Python (PySpark), Scala|
|Catalog Support|✅ Glue Data Catalog|
|Visual Authoring|✅ Glue Studio, Glue DataBrew|
|Triggering|On schedule, on event, or manually|
|Pricing|Per second, per DPU|
|Integrations|S3, RDS, Redshift, Athena, DynamoDB|

---
