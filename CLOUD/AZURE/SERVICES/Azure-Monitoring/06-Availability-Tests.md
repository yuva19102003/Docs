# Azure Availability Tests

## Overview

Availability tests monitor application availability and responsiveness from multiple geographic locations around the world. They help ensure your application is accessible to users globally.

## Test Types

### 1. URL Ping Test (Standard Test)
Simple HTTP/HTTPS endpoint check.

**Features:**
- Validates HTTP status code
- Checks response content
- Monitors SSL certificate
- Tests from multiple regions
- 5, 10, or 15-minute frequency

### 2. Multi-step Web Test (Classic)
Record and replay web interactions.

**Features:**
- Test complex user flows
- Validate multi-page scenarios
- Form submissions
- Authentication flows
- Visual Studio Web Test format

### 3. Custom TrackAvailability
Custom availability tests in code.

**Features:**
- Complex validation logic
- Integration with test frameworks
- Custom metrics
- Flexible scheduling

## Create URL Ping Test

### Azure Portal

1. Navigate to Application Insights resource
2. Select "Availability" under Investigate
3. Click "+ Add Standard test"
4. Configure:
   - **Test name:** Descriptive name
   - **URL:** Endpoint to test
   - **Test frequency:** 5, 10, or 15 minutes
   - **Test locations:** Select at least 5 locations
   - **Success criteria:**
     - HTTP status code (default: 200)
     - Content match (optional)
     - SSL certificate check
   - **Alerts:** Enable/disable

### Azure CLI

```bash
az rest --method put \
  --url "https://management.azure.com/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Insights/webtests/{test-name}?api-version=2022-06-15" \
  --body '{
    "location": "eastus",
    "tags": {
      "hidden-link:/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Insights/components/{app-insights-name}": "Resource"
    },
    "kind": "standard",
    "properties": {
      "SyntheticMonitorId": "{test-name}",
      "Name": "{test-name}",
      "Enabled": true,
      "Frequency": 300,
      "Timeout": 30,
      "Kind": "standard",
      "RetryEnabled": true,
      "Locations": [
        {"Id": "us-va-ash-azr"},
        {"Id": "us-ca-sjc-azr"},
        {"Id": "us-tx-sn1-azr"},
        {"Id": "us-il-ch1-azr"},
        {"Id": "us-fl-mia-edge"}
      ],
      "Request": {
        "RequestUrl": "https://example.com",
        "HttpVerb": "GET",
        "ParseDependentRequests": false
      },
      "ValidationRules": {
        "ExpectedHttpStatusCode": 200,
        "SSLCheck": true,
        "SSLCertRemainingLifetimeCheck": 7
      }
    }
  }'
```

### ARM Template

```json
{
  "type": "Microsoft.Insights/webtests",
  "apiVersion": "2022-06-15",
  "name": "myAvailabilityTest",
  "location": "eastus",
  "tags": {
    "hidden-link:/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Insights/components/{app-insights}": "Resource"
  },
  "kind": "standard",
  "properties": {
    "SyntheticMonitorId": "myAvailabilityTest",
    "Name": "My Availability Test",
    "Enabled": true,
    "Frequency": 300,
    "Timeout": 30,
    "Kind": "standard",
    "RetryEnabled": true,
    "Locations": [
      {"Id": "us-va-ash-azr"},
      {"Id": "us-ca-sjc-azr"},
      {"Id": "us-tx-sn1-azr"}
    ],
    "Request": {
      "RequestUrl": "https://example.com/api/health",
      "HttpVerb": "GET",
      "Headers": [
        {"key": "Authorization", "value": "Bearer token"}
      ],
      "ParseDependentRequests": false
    },
    "ValidationRules": {
      "ExpectedHttpStatusCode": 200,
      "ContentValidation": {
        "ContentMatch": "healthy",
        "IgnoreCase": true,
        "PassIfTextFound": true
      },
      "SSLCheck": true,
      "SSLCertRemainingLifetimeCheck": 7
    }
  }
}
```

## Test Locations

### Available Locations

```
North America:
- us-va-ash-azr (East US - Virginia)
- us-ca-sjc-azr (West US - California)
- us-tx-sn1-azr (South Central US - Texas)
- us-il-ch1-azr (North Central US - Illinois)
- us-fl-mia-edge (East US - Florida)

Europe:
- emea-nl-ams-azr (West Europe - Netherlands)
- emea-gb-db3-azr (UK South - London)
- emea-fr-pra-edge (France Central - Paris)
- emea-ch-zrh-edge (Switzerland North - Zurich)
- emea-ru-msa-edge (Russia Central - Moscow)
- emea-se-sto-edge (Sweden Central - Stockholm)

Asia Pacific:
- apac-sg-sin-azr (Southeast Asia - Singapore)
- apac-jp-kaw-edge (Japan East - Tokyo)
- apac-hk-hkn-azr (East Asia - Hong Kong)
- apac-au-syd-azr (Australia East - Sydney)

South America:
- latam-br-gru-edge (Brazil South - São Paulo)
```

