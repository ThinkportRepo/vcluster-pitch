resource "kubernetes_namespace" "v-dev-ns" {
  #depends_on = [var.mod_dependency]
  # count = data.kubernetes_namespace.v-dev-ns-check.id == "" ? 1 : 0
  metadata {
    name = var.namespace-v-dev
  }
}

## Network_policy   ##

resource "kubernetes_network_policy" "v_dev_default_deny" {
  depends_on = [helm_release.v-dev]
  metadata {
    name      = "v-dev-netpol"
    namespace = kubernetes_namespace.v-dev-ns.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

/*resource "kubernetes_network_policy" "v-dev-np" {
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
}*/
