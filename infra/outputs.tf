output "xnat" {
  value = {
    url      = "https://${module.xnat.fqdn}"
    username = module.xnat.username
    password = module.xnat.password
  }

  sensitive = true
}

output "omero" {
  value = {
    url      = "https://${module.omero.fqdn}"
    username = module.omero.username
    password = module.omero.password
  }

  sensitive = true
}

output "ssh" {
  value = module.aws.ssh_command
}
