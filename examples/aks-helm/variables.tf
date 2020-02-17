variable "location" {
  default = "uksouth"
}

variable "agent_pool_node_count" {
  default = 1
}

variable "agent_pool_node_min_count" {
  default = 1
}

variable "agent_pool_node_max_count" {
  default = 3
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

variable "agent_pool_enable_auto_scaling" {
  default = true
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

# Use data source: azurerm_client_config
# variable "service_principal_client_id" {
#   default = "__ARM_CLIENT_ID__"
# }

# Create env var: TF_VAR_service_principal_client_secret
variable "service_principal_client_secret" {
  default = "__ARM_CLIENT_SECRET__"
}
