# Azure Monitoring Dashboards

## Overview

Azure dashboards provide a customizable view of your monitoring data, combining metrics, logs, and other visualizations in a single pane of glass.

## Dashboard Types

### Azure Portal Dashboards
- Shareable across users
- Support for multiple tile types
- JSON-based configuration
- RBAC integration

### Azure Workbooks
- Interactive reports
- Parameter-driven queries
- Rich visualizations
- Template-based

### Grafana
- Third-party integration
- Advanced visualizations
- Multi-source dashboards
- Community templates

## Create Portal Dashboard

### Via Azure Portal

1. Navigate to Azure Portal
2. Click "Dashboard" in left menu
3. Click "+ New dashboard"
4. Choose "Blank dashboard"
5. Add tiles:
   - Metrics chart
   - Logs query
   - Resource health
   - Markdown
   - Custom tiles

### Via Azure CLI

```bash
# Create dashboard
az portal dashboard create \
  --resource-group myResourceGroup \
  --name myDashboard \
  --location eastus \
  --input-path dashboard.json
```

### Dashboard JSON Structure

```json
{
  "properties": {
    "lenses": {
      "0": {
        "order": 0,
        "parts": {
          "0": {
            "position": {
              "x": 0,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "settings": {
                "content": {
                  "metrics": [
                    {
                      "resourceMetadata": {
                        "id": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}"
                      },
                      "name": "Percentage CPU",
                      "aggregationType": 4,
                      "namespace": "Microsoft.Compute/virtualMachines",
                      "metricVisualization": {
                        "displayName": "Percentage CPU"
                      }
                    }
                  ],
                  "title": "VM CPU Usage",
                  "titleKind": 1,
                  "visualization": {
                    "chartType": 2
                  },
                  "timespan": {
                    "relative": {
                      "duration": 3600000
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Dashboard Tiles

### Metrics Chart Tile

```json
{
  "type": "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
  "settings": {
    "content": {
      "metrics": [
        {
          "resourceMetadata": {"id": "{resource-id}"},
          "name": "Percentage CPU",
          "aggregationType": 4
        }
      ],
      "title": "CPU Usage",
      "visualization": {"chartType": 2}
    }
  }
}
```

### Logs Query Tile

```json
{
  "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
  "settings": {
    "content": {
      "Query": "Perf | where CounterName == '% Processor Time' | summarize avg(CounterValue) by bin(TimeGenerated, 5m)",
      "ControlType": "AnalyticsChart",
      "SpecificChart": "Line",
      "Dimensions": {
        "xAxis": {"name": "TimeGenerated", "type": "datetime"},
        "yAxis": [{"name": "avg_CounterValue", "type": "real"}]
      }
    }
  }
}
```

### Markdown Tile

```json
{
  "type": "Extension/HubsExtension/PartType/MarkdownPart",
  "settings": {
    "content": {
      "settings": {
        "content": "# Production Environment\n\nMonitoring dashboard for production resources.",
        "title": "Overview",
        "subtitle": ""
      }
    }
  }
}
```

## Azure Workbooks

### Create Workbook

1. Navigate to Azure Monitor
2. Select "Workbooks" under Insights
3. Click "+ New"
4. Add components:
   - Text
   - Parameters
   - Queries
   - Metrics
   - Links

### Workbook Components

**Text Component:**
```markdown
# Application Performance Dashboard

Monitor key metrics for production applications.

## Current Status
- Availability: 99.9%
- Response Time: < 200ms
- Error Rate: < 0.1%
```

**Query Component:**
```kql
requests
| where timestamp > ago(24h)
| summarize 
    RequestCount = count(),
    AvgDuration = avg(duration),
    FailureRate = countif(success == false) * 100.0 / count()
    by bin(timestamp, 1h)
| render timechart
```

**Parameters:**
```json
{
  "name": "TimeRange",
  "type": "timeRange",
  "label": "Time Range",
  "value": {
    "durationMs": 3600000
  }
}
```

### Workbook Template Example

```json
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 1,
      "content": {
        "json": "# Application Monitoring Dashboard"
      }
    },
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "parameters": [
          {
            "id": "time-range",
            "version": "KqlParameterItem/1.0",
            "name": "TimeRange",
            "type": 4,
            "value": {
              "durationMs": 3600000
            }
          }
        ]
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "requests | where timestamp {TimeRange} | summarize count() by bin(timestamp, 5m)",
        "size": 0,
        "title": "Request Rate",
        "queryType": 0,
        "resourceType": "microsoft.insights/components"
      }
    }
  ]
}
```

### Save and Share Workbook

```bash
# Export workbook template
az monitor workbook show \
  --resource-group myResourceGroup \
  --name myWorkbook \
  --query properties.serializedData -o json > workbook.json

# Create workbook from template
az monitor workbook create \
  --resource-group myResourceGroup \
  --name myWorkbook \
  --location eastus \
  --display-name "My Workbook" \
  --serialized-data @workbook.json
```

## Grafana Integration

### Azure Managed Grafana

```bash
# Create Managed Grafana instance
az grafana create \
  --name myGrafana \
  --resource-group myResourceGroup \
  --location eastus
