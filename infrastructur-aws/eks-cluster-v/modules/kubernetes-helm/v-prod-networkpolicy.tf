resource "kubernetes_namespace" "v-prod-ns" {
  metadata {
    name = var.namespace-v-prod
  }
}

## Network_policy   ##

resource "kubernetes_network_policy" "v_prod_default_deny" {
  depends_on = [helm_release.v-prod]
  metadata {
    name      = "v-prod-netpol"
    namespace = kubernetes_namespace.v-prod-ns.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}