# Deployment Strategies

**Essential deployment patterns for zero-downtime releases and safe production updates**

---

## Overview

A deployment strategy is a plan for how to release and update software carefully to avoid problems for users. Choosing the right strategy depends on your application requirements, downtime tolerance, and rollback needs.

**Video Tutorial:** [Deployment Strategies Explained](https://youtu.be/AsXNDf5-cTs)

---

## What is Deployment? 🚀

**Deployment** means releasing or upgrading software so that users can access it. In modern DevOps, deployments should be:
- **Automated** - Minimal manual intervention
- **Repeatable** - Consistent across environments
- **Safe** - Minimize risk to production
- **Fast** - Quick rollout and rollback

---

## Deployment Strategies Overview

### Quick Comparison

| Strategy | Downtime | Rollback Speed | Resource Cost | Complexity | Risk |
|----------|----------|----------------|---------------|------------|------|
| **Recreate** | Yes | Fast | Low | Low | High |
| **Rolling Update** | No | Medium | Low | Low | Medium |
| **Blue-Green** | No | Instant | High (2x) | Medium | Low |
| **Canary** | No | Fast | Medium | High | Low |
| **A/B Testing** | No | Fast | Medium | High | Low |

---

## 1. Recreate Strategy 🔁

### Definition
All old instances are terminated at once, then new instances are created with the updated version.

### Architecture Diagram
```
Before Deployment:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v1.0    │  │ v1.0    │  │ v1.0    │
│ Running │  │ Running │  │ Running │
└─────────┘  └─────────┘  └─────────┘

During Deployment (Downtime):
┌─────────┐  ┌─────────┐  ┌─────────┐
│ Stopped │  │ Stopped │  │ Stopped │
└─────────┘  └─────────┘  └─────────┘

After Deployment:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v2.0    │  │ v2.0    │  │ v2.0    │
│ Running │  │ Running │  │ Running │
└─────────┘  └─────────┘  └─────────┘
```

![Recreate Deployment Strategy](Untitled%201.png)

### Workflow
1. **Stop all v1.0 instances** - Application becomes unavailable
2. **Wait for cleanup** - Ensure all connections closed
3. **Deploy v2.0 instances** - Start new version
4. **Health checks pass** - Application available again

### Pros
✅ Simple and straightforward  
✅ Ensures all instances run the same version  
✅ No version compatibility issues  
✅ Clean state transition  

### Cons
❌ Downtime during transition  
❌ All users affected simultaneously  
❌ No gradual rollout  
❌ Risky for critical applications  

### When to Use
- Development/staging environments
- Applications with short startup time
- Stateless applications
- Maintenance windows acceptable
- Non-critical services

### Kubernetes Implementation
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  strategy:
    type: Recreate  # All pods terminated before new ones created
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

**Deploy:**
```bash
kubectl apply -f recreate-deployment.yaml
kubectl rollout status deployment/myapp-deployment
```

---

## 2. Rolling Update Strategy 🔄

### Definition
New instances are gradually created while old instances are gradually terminated, ensuring continuous availability.

### Architecture Diagram
```
Initial State:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v1.0    │  │ v1.0    │  │ v1.0    │
│ Running │  │ Running │  │ Running │
└─────────┘  └─────────┘  └─────────┘

Step 1:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v1.0    │  │ v1.0    │  │ v2.0    │
│ Running │  │ Running │  │ Starting│
└─────────┘  └─────────┘  └─────────┘

Step 2:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v1.0    │  │ v2.0    │  │ v2.0    │
│ Running │  │ Running │  │ Running │
└─────────┘  └─────────┘  └─────────┘

Final State:
┌─────────┐  ┌─────────┐  ┌─────────┐
│ v2.0    │  │ v2.0    │  │ v2.0    │
│ Running │  │ Running │  │ Running │
└─────────┘  └─────────┘  └─────────┘
```

![Rolling Update Strategy](Untitled%202.png)

### Workflow
1. **Create new v2.0 instance** - Start one new pod
2. **Health check passes** - Verify new pod is healthy
3. **Terminate one v1.0 instance** - Remove old pod
4. **Repeat** - Continue until all pods updated

### Pros
✅ Zero downtime deployment  
✅ Easy to roll back  
✅ Gradual transition  
✅ Default Kubernetes strategy  
✅ Resource efficient  

### Cons
❌ Longer deployment time  
❌ Both versions running simultaneously  
❌ Requires version compatibility  
❌ Complex state management  

### When to Use
- Production applications requiring zero downtime
- Applications that can handle multiple versions
- Standard web applications
- Microservices
- Most common use case

### Kubernetes Implementation
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: myapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Max pods unavailable during update
      maxSurge: 1        # Max extra pods during update
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Deploy and Monitor:**
```bash
# Apply deployment
kubectl apply -f rolling-update-deployment.yaml

# Watch rollout
kubectl rollout status deployment/myapp-deployment

# Pause rollout if issues detected
kubectl rollout pause deployment/myapp-deployment

# Resume rollout
kubectl rollout resume deployment/myapp-deployment

# Rollback to previous version
kubectl rollout undo deployment/myapp-deployment
```

---

## 3. Blue-Green Deployment 🟦🟩

### Definition
Two identical production environments (Blue and Green) run simultaneously. Only one is active at any time. Traffic is switched instantly from one to the other.

### Architecture Diagram
```
Initial State (Blue Active):
                    ┌──────────────┐
                    │ Load Balancer│
                    │  (→ Blue)    │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
    ┌───────┐          ┌───────┐          ┌───────┐
    │ Blue  │          │ Blue  │          │ Blue  │
    │ v1.0  │          │ v1.0  │          │ v1.0  │
    │Active │          │Active │          │Active │
    └───────┘          └───────┘          └───────┘

    ┌───────┐          ┌───────┐          ┌───────┐
    │ Green │          │ Green │          │ Green │
    │ v2.0  │          │ v2.0  │          │ v2.0  │
    │Standby│          │Standby│          │Standby│
    └───────┘          └───────┘          └───────┘

After Switch (Green Active):
                    ┌──────────────┐
                    │ Load Balancer│
                    │  (→ Green)   │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
    ┌───────┐          ┌───────┐          ┌───────┐
    │ Blue  │          │ Blue  │          │ Blue  │
    │ v1.0  │          │ v1.0  │          │ v1.0  │
    │Standby│          │Standby│          │Standby│
    └───────┘          └───────┘          └───────┘

    ┌───────┐          ┌───────┐          ┌───────┐
    │ Green │          │ Green │          │ Green │
    │ v2.0  │          │ v2.0  │          │ v2.0  │
    │Active │          │Active │          │Active │
    └───────┘          └───────┘          └───────┘
```

![Blue-Green Deployment](Untitled%203.png)

### Workflow
1. **Blue environment active** - Serving production traffic (v1.0)
2. **Deploy to Green** - Update Green environment to v2.0
3. **Test Green** - Verify Green environment works correctly
4. **Switch traffic** - Update load balancer to point to Green
5. **Monitor** - Watch for issues
6. **Keep Blue** - Blue remains as instant rollback option

### Pros
✅ Zero downtime deployment  
✅ Instant rollback (switch back to Blue)  
✅ Full testing before switch  
✅ Clean separation of versions  
✅ Easy to understand  

### Cons
❌ Requires double resources (2x cost)  
❌ Database migrations complex  
❌ Stateful applications challenging  
❌ Need to maintain two environments  

### When to Use
- Critical production applications
- Need instant rollback capability
- Can afford double resources
- Stateless applications
- High-risk deployments

### Kubernetes Implementation
```yaml
# Service (switches between blue and green)
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer

---

# Blue Deployment (v1.0)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0
        ports:
        - containerPort: 8080

---

# Green Deployment (v2.0)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0
        ports:
        - containerPort: 8080
```

**Switch Traffic:**
```bash
# Deploy both environments
kubectl apply -f blue-green-deployment.yaml

# Test green environment
kubectl port-forward deployment/myapp-green 8080:8080

# Switch to green
kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback to blue if needed
kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

---

## 4. Canary Deployment 🐤

### Definition
New version is rolled out to a small subset of users first. If successful, gradually increase traffic to new version.

### Architecture Diagram
```
Phase 1 (10% Canary):
                    ┌──────────────┐
                    │ Load Balancer│
                    └──────┬───────┘
                           │
                    ┌──────┴──────┐
                    │             │
                 90%│             │10%
                    │             │
        ┌───────────▼──┐      ┌──▼──────────┐
        │   Stable     │      │   Canary    │
        │   v1.0       │      │   v2.0      │
        │   (9 pods)   │      │   (1 pod)   │
        └──────────────┘      └─────────────┘

Phase 2 (50% Canary):
                    ┌──────────────┐
                    │ Load Balancer│
                    └──────┬───────┘
                           │
                    ┌──────┴──────┐
                    │             │
                 50%│             │50%
                    │             │
        ┌───────────▼──┐      ┌──▼──────────┐
        │   Stable     │      │   Canary    │
        │   v1.0       │      │   v2.0      │
        │   (5 pods)   │      │   (5 pods)  │
        └──────────────┘      └─────────────┘

Phase 3 (100% Canary):
                    ┌──────────────┐
                    │ Load Balancer│
                    └──────┬───────┘
                           │
                        100│
                           │
                    ┌──────▼──────┐
                    │   Canary    │
                    │   v2.0      │
                    │   (10 pods) │
                    └─────────────┘
```

![Canary Deployment Phase 1](Untitled%204.png)
![Canary Deployment Phase 2](Untitled%205.png)

### Workflow
1. **Deploy canary** - Release v2.0 to 10% of users
2. **Monitor metrics** - Watch error rates, latency, user feedback
3. **Increase traffic** - If healthy, increase to 25%, then 50%
4. **Full rollout** - Eventually 100% on v2.0
5. **Rollback if needed** - Revert to v1.0 if issues detected

### Pros
✅ Risk mitigation with small user subset  
✅ Real-world testing before full rollout  
✅ Quick issue detection  
✅ Gradual rollout control  
✅ Easy rollback  

### Cons
❌ Complex traffic routing  
❌ Requires monitoring infrastructure  
❌ Longer deployment time  
❌ Need service mesh or ingress controller  

### When to Use
- High-risk feature releases
- Testing new features with real users
- A/B testing scenarios
- Gradual rollout preferred
- Have monitoring infrastructure

### Kubernetes Implementation (with Istio)
```yaml
# VirtualService for traffic splitting
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp.example.com
  http:
  - match:
    - headers:
        user-type:
          exact: beta-tester
    route:
    - destination:
        host: myapp
        subset: v2
      weight: 100
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90  # 90% to stable
    - destination:
        host: myapp
        subset: v2
      weight: 10  # 10% to canary

---

# DestinationRule
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

**Gradual Rollout:**
```bash
# Phase 1: 10% canary
kubectl apply -f canary-10-percent.yaml

# Monitor metrics
kubectl logs -f deployment/myapp-v2

# Phase 2: 50% canary
kubectl apply -f canary-50-percent.yaml

# Phase 3: 100% canary
kubectl apply -f canary-100-percent.yaml

# Rollback if needed
kubectl apply -f canary-0-percent.yaml
```

---

## 5. A/B Testing Strategy 🅰️🅱️

### Definition
Multiple versions deployed simultaneously. Different users see different versions based on criteria (location, user type, etc.) to compare performance.

### Architecture Diagram
```
                    ┌──────────────┐
                    │ Load Balancer│
                    │  + Routing   │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        │ US Users         │ EU Users         │ Beta Users
        │                  │                  │
        ▼                  ▼                  ▼
    ┌───────┐          ┌───────┐          ┌───────┐
    │Version│          │Version│          │Version│
    │  A    │          │  B    │          │  C    │
    │ v1.0  │          │ v2.0  │          │ v3.0  │
    └───────┘          └───────┘          └───────┘
        │                  │                  │
        └──────────────────┴──────────────────┘
                           │
                    ┌──────▼───────┐
                    │   Analytics  │
                    │   Compare    │
                    │   Results    │
                    └──────────────┘
```

![A/B Testing Strategy](Untitled%206.png)

### Workflow
1. **Define criteria** - User segment, location, device type
2. **Deploy versions** - A and B running simultaneously
3. **Route traffic** - Based on criteria
4. **Collect metrics** - Conversion rate, engagement, performance
5. **Analyze results** - Determine winning version
6. **Full rollout** - Deploy winning version to all users

### Pros
✅ Data-driven decision making  
✅ Compare versions in real-world  
✅ Measure user behavior  
✅ Test multiple features  
✅ Optimize conversion rates  

### Cons
❌ Complex routing logic  
❌ Requires analytics infrastructure  
❌ Multiple versions to maintain  
❌ Longer testing period  

### When to Use
- Testing new features
- UI/UX improvements
- Performance optimizations
- Marketing campaigns
- Conversion rate optimization

### Implementation (Application Level)
```python
# Python Flask example
from flask import Flask, request
import random

app = Flask(__name__)

def get_user_version(user_id):
    """Determine which version user should see"""
    # Consistent hashing based on user_id
    if hash(user_id) % 2 == 0:
        return 'A'
    else:
        return 'B'

@app.route('/feature')
def feature():
    user_id = request.headers.get('User-ID')
    version = get_user_version(user_id)
    
    if version == 'A':
        # Version A code
        return render_template('feature_a.html')
    else:
        # Version B code
        return render_template('feature_b.html')
```

### Kubernetes Implementation (with Istio)
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp-ab-test
spec:
  hosts:
  - myapp.example.com
  http:
  - match:
    - headers:
        user-location:
          exact: "US"
    route:
    - destination:
        host: myapp
        subset: version-a
  - match:
    - headers:
        user-location:
          exact: "EU"
    route:
    - destination:
        host: myapp
        subset: version-b
  - route:  # Default
    - destination:
        host: myapp
        subset: version-a
      weight: 50
    - destination:
        host: myapp
        subset: version-b
      weight: 50
```

---

## Decision Matrix

### Choose Based on Requirements

| Requirement | Recommended Strategy |
|-------------|---------------------|
| Zero downtime required | Rolling Update, Blue-Green, Canary |
| Instant rollback needed | Blue-Green |
| Limited resources | Rolling Update, Recreate |
| High-risk deployment | Canary, Blue-Green |
| Testing with real users | Canary, A/B Testing |
| Simple deployment | Recreate, Rolling Update |
| Downtime acceptable | Recreate |
| Need metrics comparison | A/B Testing |
| Gradual rollout | Canary, Rolling Update |
| Cost-sensitive | Rolling Update, Recreate |

---

## Best Practices

### General Guidelines
✅ **Automate deployments** - Use CI/CD pipelines  
✅ **Health checks** - Implement liveness and readiness probes  
✅ **Monitoring** - Track metrics during deployment  
✅ **Rollback plan** - Always have a rollback strategy  
✅ **Test thoroughly** - Test in staging before production  
✅ **Version control** - Tag releases properly  
✅ **Documentation** - Document deployment procedures  

### Kubernetes Specific
✅ **Use namespaces** - Separate environments  
✅ **Resource limits** - Set CPU/memory limits  
✅ **ConfigMaps/Secrets** - Externalize configuration  
✅ **Service mesh** - Use Istio/Linkerd for advanced routing  
✅ **GitOps** - Use ArgoCD/Flux for declarative deployments  

### Monitoring
✅ **Error rates** - Track 4xx/5xx errors  
✅ **Latency** - Monitor response times  
✅ **Throughput** - Requests per second  
✅ **Resource usage** - CPU/memory consumption  
✅ **User metrics** - Conversion rates, engagement  

---

## Tools & Technologies

### Kubernetes Native
- **kubectl** - Command-line tool
- **Helm** - Package manager
- **Kustomize** - Configuration management

### Service Mesh
- **Istio** - Advanced traffic management
- **Linkerd** - Lightweight service mesh
- **Consul** - Service discovery and mesh

### GitOps
- **ArgoCD** - Declarative GitOps
- **Flux** - GitOps toolkit
- **Jenkins X** - CI/CD for Kubernetes

### Monitoring
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Datadog** - Full-stack monitoring
- **New Relic** - APM

---

## Related Topics
- [CI/CD Pipelines](../CICD/README.md)
- [Kubernetes](../CONTAINERIZATION/)
- [Monitoring & Observability](../OBSERVABILITY/README.md)
- [System Design Patterns](../SYSTEM-DESIGN/README.md)

---

## Additional Resources

### Official Documentation
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Istio Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)
- [ArgoCD Rollouts](https://argoproj.github.io/argo-rollouts/)

### Video Tutorials
- [Deployment Strategies Explained](https://youtu.be/AsXNDf5-cTs)

### Tools
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/) - Progressive delivery
- [Flagger](https://flagger.app/) - Progressive delivery operator
- [Spinnaker](https://spinnaker.io/) - Multi-cloud deployment

---

