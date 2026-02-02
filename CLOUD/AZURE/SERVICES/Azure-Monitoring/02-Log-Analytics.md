# Log Analytics

## Overview

Log Analytics is Azure's centralized log management and analysis service. It provides a powerful query language (KQL) to analyze log data from multiple sources.

## Key Features

- **Kusto Query Language (KQL)** for log analysis
- **Custom log collection** from any source
- **Cross-resource queries** across multiple workspaces
- **Alerting** based on log data
- **Integration** with Azure Sentinel and other services
- **Data retention** from 30 days to 2 years
- **Data export** to Storage or Event Hub

## Create Log Analytics Workspace

### Azure Portal
1. Navigate to "Log Analytics workspaces"
2. Click "Create"
3. Configure:
   - Subscription
   - Resource group
   - Name
   - Region
   - Pricing tier

### Azure CLI
```bash
az monitor log-analytics workspace create \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --location eastus \
  --sku PerGB2018
```

### Azure PowerShell
```powershell
New-AzOperationalInsightsWorkspace `
  -ResourceGroupName "myResourceGroup" `
  -Name "myWorkspace" `
  -Location "eastus" `
  -Sku "PerGB2018"
```

## Connect Data Sources

### Azure Resources
Enable diagnostic settings to send logs to workspace:

```bash
az monitor diagnostic-settings create \
  --name myDiagSettings \
  --resource /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm-name} \
  --logs '[{"category": "Administrative", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]' \
  --workspace /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}
```

### Virtual Machines
Install Log Analytics agent:

```bash
# Linux VM
az vm extension set \
  --resource-group myResourceGroup \
  --vm-name myVM \
  --name OmsAgentForLinux \
  --publisher Microsoft.EnforcementOpsInsights \
  --settings '{"workspaceId":"<workspace-id>"}' \
  --protected-settings '{"workspaceKey":"<workspace-key>"}'

# Windows VM
az vm extension set \
  --resource-group myResourceGroup \
  --vm-name myVM \
  --name MicrosoftMonitoringAgent \
  --publisher Microsoft.EnforcementOpsInsights \
  --settings '{"workspaceId":"<workspace-id>"}' \
  --protected-settings '{"workspaceKey":"<workspace-key>"}'
```

### Custom Logs
Use HTTP Data Collector API:

```python
import requests
import json
import datetime
import hashlib
import hmac
import base64

def post_data(customer_id, shared_key, body, log_type):
    method = 'POST'
    content_type = 'application/json'
    resource = '/api/logs'
    rfc1123date = datetime.datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
    content_length = len(body)
    
    signature = build_signature(customer_id, shared_key, rfc1123date, content_length, method, content_type, resource)
    uri = 'https://' + customer_id + '.ods.opinsights.azure.com' + resource + '?api-version=2016-04-01'
    
    headers = {
        'content-type': content_type,
        'Authorization': signature,
        'Log-Type': log_type,
        'x-ms-date': rfc1123date
    }
    
    response = requests.post(uri, data=body, headers=headers)
    return response.status_code

def build_signature(customer_id, shared_key, date, content_length, method, content_type, resource):
    x_headers = 'x-ms-date:' + date
    string_to_hash = method + "\n" + str(content_length) + "\n" + content_type + "\n" + x_headers + "\n" + resource
    bytes_to_hash = bytes(string_to_hash, encoding="utf-8")  
    decoded_key = base64.b64decode(shared_key)
    encoded_hash = base64.b64encode(hmac.new(decoded_key, bytes_to_hash, digestmod=hashlib.sha256).digest()).decode()
    authorization = "SharedKey {}:{}".format(customer_id, encoded_hash)
    return authorization

# Usage
log_data = [{
    "timestamp": "2026-02-02T10:00:00Z",
    "level": "INFO",
    "message": "Application started"
}]

post_data('<workspace-id>', '<workspace-key>', json.dumps(log_data), 'CustomAppLog')
```

## Log Analytics Tables

Common tables in Log Analytics:

