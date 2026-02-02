# Azure Monitoring

## Learning Checklist

- [ ] Centralize logs with Log Analytics
- [ ] Write KQL queries
- [ ] Create dashboards
- [ ] Configure alerts
- [ ] Create availability tests

## Overview

Azure Monitoring is a comprehensive suite of services that provides full-stack monitoring, analytics, and intelligent insights for applications and infrastructure running on Azure, on-premises, or in other clouds.

## Documentation Structure

This guide is organized into the following sections:

1. **[Overview](01-Overview.md)** - Introduction to Azure Monitoring concepts and architecture
2. **[Log Analytics](02-Log-Analytics.md)** - Centralized log management and workspace configuration
3. **[KQL Queries](03-KQL-Queries.md)** - Kusto Query Language reference and examples
4. **[Dashboards](04-Dashboards.md)** - Creating visualizations and workbooks
5. **[Alerts](05-Alerts.md)** - Configuring proactive notifications
6. **[Availability Tests](06-Availability-Tests.md)** - Monitoring application availability

## Quick Start

### 1. Create Log Analytics Workspace
```bash
az monitor log-analytics workspace create \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --location eastus
```

### 2. Enable Diagnostic Settings
```bash
az monitor diagnostic-settings create \
  --name myDiagSettings \
  --resource {resource-id} \
  --logs '[{"category": "AllLogs", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]' \
  --workspace {workspace-id}
```

### 3. Query Logs
```kql
AzureActivity
| where TimeGenerated > ago(24h)
| summarize count() by OperationName
| order by count_ desc
```

### 4. Create Alert
```bash
az monitor metrics alert create \
  --name myAlert \
  --resource-group myResourceGroup \
  --scopes {resource-id} \
  --condition "avg Percentage CPU > 80" \
  --description "High CPU alert"
```

## Key Concepts

### Azure Monitor
Unified monitoring platform for metrics and logs.

### Log Analytics
Centralized log repository with KQL query capabilities. [Learn more →](02-Log-Analytics.md)

### Application Insights
Application Performance Management (APM) for web applications.

### Metrics
Real-time numerical data collected from resources.

### Alerts
Proactive notifications based on conditions. [Learn more →](05-Alerts.md)

### Dashboards
Visual representations of monitoring data. [Learn more →](04-Dashboards.md)

### Availability Tests
Global endpoint monitoring. [Learn more →](06-Availability-Tests.md)

## Common Monitoring Scenarios

### Application Monitoring
- Request rates and response times
- Error rates and exceptions
- Dependency performance
- User analytics

See [KQL Queries](03-KQL-Queries.md) for query examples.

### Infrastructure Monitoring
- CPU, memory, disk usage
- Network performance
- VM health and availability
- Resource utilization trends

### Kubernetes Monitoring
- Pod and node health
- Container resource usage
- Cluster events
- Application logs

### Security Monitoring
- Failed login attempts
- Firewall blocks
- Suspicious activities
- Compliance auditing

## Resources

- [Azure Monitor Documentation](https://docs.microsoft.com/azure/azure-monitor/)
- [KQL Reference](https://docs.microsoft.com/azure/data-explorer/kusto/query/)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)
