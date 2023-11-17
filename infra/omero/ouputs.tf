output "fqdn" {
  value = var.fqdn
}

output "username" {
  value = "root"
}

output "password" {
  value = random_password.omero_root.result
}
