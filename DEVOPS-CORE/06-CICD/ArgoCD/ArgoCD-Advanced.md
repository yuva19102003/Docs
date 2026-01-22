# ArgoCD Advanced Features

## Multi-Cluster Management

### Add External Cluster

```bash
# List available contexts
kubectl config get-contexts

# Add cluster to ArgoCD
argocd cluster add <context-name>

# Add with custom name
argocd cluster add <context-name> --name production-cluster

# List registered clusters
argocd cluster list
```

### Deploy to Multiple Clusters

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-cluster-app
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
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## RBAC (Role-Based Access Control)

### Configure RBAC Policy

Edit `argocd-rbac-cm` ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    # Format: p, subject, resource, action, object, effect
    
    # Admin role - full access
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    p, role:admin, projects, *, *, allow
    
    # Developer role - can manage apps in dev project
    p, role:developer, applications, get, dev/*, allow
    p, role:developer, applications, sync, dev/*, allow
    p, role:developer, applications, create, dev/*, allow
    p, role:developer, applications, update, dev/*, allow
    p, role:developer, applications, delete, dev/*, allow
    
    # Viewer role - read-only access
    p, role:viewer, applications, get, */*, allow
    p, role:viewer, projects, get, *, allow
    
    # Assign roles to users/groups
    g, admin-group, role:admin
    g, dev-team, role:developer
    g, everyone, role:viewer
```

### RBAC Examples

```yaml
# Allow user to sync specific app
p, alice@example.com, applications, sync, default/myapp, allow

