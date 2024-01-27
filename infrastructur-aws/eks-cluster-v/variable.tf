locals {
  cluster_name = "main-eks-vcluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}