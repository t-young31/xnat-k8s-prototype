output "url" {
  value = "https://${module.aws.fqdn}"
}

output "ssh" {
  value = module.aws.ssh_command
}
