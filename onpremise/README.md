## Certmanager Install

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.3/cert-manager.yaml

k get po -n cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-75f8fbb664-q4k6f              1/1     Running   0          33s
cert-manager-cainjector-69448777d5-hnz5d   1/1     Running   0          33s
cert-manager-webhook-694b449697-7d4zp      1/1     Running   0          33s
```

## NFS Provisioner Install
```bash
k create ns nfs-provisioner

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
"nfs-subdir-external-provisioner" has been added to your repositories


helm install --kubeconfig=$KUBE_CONFIG  nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=<nfs-server-ip> --set nfs.path=<nfs-path> -n nfs-provisioner

kubectl --kubeconfig=$KUBE_CONFIG get storageclass
NAME                        PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
nfs-client                  cluster.local/nfs-subdir-external-provisioner   Delete          Immediate              true                   30s

k get po -n nfs-provisioner
NAME                                               READY   STATUS    RESTARTS   AGE
nfs-subdir-external-provisioner-5577c5d8ff-gm9p8   1/1     Running   0          16
```

## Use AWS Route53 Domain
After creating the secret key and clusterissuer as a yaml file, certificate and ingress are generated as helm chart.

## Create Kubernetes Secret using AWS Secret Key

```bash
kubectl create secret generic route53-credentials-secret \
--from-literal=secret-access-key=YOUR_AWS_SECRET_ACCESS_KEY

or

apiVersion: v1
kind: Secret
metadata:
  name: route53-credentials-secret
type: Opaque
stringData:
  secret-access-key: <aws-secret-access-key>

k apply -f route53-credentials-secret.yaml -n cert-manager

```

## Create ClusterIssuer

```bash
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: route53-issuer
spec:
  acme:
    email: <your email>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: route53-access-key
    solvers:
    - dns01:
        route53:
          region: ap-northeast-2 # Adjust this according to your AWS region
          accessKeyID: <your accessKey> # Avoid hardcoding credentials if possible
          secretAccessKeySecretRef:
            name: route53-credentials-secret
            key: secret-access-key
```

## Use GCP CloudDNS Domain
After creating the secret key and clusterissuer as a yaml file, certificate and ingress are generated as helm chart.

## Create Kubernetes Secret using GCP ServiceAccount

```bash
kubectl create secret generic clouddns-credentials-secret \
--from-file=key.json=/path/to/service-account-key.json \
--namespace=[YOUR-CERT-MANAGER-NAMESPACE]

or

cat x.json |base64

apiVersion: v1
data:
  key.json: <base64 encoded service accountkey>
kind: Secret
metadata:
  name: clouddns-credentials-secret
  namespace: cert-manager
type: Opaque
```

## Create ClusterIssuer

```bash
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: clouddns-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: <your email>
    privateKeySecretRef:
      name: clouddns-account-key
    solvers:
    - dns01:
        cloudDNS:
          project: <your project>
          serviceAccountSecretRef:
            name: clouddns-credentials-secret # secret name
            key: key.json # secret data name
```


