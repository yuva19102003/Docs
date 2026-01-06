
![Image](https://miro.medium.com/v2/resize%3Afit%3A2000/1%2AmTQZijSrIXBp6FSmF7V_jw.png?utm_source=chatgpt.com)

![Image](https://grafana.com/docs/loki/latest/send-data/promtail/logrotation/logrotation-components.png?utm_source=chatgpt.com)

![Image](https://grafana.com/media/blog/qonto-guest-post/screenshot-qonto-dashboard.png?utm_source=chatgpt.com)

---

## 1️⃣ What is Promtail?

**Promtail** is a **log collection agent** for **Grafana Loki**.

👉 Think of it like:

- **Node Exporter → metrics**
    
- **Promtail → logs**
    

Promtail:

- Reads logs from files / systemd / Docker
    
- Adds **labels**
    
- Pushes logs to **Loki**
    

---

## 2️⃣ What Promtail Is NOT

❌ Not a log storage system  
❌ Not a UI  
❌ Not a full log processor like Logstash

👉 **Promtail = lightweight log shipper**

---

## 3️⃣ Where Promtail Fits

```
[ Application / Server Logs ]
        ↓
     Promtail
        ↓
       Loki
        ↓
     Grafana
```

---

## 4️⃣ What Logs Can Promtail Collect?

✅ System logs (`/var/log/syslog`, `journalctl`)  
✅ Application logs (Node, Go, Java, etc.)  
✅ Nginx / Apache logs  
✅ Docker container logs  
✅ Kubernetes pod logs

---

## 5️⃣ Installation (Linux – Recommended)

### Step 1: Download Promtail

```bash
cd /tmp
wget https://github.com/grafana/loki/releases/latest/download/promtail-linux-amd64.zip
```

### Step 2: Extract

```bash
unzip promtail-linux-amd64.zip
chmod +x promtail-linux-amd64
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
```

---

## 6️⃣ Promtail Configuration File

### Create Config Directory

```bash
sudo mkdir /etc/promtail
sudo nano /etc/promtail/promtail.yml
```

---

### Basic promtail.yml

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://LOKI_SERVER_IP:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: syslog
          __path__: /var/log/syslog
```

📌 `positions.yaml` ensures **no duplicate logs**

---

## 7️⃣ Create Systemd Service

```bash
sudo nano /etc/systemd/system/promtail.service
```

```ini
[Unit]
Description=Promtail Log Collector
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/promtail \
  -config.file=/etc/promtail/promtail.yml

[Install]
WantedBy=multi-user.target
```

---

### Start Promtail

```bash
sudo systemctl daemon-reload
sudo systemctl enable promtail
sudo systemctl start promtail
```

---

### Check Status

```bash
sudo systemctl status promtail
```

---

## 8️⃣ Verify Promtail is Working

Check logs:

```bash
journalctl -u promtail -f
```

You should see:

```
msg="tailing file" path=/var/log/syslog
```

---

## 9️⃣ Loki Setup (Quick Overview)

Loki runs on:

```
http://LOKI_IP:3100
```

If not installed, basic Docker run:

```bash
docker run -d -p 3100:3100 grafana/loki:2.9.0
```

---

## 10️⃣ View Logs in Grafana

### Step 1: Add Loki Data Source

```
Grafana → Settings → Data Sources → Loki
URL: http://LOKI_IP:3100
```

---

### Step 2: Explore Logs

```
Explore → Select Loki
```

### Example Query

```logql
{job="syslog"}
```

---

## 11️⃣ Promtail for Application Logs (Node.js Example)

### App Log Path

```
/var/www/app/logs/app.log
```

### promtail.yml

```yaml
scrape_configs:
  - job_name: node_app
    static_configs:
      - targets:
          - localhost
        labels:
          job: nodejs
          env: prod
          __path__: /var/www/app/logs/*.log
```

---

## 12️⃣ Parsing Logs (Pipeline Stages)

### JSON Logs Example

```yaml
pipeline_stages:
  - json:
      expressions:
        level: level
        msg: message
```

---

### Regex Parsing

```yaml
pipeline_stages:
  - regex:
      expression: '(?P<level>\w+): (?P<msg>.*)'
```

---

## 13️⃣ Promtail with Docker Logs

```yaml
scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*.log
```

---

## 14️⃣ Promtail with systemd (journalctl)

```yaml
scrape_configs:
  - job_name: journal
    journal:
      path: /var/log/journal
      labels:
        job: systemd
```

---

## 15️⃣ Promtail in Docker

```bash
docker run -d \
  -v /var/log:/var/log \
  -v /etc/promtail:/etc/promtail \
  grafana/promtail \
  -config.file=/etc/promtail/promtail.yml
```

---

## 16️⃣ Promtail in Kubernetes (Overview)

- Runs as **DaemonSet**
    
- Collects logs from:
    
    ```
    /var/log/pods
    ```
    

Standard setup via:

```
loki-stack Helm chart
```

---

## 17️⃣ Labels – VERY IMPORTANT ⚠️

Bad labels ❌

```
request_id
user_id
timestamp
```

Good labels ✅

```
app
env
job
level
```

👉 High-cardinality labels = **Loki crash**

---

## 18️⃣ Common Issues & Fixes

|Issue|Fix|
|---|---|
|No logs|Check `__path__`|
|Duplicates|Check positions.yaml|
|Loki down|Promtail retries|
|High memory|Reduce labels|

---

## 19️⃣ Promtail vs Alternatives

|Tool|Type|
|---|---|
|Promtail|Loki log shipper|
|Fluent Bit|Logs + metrics|
|Logstash|Heavy processing|
|Filebeat|ELK stack|

---

## 20️⃣ Production Best Practices

✔ Use structured logs (JSON)  
✔ Avoid high-cardinality labels  
✔ Separate prod / staging  
✔ Rotate logs  
✔ Monitor Promtail itself

---

## 🏗️ Full Observability Stack (Best Practice)

```
Metrics → Prometheus + Node Exporter
Logs    → Promtail + Loki
Traces  → Tempo
UI      → Grafana
```

---

## ✅ Final Summary

✔ Lightweight & fast  
✔ Perfect match for Loki  
✔ Easy to configure  
✔ Scales well  
✔ Ideal for DevOps & Cloud

---
