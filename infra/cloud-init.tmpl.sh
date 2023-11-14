#!/bin/bash

cd /tmp
dnf upgrade -y

# ----------------- k3s setup --------------------------
# cloud-setup needs to be disabled for k3s
# See: https://slack-archive.rancher.com/t/10093428/would-you-expect-k3s-to-install-amp-run-on-an-aws-ec2-rhel9-
systemctl disable nm-cloud-setup.service nm-cloud-setup.timer

public_ip="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"

curl https://get.k3s.io | \
  K3S_KUBECONFIG_MODE="644" \
  INSTALL_K3S_EXEC="--cluster-cidr=172.16.0.0/16 --service-cidr=172.17.0.0/16 --disable=traefik --tls-san $public_ip" \
  INSTALL_K3S_VERSION=${k3s_version} sh -

until /usr/local/bin/kubectl get pods -A &> /dev/null; do
  sleep 5
done

# Install open-iscsi, jq, nfs-utils and enable services for Longhorn
dnf install iscsi-initiator-utils jq nfs-utils wget -y
systemctl enable iscsid.service
systemctl start iscsid.service
