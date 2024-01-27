output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.eks-cluster.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}