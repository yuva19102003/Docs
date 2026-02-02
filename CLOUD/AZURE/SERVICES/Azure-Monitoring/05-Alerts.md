# Azure Monitor Alerts

## Overview

Azure Monitor Alerts proactively notify you when important conditions are found in your monitoring data. They allow you to identify and address issues before users notice them.

## Alert Types

### 1. Metric Alerts
Monitor numeric values from Azure resources.

**Features:**
- Near real-time evaluation (1-5 minutes)
- Multiple conditions and dimensions
- Dynamic thresholds
- Stateful and stateless

### 2. Log Search Alerts
Query-based alerts using KQL.

**Features:**
- Complex logic using KQL
- Cross-resource queries
- Custom time windows
- Aggregation-based conditions

### 3. Activity Log Alerts
Monitor subscription-level events.

**Features:**
- Resource creation/deletion
- Configuration changes
- Service health events
- Administrative operations

### 4. Smart Detection Alerts
AI-powered anomaly detection (Application Insights).

**Features:**
- Automatic baseline learning
- Failure anomalies
- Performance degradation
- Memory leak detection

## Create Metric Alert

### Azure Portal
1. Navigate to Azure Monitor
2. Select "Alerts" > "Create" > "Alert rule"
3. Select resource scope
4. Add condition (metric)
5. Configure action group
6. Set alert details

### Azure CLI
```bash
az monitor metrics alert create \
  --name myMetricAlert \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm} \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when CPU exceeds 80%" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 2 \
  --action /subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/actionGroups/{action-group}
```

### ARM Template
```json
{
  "type": "Microsoft.Insights/metricAlerts",
  "apiVersion": "2018-03-01",
  "name": "myMetricAlert",
  "location": "global",
  "properties": {
    "description": "Alert when CPU exceeds 80%",
    "severity": 2,
    "enabled": true,
    "scopes": [
      "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}"
    ],
    "evaluationFrequency": "PT5M",
    "windowSize": "PT15M",
    "criteria": {
      "allOf": [
        {
          "name": "HighCPU",
          "metricName": "Percentage CPU",
          "metricNamespace": "Microsoft.Compute/virtualMachines",
          "operator": "GreaterThan",
          "threshold": 80,
          "timeAggregation": "Average"
        }
      ],
      "odata.type": "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria"
    },
    "actions": [
      {
        "actionGroupId": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/actionGroups/{action-group}"
      }
    ]
  }
}
```

## Create Log Search Alert

### Azure CLI
```bash
az monitor scheduled-query create \
  --name myLogAlert \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace} \
  --condition "count 'Heartbeat | where TimeGenerated > ago(5m) | summarize AggregatedValue = count() by Computer | where AggregatedValue < 1' > 0" \
  --description "Alert when VM heartbeat is missing" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 1 \
  --action-groups /subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/actionGroups/{action-group}
```

### Query Examples

**Failed Requests Alert:**
```kql
requests
| where timestamp > ago(5m)
| where success == false
| summarize FailedRequests = count()
| where FailedRequests > 10
```

**High Error Rate Alert:**
```kql
requests
| where timestamp > ago(15m)
| summarize 
    TotalRequests = count(),
    FailedRequests = countif(success == false)
| extend ErrorRate = (FailedRequests * 100.0) / TotalRequests
| where ErrorRate > 5
```

**Missing Heartbeat Alert:**
```kql
Heartbeat
| where TimeGenerated > ago(10m)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(5m)
```

**Disk Space Alert:**
```kql
Perf
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where TimeGenerated > ago(5m)
| where InstanceName != "_Total"
| summarize FreeSpace = avg(CounterValue) by Computer, InstanceName
| where FreeSpace < 10
```

## Dynamic Thresholds

Automatically learn metric patterns and adjust thresholds.

```bash
az monitor metrics alert create \
  --name myDynamicAlert \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm} \
  --condition "avg Percentage CPU > dynamic High 2 violations out of 4" \
  --description "Dynamic CPU alert" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 2
```

**Sensitivity Levels:**
- **High:** More alerts, catches smaller deviations
- **Medium:** Balanced sensitivity
- **Low:** Fewer alerts, only major deviations

