resource "kubernetes_namespace" "v-admin-ns" {
  depends_on = [var.mod_dependency]
  metadata {
    name = var.namespace-v-admin
  }
}
resource "kubernetes_network_policy" "v-admin-np" {
  metadata {
    name      = "v-admin-netpol"
    namespace = "administration"
  }

  spec {
    pod_selector {}

    ingress {}

    policy_types = ["Ingress"]
  }
}
