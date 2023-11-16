resource "aws_instance" "server" {
  ami           = data.aws_ami.rhel9.id
  instance_type = "t3a.large"
  key_name      = aws_key_pair.ssh.key_name

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = merge(local.tags, {
    Name = "${var.aws_prefix}-k3s-server"
  })

  user_data = templatefile(
    "${path.module}/scripts/cloud-init.tmpl.sh",
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
      "python ${path.module}/scripts/replace_ip_in_kubeconfig.py ${var.kubeconfig_path} ${aws_instance.server.public_ip}"
    ])
  }

  depends_on = [aws_instance.server]
}

data "external" "k3s_server_token" {
  program = ["bash", "-c", <<EOF
token=$(ssh -i ${local.ssh_key_path} -o 'StrictHostKeyChecking no' ${local.ssh_host} sudo cat /var/lib/rancher/k3s/server/node-token)
echo '{"token": "'$token'"}'
EOF
  ]
  depends_on = [aws_instance.server]
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.rhel9.id
  instance_type = "t3a.medium"
  key_name      = aws_key_pair.ssh.key_name

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = merge(local.tags, {
    Name = "${var.aws_prefix}-k3s-worker"
  })

  user_data = <<EOF
#!/bin/bash

systemctl disable nm-cloud-setup.service nm-cloud-setup.timer

curl https://get.k3s.io | \
  K3S_KUBECONFIG_MODE="644" \
  K3S_TOKEN="${data.external.k3s_server_token.result.token}" \
  INSTALL_K3S_EXEC="agent" \
  INSTALL_K3S_VERSION=${local.k3s_version} sh -s - --server https://${aws_instance.server.private_ip}:6443

dnf install iscsi-initiator-utils jq nfs-utils wget -y
systemctl enable iscsid.service
systemctl start iscsid.service
EOF

  root_block_device {
    volume_size = 30 # GB
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}
