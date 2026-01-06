# Circuit Breaker Pattern

## Overview
The Circuit Breaker pattern prevents an application from repeatedly trying to execute an operation that's likely to fail. It acts like an electrical circuit breaker - when failures reach a threshold, the circuit "opens" and requests fail immediately without attempting the operation, giving the failing service time to recover.

---

## Problem Statement

### Cascading Failures
```
Service A → Service B → Service C (FAILING)
    │           │            │
    │           │            └─ Timeout (30s)
    │           └─ Timeout (30s)
    └─ Timeout (30s)

Total Response Time: 90 seconds!
All services blocked waiting for failed service.
```

### Issues Without Circuit Breaker
- **Resource Exhaustion** - Threads blocked waiting for timeouts
- **Cascading Failures** - One service failure affects entire system
- **Slow Recovery** - Failed service overwhelmed with retry attempts
- **Poor User Experience** - Long wait times for inevitable failures
- **Wasted Resources** - CPU/memory consumed by doomed requests

### When to Use Circuit Breaker
✅ Calling external services/APIs  
✅ Database connections  
✅ Microservices communication  
✅ Network operations  
✅ Any operation that can fail  
✅ Need graceful degradation  

### When NOT to Use
❌ Internal memory operations  
❌ Operations that must succeed  
❌ Single-user applications  
❌ Operations with no timeout  

---

## Architecture Diagram

### Circuit Breaker States
```
                    ┌─────────────────────────────────────┐
                    │                                     │
                    │         CLOSED STATE                │
                    │    (Normal Operation)               │
                    │                                     │
                    │  • All requests pass through        │
                    │  • Counting failures                │
                    │  • Success resets counter           │
                    │                                     │
                    └──────────────┬──────────────────────┘
                                   │
                                   │ Failure threshold reached
                                   │ (e.g., 5 failures in 10s)
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │                                     │
                    │          OPEN STATE                 │
                    │      (Circuit Tripped)              │
                    │                                     │
                    │  • All requests fail immediately    │
                    │  • No calls to failing service      │
                    │  • Return fallback response         │
                    │  • Wait for timeout period          │
                    │                                     │
                    └──────────────┬──────────────────────┘
                                   │
                                   │ Timeout expires
                                   │ (e.g., after 60s)
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │                                     │
                    │        HALF-OPEN STATE              │
                    │      (Testing Recovery)             │
                    │                                     │
                    │  • Limited requests allowed         │
                    │  • Testing if service recovered     │
                    │  • Success → CLOSED                 │
                    │  • Failure → OPEN                   │
                    │                                     │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    │ Success                     │ Failure
                    ▼                             ▼
            ┌───────────────┐           ┌─────────────────┐
            │    CLOSED     │           │      OPEN       │
            │  (Recovered)  │           │  (Still Broken) │
            └───────────────┘           └─────────────────┘
```

### System Architecture with Circuit Breaker
```
┌──────────────────────────────────────────────────────────────────┐
│                        Client Application                        │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             │ Request
                             │
                             ▼
              ┌──────────────────────────────┐
              │      Circuit Breaker         │
              │                              │
              │  State: CLOSED/OPEN/HALF     │
              │  Failure Count: 3/5          │
              │  Last Failure: 2s ago        │
              │  Timeout: 60s                │
              └──────────┬───────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         │ CLOSED        │ OPEN          │ HALF-OPEN
         │               │               │
         ▼               ▼               ▼
┌────────────────┐  ┌────────────┐  ┌────────────┐
│  Call Service  │  │  Fail Fast │  │ Test Call  │
│                │  │  Return    │  │            │
│                │  │  Fallback  │  │            │
└───────┬────────┘  └────────────┘  └─────┬──────┘
        │                                  │
        │ Success/Failure                  │ Success/Failure
        │                                  │
        ▼                                  ▼
┌────────────────────────────────────────────────┐
│           External Service / API               │
│                                                │
│  • Payment Gateway                             │
│  • Database                                    │
│  • Third-party API                             │
│  • Microservice                                │
└────────────────────────────────────────────────┘
```

---

## Workflow Explanation

### Normal Operation (CLOSED State)
```
1. Request arrives
2. Circuit Breaker checks state → CLOSED
3. Forward request to service
4. Service responds successfully
5. Reset failure counter
6. Return response to client
```

### Failure Detection (CLOSED → OPEN)
```
1. Request arrives
2. Circuit Breaker forwards to service
3. Service fails (timeout/error)
4. Increment failure counter (3/5)
5. Another request arrives
6. Service fails again (4/5)
7. Another request arrives
8. Service fails again (5/5) ← THRESHOLD REACHED
9. Circuit Breaker opens
10. Start timeout timer (60s)
```

