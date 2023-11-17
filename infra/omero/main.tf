resource "kubernetes_namespace" "omero" {
  metadata {
    name = "omero"
  }
}

resource "random_password" "posgres_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.omero.metadata.0.name
  }

  type = "Opaque"
  data = {
    "postgres-password" = random_password.posgres_password.result
  }
}

resource "helm_release" "postgres" {
  name       = "db"
  namespace  = kubernetes_namespace.omero.metadata.0.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "11.9.13"

  # See: https://artifacthub.io/packages/helm/bitnami/postgresql
  set {
    name  = "global.postgresql.auth.existingSecret"
    value = kubernetes_secret.postgres.metadata[0].name
  }

  set {
    name  = "global.postgresql.auth.database"
    value = "omero"
  }
}

resource "random_password" "omero_root" {
  length  = 32
  special = false
}

resource "helm_release" "server" {
  name       = "server"
  namespace  = kubernetes_namespace.omero.metadata.0.name
  chart      = "omero-server"
  repository = "https://manics.github.io/kubernetes-omero/"

  version          = "0.4.3"
  create_namespace = false

  wait = false

  # Values see: https://github.com/manics/kubernetes-omero/blob/main/test-omero-server.yaml
  set {
    name  = "database.host"
    value = "${helm_release.postgres.name}-postgresql"
  }

  set {
    name  = "database.username"
    value = "postgres"
  }

  set {
    name  = "database.password"
    value = random_password.posgres_password.result
  }

  set {
    name  = "database.name"
    value = "omero"
  }

  set {
    name  = "resources.limits.cpu"
    value = 1
  }

  set {
    name  = "resources.limits.memory"
    value = "4Gi"
  }

  set {
    name  = "defaultRootPassword"
    value = random_password.omero_root.result
  }
}

resource "helm_release" "web" {
  name       = "web"
  namespace  = kubernetes_namespace.omero.metadata.0.name
  chart      = "omero-web"
  repository = "https://manics.github.io/kubernetes-omero/"

  version          = "0.4.3"
  create_namespace = false

  wait = false

  # Values see: https://github.com/manics/kubernetes-omero/blob/main/test-omero-web.yaml
  set {
    name  = "ingress.hosts[0]"
    value = var.fqdn
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = var.fqdn
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    name  = "serverList[0][0]"
    value = "server-omero-server"
  }

  set {
    name  = "serverList[0][1]"
    value = 4064
  }

  set {
    name  = "serverList[0][2]"
    value = "omero"
  }

  depends_on = [helm_release.server]
}
