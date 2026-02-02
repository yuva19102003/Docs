# KQL (Kusto Query Language) Queries

## Overview

Kusto Query Language (KQL) is the query language used in Azure Monitor Log Analytics, Application Insights, and Azure Data Explorer. It's optimized for read-heavy operations and provides powerful data exploration capabilities.

## Basic Query Structure

```kql
TableName
| operator1
| operator2
| operator3
```

## Essential Operators

### where - Filter Rows
```kql
// Filter by time
AzureActivity
| where TimeGenerated > ago(24h)

// Filter by multiple conditions
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue == "Microsoft.Compute/virtualMachines/write"
| where ActivityStatusValue == "Success"

// Filter with contains
Syslog
| where SyslogMessage contains "error"

// Filter with regex
SecurityEvent
| where Account matches regex @"^admin.*"
```

### project - Select Columns
```kql
// Select specific columns
AzureActivity
| project TimeGenerated, OperationName, ResourceGroup, Caller

// Rename columns
AzureActivity
| project Time=TimeGenerated, Operation=OperationName

// Create calculated columns
Perf
| project TimeGenerated, Computer, UsagePercent = CounterValue
```

### summarize - Aggregate Data
```kql
// Count records
AzureActivity
| summarize count() by OperationName

// Multiple aggregations
Perf
| where CounterName == "% Processor Time"
| summarize 
    AvgCPU = avg(CounterValue),
    MaxCPU = max(CounterValue),
    MinCPU = min(CounterValue)
    by Computer

// Time-based aggregation
requests
| summarize RequestCount = count() by bin(timestamp, 1h)
```

### extend - Add Calculated Columns
```kql
// Add new column
AzureActivity
| extend Hour = hourofday(TimeGenerated)

// Multiple calculations
Perf
| extend 
    UsagePercent = CounterValue,
    IsHighUsage = CounterValue > 80
```

### join - Combine Tables
```kql
// Inner join
Heartbeat
| join kind=inner (
    Perf
    | where CounterName == "% Processor Time"
) on Computer

// Left outer join
AzureActivity
| join kind=leftouter (
    AzureDiagnostics
) on ResourceId
```

### union - Combine Multiple Tables
```kql
// Union tables
union Syslog, Event
| where TimeGenerated > ago(1h)

// Union with wildcard
union withsource=TableName *
| where TimeGenerated > ago(1h)
| summarize count() by TableName
```

### sort/order - Sort Results
```kql
// Sort ascending
AzureActivity
| sort by TimeGenerated asc

// Sort descending (order is alias for sort)
AzureActivity
| order by TimeGenerated desc

// Multiple sort columns
Perf
| sort by Computer asc, TimeGenerated desc
```

### take/limit - Limit Results
```kql
// Take first 10 rows
AzureActivity
| take 10

// Limit is alias for take
AzureActivity
| limit 100
```

### top - Top N Results
```kql
// Top 10 by count
AzureActivity
| summarize count() by OperationName
| top 10 by count_

// Top computers by CPU
Perf
| where CounterName == "% Processor Time"
| summarize AvgCPU = avg(CounterValue) by Computer
| top 5 by AvgCPU desc
```

## Time Functions

```kql
// Relative time
| where TimeGenerated > ago(1h)
| where TimeGenerated > ago(7d)
| where TimeGenerated > ago(30d)

// Specific time range
| where TimeGenerated between (datetime(2026-02-01) .. datetime(2026-02-02))

// Time bins
| summarize count() by bin(TimeGenerated, 1h)
| summarize count() by bin(TimeGenerated, 1d)

// Extract time parts
| extend Hour = hourofday(TimeGenerated)
| extend DayOfWeek = dayofweek(TimeGenerated)
| extend Month = monthofyear(TimeGenerated)

// Format time
| extend FormattedTime = format_datetime(TimeGenerated, 'yyyy-MM-dd HH:mm:ss')
```

## String Functions

