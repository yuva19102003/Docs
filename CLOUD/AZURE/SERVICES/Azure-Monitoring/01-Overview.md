# Azure Monitoring - Overview

## Learning Checklist

- [ ] Centralize logs with Log Analytics
- [ ] Write KQL queries
- [ ] Create dashboards
- [ ] Configure alerts
- [ ] Create availability tests

## What is Azure Monitoring?

Azure Monitoring is a comprehensive suite of services that provides full-stack monitoring, analytics, and intelligent insights for applications and infrastructure running on Azure, on-premises, or in other clouds.

## Core Components

### Azure Monitor
The unified monitoring solution that collects, analyzes, and acts on telemetry data from Azure and on-premises environments.

**Key Features:**
- Metrics and logs collection
- Application performance monitoring
- Infrastructure monitoring
- Network monitoring
- Container monitoring

### Application Insights
Application Performance Management (APM) service for web developers.

### Log Analytics
Centralized log management and analysis service using Kusto Query Language (KQL).

### Metrics
Real-time numerical data about your resources.

### Alerts
Proactive notifications based on metrics, logs, or activity logs.

### Availability Tests
Monitor application availability and responsiveness from multiple geographic locations.

## Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Resources                          │
│  (VMs, AKS, App Services, Databases, Networks, etc.)        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   Azure Monitor                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Metrics    │  │     Logs     │  │  Activity    │     │
│  │   Platform   │  │  Diagnostic  │  │     Logs     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                Data Processing & Storage                     │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │  Log Analytics   │         │  Metrics Store   │         │
│  │   Workspace      │         │                  │         │
│  └──────────────────┘         └──────────────────┘         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Analysis & Visualization                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   KQL    │  │Workbooks │  │Dashboards│  │  Alerts  │  │
│  │ Queries  │  │          │  │          │  │          │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Key Concepts

### Data Types

**Metrics:**
- Numerical time-series data
- Collected at regular intervals
- Lightweight and near real-time
- Stored for 93 days by default

**Logs:**
- Text-based records of events
- Stored in Log Analytics workspace
- Queryable using KQL
- Configurable retention (30 days to 2 years)

**Activity Logs:**
- Subscription-level events
- Resource creation, modification, deletion
- Administrative operations
- Service health events

### Data Sources

- Azure resources (platform metrics and logs)
- Guest OS (VM agents)
- Applications (Application Insights)
- Custom sources (APIs, agents)
- Network (Network Watcher)
- Security (Azure Sentinel)

## Getting Started

### 1. Enable Diagnostic Settings
Configure resources to send logs and metrics to destinations.

### 2. Create Log Analytics Workspace
Central repository for log data.

### 3. Install Monitoring Agents
For VMs and on-premises resources.

### 4. Configure Application Insights
For application performance monitoring.

### 5. Set Up Alerts
Proactive notifications for issues.

### 6. Create Dashboards
Visualize monitoring data.

## Common Use Cases

- **Performance Monitoring:** Track application and infrastructure performance
- **Troubleshooting:** Diagnose issues using logs and metrics
- **Capacity Planning:** Analyze resource utilization trends
- **Security Monitoring:** Detect and respond to security threats
- **Compliance:** Meet regulatory requirements for logging
- **Cost Optimization:** Identify underutilized resources

## Resources

- [Azure Monitor Documentation](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Monitoring Best Practices](https://docs.microsoft.com/azure/azure-monitor/best-practices)
