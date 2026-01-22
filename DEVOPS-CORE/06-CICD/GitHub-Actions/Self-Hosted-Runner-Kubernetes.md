# Self-Hosted GitHub Actions Runner - Kubernetes Setup

Complete guide to deploying and managing GitHub Actions runners on Kubernetes with auto-scaling and advanced configurations.

## Kubernetes Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│              Kubernetes-Based Runner Architecture                       │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                         GitHub                                │
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   Workflow   │────────>│  Job Queue   │                  │
│  │   Trigger    │         │              │                  │
│  └──────────────┘         └──────┬───────┘                  │
└─────────────────────────────────┼───────────────────────────┘
                                  │
                                  │ HTTPS/Webhook
                                  │
┌─────────────────────────────────┼───────────────────────────┐
│              Kubernetes Cluster │                           │
│                                 ▼                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      Actions Runner Controller (ARC)                 │  │
│  │                                                       │  │
│  │  • Watches GitHub for jobs                          │  │
│  │  • Manages runner lifecycle                         │  │
│  │  • Handles auto-scaling                             │  │
│  └────────────────────────┬─────────────────────────────┘  │
│                           │                                │
│         ┌─────────────────┼─────────────────┐             │
│         │                 │                 │             │
│         ▼                 ▼                 ▼             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │  Runner     │  │  Runner     │  │  Runner     │      │
│  │   Pod 1     │  │   Pod 2     │  │   Pod N     │      │
│  │             │  │             │  │             │      │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │      │
│  │ │Container│ │  │ │Container│ │  │ │Container│ │      │
│  │ │         │ │  │ │         │ │  │ │         │ │      │
│  │ │ Runner  │ │  │ │ Runner  │ │  │ │ Runner  │ │      │
│  │ │ Process │ │  │ │ Process │ │  │ │ Process │ │      │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │      │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │
│         │                │                │             │
│         └────────────────┴────────────────┘             │
│                          │                              │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Auto-Scaling                            │  │
│  │                                                   │  │
│  │  ┌──────────────┐  ┌──────────────┐             │  │
│  │  │     HPA      │  │   Webhook    │             │  │
│  │  │              │  │    Scaler    │             │  │
│  │  │  • CPU/Mem   │  │              │             │  │
│  │  │  • Metrics   │  │  • GitHub    │             │  │
│  │  │              │  │    Events    │             │  │
│  │  └──────────────┘  └──────────────┘             │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                              │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Storage & Config                        │  │
│  │                                                   │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │
│  │  │   PVC    │  │ConfigMaps│  │ Secrets  │      │  │
│  │  │          │  │          │  │          │      │  │
│  │  │ • Work   │  │ • Config │  │ • Tokens │      │  │
│  │  │ • Cache  │  │ • Env    │  │ • Keys   │      │  │
│  │  └──────────┘  └──────────┘  └──────────┘      │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                      Monitoring                               │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Prometheus  │  │   Grafana    │  │     Logs     │      │
│  │              │  │              │  │              │      │
│  │  • Metrics   │  │  • Dashboard │  │  • Fluentd   │      │
│  │  • Alerts    │  │  • Visualize │  │  • ELK Stack │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Actions Runner Controller (ARC) Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                  ARC (Actions Runner Controller) Flow                   │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    Control Plane                              │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           ARC Controller                                │  │
│  │                                                         │  │
│  │  • Watches RunnerDeployment CRDs                       │  │
│  │  • Manages runner lifecycle                            │  │
│  │  • Handles scaling decisions                           │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│         ┌─────────────────┼─────────────────┐               │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Webhook    │  │   Metrics   │  │   GitHub    │        │
│  │   Server    │  │   Server    │  │     API     │        │
│  │             │  │             │  │             │        │
│  │  • Receives │  │  • Exposes  │  │  • Polls    │        │
│  │    Events   │  │    Metrics  │  │    Jobs     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└──────────────────────────────────────────────────────────────┘
         │                 │                 │
         └─────────────────┴─────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                  Runner Deployments                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │      RunnerDeployment CRD                              │  │
