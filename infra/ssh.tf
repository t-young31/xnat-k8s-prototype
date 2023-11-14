resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = local.ssh_key_path
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = var.aws_prefix
  public_key      = tls_private_key.global_key.public_key_openssh
}