# Allow group to manage apps in project
p, role:devops, applications, *, myproject/*, allow
g, devops-team, role:devops

# Deny delete for production
p, role:developer, applications, delete, production/*, deny
```

## SSO Integration

### GitHub SSO

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  dex.config: |
    connectors:
    - type: github
      id: github
      name: GitHub
      config:
        clientID: $GITHUB_CLIENT_ID
        clientSecret: $GITHUB_CLIENT_SECRET
        orgs:
        - name: my-organization
          teams:
          - devops
          - developers
```

### Google SSO

```yaml
dex.config: |
  connectors:
  - type: oidc
    id: google
    name: Google
    config:
      issuer: https://accounts.google.com
      clientID: $GOOGLE_CLIENT_ID
      clientSecret: $GOOGLE_CLIENT_SECRET
      hostedDomains:
      - example.com
```

### LDAP/Active Directory

```yaml
dex.config: |
  connectors:
  - type: ldap
    id: ldap
    name: LDAP
    config:
      host: ldap.example.com:636
      insecureNoSSL: false
      bindDN: cn=admin,dc=example,dc=com
      bindPW: $LDAP_PASSWORD
      userSearch:
        baseDN: ou=users,dc=example,dc=com
        filter: "(objectClass=person)"
        username: uid
        idAttr: uid
        emailAttr: mail
        nameAttr: cn
      groupSearch:
        baseDN: ou=groups,dc=example,dc=com
        filter: "(objectClass=groupOfNames)"
        userAttr: DN
        groupAttr: member
        nameAttr: cn
```

### SAML 2.0

```yaml
dex.config: |
  connectors:
  - type: saml
    id: saml
    name: SAML
    config:
      ssoURL: https://idp.example.com/sso
      caData: $IDP_CA_CERT
      redirectURI: https://argocd.example.com/api/dex/callback
      usernameAttr: email
      emailAttr: email
      groupsAttr: groups
```

## Projects

### Create Project

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications
  
  # Source repositories
  sourceRepos:
  - https://github.com/org/prod-apps.git
  - https://github.com/org/helm-charts.git
  
  # Destination clusters and namespaces
  destinations:
  - namespace: production
    server: https://kubernetes.default.svc
  - namespace: prod-*
    server: https://prod-cluster.example.com
  
  # Allowed cluster resources
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  - group: 'rbac.authorization.k8s.io'
    kind: ClusterRole
  
  # Denied namespaced resources
  namespaceResourceBlacklist:
  - group: ''
    kind: ResourceQuota
  
  # Roles
  roles:
  - name: developer
    description: Developers
    policies:
    - p, proj:production:developer, applications, get, production/*, allow
    - p, proj:production:developer, applications, sync, production/*, allow
    groups:
    - dev-team
  
  - name: admin
    description: Admins
    policies:
    - p, proj:production:admin, applications, *, production/*, allow
    groups:
    - admin-team
```

## Notifications

### Install Notifications Controller

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/stable/manifests/install.yaml
```

### Configure Slack Notifications

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.slack: |
    token: $slack-token
  
  template.app-deployed: |
    message: |
      Application {{.app.metadata.name}} is now running new version.
    slack:
      attachments: |
        [{
          "title": "{{ .app.metadata.name}}",
          "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
          "color": "#18be52",
          "fields": [
          {
            "title": "Sync Status",
            "value": "{{.app.status.sync.status}}",
            "short": true
          },
          {
            "title": "Repository",
            "value": "{{.app.spec.source.repoURL}}",
            "short": true
          }
          ]
        }]
  
  template.app-health-degraded: |
    message: |
      Application {{.app.metadata.name}} has degraded.
    slack:
      attachments: |
        [{
          "title": "{{ .app.metadata.name}}",
          "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
          "color": "#f4c030",
          "fields": [
          {
            "title": "Health Status",
            "value": "{{.app.status.health.status}}",
            "short": true
          }
          ]
        }]
  
  trigger.on-deployed: |
    - when: app.status.operationState.phase in ['Succeeded']
      send: [app-deployed]
  
  trigger.on-health-degraded: |
    - when: app.status.health.status == 'Degraded'
      send: [app-health-degraded]
```

### Subscribe Application to Notifications

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  annotations:
    notifications.argoproj.io/subscribe.on-deployed.slack: my-channel
    notifications.argoproj.io/subscribe.on-health-degraded.slack: alerts-channel
spec:
  # ... application spec
```

## Image Updater

### Install Image Updater

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

### Configure Image Updater

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-image-updater-config
  namespace: argocd
data:
  registries.conf: |
    registries:
    - name: Docker Hub
      api_url: https://registry-1.docker.io
      prefix: docker.io
      credentials: secret:argocd/dockerhub-secret
    
    - name: GCR
      api_url: https://gcr.io
      prefix: gcr.io
      credentials: pullsecret:kube-system/gcr-secret
```

### Enable Auto-Update for Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  annotations:
    argocd-image-updater.argoproj.io/image-list: myimage=myapp
    argocd-image-updater.argoproj.io/myimage.update-strategy: latest
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:^v[0-9]+\.[0-9]+\.[0-9]+$
    argocd-image-updater.argoproj.io/write-back-method: git
spec:
  # ... application spec
```

## Progressive Delivery with Rollouts

### Install Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

### Canary Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 1m}
      - setWeight: 40
      - pause: {duration: 1m}
      - setWeight: 60
      - pause: {duration: 1m}
      - setWeight: 80
      - pause: {duration: 1m}
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0.0
```

### Blue-Green Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 3
  strategy:
    blueGreen:
      activeService: myapp-active
      previewService: myapp-preview
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 30
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0.0
```

## Secrets Management

### Sealed Secrets Integration

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sealed-secrets
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: HEAD
    path: sealed-secrets/
  destination:
    server: https://kubernetes.default.svc
    namespace: kube-system
```

### External Secrets Operator

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: app-secrets
  data:
  - secretKey: database-password
    remoteRef:
      key: prod/database
      property: password
```

### Vault Integration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  repository.credentials: |
    - url: https://github.com/org
      passwordSecret:
        name: github-secret
        key: password
      usernameSecret:
        name: github-secret
        key: username
```

## Monitoring and Observability

### Prometheus Metrics

```yaml
apiVersion: v1
kind: Service
metadata:
  name: argocd-metrics
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-metrics
spec:
  ports:
  - name: metrics
    port: 8082
    protocol: TCP
    targetPort: 8082
  selector:
    app.kubernetes.io/name: argocd-server
```

### ServiceMonitor for Prometheus Operator

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
    interval: 30s
```

### Grafana Dashboard

Import dashboard ID: **14584** (ArgoCD Overview)

Key metrics:
- Application sync status
- Sync duration
- Repository fetch time
- Controller queue size
- API server requests

## Disaster Recovery

### Backup Strategy

```bash
# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Backup ArgoCD projects
kubectl get appprojects -n argocd -o yaml > argocd-projects-backup.yaml

# Backup ArgoCD settings
kubectl get configmaps -n argocd -o yaml > argocd-config-backup.yaml
kubectl get secrets -n argocd -o yaml > argocd-secrets-backup.yaml

# Backup to Git (recommended)
git add .
git commit -m "Backup ArgoCD configuration"
git push
```

### Restore from Backup

```bash
# Restore applications
kubectl apply -f argocd-apps-backup.yaml

# Restore projects
kubectl apply -f argocd-projects-backup.yaml

# Restore configuration
kubectl apply -f argocd-config-backup.yaml
kubectl apply -f argocd-secrets-backup.yaml
```

## Performance Tuning

### Increase Controller Replicas

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-application-controller
  namespace: argocd
spec:
  replicas: 3
```

### Adjust Resource Limits

```yaml
spec:
  template:
    spec:
      containers:
      - name: argocd-application-controller
        resources:
          requests:
            cpu: 1000m
            memory: 2Gi
          limits:
            cpu: 2000m
            memory: 4Gi
```

### Enable Sharding

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  application.controller.sharding.enabled: "true"
  application.controller.sharding.replicas: "3"
```

## Best Practices

✅ **Use Projects**: Organize and restrict applications
✅ **Implement RBAC**: Fine-grained access control
✅ **Enable SSO**: Centralized authentication
✅ **Set Up Notifications**: Stay informed of changes
✅ **Use Image Updater**: Automate image updates
✅ **Monitor Metrics**: Track performance and health
✅ **Regular Backups**: Backup configurations to Git
✅ **Multi-Cluster**: Separate dev/staging/prod clusters
✅ **Use Rollouts**: Progressive delivery strategies
✅ **Secrets Management**: External secrets operators

## Troubleshooting

### Application Stuck in Progressing

```bash
# Check application status
argocd app get myapp

# Check sync operation
argocd app get myapp --show-operation

# Terminate stuck operation
argocd app terminate-op myapp
```

### Sync Fails

```bash
# View sync errors
argocd app get myapp

# View detailed diff
argocd app diff myapp

# Force sync
argocd app sync myapp --force
```

### Performance Issues

```bash
# Check controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# Check metrics
kubectl top pods -n argocd

# Increase resources
kubectl edit deployment argocd-application-controller -n argocd
```

## Next Steps

Continue to:
- **ArgoCD-Examples.md** - Real-world examples and patterns
