/*module "istio" {
  source = "DNXLabs/eks-istio/aws"
  version = "0.2.0"
  enabled                = true
  istiod_enabled         = true
  ingressgateway_enabled = true

  create_namespace = true

}*/
/*module "eks-calico" {
  source  = "DNXLabs/eks-calico/aws"
  version = "0.1.1"
}*/
/*module "eks_calico" {
  source  = "akw-devsecops/eks/aws//modules/calico"
  version = "2.6.8"
}*/
############
## Calico ##
############
resource "helm_release" "calico" {
  name             = "calico"
  repository       = "https://projectcalico.docs.tigera.io/charts"
  chart            = "tigera-operator"
  namespace        = "tigera-operator"
  create_namespace = true
  depends_on = [helm_release.v-dev,helm_release.v-admin,helm_release.v-prod]
  set {
    name  = "kubernetesProvider"
    value = "EKS"
  }
}
