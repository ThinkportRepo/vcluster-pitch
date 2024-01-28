resource "helm_release" "v-dev" {
  name             = var.name-v-dev
  namespace        = var.namespace-v-dev
  # create_namespace = true
  repository       = var.loft-repository
  chart            = var.loft-chart
  version          = var.loft-version
  depends_on = [kubernetes_namespace.v-dev-ns]
  values = [
    file("${path.module}/config-vcluster/vcluster.yaml"),
    file("${path.module}/config-vcluster/dev-values.yaml")
  ]
}
resource "helm_release" "v-admin" {
  name             = var.name-v-admin
  namespace        = var.namespace-v-admin
  # create_namespace = true
  repository       = var.loft-repository
  chart            = var.loft-chart
  version          = var.loft-version
  depends_on = [kubernetes_namespace.v-admin-ns]
  values = [
    file("${path.module}/config-vcluster/vcluster.yaml"),
    file("${path.module}/config-vcluster/admin-values.yaml")
  ]
}
resource "helm_release" "v-prod" {
  name             = var.name-v-prod
  namespace        = var.namespace-v-prod
  create_namespace = true
  repository       = var.loft-repository
  chart            = var.loft-chart
  version          = var.loft-version
  depends_on = [kubernetes_namespace.v-prod-ns]
  values = [
    file("${path.module}/config-vcluster/vcluster.yaml"),
    file("${path.module}/config-vcluster/prod-values.yaml")
  ]
}

/*
resource "kubernetes_manifest" "v_dev_ingress" {
  depends_on = [
    helm_release.v-dev
  ]
  manifest = yamldecode(file("${path.module}/vcluster-admin-ing.yaml"))
}*/
