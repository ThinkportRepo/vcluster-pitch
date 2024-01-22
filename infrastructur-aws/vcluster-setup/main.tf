# call the terraform-aws-eks module to deploy your EKS cluster
module "eks_cluster" {
  source       = "../eks-main-cluster"
  # cluster_name = data.aws_eks_cluster.cluster.id
}

/*resource "kubernetes_namespace" "administration" {
  metadata {
    name = var.namespace-v-admin
  }
}*/

/*resource "helm_release" "v-dev" {
  chart      = "vcluster-eks"
  name       = var.name-v-dev
  namespace  = var.namespace-v-dev
  create_namespace = true
  repository = var.loft-repository

  set {
    name  = "repository-config"
    value = true
  }

  values = [
    file("config-vcluster/vcluster.yaml")
  ]
}*/

resource "helm_release" "v-dev" {
  name       = var.name-v-dev
  namespace  = var.namespace-v-dev
  create_namespace = true
  chart      = var.loft-chart
  repository = var.loft-repository
  version          = var.loft-version

  values = [
    file("config-vcluster/vcluster.yaml"),
    file("config-vcluster/dev-values.yaml")
  ]
}
 resource "helm_release" "v-admin" {
   name             = var.name-v-admin
   namespace        = var.namespace-v-admin
   create_namespace = true
   repository       = var.loft-repository
   chart            = var.loft-chart
   version          = var.loft-version

  values = [
    file("config-vcluster/vcluster.yaml"),
    file("config-vcluster/admin-values.yaml")
  ]
 }
 resource "helm_release" "v-prod" {
   name             = var.name-v-prod
   namespace        = var.namespace-v-prod
   create_namespace = true
   repository       = var.loft-repository
   chart            = var.loft-chart
   version          = var.loft-version
  values = [
    file("config-vcluster/vcluster.yaml"),
    file("config-vcluster/prod-values.yaml")
  ]
 }


resource "kubernetes_manifest" "v_dev_ingress" {
  depends_on = [
    helm_release.v-dev
  ]
  manifest = yamldecode(file("vcluster-admin-ing.yaml"))
}
