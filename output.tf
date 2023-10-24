data "local_file" "all_ingress_output_yaml_data" {
  depends_on = [local_file.all_ingress_output_yaml]
  filename = "${path.module}/all_ingress_output.yaml"
}

output "all_ingress_output_yaml" {
  value     = data.local_file.all_ingress_output_yaml_data.content
}