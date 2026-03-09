# 1️⃣1️⃣ Monitoring & Logging - Overview

Learn observability on Google Cloud Platform.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Observability Pillars](#observability-pillars)
3. [Services Comparison](#services-comparison)
4. [Decision Framework](#decision-framework)
5. [Architecture Patterns](#architecture-patterns)
6. [Cost Considerations](#cost-considerations)
7. [Quick Reference](#quick-reference)

---

## Introduction

GCP provides comprehensive observability tools to monitor, log, trace, and debug your applications and infrastructure.

### Observability Stack

```
┌─────────────────────────────────────────────────────┐
│              Google Cloud Operations                │
│              (formerly Stackdriver)                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Cloud   │  │  Cloud   │  │  Cloud   │        │
│  │Monitoring│  │ Logging  │  │  Trace   │        │
│  └──────────┘  └──────────┘  └──────────┘        │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Error   │  │ Cloud    │  │ Cloud    │        │
│  │Reporting │  │ Profiler │  │ Debugger │        │
│  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────┘
```

---

## Observability Pillars

### 1. Metrics (Cloud Monitoring)

**What:** Time-series data about system and application performance

```
┌─────────────────────────────────────┐
│      Cloud Monitoring               │
├─────────────────────────────────────┤
│  Metrics Collection:                │
│  • CPU utilization                  │
│  • Memory usage                     │
│  • Request latency                  │
│  • Error rates                      │
│  • Custom metrics                   │
├─────────────────────────────────────┤
│  Features:                          │
│  • Dashboards                       │
│  • Alerting policies                │
│  • Uptime checks                    │
│  • SLO monitoring                   │
└─────────────────────────────────────┘
```

**Use Cases:**
- Performance monitoring
- Capacity planning
- SLA/SLO tracking
- Alerting and notifications
- Trend analysis

### 2. Logs (Cloud Logging)

**What:** Structured and unstructured log data from applications and infrastructure

```
┌─────────────────────────────────────┐
│        Cloud Logging                │
├─────────────────────────────────────┤
│  Log Types:                         │
│  • Application logs                 │
│  • Audit logs                       │
│  • System logs                      │
│  • Access logs                      │
│  • Security logs                    │
├─────────────────────────────────────┤
│  Features:                          │
│  • Log Explorer                     │
│  • Log-based metrics                │
│  • Log sinks                        │
│  • Log retention                    │
└─────────────────────────────────────┘
```

**Use Cases:**
- Debugging
- Audit trails
- Security analysis
- Compliance
- Troubleshooting

### 3. Traces (Cloud Trace)

**What:** Distributed tracing for request flows across services

```
┌─────────────────────────────────────┐
│         Cloud Trace                 │
├─────────────────────────────────────┤
│  Request Flow:                      │
│  API Gateway → Service A            │
│      ↓                              │
│  Service A → Service B              │
│      ↓                              │
│  Service B → Database               │
├─────────────────────────────────────┤
│  Features:                          │
│  • Latency analysis                 │
│  • Performance insights             │
│  • Bottleneck detection             │
│  • Request visualization            │
└─────────────────────────────────────┘
```

**Use Cases:**
- Performance optimization
- Latency analysis
- Microservices debugging
- Request flow visualization
- Bottleneck identification

### 4. Errors (Error Reporting)

**What:** Real-time error tracking and alerting

```
┌─────────────────────────────────────┐
│       Error Reporting               │
├─────────────────────────────────────┤
│  Error Tracking:                    │
│  • Exception monitoring             │
│  • Error grouping                   │
│  • Stack traces                     │
│  • Error trends                     │
│  • Notifications                    │
├─────────────────────────────────────┤
│  Features:                          │
│  • Automatic detection              │
│  • Error grouping                   │
│  • Alerting                         │
│  • Integration with logs            │
└─────────────────────────────────────┘
```

**Use Cases:**
- Error tracking
- Exception monitoring
- Quality assurance
- Incident response
- Bug tracking

---

## Services Comparison

### Feature Matrix

| Service | Purpose | Data Type | Retention | Cost Model |
|---------|---------|-----------|-----------|------------|
| **Cloud Monitoring** | Metrics & alerts | Time-series | 6 weeks (default) | Per metric |
| **Cloud Logging** | Log management | Structured/text | 30 days (default) | Per GB ingested |
| **Cloud Trace** | Distributed tracing | Trace spans | 30 days | Per span |
| **Error Reporting** | Error tracking | Exceptions | 30 days | Free |
| **Cloud Profiler** | Performance profiling | CPU/Memory | 30 days | Free |
| **Cloud Debugger** | Live debugging | Snapshots | Real-time | Free |

---

## Decision Framework

### When to Use Each Service

**Cloud Monitoring:**
- Need to track system metrics
- Set up alerts for anomalies
- Monitor SLAs/SLOs
- Create dashboards
- Track custom business metrics

**Cloud Logging:**
- Debug application issues
- Audit user actions
- Compliance requirements
- Security analysis
- Long-term log retention

**Cloud Trace:**
- Microservices architecture
- Performance optimization
- Latency issues
- Request flow analysis
- Distributed systems

**Error Reporting:**
- Track application errors
- Monitor exception rates
- Quick error triage
- Production monitoring
- Quality metrics

---

## Architecture Patterns

### Pattern 1: Full Observability Stack

```
┌─────────────────────────────────────┐
│         Application                 │
└──────────────┬──────────────────────┘
               |
    ┌──────────┼──────────┐
    v          v          v
┌────────┐ ┌────────┐ ┌────────┐
│Metrics │ │ Logs   │ │Traces  │
└───┬────┘ └───┬────┘ └───┬────┘
    v          v          v
┌────────────────────────────────┐
│   Cloud Operations Suite       │
├────────────────────────────────┤
│  • Monitoring                  │
│  • Logging                     │
│  • Trace                       │
│  • Error Reporting             │
└────────────────────────────────┘
         |
         v
┌────────────────────────────────┐
│   Alerting & Dashboards        │
└────────────────────────────────┘
```

### Pattern 2: Log Aggregation

```
Multiple Sources
    |
    ├─> GKE Pods
    ├─> Cloud Run
    ├─> Compute Engine
    ├─> Cloud Functions
    |
    v
┌─────────────────────┐
│   Cloud Logging     │
└──────────┬──────────┘
           |
    ┌──────┼──────┐
    v      v      v
┌──────┐┌──────┐┌──────┐
│BigQ. ││Cloud ││Pub/  │
│      ││Store ││Sub   │
└──────┘└──────┘└──────┘
```

### Pattern 3: SLO Monitoring

```
┌─────────────────────────────────────┐
│      Service Level Objectives       │
├─────────────────────────────────────┤
│  Availability: 99.9%                │
│  Latency: p95 < 200ms               │
│  Error Rate: < 0.1%                 │
└──────────────┬──────────────────────┘
               v
┌─────────────────────────────────────┐
│      Cloud Monitoring               │
│  • SLI tracking                     │
│  • Error budget                     │
│  • Burn rate alerts                 │
└──────────────┬──────────────────────┘
               v
┌─────────────────────────────────────┐
│      Alerting & Dashboards          │
└─────────────────────────────────────┘
```

---

## Cost Considerations

### Pricing Overview

**Cloud Monitoring:**
- First 150 MB/month: Free
- Additional data: $0.2580 per MB
- API calls: $0.01 per 1,000 calls

**Cloud Logging:**
- First 50 GB/month: Free
- Additional data: $0.50 per GB
- Storage: $0.01 per GB/month

**Cloud Trace:**
- First 2.5 million spans/month: Free
- Additional: $0.20 per million spans

**Error Reporting:**
- Free (no charge)

### Cost Optimization

```bash
# Set log retention policies
gcloud logging sinks create my-sink \
  storage.googleapis.com/my-bucket \
  --log-filter='resource.type="gce_instance"'

# Exclude verbose logs
gcloud logging exclusions create exclude-debug \
  --log-filter='severity<WARNING'

# Sample high-volume logs
gcloud logging sinks create sampled-logs \
  bigquery.googleapis.com/projects/my-project/datasets/logs \
  --log-filter='sample(insertId, 0.1)'
```

---

## Quick Reference

### Cloud Monitoring

```bash
# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Alert" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8

# Create dashboard
gcloud monitoring dashboards create --config-from-file=dashboard.json
```

### Cloud Logging

```bash
# View logs
gcloud logging read "resource.type=gce_instance" --limit 10

# Create log sink
gcloud logging sinks create my-sink \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/DATASET_ID

# Create log-based metric
gcloud logging metrics create error_count \
  --description="Count of error logs" \
  --log-filter='severity>=ERROR'
```

### Cloud Trace

```bash
# List traces
gcloud trace list-traces --limit=10

# Get trace details
gcloud trace get TRACE_ID
```

---

## Best Practices

### Monitoring

✅ Define clear SLIs and SLOs  
✅ Set up meaningful alerts  
✅ Avoid alert fatigue  
✅ Use dashboards effectively  
✅ Monitor golden signals (latency, traffic, errors, saturation)  
✅ Implement custom metrics for business KPIs  
✅ Regular review of monitoring setup  

### Logging

✅ Use structured logging  
✅ Include correlation IDs  
✅ Set appropriate log levels  
✅ Implement log sampling for high-volume logs  
✅ Use log sinks for long-term retention  
✅ Exclude sensitive data from logs  
✅ Regular log analysis  

### Tracing

✅ Implement distributed tracing  
✅ Use consistent trace context  
✅ Sample traces appropriately  
✅ Monitor critical paths  
✅ Analyze latency patterns  

### Security

✅ Enable audit logging  
✅ Monitor security events  
✅ Set up security alerts  
✅ Regular security reviews  
✅ Implement least privilege for log access  

---

## Next Steps

1. **[Cloud Monitoring](1-Cloud-Monitoring.md)** - Metrics and alerting
2. **[Cloud Logging](2-Cloud-Logging.md)** - Log management
3. **[Cloud Trace](3-Cloud-Trace.md)** - Distributed tracing
4. **[Error Reporting](4-Error-Reporting.md)** - Error tracking
5. **[Cloud Profiler](5-Cloud-Profiler.md)** - Performance profiling
6. **[Best Practices](6-Best-Practices.md)** - Production guidelines

---

## Additional Resources

- [Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Cloud Trace Documentation](https://cloud.google.com/trace/docs)
- [Error Reporting Documentation](https://cloud.google.com/error-reporting/docs)
- [SRE Book](https://sre.google/books/)

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
