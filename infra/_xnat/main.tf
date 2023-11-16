resource "helm_release" "xnat" {
  name             = "xnat"
  namespace        = "xnat"
  chart            = "${path.module}/xnat-helm-charts/releases/xnat"
  version          = "1.1.7"
  create_namespace = true

  wait              = false
  dependency_update = true

  set {
    name  = "postgresql.postgresqlPassword"
    value = random_password.posgres_password.result
  }

  set {
    name  = "xnat-web.probes.startup.periodSeconds"
    value = 30
  }

  set {
    name  = "xnat-web.resources.limits.cpu"
    value = "1500m"
  }

  set {
    name  = "xnat-web.resources.limits.memory"
    value = "4000Mi"
  }

  set {
    name  = "xnat-web.resources.requests.memory"
    value = "4000Mi"
  }

  set {
    name  = "xnat-web.postgresql.postgresqlPassword"
    value = random_password.posgres_password.result
  }

  set {
    name  = "xnat-web.ingress.enabled"
    value = true
  }

  set {
    name  = "xnat-web.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    name  = "xnat-web.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-body-size"
    value = "0M" # 0 is disabled. See: https://docs.nginx.com/nginx-management-suite/acm/how-to/policies/request-body-size-limit/
  }

  set {
    name  = "xnat-web.ingress.hosts[0].host"
    value = var.fqdn
  }

  set {
    name  = "xnat-web.ingress.tls[0].hosts[0]"
    value = var.fqdn
  }

  set {
    name  = "xnat-web.image.tag"
    value = "v1.8.9.1"
  }

  set {
    name  = "xnat-web.plugins.container-service[0].provider.id"
    value = "null" # can be any value..
  }

  set {
    name  = "xnat-web.autoscaling.enabled"
    value = false
  }

  depends_on = [
    null_resource.unset_local_default_storage_class,
    helm_release.longhorn
  ]
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.1"
  create_namespace = true

  depends_on = [helm_release.xnat]
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

resource "random_password" "posgres_password" {
  length  = 32
  special = false
}

module "container_svc" {
  source = "./container_svc"

  xnat_namespace           = helm_release.xnat.namespace
  xnat_web_service_account = "${helm_release.xnat.name}-xnat-web"

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [helm_release.xnat]
}
