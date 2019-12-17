variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
}
