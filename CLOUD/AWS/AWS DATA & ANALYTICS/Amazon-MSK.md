
## 🧠 What is Amazon MSK?

**Amazon MSK** is a **fully managed service for Apache Kafka**, enabling you to build and run **high-throughput, low-latency** streaming applications on **Kafka without managing the infrastructure**.

> ✅ MSK handles provisioning, patching, scaling, monitoring, and failure recovery of Kafka clusters on AWS.

---

## 📦 Key Use Cases

|Use Case|Why MSK?|
|---|---|
|🧪 Real-time data pipelines|Process millions of events per second|
|🛡️ Log ingestion|Ingest, filter, and route logs to other systems|
|🛍️ Clickstream and user analytics|Analyze user behavior in real-time|
|🔁 Event-driven microservices|Use Kafka topics to decouple producer and consumer services|
|🚀 ETL pipelines|Ingest → Transform → Load via Kafka connectors or KDA|

---

## 🏗️ Architecture Overview

```
Producer Apps → MSK Cluster → Topics → Consumer Apps
                                   ↓
                   (Kinesis Data Analytics, Lambda, S3, etc.)
```

MSK includes **Kafka Brokers**, **Zookeeper**, and integrates with **AWS networking and security services** like VPC, IAM, CloudWatch, and KMS.

---

## 🔧 Features

|Feature|Description|
|---|---|
|**Fully Managed**|No need to manage EC2, storage, or Zookeeper|
|**VPC-native**|Kafka brokers run inside your VPC|
|**Encryption**|In-transit (TLS) and at-rest (KMS)|
|**Monitoring**|Native CloudWatch metrics and Open Monitoring (Prometheus)|
|**Authentication**|IAM, TLS mutual auth, SASL/SCRAM|
|**Multi-AZ Support**|High availability across availability zones|
|**Open-source Kafka**|Compatible with Kafka APIs, clients, connectors|

---

## 🧰 MSK vs Kafka on EC2

|Feature|MSK (Managed)|Self-managed Kafka|
|---|---|---|
|Cluster setup|Automatic|Manual|
|Scaling|Manual (with UI/API)|Manual|
|Monitoring|Built-in|Self-managed|
|HA (multi-AZ)|✅ Yes|Depends on config|
|Cost|Slightly higher|Lower, more effort|
|Maintenance|AWS-managed|You manage patches|

---

## 💰 Pricing Overview (2024)

|Component|Price (approx)|
|---|---|
|**Broker Instance Hours**|Billed per broker instance hour|
|**Storage**|~$0.10/GB-month (provisioned, not EBS burstable)|
|**Data Transfer (VPC)**|Free in same AZ, inter-AZ charges apply|
|**Zookeeper Nodes**|Small charge per instance-hour|

🧠 Tip: Use **t3.small** brokers for dev/test, and **m5.large or higher** for production.

---

## 🔐 Security

|Layer|Feature|
|---|---|
|**Encryption at Rest**|KMS-managed keys|
|**TLS in Transit**|Enabled by default|
|**IAM Auth**|IAM for Kafka (via MSK IAM auth plugin)|
|**TLS Mutual Auth**|Certificate-based (via ACM PCA)|
|**SASL/SCRAM Auth**|Username-password auth (stored securely in MSK)|
|**Private Networking**|Brokers run in your VPC, no public IPs|

---

## 🚀 MSK Connect (Managed Kafka Connect)

Use **MSK Connect** to run connectors (source/sink) without managing Kafka Connect clusters.

Example connectors:

- S3 Sink Connector
    
- Redshift Sink Connector
    
- JDBC Source Connector
    
- Elasticsearch Sink Connector
    

---

## 🔄 Integration with AWS Services

|Service|Integration|
|---|---|
|**Kinesis Data Analytics**|Use Kafka as source for streaming SQL/Flink jobs|
|**Lambda**|Kafka → Lambda trigger (MSK as source)|
|**S3**|Kafka → MSK Connect → S3|
|**Redshift**|Kafka → MSK Connect → Redshift|
|**CloudWatch**|Broker and topic-level metrics|
|**Glue/Athena**|ETL or cataloging over streaming data|

---

## 🛠️ Terraform Example — MSK Cluster

```hcl
resource "aws_msk_cluster" "example" {
  cluster_name           = "demo-cluster"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3
  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
    security_groups = [aws_security_group.msk.id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled         = true
        log_group       = aws_cloudwatch_log_group.msk_logs.name
      }
    }
  }
}
```

---

## 📥 Terraform for MSK Connect (Sink to S3)

```hcl
resource "aws_mskconnect_connector" "s3_sink" {
  name = "s3-sink-connector"

  kafkaconnect_version = "2.10.1"

  capacity {
    autoscaling {
      max_worker_count       = 4
      mcu_count              = 1
      min_worker_count       = 1
      scale_in_policy {
        cpu_utilization_percentage = 20
      }
      scale_out_policy {
        cpu_utilization_percentage = 75
      }
    }
  }

  connector_configuration = {
    "connector.class" = "io.confluent.connect.s3.S3SinkConnector"
    "tasks.max"       = "1"
    "topics"          = "demo-topic"
    "s3.bucket.name"  = "my-sink-bucket"
    "format.class"    = "io.confluent.connect.s3.format.json.JsonFormat"
    "flush.size"      = "3"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.example.bootstrap_brokers_tls
      vpc {
        security_groups = [aws_security_group.msk.id]
        subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_logs.name
      }
    }
  }

  service_execution_role_arn = aws_iam_role.mskconnect.arn
}
```

---

## ✅ TL;DR Summary

|Feature|Amazon MSK (Managed Kafka)|
|---|---|
|Serverless?|❌ (You manage instance count)|
|IAM Integration|✅ IAM auth plugin|
|Open-source Compatible?|✅ Fully Kafka compatible (open protocol)|
|Managed Kafka Connect|✅ MSK Connect|
|Network Placement|In your VPC, no public access|
|Terraform Support|✅ Yes (Cluster, Connect, Auth, Logging)|
|Ideal Use Case|High-scale, low-latency streaming platform|

---