│  │                                                         │  │
│  │  apiVersion: actions.summerwind.dev/v1alpha1          │  │
│  │  kind: RunnerDeployment                               │  │
│  │  spec:                                                 │  │
│  │    replicas: 3                                        │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│                           ▼                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │      RunnerReplicaSet                                  │  │
│  │                                                         │  │
│  │  • Manages pod replicas                                │  │
│  │  • Ensures desired state                               │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│         ┌─────────────────┼─────────────────┐               │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Runner     │  │  Runner     │  │  Runner     │        │
│  │   Pod 1     │  │   Pod 2     │  │   Pod N     │        │
│  │             │  │             │  │             │        │
│  │  Status:    │  │  Status:    │  │  Status:    │        │
│  │  Running    │  │  Running    │  │  Running    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└──────────────────────────────────────────────────────────────┘
```

## Auto-Scaling Flow

```
GitHub                 Webhook Server      HRA                 RunnerDeployment    Kubernetes          Runner Pod
  │                         │               │                        │                  │                  │
  │  1. Workflow Job        │               │                        │                  │                  │
  │     Queued              │               │                        │                  │                  │
  ├────────────────────────>│               │                        │                  │                  │
  │                         │               │                        │                  │                  │
  │                         │ 2. Scale      │                        │                  │                  │
  │                         │    Event      │                        │                  │                  │
  │                         ├──────────────>│                        │                  │                  │
  │                         │               │                        │                  │                  │
  │                         │               │ 3. Calculate           │                  │                  │
  │                         │               │    Desired             │                  │                  │
  │                         │               │    Replicas            │                  │                  │
  │                         │               │                        │                  │                  │
  │                         │               │ 4. Update              │                  │                  │
  │                         │               │    Replicas            │                  │                  │
  │                         │               ├───────────────────────>│                  │                  │
  │                         │               │                        │                  │                  │
  │                         │               │                        │ 5. Create        │                  │
  │                         │               │                        │    Pods          │                  │
  │                         │               │                        ├─────────────────>│                  │
  │                         │               │                        │                  │                  │
  │                         │               │                        │                  │ 6. Start         │
  │                         │               │                        │                  │    Runner        │
  │                         │               │                        │                  ├─────────────────>│
  │                         │               │                        │                  │                  │
  │  7. Register &          │               │                        │                  │                  │
  │     Request Job         │               │                        │                  │                  │
  │<────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │                         │               │                        │                  │                  │
  │  8. Assign Job          │               │                        │                  │                  │
  ├────────────────────────────────────────────────────────────────────────────────────────────────────────>│
  │                         │               │                        │                  │                  │
  │                         │               │                        │                  │  9. Execute      │
  │                         │               │                        │                  │     Job          │
  │                         │               │                        │                  │                  │
  │  10. Report             │               │                        │                  │                  │
  │      Complete           │               │                        │                  │                  │
  │<────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │                         │               │                        │                  │                  │
  │                         │               │                        │                  │ 11. Terminate    │
  │                         │               │                        │                  │<─────────────────┤
  │                         │               │                        │                  │                  │
  │                         │               │ 12. Update             │                  │                  │
  │                         │               │     Metrics            │                  │                  │
  │                         │               │<───────────────────────┤                  │                  │
  │                         │               │                        │                  │                  │
  │                         │               │ 13. Scale              │                  │                  │
  │                         │               │     Down               │                  │                  │
  │                         │               ├───────────────────────>│                  │                  │
  │                         │               │                        │                  │                  │
```

## Multi-Environment Setup

```
┌────────────────────────────────────────────────────────────────────────┐
│              Multi-Environment Kubernetes Architecture                  │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         Production Namespace                            │  │
│  │                                                         │  │
│  │  ┌──────────────────┐         ┌──────────────────┐    │  │
│  │  │RunnerDeployment  │────────>│  Prod Runners    │    │  │
│  │  │                  │         │                  │    │  │
│  │  │  replicas: 5     │         │  • Pod 1         │    │  │
│  │  │  labels:         │         │  • Pod 2         │    │  │
│  │  │  - production    │         │  • Pod 3         │    │  │
│  │  │  - high-priority │         │  • Pod 4         │    │  │
│  │  │                  │         │  • Pod 5         │    │  │
│  │  └──────────────────┘         └──────────────────┘    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         Staging Namespace                               │  │
│  │                                                         │  │
│  │  ┌──────────────────┐         ┌──────────────────┐    │  │
│  │  │RunnerDeployment  │────────>│ Staging Runners  │    │  │
│  │  │                  │         │                  │    │  │
│  │  │  replicas: 3     │         │  • Pod 1         │    │  │
│  │  │  labels:         │         │  • Pod 2         │    │  │
│  │  │  - staging       │         │  • Pod 3         │    │  │
│  │  │                  │         │                  │    │  │
│  │  └──────────────────┘         └──────────────────┘    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         Development Namespace                           │  │
│  │                                                         │  │
│  │  ┌──────────────────┐         ┌──────────────────┐    │  │
│  │  │RunnerDeployment  │────────>│   Dev Runners    │    │  │
│  │  │                  │         │                  │    │  │
│  │  │  replicas: 2     │         │  • Pod 1         │    │  │
│  │  │  labels:         │         │  • Pod 2         │    │  │
│  │  │  - development   │         │                  │    │  │
│  │  │                  │         │                  │    │  │
│  │  └──────────────────┘         └──────────────────┘    │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
         │                 │                 │
         └─────────────────┴─────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │    GitHub       │
                  │   Workflows     │
                  │                 │
                  │  • production   │
                  │  • staging      │
                  │  • development  │
                  └─────────────────┘
