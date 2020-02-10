# Providers / versions
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  # Pin version as per best practice
  version = "=1.43.0"
}

# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
#   username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
#   password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
# }

# Check latest release notes and CHANGELOG
# https://github.com/terraform-providers/terraform-provider-helm/blob/master/CHANGELOG.md
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
    password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}
