variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "A name of the existing namespace"
}

variable "aws_region" {
  type        = string
  description = "A name of the AWS region (us-central-1, us-west-2 and etc.)"
  default     = ""
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "0.6.0"
}

variable "poller_interval" {
  type        = string
  description = "Interval of refreshing values from secrets manager in ms"
  default     = "30000"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_oidc_url" {
  type        = string
  description = "oidc issuer url of the eks cluster"
}

variable "chart_repository" {
  type        = string
  description = "A chart repository"
  default     = "https://charts.external-secrets.io"
}

variable "chart_values" {
  type        = string
  default     = ""
  description = "Chart values"
}

variable "chart_parameters" {
  type        = list
  default     = []
  description = "A list of parameters that will override defaults"
}

variable "chart_parameters_as_string" {
  type        = list
  default     = []
  description = "A list of parameters that will override defaults"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}
