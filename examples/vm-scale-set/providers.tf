# Configure Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.44.0"
}
terraform {
  required_version = ">= 0.12"
}
