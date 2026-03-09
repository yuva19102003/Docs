# Dataproc

Managed Hadoop and Spark service.

---

## Overview

Cloud Dataproc is a fast, easy-to-use, fully managed cloud service for running Apache Spark and Apache Hadoop clusters.

---

## Key Features

- Fast cluster creation (90 seconds)
- Auto-scaling
- Preemptible workers
- Integration with GCS
- Workflow templates
- Component gateway
- Open-source ecosystem

---

## Creating Clusters

**Standard Cluster:**
```bash
# Create cluster
gcloud dataproc clusters create my-cluster \
  --region=us-central1 \
  --zone=us-central1-a \
  --master-machine-type=n1-standard-4 \
  --master-boot-disk-size=500 \
  --num-workers=2 \
  --worker-machine-type=n1-standard-4 \
  --worker-boot-disk-size=500 \
  --image-version=2.0-debian10
```

**With Preemptible Workers:**
```bash
gcloud dataproc clusters create cost-optimized-cluster \
  --region=us-central1 \
  --num-workers=2 \
  --num-preemptible-workers=10 \
  --preemptible-worker-boot-disk-size=50GB \
  --worker-machine-type=n1-standard-4
```

**With Auto-scaling:**
```bash
gcloud dataproc clusters create autoscaling-cluster \
  --region=us-central1 \
  --enable-component-gateway \
  --autoscaling-policy=my-policy \
  --num-workers=2
```

---

## Auto-scaling Policies

```bash
# Create auto-scaling policy
gcloud dataproc autoscaling-policies import my-policy \
  --source=policy.yaml \
  --region=us-central1
```

**policy.yaml:**
```yaml
workerConfig:
  minInstances: 2
  maxInstances: 100
  weight: 1
secondaryWorkerConfig:
  minInstances: 0
  maxInstances: 100
  weight: 1
basicAlgorithm:
  yarnConfig:
    scaleUpFactor: 0.05
    scaleDownFactor: 1.0
    scaleUpMinWorkerFraction: 0.0
    scaleDownMinWorkerFraction: 0.0
    gracefulDecommissionTimeout: 1h
```

---

## Submitting Jobs

**Spark Job:**
```bash
# Submit Spark job
gcloud dataproc jobs submit spark \
  --cluster=my-cluster \
  --region=us-central1 \
  --class=org.apache.spark.examples.SparkPi \
  --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
  --max-failures-per-hour=5 \
  -- 1000
```

**PySpark Job:**
```bash
gcloud dataproc jobs submit pyspark \
  --cluster=my-cluster \
  --region=us-central1 \
  gs://my-bucket/wordcount.py \
  -- gs://my-bucket/input.txt gs://my-bucket/output
```

**Hive Job:**
```bash
gcloud dataproc jobs submit hive \
  --cluster=my-cluster \
  --region=us-central1 \
  --execute="SELECT * FROM my_table LIMIT 10"
```

**Pig Job:**
```bash
gcloud dataproc jobs submit pig \
  --cluster=my-cluster \
  --region=us-central1 \
  --file=gs://my-bucket/script.pig
```

---

## Workflow Templates

**Create Template:**
```yaml
# template.yaml
jobs:
  - stepId: load-data
    sparkJob:
      mainClass: com.example.LoadData
      jarFileUris:
        - gs://my-bucket/load-data.jar
      args:
        - gs://input-bucket/data
        - gs://staging-bucket/loaded
  
  - stepId: process-data
    prerequisiteStepIds:
      - load-data
    sparkJob:
      mainClass: com.example.ProcessData
      jarFileUris:
        - gs://my-bucket/process-data.jar
      args:
        - gs://staging-bucket/loaded
        - gs://output-bucket/processed

placement:
  managedCluster:
    clusterName: workflow-cluster
    config:
      masterConfig:
        numInstances: 1
        machineTypeUri: n1-standard-4
      workerConfig:
        numInstances: 2
        machineTypeUri: n1-standard-4
```

