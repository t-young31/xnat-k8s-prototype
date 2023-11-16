locals {
  fqdn = "${cloudflare_record.app.name}.${var.cloudflare_zone_name}"

  ec2_username = "ec2-user"
  ssh_key_name = "id_rsa"

  k3s_version = "v1.27.3+k3s1"

  ssh_key_path = "${path.module}/../${local.ssh_key_name}"
  ssh_args     = "-i ${local.ssh_key_name}"
  ssh_host     = "${local.ec2_username}@${aws_instance.server.public_ip}"
  ssh_command  = "ssh ${local.ssh_args} ${local.ssh_host}"

  tags = {
    Repo  = "xnat-k8s-prototype"
    Owner = data.aws_caller_identity.current.arn
  }
}
