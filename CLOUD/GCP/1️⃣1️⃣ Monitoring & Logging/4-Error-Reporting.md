# Error Reporting

Real-time error tracking and alerting.

---

## Overview

Error Reporting aggregates and displays errors from cloud services, providing real-time notifications and detailed error analysis.

---

## Key Features

- Automatic error detection
- Error grouping
- Stack trace analysis
- Real-time notifications
- Integration with logging
- Free service

---

## Automatic Error Detection

**Supported Services:**
- App Engine
- Cloud Functions
- Cloud Run
- GKE
- Compute Engine (with agent)

**Error Detection:**
```
Automatically detects:
  • Exceptions in logs
  • HTTP 5xx errors
  • Crash reports
  • Stack traces
```

---

## Manual Error Reporting

**Python:**
```python
from google.cloud import error_reporting

client = error_reporting.Client()

try:
    raise Exception("Something went wrong")
except Exception:
    client.report_exception()
```

**Node.js:**
```javascript
const {ErrorReporting} = require('@google-cloud/error-reporting');
const errors = new ErrorReporting();

errors.report('Something went wrong');
```

---

## Best Practices

✓ Enable error reporting for all services  
✓ Add context to errors  
✓ Set up notifications  
✓ Regular error triage  
✓ Link to issue tracker  

---

**Last Updated:** March 2026