```

## Table of Contents
- [Prerequisites](#prerequisites)
- [Basic Deployment](#basic-deployment)
- [Actions Runner Controller (ARC)](#actions-runner-controller-arc)
- [Auto-Scaling](#auto-scaling)
- [Advanced Configurations](#advanced-configurations)
- [Monitoring and Logging](#monitoring-and-logging)
- [Security Best Practices](#security-best-practices)

## Prerequisites

### Required Tools
```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
kubectl version --client
helm version
```

### Kubernetes Cluster
- Kubernetes 1.24+
- kubectl configured
- Sufficient resources (2 CPU, 4GB RAM per runner minimum)

## Basic Deployment

### Manual Deployment

Create `runner-deployment.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: github-runners

---
apiVersion: v1
kind: Secret
metadata:
  name: github-runner-secret
  namespace: github-runners
type: Opaque
stringData:
  GITHUB_TOKEN: "YOUR_GITHUB_TOKEN"
  REPO_URL: "https://github.com/YOUR_ORG/YOUR_REPO"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: runner-config
  namespace: github-runners
data:
  RUNNER_WORKDIR: "/tmp/runner"
  RUNNER_GROUP: "default"
  LABELS: "self-hosted,kubernetes,linux"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-runner
  namespace: github-runners
  labels:
    app: github-runner
spec:
  replicas: 3
  selector:
    matchLabels:
      app: github-runner
  template:
    metadata:
      labels:
        app: github-runner
    spec:
      containers:
      - name: runner
        image: myoung34/github-runner:latest
        env:
        - name: REPO_URL
          valueFrom:
            secretKeyRef:
              name: github-runner-secret
              key: REPO_URL
        - name: RUNNER_TOKEN
          valueFrom:
            secretKeyRef:
              name: github-runner-secret
              key: GITHUB_TOKEN
        - name: RUNNER_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: RUNNER_WORKDIR
          valueFrom:
            configMapKeyRef:
              name: runner-config
              key: RUNNER_WORKDIR
        - name: LABELS
          valueFrom:
            configMapKeyRef:
              name: runner-config
              key: LABELS
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        volumeMounts:
        - name: work
          mountPath: /tmp/runner
      volumes:
      - name: work
        emptyDir: {}
```

Deploy:
```bash
kubectl apply -f runner-deployment.yaml
```

### StatefulSet Deployment

Create `runner-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: github-runner
  namespace: github-runners
spec:
  serviceName: github-runner
  replicas: 3
  selector:
    matchLabels:
      app: github-runner
  template:
    metadata:
      labels:
        app: github-runner
    spec:
      containers:
      - name: runner
        image: myoung34/github-runner:latest
        env:
        - name: REPO_URL
          valueFrom:
            secretKeyRef:
              name: github-runner-secret
              key: REPO_URL
        - name: RUNNER_TOKEN
          valueFrom:
            secretKeyRef:
              name: github-runner-secret
              key: GITHUB_TOKEN
        - name: RUNNER_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: LABELS
          value: "self-hosted,kubernetes,linux,stateful"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        volumeMounts:
        - name: runner-storage
          mountPath: /tmp/runner
  volumeClaimTemplates:
  - metadata:
      name: runner-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

## Actions Runner Controller (ARC)

### Install ARC with Helm

```bash
# Add Helm repository
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update

# Create namespace
kubectl create namespace actions-runner-system

# Install cert-manager (required)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager -n cert-manager

# Install Actions Runner Controller
helm install actions-runner-controller \
  actions-runner-controller/actions-runner-controller \
  --namespace actions-runner-system \
  --set authSecret.create=true \
  --set authSecret.github_token="YOUR_GITHUB_PAT"
```