| Table | Description |
|-------|-------------|
| `AzureActivity` | Azure subscription-level events |
| `AzureDiagnostics` | Diagnostic logs from Azure resources |
| `Perf` | Performance counters from VMs |
| `Syslog` | Linux system logs |
| `Event` | Windows event logs |
| `Heartbeat` | Agent health status |
| `SecurityEvent` | Windows security events |
| `ContainerLog` | Container logs |
| `KubePodInventory` | Kubernetes pod information |
| `requests` | Application Insights requests |
| `exceptions` | Application Insights exceptions |
| `availabilityResults` | Availability test results |

## Query Logs

### Azure Portal
1. Navigate to Log Analytics workspace
2. Click "Logs" under General
3. Write KQL query
4. Click "Run"

### Azure CLI
```bash
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureActivity | take 10"
```

### REST API
```bash
curl -X POST \
  -H "Authorization: Bearer <access-token>" \
  -H "Content-Type: application/json" \
  -d '{"query": "AzureActivity | take 10"}' \
  "https://api.loganalytics.io/v1/workspaces/<workspace-id>/query"
```

## Data Retention

### Configure Retention
```bash
az monitor log-analytics workspace update \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --retention-time 90
```

### Table-Level Retention
```bash
az monitor log-analytics workspace table update \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --name AzureActivity \
  --retention-time 180
```

## Data Export

### Export to Storage Account
```bash
az monitor log-analytics workspace data-export create \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --name myExport \
  --destination /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage} \
  --tables AzureActivity Syslog
```

### Export to Event Hub
```bash
az monitor log-analytics workspace data-export create \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --name myExport \
  --destination /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.EventHub/namespaces/{namespace} \
  --tables AzureActivity Syslog
```

## Workspace Management

### Get Workspace ID and Key
```bash
# Get workspace ID
az monitor log-analytics workspace show \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --query customerId -o tsv

# Get workspace key
az monitor log-analytics workspace get-shared-keys \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --query primarySharedKey -o tsv
```

### Link to Automation Account
```bash
az monitor log-analytics workspace linked-service create \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --name automation \
  --resource-id /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{account}
```

## Cost Optimization

### Pricing Tiers
- **Pay-As-You-Go:** $2.30 per GB ingested
- **Commitment Tiers:** 100 GB/day to 5000 GB/day with discounts
- **Free Tier:** 5 GB/month (limited features)

### Reduce Costs
- Filter data at source (diagnostic settings)
- Use sampling for Application Insights
- Set appropriate retention periods
- Archive old data to storage
- Use table-level retention
- Monitor data ingestion volume

### Monitor Ingestion
```kql
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize IngestedGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1d), DataType
| render timechart
```

## Best Practices

1. **Workspace Design:**
   - One workspace per environment (dev, staging, prod)
   - Consider compliance and data residency requirements
   - Use resource-centric approach for multi-tenant scenarios

2. **Access Control:**
   - Use Azure RBAC for workspace access
   - Implement table-level RBAC for sensitive data
   - Use resource-context access for developers

3. **Data Collection:**
   - Collect only necessary data
   - Use diagnostic settings filters
   - Implement sampling for high-volume sources

4. **Query Performance:**
   - Use time filters early in queries
   - Leverage indexed columns
   - Avoid wildcards in searches
   - Use materialized views for frequent queries

5. **Security:**
   - Enable customer-managed keys for encryption
   - Use Private Link for secure access
   - Audit workspace access regularly
   - Implement data purge for sensitive information

## Troubleshooting

### Agent Not Reporting
```kql
Heartbeat
| where Computer == "myVM"
| summarize LastHeartbeat = max(TimeGenerated) by Computer
```

### High Data Ingestion
```kql
Usage
| where TimeGenerated > ago(7d)
| where IsBillable == true
| summarize IngestedGB = sum(Quantity) / 1000 by Solution, DataType
| order by IngestedGB desc
```

### Query Performance Issues
- Add time range filters
- Use `where` before `summarize`
- Avoid `search *` queries
- Use specific table names

## Resources

- [Log Analytics Documentation](https://docs.microsoft.com/azure/azure-monitor/logs/log-analytics-overview)
- [Log Analytics Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Data Collection Best Practices](https://docs.microsoft.com/azure/azure-monitor/logs/data-collection-best-practices)