## Multi-Resource Alerts

Monitor multiple resources with a single alert rule.

```bash
az monitor metrics alert create \
  --name myMultiResourceAlert \
  --resource-group myResourceGroup \
  --scopes \
    /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm1} \
    /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm2} \
  --condition "avg Percentage CPU > 80" \
  --description "Alert for multiple VMs" \
  --evaluation-frequency 5m \
  --window-size 15m
```

## Action Groups

Define what happens when an alert fires.

### Create Action Group

```bash
az monitor action-group create \
  --name myActionGroup \
  --resource-group myResourceGroup \
  --short-name myAG \
  --email-receiver name=admin email=admin@example.com \
  --sms-receiver name=oncall country-code=1 phone-number=5551234567 \
  --webhook-receiver name=webhook service-uri=https://example.com/webhook \
  --azure-function-receiver name=function function-app-resource-id={function-app-id} function-name=AlertHandler http-trigger-url={function-url}
```

### Action Types

**Email/SMS/Push/Voice:**
```bash
--email-receiver name=admin email=admin@example.com
--sms-receiver name=oncall country-code=1 phone-number=5551234567
--voice-receiver name=voice country-code=1 phone-number=5551234567
```

**Webhook:**
```bash
--webhook-receiver name=webhook service-uri=https://example.com/webhook use-common-alert-schema=true
```

**Azure Function:**
```bash
--azure-function-receiver \
  name=function \
  function-app-resource-id=/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{function-app} \
  function-name=AlertHandler \
  http-trigger-url=https://{function-app}.azurewebsites.net/api/AlertHandler
```

**Logic App:**
```bash
--logic-app-receiver \
  name=logicapp \
  resource-id=/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Logic/workflows/{logic-app} \
  callback-url={callback-url}
```

**Automation Runbook:**
```bash
--automation-runbook-receiver \
  name=runbook \
  automation-account-id=/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{account} \
  runbook-name=RestartVM \
  webhook-resource-id={webhook-id} \
  is-global-runbook=false
```

**ITSM:**
```bash
--itsm-receiver \
  name=itsm \
  workspace-id={workspace-id} \
  connection-id={connection-id} \
  ticket-configuration='{"PayloadRevision":0,"WorkItemType":"Incident","UseTemplate":false}'
```

## Alert Severity Levels

| Severity | Description | Use Case |
|----------|-------------|----------|
| Sev 0 | Critical | Service down, data loss |
| Sev 1 | Error | Major functionality impaired |
| Sev 2 | Warning | Potential issues, degraded performance |
| Sev 3 | Informational | Non-urgent information |
| Sev 4 | Verbose | Detailed diagnostic information |

## Alert Processing Rules

Modify alert behavior without changing alert rules.

### Suppress Alerts During Maintenance

```bash
az monitor alert-processing-rule create \
  --name maintenanceWindow \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg} \
  --rule-type RemoveAllActionGroups \
  --schedule-start-datetime "2026-02-15T22:00:00" \
  --schedule-end-datetime "2026-02-16T02:00:00" \
  --schedule-recurrence-type Weekly \
  --schedule-recurrence-days Saturday
```

### Add Action Group to Specific Alerts

```bash
az monitor alert-processing-rule create \
  --name addActionGroup \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg} \
  --rule-type AddActionGroups \
  --action-groups /subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/actionGroups/{action-group} \
  --filter-severity Equals Sev0 Sev1
```

## Common Alert Scenarios

### Application Alerts

**High Response Time:**
```kql
requests
| where timestamp > ago(5m)
| summarize AvgDuration = avg(duration)
| where AvgDuration > 5000
```

**Exception Rate:**
```kql
exceptions
| where timestamp > ago(5m)
| summarize ExceptionCount = count()
| where ExceptionCount > 10
```

**Dependency Failures:**
```kql
dependencies
| where timestamp > ago(5m)
| where success == false
| summarize FailureCount = count() by target
| where FailureCount > 5
```

### Infrastructure Alerts

**High CPU:**
```bash
--condition "avg Percentage CPU > 80"
```

