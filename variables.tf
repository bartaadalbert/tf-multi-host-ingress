variable "kubeconfig" {
  description = "Kubeconfig path"
  type        = string
  default     = "~/.kube/config"
}

variable "hosts_to_services" {
  description = "List of maps containing host, service, port, path, and namespace details for Ingress rules"
  type = list(object({
    host      = string
    service   = string
    port      = number
    path      = string
    namespace = string
    path_type = string
  }))
  default = [
    {
      host      = "margo.nunapo.com"
      service   = "webthecars-helm"
      port      = 8000
      path      = "/"
      namespace = "thecars-net"
      path_type = "Prefix"
    },

  ]
}

variable "annotations" {
  description = "Annotations for the Ingress resource"
  type        = string
  default     = <<-EOT
  kubernetes.io/ingress.class: "traefik"
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
  ingress.kubernetes.io/force-ssl-redirect: "true"
  ingress.kubernetes.io/ssl-redirect: "true"
  traefik.ingress.kubernetes.io/router.tls: "true"
  traefik.ingress.kubernetes.io/affinity: "true"
  traefik.ingress.kubernetes.io/frontend-entry-points: http,https
  traefik.ingress.kubernetes.io/redirect-entry-point: https
  EOT
}
