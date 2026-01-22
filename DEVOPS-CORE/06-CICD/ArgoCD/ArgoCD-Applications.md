# ArgoCD Applications

## Creating Applications

### Via UI

1. Click **+ NEW APP**
2. Fill in details:
   - **Application Name**: my-app
   - **Project**: default
   - **Sync Policy**: Manual/Automatic
   - **Repository URL**: https://github.com/user/repo
   - **Path**: k8s/
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: default
3. Click **CREATE**

### Via CLI

```bash
argocd app create my-app \
  --repo https://github.com/user/repo.git \
  --path k8s/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Via YAML Manifest

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: HEAD
    path: k8s/
  
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply:

```bash
kubectl apply -f application.yaml
```

## Application with Helm

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-helm-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/user/helm-charts.git
    targetRevision: HEAD
    path: charts/myapp
    helm:
      valueFiles:
        - values.yaml
        - values-prod.yaml
      parameters:
        - name: image.tag
          value: v1.0.0
        - name: replicaCount
          value: "3"
      values: |
        service:
          type: LoadBalancer
          port: 80
  
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Application with Kustomize

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-kustomize-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: HEAD
    path: overlays/production
    kustomize:
      images:
        - myapp=myapp:v1.0.0
      commonLabels:
        environment: production
      namePrefix: prod-
  
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

## Sync Policies

### Manual Sync

```yaml
syncPolicy: {}  # No automated sync
```

Sync manually:

```bash
argocd app sync my-app
```

### Automatic Sync

```yaml
syncPolicy:
  automated:
    prune: false      # Don't delete resources
    selfHeal: false   # Don't auto-sync on cluster changes
```

### Automatic with Prune and Self-Heal

```yaml
syncPolicy:
  automated:
    prune: true       # Delete resources not in Git
    selfHeal: true    # Auto-sync on cluster changes
  syncOptions:
    - CreateNamespace=true
    - PruneLast=true
```

## Sync Options

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true        # Create namespace if not exists
    - PruneLast=true              # Prune resources last
    - ApplyOutOfSyncOnly=true     # Only sync out-of-sync resources
    - RespectIgnoreDifferences=true
    - ServerSideApply=true        # Use server-side apply
```

## Sync Hooks

### Pre-Sync Hook (Database Migration)

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: myapp:v1.0.0
        command: ["./migrate.sh"]
      restartPolicy: Never
```

### Post-Sync Hook (Smoke Tests)

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-tests
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: test
        image: myapp:v1.0.0
        command: ["./smoke-tests.sh"]
      restartPolicy: Never
```

### Sync-Fail Hook (Rollback)

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: rollback
  annotations:
    argocd.argoproj.io/hook: SyncFail
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: rollback
        image: myapp:v1.0.0
        command: ["./rollback.sh"]
      restartPolicy: Never
```

## Resource Hooks

Available hooks:
- **PreSync**: Before sync
- **Sync**: During sync
- **PostSync**: After sync
- **SyncFail**: On sync failure
- **Skip**: Skip resource during sync

Delete policies:
- **HookSucceeded**: Delete after success
- **HookFailed**: Delete after failure
- **BeforeHookCreation**: Delete before creating new hook

## Health Assessment

### Custom Health Check

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations: |
    apps/Deployment:
      health.lua: |
        hs = {}
        if obj.status ~= nil then
          if obj.status.replicas ~= nil and obj.status.updatedReplicas ~= nil then
            if obj.status.replicas == obj.status.updatedReplicas then
              hs.status = "Healthy"
              hs.message = "All replicas are updated"
              return hs
            end
          end
        end
        hs.status = "Progressing"
        hs.message = "Waiting for rollout to finish"
        return hs
```

## Ignore Differences

### Ignore Specific Fields

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
  - group: apps
    kind: StatefulSet
    jqPathExpressions:
    - .spec.volumeClaimTemplates[]?.metadata.annotations
```

## App of Apps Pattern

Parent application managing child applications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/user/apps.git
    targetRevision: HEAD
    path: apps/
  
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Directory structure:

```
apps/
├── app1.yaml
├── app2.yaml
└── app3.yaml
```

## ApplicationSet

### Git Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: microservices
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/user/repo.git
      revision: HEAD
      directories:
      - path: services/*
  
  template:
    metadata:
      name: '{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/user/repo.git
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

### List Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-env
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - cluster: dev
        url: https://dev.k8s.local
      - cluster: staging
        url: https://staging.k8s.local
      - cluster: prod
        url: https://prod.k8s.local
  
  template:
    metadata:
      name: 'myapp-{{cluster}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/user/repo.git
        targetRevision: HEAD
        path: 'overlays/{{cluster}}'
      destination:
        server: '{{url}}'
        namespace: myapp
```

### Cluster Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-apps
  namespace: argocd
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
  
  template:
    metadata:
      name: '{{name}}-myapp'
    spec:
      project: default
      source:
        repoURL: https://github.com/user/repo.git
        targetRevision: HEAD
        path: k8s/
      destination:
        server: '{{server}}'
        namespace: myapp
```

## Managing Applications

### Sync Application

```bash
# Sync application
argocd app sync my-app

# Sync specific resource
argocd app sync my-app --resource apps:Deployment:my-deployment

# Dry run
argocd app sync my-app --dry-run

# Force sync
argocd app sync my-app --force
```

### Refresh Application

```bash
# Refresh (check Git for changes)
argocd app get my-app --refresh

# Hard refresh (clear cache)
argocd app get my-app --hard-refresh
```

### Rollback Application

```bash
# List history
argocd app history my-app

# Rollback to specific revision
argocd app rollback my-app 5
```

### Delete Application

```bash
# Delete application (keep resources)
argocd app delete my-app

# Delete application and resources
argocd app delete my-app --cascade

# Delete without confirmation
argocd app delete my-app --yes
```

### Patch Application

```bash
# Patch application
argocd app patch my-app --patch '{"spec":{"source":{"targetRevision":"v2.0.0"}}}'

# Patch with file
argocd app patch my-app --patch-file patch.yaml
```

## Application Status

### View Status

```bash
# Get application details
argocd app get my-app

# Get application tree
argocd app get my-app --show-operation

# Get application resources
argocd app resources my-app
```

### View Logs

```bash
# View application logs
argocd app logs my-app

# Follow logs
argocd app logs my-app --follow

# View specific container logs
argocd app logs my-app --container my-container
```

### View Diff

```bash
# Show diff between Git and cluster
argocd app diff my-app

# Show diff for specific resource
argocd app diff my-app --resource apps:Deployment:my-deployment
```

## Best Practices

✅ **Use Projects**: Organize applications into projects
✅ **Enable Auto-Sync Carefully**: Manual for prod, auto for dev/staging
✅ **Use Sync Waves**: Control deployment order with annotations
✅ **Implement Health Checks**: Custom health checks for CRDs
✅ **Use Hooks**: Pre/post sync hooks for migrations and tests
✅ **Ignore Differences**: Ignore fields that change frequently
✅ **Use App of Apps**: Manage multiple applications
✅ **Use ApplicationSets**: Deploy to multiple clusters/environments
✅ **Monitor Sync Status**: Set up alerts for OutOfSync apps
✅ **Version Control**: All manifests in Git

## Next Steps

Continue to:
- **ArgoCD-Advanced.md** - Multi-cluster, RBAC, SSO
- **ArgoCD-Examples.md** - Real-world examples
