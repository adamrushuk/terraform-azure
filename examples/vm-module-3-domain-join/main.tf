# Uses Azure VM module with "JsonADDomainExtension" VM extension to domain join to an existing Azure AD Domain Services instance
# Uses local state file

# Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.38.0"
}
terraform {
  required_version = ">= 0.12"
}


# Data sources
# WARNING: doesnt export virtual_network_name needed for subnet, so using var vars and depends_on
data "azurerm_virtual_network" "aadds" {
  name                = var.aadds_vnet_name
  resource_group_name = var.aadds_vnet_resource_group_name
}


# Create new resources
resource "azurerm_subnet" "vm" {
  name                 = "vmsubnet"
  resource_group_name  = var.aadds_vnet_resource_group_name
  virtual_network_name = var.aadds_vnet_name
  address_prefix       = "10.0.1.0/24"
  depends_on           = [data.azurerm_virtual_network.aadds]
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  location            = var.location
  resource_group_name = var.vm_resource_group_name
  nb_instances        = var.vm_count
  vm_hostname         = var.vm_name
  vm_os_simple        = "WindowsServer"
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  nb_public_ip        = var.vm_count
  public_ip_dns       = var.vm_public_ip_dns # change to a unique name per datacenter region
  remote_port         = "3389"
  is_windows_image    = "true"
  vnet_subnet_id      = azurerm_subnet.vm.id
  tags                = var.tags
}

# Domain join extension
# Logs found on target VM here: C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.JsonADDomainExtension\1.3.2
# May need to manually uninstall extension if persistent errors occur, eg:
# "Error: Code="VMExtensionProvisioningError" Message="VM has reported a failure when processing extension 'domjoin'"
resource "azurerm_virtual_machine_extension" "vm" {
  count                = var.vm_count
  name                 = "domjoinext"
  location             = var.location
  resource_group_name  = var.vm_resource_group_name
  virtual_machine_name = "${var.vm_name}${count.index}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # [Optional SETTINGS]
  #                       "NumberOfRetries": "5",
  #                       "RetryIntervalInMilliseconds": "10000",
  #                       "UnjoinDomainUser": "${var.domjoin_user}",
  settings           = <<SETTINGS
                        {
                          "Name": "${var.domain}",
                          "User": "${var.domjoin_user}",
                          "OUPath": "${var.domain_oupath}",
                          "Restart": "true",
                          "Options": "3"
                        }
SETTINGS

  # [Optional PROTECTED_SETTINGS]
  #                       "UnjoinDomainPassword": "${var.domjoin_password}",
  protected_settings = <<PROTECTED_SETTINGS
                        {
                          "Password": "${var.domjoin_password}"
                        }
PROTECTED_SETTINGS

  depends_on         = [module.windowsservers]
}


# TODO: Add local exec to generate RDP files (see notes)

# Ouputs
output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
