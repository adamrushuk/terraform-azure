resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

locals {
  aks_cluster_name = "${random_string.random.result}-aks-ar"
}

resource "azurerm_resource_group" "aks" {
  name     = "${random_string.random.result}-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = local.aks_cluster_name

  default_node_pool {
    name            = "default"
    node_count      = var.agent_pool_count
    vm_size         = var.agent_pool_profile_vm_size
    os_disk_size_gb = var.agent_pool_profile_disk_size_gb
  }

  service_principal {
    client_id     = azuread_application.aks_sp.application_id
    client_secret = random_password.aks_sp_pwd.result
  }

  tags = {
    Environment = "dev"
  }
}
