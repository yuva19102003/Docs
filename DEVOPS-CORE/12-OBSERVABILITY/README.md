# 📊 Observability & Monitoring

**Complete Guide to Monitoring, Logging, and Tracing for DevOps**

---

## 📚 Overview

This section covers the complete observability stack - from metrics collection with Prometheus to visualization with Grafana, log aggregation with Loki, and distributed tracing with OpenTelemetry. Learn how to monitor, troubleshoot, and optimize your infrastructure and applications.

---

## 🎯 What is Observability?

**Observability** is the ability to understand the internal state of a system by examining its outputs. It consists of three pillars:

1. **Metrics** - Numerical data about system performance (CPU, memory, requests/sec)
2. **Logs** - Detailed records of events and transactions
3. **Traces** - Request flow through distributed systems

---

## 📁 Folder Structure

```
OBSERVABILITY/
├── README.md                           ✅ This file
│
├── Grafana-Observability-Stack/        ✅ Complete monitoring stack
│   ├── 0-Grafana-Observability-Stack.md
│   ├── 📈 Prometheus – Full End-to-End Tutorial.md
│   ├── 📊 Grafana + Prometheus – Full End-to-End Tutorial.md
│   ├── 📊 Grafana for Loki – Complete Log Monitoring Tutorial.md
│   ├── 📊 Prometheus Node Exporter – Full Tutorial.md
│   ├── 📜 Promtail – Full End-to-End Tutorial (with Loki & Grafana).md
│   ├── 📦 Grafana Loki Storage – S3 - Azure Blob - DO Spaces (End-to-End).md
│   └── 🔧 Promtail + systemd (journalctl) for `pay2chat`.md
│
├── Helm-Deployments/                   ✅ Kubernetes deployments
│   ├── prometheus-helm.md
│   └── grafana-helm.md
│
└── OpenTelemetry/                      ✅ Distributed tracing
    ├── OpenTelemetry.md
    ├── OpenTelemetry-Setup-Code.md
    └── otel-demo/
        ├── docker-compose.yml
        ├── otel-collector.yaml
        └── app/
```

---

## 🔧 Components

### 1. **Grafana Observability Stack**

Complete end-to-end monitoring solution combining multiple tools.

#### **Prometheus** - Metrics Collection
- Time-series database
- Pull-based metrics collection
- PromQL query language
- Alerting capabilities

**Tutorial:** `📈 Prometheus – Full End-to-End Tutorial.md`

**Key Features:**
- Service discovery
- Multi-dimensional data model
- Powerful query language
- Built-in alerting
- Horizontal scalability

**Use Cases:**
- Infrastructure monitoring
- Application metrics
- Custom business metrics
- SLA monitoring

---

#### **Grafana** - Visualization & Dashboards
- Beautiful, customizable dashboards
- Multiple data source support
- Alerting and notifications
- User management

**Tutorials:**
- `📊 Grafana + Prometheus – Full End-to-End Tutorial.md`
- `📊 Grafana for Loki – Complete Log Monitoring Tutorial.md`

**Key Features:**
- Rich visualization options
- Template variables
- Dashboard sharing
- Plugin ecosystem
- Alert management

**Use Cases:**
- Real-time monitoring dashboards
- Historical data analysis
- Team collaboration
- Executive reporting

---

#### **Prometheus Node Exporter** - System Metrics
- Hardware and OS metrics
- CPU, memory, disk, network stats
- Runs on each monitored host

**Tutorial:** `📊 Prometheus Node Exporter – Full Tutorial.md`

**Metrics Collected:**
- CPU usage and load
- Memory and swap
- Disk I/O and space
- Network traffic
- System uptime

---

#### **Loki** - Log Aggregation
- Horizontally scalable log aggregation
- Inspired by Prometheus
- Cost-effective log storage
- LogQL query language

**Tutorials:**
- `📊 Grafana for Loki – Complete Log Monitoring Tutorial.md`
- `📦 Grafana Loki Storage – S3 - Azure Blob - DO Spaces (End-to-End).md`

**Key Features:**
- Label-based indexing
- Multi-tenancy
- Cloud storage backends (S3, Azure Blob, DO Spaces)
- Grafana integration

**Use Cases:**
- Application logs
- System logs
- Audit logs
- Troubleshooting

---

#### **Promtail** - Log Shipper
- Collects and ships logs to Loki
- Systemd journal integration
- Label extraction
- Pipeline processing

**Tutorials:**
- `📜 Promtail – Full End-to-End Tutorial (with Loki & Grafana).md`
- `🔧 Promtail + systemd (journalctl) for pay2chat.md`

