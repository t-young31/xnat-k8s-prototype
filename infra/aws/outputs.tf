output "ssh_command" {
  value = local.ssh_command
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}
