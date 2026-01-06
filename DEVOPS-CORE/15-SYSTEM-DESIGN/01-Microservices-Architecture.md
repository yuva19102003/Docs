# Microservices Architecture Pattern

## Overview
Microservices architecture is a design approach where an application is built as a collection of small, independent services that communicate over well-defined APIs. Each service is self-contained, focused on a specific business capability, and can be developed, deployed, and scaled independently.

---

## Problem Statement

### Monolithic Architecture Challenges
- **Tight Coupling** - All components are interconnected
- **Difficult Scaling** - Must scale entire application
- **Slow Deployment** - Small changes require full redeployment
- **Technology Lock-in** - Stuck with initial technology choices
- **Team Bottlenecks** - Multiple teams working on same codebase
- **Risk** - Single bug can bring down entire system

### When to Use Microservices
✅ Large, complex applications  
✅ Multiple teams working independently  
✅ Need to scale specific features  
✅ Different technology requirements  
✅ Frequent deployments required  
✅ Long-term maintainability important  

### When NOT to Use
❌ Small applications or MVPs  
❌ Limited team size (< 5 developers)  
❌ Simple CRUD applications  
❌ Tight latency requirements  
❌ Limited DevOps maturity  

---

## Architecture Diagram

### High-Level Microservices Architecture
```
                                    ┌─────────────────────────────────┐
                                    │         Load Balancer           │
                                    │         (NGINX/HAProxy)         │
                                    └────────────────┬────────────────┘
                                                     │
                    ┌────────────────────────────────┼────────────────────────────────┐
                    │                                │                                │
            ┌───────▼────────┐              ┌───────▼────────┐              ┌───────▼────────┐
            │  API Gateway 1 │              │  API Gateway 2 │              │  API Gateway 3 │
            │  (Kong/Traefik)│              │  (Kong/Traefik)│              │  (Kong/Traefik)│
            └───────┬────────┘              └───────┬────────┘              └───────┬────────┘
                    │                                │                                │
                    └────────────────────────────────┼────────────────────────────────┘
                                                     │
        ┌────────────────┬───────────────┬──────────┼──────────┬───────────────┬────────────────┐
        │                │               │          │          │               │                │
┌───────▼──────┐  ┌──────▼─────┐  ┌─────▼────┐  ┌─▼────┐  ┌──▼──────┐  ┌─────▼─────┐  ┌──────▼──────┐
│   User       │  │  Product   │  │  Order   │  │ Cart │  │ Payment │  │ Inventory │  │ Notification│
│   Service    │  │  Service   │  │  Service │  │ Svc  │  │ Service │  │  Service  │  │   Service   │
│              │  │            │  │          │  │      │  │         │  │           │  │             │
│  Port: 8001  │  │ Port: 8002 │  │Port: 8003│  │ 8004 │  │Port:8005│  │Port: 8006 │  │ Port: 8007  │
└───────┬──────┘  └──────┬─────┘  └─────┬────┘  └─┬────┘  └──┬──────┘  └─────┬─────┘  └──────┬──────┘
        │                │               │         │          │               │                │
        │                │               │         │          │               │                │
┌───────▼──────┐  ┌──────▼─────┐  ┌─────▼────┐  ┌─▼────┐  ┌──▼──────┐  ┌─────▼─────┐  ┌──────▼──────┐
│   User DB    │  │ Product DB │  │ Order DB │  │ Cart │  │ Payment │  │Inventory  │  │   Queue     │
│ (PostgreSQL) │  │(PostgreSQL)│  │(MongoDB) │  │Redis │  │   DB    │  │    DB     │  │  (Kafka)    │
└──────────────┘  └────────────┘  └──────────┘  └──────┘  └─────────┘  └───────────┘  └─────────────┘
        │                │               │         │          │               │                │
        └────────────────┴───────────────┴─────────┴──────────┴───────────────┴────────────────┘
                                                     │
                                          ┌──────────▼──────────┐
                                          │  Service Discovery  │
                                          │     (Consul)        │
                                          └──────────┬──────────┘
                                                     │
                                          ┌──────────▼──────────┐
                                          │  Monitoring Stack   │
                                          │  Prometheus/Grafana │
                                          └─────────────────────┘
```

