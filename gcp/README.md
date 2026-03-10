
# GCP Helm Chart Templates

Helm chart templates for GKE and related GCP services, designed for use with ArgoCD.

## Charts

### gke-use-firestore

Helm chart template for applications on GKE using Firestore. Includes managed certificates, backend/frontend configs, and external secrets.

### gke-use-firestore-shared-vpc

Similar to `gke-use-firestore` but configured for GKE clusters running in a shared VPC environment.

### gke-use-nfs-server

Helm chart template for applications on GKE using NFS server for persistent storage.

### gke-use-pd-csi

Helm chart template for applications on GKE using Persistent Disk CSI driver for storage.

### external-dns

ExternalDNS deployment for GCP Cloud DNS, managed via helmfile.

### haproxy

HAProxy deployment chart for GCP environments.

## GKE Storage Classes

```bash
kubectl get storageclasses.storage.k8s.io
NAME                        PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION
enterprise-multishare-rwx   filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true
enterprise-rwx              filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true
nfs-client                  cluster.local/nfs-subdir-external-provisioner   Delete          Immediate              true
premium-rwo                 pd.csi.storage.gke.io                           Delete          WaitForFirstConsumer   true
premium-rwx                 filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true
standard                    kubernetes.io/gce-pd                            Delete          Immediate              true
standard-rwo (default)      pd.csi.storage.gke.io                           Delete          WaitForFirstConsumer   true
standard-rwx                filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true
```

## Reference

- [External Secrets Operator](https://external-secrets.io/)
- [GKE Storage Classes](https://cloud.google.com/kubernetes-engine/docs/concepts/storage-overview)
- [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
