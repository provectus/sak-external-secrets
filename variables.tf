variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "A name of the existing namespace"
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "6.0.0"
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

variable "chart_repository" {
  type        = string
  description = "A chart repository"
  default     = "https://external-secrets.github.io/kubernetes-external-secrets/"
}

variable "chart_name" {
  type        = string
  description = "A name of the chart"
  default     = "kubernetes-external-secrets"
}

variable "chart_values" {
  type        = map(string)
  default     = {}
  description = "Chart values"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "allowed_secrets_prefix" {
  type        = string
  description = "Prefix of for secrets we should be able to access from the external-secrets app?"
  default     = ""
}

variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}
