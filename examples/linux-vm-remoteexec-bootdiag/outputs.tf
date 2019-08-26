output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.myterraformpublicip.id
}

# This may not show up on the first run
output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.myterraformpublicip.ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.myterraformpublicip.fqdn
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.myterraformpublicip.fqdn}"
}
