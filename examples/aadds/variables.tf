# General
variable "location" {
  description = "The location/region where resources are created"
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "aadds-rg"
}

# AADDS
variable "domain_name" {
  description = "Your Azure AD DS managed domain"
  default     = "mydomain.onmicrosoft.com"
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
