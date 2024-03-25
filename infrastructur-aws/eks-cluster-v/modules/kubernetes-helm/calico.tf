############
## Calico ##
############
resource "helm_release" "calico" {
  name             = "calico"
  repository       = "https://projectcalico.docs.tigera.io/charts"
  chart            = "tigera-operator"
  namespace        = "tigera-operator"
  create_namespace = true
  depends_on       = [helm_release.v-dev, helm_release.v-admin, helm_release.v-prod, helm_release.prometheus]
  set {
    name  = "kubernetesProvider"
    value = "EKS"
  }
}
