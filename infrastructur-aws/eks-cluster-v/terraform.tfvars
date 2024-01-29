### Main
cluster_name = "main-eks-vcluster"
region       = "eu-central-1"
### VPC
vpc_id          = "vpc-1234556abcdef"
vpc_name        = "v-main-vpc"
cidr            = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

### EKS
ami_type         = "AL2_x86_64"
node_group_name  = "eks-vcluster-node-group"
instance_types   = ["t3.medium"]
cluster_version  = "1.28"
capacity_type_od = "ON_DEMAND"
capacity_type_sp = "SPOT"
### IAM
arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
role_name = "AmazonEKS_EBS_CSI_DriverRole"
oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
addon_name               = "aws-ebs-csi-driver"
addon_version            = "v1.20.0-eksbuild.1"
### Security Group
name_prefix = "worker_group_mgmt_g_one"
cidr_blocks = ["10.0.0.0/8"]