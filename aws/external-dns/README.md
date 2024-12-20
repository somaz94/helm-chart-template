# External DNS Installation Guide

<br/>

## Table of Contents
1. [Installing External DNS](#installing-external-dns)
2. [Adding IAM Policy](#adding-iam-policy)
3. [AWS Credentials Configuration](#aws-credentials-configuration)
4. [Annotations Examples](#annotations-examples)
5. [Additional Notes](#additional-notes)

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
  --set provider.name=aws \
  --set domainFilters[0]=<YOUR_DOMAIN> \
  --set txtOwnerId=<YOUR_HOSTED_ZONE_ID> \
  --set policy=upsert-only \

# Or using values file (recommended)

# Install using values file
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  -f route53-values.yaml
```

<br/>

## Adding IAM Policy
External DNS needs permissions to modify Route53 records. Create an IAM policy with the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

<br/>

## AWS Credentials Configuration
External DNS requires authentication to access AWS Route53. There are two ways to configure this:

### 1. EKS IRSA (Recommended)
For EKS clusters, use IRSA (IAM Role for Service Account):
```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT-ID:role/external-dns"
```

### 2. AWS Credentials Secret (Non-EKS)
For non-EKS environments, create and use AWS credentials secret:
```bash
# Create AWS credentials secret
kubectl create secret generic aws-credentials \
  --from-literal=access-key-id=AKIAXXXXXXXXXXXXXXXX \
  --from-literal=secret-access-key=XXXXXXXXXXXXXXXXX \
  --namespace external-dns

# Update values.yaml to use credentials
env:
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: aws-credentials
        key: access-key-id
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: aws-credentials
        key: secret-access-key
  - name: AWS_REGION
    value: "ap-northeast-2"  # Specify your AWS region
```

<br/>

## Annotations Examples
External DNS supports various annotations to configure DNS records. Here are some common examples using Services:

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

### CNAME Record Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service-cname
  annotations:
    external-dns.alpha.kubernetes.io/hostname: app-cname.example.com
    external-dns.alpha.kubernetes.io/target: elb.example.com
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app
```

### AWS Route53 Weighted Routing Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service-weighted
  annotations:
    external-dns.alpha.kubernetes.io/hostname: app-weighted.example.com
    external-dns.alpha.kubernetes.io/set-identifier: "prod"
    external-dns.alpha.kubernetes.io/aws-weight: "100"
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
- Make sure to replace `<YOUR_AWS_REGION>` and `<YOUR_DOMAIN>` with your actual values
- Verify that your cluster has the necessary AWS credentials configured
- For more detailed configuration options, refer to the [External DNS documentation AWS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)