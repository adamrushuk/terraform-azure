# Declare variables
variable "environment" {}
variable "location" {}
variable "resource_group_name" {}

variable "admin_username" {}
variable "admin_password" {}

variable "address_space" {
  type = list
}

variable "vm_image_publisher" {}
variable "vm_image_offer" {}
variable "vm_image_sku" {}
variable "vm_image_version" {}

variable "scaleset_vm_size" {}
variable "scaleset_capacity" {}
