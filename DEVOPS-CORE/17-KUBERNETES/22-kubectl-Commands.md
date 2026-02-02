# kubectl Commands Reference

Comprehensive guide to kubectl commands for managing Kubernetes clusters.

## kubectl Basics

### Configuration

```bash
# View kubeconfig
kubectl config view

# Get current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>

# Set namespace
kubectl config set-context --current --namespace=<namespace>

# Set cluster
kubectl config set-cluster <cluster-name> --server=https://...

# Set credentials
kubectl config set-credentials <user-name> --token=<token>
```

### Cluster Info

```bash
# Cluster information
kubectl cluster-info

# Cluster version
kubectl version

# API resources
kubectl api-resources

# API versions
kubectl api-versions

# Component status
kubectl get componentstatuses
kubectl get cs
```

## Resource Management

### Get Resources

```bash
# List pods
kubectl get pods
kubectl get po

# List all resources
kubectl get all

# List with more details
kubectl get pods -o wide

# List in all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A

# List with labels
kubectl get pods --show-labels

# List specific columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Watch resources
kubectl get pods --watch
kubectl get pods -w

# Sort by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp

# Filter by field
kubectl get pods --field-selector status.phase=Running
```

### Describe Resources

```bash
# Describe pod
kubectl describe pod <pod-name>

# Describe node
kubectl describe node <node-name>

# Describe service
kubectl describe service <service-name>

# Describe all pods
kubectl describe pods
```

### Create Resources

```bash
# Create from file
kubectl create -f <file.yaml>

# Create from directory
kubectl create -f <directory>/

# Create from URL
kubectl create -f https://example.com/resource.yaml

# Create namespace
kubectl create namespace <namespace-name>

# Create deployment
kubectl create deployment nginx --image=nginx

# Create service
kubectl create service clusterip my-service --tcp=80:8080

# Create configmap
kubectl create configmap my-config --from-literal=key=value

# Create secret
kubectl create secret generic my-secret --from-literal=password=secret123

# Create job
kubectl create job test --image=busybox -- echo "Hello"

# Create cronjob
kubectl create cronjob backup --image=backup:latest --schedule="0 2 * * *" -- backup.sh
```

### Apply Resources

```bash
# Apply configuration
kubectl apply -f <file.yaml>

# Apply directory
kubectl apply -f <directory>/

# Apply with recursive
kubectl apply -f <directory>/ -R

# Apply with prune
kubectl apply -f <file.yaml> --prune -l app=myapp

# Server-side apply
kubectl apply -f <file.yaml> --server-side

# Dry run
kubectl apply -f <file.yaml> --dry-run=client
kubectl apply -f <file.yaml> --dry-run=server
```

### Edit Resources

```bash
# Edit pod
kubectl edit pod <pod-name>

# Edit deployment
kubectl edit deployment <deployment-name>

# Edit with specific editor
KUBE_EDITOR="nano" kubectl edit pod <pod-name>
```

### Delete Resources

```bash
# Delete pod
kubectl delete pod <pod-name>

# Delete from file
kubectl delete -f <file.yaml>

# Delete all pods
kubectl delete pods --all

# Delete with label selector
kubectl delete pods -l app=myapp

# Force delete
kubectl delete pod <pod-name> --grace-period=0 --force

# Delete namespace (and all resources)
kubectl delete namespace <namespace-name>
```

## Pod Operations

### Logs

```bash
# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Logs from specific container
kubectl logs <pod-name> -c <container-name>

# Previous container logs
kubectl logs <pod-name> --previous

# Logs with timestamps
kubectl logs <pod-name> --timestamps

# Tail logs
kubectl logs <pod-name> --tail=100

# Logs since time
kubectl logs <pod-name> --since=1h
kubectl logs <pod-name> --since-time=2024-01-01T00:00:00Z

# Logs from all containers
kubectl logs <pod-name> --all-containers
```

### Execute Commands

```bash
# Execute command
kubectl exec <pod-name> -- ls /

# Interactive shell
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- /bin/sh

# Execute in specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash

# Execute with stdin
echo "SELECT * FROM users;" | kubectl exec -i <pod-name> -- mysql -u root -p
```

### Port Forwarding

```bash
# Forward pod port
kubectl port-forward <pod-name> 8080:80

# Forward service port
kubectl port-forward service/<service-name> 8080:80

# Forward deployment port
kubectl port-forward deployment/<deployment-name> 8080:80

# Listen on all addresses
kubectl port-forward --address 0.0.0.0 <pod-name> 8080:80
```

### Copy Files

```bash
# Copy from pod
kubectl cp <pod-name>:/path/to/file ./local-file

# Copy to pod
kubectl cp ./local-file <pod-name>:/path/to/file

# Copy from specific container
kubectl cp <pod-name>:/path/to/file ./local-file -c <container-name>
```

### Attach to Pod

```bash
# Attach to running container
kubectl attach <pod-name>

# Attach with stdin
kubectl attach <pod-name> -i

# Attach to specific container
kubectl attach <pod-name> -c <container-name>
```

