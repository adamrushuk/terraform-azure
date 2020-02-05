variable "location" {
  default = "uksouth"
}

variable "agent_pool_count" {
  default = 2
}


variable "agent_pool_profile_vm_size" {
  default = "Standard_D2_v2"
}

variable "agent_pool_profile_os_type" {
  default = "Linux"
}

variable "agent_pool_profile_disk_size_gb" {
  default = 30
}