```kql
// Contains
| where Message contains "error"

// Case-insensitive contains
| where Message contains_cs "Error"

// Starts with / ends with
| where Computer startswith "web"
| where Computer endswith "prod"

// String extraction
| extend Domain = extract(@"@(.+)", 1, Email)

// String split
| extend Parts = split(Path, "/")

// String concatenation
| extend FullName = strcat(FirstName, " ", LastName)

// String length
| extend MessageLength = strlen(Message)

// Replace
| extend CleanMessage = replace(@"\d+", "X", Message)
```

## Aggregation Functions

```kql
// Count
| summarize count()
| summarize count() by Category
| summarize CountIf = countif(Status == "Failed")

// Sum
| summarize TotalBytes = sum(BytesSent)

// Average
| summarize AvgDuration = avg(DurationMs)

// Min/Max
| summarize MinValue = min(Value), MaxValue = max(Value)

// Percentiles
| summarize 
    p50 = percentile(DurationMs, 50),
    p95 = percentile(DurationMs, 95),
    p99 = percentile(DurationMs, 99)

// Standard deviation
| summarize StdDev = stdev(Value)

// Distinct count
| summarize UniqueUsers = dcount(UserId)

// Make list/set
| summarize Computers = make_list(Computer)
| summarize UniqueComputers = make_set(Computer)
```

## Practical Query Examples

### Application Monitoring

```kql
// Failed requests in last 24 hours
requests
| where timestamp > ago(24h)
| where success == false
| summarize FailureCount = count() by resultCode, bin(timestamp, 1h)
| render timechart

// Slow requests (> 5 seconds)
requests
| where timestamp > ago(1h)
| where duration > 5000
| project timestamp, name, url, duration, resultCode
| order by duration desc

// Exception analysis
exceptions
| where timestamp > ago(24h)
| summarize ExceptionCount = count() by type, outerMessage
| order by ExceptionCount desc

// User activity
pageViews
| where timestamp > ago(7d)
| summarize Users = dcount(user_Id), PageViews = count() by bin(timestamp, 1d)
| render timechart
```

### Infrastructure Monitoring

```kql
// CPU usage across VMs
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| where TimeGenerated > ago(1h)
| summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart

// Memory usage
Perf
| where ObjectName == "Memory" and CounterName == "Available MBytes"
| where TimeGenerated > ago(1h)
| summarize AvgMemory = avg(CounterValue) by Computer
| order by AvgMemory asc

// Disk space
Perf
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where TimeGenerated > ago(1h)
| where InstanceName != "_Total"
| summarize FreeSpace = avg(CounterValue) by Computer, InstanceName
| where FreeSpace < 20

// Network traffic
Perf
| where ObjectName == "Network Adapter"
| where CounterName in ("Bytes Sent/sec", "Bytes Received/sec")
| where TimeGenerated > ago(1h)
| summarize Traffic = sum(CounterValue) by Computer, CounterName, bin(TimeGenerated, 5m)
| render timechart
```

### Kubernetes Monitoring

```kql
// Pod CPU usage
Perf
| where ObjectName == "K8SContainer"
| where CounterName == "cpuUsageNanoCores"
| where TimeGenerated > ago(1h)
| summarize AvgCPU = avg(CounterValue) by InstanceName, bin(TimeGenerated, 5m)
| render timechart

// Failed pods
KubePodInventory
| where TimeGenerated > ago(1h)
| where PodStatus != "Running"
| summarize count() by PodStatus, Namespace, Name
| order by count_ desc

// Container restarts
KubePodInventory
| where TimeGenerated > ago(24h)
| where RestartCount > 0
| summarize TotalRestarts = sum(RestartCount) by Namespace, Name
| order by TotalRestarts desc

// Node resource usage
KubeNodeInventory
| where TimeGenerated > ago(1h)
| extend CPUUsage = AllocatableCpuCores - AvailableCpuCores
| extend MemoryUsage = AllocatableMemoryBytes - AvailableMemoryBytes
| project TimeGenerated, Computer, CPUUsage, MemoryUsage
```

### Security Monitoring

