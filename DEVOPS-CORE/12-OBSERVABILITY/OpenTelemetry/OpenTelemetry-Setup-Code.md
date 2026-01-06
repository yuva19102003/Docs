# OpenTelemetry Setup Code

This guide provides setup code examples for OpenTelemetry instrumentation in Python, Node.js, and Go applications.

---

## Python Setup

### Installation

```bash
pip install opentelemetry-api
pip install opentelemetry-sdk
pip install opentelemetry-instrumentation
pip install opentelemetry-exporter-otlp
```

### Basic Setup

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource

# Configure resource
resource = Resource(attributes={
    "service.name": "my-python-service",
    "service.version": "1.0.0"
})

# Set up tracer provider
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer_provider = trace.get_tracer_provider()

# Configure OTLP exporter
otlp_exporter = OTLPSpanExporter(
    endpoint="http://localhost:4317",
    insecure=True
)

# Add span processor
tracer_provider.add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

# Get tracer
tracer = trace.get_tracer(__name__)
```

### Flask Application Example

```python
from flask import Flask
from opentelemetry.instrumentation.flask import FlaskInstrumentor

app = Flask(__name__)

# Auto-instrument Flask
FlaskInstrumentor().instrument_app(app)

@app.route('/')
def hello():
    with tracer.start_as_current_span("hello-span"):
        return "Hello, World!"

@app.route('/user/<username>')
def get_user(username):
    with tracer.start_as_current_span("get-user") as span:
        span.set_attribute("user.name", username)
        # Your logic here
        return f"User: {username}"

if __name__ == '__main__':
    app.run(debug=True)
```

### Manual Instrumentation

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

def process_data(data):
    with tracer.start_as_current_span("process-data") as span:
        span.set_attribute("data.size", len(data))
        
        # Add event
        span.add_event("Processing started")
        
        try:
            result = data.upper()
            span.set_attribute("processing.status", "success")
            return result
        except Exception as e:
            span.set_attribute("processing.status", "error")
            span.record_exception(e)
            raise
```

---

## Node.js Setup

### Installation

```bash
npm install @opentelemetry/api
npm install @opentelemetry/sdk-node
npm install @opentelemetry/auto-instrumentations-node
npm install @opentelemetry/exporter-trace-otlp-grpc
```

### Basic Setup (tracing.js)

```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');

// Configure OTLP exporter
const traceExporter = new OTLPTraceExporter({
  url: 'http://localhost:4317',
});

// Configure SDK
const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'my-nodejs-service',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter,
  instrumentations: [getNodeAutoInstrumentations()],
});

// Start SDK
sdk.start();

// Graceful shutdown
process.on('SIGTERM', () => {
  sdk.shutdown()
    .then(() => console.log('Tracing terminated'))
    .catch((error) => console.log('Error terminating tracing', error))
    .finally(() => process.exit(0));
});

module.exports = sdk;
```

### Express Application Example

```javascript
// Import tracing first
require('./tracing');

const express = require('express');
const { trace } = require('@opentelemetry/api');

const app = express();
const tracer = trace.getTracer('express-app');

app.get('/', (req, res) => {
  const span = tracer.startSpan('home-route');
  span.setAttribute('http.route', '/');
  
  res.send('Hello, World!');
  
  span.end();
});

app.get('/user/:id', async (req, res) => {
  const span = tracer.startSpan('get-user');
  span.setAttribute('user.id', req.params.id);
  
  try {
    // Simulate async operation
    await new Promise(resolve => setTimeout(resolve, 100));
    
    span.addEvent('User fetched successfully');
    res.json({ id: req.params.id, name: 'John Doe' });
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: 2, message: error.message });
    res.status(500).send('Error');
  } finally {
    span.end();
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Manual Instrumentation

```javascript
const { trace, context } = require('@opentelemetry/api');

const tracer = trace.getTracer('manual-instrumentation');

async function processOrder(orderId) {
  const span = tracer.startSpan('process-order');
  
  return context.with(trace.setSpan(context.active(), span), async () => {
    span.setAttribute('order.id', orderId);
    
    try {
      // Create child span
      const childSpan = tracer.startSpan('validate-order', {
        parent: span,
      });
      
      childSpan.addEvent('Validation started');
      // Validation logic
      childSpan.end();
      
      span.setStatus({ code: 1 }); // OK
      return { success: true };
    } catch (error) {
      span.recordException(error);
      span.setStatus({ code: 2, message: error.message }); // ERROR
      throw error;
    } finally {
      span.end();
    }
  });
}
```

---

## Go Setup

### Installation

```bash
go get go.opentelemetry.io/otel
go get go.opentelemetry.io/otel/sdk
go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc
go get go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp
```

### Basic Setup

```go
package main

import (
    "context"
    "log"
    "time"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/resource"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.17.0"
)

func initTracer() (*sdktrace.TracerProvider, error) {
    ctx := context.Background()

    // Create OTLP exporter
    exporter, err := otlptracegrpc.New(ctx,
        otlptracegrpc.WithEndpoint("localhost:4317"),
        otlptracegrpc.WithInsecure(),
    )
    if err != nil {
        return nil, err
    }

    // Create resource
    res, err := resource.New(ctx,
        resource.WithAttributes(
            semconv.ServiceName("my-go-service"),
            semconv.ServiceVersion("1.0.0"),
        ),
    )
    if err != nil {
        return nil, err
    }

    // Create tracer provider
    tp := sdktrace.NewTracerProvider(
        sdktrace.WithBatcher(exporter),
        sdktrace.WithResource(res),
    )

    otel.SetTracerProvider(tp)
    return tp, nil
}
```

### HTTP Server Example

```go
package main

