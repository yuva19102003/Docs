# Cloud Trace

Distributed tracing system for latency analysis.

---

## Overview

Cloud Trace collects latency data from applications and displays it in the Google Cloud Console, helping you understand how requests propagate through your application.

---

## Key Features

- Distributed tracing
- Latency analysis
- Performance insights
- Automatic trace collection (App Engine, Cloud Run, GKE)
- Custom trace spans
- Integration with OpenTelemetry

---

## Quick Start

### Automatic Tracing

**Cloud Run:**
```bash
# Tracing enabled by default
gcloud run deploy my-service --image=IMAGE_URL
```

**GKE with Istio:**
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    enableTracing: true
    defaultConfig:
      tracing:
        stackdriver: {}
```

### Manual Instrumentation

**Python:**
```python
from google.cloud import trace_v1

tracer = trace_v1.TraceServiceClient()
project_id = "my-project"

# Create trace
trace = {
    "project_id": project_id,
    "trace_id": "unique-trace-id",
    "spans": [{
        "span_id": "1",
        "name": "my-operation",
        "start_time": start_time,
        "end_time": end_time
    }]
}
```

---

## Best Practices

✓ Use consistent trace context  
✓ Sample traces appropriately (1-10%)  
✓ Monitor critical paths  
✓ Analyze latency patterns  
✓ Integrate with logging  

---

**Last Updated:** March 2026
