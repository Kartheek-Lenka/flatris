output "ec2_public_ip" {
  description = "EC2 public IP — add this to GitHub Secret EC2_HOST"
  value       = aws_eip.flatris.public_ip
}

output "game_url" {
  description = "Your game URL"
  value       = "http://${aws_eip.flatris.public_ip}:3000"
}

output "ssh_command" {
  description = "SSH into your server"
  value       = "ssh -i your-key.pem ubuntu@${aws_eip.flatris.public_ip}"
}