import (
    "context"
    "fmt"
    "log"
    "net/http"
    "time"

    "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("http-server")

func main() {
    // Initialize tracer
    tp, err := initTracer()
    if err != nil {
        log.Fatal(err)
    }
    defer func() {
        if err := tp.Shutdown(context.Background()); err != nil {
            log.Printf("Error shutting down tracer provider: %v", err)
        }
    }()

    // Create HTTP handler with auto-instrumentation
    handler := http.NewServeMux()
    handler.HandleFunc("/", homeHandler)
    handler.HandleFunc("/user/", userHandler)

    // Wrap handler with OpenTelemetry middleware
    wrappedHandler := otelhttp.NewHandler(handler, "server")

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", wrappedHandler))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    span := trace.SpanFromContext(ctx)
    span.SetAttributes(attribute.String("http.route", "/"))

    fmt.Fprintf(w, "Hello, World!")
}

func userHandler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    
    // Create custom span
    ctx, span := tracer.Start(ctx, "get-user")
    defer span.End()

    userID := r.URL.Path[len("/user/"):]
    span.SetAttributes(attribute.String("user.id", userID))

    // Simulate processing
    processUser(ctx, userID)

    fmt.Fprintf(w, "User: %s", userID)
}

func processUser(ctx context.Context, userID string) {
    _, span := tracer.Start(ctx, "process-user")
    defer span.End()

    span.AddEvent("Processing started")
    time.Sleep(50 * time.Millisecond)
    span.AddEvent("Processing completed")
}
```

### Manual Instrumentation

```go
package main

import (
    "context"
    "errors"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("manual-instrumentation")

func ProcessOrder(ctx context.Context, orderID string) error {
    ctx, span := tracer.Start(ctx, "process-order")
    defer span.End()

    span.SetAttributes(
        attribute.String("order.id", orderID),
        attribute.String("order.status", "processing"),
    )

    // Validate order
    if err := validateOrder(ctx, orderID); err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, err.Error())
        return err
    }

    // Process payment
    if err := processPayment(ctx, orderID); err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, err.Error())
        return err
    }

    span.SetStatus(codes.Ok, "Order processed successfully")
    return nil
}

func validateOrder(ctx context.Context, orderID string) error {
    _, span := tracer.Start(ctx, "validate-order")
    defer span.End()

    span.AddEvent("Validation started")
    
    // Validation logic
    if orderID == "" {
        err := errors.New("invalid order ID")
        span.RecordError(err)
        return err
    }

    span.AddEvent("Validation completed")
    return nil
}

func processPayment(ctx context.Context, orderID string) error {
    _, span := tracer.Start(ctx, "process-payment")
    defer span.End()

    span.SetAttributes(attribute.String("payment.method", "credit_card"))
    
    // Payment processing logic
    span.AddEvent("Payment processed")
    return nil
}
```

---

## Docker Compose Setup

### Complete Observability Stack

```yaml
version: '3.8'

services:
  # OpenTelemetry Collector
  otel-collector:
    image: otel/opentelemetry-collector:latest
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    ports:
      - "4317:4317"   # OTLP gRPC receiver
      - "4318:4318"   # OTLP HTTP receiver
      - "8888:8888"   # Prometheus metrics
      - "8889:8889"   # Prometheus exporter

  # Jaeger for traces
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"  # Jaeger UI
      - "14250:14250"  # Jaeger gRPC

  # Prometheus for metrics
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### OpenTelemetry Collector Config

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024

exporters:
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true
  
  prometheus:
    endpoint: "0.0.0.0:8889"
  
  logging:
    loglevel: debug

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger, logging]
    
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus, logging]
```

---

## Environment Variables

### Common Configuration

```bash
# Exporter endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Service name
export OTEL_SERVICE_NAME="my-service"

# Resource attributes
export OTEL_RESOURCE_ATTRIBUTES="service.version=1.0.0,deployment.environment=production"

# Trace sampling
export OTEL_TRACES_SAMPLER="parentbased_traceidratio"
export OTEL_TRACES_SAMPLER_ARG="0.5"
```

---

## Best Practices

1. **Always set service name and version** for proper identification
2. **Use semantic conventions** for attribute naming
3. **Implement proper error handling** and record exceptions
4. **Use batch processors** for better performance
5. **Add meaningful events** to spans for debugging
6. **Set appropriate sampling rates** for production
7. **Use context propagation** for distributed tracing
8. **Monitor collector health** and resource usage

---

## Troubleshooting

### Common Issues

**Connection refused to collector:**
```bash
# Check if collector is running
curl http://localhost:4317

# Verify endpoint configuration
echo $OTEL_EXPORTER_OTLP_ENDPOINT
```

**No traces appearing:**
- Check sampling configuration
- Verify exporter is properly configured
- Check collector logs for errors
- Ensure spans are being ended properly

**High memory usage:**
- Adjust batch processor settings
- Reduce sampling rate
- Check for span leaks (spans not ended)

---

## Additional Resources

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Python SDK](https://opentelemetry-python.readthedocs.io/)
- [Node.js SDK](https://github.com/open-telemetry/opentelemetry-js)
- [Go SDK](https://github.com/open-telemetry/opentelemetry-go)
- [Semantic Conventions](https://opentelemetry.io/docs/reference/specification/trace/semantic_conventions/)
