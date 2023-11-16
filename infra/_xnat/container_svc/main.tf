data "kubernetes_service_account" "container_svc" {
  metadata {
    name      = var.xnat_web_service_account
    namespace = var.xnat_namespace
  }
}

resource "kubernetes_role" "container_svc" {
  metadata {
    name      = "job-admin"
    namespace = var.xnat_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role" "container_svc" {
  metadata {
    name = "api-ready-reader"
  }

  rule {
    non_resource_urls = ["/readyz", "/readyz/*"]
    verbs             = ["get"]
  }
}

resource "kubernetes_role_binding" "container_svc" {
  metadata {
    name      = "${data.kubernetes_service_account.container_svc.metadata.0.name}-job-binding"
    namespace = var.xnat_namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.container_svc.metadata.0.name
    namespace = var.xnat_namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.container_svc.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "container_svc" {
  metadata {
    name = "${data.kubernetes_service_account.container_svc.metadata.0.name}-api-ready-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.container_svc.metadata.0.name
    namespace = var.xnat_namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.container_svc.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_secret" "token" {
  metadata {
    name      = "${var.xnat_web_service_account}-token"
    namespace = var.xnat_namespace
    annotations = {
      "kubernetes.io/service-account.name" = data.kubernetes_service_account.container_svc.metadata.0.name
    }
  }

  type = "kubernetes.io/service-account-token"
}
