# Persistent Volumes (PV) and Persistent Volume Claims (PVC)

Persistent storage in Kubernetes that exists beyond pod lifecycle.

## PV and PVC Overview

```
┌─────────────────────────────────────────────────┐
│         Storage Provisioning Flow              │
├─────────────────────────────────────────────────┤
│                                                 │
│  Admin Creates PV  →  User Creates PVC         │
│         ↓                    ↓                  │
│    PV Available  →  PVC Binds to PV            │
│                          ↓                      │
│                   Pod Uses PVC                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Persistent Volume (PV)

Cluster-level storage resource provisioned by administrator.

### Basic PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data"
```

### PV with NFS

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.example.com
    path: "/exported/path"
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
```

### PV with AWS EBS

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: aws-ebs-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  awsElasticBlockStore:
    volumeID: vol-0123456789abcdef0
    fsType: ext4
  persistentVolumeReclaimPolicy: Delete
  storageClassName: gp3
```

### PV with GCP Persistent Disk

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gcp-pd-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    pdName: my-data-disk
    fsType: ext4
  persistentVolumeReclaimPolicy: Delete
  storageClassName: pd-ssd
```

### PV with Azure Disk

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: azure-disk-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  azureDisk:
    diskName: myAzureDisk
    diskURI: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Compute/disks/myAzureDisk
    kind: Managed
    fsType: ext4
  persistentVolumeReclaimPolicy: Delete
  storageClassName: managed-premium
```

## Access Modes

### ReadWriteOnce (RWO)
Single node can mount as read-write

```yaml
accessModes:
  - ReadWriteOnce
```

**Use Cases:**
- Databases (MySQL, PostgreSQL)
- Single-instance applications
- Block storage (EBS, Azure Disk)

### ReadOnlyMany (ROX)
Multiple nodes can mount as read-only

```yaml
accessModes:
  - ReadOnlyMany
```

**Use Cases:**
- Static content
- Shared configuration
- Read replicas

### ReadWriteMany (RWX)
Multiple nodes can mount as read-write

```yaml
accessModes:
  - ReadWriteMany
```

**Use Cases:**
- Shared file systems (NFS, CephFS)
- Multi-pod applications
- Content management systems

### ReadWriteOncePod (RWOP)
Single pod can mount as read-write

```yaml
accessModes:
  - ReadWriteOncePod
```

**Use Cases:**
- Strict single-pod access
- Enhanced data safety
- Kubernetes 1.22+

## Reclaim Policies

### Retain
Manual reclamation after PVC deletion

```yaml
persistentVolumeReclaimPolicy: Retain
```

**Behavior:**
- PV remains after PVC deletion
- Data preserved
- Manual cleanup required
- PV status: Released

### Delete
Automatic deletion of PV and storage

```yaml
persistentVolumeReclaimPolicy: Delete
```

**Behavior:**
- PV deleted when PVC deleted
- Storage asset deleted (cloud disk)
- Data lost
- Default for dynamic provisioning

### Recycle (Deprecated)
Basic scrub and make available again

```yaml
persistentVolumeReclaimPolicy: Recycle
```

**Behavior:**
- Deprecated, use Delete instead
- Runs `rm -rf /volume/*`
- PV becomes Available

## Persistent Volume Claim (PVC)

User request for storage.

### Basic PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

### PVC with Selector

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-with-selector
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  selector:
    matchLabels:
      environment: production
      type: ssd
  storageClassName: fast
```

### PVC with Volume Mode

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: block-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-block
```

## Using PVC in Pods

### Single Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: pvc-example
```

### Multiple Containers Sharing PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-pvc-pod
spec:
  containers:
  - name: writer
    image: busybox
    command: ['sh', '-c', 'while true; do echo $(date) >> /data/log.txt; sleep 5; done']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  
  - name: reader
    image: busybox
    command: ['sh', '-c', 'tail -f /data/log.txt']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  
  volumes:
  - name: shared-data
    persistentVolumeClaim:
      claimName: shared-pvc
```

### Deployment with PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: webapp-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webapp-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

## StatefulSet with PVC

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  serviceName: database
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        env:
        - name: POSTGRES_PASSWORD
          value: password
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi
```

## PV and PVC Binding

### Manual Binding

```yaml
# PV with label
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-manual
  labels:
    type: local
    environment: production
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
  storageClassName: manual
