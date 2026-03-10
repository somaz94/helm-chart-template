# AWS Helm Chart Templates

Helm chart templates for AWS EKS and related services, designed for use with ArgoCD.

## Charts

### eks-fargate-use-ebs

Helm chart template for applications running on EKS Fargate with EBS (Elastic Block Store) volumes.

- Supports staging and production deployments
- Configurable storage classes, persistent volumes, and external secrets
- Includes sidecar container support

### eks-fargate-use-efs

Helm chart template for applications running on EKS Fargate with EFS (Elastic File System) volumes.

- Similar structure to EBS template with EFS-specific storage configuration
- Supports staging and production deployments
- Configurable probes via values

### external-secrets

> **Deprecated**: This chart uses `kubernetes-external-secrets` (v8.5.5) which is deprecated.
> Consider migrating to [External Secrets Operator (ESO)](https://external-secrets.io/).

### external-dns

ExternalDNS deployment for AWS Route53, managed via helmfile.

### gitlab-runner-aws

GitLab Runner deployment for AWS, managed via helmfile.

## Reference

- [AWS EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [AWS EFS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)
- [External Secrets Operator](https://external-secrets.io/)
