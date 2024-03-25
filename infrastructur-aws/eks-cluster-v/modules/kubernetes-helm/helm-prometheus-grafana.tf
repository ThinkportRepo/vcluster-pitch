resource "time_sleep" "wait_for_kubernetes" {

  depends_on = [
    var.cluster_name
  ]

  create_duration = "20s"
}
## create namespaces

resource "kubernetes_namespace" "prometheus" {
  depends_on = [var.mod_dependency]
  count      = (var.enabled && var.create_namespace_prometheus && var.namespace_prometheus != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace_prometheus
  }
}


resource "helm_release" "prometheus" {
  depends_on       = [kubernetes_namespace.prometheus, time_sleep.wait_for_kubernetes]
  name             = var.helm_chart_prometheus_name
  repository       = var.helm_chart_prometheus_repo
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.prometheus[0].id
  create_namespace = true
  version          = "45.7.1"
  values           = [
    file("${path.module}/values.yaml")
  ]
  timeout = 2000


  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
  set {
    name  = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "400m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "200m"
        memory = "60Mi"
      }
    })
  }
}
