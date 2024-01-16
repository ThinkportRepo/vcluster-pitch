#####################
# Datei für AWS VPC #
#####################

# Die VPC verfügt über drei öffentliche und private Subnetze
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "main-cluster-vpc-${random_string.suffix.result}"

  cidr = "10.0.0.0/16" #Die erstellung der AWS VPC des CIDR-Bereichs 10.0.0.0/16 in der Region eu-central-1
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # Aktivierung der Das NAT-Gateway und der DNS-Hostname.
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}