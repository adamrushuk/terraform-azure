# TODO: implement merge() to merge single vars with arm param map
# https://www.terraform.io/docs/configuration/functions/merge.html
# locals {}

# TODO: Add local-exec to handle proper ARM template destroy, as per:
# https://medium.com/@charotamine/terraform-azure-terraform-destroy-6bc0151fe0bd

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
  # Bugfix: remove the schema and version lines from the parameters file
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1437
  parameters_body = file("${path.module}/arm/parameters.json")
  deployment_mode = "Incremental"
}