## Deployment Operations

### Scale

```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=5

# Scale replicaset
kubectl scale replicaset <rs-name> --replicas=3

# Scale statefulset
kubectl scale statefulset <sts-name> --replicas=3

# Autoscale
kubectl autoscale deployment <deployment-name> --min=2 --max=10 --cpu-percent=80
```

### Rollout

```bash
# Check rollout status
kubectl rollout status deployment/<deployment-name>

# View rollout history
kubectl rollout history deployment/<deployment-name>

# View specific revision
kubectl rollout history deployment/<deployment-name> --revision=2

# Rollback to previous version
kubectl rollout undo deployment/<deployment-name>

# Rollback to specific revision
kubectl rollout undo deployment/<deployment-name> --to-revision=2

# Pause rollout
kubectl rollout pause deployment/<deployment-name>

# Resume rollout
kubectl rollout resume deployment/<deployment-name>

# Restart deployment
kubectl rollout restart deployment/<deployment-name>
```

### Update

```bash
# Set image
kubectl set image deployment/<deployment-name> <container-name>=<new-image>

# Set resources
kubectl set resources deployment/<deployment-name> -c=<container-name> --limits=cpu=200m,memory=512Mi

# Set env variable
kubectl set env deployment/<deployment-name> KEY=value

# Set service account
kubectl set serviceaccount deployment/<deployment-name> <sa-name>
```

## Node Operations

```bash
# List nodes
kubectl get nodes

# Describe node
kubectl describe node <node-name>

# Cordon node (mark unschedulable)
kubectl cordon <node-name>

# Uncordon node
kubectl uncordon <node-name>

# Drain node (evict pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Taint node
kubectl taint nodes <node-name> key=value:NoSchedule

# Remove taint
kubectl taint nodes <node-name> key:NoSchedule-

# Label node
kubectl label nodes <node-name> disktype=ssd

# Remove label
kubectl label nodes <node-name> disktype-
```

## Label and Annotation Operations

```bash
# Add label
kubectl label pod <pod-name> environment=production

# Update label
kubectl label pod <pod-name> environment=staging --overwrite

# Remove label
kubectl label pod <pod-name> environment-

# Show labels
kubectl get pods --show-labels

# Filter by label
kubectl get pods -l environment=production
kubectl get pods -l 'environment in (production,staging)'

# Add annotation
kubectl annotate pod <pod-name> description="Production pod"

# Remove annotation
kubectl annotate pod <pod-name> description-
```

## Output Formats

```bash
# YAML output
kubectl get pod <pod-name> -o yaml

# JSON output
kubectl get pod <pod-name> -o json

# Wide output
kubectl get pods -o wide

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# Go template
kubectl get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'

# Name only
kubectl get pods -o name
```

## Resource Quotas and Limits

```bash
# View resource usage
kubectl top nodes
kubectl top pods

# View resource quotas
kubectl get resourcequota

# View limit ranges
kubectl get limitrange

# Describe quota
kubectl describe resourcequota <quota-name>
```

## Debugging

```bash
# Run debug pod
kubectl run debug --image=busybox --rm -it --restart=Never -- sh

# Debug with specific image
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- bash

# Debug node
kubectl debug node/<node-name> -it --image=ubuntu

# Debug pod (ephemeral container)
kubectl debug <pod-name> -it --image=busybox --target=<container-name>

# Events
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=<pod-name>
```

## Advanced Operations

### Patch

```bash
# Strategic merge patch
kubectl patch deployment <deployment-name> -p '{"spec":{"replicas":5}}'

# JSON patch
kubectl patch pod <pod-name> --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx:1.22"}]'

# Merge patch
kubectl patch service <service-name> --type='merge' -p '{"spec":{"type":"LoadBalancer"}}'
```

### Replace

```bash
# Replace resource
kubectl replace -f <file.yaml>

# Force replace
kubectl replace -f <file.yaml> --force
```

### Wait

```bash
# Wait for condition
kubectl wait --for=condition=Ready pod/<pod-name>

# Wait for deletion
kubectl wait --for=delete pod/<pod-name> --timeout=60s

# Wait for rollout
kubectl wait --for=condition=Available deployment/<deployment-name>
```

### Diff

```bash
# Show differences
kubectl diff -f <file.yaml>
```

## Plugin Management

```bash
# List plugins
kubectl plugin list

# Install krew (plugin manager)
kubectl krew install <plugin-name>

# Update plugins
kubectl krew update
kubectl krew upgrade
```

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# With completion
complete -F __start_kubectl k
```

## kubectl Cheat Sheet

```bash
# Quick reference
kubectl get pods                    # List pods
kubectl describe pod <name>         # Describe pod
kubectl logs <pod>                  # View logs
kubectl exec -it <pod> -- bash      # Shell into pod
kubectl apply -f <file>             # Apply config
kubectl delete pod <name>           # Delete pod
kubectl get svc                     # List services
kubectl get nodes                   # List nodes
kubectl top pods                    # Resource usage
kubectl rollout restart deploy/<name> # Restart deployment
```

## References

- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl Commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