### Select Locations

**Best Practices:**
- Choose at least 5 locations
- Cover regions where users are located
- Include geographically diverse locations
- Consider regulatory requirements

## Custom Availability Tests

### C# Example

```csharp
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using System;
using System.Diagnostics;
using System.Net.Http;
using System.Threading.Tasks;

public class CustomAvailabilityTest
{
    private readonly TelemetryClient _telemetryClient;

    public CustomAvailabilityTest(string instrumentationKey)
    {
        var config = new TelemetryConfiguration(instrumentationKey);
        _telemetryClient = new TelemetryClient(config);
    }

    public async Task RunAvailabilityTestAsync()
    {
        var availability = new AvailabilityTelemetry
        {
            Name = "Custom API Health Check",
            RunLocation = Environment.MachineName,
            Success = false
        };

        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            using var httpClient = new HttpClient();
            httpClient.Timeout = TimeSpan.FromSeconds(30);
            
            var response = await httpClient.GetAsync("https://api.example.com/health");
            var content = await response.Content.ReadAsStringAsync();
            
            availability.Success = response.IsSuccessStatusCode && content.Contains("healthy");
            availability.Message = $"Status: {response.StatusCode}, Content: {content}";
            
            // Add custom properties
            availability.Properties.Add("StatusCode", ((int)response.StatusCode).ToString());
            availability.Properties.Add("ResponseSize", content.Length.ToString());
        }
        catch (Exception ex)
        {
            availability.Success = false;
            availability.Message = $"Exception: {ex.Message}";
        }
        finally
        {
            stopwatch.Stop();
            availability.Duration = stopwatch.Elapsed;
            availability.Timestamp = DateTimeOffset.UtcNow;
            
            _telemetryClient.TrackAvailability(availability);
            _telemetryClient.Flush();
        }
    }
}
```

### Node.js Example

```javascript
const appInsights = require('applicationinsights');
const axios = require('axios');

appInsights.setup('YOUR_INSTRUMENTATION_KEY').start();
const client = appInsights.defaultClient;

async function runAvailabilityTest() {
    const startTime = Date.now();
    let success = false;
    let message = '';

    try {
        const response = await axios.get('https://api.example.com/health', {
            timeout: 30000
        });
        
        success = response.status === 200 && response.data.status === 'healthy';
        message = `Status: ${response.status}`;
    } catch (error) {
        success = false;
        message = `Error: ${error.message}`;
    }

    const duration = Date.now() - startTime;

    client.trackAvailability({
        name: 'Custom API Health Check',
        success: success,
        duration: duration,
        runLocation: process.env.HOSTNAME || 'local',
        message: message
    });

    client.flush();
}

// Run every 5 minutes
setInterval(runAvailabilityTest, 5 * 60 * 1000);
```

### Python Example

```python
from applicationinsights import TelemetryClient
from applicationinsights.channel import TelemetryChannel
import requests
import time
from datetime import datetime

def run_availability_test(instrumentation_key):
    client = TelemetryClient(instrumentation_key)
    
    start_time = time.time()
    success = False
    message = ''
    
    try:
        response = requests.get('https://api.example.com/health', timeout=30)
        success = response.status_code == 200 and 'healthy' in response.text
        message = f'Status: {response.status_code}'
    except Exception as e:
        success = False
        message = f'Exception: {str(e)}'
    
    duration = time.time() - start_time
    
    client.track_availability(
        name='Custom API Health Check',
        duration=duration * 1000,  # milliseconds
        success=success,
        run_location='local',
        message=message
    )
    
    client.flush()

# Run test
run_availability_test('YOUR_INSTRUMENTATION_KEY')
```

## Query Availability Results

### Basic Queries

```kql
// Availability test results
availabilityResults
| where timestamp > ago(24h)
| summarize 
    AvailabilityRate = avg(success) * 100,
    AvgDuration = avg(duration),
    FailureCount = countif(success == false)
    by name, location
| order by AvailabilityRate asc

// Failed tests
availabilityResults
| where timestamp > ago(1h)
| where success == false
| project timestamp, name, location, message, duration
| order by timestamp desc

// Availability by location
availabilityResults
| where timestamp > ago(7d)
| summarize AvailabilityRate = avg(success) * 100 by location, bin(timestamp, 1h)
| render timechart

// Response time trend
availabilityResults
| where timestamp > ago(24h)
| where success == true
| summarize AvgDuration = avg(duration) by bin(timestamp, 15m), name
| render timechart
```

