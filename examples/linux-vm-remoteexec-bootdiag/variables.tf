# Declare variables
variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
variable "admin_username" {}
variable "address_space" {
  type = "list"
}
variable "vm_size" {}
variable "vm_image_publisher" {}
variable "vm_image_offer" {}
variable "vm_image_sku" {}
variable "vm_image_version" {}
