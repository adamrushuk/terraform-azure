# Using VM modules
# Uses local state file

# Configure Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.33.1"
}
terraform {
  required_version = ">= 0.12"
}

module "linuxservers" {
  source         = "Azure/compute/azurerm"
  location       = "West US 2"
  vm_os_simple   = "UbuntuServer"
  public_ip_dns  = ["asr999linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id = "${module.network.vnet_subnets[0]}"
}

module "windowsservers" {
  source           = "Azure/compute/azurerm"
  location         = "West US 2"
  vm_hostname      = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password   = "ComplxP@ssw0rd!"
  vm_os_simple     = "WindowsServer"
  is_windows_image = "true"
  public_ip_dns    = ["asr999winsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id   = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "~> 1.1.1"
  location            = "West US 2"
  allow_rdp_traffic   = "true"
  allow_ssh_traffic   = "true"
  resource_group_name = "terraform-compute"
}

output "linux_vm_public_name" {
  value = "${module.linuxservers.public_ip_dns_name}"
}

output "windows_vm_public_name" {
  value = "${module.windowsservers.public_ip_dns_name}"
}