**Key Features:**
- Multiple input sources
- Label discovery
- Pipeline stages
- Position tracking

---

### 2. **Helm Deployments**

Kubernetes deployment guides for monitoring stack.

#### **Prometheus Helm Chart**
**File:** `Helm-Deployments/prometheus-helm.md`

**Covers:**
- Helm chart installation
- Configuration options
- Service discovery in Kubernetes
- Persistent storage setup
- High availability configuration

**Deployment:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
```

---

#### **Grafana Helm Chart**
**File:** `Helm-Deployments/grafana-helm.md`

**Covers:**
- Helm chart installation
- Data source configuration
- Dashboard provisioning
- Authentication setup
- Ingress configuration

**Deployment:**
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana
```

---

### 3. **OpenTelemetry**

Modern distributed tracing and observability framework.

#### **What is OpenTelemetry?**
- Vendor-neutral observability framework
- Unified API for metrics, logs, and traces
- Auto-instrumentation for popular frameworks
- Flexible backend support

**Files:**
- `OpenTelemetry/OpenTelemetry.md` - Concepts and architecture
- `OpenTelemetry/OpenTelemetry-Setup-Code.md` - Implementation guide
- `OpenTelemetry/otel-demo/` - Working demo application

**Key Components:**
1. **SDK** - Instrument your code
2. **Collector** - Receive, process, export telemetry
3. **Exporters** - Send data to backends (Jaeger, Zipkin, Prometheus)

**Use Cases:**
- Distributed tracing
- Request flow visualization
- Performance bottleneck identification
- Service dependency mapping

**Demo Application:**
- Docker Compose setup
- Multi-service architecture
- Collector configuration
- Trace visualization

---

## 🎓 Learning Path

### Week 1-2: Metrics Foundation
1. **Prometheus Basics**
   - Install Prometheus
   - Understand metrics types (Counter, Gauge, Histogram, Summary)
   - Write PromQL queries
   - Set up basic alerts

2. **Node Exporter**
   - Deploy on servers
   - Understand system metrics
   - Create basic dashboards

### Week 3-4: Visualization
3. **Grafana Setup**
   - Install Grafana
   - Connect to Prometheus
   - Create dashboards
   - Set up alerts

4. **Advanced Dashboards**
   - Template variables
   - Panel types
   - Dashboard organization
   - Sharing and permissions

### Week 5-6: Logs
5. **Loki & Promtail**
   - Deploy Loki
   - Configure Promtail
   - Write LogQL queries
   - Integrate with Grafana

6. **Log Storage**
   - Configure S3/Azure Blob storage
   - Set up retention policies
   - Optimize performance

### Week 7-8: Tracing
7. **OpenTelemetry**
   - Understand distributed tracing
   - Instrument applications
   - Deploy collector
   - Visualize traces

8. **Production Setup**
   - High availability
   - Scaling strategies
   - Security best practices
   - Cost optimization

---

## 🚀 Quick Start

### Local Development Setup

#### 1. Prometheus + Grafana (Docker Compose)
```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

#### 2. Access Services
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

#### 3. Add Prometheus Data Source in Grafana
- URL: http://prometheus:9090
- Access: Server (default)

---

## 📊 Common Monitoring Patterns

### 1. **Infrastructure Monitoring**
**Metrics to Track:**
- CPU usage
- Memory utilization
- Disk I/O and space
- Network traffic
- System load

**Tools:** Prometheus + Node Exporter + Grafana

---

### 2. **Application Monitoring**
**Metrics to Track:**
- Request rate
- Error rate
- Response time (latency)
- Throughput

**Tools:** Prometheus + Application instrumentation + Grafana

---

### 3. **Log Monitoring**
**What to Monitor:**
- Error logs
- Access logs
- Application logs
- Security logs

**Tools:** Loki + Promtail + Grafana

---

### 4. **Distributed Tracing**
**What to Track:**
- Request flow
- Service dependencies
- Latency breakdown
- Error propagation

**Tools:** OpenTelemetry + Jaeger/Zipkin

---

## 🔍 Key Metrics to Monitor

### System Metrics
```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk Usage
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

