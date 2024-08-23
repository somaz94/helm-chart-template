## Ingress Nginx TLS Setup
This setup guide details the installation of the NGINX Ingress Controller in a Kubernetes cluster with TLS termination. Ensure your cluster has a TLS certificate ready in kube-system/tls-somaz-link or adjust the secret reference accordingly.


### Configuration File: ingress-nginx-values-tls.yaml
```yaml
controller:
...
  containerPort:
    http: 1380  # NGINX container will listen on this port for HTTP traffic
    https: 13443 #  NGINX container will listen on this port for HTTPS traffic
...
  extraArgs:
    default-ssl-certificate: "kube-system/tls-somaz-link" # Specifies the default TLS certificate
    http-port: "1380" # NGINX container will listen on this port for HTTP traffic
    https-port: "13443" # NGINX container will listen on this port for HTTPS traffic
...
  autoscaling:
    enabled: true
    annotations: {}
    minReplicas: 2
    maxReplicas: 7
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
    behavior: 
      scaleDown:
        stabilizationWindowSeconds: 300
        policies:
        - type: Pods
          value: 1
          periodSeconds: 180
      scaleUp:
        stabilizationWindowSeconds: 300
        policies:
        - type: Pods
          value: 2
          periodSeconds: 60
...
  service:
    enabled: true
    type: LoadBalancer
    externalTrafficPolicy: "Cluster"
    loadBalancerIP: "10.0.0.120" # Optional: Assign a specific IP to the load balancer
```

### Installation
Run the following commands to lint and install the ingress controller using Helm:

```bash
helm lint --values ingress-nginx-values-tls.yaml 

helm install ingress-nginx . -n ingress-nginx -f ingress-nginx-values.yaml --create-namespace
```

### Example Application Deployment: Super Mario Game
Deploy a test application (Super Mario Game) to verify that the ingress controller routes traffic correctly.

#### Deployment Manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: supermario-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: supermario
  template:
    metadata:
      labels:
        app: supermario
    spec:
      containers:
        - name: supermario
          image: pengbai/docker-supermario
          ports:
            - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: supermario-service
  namespace: default
spec:
  selector:
    app: supermario
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: supermario-ingress
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - test02-pod.somaz.link
      secretName: tls-sia-somaz-link
  rules:
    - host: test02-pod.somaz.link
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: supermario-service
                port:
                  number: 80
```
- This setup will expose the Super Mario game on test02-pod.somaz.link via HTTPS, redirecting all traffic securely through the ingress controller.

