
/*resource "aws_eks_cluster" "cluster" {
  name     = data.aws_eks_cluster.cluster.name
  role_arn   = aws_iam_role_policy_attachment.ebs_csi.policy_arn
  depends_on = [aws_iam_role_policy_attachment.ebs_csi]
  vpc_config = module.vpc.vpc_id
}*/

resource "aws_iam_role" "ebs_csi_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  // Assume role policy for EKS
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
