# 🔷 What is Kafka UI?

**Kafka UI** is a **web-based dashboard** to:

* View topics & partitions
* Monitor consumer groups & lag
* Produce & consume messages
* Manage schemas
* Inspect configs (safe, read-only by default)

👉 It replaces painful CLI debugging in daily work.

![Image](https://www.instaclustr.com/wp-content/uploads/Screenshot-2024-01-18-at-5.00.49%E2%80%AFpm.png)

![Image](https://www.instaclustr.com/wp-content/uploads/Screenshot-2024-01-18-at-3.53.41%E2%80%AFpm.png)

![Image](https://www.entechlog.com/images/blog/kafka/kafka-consumer-lag/kafka-ui-dashboard_hu93eb829566bcf915abf9f0c70df0ab06_57783_1288x503_resize_q100_h2_box_3.webp)

![Image](https://docs.cloudera.com/runtime/7.3.1/schema-registry-overview/images/Schema-Registry-UI.png)


---

## 🔷 Why Kafka UI is Important (Real DevOps Reason)

| Without Kafka UI  | With Kafka UI        |
| ----------------- | -------------------- |
| CLI only          | Visual + CLI         |
| Hard to debug lag | Instant lag graphs   |
| No visibility     | Full cluster insight |
| Risky admin ops   | Safer UI actions     |

💡 In production, **Kafka UI is mandatory**, not optional.

---

## 🔷 Architecture (How Kafka UI Works)


![Image](https://user-images.githubusercontent.com/12738569/141159348-007ad5f4-b76d-4550-9b49-b715a72b1d5f.png)

```
Browser
   ↓
Kafka UI
   ↓
Kafka Brokers
   ↓
Schema Registry (optional)
```

Kafka UI is **stateless** → easy to deploy.

---

## 🔷 Install Kafka UI (Docker – Recommended)

### 📦 Prerequisites

* Kafka running (your existing setup)
* Docker

---

### 🔹 docker-compose.yml (Kafka + Kafka UI)

```yaml
version: "3.8"

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
    depends_on:
      - kafka
```

Start everything:

```bash
docker compose up -d
```

---

### 🌐 Access Kafka UI

```
http://localhost:8080
```

You should see:

* Cluster name: **local**
* Broker count
* Topics count

---

## 🔷 Kafka UI Features (Hands-On Walkthrough)

---

### 1️⃣ Topics View

You can:

* List topics
* See partitions & replication
* Check retention & cleanup policy

👉 Click `user-events` → **Partitions tab**

You’ll see:

* Partition ID
* Leader broker
* Offset range

---

### 2️⃣ Produce Messages (UI)

Steps:

1. Open **Topics**
2. Select topic → **Messages**
3. Click **Produce Message**

Example:

```json
Key: user123
Value:
{
  "event": "login",
  "device": "mobile"
}
```

✔ Message instantly visible to consumers.

---

### 3️⃣ Consume Messages (UI)

* Choose topic
* Set:

  * Offset: earliest / latest
  * Limit: 100
* Click **Consume**

🔥 This is extremely useful for debugging.

---

### 4️⃣ Consumer Groups (MOST IMPORTANT)

Open **Consumer Groups** tab.

You’ll see:

* Group name
* Assigned partitions
* **Lag per partition**
* Total lag

👉 Lag ≠ bad always
👉 Growing lag = red flag 🚨

---

### 5️⃣ Consumer Lag Explained (Visual)



![Image](https://www.entechlog.com/images/blog/kafka/kafka-consumer-lag/overview.png)

```
Latest Offset: 1000
Consumer Offset: 850
Lag = 150
```

Meaning:

* Consumer is behind
* Needs scaling or optimization

---

### 6️⃣ Topic Configuration (Read-only by default)

Kafka UI shows:

* retention.ms
* cleanup.policy
* segment.bytes

⚠️ In production, **editing configs should be restricted**.

---

## 🔷 Schema Registry Integration (Optional but Powerful)

If using **Avro / Protobuf / JSON Schema**:

Kafka UI can:

* View schemas
* Track versions
* Validate compatibility

Example config:

```yaml
KAFKA_CLUSTERS_0_SCHEMAREGISTRY: http://schema-registry:8081
```

---

## 🔷 Security (Production Setup)

### 🔐 Authentication Options

* Basic Auth
* OAuth2
* LDAP
* OIDC (Keycloak)

### 🔒 Kafka Security Support

* SSL
* SASL/PLAIN
* SASL/SCRAM
* SASL/OAUTH

---

## 🔷 Kafka UI vs Other Tools

| Tool                     | Notes               |
| ------------------------ | ------------------- |
| Kafka UI                 | Best open-source UI |
| Confluent Control Center | Paid                |
| AKHQ                     | Older, less UX      |
| CLI                      | Still needed        |

👉 Kafka UI is the **industry default OSS choice**.

---

## 🔷 Common Mistakes 🚨

❌ Exposing Kafka UI publicly
❌ No authentication
❌ Using UI to delete prod topics
❌ Ignoring lag warnings

---

## 🔷 Best Practices (DevOps Approved ✅)

✔ Deploy Kafka UI inside private network
✔ Protect with auth
✔ Read-only for most users
✔ Monitor lag via Prometheus
✔ Use UI for debugging, not automation

---

## 🔷 When to Use Kafka UI vs CLI

| Task             | Tool            |
| ---------------- | --------------- |
| Debug lag        | Kafka UI        |
| Inspect messages | Kafka UI        |
| Bulk admin       | CLI             |
| Automation       | CLI / Terraform |

---

## 🧠 Mental Model

> **Kafka UI is your observability lens, not your control plane.**

---

## ✅ What You Can Do Now

* Debug consumer lag in seconds
* Inspect live Kafka data
* Safely explore production clusters
* Reduce incident resolution time

---
