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
  description = "Art des AMI (Amazon Machine Image) für die EC2-Instanzen"
}
variable "cluster_version" {
  type        = string
  description = "Version des EKS-Clusters"
}
variable "node_group_name" {
  type        = string
  description = "Name der Node-Gruppe im EKS-Cluster"
}
variable "instance_types" {
  type        = list(string)
  description = "Liste der Instanztypen für die EC2-Instanzen in der Node-Gruppe"
}
variable "capacity_type_od" {
  type        = string
  description = ""
}
variable "capacity_type_sp" {
  type        = string
  description = "Kapazitätstyp für die EC2-Instanzen (On-Demand)"
}
### IAM
variable "arn" {
  type        = string
  description = "Amazon Resource Name (ARN) für die IAM-Rolle"
}
variable "role_name" {
  type        = string
  description = "Name der IAM-Rolle"
}
variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = "Vollständig qualifizierte Subjekte für OIDC (OpenID Connect)"
}
variable "addon_name" {
  type        = string
  description = "Name des Add-Ons für den EKS-Cluster"
}
variable "addon_version" {
  type        = string
  description = "Version des Add-Ons für den EKS-Cluster"
}
### Security Group
variable "name_prefix" {
  type        = string
  description = "Präfix für den Namen der Sicherheitsgruppe"
}
variable "cidr_blocks" {
  type        = list(string)
  description = "Liste der CIDR-Blöcke für die Sicherheitsgruppe"
}
