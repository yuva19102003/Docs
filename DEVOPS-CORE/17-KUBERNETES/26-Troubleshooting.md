# Kubernetes Troubleshooting Guide

Comprehensive guide to diagnosing and resolving common Kubernetes issues.

## Troubleshooting Workflow

```
1. Identify the Problem
   ↓
2. Check Pod Status
   ↓
3. View Logs
   ↓
4. Describe Resources
   ↓
5. Check Events
   ↓
6. Verify Configuration
   ↓
7. Test Connectivity
   ↓
8. Fix and Verify
```

## Pod Issues

### Pod Stuck in Pending

**Symptoms:**
```bash
kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
myapp     0/1     Pending   0          5m
```

**Diagnosis:**
```bash
# Describe pod
kubectl describe pod myapp

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check node resources
kubectl top nodes
kubectl describe nodes
```

**Common Causes:**
1. **Insufficient Resources**
   ```
   Events:
     Warning  FailedScheduling  pod didn't fit on any node
   ```
   **Solution:** Add nodes or reduce resource requests

2. **Node Selector Mismatch**
   ```yaml
   nodeSelector:
     disktype: ssd  # No nodes with this label
   ```
   **Solution:** Fix node selector or add label to nodes

3. **PVC Not Bound**
   ```bash
   kubectl get pvc
   ```
   **Solution:** Check PVC status and storage class

### Pod Stuck in ImagePullBackOff

**Symptoms:**
```bash
NAME      READY   STATUS             RESTARTS   AGE
myapp     0/1     ImagePullBackOff   0          2m
```

**Diagnosis:**
```bash
kubectl describe pod myapp
```

**Common Causes:**
1. **Image Doesn't Exist**
   ```
   Failed to pull image "myapp:1.0": not found
   ```
   **Solution:** Verify image name and tag

2. **Authentication Required**
   ```
   Failed to pull image: unauthorized
   ```
   **Solution:** Add imagePullSecrets
   ```yaml
   imagePullSecrets:
   - name: regcred
   ```

3. **Network Issues**
   ```bash
   # Test from node
   docker pull myapp:1.0
   ```

### Pod Stuck in CrashLoopBackOff

**Symptoms:**
```bash
NAME      READY   STATUS             RESTARTS   AGE
myapp     0/1     CrashLoopBackOff   5          5m
```

**Diagnosis:**
```bash
# View logs
kubectl logs myapp
kubectl logs myapp --previous

# Describe pod
kubectl describe pod myapp

# Check exit code
kubectl get pod myapp -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'
```

**Common Causes:**
1. **Application Error**
   ```bash
   # Check logs for errors
   kubectl logs myapp --previous
   ```

2. **Missing Dependencies**
   ```
   Error: Cannot connect to database
   ```
   **Solution:** Verify ConfigMap/Secret values

3. **Liveness Probe Failing**
   ```yaml
   livenessProbe:
     httpGet:
       path: /healthz
       port: 8080
     initialDelaySeconds: 30  # Increase if app is slow to start
   ```

### Pod in Error State

**Diagnosis:**
```bash
kubectl describe pod myapp
kubectl logs myapp
```

**Common Causes:**
1. **Init Container Failed**
   ```bash
   kubectl logs myapp -c init-container
   ```

2. **Volume Mount Issues**
   ```
   Error: failed to mount volume
   ```

3. **Security Context Issues**
   ```
   Error: container has runAsNonRoot and image has non-numeric user
   ```

## Service Issues

### Service Not Accessible

**Diagnosis:**
```bash
# Check service
kubectl get svc myapp
kubectl describe svc myapp

# Check endpoints
kubectl get endpoints myapp

# Test from within cluster
kubectl run test --rm -it --image=busybox --restart=Never -- wget -O- http://myapp
```

**Common Causes:**
1. **No Endpoints**
   ```bash
   kubectl get endpoints myapp
   # NAME    ENDPOINTS   AGE
   # myapp   <none>      5m
   ```
   **Solution:** Check pod selector matches
   ```bash
   kubectl get pods --show-labels
   kubectl get svc myapp -o yaml | grep selector
   ```

2. **Wrong Port**
   ```yaml
   ports:
   - port: 80
     targetPort: 8080  # Must match container port
   ```

