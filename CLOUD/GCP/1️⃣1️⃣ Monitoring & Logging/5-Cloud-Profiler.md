# Cloud Profiler

Continuous CPU and memory profiling.

---

## Overview

Cloud Profiler provides continuous profiling of CPU and memory usage in production, helping identify performance bottlenecks.

---

## Key Features

- CPU profiling
- Heap profiling
- Low overhead (<0.5%)
- Production-safe
- Flame graphs
- Free service

---

## Supported Languages

- Java
- Go
- Python
- Node.js
- .NET

---

## Quick Start

**Python:**
```python
import googlecloudprofiler

googlecloudprofiler.start(
    service='my-service',
    service_version='1.0.0',
    verbose=3
)
```

**Node.js:**
```javascript
require('@google-cloud/profiler').start({
  serviceContext: {
    service: 'my-service',
    version: '1.0.0'
  }
});
```

**Go:**
```go
import "cloud.google.com/go/profiler"

if err := profiler.Start(profiler.Config{
    Service:        "my-service",
    ServiceVersion: "1.0.0",
}); err != nil {
    log.Fatal(err)
}
```

---

## Best Practices

✓ Enable in production  
✓ Use meaningful service names  
✓ Include version information  
✓ Regular profile analysis  
✓ Compare profiles over time  

---

**Last Updated:** March 2026
