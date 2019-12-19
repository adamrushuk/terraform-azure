output "azurerm_resource_group" {
  description = "resource group"
  value       = azurerm_resource_group.p2svpn
}

output "azurerm_virtual_wan" {
  description = "virtual wan"
  value       = azurerm_virtual_wan.p2svpn
}

output "azurerm_virtual_hub" {
  description = "virtual hub"
  value       = azurerm_virtual_hub.p2svpn
}

output "azurerm_vpn_server_configuration" {
  description = "vpn configuration"
  value       = azurerm_vpn_server_configuration.p2svpn
}

output "azurerm_point_to_site_vpn_gateway" {
  description = "p2s vpn gateway"
  value       = azurerm_point_to_site_vpn_gateway.p2svpn
}
