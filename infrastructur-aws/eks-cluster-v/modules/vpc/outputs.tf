###### vpc/outputs.tf
output "aws_public_subnet" {
  value = aws_subnet.eks-cluster_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.eks-cluster-vpc.id
}