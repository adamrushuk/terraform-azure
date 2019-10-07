provider "azurerm" {
  # Pin version as per best practice
  version = "=1.35.0"
}

resource "random_id" "prefix" {
  byte_length = 8
}