```

### Configure Azure Monitor Data Source

1. Open Grafana
2. Go to Configuration > Data Sources
3. Add "Azure Monitor" data source
4. Configure authentication:
   - Managed Identity (recommended)
   - Service Principal
   - App Registration

### Grafana Dashboard JSON

```json
{
  "dashboard": {
    "title": "Azure VM Monitoring",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "graph",
        "datasource": "Azure Monitor",
        "targets": [
          {
            "azureMonitor": {
              "resourceGroup": "myResourceGroup",
              "resourceName": "myVM",
              "metricNamespace": "Microsoft.Compute/virtualMachines",
              "metricName": "Percentage CPU",
              "aggregation": "Average"
            }
          }
        ]
      }
    ]
  }
}
```

### Import Grafana Dashboard

```bash
# Using Grafana API
curl -X POST \
  -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @dashboard.json \
  "https://myGrafana.grafana.azure.com/api/dashboards/db"
```

## Dashboard Best Practices

### Design Principles

1. **Hierarchy:** Most important metrics at top
2. **Grouping:** Related metrics together
3. **Consistency:** Same colors for same metrics
4. **Context:** Include time ranges and filters
5. **Actionable:** Link to detailed views

### Layout Guidelines

```
┌─────────────────────────────────────────────────┐
│  Title and Overview (Markdown)                  │
├─────────────────────────────────────────────────┤
│  Key Metrics (Single Value Tiles)              │
│  [Availability] [Response Time] [Error Rate]   │
├─────────────────────────────────────────────────┤
│  Trends (Time Charts)                           │
│  [Request Rate Chart]                           │
│  [Response Time Chart]                          │
├─────────────────────────────────────────────────┤
│  Details (Tables and Lists)                     │
│  [Top Errors] [Slow Requests]                   │
└─────────────────────────────────────────────────┘
```

### Performance Optimization

- Limit number of tiles (< 20)
- Use appropriate time ranges
- Avoid complex queries
- Cache query results
- Use parameters for filtering

## Common Dashboard Examples

### Application Dashboard

```kql
// Availability
requests
| where timestamp > ago(1h)
| summarize Availability = (count() - countif(success == false)) * 100.0 / count()

// Response Time
requests
| where timestamp > ago(1h)
| summarize 
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95)

// Error Rate
requests
| where timestamp > ago(1h)
| summarize ErrorRate = countif(success == false) * 100.0 / count()

// Request Trend
requests
| where timestamp > ago(24h)
| summarize count() by bin(timestamp, 1h)
| render timechart
```

### Infrastructure Dashboard

```kql
// VM Health
Heartbeat
| where TimeGenerated > ago(5m)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| extend Status = iff(LastHeartbeat > ago(5m), "Healthy", "Unhealthy")

// CPU Usage
Perf
| where CounterName == "% Processor Time"
| where TimeGenerated > ago(1h)
| summarize AvgCPU = avg(CounterValue) by Computer

// Memory Usage
Perf
| where CounterName == "Available MBytes"
| where TimeGenerated > ago(1h)
| summarize AvgMemory = avg(CounterValue) by Computer

// Disk Space
Perf
| where CounterName == "% Free Space"
| where TimeGenerated > ago(1h)
| summarize FreeSpace = avg(CounterValue) by Computer, InstanceName
```

### Kubernetes Dashboard

```kql
// Cluster Health
KubeNodeInventory
| where TimeGenerated > ago(5m)
| summarize NodeCount = dcount(Computer) by Status

// Pod Status
KubePodInventory
| where TimeGenerated > ago(5m)
| summarize PodCount = count() by PodStatus, Namespace

// Container Restarts
KubePodInventory
| where TimeGenerated > ago(24h)
| where RestartCount > 0
| summarize TotalRestarts = sum(RestartCount) by Namespace, Name
| top 10 by TotalRestarts desc

// Resource Usage
Perf
| where ObjectName == "K8SContainer"
| where CounterName in ("cpuUsageNanoCores", "memoryRssBytes")
| summarize avg(CounterValue) by CounterName, bin(TimeGenerated, 5m)
| render timechart
```

## Share and Manage Dashboards

### Share Dashboard

```bash
# Grant access to dashboard
az role assignment create \
  --assignee user@example.com \
  --role "Dashboard Contributor" \
  --scope /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Portal/dashboards/{dashboard-name}
```

### Export Dashboard

```bash
# Export dashboard JSON
az portal dashboard show \
  --resource-group myResourceGroup \
  --name myDashboard \
  --query properties -o json > dashboard.json
```

### Import Dashboard

```bash
# Import dashboard
az portal dashboard create \
  --resource-group myResourceGroup \
  --name myDashboard \
  --location eastus \
  --input-path dashboard.json
```

## Resources

- [Azure Dashboards Documentation](https://docs.microsoft.com/azure/azure-portal/azure-portal-dashboards)
- [Azure Workbooks](https://docs.microsoft.com/azure/azure-monitor/visualize/workbooks-overview)
- [Grafana Integration](https://docs.microsoft.com/azure/managed-grafana/)
- [Dashboard Best Practices](https://docs.microsoft.com/azure/azure-portal/azure-portal-dashboards-best-practices)