### Service-to-Service Communication
```
┌──────────────┐                    ┌──────────────┐
│    Order     │   HTTP/REST API    │   Product    │
│   Service    │───────────────────►│   Service    │
│              │   Get Product Info │              │
└──────┬───────┘                    └──────────────┘
       │
       │ Publish Event
       │ "OrderCreated"
       │
       ▼
┌──────────────┐                    ┌──────────────┐
│    Kafka     │   Subscribe Event  │   Payment    │
│  Event Bus   │───────────────────►│   Service    │
│              │                    │              │
└──────────────┘                    └──────┬───────┘
                                           │
                                           │ Publish Event
                                           │ "PaymentProcessed"
                                           │
                                           ▼
                                    ┌──────────────┐
                                    │ Notification │
                                    │   Service    │
                                    │              │
                                    └──────────────┘
```

---

## Workflow Explanation

### Request Flow (Synchronous)
1. **Client Request** → Load balancer receives HTTPS request
2. **Route to Gateway** → Load balancer forwards to API Gateway
3. **Authentication** → API Gateway validates JWT token
4. **Service Discovery** → Gateway queries Consul for service location
5. **Route to Service** → Request forwarded to appropriate microservice
6. **Business Logic** → Service processes request
7. **Database Query** → Service queries its own database
8. **Inter-Service Call** → Service may call other services via REST/gRPC
9. **Response** → Service returns response through gateway
10. **Client Response** → Client receives JSON response

### Event Flow (Asynchronous)
1. **Event Trigger** → Service completes operation
2. **Publish Event** → Service publishes event to Kafka
3. **Event Storage** → Kafka stores event in topic
4. **Subscribers Notified** → Kafka notifies all subscribers
5. **Event Processing** → Each subscriber processes event independently
6. **Side Effects** → Subscribers update their own state/databases

---

## Key Components

### 1. API Gateway
**Purpose:** Single entry point for all client requests

**Responsibilities:**
- Request routing
- Authentication & authorization
- Rate limiting
- Request/response transformation
- API composition
- Protocol translation

**Tools:**
- **Kong** - Open-source API gateway with plugins
- **Traefik** - Cloud-native edge router
- **AWS API Gateway** - Managed service
- **NGINX** - Reverse proxy with API gateway capabilities

**Example Kong Configuration:**
```yaml
services:
  - name: user-service
    url: http://user-service:8001
    routes:
      - name: user-route
        paths:
          - /api/users
    plugins:
      - name: rate-limiting
        config:
          minute: 100
      - name: jwt
```

### 2. Service Discovery
**Purpose:** Dynamic service location and health checking

**Responsibilities:**
- Service registration
- Health monitoring
- Load balancing
- Service metadata storage

**Tools:**
- **Consul** - Service mesh with discovery
- **Eureka** - Netflix service discovery
- **etcd** - Distributed key-value store
- **Kubernetes DNS** - Built-in service discovery

**Example Consul Registration:**
```json
{
  "service": {
    "name": "user-service",
    "port": 8001,
    "check": {
      "http": "http://localhost:8001/health",
      "interval": "10s"
    }
  }
}
```

### 3. Message Broker
**Purpose:** Asynchronous communication between services

**Responsibilities:**
- Event publishing
- Event subscription
- Message persistence
- Guaranteed delivery

**Tools:**
- **Apache Kafka** - Distributed streaming platform
- **RabbitMQ** - Message broker
- **AWS SQS/SNS** - Managed messaging
- **NATS** - Cloud-native messaging

**Example Kafka Event:**
```json
{
  "eventType": "OrderCreated",
  "timestamp": "2026-01-05T10:30:00Z",
  "data": {
    "orderId": "ORD-12345",
    "userId": "USR-789",
    "items": [
      {"productId": "PROD-001", "quantity": 2}
    ],
    "totalAmount": 99.99
  }
}
```

### 4. Container Orchestration
**Purpose:** Deploy, scale, and manage containerized services