### Create Runner Deployment with ARC

Create `arc-runner-deployment.yaml`:

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: github-runner
  namespace: github-runners
spec:
  replicas: 3
  template:
    spec:
      repository: YOUR_ORG/YOUR_REPO
      labels:
        - self-hosted
        - kubernetes
        - arc
      resources:
        requests:
          memory: "2Gi"
          cpu: "1000m"
        limits:
          memory: "4Gi"
          cpu: "2000m"
      volumeMounts:
        - name: work
          mountPath: /runner/_work
      volumes:
        - name: work
          emptyDir: {}
```

Apply:
```bash
kubectl apply -f arc-runner-deployment.yaml
```

### Organization-Level Runners

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: org-runners
  namespace: github-runners
spec:
  replicas: 5
  template:
    spec:
      organization: YOUR_ORG
      labels:
        - self-hosted
        - kubernetes
        - org-wide
      resources:
        requests:
          memory: "2Gi"
          cpu: "1000m"
        limits:
          memory: "4Gi"
          cpu: "2000m"
```

## Auto-Scaling

### Horizontal Pod Autoscaler (HPA)

Create `runner-hpa.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: github-runner-hpa
  namespace: github-runners
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: github-runner
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
```

### ARC Auto-Scaling

Create `arc-autoscaler.yaml`:

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: HorizontalRunnerAutoscaler
metadata:
  name: github-runner-autoscaler
  namespace: github-runners
spec:
  scaleTargetRef:
    name: github-runner
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: PercentageRunnersBusy
    scaleUpThreshold: '0.75'
    scaleDownThreshold: '0.25'
    scaleUpFactor: '2'
    scaleDownFactor: '0.5'
  - type: TotalNumberOfQueuedAndInProgressWorkflowRuns
    repositoryNames:
    - YOUR_ORG/YOUR_REPO
```

### Webhook-Based Auto-Scaling

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: HorizontalRunnerAutoscaler
metadata:
  name: webhook-autoscaler
  namespace: github-runners
spec:
  scaleTargetRef:
    name: github-runner
  minReplicas: 1
  maxReplicas: 50
  scaleDownDelaySecondsAfterScaleOut: 300
  metrics:
  - type: TotalNumberOfQueuedAndInProgressWorkflowRuns
    repositoryNames:
    - YOUR_ORG/YOUR_REPO
  scaleUpTriggers:
  - githubEvent:
      workflowJob: {}
    amount: 1
    duration: "5m"
```

## Advanced Configurations

### DinD (Docker-in-Docker) Runner

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: github-runner-dind
  namespace: github-runners
spec:
  containers:
  - name: runner
    image: myoung34/github-runner:latest
    env:
    - name: REPO_URL
      value: "https://github.com/YOUR_ORG/YOUR_REPO"
    - name: RUNNER_TOKEN
      valueFrom:
        secretKeyRef:
          name: github-runner-secret
          key: GITHUB_TOKEN
    - name: DOCKER_HOST
      value: "tcp://localhost:2375"
    - name: LABELS
      value: "self-hosted,kubernetes,dind"
    resources:
      requests:
        memory: "2Gi"
        cpu: "1000m"
      limits:
        memory: "4Gi"
        cpu: "2000m"
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    volumeMounts:
    - name: docker-storage
      mountPath: /var/lib/docker
  volumes:
  - name: docker-storage
    emptyDir: {}
```

### Kaniko Builder (Rootless)

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: kaniko-runner
  namespace: github-runners
spec:
  replicas: 3
  template:
    spec:
      repository: YOUR_ORG/YOUR_REPO
      labels:
        - self-hosted
        - kubernetes
        - kaniko
      dockerdWithinRunnerContainer: false
      image: summerwind/actions-runner:latest
      dockerRegistryMirror: https://mirror.gcr.io
      sidecarContainers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        command: ["/busybox/sh"]
        args: ["-c", "while true; do sleep 1; done"]
        volumeMounts:
        - name: work
          mountPath: /workspace
      volumeMounts:
      - name: work
        mountPath: /runner/_work
      volumes:
      - name: work
        emptyDir: {}
```

### GPU-Enabled Runners

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: gpu-runner
  namespace: github-runners
spec:
  replicas: 2
  template:
    spec:
      repository: YOUR_ORG/YOUR_REPO
      labels:
        - self-hosted
        - kubernetes
        - gpu
      nodeSelector:
        accelerator: nvidia-tesla-v100
      tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
      resources:
        requests:
          memory: "8Gi"
          cpu: "4000m"
          nvidia.com/gpu: 1
        limits:
          memory: "16Gi"
          cpu: "8000m"
          nvidia.com/gpu: 1
