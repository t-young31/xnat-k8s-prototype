resource "aws_instance" "server" {
  ami           = data.aws_ami.rhel9.id
  instance_type = "t3a.xlarge"
  key_name      = aws_key_pair.ssh.key_name

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = merge(local.tags, {
    Name = "${var.aws_prefix}-k3s-server"
  })

  user_data = templatefile(
    "${path.module}/cloud-init.tmpl.sh",
    {
      k3s_version = local.k3s_version
    }
  )

  root_block_device {
    volume_size = 50 # GB
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  connection {
    type        = "ssh"
    user        = local.ec2_username
    private_key = tls_private_key.global_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["while ! kubectl get pods -A | grep Running; do sleep 5; done"]
  }

  depends_on = [
    aws_security_group_rule.all_ingress_from_deployers_ip
  ]
}

resource "null_resource" "get_kubeconfig" {
  provisioner "local-exec" {
    command = join(" && ", [
      "scp -i ${local.ssh_key_path} -o 'StrictHostKeyChecking no' ${local.ssh_host}:/etc/rancher/k3s/k3s.yaml ${var.kubeconfig_path}",
      "python scripts/replace_ip_in_kubeconfig.py ${var.kubeconfig_path} ${aws_instance.server.public_ip}"
    ])
  }

  depends_on = [aws_instance.server]
}
