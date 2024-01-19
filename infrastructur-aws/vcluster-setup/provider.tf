
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
  required_version = "~> 1.3"
}
/*
data "aws_eks_cluster" "hr-dev-eks-demo" {
  name = "hr-dev-eks-demo"
}
data "aws_eks_cluster_auth" "hr-dev-eks-demo_auth" {
  name = "hr-dev-eks-demo_auth"
}*/
