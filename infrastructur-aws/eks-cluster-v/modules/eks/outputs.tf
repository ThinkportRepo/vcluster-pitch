/*
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
}*/

output "provider_url" {
  value = module.eks.oidc_provider
}
output "certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}