resource "kubernetes_namespace" "v-admin-ns" {

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
