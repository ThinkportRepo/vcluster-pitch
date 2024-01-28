resource "kubernetes_namespace" "v-dev-ns" {
  depends_on = [var.mod_dependency]
  metadata {
    name = var.namespace-v-dev
  }
}
resource "kubernetes_network_policy" "v-dev-np" {
  metadata {
    name      = "v-dev-netpol"
    namespace = "development"
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
