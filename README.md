# Helm Chart Templates with ArgoCD
This repository contains Helm chart templates specifically designed to work seamlessly with ArgoCD across various platforms: AWS, GCP, and on-premises infrastructure.

## 📁 AWS
- 📂 eks-fargate-use-ebs: A template for storage using EBS.
- 📂 eks-fargate-use-efs: A template for file storage using EFS.
- 📂 external-secrets: Chart for managing AWS external secrets.

## 📁 GCP
- 📂 gke-use-firestore: Template for using Firestore on GKE.
- 📂 gke-use-firestore-shared-vpc: Template for using Firestore on GKE with a shared VPC.
- 📂 gke-use-nfs-server: Template for NFS server usage on GKE.
- 📂 gke-use-pd-csi: Template for persistent disk CSI on GKE.
- 📂 external-secrets: Chart for managing GCP external secrets.

## 📁 argocd-applicationset
Contains YAML files for configuring ArgoCD application sets.

## 📁 Onpremise
- 📂 ke-use-nfs-server: Template for NFS server usage on a Kubernetes cluster deployed on-premise.
