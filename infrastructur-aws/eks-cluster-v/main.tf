###### root/main.tf
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
module "eks" {
  source                   = "./modules/eks"
  vpc_id                   = module.vpc.vpc_id
  cluster_name             = var.cluster_name
  subnet_ids               = var.private_subnets
  ami_type                 = var.ami_type
  cluster_version          = var.cluster_version
  node_group_name          = var.node_group_name
  instance_types           = var.instance_types
  capacity_type_od         = var.capacity_type_od
  capacity_type_sp         = var.capacity_type_sp
}

module "vpc" {
  source          = "./modules/vpc"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name    = var.cluster_name
  vpc_name        = var.vpc_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}
module "iam" {
  source = "./modules/iam"
  cluster_name    = var.cluster_name
  arn = var.arn
  role_name = var.role_name
  provider_url                  = module.eks.provider_url
  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
  addon_name               = var.addon_name
  addon_version            = var.addon_version
}
module "security-group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
  cidr_blocks = var.cidr_blocks
  name_prefix = var.name_prefix
}
module "kubernetes" {
  source = "./modules/kubernetes-helm"
  endpoint = module.eks.endpoint
  cluster_name    = var.cluster_name
  cluster_ca_certificate = module.eks.certificate_authority_data
}
