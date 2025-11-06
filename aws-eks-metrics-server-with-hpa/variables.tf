variable "environment" {
    type        = string
    description = "Environment"
}

variable "helm_name" {
    type        = string
    default     = "metrics-server"
    description = "Name of the metrics-server resources"
}

variable "helm_chart" {
    type        = string
    default     = "metrics-server"
    description = "Name of the helm chart"
}
variable "helm_metrics_namespace" {
    type        = string
    default     = "kube-system"
    description = "Namespace to deploy the metrics-server."
}

variable "web_namespace" {
    type        = string
    description = "app namespace."
}

variable "helm_chart_version" {
    type        = string
    default     = "3.11.0"
    description = "Helm Chart metrics-server version to use."
}

variable "helm_repository" {
    type        = string
    default     = "https://kubernetes-sigs.github.io/metrics-server/"
    description = "Helm Repository to pull from"
}
