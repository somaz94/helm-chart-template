
## GKE Storage Class ##
k get storageclasses.storage.k8s.io
NAME                        PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
enterprise-multishare-rwx   filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true                   34d
enterprise-rwx              filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true                   34d
nfs-client                  cluster.local/nfs-subdir-external-provisioner   Delete          Immediate              true                   21d
premium-rwo                 pd.csi.storage.gke.io                           Delete          WaitForFirstConsumer   true                   34d
premium-rwx                 filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true                   34d
standard                    kubernetes.io/gce-pd                            Delete          Immediate              true                   34d
standard-rwo (default)      pd.csi.storage.gke.io                           Delete          WaitForFirstConsumer   true                   34d
standard-rwx                filestore.csi.storage.gke.io                    Delete          WaitForFirstConsumer   true                   34d

## External Secret ##
https://github.com/external-secrets/kubernetes-external-secrets/tree/master
