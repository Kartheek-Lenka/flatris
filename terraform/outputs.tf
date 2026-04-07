output "app_url" {
  value = "http://${aws_instance.flatris.public_ip}:3000"
}
