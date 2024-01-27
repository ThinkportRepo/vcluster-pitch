resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-iam-role.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEBSCSIDriverPolicy
  ]
}

resource "aws_eks_node_group" "eks-cluster-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.iam-eks-role.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEBSCSIDriverPolicy,
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "iam-eks-role" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
/*data "aws_eks_cluster" "cluster" {
  name = var.cluster_name  # Replace with your EKS cluster name variable
}*/


module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"
  create_role                   = false
  role_name                     = "AmazonEKS_EBS_CSI_DriverRole"
  provider_url                  = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
  #data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_role_policy_attachment.eks-cluster-AmazonEBSCSIDriverPolicy.policy_arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.iam-eks-role.name
}



resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = aws_eks_cluster.eks-cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}