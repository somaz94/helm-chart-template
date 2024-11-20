# Helm Chart Templates with ArgoCD 🚀

This repository contains Helm chart templates specifically designed to work seamlessly with ArgoCD across various platforms: AWS, GCP, and on-premises infrastructure.

<br/>

## 📁 AWS

- 📂 eks-fargate-use-ebs: A template for storage using EBS.
- 📂 eks-fargate-use-efs: A template for file storage using EFS.
- 📂 external-secrets: Chart for managing AWS external secrets.

<br/>

## 📁 GCP

- 📂 gke-use-firestore: Template for using Firestore on GKE.
- 📂 gke-use-firestore-shared-vpc: Template for using Firestore on GKE with a shared VPC.
- 📂 gke-use-nfs-server: Template for NFS server usage on GKE.
- 📂 gke-use-pd-csi: Template for persistent disk CSI on GKE.
- 📂 external-secrets: Chart for managing GCP external secrets.

<br/>

## 📁 k8s-service

- 📁 argocd: Helm chart and YAML files for ArgoCD.
- 📁 harbor: Helm chart for Harbor.
- 📁 monitoring: Helm chart for monitoring(Prometheus, Grafana, Loki, Thanos, etc.)
- 📁 storage-provisioner: Helm chart for storage provisioner(Local, NFS))
- 📁 ingress-nginx: Helm chart for ingress-nginx.
- 📁 metallb: YAML files for metallb.

<br/>

## 📁 Onpremise

- 📂 ke-use-nfs-server: Template for NFS server usage on a Kubernetes cluster deployed on-premise.
- 📂 ke-use-nfs-server-sidecar-fluentbit: Template for NFS server usage on a Kubernetes cluster deployed on-premise with FluentBit sidecar.

<br/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
