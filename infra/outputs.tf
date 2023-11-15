output "url" {
  value = "https://${local.fqdn}"
}

output "ssh" {
  value = local.ssh_command
}
