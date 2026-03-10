# Helm Chart Templates with ArgoCD

This repository contains Helm chart templates specifically designed to work seamlessly with ArgoCD across various platforms: AWS, GCP, and on-premises infrastructure.

## AWS

- **eks-fargate-use-ebs**: Template for EKS Fargate with EBS storage
- **eks-fargate-use-efs**: Template for EKS Fargate with EFS file storage
- **external-secrets**: Chart for managing external secrets (deprecated, see [External Secrets Operator](https://external-secrets.io/))
- **external-dns**: ExternalDNS chart for AWS Route53 (helmfile)
- **gitlab-runner-aws**: GitLab Runner chart for AWS (helmfile)

## GCP

- **gke-use-firestore**: Template for GKE with Firestore
- **gke-use-firestore-shared-vpc**: Template for GKE with Firestore on shared VPC
- **gke-use-nfs-server**: Template for GKE with NFS server
- **gke-use-pd-csi**: Template for GKE with PD CSI driver
- **external-dns**: ExternalDNS chart for GCP Cloud DNS (helmfile)
- **haproxy**: HAProxy chart for GCP

## k8s-service

- **argocd**: Helm chart and YAML files for ArgoCD
- **harbor**: Helm chart for Harbor
- **monitoring**: Helm charts for monitoring (Prometheus, Grafana, Loki, Thanos, ELK Stack, etc.)
- **storage-provisioner**: Helm charts for storage provisioners (Local Path, NFS)
- **ingress-nginx**: Helm chart for ingress-nginx
- **metallb**: YAML files for MetalLB
- **nginx-gateway-fabric**: Nginx Gateway Fabric chart

## Onpremise

- **ke-use-nfs-server**: Template for NFS server usage on an on-premise Kubernetes cluster
- **ke-use-nfs-server-sidecar-fluentbit**: Template for NFS server usage on an on-premise Kubernetes cluster with FluentBit sidecar

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
