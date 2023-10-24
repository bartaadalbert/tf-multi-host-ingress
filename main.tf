# locals {
#   unique_namespaces = distinct([for host_map in var.hosts_to_services : host_map.namespace])
# }

locals {
  unique_namespaces = distinct([for host_map in var.hosts_to_services : host_map.namespace])
  all_yaml_outputs = join("\n---\n", [for i in kubectl_manifest.multi_host_ingress : i.yaml_body])
}

resource "local_file" "output_yaml" {
  content  = local.all_yaml_outputs
  filename = "${path.module}/all_ingress_output.yaml"
}

resource "null_resource" "namespace_readiness_checker" {
  count = length(var.hosts_to_services) > 0 ? length(local.unique_namespaces) : 0

  triggers = {
    namespace_name = local.unique_namespaces[count.index]
  }

  provisioner "local-exec" {
    command = <<-EOT
      until kubectl get namespace ${self.triggers.namespace_name}; do 
        echo "Waiting for namespace ${self.triggers.namespace_name} to be ready..."
        sleep 5 
      done
    EOT
  }
}

resource "kubectl_manifest" "multi_host_ingress" {
  depends_on = [null_resource.namespace_readiness_checker]
  
  count = length(var.hosts_to_services) > 0 ? length(local.unique_namespaces) : 0

  yaml_body = <<-YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-host-ingress-${local.unique_namespaces[count.index]}
  namespace: ${local.unique_namespaces[count.index]}
  annotations:
    ${indent(4, var.annotations)}
spec:
  rules:
  ${indent(2, join("", [for host_map in var.hosts_to_services : host_map.namespace == local.unique_namespaces[count.index] ? <<-EOT
  - host: ${host_map.host}
    http:
      paths:
      - path: /
        pathType: ${host_map.path_type}
        backend:
          service:
            name: ${host_map.service}
            port:
              number: ${host_map.port}
EOT
: ""]))}
  tls:
  - hosts:
    ${join("", [for host_map in var.hosts_to_services : host_map.namespace == local.unique_namespaces[count.index] ? "  - ${host_map.host}\n" : ""])}
    secretName: multi-host-tls-${local.unique_namespaces[count.index]}
YAML
}