### Application Metrics
```promql
# Request Rate
rate(http_requests_total[5m])

# Error Rate
rate(http_requests_total{status=~"5.."}[5m])

# Response Time (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

---

## 🎯 Best Practices

### Metrics
- ✅ Use consistent naming conventions
- ✅ Add meaningful labels
- ✅ Set appropriate scrape intervals
- ✅ Monitor the monitoring system itself
- ✅ Set up retention policies

### Dashboards
- ✅ Organize by service/team
- ✅ Use template variables
- ✅ Include documentation
- ✅ Set appropriate time ranges
- ✅ Use consistent color schemes

### Alerts
- ✅ Alert on symptoms, not causes
- ✅ Set appropriate thresholds
- ✅ Avoid alert fatigue
- ✅ Include runbooks
- ✅ Test alert rules

### Logs
- ✅ Use structured logging
- ✅ Add context (request ID, user ID)
- ✅ Set log levels appropriately
- ✅ Implement log rotation
- ✅ Secure sensitive data

### Tracing
- ✅ Sample appropriately
- ✅ Add custom spans for key operations
- ✅ Include relevant metadata
- ✅ Monitor trace volume
- ✅ Set retention policies

---

## 🛠️ Tools & Commands

### Prometheus
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Query metrics
curl 'http://localhost:9090/api/v1/query?query=up'

# Reload configuration
curl -X POST http://localhost:9090/-/reload
```

### Grafana
```bash
# Create API key
curl -X POST http://admin:admin@localhost:3000/api/auth/keys \
  -H "Content-Type: application/json" \
  -d '{"name":"mykey", "role": "Admin"}'

# Import dashboard
curl -X POST http://localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @dashboard.json
```

### Loki
```bash
# Query logs
curl -G -s "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={job="varlogs"}'

# Push logs
curl -H "Content-Type: application/json" \
  -XPOST -s "http://localhost:3100/loki/api/v1/push" \
  --data-raw '{"streams": [{"stream": {"job": "test"}, "values": ["1234567890000000000", "test log"]("1234567890000000000",%20"test%20log".md)}]}'
```

---

## 📈 Scaling Considerations

### Prometheus
- **Vertical Scaling:** Increase resources (CPU, memory, disk)
- **Horizontal Scaling:** Federation or Thanos
- **Storage:** Use remote storage for long-term retention

### Grafana
- **Load Balancing:** Multiple Grafana instances behind LB
- **Database:** Use external database (MySQL, PostgreSQL)
- **Caching:** Enable query caching

### Loki
- **Microservices Mode:** Separate components (ingester, querier, distributor)
- **Object Storage:** S3, Azure Blob, GCS for chunks
- **Caching:** Redis/Memcached for query results

---

## 🔐 Security Best Practices

### Authentication
- ✅ Enable authentication on all services
- ✅ Use strong passwords
- ✅ Implement SSO/OAuth
- ✅ Regular credential rotation

### Authorization
- ✅ Role-based access control (RBAC)
- ✅ Least privilege principle
- ✅ Separate read/write permissions
- ✅ Audit access logs

### Network Security
- ✅ Use TLS/SSL for all connections
- ✅ Firewall rules
- ✅ VPN for remote access
- ✅ Network segmentation

### Data Security
- ✅ Encrypt data at rest
- ✅ Encrypt data in transit
- ✅ Mask sensitive data in logs
- ✅ Secure backup storage

---

## 💡 Troubleshooting Guide

### Prometheus Not Scraping Targets
1. Check target configuration
2. Verify network connectivity
3. Check firewall rules
4. Verify metrics endpoint

### Grafana Dashboard Not Loading
1. Check data source connection
2. Verify query syntax
3. Check time range
4. Review Grafana logs

### Loki Not Receiving Logs
1. Check Promtail configuration
2. Verify network connectivity
3. Check Loki ingestion limits
4. Review Promtail logs

### OpenTelemetry Traces Missing
1. Verify instrumentation
2. Check collector configuration
3. Verify exporter settings
4. Review sampling configuration

---

## 🔗 Related Documentation

- **Infrastructure:** `../IAC/` - Terraform for monitoring infrastructure
- **Containers:** `../CONTAINERIZATION/` - Docker for monitoring stack
- **Cloud:** `../../CLOUD/` - Cloud-native monitoring
- **CI/CD:** `../CICD/` - Monitoring in pipelines

---

## 📚 Additional Resources

### Official Documentation
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Loki Docs](https://grafana.com/docs/loki/)
- [OpenTelemetry Docs](https://opentelemetry.io/docs/)

### Community
- Prometheus Community
- Grafana Community Forums
- CNCF Slack channels

### Training
- Grafana Labs Training
- Prometheus Certified Associate
- OpenTelemetry workshops

---

## 📝 Summary

This observability section provides:
- ✅ Complete monitoring stack (Prometheus, Grafana, Loki)
- ✅ Kubernetes deployment guides (Helm charts)
- ✅ Distributed tracing (OpenTelemetry)
- ✅ End-to-end tutorials
- ✅ Best practices and patterns
- ✅ Troubleshooting guides

**Ready to monitor your infrastructure!** 📊

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete and organized  
**Coverage:** Full observability stack

