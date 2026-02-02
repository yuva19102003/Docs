# Kubernetes Storage Overview

Understanding storage in Kubernetes for persistent data management.

## Storage Concepts

```
┌────────────────────────────────────────────────────┐
│              STORAGE HIERARCHY                     │
├────────────────────────────────────────────────────┤
│  Volume                                            │
│    ↓                                               │
│  PersistentVolume (PV)                            │
│    ↓                                               │
│  PersistentVolumeClaim (PVC)                      │
│    ↓                                               │
│  StorageClass                                      │
│    ↓                                               │
│  Pod Volume Mount                                  │
└────────────────────────────────────────────────────┘
```

## Volume Types

### Ephemeral Volumes

**emptyDir**: Temporary storage, deleted with pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: cache
      mountPath: /cache
  volumes:
  - name: cache
    emptyDir: {}
```

**emptyDir with size limit**:
```yaml
volumes:
- name: cache
  emptyDir:
    sizeLimit: 1Gi
```

**emptyDir in memory**:
```yaml
volumes:
- name: cache
  emptyDir:
    medium: Memory
    sizeLimit: 128Mi
```

### ConfigMap Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

### Secret Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: secrets
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: app-secrets
```

### HostPath Volume

Mount from host node (use with caution):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: host-data
      mountPath: /data
  volumes:
  - name: host-data
    hostPath:
      path: /mnt/data
      type: DirectoryOrCreate
```

**HostPath Types:**
- `DirectoryOrCreate`: Create if doesn't exist
- `Directory`: Must exist as directory
- `FileOrCreate`: Create file if doesn't exist
- `File`: Must exist as file
- `Socket`: Must exist as socket
- `CharDevice`: Must exist as character device
- `BlockDevice`: Must exist as block device

## Persistent Volumes

### PersistentVolume (PV)

Cluster-level storage resource:

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
  storageClassName: standard
  hostPath:
    path: /mnt/data
```

### Access Modes

- **ReadWriteOnce (RWO)**: Single node read-write
- **ReadOnlyMany (ROX)**: Multiple nodes read-only
- **ReadWriteMany (RWX)**: Multiple nodes read-write
- **ReadWriteOncePod (RWOP)**: Single pod read-write

### Reclaim Policies

- **Retain**: Manual reclamation
- **Delete**: Delete volume when claim is deleted
- **Recycle**: Basic scrub (deprecated)

### Volume Modes

- **Filesystem**: Mounted as filesystem (default)
- **Block**: Raw block device

## PersistentVolumeClaim (PVC)

Request for storage by user:

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
  storageClassName: standard
```

### Using PVC in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: pvc-example
```

## Storage Classes

Dynamic provisioning of storage:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### Volume Binding Modes

- **Immediate**: Provision immediately
- **WaitForFirstConsumer**: Wait until pod is scheduled

### Common Provisioners

**AWS EBS:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
```

**GCP Persistent Disk:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gcp-pd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

**Azure Disk:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
```

**NFS:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs
provisioner: example.com/nfs
parameters:
  server: nfs-server.example.com
  path: /exported/path
```

## Volume Snapshots

### VolumeSnapshotClass

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapclass
driver: ebs.csi.aws.com
deletionPolicy: Delete
```

### VolumeSnapshot

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: snapshot-example
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: pvc-example
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
```

## CSI (Container Storage Interface)

Standard interface for storage systems:

```
┌──────────────────────────────────────┐
│         Kubernetes                   │
└────────────┬─────────────────────────┘
             │
             │ CSI API
             │
┌────────────▼─────────────────────────┐
│       CSI Driver                     │
│  (AWS EBS, GCP PD, Azure Disk, etc) │
└────────────┬─────────────────────────┘
             │
             │
┌────────────▼─────────────────────────┐
│      Storage Backend                 │
└──────────────────────────────────────┘
```

### CSI Driver Deployment

```yaml
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: ebs.csi.aws.com
spec:
  attachRequired: true
  podInfoOnMount: false
  volumeLifecycleModes:
  - Persistent
  - Ephemeral
```

## StatefulSet with Storage

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 1Gi
```

## Volume Expansion

Enable in StorageClass:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable
provisioner: kubernetes.io/aws-ebs
allowVolumeExpansion: true
```

Expand PVC:

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
      storage: 20Gi  # Increased from 10Gi
  storageClassName: expandable
```

## Projected Volumes

Combine multiple volume sources:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: projected-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: all-in-one
      mountPath: /projected
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
          - key: username
            path: my-group/my-username
      - configMap:
          name: myconfigmap
          items:
          - key: config
            path: my-group/my-config
      - downwardAPI:
          items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
```

## Downward API Volume

Expose pod/container fields:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: downward-api-pod
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: podinfo
      mountPath: /etc/podinfo
  volumes:
  - name: podinfo
    downwardAPI:
      items:
      - path: "labels"
        fieldRef:
          fieldPath: metadata.labels
      - path: "annotations"
        fieldRef:
          fieldPath: metadata.annotations
      - path: "cpu_limit"
        resourceFieldRef:
          containerName: app
          resource: limits.cpu
```

## Storage Commands

```bash
# List PVs
kubectl get pv

# List PVCs
kubectl get pvc

# Describe PV
kubectl describe pv <pv-name>

# Describe PVC
kubectl describe pvc <pvc-name>

# List StorageClasses
kubectl get storageclass
kubectl get sc

# List VolumeSnapshots
kubectl get volumesnapshot

# Create PVC
kubectl apply -f pvc.yaml

# Delete PVC
kubectl delete pvc <pvc-name>

# Check PVC status
kubectl get pvc <pvc-name> -o jsonpath='{.status.phase}'
```

## Troubleshooting

```bash
# Check PVC binding
kubectl get pvc

# Check PV status
kubectl get pv

# Describe PVC for events
kubectl describe pvc <pvc-name>

# Check StorageClass
kubectl describe sc <storage-class-name>

# View pod events
kubectl describe pod <pod-name>

# Check CSI driver
kubectl get csidrivers

# View CSI node info
kubectl get csinodes
```

## Best Practices

1. **Use StorageClasses**
   - Dynamic provisioning
   - Standardize storage types
   - Set appropriate defaults

2. **Access Modes**
   - Choose appropriate mode
   - Consider multi-node access
   - Understand limitations

3. **Reclaim Policy**
   - Retain for production data
   - Delete for temporary data
   - Backup before deletion

4. **Resource Requests**
   - Request appropriate size
   - Plan for growth
   - Monitor usage

5. **Backup Strategy**
   - Use volume snapshots
   - Regular backup schedule
   - Test restore procedures

6. **Security**
   - Encrypt at rest
   - Use appropriate permissions
   - Isolate sensitive data

## References

- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [CSI](https://kubernetes-csi.github.io/docs/)
