module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.21.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_kms_key                  = false
  cluster_encryption_config       = {}
  create_cloudwatch_log_group     = false
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  enable_irsa                     = true

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type
  }

  eks_managed_node_groups = {
#    g_two = {}
    g_one = {
      # name = var.node_group_name

      instance_types = var.instance_types

      min_size     = 1
      max_size     = 7
      desired_size = 2

      capacity_type = var.capacity_type_od
      capacity_type = var.capacity_type_sp
    }
  }

  tags = {
    env       = "dev"
    terraform = "true"
  }
}
