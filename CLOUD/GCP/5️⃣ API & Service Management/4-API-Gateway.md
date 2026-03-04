# API Gateway

Complete guide to Google Cloud API Gateway for managing, securing, and monitoring APIs.

---

## 📚 Overview

API Gateway enables you to create, secure, and monitor APIs for serverless workloads and containerized applications. It provides a unified entry point for your backend services.

**Key Features:**
- **API Management**: Create and manage APIs with OpenAPI specs
- **Security**: Authentication, authorization, API keys
- **Rate Limiting**: Control API usage
- **Monitoring**: Track API performance and usage
- **Serverless**: Fully managed, no infrastructure

---

## 🎯 API Gateway Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  API Gateway Flow                                                │
└─────────────────────────────────────────────────────────────────┘

Client Application
      │
      ├─ HTTPS Request
      │  GET /api/users
      │
      ▼
┌─────────────────────┐
│  API Gateway        │
│  • Authentication   │
│  • Rate limiting    │
│  • Validation       │
│  • Transformation   │
└──────────┬──────────┘
           │
           ├─ Route to backend
           │
           ▼
┌─────────────────────┐
│  Backend Service    │
│  • Cloud Functions  │
│  • Cloud Run        │
│  • App Engine       │
│  • Compute Engine   │
└─────────────────────┘

Benefits:
✓ Single entry point
✓ Centralized security
✓ Rate limiting
✓ Monitoring and logging
✓ API versioning
```

---

## 🚀 Setting Up API Gateway

### 1. Create OpenAPI Specification

```yaml
# openapi-spec.yaml
swagger: '2.0'
info:
  title: My API
  description: Sample API
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Greet a user
      operationId: hello
      x-google-backend:
        address: https://CLOUD_FUNCTION_URL
      responses:
        '200':
          description: A successful response
          schema:
            type: string
  /users:
    get:
      summary: List users
      operationId: listUsers
      x-google-backend:
        address: https://CLOUD_RUN_URL/users
      security:
        - api_key: []
      responses:
        '200':
          description: List of users
securityDefinitions:
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"
```

### 2. Deploy API Gateway

```bash
# Enable required APIs
gcloud services enable apigateway.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com

# Create API config
gcloud api-gateway api-configs create my-api-config \
  --api=my-api \
  --openapi-spec=openapi-spec.yaml \
  --project=PROJECT_ID \
  --backend-auth-service-account=BACKEND_SA@PROJECT_ID.iam.gserviceaccount.com

# Create API
gcloud api-gateway apis create my-api \
  --project=PROJECT_ID

# Create gateway
gcloud api-gateway gateways create my-gateway \
  --api=my-api \
  --api-config=my-api-config \
  --location=us-central1 \
  --project=PROJECT_ID

# Get gateway URL
gcloud api-gateway gateways describe my-gateway \
  --location=us-central1 \
  --project=PROJECT_ID \
  --format="value(defaultHostname)"

# Test API
curl https://my-gateway-HASH.uc.gateway.dev/hello
```

---

## 🔐 Security Features

### 1. API Key Authentication

```yaml
# openapi-spec.yaml with API key
securityDefinitions:
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"  # or "header"

paths:
  /protected:
    get:
      security:
        - api_key: []
      x-google-backend:
        address: https://backend-url
```

```bash
# Create API key
gcloud services api-keys create \
  --display-name="My API Key" \
  --api-target=service=my-api-HASH.apigateway.PROJECT_ID.cloud.goog

# Get API key value
gcloud services api-keys list

# Use API key
curl "https://my-gateway.uc.gateway.dev/protected?key=YOUR_API_KEY"
```

### 2. JWT Authentication

```yaml
# openapi-spec.yaml with JWT
securityDefinitions:
  firebase:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://securetoken.google.com/PROJECT_ID"
    x-google-jwks_uri: "https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com"
    x-google-audiences: "PROJECT_ID"

paths:
  /protected:
    get:
      security:
        - firebase: []
```

### 3. Service Account Authentication

```yaml
# Backend authentication with service account
x-google-backend:
  address: https://backend-url
  jwt_audience: https://backend-url
  # API Gateway will add JWT for backend authentication
```

---

## 📊 Rate Limiting and Quotas

### 1. Configure Rate Limits

```yaml
# openapi-spec.yaml with rate limiting
x-google-management:
  metrics:
    - name: "read-requests"
      valueType: INT64
      metricKind: DELTA
  quota:
    limits:
      - name: "read-limit"
        metric: "read-requests"
        unit: "1/min/{project}"
        values:
          STANDARD: 1000

paths:
  /data:
    get:
      x-google-quota:
        metricCosts:
          "read-requests": 1
```

### 2. Per-User Rate Limiting

```yaml
x-google-management:
  quota:
    limits:
      - name: "per-user-limit"
        metric: "api-requests"
        unit: "1/min/{user}"
        values:
          STANDARD: 100