3. **Readiness Probe Failing**
   ```bash
   kubectl describe pod myapp
   # Check readiness probe status
   ```

### LoadBalancer Pending

**Symptoms:**
```bash
kubectl get svc
NAME    TYPE           EXTERNAL-IP   PORT(S)
myapp   LoadBalancer   <pending>     80:30080/TCP
```

**Diagnosis:**
```bash
kubectl describe svc myapp
```

**Common Causes:**
1. **Cloud Provider Not Configured**
   - Verify cloud controller manager is running
   - Check cloud provider credentials

2. **Quota Exceeded**
   - Check cloud provider quotas
   - Verify billing is active

3. **Network Configuration**
   - Check VPC/subnet configuration
   - Verify security groups

## Networking Issues

### Pod-to-Pod Communication

**Test Connectivity:**
```bash
# Get pod IPs
kubectl get pods -o wide

# Test from one pod to another
kubectl exec -it pod1 -- ping <pod2-ip>
kubectl exec -it pod1 -- curl http://<pod2-ip>:8080
```

**Common Issues:**
1. **Network Policy Blocking**
   ```bash
   kubectl get networkpolicies
   kubectl describe networkpolicy <policy-name>
   ```

2. **CNI Plugin Issues**
   ```bash
   kubectl get pods -n kube-system | grep -E 'calico|flannel|weave'
   kubectl logs -n kube-system <cni-pod>
   ```

### DNS Issues

**Test DNS:**
```bash
# Test DNS resolution
kubectl run test --rm -it --image=busybox --restart=Never -- nslookup kubernetes.default

# Test service DNS
kubectl run test --rm -it --image=busybox --restart=Never -- nslookup myapp.default.svc.cluster.local

# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

**Common Issues:**
1. **CoreDNS Not Running**
   ```bash
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   ```

2. **DNS Configuration**
   ```bash
   kubectl get configmap -n kube-system coredns -o yaml
   ```

3. **Pod DNS Policy**
   ```yaml
   dnsPolicy: ClusterFirst  # Should be default
   ```

## Storage Issues

### PVC Stuck in Pending

**Diagnosis:**
```bash
kubectl get pvc
kubectl describe pvc myapp-pvc
```

**Common Causes:**
1. **No Storage Class**
   ```bash
   kubectl get storageclass
   ```
   **Solution:** Create or specify storage class

2. **No Available PV**
   ```bash
   kubectl get pv
   ```
   **Solution:** Create PV or use dynamic provisioning

3. **Access Mode Mismatch**
   ```yaml
   accessModes:
   - ReadWriteOnce  # Must match PV
   ```

### Volume Mount Failures

**Diagnosis:**
```bash
kubectl describe pod myapp
# Check events for mount errors
```

**Common Issues:**
1. **Permission Denied**
   ```yaml
   securityContext:
     fsGroup: 2000  # Add fsGroup
   ```

2. **Volume Not Found**
   ```bash
   kubectl get pvc
   kubectl get pv
   ```

## Node Issues

### Node NotReady

**Diagnosis:**
```bash
kubectl get nodes
kubectl describe node <node-name>

# Check kubelet
ssh <node>
systemctl status kubelet
journalctl -u kubelet -f
```

**Common Causes:**
1. **Kubelet Not Running**
   ```bash
   systemctl start kubelet
   systemctl enable kubelet
   ```

2. **Disk Pressure**
   ```bash
   df -h
   # Clean up disk space
   ```

3. **Memory Pressure**
   ```bash
   free -h
   # Add more memory or reduce workload
   ```

### Node Disk Pressure

**Diagnosis:**
```bash
kubectl describe node <node-name>
# Check conditions

ssh <node>
df -h
```

**Solution:**
```bash
# Clean up images
docker system prune -a

# Clean up logs
journalctl --vacuum-time=3d

# Clean up pods
kubectl delete pods --field-selector=status.phase==Succeeded
```

## Resource Issues

### Out of Memory (OOM)

**Symptoms:**
```bash
kubectl get pods
NAME      READY   STATUS      RESTARTS   AGE
myapp     0/1     OOMKilled   1          2m
```

**Diagnosis:**
```bash
kubectl describe pod myapp
# Check last state: OOMKilled

