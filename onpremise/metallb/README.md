# Install Guide

## Preparation in advance
- Note: When using ipvs mode of kube-proxy, `strictARP:true` setting is required

```yaml
kubectl edit configmap -n kube-system kube-proxy
...
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true

# or
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# restart
kubectl rollout restart -n kube-system daemonset kube-proxy
```

## Install With Helm

Install metallb.
```yaml
helm repo add metallb https://metallb.github.io/metallb

helm install metallb metallb/metallb -n metallb-system --create-namespace

# Example
helm install -n <네임스페이스> <릴리즈 이름> -f <브랜치별 helm values 파일명>.yaml metallb/metallb

# No memberlist required when installing with help. Automatically installed.
k get secret -n metallb-system
NAME                            TYPE                 DATA   AGE
metallb-memberlist              Opaque               1      2d
metallb-webhook-cert            Opaque               4      2d
sh.helm.release.v1.metallb.v1   helm.sh/release.v1   1      2d
```

Set metallb config.
```yaml
# metallb config 
cat <<EOF >> metallb-config.yaml
# apiversion
apiVersion: metallb.io/v1beta1 
kind: IPAddressPool
metadata:
  name: ip-pool
  namespace: metallb-system
spec:
  addresses:
  # Using ip address pool
  - 111.111.111.111 - 111.111.111.111 
  autoAssign: true
--- 
apiVersion: metallb.io/v1beta1 
# Use l2 mode
kind: L2Advertisement 
metadata:
  name: l2-network
  namespace: metallb-system
spec:
   # ipAddressPools
  ipAddressPools:
    - ip-pool
EOF
```

Check the ipaddrsspool after deleting the existing settings.

```yaml
# Check Settings
kubectl get validatingwebhookconfigurations

# Delete existing settings
kubectl delete validatingwebhookconfigurations  metallb-webhook-configuration

# Confirm deletion (no resource found should appear)
kubectl get validatingwebhookconfigurations

# Apply settings
kubectl apply -f metallb-config.yaml -n metallb-system

# Final confirmation
kubectl describe ipaddresspool.metallb.io --namespace metallb-system

kubectl get po -n metallb-system -o wide
```

### Reference
- https://github.com/metallb/metallb