### Fast Fail (OPEN State)
```
1. Request arrives
2. Circuit Breaker checks state → OPEN
3. Check if timeout expired → NO
4. Fail immediately (no service call)
5. Return fallback response
6. Total time: < 1ms (vs 30s timeout)
```

### Recovery Testing (HALF-OPEN State)
```
1. Timeout expires (60s passed)
2. Circuit Breaker → HALF-OPEN
3. Next request arrives
4. Allow ONE test request through
5. Forward to service
6. Service responds successfully
7. Circuit Breaker → CLOSED
8. Resume normal operation
```

---

## Implementation Examples

### Node.js with opossum
```javascript
const CircuitBreaker = require('opossum');
const axios = require('axios');

// Function to protect
async function callExternalAPI(userId) {
  const response = await axios.get(`https://api.example.com/users/${userId}`);
  return response.data;
}

// Circuit breaker options
const options = {
  timeout: 3000,              // 3s timeout
  errorThresholdPercentage: 50, // Open after 50% failures
  resetTimeout: 30000,        // Try again after 30s
  rollingCountTimeout: 10000, // 10s window for counting
  rollingCountBuckets: 10,    // Number of buckets
  name: 'externalAPI',
  fallback: (userId) => {
    // Fallback response when circuit is open
    return {
      id: userId,
      name: 'Unknown',
      cached: true,
      message: 'Service temporarily unavailable'
    };
  }
};

// Create circuit breaker
const breaker = new CircuitBreaker(callExternalAPI, options);

// Event listeners
breaker.on('open', () => {
  console.log('Circuit breaker opened - service is failing');
});

breaker.on('halfOpen', () => {
  console.log('Circuit breaker half-open - testing service');
});

breaker.on('close', () => {
  console.log('Circuit breaker closed - service recovered');
});

breaker.on('fallback', (result) => {
  console.log('Fallback executed:', result);
});

// Usage
async function getUser(userId) {
  try {
    const user = await breaker.fire(userId);
    return user;
  } catch (error) {
    console.error('Request failed:', error.message);
    throw error;
  }
}

// Express endpoint
app.get('/users/:id', async (req, res) => {
  try {
    const user = await getUser(req.params.id);
    res.json(user);
  } catch (error) {
    res.status(503).json({
      error: 'Service unavailable',
      message: error.message
    });
  }
});

// Health check endpoint
app.get('/health/circuit-breaker', (req, res) => {
  res.json({
    name: breaker.name,
    state: breaker.opened ? 'OPEN' : breaker.halfOpen ? 'HALF_OPEN' : 'CLOSED',
    stats: breaker.stats
  });
});
```

### Go with gobreaker
```go
package main

import (
    "errors"
    "fmt"
    "net/http"
    "time"
    
    "github.com/sony/gobreaker"
)

// Create circuit breaker
var cb *gobreaker.CircuitBreaker

func init() {
    settings := gobreaker.Settings{
        Name:        "ExternalAPI",
        MaxRequests: 3,                    // Max requests in half-open
        Interval:    time.Second * 10,     // Rolling window
        Timeout:     time.Second * 60,     // Time before half-open
        ReadyToTrip: func(counts gobreaker.Counts) bool {
            failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
            return counts.Requests >= 3 && failureRatio >= 0.6
        },
        OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
            fmt.Printf("Circuit Breaker '%s': %s -> %s\n", name, from, to)
        },
    }
    
    cb = gobreaker.NewCircuitBreaker(settings)
}

// Protected function
func callExternalAPI(userID string) (User, error) {
    result, err := cb.Execute(func() (interface{}, error) {
        // Make HTTP request
        resp, err := http.Get(fmt.Sprintf("https://api.example.com/users/%s", userID))
        if err != nil {
            return nil, err
        }
        defer resp.Body.Close()
        
        if resp.StatusCode != 200 {
            return nil, fmt.Errorf("API returned status %d", resp.StatusCode)
        }
        
        var user User
        if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
            return nil, err
        }
        
        return user, nil
    })
    
    if err != nil {
        // Return fallback
        return User{
            ID:      userID,
            Name:    "Unknown",
            Cached:  true,
            Message: "Service temporarily unavailable",
        }, err
    }
    
    return result.(User), nil
}

// HTTP handler
func getUserHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.URL.Query().Get("id")
    
    user, err := callExternalAPI(userID)
    if err != nil {
        if errors.Is(err, gobreaker.ErrOpenState) {
            w.WriteHeader(http.StatusServiceUnavailable)
            json.NewEncoder(w).Encode(map[string]string{
                "error": "Circuit breaker is open",
                "message": "Service temporarily unavailable",
            })
            return
        }
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}

