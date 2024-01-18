# call the terraform-aws-eks module to deploy your EKS cluster
module "eks_cluster" {
  source       = "../eks-cluster"
  # cluster_name = data.aws_eks_cluster.cluster.id
}

/*resource "kubernetes_namespace" "administration" {
  metadata {
    name = var.namespace-v-admin
  }
}*/
resource "helm_release" "v-dev" {
  chart      = "vcluster-eks"
  name       = var.name-v-dev
  namespace  = var.namespace-v-dev
  create_namespace = true
  repository = var.repository

  set {
    name  = "repository-config"
    value = true
  }

  values = [
    file("config-vcluster/vcluster.yaml")
  ]
}
 resource "helm_release" "v-cluster_admin" {
   name             = "admin-vcluster"
   namespace        = "administration"
   create_namespace = true
   repository       = "https://charts.loft.sh"
   chart            = "vcluster-eks"
   version          = "0.18.1"
 }
