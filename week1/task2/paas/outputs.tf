output "public_ip" {
  description = "vm public ip address"
  value       = tencentcloud_instance.yaml2infra[0].public_ip
}

output "kube_config" {
  description = "kubeconfig"
  value       = "${path.module}/config.yaml"
}

output "password" {
  description = "vm password"
  value       = var.password
}
