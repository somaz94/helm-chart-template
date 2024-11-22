# External DNS Installation Guide

<br/>

## Table of Contents
1. [Installing External DNS](#installing-external-dns)
2. [Configuration Settings](#configuration-settings)
3. [Adding IAM Policy](#adding-iam-policy)
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
  --set provider=aws \
  --set aws.region=<YOUR_AWS_REGION> \
  --set domainFilters[0]=<YOUR_DOMAIN> \
  --set txtOwnerId=<YOUR_IDENTIFIER>

# Or using values file (recommended)

# Install using values file
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  -f route53-values.yaml
```

<br/>

## Configuration Settings
External DNS requires proper AWS configuration to manage Route53 records. Make sure to configure the following:

```yaml
# Example values.yaml configuration
provider: aws
aws:
  region: us-east-1
  zoneType: public
domainFilters:
  - example.com
policy: sync
txtOwnerId: my-identifier
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
- For more detailed configuration options, refer to the [External DNS documentation](https://github.com/kubernetes-sigs/external-dns)