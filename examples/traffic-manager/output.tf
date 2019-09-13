output "web_server_rg_name" {
  value = "${azurerm_resource_group.web_server_rg.name}"
}

output "web_server_lb_public_ip_id" {
  value = "${azurerm_public_ip.web_server_lb_public_ip.id}"
}

output "web_server_vnet_id" {
  value = "${azurerm_virtual_network.web_server_vnet.id}"
}

output "web_server_vnet_name" {
  value = "${azurerm_virtual_network.web_server_vnet.name}"
}
