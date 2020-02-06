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

variable "enable_aks_dashboard" {
  description = "Should Kubernetes dashboard be enabled"
  default     = true
}

variable "admin_username" {
  description = "The admin username of the VM(s) that will be deployed"
  default     = "sysadmin"
}

variable "public_ssh_key_path" {
  description = "Public key path for ssh access to the VM"
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  description = "A map of the tags to use on the resources"

  default = {
    Environment = "Dev"
    Owner       = "Adam Rush"
    Source      = "terraform"
  }
}