**Import and Run:**
```bash
# Import template
gcloud dataproc workflow-templates import my-template \
  --source=template.yaml \
  --region=us-central1

# Instantiate template
gcloud dataproc workflow-templates instantiate my-template \
  --region=us-central1
```

---

## Initialization Actions

**Custom Initialization Script:**
```bash
#!/bin/bash

# Install additional packages
apt-get update
apt-get install -y python3-pip

# Install Python libraries
pip3 install pandas numpy scikit-learn

# Configure Spark
echo "spark.executor.memory=4g" >> /etc/spark/conf/spark-defaults.conf
```

**Use Initialization Action:**
```bash
gcloud dataproc clusters create my-cluster \
  --region=us-central1 \
  --initialization-actions=gs://my-bucket/init.sh \
  --metadata='PIP_PACKAGES=pandas numpy'
```

---

## Component Gateway

```bash
# Create cluster with component gateway
gcloud dataproc clusters create gateway-cluster \
  --region=us-central1 \
  --enable-component-gateway \
  --optional-components=JUPYTER,ZEPPELIN

# Access web interfaces
# Jupyter: https://CLUSTER_NAME-m.REGION.c.PROJECT_ID.internal:8123
# Zeppelin: https://CLUSTER_NAME-m.REGION.c.PROJECT_ID.internal:8124
```

---

## Integration with GCS

**Read from GCS (Spark):**
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("GCS Example").getOrCreate()

# Read from GCS
df = spark.read.csv("gs://my-bucket/data.csv", header=True)

# Process data
result = df.groupBy("category").count()

# Write to GCS
result.write.mode("overwrite").csv("gs://my-bucket/output")
```

**Hive with GCS:**
```sql
-- Create external table on GCS
CREATE EXTERNAL TABLE my_table (
  id INT,
  name STRING,
  value DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'gs://my-bucket/data/';

-- Query data
SELECT category, AVG(value) as avg_value
FROM my_table
GROUP BY category;
```

---

## Ephemeral Clusters

**Create and Delete After Job:**
```bash
# Create cluster, run job, delete cluster
gcloud dataproc jobs submit spark \
  --cluster=temp-cluster \
  --region=us-central1 \
  --class=com.example.MyJob \
  --jars=gs://my-bucket/my-job.jar \
  --properties=dataproc:dataproc.cluster.delete.on.job.completion=true
```

---

## Monitoring

**View Job Output:**
```bash
# List jobs
gcloud dataproc jobs list --region=us-central1

# Get job details
gcloud dataproc jobs describe JOB_ID --region=us-central1

# View job output
gcloud dataproc jobs wait JOB_ID --region=us-central1
```

**Metrics:**
```bash
# View cluster metrics
gcloud monitoring time-series list \
  --filter='metric.type="dataproc.googleapis.com/cluster/hdfs/capacity"' \
  --format=json
```

---

## Best Practices

✓ Use preemptible workers for cost savings  
✓ Right-size clusters  
✓ Use ephemeral clusters  
✓ Store data in GCS  
✓ Enable autoscaling  
✓ Use workflow templates  
✓ Monitor cluster utilization  
✓ Implement graceful decommissioning  

---

## Cost Optimization

```bash
# Use preemptible workers (up to 80% savings)
gcloud dataproc clusters create cost-cluster \
  --num-workers=2 \
  --num-preemptible-workers=20

# Use custom machine types
gcloud dataproc clusters create custom-cluster \
  --master-machine-type=custom-4-15360 \
  --worker-machine-type=custom-4-15360

# Delete idle clusters
gcloud dataproc clusters delete idle-cluster --region=us-central1
```

---

## Pricing

```
Dataproc fee: $0.01 per vCPU-hour
Plus: Compute Engine pricing
Preemptible workers: Up to 80% discount
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
