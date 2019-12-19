# Output commands to test connectivity
# https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke#test-connectivity--linux
output "step1_connect_to_onprem_vm" {
  description = "SSH connection command"
  value       = "ssh ${var.username}@${azurerm_public_ip.onprem-pip.ip_address}"
}

output "step2_test_hub_vm_private_ip_connection" {
  description = "HUB VM Connection Test Command"
  value       = "nc -vzw 1 ${azurerm_network_interface.hub-nic.private_ip_address} 22"
}

output "step3_test_nva_vm_private_ip_connection" {
  description = "NVA VM Connection Test Command"
  value       = "nc -vzw 1 ${azurerm_network_interface.hub-nva-nic.private_ip_address} 22"
}

output "step4_test_spoke1_vm_private_ip_connection" {
  description = "Spoke 1 VM Connection Test Command"
  value       = "nc -vzw 1 ${azurerm_network_interface.spoke1-nic.private_ip_address} 22"
}

output "step5_test_spoke2_vm_private_ip_connection" {
  description = "Spoke 2 VM Connection Test Command"
  value       = "nc -vzw 1 ${azurerm_network_interface.spoke2-nic.private_ip_address} 22"
}
