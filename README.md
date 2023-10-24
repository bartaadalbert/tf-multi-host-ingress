# Terraform Multi-Host Ingress Module

This module allows for the creation of Kubernetes Ingress resources for multiple hosts, with the ability to specify unique services, ports, paths, and namespaces for each host.

## Features

- Dynamic creation of Kubernetes Ingress based on provided hosts, services, ports, paths, and namespaces.
- Allows for custom annotations on the Ingress resource.
- Checks for namespace readiness before creating the Ingress resource.
- Uses the `kubectl` Terraform provider for Kubernetes operations.

## Requirements

- Terraform version `>= 1.0`
- `kubectl` Terraform provider version `>= 1.14.0`

## Usage

```hcl
module "multi_host_ingress" {
  source = "github.com/bartaadalbert/tf-multi-host-ingress"

  kubeconfig = "~/.kube/config"
  hosts_to_services = [
    {
      host      = "example1.com"
      service   = "service1"
      port      = 80
      path      = "/"
      namespace = "default"
    },
    {
      host      = "example2.com"
      service   = "service2"
      port      = 8080
      path      = "/app"
      namespace = "default"
    }
  ]
  annotations = <<-EOT
  kubernetes.io/ingress.class: "traefik"
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
  EOT
}
```

## Input Variables

| Name               | Description                                                                                                              | Type                                   | Default                           |
|--------------------|--------------------------------------------------------------------------------------------------------------------------|----------------------------------------|-----------------------------------|
| kubeconfig         | Path to your Kubernetes configuration file.                                                                              | String                                 | `~/.kube/config`                  |
| hosts_to_services  | A list of maps detailing the host, service, port, path, and namespace for each Ingress rule.                             | List of Objects (details below)        | `[]`                              |
| annotations        | Annotations to attach to the Ingress resource.                                                                           | Map of Strings                         | (Default annotations for Traefik) |

For `hosts_to_services` each object should have:

| Key       | Description                                                                  | Type     |
|-----------|------------------------------------------------------------------------------|----------|
| host      | The hostname for the Ingress rule.                                          | String   |
| service   | The service name to which traffic should be directed.                        | String   |
| port      | The service port to which traffic should be directed.                        | Number   |
| path      | The path for the Ingress rule.                                              | String   |
| namespace | The namespace in which the Ingress should be created.                        | String   |

Certainly! You can create (or update) a `README.md` file to include this information. Here's a suggested entry for your `README.md`:

---


### Output

The combined ingress configurations are written to a file named `all_ingress_output.yaml` located in the module's directory.

To view the contents of the generated file, you can check the Terraform output using:

```
terraform output all_ingress_output_yaml
```


## Notes

- Ensure the namespaces specified in `hosts_to_services` are created before applying this module, as it checks for their existence before creating the Ingress resources.
- Modify the default annotations as per your Ingress controller and requirements.


## Contributing

If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request. Your contributions are welcome!

Modify this draft to align with your project's specific details and requirements, and make sure to update the source URL to match your actual Terraform module's repository location.