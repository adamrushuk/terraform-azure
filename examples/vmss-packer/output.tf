output "vmss_public_ip" {
  value = "${azurerm_public_ip.vmss.fqdn}"
}

output "jumpbox_public_ip" {
    value = "${azurerm_public_ip.jumpbox.fqdn}"
}

output "jumpbox_ssh_connection" {
  description = "SSH connection command for Jumpbox"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.jumpbox.fqdn}"
}

# TODO: add a data resource using az cli or PS, to get internal IPs
# output "vmss_internal_ips" {
#   description = "Internal IPs from VMSS instances"
#   value       = "${azurerm_virtual_machine_scale_set.vmss.IPs}"
# }
