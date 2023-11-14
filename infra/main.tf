resource "helm_release" "metallb" {
  name             = "xnat"
  namespace        = "xnat"
  repository       = "https://australian-imaging-service.github.io/charts"
  chart            = "xnat"
  version          = "1.1.7"
  create_namespace = true
}
