output "public_ip" {
  description = "vm public ip address"
  value       = tencentcloud_instance.cvm-docker[0].public_ip
}

output "password" {
  description = "vm password"
  value       = var.password
}