**Low Memory:**
```kql
Perf
| where ObjectName == "Memory" and CounterName == "Available MBytes"
| where TimeGenerated > ago(5m)
| summarize AvgMemory = avg(CounterValue) by Computer
| where AvgMemory < 500
```

**Disk Space:**
```kql
Perf
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where TimeGenerated > ago(5m)
| summarize FreeSpace = avg(CounterValue) by Computer, InstanceName
| where FreeSpace < 10
```

### Kubernetes Alerts

**Pod Restarts:**
```kql
KubePodInventory
| where TimeGenerated > ago(15m)
| where RestartCount > 0
| summarize TotalRestarts = sum(RestartCount) by Namespace, Name
| where TotalRestarts > 3
```

**Failed Pods:**
```kql
KubePodInventory
| where TimeGenerated > ago(5m)
| where PodStatus in ("Failed", "Pending", "Unknown")
| summarize count() by PodStatus, Namespace
```

**Node Not Ready:**
```kql
KubeNodeInventory
| where TimeGenerated > ago(5m)
| where Status != "Ready"
| summarize count() by Computer, Status
```

### Security Alerts

**Failed Login Attempts:**
```kql
SecurityEvent
| where TimeGenerated > ago(15m)
| where EventID == 4625
| summarize FailedLogins = count() by Account, Computer
| where FailedLogins > 5
```

**Firewall Blocks:**
```kql
AzureDiagnostics
| where TimeGenerated > ago(5m)
| where Category == "AzureFirewallNetworkRule"
| where msg_s contains "Deny"
| summarize BlockCount = count()
| where BlockCount > 100
```

## Alert Best Practices

### 1. Alert Design
- Alert on symptoms, not causes
- Set appropriate thresholds
- Use dynamic thresholds for variable workloads
- Avoid alert fatigue

### 2. Action Groups
- Create role-based action groups
- Use different actions for different severities
- Test action groups regularly
- Document escalation procedures

### 3. Alert Processing
- Use suppression rules for maintenance windows
- Group related alerts
- Set up alert enrichment
- Implement alert correlation

### 4. Monitoring
- Track alert volume and trends
- Monitor alert resolution time
- Review and tune alert rules regularly
- Document alert runbooks

### 5. Cost Optimization
- Use appropriate evaluation frequencies
- Consolidate similar alerts
- Use multi-resource alerts
- Monitor alert rule costs

## Webhook Payload

Common alert schema payload:

```json
{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/{sub-id}/providers/Microsoft.AlertsManagement/alerts/{alert-id}",
      "alertRule": "myAlert",
      "severity": "Sev2",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": [
        "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}"
      ],
      "originAlertId": "{origin-id}",
      "firedDateTime": "2026-02-02T10:00:00.0000000Z",
      "description": "Alert when CPU exceeds 80%"
    },
    "alertContext": {
      "properties": null,
      "conditionType": "SingleResourceMultipleMetricCriteria",
      "condition": {
        "windowSize": "PT15M",
        "allOf": [
          {
            "metricName": "Percentage CPU",
            "metricNamespace": "Microsoft.Compute/virtualMachines",
            "operator": "GreaterThan",
            "threshold": "80",
            "timeAggregation": "Average",
            "dimensions": [],
            "metricValue": 85.5
          }
        ]
      }
    }
  }
}
```

## Query Alert History

```kql
// Alert history
AlertsManagementResources
| where type == "microsoft.alertsmanagement/alerts"
| where properties.essentials.startDateTime > ago(7d)
| project 
    AlertName = properties.essentials.alertRule,
    Severity = properties.essentials.severity,
    Status = properties.essentials.monitorCondition,
    StartTime = properties.essentials.startDateTime,
    Resource = tostring(properties.essentials.targetResourceName)
| order by StartTime desc

// Alert frequency
AlertsManagementResources
| where type == "microsoft.alertsmanagement/alerts"
| where properties.essentials.startDateTime > ago(30d)
| summarize AlertCount = count() by AlertName = tostring(properties.essentials.alertRule)
| order by AlertCount desc
```

## Resources

- [Azure Monitor Alerts Documentation](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-overview)
- [Alert Types](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-types)
- [Action Groups](https://docs.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Common Alert Schema](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-common-schema)
