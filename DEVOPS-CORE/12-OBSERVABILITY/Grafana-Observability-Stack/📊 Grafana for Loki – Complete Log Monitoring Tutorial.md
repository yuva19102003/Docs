
![Image](https://grafana.com/docs/loki/latest/get-started/loki_architecture_components.svg?utm_source=chatgpt.com)

![Image](https://grafana.com/static/assets/img/blog/logcontext_explore.png?utm_source=chatgpt.com)

![Image](https://grafana.com/media/blog/improve-log-dashboards/screenshot-improve-log-dashboards-dashboard.png?w=1504&utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AyC1F-AxwK-s2D7nEvgdvKQ.png?utm_source=chatgpt.com)

---

## 1️⃣ What is Grafana for Loki?

Grafana is the **UI layer** for Loki.

- Loki → stores logs
    
- Grafana → **search, filter, visualize, alert on logs**
    

Think of it as:

```
Prometheus : Grafana :: Loki : Grafana
```

---

## 2️⃣ Final Architecture (What You’re Building)

```
Application (pay2chat)
        ↓
     journald
        ↓
     Promtail
        ↓
       Loki
        ↓
     Grafana
   (Explore + Dashboards + Alerts)
```

---

## 3️⃣ Prerequisites

You already need:

- Loki running (`http://localhost:3100`)
    
- Promtail pushing logs
    
- Grafana running (`http://localhost:3000`)
    

---

## 4️⃣ Add Loki as Data Source in Grafana

### Step-by-step (UI)

1. Open Grafana
    
    ```
    http://SERVER_IP:3000
    ```
    
2. Go to:
    
    ```
    Settings → Data Sources → Add data source
    ```
    
3. Select:
    
    ```
    Loki
    ```
    
4. Configure:
    
    ```
    URL: http://localhost:3100
    ```
    
5. Click:
    
    ```
    Save & Test
    ```
    

✅ You should see **“Data source connected”**

---

## 5️⃣ Grafana Explore – Core Log Monitoring Tool

### Open Explore

```
Grafana → Explore
```

Select data source:

```
Loki
```

---

## 6️⃣ Basic Log Query (VERY IMPORTANT)

### Show all pay2chat logs

```logql
{job="pay2chat"}
```

This is equivalent to:

```bash
journalctl -u pay2chat
```

But now:  
✔ searchable  
✔ filterable  
✔ time-based  
✔ persistent

---

## 7️⃣ Live Log Streaming (Like `-f`)

In Explore:

- Toggle **Live**
    
- Run:
    

```logql
{job="pay2chat"}
```

🎯 This behaves like:

```bash
journalctl -u pay2chat -f
```

---

## 8️⃣ LogQL Basics (Must Know)

### 8.1 Filter by Text

```logql
{job="pay2chat"} |= "ERROR"
```

```logql
{job="pay2chat"} |= "Mongo"
```

---

### 8.2 Exclude Text

```logql
{job="pay2chat"} != "healthcheck"
```

---

### 8.3 Regex Search

```logql
{job="pay2chat"} |~ "ERROR|WARN"
```

---

### 8.4 Time Range

Use Grafana top-right:

```
Last 5m | 15m | 1h | 24h
```

---

## 9️⃣ If You Parsed Log Levels (Recommended)

If Promtail added:

```
level=INFO|ERROR|WARN
```

### Query only errors

```logql
{job="pay2chat", level="ERROR"}
```

### Query warnings

```logql
{job="pay2chat", level="WARN"}
```

---

## 10️⃣ Create Log Dashboards (IMPORTANT)

Logs don’t have to live only in **Explore**.

### Create Dashboard

```
Dashboards → New → New dashboard
```

Add panel:

- Visualization: **Logs**
    
- Data source: Loki
    
- Query:
    

```logql
{job="pay2chat"}
```

Save as:

```
pay2chat – Logs
```

---

## 11️⃣ Useful Log Panels to Create

### 🔹 Errors Panel

```logql
{job="pay2chat"} |= "ERROR"
```

### 🔹 Warnings Panel

```logql
{job="pay2chat"} |= "WARN"
```

### 🔹 Auth / Login Logs

```logql
{job="pay2chat"} |= "login"
```

---

## 12️⃣ Convert Logs → Metrics (POWERFUL)

Grafana Loki can **count logs**.

### Errors per minute

```logql
count_over_time({job="pay2chat"} |= "ERROR" [1m])
```

Visualization:

- Time series
    

Now you have **error rate graphs** 📈

---

## 13️⃣ Alerts on Logs (VERY IMPORTANT)

### Example: Alert on ERROR logs

Go to:

```
Alerting → Alert rules → New alert rule
```

Query:

```logql
count_over_time({job="pay2chat"} |= "ERROR" [1m]) > 0
```

Condition:

- For: `2m`
    

Notification:

- Slack / Email / Discord
    

🚨 You now get alerts when errors appear in logs.

---

## 14️⃣ Example: Crash Detection Alert

```logql
count_over_time({job="pay2chat"} |= "UnhandledPromiseRejection" [1m]) > 0
```

---

## 15️⃣ Correlate Logs + Metrics (Best Practice)

If you already use Prometheus:

```
CPU spike → click time → view logs
```

Grafana allows:

- Shared time range
    
- Same dashboard
    
- Faster debugging
    

---

## 16️⃣ Log Retention Awareness

Grafana **does NOT store logs**  
Loki does.

So:

- If logs disappear → check Loki retention
    
- Grafana only visualizes
    

---

## 17️⃣ Performance & UX Tips

✔ Use **labels for filtering**, not content  
✔ Use **text filters sparingly**  
✔ Narrow time range for faster queries  
✔ Avoid wild regex on large ranges

---

## 18️⃣ Common Mistakes ❌

|Mistake|Why bad|
|---|---|
|Using user_id as label|High cardinality|
|Searching huge time range|Slow|
|Using Loki for metrics|Wrong tool|
|No alerts|Blind failures|

---

## 19️⃣ Recommended Dashboards for pay2chat

Create one dashboard with:

- Live logs
    
- Error logs
    
- Error count graph
    
- Auth logs
    
- Deployment logs
    

---

## 20️⃣ Final Production Observability Stack

```
Metrics → Prometheus + Node Exporter
Logs    → Promtail + Loki
UI      → Grafana
Alerts  → Grafana Alerting
```

---

## ✅ Final Summary

✔ Grafana is the **control center for Loki logs**  
✔ Explore = live debugging  
✔ Dashboards = observability  
✔ Alerts = reliability  
✔ Perfect for systemd + backend apps

---
