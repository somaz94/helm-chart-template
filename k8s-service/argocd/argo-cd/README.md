# ArgoCD Installation Guide(Helm)

<br/>

## Table of Contents
1. [Installing ArgoCD](#installing-argocd)
2. [Installing cert-manager and Let's Encrypt Settings](#installing-cert-manager-and-lets-encrypt-settings)
3. [Adding Git Source Repository](#adding-git-source-repository)
4. [Helm Configuration](#helm-configuration)
5. [Additional Notes](#additional-notes)

<br/>

## Installing ArgoCD
```bash
# Normal mode
helm install argocd . -n argocd -f ./values/mgmt-single.yaml --create-namespace

# Normal mode with TLS
helm install argocd . -n argocd -f ./values/mgmt-tls-single.yaml --create-namespace

# HA mode
helm install argocd . -n argocd -f ./values/mgmt-ha.yaml --create-namespace

# HA mode with TLS
helm install argocd . -n argocd -f ./values/mgmt-tls-ha.yaml --create-namespace
```

<br/>

## Installing cert-manager and Let's Encrypt Settings
For detailed instructions, follow the guide: [certmanager-letsencrypt](https://github.com/somaz94/certmanager-letsencrypt).

<br/>

## Adding Git Source Repository
Before registering the git source repo, generate the ssh key and register it with the repo:

```bash
ssh-keygen -t rsa -f ~/.ssh/[KEY_FILENAME] -C [USERNAME] 	# rsa
ssh-keygen -m PEM -t rsa -f ~/.ssh/[KEY_FILENAME] -C [USERNAME]	# pem

kubectl apply -f repo-secret.yaml -n argocd
```

Note: When using a private Gitlab instance, you need to add the Gitlab server's SSH host key to ArgoCD's known_hosts configuration:
```bash
# Get your Gitlab host key
ssh-keyscan gitlab.your-domain.com

# Example output:
# gitlab.your-domain.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwzyYtyGeO...
# gitlab.your-domain.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHA...
# gitlab.your-domain.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDB2NGVSx5...

# Edit ArgoCD known_hosts ConfigMap
kubectl edit cm -n argocd argocd-ssh-known-hosts-cm

# Add the output from ssh-keyscan to the end of ssh_known_hosts section in the ConfigMap
# Example structure:
# data:
#   ssh_known_hosts: |
#     [existing entries...]
#     gitlab.your-domain.com ssh-rsa AAAAB3NzaC1...
```

<br/>

## Helm Configuration
### Helmfile Configuration
The helmfile.yaml contains the following configuration:

```yaml
repositories:
  - name: argo
    url: https://argoproj.github.io/argo-helm
  - name: dandydeveloper
    url: https://dandydeveloper.github.io/charts/

releases:
  - name: argocd
    namespace: argocd
    createNamespace: true
    chart: ./
    version: 7.4.7
    values:
      - values/ha.yaml

hooks:
  - events: ["presync"]
    showlogs: true
    command: "helm"
    args:
      - "dependency"
      - "update"
      - "."

  - events: ["presync"]
    showlogs: true
    command: "kubectl"
    args:
      - "create"
      - "namespace"
      - "argocd"
      - "--dry-run=client"
      - "-o"
      - "yaml"
      - "||"
      - "true"
```

### Common Helm Commands
```bash
# Install using helmfile
helmfile sync

# Update dependencies
helm dependency update

# Upgrade existing installation
helm upgrade argocd . -n argocd -f values/ha.yaml

# Rollback to previous version
helm rollback argocd [REVISION] -n argocd

# List all releases
helm list -n argocd

# Get release status
helm status argocd -n argocd

# Uninstall release
helm uninstall argocd -n argocd
```

<br/>

## Additional Notes
- Make sure to modify the `Domain`, `host`, and parts in all yaml files
- Adjust the key details within the `repo-secret.yaml` file as necessary
- For HA mode, ensure your cluster has sufficient resources
- Regular backup of ArgoCD configurations is recommended
- Monitor the ArgoCD metrics for performance and health
- Consider setting up alerts for critical events
- Review security best practices for production deployments