kubectl top pod myapp
```

**Solution:**
```yaml
resources:
  limits:
    memory: "512Mi"  # Increase memory limit
  requests:
    memory: "256Mi"
```

### CPU Throttling

**Diagnosis:**
```bash
kubectl top pods
kubectl top nodes

# Check metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods
```

**Solution:**
```yaml
resources:
  limits:
    cpu: "1000m"  # Increase CPU limit
  requests:
    cpu: "500m"
```

## Configuration Issues

### ConfigMap/Secret Not Found

**Diagnosis:**
```bash
kubectl get configmap
kubectl get secret

kubectl describe pod myapp
# Check events
```

**Solution:**
```bash
# Create missing ConfigMap
kubectl create configmap myapp-config --from-literal=key=value

# Verify reference
kubectl get pod myapp -o yaml | grep -A 5 configMap
```

### Environment Variable Issues

**Diagnosis:**
```bash
# Check environment variables
kubectl exec myapp -- env

# Check pod spec
kubectl get pod myapp -o yaml | grep -A 10 env
```

## RBAC Issues

### Permission Denied

**Diagnosis:**
```bash
# Check permissions
kubectl auth can-i create pods
kubectl auth can-i create pods --as=system:serviceaccount:default:myapp-sa

# Check role bindings
kubectl get rolebindings
kubectl describe rolebinding <binding-name>
```

**Solution:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-binding
subjects:
- kind: ServiceAccount
  name: myapp-sa
roleRef:
  kind: Role
  name: myapp-role
  apiGroup: rbac.authorization.k8s.io
```

## Debugging Tools

### Debug Container

```bash
# Add ephemeral debug container
kubectl debug myapp -it --image=busybox --target=myapp

# Debug node
kubectl debug node/<node-name> -it --image=ubuntu
```

### Network Debug Pod

```bash
kubectl run netshoot --rm -it --image=nicolaka/netshoot --restart=Never -- bash

# Inside pod
ping <ip>
nslookup <service>
curl http://<service>
traceroute <ip>
```

### Port Forward for Debugging

```bash
# Forward pod port
kubectl port-forward myapp 8080:80

# Forward service port
kubectl port-forward svc/myapp 8080:80

# Test locally
curl http://localhost:8080
```

## Useful Commands

### Get Events

```bash
# All events
kubectl get events --sort-by='.lastTimestamp'

# Events for specific resource
kubectl get events --field-selector involvedObject.name=myapp

# Watch events
kubectl get events --watch
```

### Check Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods

# Pod resources in namespace
kubectl top pods -n production
```

### View Logs

```bash
# Current logs
kubectl logs myapp

# Previous container logs
kubectl logs myapp --previous

# Follow logs
kubectl logs -f myapp

# Logs from specific container
kubectl logs myapp -c container-name

# Logs with timestamps
kubectl logs myapp --timestamps

# Tail logs
kubectl logs myapp --tail=100
```

### Describe Resources

```bash
kubectl describe pod myapp
kubectl describe node <node-name>
kubectl describe svc myapp
kubectl describe pvc myapp-pvc
```

## Common Error Messages

### "ImagePullBackOff"
- Image doesn't exist
- Wrong image name/tag
- Authentication required
- Network issues

### "CrashLoopBackOff"
- Application error
- Missing dependencies
- Liveness probe failing
- Wrong command/args

### "Pending"
- Insufficient resources
- Node selector mismatch
- PVC not bound
- Taints/tolerations

### "Error"
- Init container failed
- Volume mount issues
- Security context issues
- Command failed

### "OOMKilled"
- Memory limit too low
- Memory leak in application
- Increase memory limits

## Best Practices

1. **Enable Logging**
   - Centralized logging
   - Structured logs
   - Appropriate log levels

2. **Monitor Resources**
   - Set up metrics collection
   - Create alerts
   - Regular reviews

3. **Use Health Checks**
   - Liveness probes
   - Readiness probes
   - Startup probes

4. **Document Issues**
   - Keep runbooks
   - Document solutions
   - Share knowledge

5. **Test Changes**
   - Test in non-production
   - Use dry-run
   - Gradual rollouts

## References

- [Troubleshooting Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshooting Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)
- [Debug Running Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)
