
## 🧠 What is Amazon EMR?

**Amazon EMR (Elastic MapReduce)** is a **managed big data platform** that simplifies running **Apache Hadoop, Spark, Hive, HBase, Flink, Presto**, and other frameworks on AWS.

> ✅ It lets you **process and analyze massive datasets** cost-effectively using open-source tools in a **scalable, cluster-based environment**.

---

## 📦 Core Use Cases

|Use Case|Why Use EMR?|
|---|---|
|🧪 Big Data Processing (ETL)|Ingest, clean, transform TB–PB of data|
|🔍 Data Lake Analytics|Analyze S3-stored data using Spark, Hive, Presto|
|🧠 Machine Learning Pipelines|Distributed ML training using PySpark, TensorFlow|
|📊 Data Warehousing|SQL-like analytics using Hive/Presto|
|📂 Log & Clickstream Analysis|Real-time and batch log processing|

---

## 🏗️ Architecture Overview

```
       +--------------------+
       |   S3 (raw data)    |
       +--------------------+
                ↓
        +---------------+
        |   EMR Cluster  |
        |  - Master Node |
        |  - Core Nodes  |
        |  - Task Nodes  |
        +---------------+
                ↓
     Processed data → S3 / RDS / Redshift / DynamoDB
```

### Node Types:

- **Master Node**: Manages cluster, job scheduling
    
- **Core Nodes**: Store data using HDFS and process tasks
    
- **Task Nodes**: Only perform processing (no HDFS storage)
    

---

## 🧰 Supported Frameworks

|Framework|Purpose|
|---|---|
|**Apache Spark**|Fast, in-memory big data engine|
|**Apache Hive**|SQL-on-Hadoop for batch processing|
|**Apache HBase**|NoSQL database over HDFS|
|**Presto/Trino**|Distributed SQL query engine|
|**Flink**|Real-time stream processing|
|**Hue**|Web UI for Hadoop ecosystem|

---

## 🧪 Cluster Types

|Type|Description|
|---|---|
|**Transient Cluster**|Runs one job and shuts down automatically|
|**Long-running Cluster**|Always-on for streaming, multi-job workloads|
|**EMR on EKS**|Run Spark on Kubernetes|
|**EMR Serverless**|No cluster management, pay per job|

---

## 🔐 Security

|Feature|Description|
|---|---|
|**IAM Roles**|Control access to EMR and underlying services|
|**Kerberos Authentication**|Secure access to cluster services|
|**TLS In-Transit Encryption**|Secures communication between nodes|
|**At-Rest Encryption**|Uses S3 SSE, EBS encryption, and HDFS encryption|
|**Private Subnets / VPC**|Full network isolation with security groups|

---

## 📊 Monitoring & Debugging

|Tool|What It Does|
|---|---|
|**Amazon CloudWatch**|Logs, metrics for cluster and apps|
|**Ganglia**|Real-time performance monitoring|
|**Spark UI**|Visual interface for Spark job DAGs|
|**YARN Resource Manager UI**|View Hadoop resource usage|

---

## 💰 Pricing

|Component|Billed By|
|---|---|
|**EC2 Instances**|Per instance-hour|
|**EMR Cost**|Per-node per-hour (~$0.015–$0.27/hour)|
|**S3 Storage**|Billed separately|
|**Spot Support**|✅ Supported (save up to 90%)|

🧠 **Tip**: Use **EMR Instance Fleets** or **Spot + On-Demand mix** for cost optimization.

---

## 🛠️ Terraform Example — EMR Cluster with Spark

```hcl
resource "aws_emr_cluster" "example" {
  name          = "example-emr-cluster"
  release_label = "emr-6.13.0"
  applications  = ["Spark", "Hive"]

  ec2_attributes {
    key_name                          = "my-key"
    subnet_id                         = "subnet-0abc123456"
    emr_managed_master_security_group = aws_security_group.master.id
    emr_managed_slave_security_group  = aws_security_group.core.id
  }

  master_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 1
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 2
  }

  bootstrap_action {
    path = "s3://my-bucket/scripts/install-custom-libs.sh"
  }

  log_uri = "s3://my-emr-logs/"

  configurations_json = <<EOF
[
  {
    "Classification": "spark-defaults",
    "Properties": {
      "spark.executor.memory": "4g"
    }
  }
]
EOF

  service_role = "EMR_DefaultRole"
  job_flow_role = "EMR_EC2_DefaultRole"
}
```

---

## ✅ TL;DR Summary

|Feature|Amazon EMR|
|---|---|
|Managed Frameworks|Spark, Hive, HBase, Flink, Presto, etc.|
|Storage|HDFS, Amazon S3|
|Compute|EC2, EKS, or EMR Serverless|
|Cost|EC2 + EMR fee (by hour)|
|Security|IAM, VPC, TLS, Kerberos|
|Monitoring|CloudWatch, Spark UI, YARN, Ganglia|
|Terraform Support|✅ Yes|

---

## 🔄 Variants

|Variant|Description|
|---|---|
|**EMR on EC2**|Traditional cluster-based EMR|
|**EMR on EKS**|Spark jobs on Kubernetes (more control)|
|**EMR Serverless**|No need to manage clusters (pay per job)|

---
