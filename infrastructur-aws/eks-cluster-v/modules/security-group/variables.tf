### Security Group
variable "vpc_id" {
  type        = string
  description = ""
}
variable "name_prefix" {
  type        = string
  description = ""
}
variable "cidr_blocks" {
  type        = list(string)
  description = ""
}