// Health check
func healthHandler(w http.ResponseWriter, r *http.Request) {
    state := cb.State()
    
    status := map[string]interface{}{
        "name":  cb.Name,
        "state": state.String(),
        "counts": cb.Counts(),
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(status)
}
```

### Java with Resilience4j
```java
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import java.time.Duration;

public class CircuitBreakerExample {
    
    private final CircuitBreaker circuitBreaker;
    private final ExternalAPIClient apiClient;
    
    public CircuitBreakerExample() {
        // Configure circuit breaker
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
            .failureRateThreshold(50)                    // 50% failure rate
            .waitDurationInOpenState(Duration.ofSeconds(60))  // Wait 60s
            .slidingWindowSize(10)                       // Last 10 calls
            .minimumNumberOfCalls(5)                     // Min 5 calls
            .permittedNumberOfCallsInHalfOpenState(3)    // 3 test calls
            .automaticTransitionFromOpenToHalfOpenEnabled(true)
            .build();
        
        CircuitBreakerRegistry registry = CircuitBreakerRegistry.of(config);
        this.circuitBreaker = registry.circuitBreaker("externalAPI");
        
        // Event listeners
        circuitBreaker.getEventPublisher()
            .onStateTransition(event -> 
                System.out.println("Circuit Breaker: " + event.getStateTransition())
            )
            .onError(event -> 
                System.out.println("Error: " + event.getThrowable().getMessage())
            );
        
        this.apiClient = new ExternalAPIClient();
    }
    
    public User getUser(String userId) {
        return circuitBreaker.executeSupplier(() -> {
            try {
                return apiClient.fetchUser(userId);
            } catch (Exception e) {
                throw new RuntimeException("API call failed", e);
            }
        });
    }
    
    public User getUserWithFallback(String userId) {
        return circuitBreaker.executeSupplier(
            () -> apiClient.fetchUser(userId),
            throwable -> {
                // Fallback response
                return new User(userId, "Unknown", true, 
                    "Service temporarily unavailable");
            }
        );
    }
}
```

---

## Configuration Parameters

### Key Settings

| Parameter | Description | Typical Value |
|-----------|-------------|---------------|
| **Failure Threshold** | Number/percentage of failures to open | 50% or 5 failures |
| **Timeout** | Max time to wait for response | 3-10 seconds |
| **Reset Timeout** | Time before trying half-open | 30-60 seconds |
| **Success Threshold** | Successes needed to close | 2-3 requests |
| **Rolling Window** | Time window for counting failures | 10-60 seconds |
| **Half-Open Requests** | Test requests in half-open state | 1-3 requests |

### Example Configuration
```yaml
circuit-breaker:
  external-api:
    failure-rate-threshold: 50        # 50% failures
    slow-call-rate-threshold: 50      # 50% slow calls
    slow-call-duration-threshold: 3s  # > 3s is slow
    wait-duration-in-open-state: 60s  # Wait 60s
    sliding-window-type: COUNT_BASED  # or TIME_BASED
    sliding-window-size: 10           # Last 10 calls
    minimum-number-of-calls: 5        # Min 5 calls
    permitted-calls-in-half-open: 3   # 3 test calls
```

---

## Fallback Strategies

### 1. Cached Response
```javascript
const cache = new Map();

const fallback = (userId) => {
  // Return cached data if available
  if (cache.has(userId)) {
    return {
      ...cache.get(userId),
      cached: true,
      timestamp: new Date()
    };
  }
  
  // Return default response
  return {
    id: userId,
    name: 'Unknown',
    message: 'Service unavailable'
  };
};
```

### 2. Default Response
```javascript
const fallback = () => ({
  status: 'unavailable',
  message: 'Service temporarily unavailable. Please try again later.',
  retryAfter: 60
});
```

### 3. Alternative Service
```javascript
const fallback = async (userId) => {
  // Try backup service
  try {
    return await backupService.getUser(userId);
  } catch (error) {
    return defaultResponse(userId);
  }
};
```

### 4. Degraded Functionality
```javascript
const fallback = (userId) => ({
  id: userId,
  name: 'User',
  features: {
    basicProfile: true,
    advancedFeatures: false  // Disable advanced features
  },
  message: 'Running in degraded mode'
});
```

---

## Monitoring & Metrics

### Key Metrics to Track
```
┌─────────────────────────────────────────┐
│      Circuit Breaker Metrics            │
├─────────────────────────────────────────┤
│ • Current State (CLOSED/OPEN/HALF)      │
│ • Failure Rate (%)                      │
│ • Success Rate (%)                      │
│ • Total Requests                        │
│ • Failed Requests                       │
│ • Successful Requests                   │
│ • Rejected Requests (circuit open)      │
│ • Response Time (p50, p95, p99)         │
│ • Time in Each State                    │
│ • State Transitions Count               │
└─────────────────────────────────────────┘
```

### Prometheus Metrics
```javascript
const { Gauge, Counter, Histogram } = require('prom-client');

// Circuit breaker state
const circuitState = new Gauge({
  name: 'circuit_breaker_state',
  help: 'Circuit breaker state (0=closed, 1=open, 2=half-open)',
  labelNames: ['name']
});

// Request counter
const requests = new Counter({
  name: 'circuit_breaker_requests_total',
  help: 'Total requests through circuit breaker',
  labelNames: ['name', 'result']  // result: success, failure, rejected
});

// Response time
const responseTime = new Histogram({
  name: 'circuit_breaker_response_time_seconds',
  help: 'Response time through circuit breaker',
  labelNames: ['name']
});

// Update metrics
breaker.on('success', () => {
  requests.inc({ name: breaker.name, result: 'success' });
});

breaker.on('failure', () => {
  requests.inc({ name: breaker.name, result: 'failure' });
});

breaker.on('reject', () => {
  requests.inc({ name: breaker.name, result: 'rejected' });
});

breaker.on('open', () => {
  circuitState.set({ name: breaker.name }, 1);
});

breaker.on('close', () => {
  circuitState.set({ name: breaker.name }, 0);
});
```

### Grafana Dashboard
```
┌─────────────────────────────────────────────────────────┐
│  Circuit Breaker: External API                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  State: CLOSED          Uptime: 99.5%                   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Request Rate                                     │  │
│  │  ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁                                 │  │
│  │  1000 req/s                                       │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Success Rate                                     │  │
│  │  ████████████████████████████████████░░  95%     │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Response Time (p95)                              │  │
│  │  ▁▁▂▂▃▃▄▄▅▅▆▆▇▇██                                │  │
│  │  250ms                                            │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  State Transitions (Last 24h): 2                        │
│  Last Open: 2 hours ago (Duration: 60s)                 │
└─────────────────────────────────────────────────────────┘
```

---

## Best Practices

### Configuration
✅ **Set Appropriate Thresholds** - Not too sensitive, not too lenient  
✅ **Consider Service SLA** - Align timeouts with SLA  
✅ **Test Failure Scenarios** - Verify circuit breaker works  
✅ **Monitor Metrics** - Track state transitions  
✅ **Document Behavior** - Team understands fallbacks  

### Implementation
✅ **Implement Fallbacks** - Always provide fallback response  
✅ **Use Caching** - Cache responses for fallback  
✅ **Log State Changes** - Track when circuit opens/closes  
✅ **Gradual Recovery** - Use half-open state properly  
✅ **Per-Service Breakers** - Separate breaker per dependency  

### Operations
✅ **Alert on Open State** - Know when services fail  
✅ **Dashboard Visibility** - Monitor circuit breaker health  
✅ **Regular Testing** - Chaos engineering  
✅ **Review Thresholds** - Adjust based on metrics  
✅ **Document Incidents** - Learn from failures  

---

## Pros & Cons

### Advantages
✅ **Prevents Cascading Failures** - Isolates failures  
✅ **Fast Failure** - No waiting for timeouts  
✅ **Resource Protection** - Prevents resource exhaustion  
✅ **Automatic Recovery** - Self-healing capability  
✅ **Better UX** - Faster error responses  
✅ **Graceful Degradation** - Fallback responses  

### Disadvantages
❌ **Added Complexity** - More code to maintain  
❌ **Configuration Challenge** - Hard to tune correctly  
❌ **False Positives** - May open unnecessarily  
❌ **Monitoring Overhead** - Need good observability  
❌ **Testing Complexity** - Hard to test all scenarios  

---

## Real-World Examples

### Netflix Hystrix
- Protects 10+ billion requests/day
- Prevents cascading failures
- Provides fallback responses
- Real-time monitoring dashboard

### AWS API Gateway
- Built-in circuit breaker
- Automatic throttling
- Protects backend services

### Kubernetes
- Readiness/liveness probes
- Service mesh circuit breakers (Istio)
- Automatic pod restarts

---

## Related Patterns
- [Rate Limiting Pattern](09-Rate-Limiting.md)
- [Retry Pattern](../DEVOPS-TOPICS/)
- [Bulkhead Pattern](../DEVOPS-TOPICS/)
- [Timeout Pattern](../DEVOPS-TOPICS/)

---

## Tools & Libraries

### Node.js
- **opossum** - Full-featured circuit breaker
- **cockatiel** - Resilience patterns library
- **brakes** - Hystrix-inspired breaker

### Go
- **gobreaker** - Simple circuit breaker
- **hystrix-go** - Netflix Hystrix port

### Java
- **Resilience4j** - Modern resilience library
- **Hystrix** - Netflix (maintenance mode)
- **Failsafe** - Lightweight library

### Python
- **pybreaker** - Circuit breaker implementation
- **circuitbreaker** - Simple decorator

---

**Last Updated:** January 5, 2026  
**Pattern Complexity:** Medium  
**Recommended For:** All distributed systems with external dependencies
