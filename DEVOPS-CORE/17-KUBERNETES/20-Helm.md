# Helm - Kubernetes Package Manager

Helm is the package manager for Kubernetes, simplifying application deployment and management.

## Helm Overview

```
┌────────────────────────────────────────┐
│          Helm Architecture             │
├────────────────────────────────────────┤
│                                        │
│  Helm CLI  ──────►  Kubernetes API     │
│                                        │
│  Chart (Package)                       │
│    ├── templates/                      │
│    ├── values.yaml                     │
│    └── Chart.yaml                      │
│                                        │
│  Release (Deployed Instance)           │
└────────────────────────────────────────┘
```

## Installation

```bash
# Install Helm (Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Helm (macOS)
brew install helm

# Verify installation
helm version
```

## Core Concepts

### Chart
Package containing Kubernetes resource definitions

### Release
Instance of a chart running in cluster

### Repository
Collection of charts

### Values
Configuration parameters for charts

## Basic Commands

```bash
# Add repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Search charts
helm search repo nginx
helm search hub wordpress

# Install chart
helm install my-release bitnami/nginx

# List releases
helm list
helm list --all-namespaces

# Get release status
helm status my-release

# Upgrade release
helm upgrade my-release bitnami/nginx

# Rollback release
helm rollback my-release 1

# Uninstall release
helm uninstall my-release

# Get values
helm get values my-release

# Get manifest
helm get manifest my-release
```

## Chart Structure

```
mychart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── charts/             # Dependencies
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl   # Template helpers
│   └── NOTES.txt      # Post-install notes
├── .helmignore        # Files to ignore
└── README.md          # Documentation
```

## Chart.yaml

```yaml
apiVersion: v2
name: myapp
description: A Helm chart for my application
type: application
version: 1.0.0
appVersion: "1.0"
keywords:
  - web
  - application
home: https://example.com
sources:
  - https://github.com/example/myapp
maintainers:
  - name: John Doe
    email: john@example.com
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
```

## values.yaml

```yaml
# Default values for myapp
replicaCount: 3

image:
  repository: myapp
  pullPolicy: IfNotPresent
  tag: "1.0"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}
```

## Template Example

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "myapp.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /healthz
            port: http
        readinessProbe:
          httpGet:
            path: /ready
            port: http
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

### _helpers.tpl

```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "myapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "myapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "myapp.labels" -}}
helm.sh/chart: {{ include "myapp.chart" . }}
{{ include "myapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "myapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

## Installing Charts

### Basic Install

```bash
# Install from repository
helm install my-release bitnami/nginx

# Install with custom values
helm install my-release bitnami/nginx --values custom-values.yaml

# Install with set values
helm install my-release bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=LoadBalancer

# Install in specific namespace
helm install my-release bitnami/nginx --namespace production --create-namespace

# Dry run
helm install my-release bitnami/nginx --dry-run --debug

# Generate manifest without installing
helm template my-release bitnami/nginx
```

### Custom Values File

```yaml
# custom-values.yaml
replicaCount: 5

image:
  tag: "1.21"

service:
  type: LoadBalancer
  port: 8080

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

```bash
helm install my-release bitnami/nginx -f custom-values.yaml
```

## Upgrading Releases

```bash
# Upgrade with new values
helm upgrade my-release bitnami/nginx --values new-values.yaml

# Upgrade with set values
helm upgrade my-release bitnami/nginx --set replicaCount=5

# Upgrade or install
helm upgrade --install my-release bitnami/nginx

# Force upgrade
helm upgrade my-release bitnami/nginx --force

# Upgrade with wait
helm upgrade my-release bitnami/nginx --wait --timeout 5m

# Upgrade with atomic (rollback on failure)
helm upgrade my-release bitnami/nginx --atomic
```

## Rollback

```bash
# List revisions
helm history my-release

# Rollback to previous version
helm rollback my-release

# Rollback to specific revision
helm rollback my-release 2

# Rollback with wait
helm rollback my-release 2 --wait
```

## Creating Charts

```bash
# Create new chart
helm create myapp

# Lint chart
helm lint myapp/

# Package chart
helm package myapp/

# Install local chart
helm install my-release ./myapp

# Install packaged chart
helm install my-release myapp-1.0.0.tgz
```

## Dependencies

### Chart.yaml

```yaml
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  - name: redis
    version: "17.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

### Manage Dependencies

```bash
# Update dependencies
helm dependency update myapp/

# List dependencies
helm dependency list myapp/

# Build dependencies
helm dependency build myapp/
```

## Hooks

Execute actions at specific points:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "myapp.fullname" . }}-migration
  annotations:
    "helm.sh/hook": pre-upgrade,pre-install
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      containers:
      - name: migration
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        command: ["./migrate.sh"]
      restartPolicy: Never
```

**Hook Types:**
- `pre-install`: Before resources are installed
- `post-install`: After all resources are installed
- `pre-delete`: Before resources are deleted
- `post-delete`: After all resources are deleted
- `pre-upgrade`: Before resources are upgraded
- `post-upgrade`: After all resources are upgraded
- `pre-rollback`: Before rollback
- `post-rollback`: After rollback
- `test`: When `helm test` is run

## Testing

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "myapp.fullname" . }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: wget
    image: busybox
    command: ['wget']
    args: ['{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

```bash
# Run tests
helm test my-release

# Run tests with logs
helm test my-release --logs
```

## Helm Plugins

```bash
# List plugins
helm plugin list

# Install plugin
helm plugin install https://github.com/databus23/helm-diff

# Use diff plugin
helm diff upgrade my-release bitnami/nginx --values new-values.yaml

# Install secrets plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# Use secrets
helm secrets install my-release ./myapp -f secrets.yaml
```

## Repository Management

```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# List repositories
helm repo list

# Update repositories
helm repo update

# Remove repository
helm repo remove bitnami

# Search repository
helm search repo nginx

# Search hub
helm search hub wordpress
```

## Best Practices

1. **Version Control**
   - Store charts in Git
   - Use semantic versioning
   - Tag releases

2. **Values Organization**
   - Use descriptive names
   - Group related values
   - Document all values

3. **Templates**
   - Use helpers for common patterns
   - Keep templates simple
   - Add comments

4. **Testing**
   - Lint charts before packaging
   - Test installations
   - Use helm test

5. **Security**
   - Don't commit secrets
   - Use helm-secrets plugin
   - Scan charts for vulnerabilities

6. **Documentation**
   - Maintain README
   - Document values
   - Add NOTES.txt

## Troubleshooting

```bash
# Debug installation
helm install my-release ./myapp --debug --dry-run

# Get release manifest
helm get manifest my-release

# Get release values
helm get values my-release

# Get all release info
helm get all my-release

# View release history
helm history my-release

# Check release status
helm status my-release

# List all releases
helm list --all-namespaces

# Uninstall with keep history
helm uninstall my-release --keep-history
```

## Common Issues

1. **Chart not found**
   ```bash
   helm repo update
   helm search repo <chart-name>
   ```

2. **Values not applied**
   ```bash
   helm get values my-release
   helm upgrade my-release ./myapp --values values.yaml --debug
   ```

3. **Template errors**
   ```bash
   helm lint ./myapp
   helm template my-release ./myapp --debug
   ```

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Charts](https://github.com/helm/charts)
- [Artifact Hub](https://artifacthub.io/)
