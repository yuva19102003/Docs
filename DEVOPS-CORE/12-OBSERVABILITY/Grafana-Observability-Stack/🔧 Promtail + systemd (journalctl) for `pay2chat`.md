
![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AgTD64wp0vn2AZ5SazChi_w.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1270/1%2A5Lpbu46ybiGZnxRRRO4Qjw.png?utm_source=chatgpt.com)

![Image](https://boredconsultant.com/2022/06/20/Collecting-logs-in-the-cloud-with-Grafana-Loki/grafana-loki-explore-view.png?utm_source=chatgpt.com)

---

## 1️⃣ Current Situation (Your Case)

✔ Backend runs via `systemd`  
✔ Logs visible using:

```bash
journalctl -u pay2chat
```

❌ No log file (`.log`)  
❌ Only current logs visible

👉 **Solution**: Promtail → journald → Loki → Grafana

---

## 2️⃣ High-Level Flow

```
pay2chat (systemd service)
        ↓
     journald
        ↓
     Promtail
        ↓
        Loki
        ↓
      Grafana
```

---

## 3️⃣ Prerequisites

- Promtail installed on the same server
    
- Loki running (local or remote)
    
- pay2chat service name known (`pay2chat.service`)
    

Check service name:

```bash
systemctl list-units | grep pay2chat
```

---

## 4️⃣ Promtail Config for systemd Logs (IMPORTANT)

Edit Promtail config:

```bash
sudo nano /etc/promtail/promtail.yml
```

### ✅ Minimal & Correct Config for journald

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://LOKI_IP:3100/loki/api/v1/push

scrape_configs:
  - job_name: pay2chat_journal
    journal:
      max_age: 12h
      labels:
        job: pay2chat
        env: prod
```

📌 This reads **ALL journald logs**  
📌 We’ll filter only `pay2chat` in the next step

---

## 5️⃣ Filter Only `pay2chat` Logs (Best Practice)

Add a **pipeline stage filter** 👇

```yaml
scrape_configs:
  - job_name: pay2chat_journal
    journal:
      max_age: 12h
      labels:
        job: pay2chat
        env: prod

    pipeline_stages:
      - match:
          selector: '{job="pay2chat"}'
          stages:
            - regex:
                expression: '.*'
```

But journald already has metadata — we should use **systemd unit filter** instead 👇

---

## ✅ BEST & CLEAN WAY (Recommended)

```yaml
scrape_configs:
  - job_name: pay2chat_journal
    journal:
      max_age: 12h
      labels:
        job: pay2chat
        env: prod
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        regex: 'pay2chat.service'
        action: keep
```

✔ Only logs from `pay2chat.service`  
✔ No noise  
✔ Production-safe

---

## 6️⃣ Ensure Promtail Has Permission to Read Journald

Promtail **must run as root** (or journald group).

Check service:

```bash
sudo nano /etc/systemd/system/promtail.service
```

Ensure:

```ini
[Service]
User=root
ExecStart=/usr/local/bin/promtail \
  -config.file=/etc/promtail/promtail.yml
```

Restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart promtail
```

---

## 7️⃣ Verify Promtail is Reading pay2chat Logs

```bash
journalctl -u promtail -f
```

You should see something like:

```
level=info msg="tailing journal"
```

No errors = ✅

---

## 8️⃣ View Logs in Grafana (IMPORTANT)

### Open Grafana → Explore → Loki

Use this query:

```logql
{job="pay2chat"}
```

Or:

```logql
{job="pay2chat", env="prod"}
```

🎉 You’ll now see **historical + live logs**

---

## 9️⃣ Bonus: See Same Logs as journalctl

Compare:

```bash
journalctl -u pay2chat -f
```

Grafana:

```logql
{job="pay2chat"}
```

✔ Same logs  
✔ Searchable  
✔ Filterable  
✔ Persisted

---

## 10️⃣ Optional: Parse Log Levels (Node.js)

If your backend logs like:

```
INFO Server started
ERROR Database failed
```

Add parsing 👇

```yaml
pipeline_stages:
  - regex:
      expression: '(?P<level>INFO|ERROR|WARN|DEBUG)'
```

Then query:

```logql
{job="pay2chat", level="ERROR"}
```

---

## 11️⃣ Very Important ⚠️ (Avoid This)

❌ Don’t label:

```
request_id
user_id
timestamp
```

✔ Good labels:

```
job
env
service
level
```

High-cardinality labels will **crash Loki**.

---

## 12️⃣ Recommended Production Setup for pay2chat

```
Metrics → Prometheus + Node Exporter
Logs    → Promtail (journald) + Loki
UI      → Grafana
```

---

## ✅ Final Answer (Short)

You **do NOT need log files**.

✔ Promtail can read `journalctl`  
✔ Filter by `pay2chat.service`  
✔ Push to Loki  
✔ View in Grafana  
✔ Works with systemd perfectly

---
