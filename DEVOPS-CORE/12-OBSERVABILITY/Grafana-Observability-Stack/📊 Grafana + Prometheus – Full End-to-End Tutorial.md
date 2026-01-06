
![Image](https://devopscube.com/content/images/2025/03/prometheus-architecture.gif?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A9_XeHLdBdRveDxVVBPf_kA.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/0%2AsV4qTWT8tt9Mhhmj?utm_source=chatgpt.com)

---

## 1️⃣ What is Grafana + Prometheus?

### 🔹 Prometheus

- Collects & stores **metrics**
    
- Uses **PromQL**
    
- Pull-based monitoring
    

### 🔹 Grafana

- **Visualizes metrics**
    
- Dashboards, charts, alerts
    
- Works with Prometheus, Loki, etc.
    

👉 Together = **Industry-standard monitoring stack**

---

## 2️⃣ Architecture Overview

```
[ Server / App ]
      ↓
[ Exporter (Node Exporter, App Exporter) ]
      ↓
[ Prometheus ]
      ↓
[ Grafana ]
      ↓
[ Alerts → Slack / Email ]
```

---

## 3️⃣ Prerequisites

You need:

- Linux VM / server
    
- Prometheus running (port `9090`)
    
- Node Exporter running (port `9100`)
    
- Internet access
    

---

## 4️⃣ Install Grafana (Linux – Recommended)

### Step 1: Add Grafana Repo

```bash
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
```

---

### Step 2: Install Grafana

```bash
sudo apt update
sudo apt install grafana -y
```

---

### Step 3: Start Grafana

```bash
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

---

### Step 4: Access Grafana

```
http://SERVER_IP:3000
```

**Default login**

```
username: admin
password: admin
```

(Change password after first login)

---

## 5️⃣ Add Prometheus as Data Source

### Steps in Grafana UI

```
Settings → Data Sources → Add data source → Prometheus
```

### Configuration

```
URL: http://PROMETHEUS_IP:9090
```

Click **Save & Test**  
✔ Data source connected

---

## 6️⃣ Verify Connection (Quick Test)

Go to:

```
Explore → Run query: up
```

You should see:

```
job="prometheus" = 1
job="node_exporter" = 1
```

---

## 7️⃣ Import Ready-Made Dashboards (BEST PRACTICE)

### 🔥 Most Popular Node Exporter Dashboard

```
Dashboard ID: 1860
Name: Node Exporter Full
```

### How to Import

```
+ → Import → Enter ID → Load → Select Prometheus → Import
```

---

## 8️⃣ Important Dashboards to Use

|Purpose|Dashboard ID|
|---|---|
|Node Exporter Full|1860|
|Linux Server|13978|
|Docker Monitoring|893|
|Prometheus Stats|3662|

---

## 9️⃣ Key Metrics You’ll See

### CPU

```promql
avg(rate(node_cpu_seconds_total{mode!="idle"}[5m])) * 100
```

### Memory

```promql
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

### Disk Usage

```promql
100 - (node_filesystem_avail_bytes / node_filesystem_size_bytes * 100)
```

---

## 10️⃣ Create Your Own Dashboard (Basic)

### Steps

```
Dashboards → New → Add visualization
```

### Example

- Data source: Prometheus
    
- Query:
    

```promql
node_load1
```

- Visualization: Time series
    

Save dashboard.

---

## 🚨 11️⃣ Alerts in Grafana (NEW Alerting)

Grafana supports **unified alerting** (no need Alertmanager for basic alerts).

---

### Example: High CPU Alert

1. Edit panel
    
2. Go to **Alert → Create alert rule**
    
3. Query:
    

```promql
avg(rate(node_cpu_seconds_total{mode!="idle"}[5m])) > 0.8
```

4. Condition: for 2 minutes
    
5. Notification: Slack / Email
    

---

## 12️⃣ Slack Alert Setup

### Create Slack Webhook

```
Slack → Apps → Incoming Webhooks
```

### Grafana

```
Alerting → Contact points → Slack
```

Paste webhook URL.

---

## 13️⃣ Grafana + Prometheus with Docker Compose

```yaml
version: "3"

services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

Run:

```bash
docker-compose up -d
```

---

## 14️⃣ Grafana + Prometheus in Kubernetes (Overview)

Production standard:

```
kube-prometheus-stack (Helm)
```

Includes:

- Prometheus
    
- Grafana
    
- Alertmanager
    
- Node Exporter
    

---

## 15️⃣ Security Best Practices

✔ Do NOT expose Grafana publicly  
✔ Change default admin password  
✔ Enable authentication (OAuth)  
✔ Restrict Prometheus access  
✔ Use VPN / private network

---

## 16️⃣ Common Problems & Fixes

|Problem|Fix|
|---|---|
|No data|Prometheus URL wrong|
|Dashboard empty|Wrong job labels|
|High CPU alerts noisy|Increase alert duration|
|Grafana restart resets|Use persistent volume|

---

## 17️⃣ Grafana vs Prometheus (Clear Difference)

|Tool|Purpose|
|---|---|
|Prometheus|Collect & store metrics|
|Grafana|Visualize & alert|
|Loki|Logs|
|Tempo|Traces|

---

## 18️⃣ Production-Grade Monitoring Stack

```
Node Exporter
      ↓
Prometheus (HA)
      ↓
Grafana
      ↓
Alerts → Slack / PagerDuty
```

(Optional)

```
Logs → Loki
Traces → Tempo
```

---

## ✅ Final Summary

✔ Prometheus = metrics engine  
✔ Grafana = visualization & alerting  
✔ Works with VM, Docker, Kubernetes  
✔ Industry standard DevOps stack  
✔ Scales from startup → enterprise

---
