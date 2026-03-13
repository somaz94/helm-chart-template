# k8s-service Helm Chart Templates

Helm charts and configurations for common Kubernetes services, designed for use with ArgoCD and helmfile.

## Charts

### argocd

Helm chart and YAML files for ArgoCD deployment, including ApplicationSet configurations.

### harbor

Helm chart for Harbor container registry.

### ingress-nginx

Helm chart for ingress-nginx controller, managed via helmfile.

### metallb

YAML configuration files for MetalLB load balancer.

### monitoring

Helm charts for monitoring stack:
- **kube-prometheus-stack**: Prometheus, Alertmanager, Grafana
- **grafana**: Standalone Grafana dashboards
- **loki**: Log aggregation
- **promtail**: Log collection agent
- **thanos**: Long-term Prometheus storage
- **elk-stack**: Elasticsearch, Logstash, Kibana, Filebeat, Metricbeat, APM Server

### nginx-gateway-fabric

Helm chart for Nginx Gateway Fabric (Gateway API implementation).

### storage-provisioner

Helm charts for storage provisioners:
- **local-path-provisioner**: Local path based dynamic provisioning
- **nfs-subdir-external-provisioner**: NFS based dynamic provisioning (managed via helmfile)

## Reference

- [ArgoCD](https://argo-cd.readthedocs.io/)
- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/)
- [MetalLB](https://metallb.universe.tf/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts)
- [Loki](https://grafana.com/oss/loki/)
- [Nginx Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric)
