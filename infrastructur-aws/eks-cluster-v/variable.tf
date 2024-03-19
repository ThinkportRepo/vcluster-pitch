### Main
variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}
variable "region" {
  type        = string
  description = "AWS region"
}
### VPC
variable "vpc_id" {
  type        = string
  description = ""
}
variable "vpc_name" {
  type        = string
  description = ""
}
variable "cidr" {
  type        = string
  description = ""
}
variable "private_subnets" {
  type        = list(string)
  description = ""
}
variable "public_subnets" {
  type        = list(string)
  description = ""
}
### EKS
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
### IAM
variable "arn" {
  type        = string
  description = ""
}
variable "role_name" {
  type        = string
  description = ""
}
variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = ""
}
variable "addon_name" {
  type        = string
  description = ""
}
variable "addon_version" {
  type        = string
  description = ""
}
### Security Group
variable "name_prefix" {
  type        = string
  description = ""
}
variable "cidr_blocks" {
  type        = list(string)
  description = ""
}
