#output "xnat_url" {
#  value = "https://${module.xnat.fqdn}"
#}

output "omero_url" {
  value = "https://${module.omero.fqdn}"
}

output "ssh" {
  value = module.aws.ssh_command
}