**Responsibilities:**
- Container scheduling
- Auto-scaling
- Self-healing
- Load balancing
- Rolling updates

**Tools:**
- **Kubernetes** - Industry standard orchestrator
- **Docker Swarm** - Docker-native orchestration
- **AWS ECS** - Managed container service

**Example Kubernetes Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: user-service:v1.2.0
        ports:
        - containerPort: 8001
        env:
        - name: DB_HOST
          value: user-db
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8001
          initialDelaySeconds: 30
          periodSeconds: 10
```

### 5. Monitoring & Observability
**Purpose:** Track service health and performance

**Responsibilities:**
- Metrics collection
- Log aggregation
- Distributed tracing
- Alerting

**Tools:**
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Jaeger** - Distributed tracing
- **ELK Stack** - Log aggregation

---

## Communication Patterns

### Synchronous Communication

#### REST API
```
GET /api/products/123
Authorization: Bearer <token>

Response:
{
  "id": "123",
  "name": "Product Name",
  "price": 29.99
}
```

#### gRPC
```protobuf
service ProductService {
  rpc GetProduct(ProductRequest) returns (ProductResponse);
}

message ProductRequest {
  string product_id = 1;
}

message ProductResponse {
  string id = 1;
  string name = 2;
  double price = 3;
}
```

### Asynchronous Communication

#### Event-Driven (Kafka)
```javascript
// Producer
await producer.send({
  topic: 'order-events',
  messages: [{
    key: orderId,
    value: JSON.stringify({
      eventType: 'OrderCreated',
      orderId: orderId,
      userId: userId,
      timestamp: new Date().toISOString()
    })
  }]
});

// Consumer
consumer.on('message', async (message) => {
  const event = JSON.parse(message.value);
  if (event.eventType === 'OrderCreated') {
    await processOrder(event);
  }
});
```

---

## Data Management

### Database Per Service Pattern
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    User      │     │   Product    │     │    Order     │
│   Service    │     │   Service    │     │   Service    │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       │ Owns               │ Owns               │ Owns
       │                    │                    │
┌──────▼───────┐     ┌──────▼───────┐     ┌──────▼───────┐
│   User DB    │     │  Product DB  │     │   Order DB   │
│ (PostgreSQL) │     │ (PostgreSQL) │     │  (MongoDB)   │
└──────────────┘     └──────────────┘     └──────────────┘
```

**Benefits:**
- Loose coupling
- Independent scaling
- Technology flexibility
- Fault isolation

**Challenges:**
- Distributed transactions
- Data consistency
- Complex queries across services

### Saga Pattern (Distributed Transactions)
```
Order Service → Payment Service → Inventory Service → Notification Service
     │               │                  │                    │
     │ Create        │ Charge           │ Reserve            │ Send
     │ Order         │ Payment          │ Items              │ Email
     │               │                  │                    │
     ▼               ▼                  ▼                    ▼
   Success         Success            Success              Success
     │               │                  │                    │
     └───────────────┴──────────────────┴────────────────────┘
                            │
                    ┌───────▼────────┐
                    │ Transaction    │
                    │   Complete     │
                    └────────────────┘

If any step fails:
     │               │                  │                    │
     ▼               ▼                  ▼                    ▼
   Success         Success            FAILED!              Skipped
     │               │                  │                    │
     │ Compensate    │ Compensate       │                    │
     │ (Cancel)      │ (Refund)         │                    │
     └───────────────┴──────────────────┘
```

---

## Deployment Strategies

### Blue-Green Deployment
```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer                        │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────▼─────┐          ┌─────▼────┐
    │  Blue    │          │  Green   │
    │ (v1.0)   │          │ (v2.0)   │
    │ Active   │          │ Standby  │
    └──────────┘          └──────────┘
         │                       │
         │ Switch Traffic        │
         └───────────────────────┘
```

### Canary Deployment
```
┌─────────────────────────────────────────────────────────┐
│              Load Balancer (95% / 5%)                   │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────▼─────┐          ┌─────▼────┐
    │ Stable   │          │  Canary  │
    │ (v1.0)   │          │  (v2.0)  │
    │ 95%      │          │   5%     │
    └──────────┘          └──────────┘
```

