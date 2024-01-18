variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

variable "name-v-admin" {
  type    = string
  default = "v-admin"
}

variable "name-v-dev" {
  type    = string
  default = "v-dev"
}


variable "name-v-monitor" {
  type    = string
  default = "v-monitor"
}
variable "namespace-v-admin" {
  type    = string
  default = "administration"
}

variable "namespace-v-dev" {
  type    = string
  default = "development"
}

variable "namespace-v-monitor" {
  type    = string
  default = "administration"
} #https://charts.loft.sh

variable "repository" {
  type    = string
  default = "https://charts.loft.sh"
}