---
# PVC with selector
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-manual
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  selector:
    matchLabels:
      type: local
      environment: production
  storageClassName: manual
```

### Binding Process

```
1. User creates PVC
2. Control loop watches for new PVCs
3. Finds matching PV based on:
   - Storage class
   - Access modes
   - Storage size
   - Selector (if specified)
4. Binds PVC to PV
5. PVC status: Bound
```

## PV and PVC Lifecycle

```
┌──────────────────────────────────────────────┐
│         PV Lifecycle States                  │
├──────────────────────────────────────────────┤
│                                              │
│  Available → Bound → Released → Failed      │
│                                              │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│         PVC Lifecycle States                 │
├──────────────────────────────────────────────┤
│                                              │
│  Pending → Bound → (Pod uses) → Deleted     │
│                                              │
└──────────────────────────────────────────────┘
```

### PV States

**Available**: Ready for binding
**Bound**: Bound to PVC
**Released**: PVC deleted, but not reclaimed
**Failed**: Automatic reclamation failed

### PVC States

**Pending**: Waiting for PV
**Bound**: Bound to PV

## Volume Expansion

### Enable Expansion in StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
allowVolumeExpansion: true
```

### Expand PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: expandable-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi  # Increased from 10Gi
  storageClassName: expandable
```

### Expansion Process

```bash
# 1. Edit PVC to increase size
kubectl edit pvc expandable-pvc

# 2. Check expansion status
kubectl describe pvc expandable-pvc

# 3. For some storage types, restart pod
kubectl delete pod <pod-name>

# 4. Verify new size
kubectl exec <pod-name> -- df -h
```

## Volume Cloning

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cloned-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  dataSource:
    kind: PersistentVolumeClaim
    name: source-pvc
  storageClassName: standard
```

## Volume Snapshots

### VolumeSnapshot

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: snapshot-example
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: source-pvc
```

### Restore from Snapshot

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  dataSource:
    name: snapshot-example
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  storageClassName: standard
```

## Local Persistent Volumes

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node-1
```

## Commands

```bash
# List PVs
kubectl get pv

# List PVCs
kubectl get pvc

# Describe PV
kubectl describe pv pv-example

# Describe PVC
kubectl describe pvc pvc-example

# Get PV details
kubectl get pv pv-example -o yaml

# Get PVC details
kubectl get pvc pvc-example -o yaml

# Check PVC status
kubectl get pvc pvc-example -o jsonpath='{.status.phase}'

# Delete PVC
kubectl delete pvc pvc-example

# Delete PV
kubectl delete pv pv-example

# Watch PVC status
kubectl get pvc --watch
```

## Troubleshooting

### PVC Stuck in Pending

```bash
# Check PVC events
kubectl describe pvc pvc-example

# Check available PVs
kubectl get pv

# Check storage class
kubectl get storageclass

# Common issues:
# - No matching PV available
# - Storage class doesn't exist
# - Access mode mismatch
# - Size mismatch
```

### PV Not Binding

```bash
# Check PV status
kubectl get pv

# Check PV details
kubectl describe pv pv-example

# Verify:
# - Storage class matches
# - Access modes compatible
# - Size sufficient
# - Selector matches (if used)
```

### Volume Mount Failures

```bash
# Check pod events
kubectl describe pod pod-name

# Check volume status
kubectl get pvc

# Common issues:
# - PVC not bound
# - Permission issues
# - Volume not available on node
```

## Best Practices

1. **Use StorageClasses**
   - Dynamic provisioning
   - Standardize storage types
   - Simplify management

2. **Set Appropriate Reclaim Policy**
   - Retain for production data
   - Delete for temporary data
   - Consider backup strategy

3. **Choose Correct Access Mode**
   - RWO for single-node apps
   - RWX for multi-node apps
   - Consider performance implications

4. **Size Appropriately**
   - Plan for growth
   - Monitor usage
   - Enable expansion if needed

5. **Use Labels and Selectors**
   - Organize PVs
   - Control binding
   - Manage lifecycle

6. **Backup Important Data**
   - Use volume snapshots
   - Regular backup schedule
   - Test restore procedures

7. **Monitor Storage**
   - Track usage
   - Set up alerts
   - Plan capacity

## References

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Volume Snapshots](https://kubernetes.io/docs/concepts/storage/volume-snapshots/)
