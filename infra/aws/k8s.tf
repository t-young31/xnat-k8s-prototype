
resource "helm_release" "nginx_ingress" {
  name             = "nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.1"
  create_namespace = true

  depends_on = [null_resource.get_kubeconfig]
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = "1.5.2"
  create_namespace = true

  set {
    name  = "persistence.defaultClassReplicaCount"
    value = 1
  }

  set {
    name  = "csi.attacherReplicaCount"
    value = 1
  }

  set {
    name  = "csi.snapshotterReplicaCount"
    value = 1
  }

  set {
    name  = "csi.resizerReplicaCount"
    value = 1
  }

  set {
    name  = "longhornUI.replicas"
    value = 1
  }

  depends_on = [null_resource.get_kubeconfig]
}

resource "null_resource" "unset_local_default_storage_class" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }

    command = <<EOF
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
EOF
  }

  depends_on = [helm_release.longhorn]
}
