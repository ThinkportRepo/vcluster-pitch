/*module "istio" {
  source = "DNXLabs/eks-istio/aws"
  version = "0.2.0"
  enabled                = true
  istiod_enabled         = true
  ingressgateway_enabled = true

  create_namespace = true

}*/
module "eks-calico" {
  source  = "DNXLabs/eks-calico/aws"
  version = "0.1.1"
}