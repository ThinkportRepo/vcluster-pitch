resource "kubernetes_namespace" "v-prod-ns" {
  #depends_on = [var.mod_dependency]
  # count = data.kubernetes_namespace.v-prod-ns-check.id == "" ? 1 : 0
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

/*resource "kubernetes_network_policy" "v-prod-np" {
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
}*/
