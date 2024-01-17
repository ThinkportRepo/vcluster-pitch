#############################
# Datei für den EKS-Cluster #
#############################
# AWS EKS-Modul zur EKS-Cluster-Erstellung

locals {
  cluster_name = "main-cluster-eks-${random_string.suffix.result}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }
  # Erstellung 2 Worker-Gruppen mit der gewünschten Kapazität von 3 Instanzen vom Typ t2.micro.
  eks_managed_node_groups = {
    #  die Anbindung der erstellten Sicherheitsgruppe an beide Worker-Knotengruppen.
    one = {
      name = "node-group-${random_string.suffix.result}"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}


data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [aws_iam_role_policy_attachment.ebs_csi]
}
data "aws_eks_cluster_auth" "cluster_name" {
  name = module.eks.cluster_name
}