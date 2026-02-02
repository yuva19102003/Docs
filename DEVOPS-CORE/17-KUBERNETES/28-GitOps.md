# GitOps with Kubernetes

GitOps principles and practices for Kubernetes deployments.

## GitOps Principles

```
┌────────────────────────────────────────────────┐
│         GitOps Workflow                        │
├────────────────────────────────────────────────┤
│  1. Git as Single Source of Truth              │
│  2. Declarative Configuration                  │
│  3. Automated Deployment                       │
│  4. Continuous Reconciliation                  │
└────────────────────────────────────────────────┘
```

## ArgoCD

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/myapp
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Flux CD

### Install Flux

```bash
# Install Flux CLI
brew install fluxcd/tap/flux

# Bootstrap Flux
flux bootstrap github \
  --owner=myorg \
  --repository=myrepo \
  --branch=main \
  --path=clusters/production \
  --personal
```

### GitRepository

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: myapp
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/example/myapp
  ref:
    branch: main
```

### Kustomization

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: myapp
  namespace: flux-system
spec:
  interval: 5m
  path: ./k8s
  prune: true
  sourceRef:
    kind: GitRepository
    name: myapp
  healthChecks:
  - apiVersion: apps/v1
    kind: Deployment
    name: myapp
    namespace: production
```

## Repository Structure

```
myapp/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   └── kustomization.yaml
│   └── production/
│       └── kustomization.yaml
└── README.md
```

## Best Practices

1. **Git as Source of Truth**
2. **Separate Config Repos**
3. **Use Kustomize/Helm**
4. **Automated Sync**
5. **Monitor Drift**

## References

- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Flux](https://fluxcd.io/)
- [GitOps Principles](https://opengitops.dev/)
