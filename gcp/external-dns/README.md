# External DNS Installation Guide

<br/>

## Table of Contents
1. [Installing External DNS](#installing-external-dns)
2. [Adding IAM Policy](#adding-iam-policy)
3. [Annotations Examples](#annotations-examples)
4. [Additional Notes](#additional-notes)

<br/>

## Installing External DNS
```bash
# Add External DNS helm repository
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

# Create namespace
kubectl create namespace external-dns

# Using direct helm install
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --set provider.name=google \
  --set extraArgs[0]="--google-zone-visibility=public" \
  --set extraArgs[1]="--google-project=dns-project" \
  --set env[0].name=GOOGLE_APPLICATION_CREDENTIALS \
  --set env[0].value=/etc/secrets/service-account/credentials.json \
  --set extraVolumes[0].name=google-service-account \
  --set extraVolumes[0].secret.secretName=external-dns \
  --set extraVolumeMounts[0].name=google-service-account \
  --set extraVolumeMounts[0].mountPath=/etc/secrets/service-account/ \
  --set logFormat=json \
  --set policy=upsert-only \

# Or using values file (recommended)
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  -f clouddns-values.yaml
```

<br/>

## Adding IAM Policy
External DNS needs permissions to modify Cloud DNS records. Create a Service Account with the following roles:

```bash
# Create a Service Account
export SA_NAME="external-dns-sa"
export PROJECT_ID="your-project-id"

gcloud iam service-accounts create $SA_NAME \
  --display-name "External DNS"

# Grant DNS Administrator role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/dns.admin"

# Create and download the key
gcloud iam service-accounts keys create credentials.json \
  --iam-account=$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com

# Create Kubernetes Secret
kubectl create secret generic external-dns \
  --from-file=credentials.json \
  --namespace external-dns
```

<br/>

## Annotations Examples
External DNS supports various annotations to configure DNS records. Here are some common examples:

### A Record Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  annotations:
    external-dns.alpha.kubernetes.io/hostname: app.example.com
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app
```

### Common Annotations Reference
| Annotation | Description | Example |
|------------|-------------|---------|
| `external-dns.alpha.kubernetes.io/hostname` | Specifies the hostname for DNS records | `app.example.com` |
| `external-dns.alpha.kubernetes.io/target` | Overrides the target of DNS records | `elb.example.com` |
| `external-dns.alpha.kubernetes.io/ttl` | Sets Time-To-Live for DNS records | `"300"` |
| `external-dns.alpha.kubernetes.io/alias` | Creates an ALIAS record instead of CNAME (AWS only) | `"true"` |
| `external-dns.alpha.kubernetes.io/set-identifier` | Sets identifier for routing policies (AWS only) | `"prod"` |
| `external-dns.alpha.kubernetes.io/aws-weight` | Sets weight for Route53 weighted records | `"100"` |

<br/>

## Additional Notes
- Make sure to replace `<YOUR_GCP_PROJECT>` and `<YOUR_DOMAIN>` with your actual values
- Verify that your cluster has the necessary GCP credentials configured
- For more detailed configuration options, refer to the [External DNS documentation GCP](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/gcp.md)
- If Cloud DNS and GKE are in different projects, specify Cloud DNS projects under the '--google-project' flag
- Service Account settings are different when you use Workflow Identity