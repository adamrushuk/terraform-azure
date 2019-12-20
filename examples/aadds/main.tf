# TODO: implement merge() to merge single vars with arm param map
# https://www.terraform.io/docs/configuration/functions/merge.html
# locals {}

# Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.39.0"
}
terraform {
  required_version = ">= 0.12"
}


resource "azurerm_resource_group" "aadds" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_template_deployment" "aadds" {
  name                = "aadds-arm-template"
  resource_group_name = azurerm_resource_group.aadds.name
  template_body       = file("${path.module}/arm/template.json")
  parameters = {
    apiVersion              = var.arm_parameters.apiVersion
    domainConfigurationType = var.arm_parameters.domainConfigurationType
    domainName              = var.domain_name
    filteredSync            = var.arm_parameters.filteredSync
    location                = var.location
    subnetName              = var.arm_parameters.subnetName
    vnetName                = var.arm_parameters.vnetName
    vnetAddressPrefixes     = var.arm_parameters.vnetAddressPrefixes
    subnetAddressPrefix     = var.arm_parameters.subnetAddressPrefix
    nsgName                 = var.arm_parameters.nsgName
  }
  deployment_mode = "Incremental"
}
