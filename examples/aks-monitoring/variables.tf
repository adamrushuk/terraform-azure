variable "prefix" {
  description = "A prefix used for all resources in this example"
  default     = "artesting123"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default     = "uksouth"
}

variable "kubernetes_client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "kubernetes_client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}
