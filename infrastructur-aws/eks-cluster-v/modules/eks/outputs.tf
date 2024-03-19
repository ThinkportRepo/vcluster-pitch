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