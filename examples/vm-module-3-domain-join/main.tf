# Using VM module with domain join to existing Azure AD Domain Services instance
# Uses local state file

# Local vars
locals {
  location                 = "uksouth"
  vnet_name                = "aadds-vnet"
  vnet_resource_group_name = "aadds-rg"
}


# Configure Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.37.0"
}
terraform {
  required_version = ">= 0.12"
}


# Data sources
# WARNING: doesnt export virtual_network_name needed for subnet, so using local vars and depends_on
data "azurerm_virtual_network" "aadds" {
  name                = local.vnet_name
  resource_group_name = local.vnet_resource_group_name
}


# Create new resources
resource "azurerm_subnet" "vm" {
  name                 = "vmsubnet"
  resource_group_name  = local.vnet_resource_group_name
  virtual_network_name = local.vnet_name
  address_prefix       = "10.0.1.0/24"
  depends_on           = [data.azurerm_virtual_network.aadds]
}

module "windowsservers" {
  source           = "Azure/compute/azurerm"
  location         = local.location
  vm_hostname      = "domjoinvm"
  vm_os_simple     = "WindowsServer"
  admin_password   = "ComplxP@ssw0rd!"
  admin_username   = "sysadmin"
  public_ip_dns    = ["asr999winsimplevmips"] # change to a unique name per datacenter region
  remote_port      = "3389"
  is_windows_image = "true"
  vnet_subnet_id   = azurerm_subnet.vm.id
}


# Ouputs
output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
