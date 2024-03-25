#######modules/eks/variables.tf
variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}
variable "vpc_id" {
  type        = string
  description = ""
}
variable "subnet_ids" {
  type        = list(string)
  description = ""
}
variable "ami_type" {
  type        = string
  description = ""
}
variable "cluster_version" {
  type        = string
  description = ""
}
variable "node_group_name" {
  type        = string
  description = ""
}
variable "instance_types" {
  type        = list(string)
  description = ""
}
variable "capacity_type_od" {
  type        = string
  description = ""
}
variable "capacity_type_sp" {
  type        = string
  description = ""
}
