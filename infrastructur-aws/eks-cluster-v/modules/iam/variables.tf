variable "cluster_name" {
  type        = string
  description = ""
}
variable "provider_url" {

  type        = string
  description = ""
}
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