securityDefinitions:
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"
```

---

## 📈 Monitoring and Logging

### 1. View API Metrics

```bash
# View API Gateway metrics
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND resource.labels.service="my-api-HASH.apigateway.PROJECT_ID.cloud.goog"'

# View latency metrics
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_latencies"'

# View error rates
gcloud monitoring time-series list \
  --filter='metric.type="serviceruntime.googleapis.com/api/request_count" AND metric.labels.response_code_class="5xx"'
```

### 2. Access Logs

```bash
# View API Gateway logs
gcloud logging read \
  'resource.type="api" AND resource.labels.service="my-api-HASH.apigateway.PROJECT_ID.cloud.goog"' \
  --limit=50 \
  --format=json

# View error logs
gcloud logging read \
  'resource.type="api" AND severity>=ERROR' \
  --limit=50

# View specific endpoint logs
gcloud logging read \
  'resource.type="api" AND httpRequest.requestUrl=~"/users"' \
  --limit=50
```

### 3. Create Dashboards

```python
from google.cloud import monitoring_dashboard_v1

def create_api_gateway_dashboard(project_id, api_name):
    """Create monitoring dashboard for API Gateway"""
    client = monitoring_dashboard_v1.DashboardsServiceClient()
    
    dashboard = monitoring_dashboard_v1.Dashboard(
        display_name=f"API Gateway - {api_name}",
        grid_layout=monitoring_dashboard_v1.GridLayout(
            widgets=[
                # Request count widget
                monitoring_dashboard_v1.Widget(
                    title="Request Count",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter=f'metric.type="serviceruntime.googleapis.com/api/request_count" AND resource.labels.service="{api_name}"'
                                    )
                                )
                            )
                        ]
                    )
                ),
                # Latency widget
                monitoring_dashboard_v1.Widget(
                    title="API Latency",
                    xy_chart=monitoring_dashboard_v1.XyChart(
                        data_sets=[
                            monitoring_dashboard_v1.XyChart.DataSet(
                                time_series_query=monitoring_dashboard_v1.TimeSeriesQuery(
                                    time_series_filter=monitoring_dashboard_v1.TimeSeriesFilter(
                                        filter=f'metric.type="serviceruntime.googleapis.com/api/request_latencies"'
                                    )
                                )
                            )
                        ]
                    )
                ),
            ]
        )
    )
    
    parent = f"projects/{project_id}"
    response = client.create_dashboard(parent=parent, dashboard=dashboard)
    print(f"Dashboard created: {response.name}")
```

---

## 🔧 Advanced Features

### 1. Request/Response Transformation

```yaml
# Transform request headers
x-google-backend:
  address: https://backend-url
  path_translation: APPEND_PATH_TO_ADDRESS
  # Add custom headers
  headers:
    - name: "X-Custom-Header"
      value: "custom-value"
```

### 2. CORS Configuration

```yaml
# Enable CORS
paths:
  /api:
    options:
      summary: CORS support
      responses:
        '200':
          description: CORS headers
          headers:
            Access-Control-Allow-Origin:
              type: string
            Access-Control-Allow-Methods:
              type: string
            Access-Control-Allow-Headers:
              type: string
```

### 3. Custom Domains

```bash
# Map custom domain to API Gateway
gcloud api-gateway gateways update my-gateway \
  --location=us-central1 \
  --display-name="My API Gateway" \
  --labels=environment=production

# Configure DNS
# Create A record pointing to gateway IP
# Or CNAME to gateway hostname
```

---

## ✅ Best Practices

### API Design
- [ ] Use OpenAPI 2.0 or 3.0 specifications
- [ ] Version your APIs (/v1, /v2)
- [ ] Use meaningful endpoint names
- [ ] Document all endpoints
- [ ] Implement proper error responses
- [ ] Use appropriate HTTP methods

### Security
- [ ] Always use HTTPS
- [ ] Implement authentication
- [ ] Use API keys for public APIs
- [ ] Use JWT for user authentication
- [ ] Implement rate limiting
- [ ] Validate all inputs
- [ ] Use service accounts for backend auth

### Performance
- [ ] Enable caching where appropriate
- [ ] Implement pagination for large datasets
- [ ] Use compression
- [ ] Monitor latency
- [ ] Optimize backend services
- [ ] Use CDN for static content

### Operations
- [ ] Monitor API usage and errors
- [ ] Set up alerts for anomalies
- [ ] Log all requests
- [ ] Regular security audits
- [ ] Document API changes
- [ ] Version control OpenAPI specs

---

## 🎓 Next Steps

1. Use [Service Usage API](./5-Service-Usage-API.md) for automation
2. Set up [API Monitoring](./6-API-Monitoring.md) for observability
3. Return to [Service APIs](./1-Service-APIs.md) for API fundamentals
4. Review [Service Quotas](./3-Service-Quotas.md) for limits

---

**Last Updated:** March 2026
**Version:** 2.0
