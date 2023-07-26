# helm-chart-template
This is helm chart template with ArgoCD

## AWS

```bash
└── aws
    ├── eks-fargate-use-ebs
    │   ├── Chart.yaml
    │   ├── ebs-csi.values.yaml
    │   ├── templates
    │   └── values.yaml
    ├── eks-fargate-use-efs
    │   ├── Chart.yaml
    │   ├── efs-csi.values.yaml
    │   ├── templates
    │   └── values.yaml
    └── external-secrets
        ├── Chart.yaml
        ├── README.md
        ├── crds      
        ├── somaz.values.yaml
        ├── templates
        └── values.yaml
```

## GCP

```bash
└── gcp
    ├── gke-use-firestore
    │   ├── Chart.yaml
    │   ├── firestore.values.yaml
    │   ├── templates
    │   └── values.yaml
    ├── gke-use-firestore-shared-vpc
    │   ├── Chart.yaml
    │   ├── firestore-shared-vpc.values.yaml
    │   ├── templates
    │   └── values.yaml
    ├── gke-use-nfs-server
    │   ├── Chart.yaml
    │   ├── nfs-server.values.yaml
    │   ├── templates
    │   └── values.yaml
    ├── gke-use-pd-csi
    │   ├── Chart.yaml
    │   ├── pd-csi.values.yaml
    │   ├── templates
    │   └── values.yaml
    └── external-secrets
        ├── Chart.yaml
        ├── README.md
        ├── crds
        ├── somaz.values.yaml
        ├── templates
        └── values.yaml
```


## argocd-applicationset

```bash
└── argocd-applicationset
    ├── aws-applicationset.yaml
    ├── aws-externalsecret-applicationset.yaml
    ├── gcp-applicationset.yaml
    └── gcp-externalsecret-applicationset.yaml
```
