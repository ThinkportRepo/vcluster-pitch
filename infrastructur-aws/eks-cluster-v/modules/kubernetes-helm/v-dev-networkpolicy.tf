resource "kubernetes_namespace" "v-dev-ns" {

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