---

## Best Practices

### Design Principles
✅ **Single Responsibility** - One service, one business capability  
✅ **Loose Coupling** - Minimize dependencies between services  
✅ **High Cohesion** - Related functionality in same service  
✅ **Autonomous** - Services can be deployed independently  
✅ **Observable** - Comprehensive logging and monitoring  
✅ **Resilient** - Handle failures gracefully  

### Service Boundaries
- Align with business capabilities
- Consider team structure (Conway's Law)
- Avoid chatty communication
- Design for failure

### API Design
- Use RESTful principles
- Version your APIs
- Document with OpenAPI/Swagger
- Implement backward compatibility

### Security
- Implement authentication at gateway
- Use service-to-service authentication
- Encrypt data in transit (TLS)
- Implement rate limiting
- Regular security audits

---

## Pros & Cons

### Advantages
✅ **Independent Deployment** - Deploy services separately  
✅ **Technology Flexibility** - Use best tool for each service  
✅ **Scalability** - Scale services independently  
✅ **Fault Isolation** - Failures don't cascade  
✅ **Team Autonomy** - Teams own services end-to-end  
✅ **Faster Development** - Parallel development  

### Disadvantages
❌ **Complexity** - Distributed system challenges  
❌ **Network Latency** - Inter-service communication overhead  
❌ **Data Consistency** - Eventual consistency challenges  
❌ **Testing** - Integration testing is complex  
❌ **Operational Overhead** - More services to monitor  
❌ **DevOps Requirements** - Need mature CI/CD  

---

## Real-World Examples

### Netflix
- 700+ microservices
- Handles 200+ million subscribers
- Uses Eureka for service discovery
- Hystrix for circuit breaking

### Amazon
- Thousands of microservices
- Each team owns services
- Two-pizza team rule
- Service-oriented architecture

### Uber
- 2,200+ microservices
- Real-time processing
- Event-driven architecture
- Polyglot persistence

---

## Migration Strategy

### From Monolith to Microservices

#### Step 1: Identify Boundaries
- Analyze business capabilities
- Map domain models
- Identify bounded contexts

#### Step 2: Strangler Pattern
```
┌─────────────────────────────────────┐
│          Monolith                   │
│  ┌──────────┐  ┌──────────┐        │
│  │  Users   │  │ Products │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │  Orders  │  │ Payments │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
              │
              │ Extract Service
              ▼
┌─────────────────────────────────────┐
│          Monolith                   │
│  ┌──────────┐                       │
│  │  Users   │                       │
│  └──────────┘                       │
│  ┌──────────┐  ┌──────────┐        │
│  │  Orders  │  │ Payments │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
              │
              │ API Call
              ▼
        ┌──────────┐
        │ Product  │
        │ Service  │
        └──────────┘
```

#### Step 3: Implement API Gateway
#### Step 4: Extract Services Incrementally
#### Step 5: Migrate Data
#### Step 6: Decommission Monolith Components

---

## Related Patterns
- [Event-Driven Architecture](02-Event-Driven-Architecture.md)
- [API Gateway Pattern](03-API-Gateway-Pattern.md)
- [Service Mesh Pattern](04-Service-Mesh-Pattern.md)
- [Circuit Breaker Pattern](08-Circuit-Breaker.md)
- [CQRS Pattern](06-CQRS-Pattern.md)

---

## Additional Resources

### Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kong API Gateway](https://docs.konghq.com/)
- [Consul Service Discovery](https://www.consul.io/docs)

### Books
- "Building Microservices" by Sam Newman
- "Microservices Patterns" by Chris Richardson

### Tools
- [Kubernetes](https://kubernetes.io/)
- [Docker](https://www.docker.com/)
- [Istio](https://istio.io/)
- [Prometheus](https://prometheus.io/)

---

**Last Updated:** January 5, 2026  
**Pattern Complexity:** High  
**Recommended For:** Large-scale applications with multiple teams
