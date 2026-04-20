# Helm Chart Templates with ArgoCD

This repository contains Helm chart templates specifically designed to work seamlessly with ArgoCD across various platforms: AWS, GCP, and on-premises infrastructure.

<br/>

## AWS

- **eks-fargate-use-ebs**: Template for EKS Fargate with EBS storage
- **eks-fargate-use-efs**: Template for EKS Fargate with EFS file storage
- **external-dns**: ExternalDNS chart for AWS Route53 (helmfile)
- **gitlab-runner-aws**: GitLab Runner chart for AWS (helmfile)

<br/>

## GCP

- **gke-use-firestore**: Template for GKE with Firestore (supports default and shared-VPC modes via separate values files)
- **gke-use-nfs-server**: Template for GKE with NFS server
- **gke-use-pd-csi**: Template for GKE with PD CSI driver
- **external-dns**: ExternalDNS chart for GCP Cloud DNS (helmfile)
- **haproxy**: HAProxy chart for GCP

<br/>

## Onpremise

- **ke-use-nfs-server**: Template for NFS server usage on an on-premise Kubernetes cluster
- **ke-use-nfs-server-sidecar-fluentbit**: Template for NFS server usage on an on-premise Kubernetes cluster with FluentBit sidecar

<br/>

## Related Repositories

Cluster infrastructure services (ArgoCD, Harbor, monitoring stack, ingress, storage, MetalLB, Nginx Gateway) have moved to [cicd-monitoring](https://github.com/somaz94/cicd-monitoring) — a dedicated repo for production-ready CI/CD and monitoring configurations across AWS, GCP, and on-premise Kubernetes.

<br/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
