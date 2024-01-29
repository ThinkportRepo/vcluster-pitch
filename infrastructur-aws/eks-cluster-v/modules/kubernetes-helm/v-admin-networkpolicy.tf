resource "kubernetes_namespace" "v-admin-ns" {
  # depends_on = [var.mod_dependency]
  # count = data.kubernetes_namespace.v-admin-ns-check.id == "" ? 1 : 0
  metadata {
    name = var.namespace-v-admin
  }
}

## Network_policy   ##

resource "kubernetes_network_policy" "v_admin_default_deny" {
  depends_on = [helm_release.v-admin]

  metadata {
    name      = "v-admin-netpol"
    namespace = kubernetes_namespace.v-admin-ns.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}
/*resource "kubernetes_network_policy" "v-admin-np" {
  metadata {
    name      = "v-admin-netpol"
    namespace = "administration"
  }

  spec {
    pod_selector {}

    ingress {}

    policy_types = ["Ingress"]
  }
}*/