```

### Multi-Architecture Runners

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: amd64-runner
  namespace: github-runners
spec:
  replicas: 3
  template:
    spec:
      repository: YOUR_ORG/YOUR_REPO
      labels:
        - self-hosted
        - kubernetes
        - amd64
      nodeSelector:
        kubernetes.io/arch: amd64

---
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: arm64-runner
  namespace: github-runners
spec:
  replicas: 2
  template:
    spec:
      repository: YOUR_ORG/YOUR_REPO
      labels:
        - self-hosted
        - kubernetes
        - arm64
      nodeSelector:
        kubernetes.io/arch: arm64
```

## Monitoring and Logging

### Prometheus Monitoring

Create `servicemonitor.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: github-runner-metrics
  namespace: github-runners
  labels:
    app: github-runner
spec:
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
  selector:
    app: github-runner

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: github-runner-monitor
  namespace: github-runners
  labels:
    app: github-runner
spec:
  selector:
    matchLabels:
      app: github-runner
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### Grafana Dashboard

Create `grafana-dashboard-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: github-runner-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "GitHub Actions Runners",
        "panels": [
          {
            "title": "Active Runners",
            "targets": [
              {
                "expr": "count(kube_pod_status_phase{namespace='github-runners',phase='Running'})"
              }
            ]
          },
          {
            "title": "CPU Usage",
            "targets": [
              {
                "expr": "sum(rate(container_cpu_usage_seconds_total{namespace='github-runners'}[5m]))"
              }
            ]
          },
          {
            "title": "Memory Usage",
            "targets": [
              {
                "expr": "sum(container_memory_usage_bytes{namespace='github-runners'})"
              }
            ]
          }
        ]
      }
    }
```

### Logging with Fluentd

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: github-runners
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/github-runner*.log
      pos_file /var/log/fluentd-github-runner.pos
      tag kubernetes.github-runner
      <parse>
        @type json
        time_key time
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
    
    <match kubernetes.github-runner>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      logstash_format true
      logstash_prefix github-runner
    </match>
```

## Security Best Practices

### Pod Security Policy

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: github-runner-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: false
```

### Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: github-runner-netpol
  namespace: github-runners
spec:
  podSelector:
    matchLabels:
      app: github-runner
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 80
  - to:
    - podSelector:
        matchLabels:
          app: dns
    ports:
    - protocol: UDP
      port: 53
```

### RBAC Configuration

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: github-runner
  namespace: github-runners

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: github-runner-role
  namespace: github-runners
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: github-runner-rolebinding
  namespace: github-runners
subjects:
- kind: ServiceAccount
  name: github-runner
  namespace: github-runners
roleRef:
  kind: Role
  name: github-runner-role
  apiGroup: rbac.authorization.k8s.io
```

## Management Commands

```bash
# View runners
kubectl get pods -n github-runners

# View logs
kubectl logs -f deployment/github-runner -n github-runners

# Scale runners
kubectl scale deployment github-runner --replicas=5 -n github-runners

# Delete runner
kubectl delete pod github-runner-xxx -n github-runners

# View HPA status
kubectl get hpa -n github-runners

# Describe runner
kubectl describe pod github-runner-xxx -n github-runners

# Execute command in runner
kubectl exec -it github-runner-xxx -n github-runners -- bash

# View events
kubectl get events -n github-runners --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward deployment/github-runner 8080:8080 -n github-runners
```

## Troubleshooting

### Runner Not Registering

```bash
# Check logs
kubectl logs deployment/github-runner -n github-runners

# Verify secrets
kubectl get secret github-runner-secret -n github-runners -o yaml

# Check network connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl -v https://github.com
```

### High Resource Usage

```bash
# Check resource usage
kubectl top pods -n github-runners

# View resource limits
kubectl describe pod github-runner-xxx -n github-runners | grep -A 5 "Limits"

# Check HPA metrics
kubectl get hpa github-runner-hpa -n github-runners -o yaml
```

### Pod Eviction

```bash
# Check node resources
kubectl top nodes

# View pod priority
kubectl get pods -n github-runners -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority

# Add priority class
kubectl apply -f - <<EOF
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: github-runner-priority
value: 1000
globalDefault: false
description: "Priority class for GitHub runners"
EOF
```
