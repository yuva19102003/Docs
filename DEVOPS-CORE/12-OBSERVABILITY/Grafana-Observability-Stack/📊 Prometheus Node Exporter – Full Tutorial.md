

![Image](https://devopscube.com/content/images/2025/03/image-118-9.png?utm_source=chatgpt.com)

![Image](https://devopscube.com/content/images/2025/03/prometheus-architecture.gif?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A9_XeHLdBdRveDxVVBPf_kA.png?utm_source=chatgpt.com)

---

## 1️⃣ What is Node Exporter?

**Node Exporter** is a **Prometheus exporter** that exposes **OS-level system metrics** from a Linux server.

### It collects:

- CPU usage
    
- Memory usage
    
- Disk usage & I/O
    
- Network traffic
    
- Load average
    
- Filesystem stats
    
- Hardware info
    

👉 It does **NOT** monitor applications  
👉 It monitors **the server itself**

---

## 2️⃣ Where Node Exporter Fits

```
[ Linux Server ]
     ↓
[ Node Exporter :9100 ]
     ↓
[ Prometheus ]
     ↓
[ Grafana Dashboard ]
```

---

## 3️⃣ When to Use Node Exporter

✅ Monitor VM / bare metal  
✅ Cloud servers (AWS, Azure, DO, OCI)  
✅ Kubernetes nodes  
❌ Not for application-level metrics

---

## 4️⃣ Default Port

```
9100
```

Metrics endpoint:

```
http://SERVER_IP:9100/metrics
```

---

## 5️⃣ Installation (Linux – Recommended Way)

### Step 1: Download Binary

```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.7.0.linux-amd64.tar.gz
```

### Step 2: Extract

```bash
tar xvf node_exporter-*.tar.gz
cd node_exporter-*/
```

### Step 3: Move Binary

```bash
sudo mv node_exporter /usr/local/bin/
```

---

## 6️⃣ Create Systemd Service (IMPORTANT)

### Create Service File

```bash
sudo nano /etc/systemd/system/node_exporter.service
```

### Paste This

```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

---

### Enable & Start

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

---

### Check Status

```bash
sudo systemctl status node_exporter
```

---

## 7️⃣ Verify Node Exporter

Open in browser:

```
http://SERVER_IP:9100/metrics
```

✔ If you see metrics → working correctly

---

## 8️⃣ Firewall Rules (IMPORTANT)

```bash
sudo ufw allow 9100
```

Or allow only Prometheus server IP (recommended).

---

## 9️⃣ Integrate with Prometheus

### prometheus.yml

```yaml
scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets:
          - "SERVER_IP:9100"
```

---

### Reload Prometheus

```bash
sudo systemctl reload prometheus
```

---

## 🔍 10️⃣ Verify in Prometheus UI

Open:

```
http://PROMETHEUS_IP:9090
```

Check:

- **Status → Targets**
    
- `node_exporter` should be **UP**
    

---

## 📈 11️⃣ Grafana Dashboard (Recommended)

### Step 1: Add Prometheus as Data Source

```
Grafana → Settings → Data Sources → Prometheus
URL: http://PROMETHEUS_IP:9090
```

---

### Step 2: Import Dashboard

**Best Dashboard ID**

```
1860
```

✔ “Node Exporter Full”

---

## 12️⃣ Key Metrics You’ll Use

|Metric|Meaning|
|---|---|
|node_cpu_seconds_total|CPU usage|
|node_memory_MemAvailable_bytes|Free memory|
|node_filesystem_avail_bytes|Disk free|
|node_load1|Load avg|
|node_network_receive_bytes_total|Network in|
|node_disk_io_time_seconds_total|Disk IO|

---

## 13️⃣ Alerts (Example)

### High CPU Alert

```yaml
- alert: HighCPUUsage
  expr: avg(rate(node_cpu_seconds_total{mode!="idle"}[5m])) > 0.8
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage detected"
```

---

## 14️⃣ Node Exporter in Docker

```bash
docker run -d \
  --name=node-exporter \
  -p 9100:9100 \
  --pid=host \
  -v "/:/host:ro,rslave" \
  prom/node-exporter \
  --path.rootfs=/host
```

---

## 15️⃣ Node Exporter in Kubernetes

```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus/node_exporter/master/examples/node-exporter-daemonset.yaml
```

Runs on **every node** as DaemonSet.

---

## 16️⃣ Security Best Practices

✔ Do not expose 9100 publicly  
✔ Restrict access to Prometheus IP  
✔ Use firewall rules  
✔ Run as non-root  
✔ Use VPN / private network

---

## 17️⃣ Node Exporter vs Alternatives

|Tool|Purpose|
|---|---|
|Node Exporter|OS metrics|
|cAdvisor|Container metrics|
|Telegraf|Metrics + logs|
|CloudWatch Agent|AWS only|
|Azure Monitor Agent|Azure only|

---

## 18️⃣ Real-World Production Setup

```
Node Exporter → Prometheus → Alertmanager → Slack/Email
                         ↓
                      Grafana
```

---

## 19️⃣ Common Mistakes ❌

|Mistake|Fix|
|---|---|
|Port blocked|Open 9100|
|Target DOWN|Check firewall|
|Wrong IP|Use private IP|
|Running as root|Use nobody|

---

## ✅ Final Summary

✔ Lightweight  
✔ Zero config  
✔ Industry standard  
✔ Works everywhere  
✔ Perfect for infra monitoring

---
