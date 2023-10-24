Certainly! It seems you want to add an `ExternalName` service that points to an existing service in another namespace. The `ExternalName` 
1. **Terraform Code**:
    - Create a Terraform resource for the `ExternalName` service.
    
2. **DNS Resolution Check**:
    - Provide a way to check if DNS resolves the query.

---

1. **Description 

## ExternalName Service

To create an alias to a service in another namespace using `ExternalName`, you can define a service of type `ExternalName`. This service type allows you to return an alias to a service in the form of a domain name, rather than an IP address.

For example, to create an alias `external-argocd-server` in the `default` namespace that points to `argocd-server` service in the `argocd` namespace, you can use the following:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-argocd-server
  namespace: default
spec:
  type: ExternalName
  externalName: argocd-server.argocd.svc.cluster.local
  ports:
  - port: 88 # in my situation
```

Once created, any requests to `external-argocd-server.default.svc.cluster.local` on port 88 will be forwarded to `argocd-server.argocd.svc.cluster.local`.
```

2. **Terraform Code**:

```hcl
resource "kubectl_manifest" "external_service" {
  yaml_body = <<-EOT
apiVersion: v1
kind: Service
metadata:
  name: external-argocd-server
  namespace: default
spec:
  type: ExternalName
  externalName: argocd-server.argocd.svc.cluster.local
  ports:
  - port: 88
  EOT
}
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
#  namespace: argocd
  namespace: demo
  annotations:
    kubernetes.io/ingress.class: "traefik"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    ingress.kubernetes.io/ssl-redirect: "true"
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  rules:
  - host: my-example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
#            name: argocd-server
            name: external-argocd-server
            port:
              name: http
#              number: 88
  tls:
  - hosts:
    - my-example.com
    secretName: argocd-tls
```

3. **DNS Resolution Check**:

Running a temporary pod named `dnsutils` using the `tutum/dnsutils` image, which contains networking tools like `nslookup`. You're then using `nslookup` to resolve the DNS for `external-argocd-server.default.svc.cluster.local`.


To validate that the `ExternalName` service is correctly resolving, you can use a temporary pod within your Kubernetes cluster with DNS tools installed. Here's a command that does this:

```bash
kubectl run -it --rm dnsutils --image=tutum/dnsutils --restart=Never -- nslookup external-argocd-server.defaultt.svc.cluster.local
```

This command:

1. Creates a temporary pod named `dnsutils` using the `tutum/dnsutils` image.
2. Runs the `nslookup` command inside this pod to resolve `external-argocd-server.default.svc.cluster.local`.
3. Removes the pod once the command is executed (because of the `--rm` flag).

If the DNS resolution is correct, you should see the address of the target service (`argocd-server.argocd.svc.cluster.local`) in the command's output.
