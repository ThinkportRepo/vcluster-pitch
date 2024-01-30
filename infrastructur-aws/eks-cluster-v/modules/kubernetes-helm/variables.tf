variable "cluster_name" {
  type        = string
  description = ""
}
variable "endpoint" {
  type        = string
  description = ""
}
variable "cluster_ca_certificate" {
  type        = string
  description = ""
}
## Prometheus && Grafana
variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "create_namespace_prometheus" {
  type        = bool
  default     = true
  description = "Whether to create Prometheus Kubernetes namespace with name defined by `namespace`."
}

variable "create_namespace_grafana" {
  type        = bool
  default     = true
  description = "Whether to create Grafana Kubernetes namespace with name defined by `namespace`."
}

variable "namespace_prometheus" {
  type        = string
  default     = "prometheus"
  description = "Kubernetes namespace to deploy Prometheus stack Helm charts."
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable."
}

# Prometheus

variable "settings_prometheus" {
  default = {
    alertmanager = {
      persistentVolume = {
        storageClass = "gp2"
      }
    }
    server = {
      persistentVolume = {
        storageClass = "gp2"
      }
    }
  }
  description = "Additional settings which will be passed to Prometheus Helm chart values."
}

variable "helm_chart_prometheus_release_name" {
  type        = string
  default     = "prometheus"
  description = "Prometheus Helm release name"
}

variable "helm_chart_prometheus_name" {
  type        = string
  default     = "prometheus"
  description = "Prometheus Helm chart name to be installed"
}

variable "helm_chart_prometheus_version" {
  type        = string
  default     = "25.9.0"
  description = "Prometheus Helm chart version."
}

variable "helm_chart_prometheus_repo" {
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  description = "Prometheus repository name."
}
### VCLUSTER
variable "name-v-admin" {
  type    = string
  default = "admin-vcluster"
}

variable "name-v-dev" {
  type    = string
  default = "dev-vcluster"
}

variable "name-v-prod" {
  type    = string
  default = "prod-vcluster"
}

## namespaces
variable "namespace-v-admin" {
  type    = string
  default = "administration"
}

variable "namespace-v-dev" {
  type    = string
  default = "development"
}

variable "namespace-v-prod" {
  type    = string
  default = "production"
} #https://charts.loft.sh

## helm values
variable "loft-repository" {
  type    = string
  default = "https://charts.loft.sh"
}

variable "loft-chart" {
  type    = string
  default = "vcluster"
}
variable "loft-version" {
  type    = string
  default = "0.19.0-alpha.4"
}
