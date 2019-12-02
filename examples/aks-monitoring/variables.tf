variable "prefix" {
  description = "A prefix used for all resources in this example"
  default     = "artesting123"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default     = "uksouth"
}

variable "node_count" {
  description = "The initial number of nodes which should exist within this Node Pool"
  default     = 2
}

variable "kubernetes_client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "kubernetes_client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}
