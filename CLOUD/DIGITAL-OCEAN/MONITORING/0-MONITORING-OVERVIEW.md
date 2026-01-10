# DigitalOcean Monitoring Overview

## Introduction

Built-in monitoring provides metrics, alerts, and insights for all DigitalOcean resources.

## Key Features

- Resource metrics (CPU, memory, disk, bandwidth)
- Custom alerts
- Uptime monitoring
- Performance insights
- Free for all resources

## Available Metrics

### Droplet Metrics
```
- CPU usage (%)
- Memory usage (%)
- Disk usage (%)
- Disk I/O
- Bandwidth (inbound/outbound)
- Network traffic
```

### Database Metrics
```
- CPU usage
- Memory usage
- Disk usage
- Connection count
- Query performance
- Replication lag
```

### Kubernetes Metrics
```
- Node CPU/memory
- Pod CPU/memory
- Cluster health
- Resource utilization
```

## Setting Up Alerts

```bash
# Enable monitoring
doctl compute droplet-action enable-monitoring <droplet-id>

# Create alert policy (via control panel)
# Droplets → Monitoring → Create Alert Policy

Alert Types:
├─> CPU > 80%
├─> Memory > 90%
├─> Disk > 90%
└─> Bandwidth > threshold
```

## Viewing Metrics

```
Control Panel:
├─> Droplets → Select Droplet → Graphs
├─> Databases → Select DB → Insights
└─> Kubernetes → Select Cluster → Insights

Time Ranges:
├─> Last hour
├─> Last 6 hours
├─> Last 24 hours
└─> Last 7 days
```

## Integration

```
Export to:
├─> Datadog
├─> New Relic
├─> Prometheus
└─> Custom endpoints
```
