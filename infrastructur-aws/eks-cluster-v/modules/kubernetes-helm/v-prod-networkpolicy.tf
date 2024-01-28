resource "kubernetes_namespace" "v-prod-ns" {
  depends_on = [var.mod_dependency]
  metadata {
    name = var.namespace-v-prod
  }
}
resource "kubernetes_network_policy" "v-prod-np" {
  metadata {
    name      = "v-prod-netpol"
    namespace = "production"
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "administration"
          }
        }
      }
    }

    egress {} # single empty rule to allow all egress traffic

    policy_types = ["Ingress", "Egress"]
  }
}
