resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

locals {
  aks_cluster_name             = "${random_string.random.result}-aks-ar"
  log_analytics_workspace_name = "${local.aks_cluster_name}-workspace"
}

resource "azurerm_resource_group" "aks" {
  name     = "${random_string.random.result}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "aks" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aks.location
  resource_group_name   = azurerm_resource_group.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = local.aks_cluster_name

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    node_count          = var.agent_pool_node_count
    vm_size             = var.agent_pool_profile_vm_size
    os_disk_size_gb     = var.agent_pool_profile_disk_size_gb
    enable_auto_scaling = var.agent_pool_enable_auto_scaling
    min_count           = var.agent_pool_node_min_count
    max_count           = var.agent_pool_node_max_count
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = file(var.public_ssh_key_path)
    }
  }

  service_principal {
    # Use current logged in client
    client_id = data.azurerm_client_config.current.client_id
    # Use env var TF_VAR_service_principal_client_secret
    client_secret = var.service_principal_client_secret
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_aks_dashboard
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      service_principal,
      default_node_pool[0].node_count,
      # addon_profile,
    ]
  }
}
