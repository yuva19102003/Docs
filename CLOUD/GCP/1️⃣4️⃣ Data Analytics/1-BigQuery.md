# BigQuery

Serverless, highly scalable data warehouse.

---

## Overview

BigQuery is a fully managed, serverless data warehouse that enables super-fast SQL queries using the processing power of Google's infrastructure.

---

## Key Features

- Petabyte-scale analytics
- Standard SQL
- Real-time analytics
- Machine learning (BQML)
- Geospatial analysis
- BI Engine (in-memory)
- Streaming inserts
- Federated queries

---

## Creating Datasets

```bash
# Create dataset
bq mk --dataset \
  --location=US \
  --description="My dataset" \
  PROJECT_ID:my_dataset

# Create dataset with default table expiration
bq mk --dataset \
  --default_table_expiration=3600 \
  PROJECT_ID:my_dataset
```

---

## Creating Tables

**From Schema:**
```bash
# Create table with schema
bq mk --table \
  PROJECT_ID:my_dataset.my_table \
  schema.json

# schema.json
[
  {"name": "id", "type": "INTEGER", "mode": "REQUIRED"},
  {"name": "name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "created_at", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
```

**Partitioned Table:**
```sql
CREATE TABLE my_dataset.partitioned_table
(
  id INT64,
  name STRING,
  created_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY id
OPTIONS(
  partition_expiration_days=90,
  require_partition_filter=true
);
```

**Clustered Table:**
```sql
CREATE TABLE my_dataset.clustered_table
(
  country STRING,
  city STRING,
  user_id INT64,
  amount FLOAT64
)
CLUSTER BY country, city;
```

---

## Loading Data

**From Cloud Storage:**
```bash
# Load CSV
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  my_dataset.my_table \
  gs://my-bucket/data.csv \
  schema.json

# Load JSON
bq load \
  --source_format=NEWLINE_DELIMITED_JSON \
  my_dataset.my_table \
  gs://my-bucket/data.json \
  schema.json

# Load Parquet
bq load \
  --source_format=PARQUET \
  my_dataset.my_table \
  gs://my-bucket/data.parquet
```

**Streaming Insert (Python):**
```python
from google.cloud import bigquery

client = bigquery.Client()
table_id = "project.dataset.table"

rows_to_insert = [
    {"id": 1, "name": "Alice", "created_at": "2026-03-09T12:00:00"},
    {"id": 2, "name": "Bob", "created_at": "2026-03-09T12:01:00"},
]

errors = client.insert_rows_json(table_id, rows_to_insert)
if errors:
    print(f"Errors: {errors}")
```

---

## Querying Data

**Basic Query:**
```sql
SELECT 
  country,
  COUNT(*) as user_count,
  AVG(amount) as avg_amount
FROM my_dataset.transactions
WHERE DATE(created_at) >= '2026-01-01'
GROUP BY country
ORDER BY user_count DESC
LIMIT 10;
```

**Window Functions:**
```sql
SELECT
  user_id,
  order_date,
  amount,
  SUM(amount) OVER (
    PARTITION BY user_id 
    ORDER BY order_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) as running_total
FROM my_dataset.orders;
```

**Partitioned Query:**
```sql
SELECT *
FROM my_dataset.partitioned_table
WHERE DATE(created_at) = '2026-03-09'  -- Partition filter
  AND id > 1000;
```

---

## BigQuery ML

**Create Model:**
```sql
CREATE OR REPLACE MODEL my_dataset.customer_churn_model
OPTIONS(
  model_type='LOGISTIC_REG',
  input_label_cols=['churned']
) AS
SELECT
  age,
  tenure,
  monthly_charges,
  total_charges,
  churned
FROM my_dataset.customers;
```

**Predict:**
```sql
SELECT
  customer_id,
  predicted_churned,
  predicted_churned_probs[OFFSET(0)].prob as churn_probability
FROM ML.PREDICT(
  MODEL my_dataset.customer_churn_model,
  (SELECT * FROM my_dataset.new_customers)
);
```

---

## Optimization

**Partitioning:**
```sql
-- Time-unit column partitioning
CREATE TABLE my_dataset.events
PARTITION BY DATE(event_timestamp)
AS SELECT * FROM source_table;

-- Integer range partitioning
CREATE TABLE my_dataset.users
PARTITION BY RANGE_BUCKET(user_id, GENERATE_ARRAY(0, 1000000, 10000))
AS SELECT * FROM source_table;
```

**Clustering:**
```sql
CREATE TABLE my_dataset.optimized_table
PARTITION BY DATE(created_at)
CLUSTER BY country, city
AS SELECT * FROM source_table;
```

**Materialized Views:**
```sql
CREATE MATERIALIZED VIEW my_dataset.daily_summary
AS
SELECT
  DATE(created_at) as date,
  country,
  COUNT(*) as count,
  SUM(amount) as total_amount
FROM my_dataset.transactions
GROUP BY date, country;
```

---

## Cost Optimization

```sql
-- Use partitioning and clustering
-- Avoid SELECT *
SELECT id, name, amount  -- Specific columns only
FROM my_dataset.large_table
WHERE _PARTITIONDATE = '2026-03-09';

-- Use approximate aggregation
SELECT APPROX_COUNT_DISTINCT(user_id) as unique_users
FROM my_dataset.events;

-- Use BI Engine for dashboards
ALTER TABLE my_dataset.my_table
SET OPTIONS (
  max_staleness = INTERVAL 1 HOUR
);
```

---

## Best Practices

✓ Use partitioning and clustering  
✓ Avoid SELECT *  
✓ Use appropriate data types  
✓ Implement incremental loads  
✓ Use materialized views  
✓ Monitor query costs  
✓ Use BI Engine for dashboards  
✓ Implement data lifecycle policies  

---

## Pricing

**On-Demand:**
- Queries: $5 per TB processed
- Storage: $0.02 per GB/month (active)
- Storage: $0.01 per GB/month (long-term)
- Streaming: $0.01 per 200 MB

**Flat-Rate:**
- Starting at $2,000/month (100 slots)
- Predictable costs
- Better for consistent workloads

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
