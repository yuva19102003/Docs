
## 🧠 What is AWS Athena?

**Amazon Athena** is a **serverless, interactive query service** that lets you analyze data directly in **Amazon S3** using **standard SQL**.

> ✅ You don’t need to manage infrastructure — just point Athena to your data in S3, define a schema, and start querying.

---

## 🔍 Key Highlights

|Feature|Description|
|---|---|
|Query Engine|Presto (open-source distributed SQL engine)|
|Query Language|ANSI SQL (standard SQL)|
|Serverless?|✅ Yes|
|Data Source|Amazon S3 (default)|
|Schema Management|AWS Glue Data Catalog (or inline DDLs)|
|Output Location|Query results stored in S3 (CSV/Parquet)|

---

## 🧰 Common Use Cases

|Scenario|Why Use Athena?|
|---|---|
|📊 Ad-hoc log analysis|Run SQL queries on S3-stored CloudTrail or ELB logs|
|🧪 Data lake exploration|Query large data lakes stored in Parquet, ORC, JSON, CSV|
|🧼 ETL pipeline staging|Lightweight pre-processing for EMR, Redshift, or Glue|
|🕵️ Security investigation|Query S3-stored VPC flow logs, GuardDuty alerts, etc.|
|💰 Cost monitoring|Analyze CUR (Cost and Usage Report) files in S3|

---

## 🧱 Architecture

```
        +----------------+                 +------------------------+
        |  Data in S3    | <----------+    | AWS Glue Data Catalog  |
        +----------------+           |     +------------------------+
               ↑                     |            ↑
         Partitioned /              |        Table definitions
         Columnar formats           |
               ↑                    |
        +------------------+        |     +-------------------------+
        |   Amazon Athena   |  SQL  +---> | Results stored in S3    |
        +------------------+              +-------------------------+
```

- **Athena reads data** from **S3 directly**
    
- Uses **Glue Data Catalog** for schema definitions
    
- Results are **stored in S3** for download or further processing
    

---

## 📚 Supported Data Formats

|Format|Compression Supported|Columnar?|
|---|---|---|
|CSV|GZIP|❌|
|JSON|GZIP|❌|
|Parquet|GZIP, Snappy|✅|
|ORC|ZLIB, Snappy|✅|
|Avro|Deflate, Snappy|✅|
|TSV|GZIP|❌|

✅ **Use Parquet or ORC** for best performance (columnar, compressed)

---

## 🔐 Security Features

|Layer|Description|
|---|---|
|**IAM Policies**|Restrict Athena API access and S3 read/write|
|**S3 Bucket Policy**|Restrict access to query and result locations|
|**Encryption at Rest**|S3-SSE / SSE-KMS for input and output|
|**In-Transit**|HTTPS (secure transmission)|
|**Workgroups**|Isolate workloads and enforce limits/quota|
|**Access Control**|Fine-grained access to Glue catalog/tables|

---

## 💰 Pricing (as of 2024)

|Metric|Cost|
|---|---|
|**Data scanned per query**|**$5.00 per TB**|
|**Data catalog (Glue)**|Free for <1 million objects/month|
|**Workgroup control/monitoring**|Free|

🧠 **Tip**: Use compressed columnar formats + partitioning to reduce scan size!

---

## 🛠️ Terraform Example: Athena Table in Glue Catalog

```hcl
resource "aws_glue_catalog_database" "example_db" {
  name = "example_database"
}

resource "aws_glue_catalog_table" "example_table" {
  name          = "access_logs"
  database_name = aws_glue_catalog_database.example_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://my-bucket/logs/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    serde_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = "\t"
      }
    }
    columns {
      name = "ip"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
    columns {
      name = "method"
      type = "string"
    }
  }
}
```

Now you can query this in Athena:

```sql
SELECT * FROM example_database.access_logs WHERE method = 'POST';
```

---

## 🧪 Best Practices

|Best Practice|Why it Matters|
|---|---|
|Partition your data (e.g., by date)|Reduces data scanned and improves performance|
|Use columnar formats (Parquet/ORC)|Faster queries and lower costs|
|Compress files|Smaller scan size = lower cost|
|Use Workgroups|Enforce usage limits and control access|
|Use Glue Catalog|Central schema management for Athena & ETL|

---

## ✅ TL;DR Summary

|Feature|AWS Athena|
|---|---|
|Query Engine|Presto|
|Serverless?|✅ Yes|
|Data Source|Amazon S3 (also federated sources)|
|Schema Catalog|AWS Glue Data Catalog|
|Pricing|$5/TB scanned|
|Use Cases|Ad hoc analytics, logs, billing|
|Performance Tip|Partitioned + columnar format|
|Terraform Support|✅ Via Glue Catalog + IAM|

---

## 🔄 Related Services

|If You Need...|Use This|
|---|---|
|Query S3 with SQL|✅ Amazon Athena|
|Managed Data Warehouse|Amazon Redshift|
|ETL Jobs|AWS Glue|
|Run SQL over streaming data|Amazon Kinesis Analytics|
|Scheduled Athena queries|EventBridge + Lambda|

---