### Advanced Queries

```kql
// Availability SLA calculation
availabilityResults
| where timestamp > ago(30d)
| summarize 
    TotalTests = count(),
    SuccessfulTests = countif(success == true)
| extend SLA = (SuccessfulTests * 100.0) / TotalTests
| project SLA, TotalTests, SuccessfulTests

// Slowest locations
availabilityResults
| where timestamp > ago(24h)
| where success == true
| summarize AvgDuration = avg(duration) by location
| order by AvgDuration desc
| take 5

// Failure patterns
availabilityResults
| where timestamp > ago(7d)
| where success == false
| summarize FailureCount = count() by bin(timestamp, 1h), location
| render timechart

// Compare test performance
availabilityResults
| where timestamp > ago(24h)
| summarize 
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95),
    AvailabilityRate = avg(success) * 100
    by name
| order by AvailabilityRate asc
```

## Configure Alerts

### Availability Alert

```bash
az monitor metrics alert create \
  --name availabilityAlert \
  --resource-group myResourceGroup \
  --scopes /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Insights/components/{app-insights} \
  --condition "avg availabilityResults/availabilityPercentage < 99" \
  --description "Alert when availability drops below 99%" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 1 \
  --action /subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/actionGroups/{action-group}
```

### Multi-Location Alert

Alert when test fails from multiple locations:

```kql
availabilityResults
| where timestamp > ago(5m)
| where success == false
| summarize FailedLocations = dcount(location) by name
| where FailedLocations >= 3
```

## Best Practices

### Test Configuration

1. **Frequency:**
   - Critical endpoints: 5 minutes
   - Important endpoints: 10 minutes
   - Non-critical endpoints: 15 minutes

2. **Locations:**
   - Minimum 5 locations
   - Cover user geographic distribution
   - Include diverse regions

3. **Timeout:**
   - Set realistic timeouts (30-120 seconds)
   - Consider network latency
   - Balance between false positives and real issues

4. **Retry:**
   - Enable retry for transient failures
   - Reduces false positive alerts

### What to Test

- **Critical user paths:** Login, checkout, search
- **API endpoints:** Health checks, key APIs
- **Static content:** Homepage, CDN endpoints
- **Dependencies:** External services, databases

### What NOT to Test

- Internal-only endpoints
- Development/staging environments (use separate tests)
- Endpoints with rate limiting
- Endpoints requiring complex authentication

### Content Validation

```json
{
  "ContentValidation": {
    "ContentMatch": "healthy",
    "IgnoreCase": true,
    "PassIfTextFound": true
  }
}
```

**Use Cases:**
- Verify API response format
- Check for error messages
- Validate dynamic content
- Ensure correct page loaded

### SSL Certificate Monitoring

```json
{
  "SSLCheck": true,
  "SSLCertRemainingLifetimeCheck": 7
}
```

**Benefits:**
- Prevent certificate expiration
- Early warning (7 days default)
- Automatic monitoring

## Troubleshooting

### Test Failures

**Check:**
1. Test configuration (URL, headers, validation rules)
2. Application logs for errors
3. Network connectivity from test locations
4. SSL certificate validity
5. Firewall/WAF rules

### False Positives

**Solutions:**
- Increase timeout value
- Enable retry
- Adjust content validation
- Review alert thresholds
- Check for maintenance windows

### High Response Times

**Investigate:**
```kql
availabilityResults
| where timestamp > ago(24h)
| where duration > 5000
| summarize count() by location, bin(timestamp, 1h)
| render timechart
```

## Cost Optimization

**Pricing:**
- Standard tests: $0.001 per test execution
- Multi-step tests: $0.005 per test execution

**Optimization:**
- Use appropriate test frequency
- Limit number of test locations
- Consolidate similar tests
- Use custom tests for complex scenarios

## Resources

- [Availability Tests Documentation](https://docs.microsoft.com/azure/azure-monitor/app/availability-overview)
- [URL Ping Tests](https://docs.microsoft.com/azure/azure-monitor/app/monitor-web-app-availability)
- [Custom Availability Tests](https://docs.microsoft.com/azure/azure-monitor/app/availability-azure-functions)
- [Troubleshooting Guide](https://docs.microsoft.com/azure/azure-monitor/app/troubleshoot-availability)