```kql
// Failed login attempts
SecurityEvent
| where TimeGenerated > ago(24h)
| where EventID == 4625
| summarize FailedLogins = count() by Account, Computer
| where FailedLogins > 5
| order by FailedLogins desc

// Successful logins after failures
let FailedLogins = SecurityEvent
| where TimeGenerated > ago(1h)
| where EventID == 4625
| project Account, Computer, FailTime = TimeGenerated;
SecurityEvent
| where TimeGenerated > ago(1h)
| where EventID == 4624
| join kind=inner (FailedLogins) on Account, Computer
| where TimeGenerated > FailTime
| project Account, Computer, FailTime, SuccessTime = TimeGenerated

// Firewall blocks
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule" or Category == "AzureFirewallNetworkRule"
| where msg_s contains "Deny"
| summarize BlockCount = count() by SourceIP = split(msg_s, " ")[3]
| order by BlockCount desc
```

### Cost Analysis

```kql
// Data ingestion by table
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize IngestedGB = sum(Quantity) / 1000 by DataType
| order by IngestedGB desc

// Daily ingestion trend
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize IngestedGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1d)
| render timechart

// Ingestion by resource
AzureDiagnostics
| where TimeGenerated > ago(7d)
| summarize RecordCount = count() by ResourceId
| order by RecordCount desc
```

## Advanced Techniques

### Let Statements (Variables)
```kql
let threshold = 80;
let timeRange = ago(1h);
Perf
| where TimeGenerated > timeRange
| where CounterValue > threshold
| summarize count() by Computer
```

### Functions
```kql
let GetHighCPU = (threshold: real) {
    Perf
    | where CounterName == "% Processor Time"
    | where CounterValue > threshold
    | summarize AvgCPU = avg(CounterValue) by Computer
};
GetHighCPU(80)
```

### Subqueries
```kql
// Find computers with high CPU
let HighCPUComputers = Perf
| where CounterName == "% Processor Time"
| where CounterValue > 80
| distinct Computer;
// Get all metrics for those computers
Perf
| where Computer in (HighCPUComputers)
| where TimeGenerated > ago(1h)
```

### Pivot
```kql
Perf
| where CounterName in ("% Processor Time", "Available MBytes")
| summarize avg(CounterValue) by Computer, CounterName
| evaluate pivot(CounterName)
```

### Render Visualizations
```kql
// Time chart
| render timechart

// Bar chart
| render barchart

// Pie chart
| render piechart

// Scatter chart
| render scatterchart

// Area chart
| render areachart
```

## Query Optimization Tips

1. **Filter Early:** Use `where` before other operators
2. **Limit Time Range:** Always specify time filters
3. **Use Specific Columns:** Use `project` to select only needed columns
4. **Avoid Wildcards:** Use specific table names instead of `union *`
5. **Use Indexed Columns:** Filter on TimeGenerated, Computer, ResourceId
6. **Summarize Before Join:** Reduce data before joining tables
7. **Use `take` for Exploration:** Limit results during query development
8. **Cache Results:** Use `let` statements for repeated subqueries

## Common Patterns

### Top N with Others
```kql
requests
| summarize RequestCount = count() by name
| top 10 by RequestCount desc
| extend name = iff(RequestCount < 100, "Others", name)
| summarize sum(RequestCount) by name
```

### Moving Average
```kql
Perf
| where CounterName == "% Processor Time"
| where TimeGenerated > ago(24h)
| summarize AvgCPU = avg(CounterValue) by bin(TimeGenerated, 5m), Computer
| order by Computer, TimeGenerated asc
| serialize
| extend MovingAvg = row_window_session(AvgCPU, TimeGenerated, 15m, Computer, avg(AvgCPU))
```

### Anomaly Detection
```kql
requests
| where timestamp > ago(7d)
| make-series RequestCount = count() default = 0 on timestamp step 1h
| extend anomalies = series_decompose_anomalies(RequestCount, 1.5)
```

## Resources

- [KQL Quick Reference](https://docs.microsoft.com/azure/data-explorer/kql-quick-reference)
- [KQL Tutorial](https://docs.microsoft.com/azure/data-explorer/kusto/query/tutorial)
- [Best Practices](https://docs.microsoft.com/azure/data-explorer/kusto/query/best-practices)
- [Query Optimization](https://docs.microsoft.com/azure/azure-monitor/logs/query-optimization)
