####### modules/vpc/variables.tf
variable "azs" {}
variable "cluster_name" {
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