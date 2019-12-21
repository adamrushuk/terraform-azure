variable "location" {
  description = "The location/region where resources are created"
  default     = "uksouth"
}


# AADDS - Specify your domain details
variable "domain" {
  description = "Your Azure AD DS managed domain"
  default     = "myaaddsdomain.onmicrosoft.com"
}

# Use "User name" shown in Azure AD: https://portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/AllUsers
# It should show UPN format, eg: joebloggs@mydomain.onmicrosoft.com
variable "domain_user_upn" {
  description = "Specify a user (in UPN format, eg: joebloggs@mydomain.onmicrosoft.com) that belongs to the 'AAD DC Administrators' group. Only members of this group have privileges to join machines to the Azure AD DS managed domain. The account must be part of the Azure AD DS managed domain or Azure AD tenant - accounts from external directories associated with your Azure AD tenant can't correctly authenticate during the domain-join process. Use the 'User name' shown in Azure AD here: https://portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/AllUsers"
  default     = ""
}

variable "domain_password" {
  description = "Specify a password for a user that belongs to the 'AAD DC Administrators' group. Only members of this group have privileges to join machines to the Azure AD DS managed domain. The account must be part of the Azure AD DS managed domain or Azure AD tenant - accounts from external directories associated with your Azure AD tenant can't correctly authenticate during the domain-join process"
  default     = ""
}

variable "domain_oupath" {
  description = "Specify the OU that the joined computer will be placed. This OU MUST exist first. The default 'OU=AADDC Computers,DC=myaaddsdomain,DC=onmicrosoft,DC=com' is created when a 'Azure AD Domain Services' instance is provisioned."
  default     = "OU=AADDC Computers,DC=myaaddsdomain,DC=onmicrosoft,DC=com"
}


# AADDS - these shouldn't need changing
variable "aadds_vnet_resource_group_name" {
  description = "The name of the resource group where the aadds vnet exists. Azure AD Domain Services uses the default: 'aadds-rg'"
  default     = "aadds-rg"
}

variable "aadds_vnet_name" {
  description = "The name of the aadds vnet. Azure AD Domain Services uses the default: 'aadds-vnet'"
  default     = "aadds-vnet"
}


# VM
variable "vm_resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "terraform-compute-rg"
}

variable "vm_admin_username" {
  description = "The admin username of the VM(s) that will be deployed"
  default     = "sysadmin"
}

variable "vm_admin_password" {
  description = "The admin password of the VM(s) that will be deployed. The password must meet the complexity requirements of Azure"
  default     = ""
}

variable "vm_name" {
  description = "Name of the VM. Numbers will be appended if more than 1 VM is defined."
  default     = "domjoin"
}

variable "vm_count" {
  description = "The number of VM instances"
  default     = 1
}

variable "vm_public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [""]
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine"
  default     = "Standard_DS2_v2"
}


# Misc
variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources"

  default = {
    Environment = "Dev"
    Owner       = "Adam Rush"
    Source      = "terraform"
  }
}
