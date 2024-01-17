output "cluster_endpoint" {
  description = "Endpoint für EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Sicherheitsgruppen-IDs, die der Cluster-Control-Plane zugeordnet sind"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_id" {
  description = "Kubernetes Cluster ID"
    value = module.eks.cluster_id
}

# EKS Security Group ID
output "eks_security_group_id" {
  value = aws_security_group.all_worker_mgmt.id
}